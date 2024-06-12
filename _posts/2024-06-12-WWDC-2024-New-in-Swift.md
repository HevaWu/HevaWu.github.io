---
layout: post
title: WWDC 2024 New in Swift
date: 2024-06-12 20:47:29
comment_id: 245
categories: [WWDC2024, Swift]
---

![](/images/2024-06-12-WWDC-2024-New-in-Swift/SwiftOverTheYears.png)

## Supported platforms

- Apple
- Linux
- Windows
- WebAssembly
- Ubuntu
- Amazon Linux
- CentOS
- Red Hat UBI
- Fedora
- Debian

## Static Linux SDK for Swift

```
--swift-sdk aarch64-swift-linux-musl
```

Identify which SDK to build against.

- Built the service for macOS on macOS
- Installed fully static Linux SDK for Swift
- Built the service for Linux on macOS

## Swift everywhere

![](/images/2024-06-12-WWDC-2024-New-in-Swift/swiftEverywhere.png)

### Swift Testing

```swift
// Swift Testing - Customize test's name / organize test function with tags / parameterize test with arguments

import Testing

@Test("Recognized rating",
       .tags(.critical),
       arguments: [
           (1, "A Beach",       "⭐️⭐️⭐️⭐️⭐️"),
           (2, "Mystery Creek", "⭐️⭐️⭐️⭐️"),
       ])
func rating(videoId: Int, videoName: String, expectedRating: String) {
    let video = Video(id: videoId, name: videoName)
    #expect(video.rating == expectedRating)
}
```

### Implicitly built modules

![](/images/2024-06-12-WWDC-2024-New-in-Swift/implicitlyBuilt.png)

### Explicitly built modules

- More parallelism in builds
- Better visibility into build steps
- Improved reliability of builds
- Faster debugger start-up

![](/images/2024-06-12-WWDC-2024-New-in-Swift/explicitlyBuilt.png)

## Language updates

- github.com/swiftlang

### Noncopyable types

- Supported in all generic contexts
- Standard library support for `Optional`, `Result`, `Unsafe Pointers`

```swift
// Before
struct File: ~Copyable {
  private let fd: CInt

  init(descriptor: CInt) {
    self.fd = descriptor
  }

  func write(buffer: [UInt8]) {
    // ...
  }

  deinit {
    close(fd)
  }
}

guard let fd = open(name) else {
  return
}
let file = File(descriptor: fd)
file.write(buffer: data)

// After
struct File: ~Copyable {
  private let fd: CInt

  init?(name: String) {
    guard let fd = open(name) else {
      return nil
    }
    self.fd = fd
  }

  func write(buffer: [UInt8]) {
    // ...
  }

  deinit {
    close(fd)
  }
}
```

### Embedded Swift

- Small and standalone binaries
  - Disables feature that need a runtime: reflection, "any" types
  - Special compiler techniques: full generics specialization, static linking
  - Embedded Swift subset close to "full" Swift
- Systems with limited memory
  - ARM and RISC-V micro-controllers

### C++ interoperability

- Virtual methods
- Default arguments
- C++ move-only types, `std::map`, `std::set`, `std::optional`, `std::chrono::duration`

```swift
// C++
struct Person {
  Person(const Person&) = delete;
  Person(Person &&) = default;
  // ...
};

// Swift
struct Developer: ~Copyable {
    let person: Person
    init(person: consuming Person) {
      self.person = person
    }
}

let person = Person()
let developer = Developer(person: person)
person.printInfo()
```

### Typed throws

Use typed throws when:

- Same module error handling
- Propagating error type in generic contexts
- Constrained environments

```swift
// Untyped throws
enum IntegerParseError: Error {
  case nonDigitCharacter(String, index: String.Index)
}

func parse(string: String) throws -> Int {
  for index in string.indices {
    // ...
    throw IntegerParseError.nonDigitCharacter(string, index: index)
  }
}

do {
  let value = try parse(string: "1+234")
}
catch let error as IntegerParseError {
  // ...
}
catch {
   // error is 'any Error'
}

func parse(string: String) throws -> Int {
  //...
}

func parse(string: String) -> Int {
  //...
}

// typed throws
enum IntegerParseError: Error {
  case nonDigitCharacter(String, index: String.Index)
}

func parse(string: String) throws(IntegerParseError) -> Int {
  for index in string.indices {
    // ...
    throw IntegerParseError.nonDigitCharacter(string, index: index)
  }
}

do {
  let value = try parse(string: "1+234")
}
catch {
   // error is 'IntegerParseError'
}

func parse(string: String) throws(any Error) -> Int {
  //...
}

func parse(string: String) throws(Never) -> Int {
  //...
}
```

### Data-race safety

![](/images/2024-06-12-WWDC-2024-New-in-Swift/datarace.png)

```swift
// Pass NonSendable reference across actor isolation boundaries
class Client {
  init(name: String, balance: Double) {}
}

actor ClientStore {
  static let shared = ClientStore()
  private var clients: [Client] = []
  func addClient(_ client: Client) {
    clients.append(client)
  }
}

@MainActor
func openAccount(name: String, balance: Double) async {
  let client = Client(name: name, balance: balance)
  await ClientStore.shared.addClient(client) // the client here won't show warnings
}

// Atomic
import Dispatch
import Synchronization

let counter = Atomic<Int>(0)

DispatchQueue.concurrentPerform(iterations: 10) { _ in
  for _ in 0 ..< 1_000_000 {
    counter.wrappingAdd(1, ordering: .relaxed)
  }
}

print(counter.load(ordering: .relaxed))

// Mutex
import Synchronization

final class LockingResourceManager: Sendable {
  let cache = Mutex<[String: Resource]>([:])

  func save(_ resource: Resource, as key: String) {
    cache.withLock {
      $0[key] = resource
    }
  }
}
```

#### References

- <https://developer.apple.com/wwdc24/10136>
