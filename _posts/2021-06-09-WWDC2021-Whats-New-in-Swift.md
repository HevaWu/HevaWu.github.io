---
layout: post
title: WWDC2021 What's New in Swift
date: 2021-06-09 15:33:00
comment_id: 163
categories: [WWDC2021, Swift]
tag: [Concurrency, iOS15]
---

# Diversity

<https://swift.org/diversity/>

# Swift Packages

- Use Swift Package Index to search swift packages
- Swift Package collections in Xcode

## Swift Package Collections

- anyone can publish them

## Apple Swift Packages

### Swift Collections

<https://github.com/apple/swift-collections>

- Deque
- Ordered Set
- Ordered Dictionary

### Swift Algorithms

<https://github.com/apple/swift-algorithms>

![](/images/2021-06-09-WWDC2021-Whats-New-in-Swift/algorithm.png)

### Swift System

<https://github.com/apple/swift-system>

- idiomatic, low-level interfaces to system calls
- strong types, error handling, memory safety
- Linux and Windows support

### Swift Numerics

<https://github.com/apple/swift-numerics>

- `Float16` support on Apple silicon Macs

### Swift ArgumentParser

<https://github.com/apple/swift-argument-parser>

- Fish shell completion scripts
- Joined short options (-Ddebug)
- Improved error messages

# Update Swift on server

- Static linking on Linux
- Improved JSON performance
- Enhanced AWS Lambda runtime

# Developer experience

## Swift DocC

Will be open sourced this year(2021).

## Build Improvements

- faster builds when changing imported modules
- faster startup time before launching compiles
- fewer recompilations after changing an extension body

## Memory Management

- Add Xcode settings: `Optimize Object Lifetimes`

# Ergonomic improvements

![](/images/2021-06-09-WWDC2021-Whats-New-in-Swift/ergonomic.png)

## Enum Codable synthesis

```swift
enum Command: Codable {
    case load(key: String)
    case store(key: String, value: Int)
}
```

## Flexible static member lookup

```swift
protocol Coffee { ... }
struct RegularCoffee: Coffee { }
struct Cappuccino: Coffee { }
extension Coffee where Self == Cappucino {
    static var cappucino: Cappucino { Cappucino() }
}

func brew<CoffeeType: Coffee>(_ coffee: CoffeeType) { ... }

brew(.cappucino.large)
```

## Property wrappers on parameters

```swift
@propertyWrapper
struct NonEmpty<Value: Collection> {
    init(wrappedValue: Value) {
        precondition(!wrappedValue.isEmpty)
        self.wrappedValue = wrappedValue
    }

    var wrappedValue: Value {
        willSet { precondition(!newValue.isEmpty) }
    }
}

func logIn(@NonEmpty _ username: String) {
    print("Logging in: \(username)")
}
```

## Actors

```swift
actor Statistics {
    private var counter: Int = 0
    func increment() {
        counter += 1
    }
    func publish() async {
        await sendResults(counter)
    }
}

var statistics = Statistics()
await statistics.increment()
```

#### Reference

- <https://developer.apple.com/wwdc21/10192>
- <https://swift.org/diversity/>
- <https://swift.org/blog/package-collections>
