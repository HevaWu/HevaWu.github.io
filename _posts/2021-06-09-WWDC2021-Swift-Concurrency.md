---
layout: post
title: Swift Concurrency
date: 2021-06-09 10:55:00
comment_id: 162
categories: [WWDC2021, Swift]
tag: [Concurrency, iOS15]
---

# Async/Await

`async` is more like suspend.

- as-is
  ![](/images/2021-06-09-WWDC2021-Swift-Concurrency/normal.png)
- to-be
  ![](/images/2021-06-09-WWDC2021-Swift-Concurrency/async.png)

```swift
// as-is
func fetchThumbnail(for id: String, completion: @escaping (UIImage?, Error?) -> Void) {
    let request = thumbnailURLRequest(for: id)
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(nil, error)
        } else if (response as? HTTPURLResponse)?.statusCode != 200 {
            completion(nil, FetchError.badID)
        } else {
            guard let image = UIImage(data: data!) else {
                completion(nil, FetchError.badImage)
                return
            }
            image.prepareThumbnail(of: CGSize(width: 40, height: 40)) { thumbnail in
                guard let thumbnail = thumbnail else {
                    completion(nil, FetchError.badImage)
                    return
                }
                completion(thumbnail, nil)
            }
        }
    }
    task.resume()
}

// to-be
func fetchThumbnail(for id: String) async throws -> UIImage {
    let request = thumbnailURLRequest(for: id)
    let (data, response) = try await URLSession.shared.data(for: request)
    guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badID }
    let maybeImage = UIImage(data: data)
    // thumbnail property is async
    guard let thumbnail = await maybeImage?.thumbnail else { throw FetchError.badImage }
    return thumbnail
}
```

Both function and property can be async.

## Async properties

- `get` can also throw: `get async`
- Only read-only properties can be `async`

```swift
extension UIImage {
    var thumbnail: UIImage? {
        get async {
            let size = CGSize(width: 40, height: 40)
            return await self.byPreparingThumbnail(ofSize: size)
        }
    }
}
```

## Async sequences

- `await` works in `for` loops

```swift
for await id in staticImageIDsURL.lines {
    let thumbnail = await fetchThumbnail(for: id)
    collage.add(thumbnail)
}
let result = await collage.draw()
```

## Async working flow

Take `fetchThumbnail(for id:) async throws -> UIImage` as an example:

- `URLSession.shared.data`: async function, when it calls, give control of the thread to system. Ask system to schedule work for it.
- system control thread, job might not start immediately. Thread can be used for other things.
- once data finishes, back to `fetchThumbnail`.

When function suspend, system state might change a lot.

## Aync/Await facts

- `async` enables function to suspend
- `await` marks where an async function may suspend execution
- other work can happen during suspension
- once an awaited async call completes, execution resumes after the `await`

## Testing async code

```swift
// as-is
class MockViewModelSpec: XCTestCase {
    func testFetchThumbnails() throws {
        let expectation = XCTestExpectation(description: "mock thumbnails completion")
        self.mockViewModel.fetchThumbnail(for: mockID) { result, error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
}

// to-be
class MockViewModelSpec: XCTestCase {
    func testFetchThumbnails() async throws {
        XCTAssertNoThrow(try await self.mockViewModel.fetchThumbnail(for: mockID))
    }
}
```

## Bridging from sync to async

```swift
struct ThumbnailView: View {
    @ObservedObject var viewModel: ViewModel
    var post: Post
    @State private var image: UIImage?

    var body: some View {
        Image(uiImage: self.image ?? placeholder)
            .onAppear {
                async {
                    self.image = try? await self.viewModel.fetchThumbnail(for: post.id)
                }
            }
    }
}
```

## Aync APIs in the SDK

![](/images/2021-06-09-WWDC2021-Swift-Concurrency/sdk.png)

## Aync alternatives and continuations

Use `Continuations`

- `resume` must be called exactly once on every path
- if continuation without `resume`, swift will call warnings

```swift
// as-is
func getPersistentPosts(completion: @escaping ([Post], Error?) -> Void) {
    do {
        let req = Post.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        let asyncRequest = NSAsynchronousFetchRequest<Post>(fetchRequest: req) { result in
            completion(result.finalResult ?? [], nil)
        }
        try self.managedObjectContext.execute(asyncRequest)
    } catch {
        completion([], error)
    }
}

// to-be
func persistentPosts() async throws -> [Post] {
    typealias PostContinuation = CheckedContinuation<[Post], Error>
    return try await withCheckedThrowingContinuation { (continuation: PostContinuation) in
        self.getPersistentPosts { posts, error in
            if let error = error {
                continuation.resume(throwing: error)
            } else {
                continuation.resume(returning: posts)
            }
        }
    }
}
```

More examples:

```swift
class ViewController: UIViewController {
    private var activeContinuation: CheckedContinuation<[Post], Error>?
    func sharedPostsFromPeer() async throws -> [Post] {
        try await withCheckedThrowingContinuation { continuation in
            self.activeContinuation = continuation
            self.peerManager.syncSharedPosts()
        }
    }
}

extension ViewController: PeerSyncDelegate {
    func peerManager(_ manager: PeerManager, received posts: [Post]) {
        self.activeContinuation?.resume(returning: posts)
        self.activeContinuation = nil // guard against multiple calls to resume
    }

    func peerManager(_ manager: PeerManager, hadError error: Error) {
        self.activeContinuation?.resume(throwing: error)
        self.activeContinuation = nil // guard against multiple calls to resume
    }
}
```

#### Reference

- https://developer.apple.com/wwdc21/10132
