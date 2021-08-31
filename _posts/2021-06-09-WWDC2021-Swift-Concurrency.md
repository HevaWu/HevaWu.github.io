---
layout: post
title: WWDC2021 Swift Concurrency
date: 2021-06-09 10:55:00
comment_id: 162
categories: [WWDC2021, Swift]
tags: [Concurrency, iOS15]
---

# Structured Programming

Previous implementation with completion block is `static scope`:

![](/images/2021-06-09-WWDC2021-Swift-Concurrency/static.png#simulator)

This can let program execution flows from top to bottom.

## Tasks in Swift

- A task provides a new `async` context for executing code concurrently
- Swift checks usage of tasks to help prevent concurrency bugs
- When calling an async function a task is `not created`

## Bindings

- Sequential bindings

![](/images/2021-06-09-WWDC2021-Swift-Concurrency/sequential.png#simulator)

- Concurrent bindings

![](/images/2021-06-09-WWDC2021-Swift-Concurrency/concurrent.png#simulator)

Use `async let` for fix amount of concurrency available.

```swift
func fetchOneThumbnail(withID id: String) async throws -> UIImage {
    let imageReq = imageRequest(for: id), metadataReq = metadataRequest(for: id)
    async let (data, _) = URLSession.shared.data(for: imageReq)
    async let (metadata, _) = URLSession.shared.data(for: metadataReq)
    guard let size = parseSize(from: try await metadata),
        let image = try await UIImage(data: data)?.byPreparingThumbnail(ofSize: size) else {
        throw ThumbnailFailedError()
    }
    return image
}
```

## Cancellation is cooperative

- Tasks are not stopped immediately when cancelled
- Cancellation can be checked from anywher
- Design with cancellation in mind

```swift
// obtain cancellation status of the current task
func fetchThumbnails(for ids: [String]) async throws -> [String: UIImage] {
    var thumbnails: [String: UIImage] = [:]
    for id in ids {
        if Task.isCancelled { break }
        thumbnails[id] = try await fetchOneThumbnail(withID: id)
    }
    return thumbnails
}
```

## Group tasks

Take this sample:

```swift
func fetchThumbnails(for ids: [String]) async throws -> [String: UIImage] {
    var thumbnails: [String: UIImage] = [:]
    for id in ids {
        thumbnails[id] = try await fetchOneThumbnail(withID: id)
    }
    return thumbnails
}

func fetchOneThumbnail(withID id: String) async throws -> UIImage {
    ...
    async let (data, _) = URLSession.shared.data(for: imageReq)
    async let (metadata, _) = URLSession.shared.data(for: metadataReq)
    ...
}
```

- `async let` will see each 2 subtasks must be completed before next for loop iteration begin
- for fetch all of thumbnails concurrently, use `task group`, this is for provide dynamic amount of concurrency.

Change above code by ⬇️, using `withThrowingTaskGroup`

![](/images/2021-06-09-WWDC2021-Swift-Concurrency/group.png#simulator)

## Date-race safety

- Task creation takes a `@Sendable` closure
- Cannot capture mutable variables
- Should only capture value types, actors or classes that implement own synchronization

To avoid data race, using ⬇️

```swift
func fetchThumbnails(for ids: [String]) async throws -> [String: UIImage] {
    var thumbnails: [String: UIImage] = [:]
    // return key value in group
    try await withThrowingTaskGroup(of: (String, UIImage).self) { group in
        for id in ids {
            group.async {
                return (id, try await fetchOneThumbnail(withID: id))
            }
        }
        // this part is sequentially, can safely add
        for try await (id, thumbnail) in group {
            thumbnails[id] = thumbnail
        }
    }
    return thumbnails
}
```

# Unstructured tasks

- Some tasks need to launch from non-async contexts
- Some tasks live beyond the confines of a single scope

For example, some delegate

```swift
// create unstructured task
@MainActor
class MyDelegate: UICollectionViewDelegate {
    func collectionView(_ view: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt item: IndexPath) {
        let ids = getThumbnailIDs(for: item)
        async {
            let thumbnails = await fetchThumbnails(for: ids)
            display(thumbnails, in: cell)
        }
    }
}
```

- Inherit actor isolation and priority of the origin context
- Lifetime is not confined to any scope
- Can be launched anywhere, even non-async functions
- Must be manually `cancelled` or `awaited`

```swift
// cancel unstructured task
@MainActor
class MyDelegate: UICollectionViewDelegate {
    var thumbnailTasks: [IndexPath: Task.Handle<Void, Never>] = [:]
    func collectionView(_ view: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt item: IndexPath) {
        let ids = getThumbnailIDs(for: item)
        thumbnailTasks[item] = async {
            let thumbnails = await fetchThumbnails(for: ids)
            display(thumbnails, in: cell)
        }
    }

    func collectionView(_ view: UICollectionView,
                        didEndDisplay cell: UICollectionViewCell,
                        forItemAt item: IndexPath) {
        thumbnailTasks[item]?.cancel()
    }
}
```

## Detached Tasks

- Unscoped lifetime, manually cancelled and awaited
- Do not inherit anything form their originating context
- Optional parameters control priority and other traits

```swift
// detaching a task, create a task group inside a detached task
@MainActor
class MyDelegate: UICollectionViewDelegate {
    var thumbnailTasks: [IndexPath: Task.Handle<Void, Never>] = [:]
    func collectionView(_ view: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt item: IndexPath) {
        let ids = getThumbnailIDs(for: item)
        thumbnailTasks[item] = async {
            defer { thumbnailTasks[item] = nil }
            let thumbnails = await fetchThumbnails(for: ids)
            asyncDetached(priority: .background) {
                withTaskGroup(of: Void.self) { g in
                    g.async { writeToLocalCache(thumbnails) }
                    g.async { log(thumbnails) }
                    g.async { ... }
                }
            }
            display(thumbnails, in: cell)
        }
    }
}
```

![](/images/2021-06-09-WWDC2021-Swift-Concurrency/tasks.png)

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

- <https://developer.apple.com/wwdc21/10132>
- <https://developer.apple.com/wwdc21/10134>
