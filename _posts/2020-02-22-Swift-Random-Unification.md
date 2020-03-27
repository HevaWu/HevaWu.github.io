---
layout: post
title: Swift Random Unification
date: 2020-02-22 10:57:00
comments: true
disqus_category_id: SwiftRandomUnification
categories: [Swift]
tags: [Random]
---

Start from Swift 4.2, Swift provide a useful random API.

## Before Swift4.2

Before Swift 4.2, if you want to do some random functionality:

> While on Linux, many developers tend to use random(3), from the POSIX standard, or rand(3), from the C standard library, for a quick and dirty solution for Linux systems.

The common implementation for developers to use is:

```swift
// This is confusing because some may look at this and think Foundation provides these functions,
// when in reality Foundation imports Darwin and Glibc from which these are defined and implemented.
// You get the same behavior when you import UIKit, or AppKit.
import Foundation

// We can't forget to seed the Linux implementation.
// This is unsecure as time is a very predictable seed.
// This raises more questions to whether or not Foundation, UIKit, or AppKit provided these functions.
#if os(Linux)
srandom(UInt32(time(nil)))
#endif

// We name this randomNumber because random() interferes with Glibc's random()'s namespace
func randomNumber() -> Int {
#if !os(Linux)
  return Int(arc4random()) // This is inefficient as it doesn't utilize all of Int's range
#else
  return random() // or Int(rand())
#endif
}

// Many tend to opt in for ranges here, but for this example I opt for a start and end argument
func random(from start: Int, to end: Int) -> Int {
#if !os(Linux)
  var random = Int(arc4random_uniform(UInt32(end - start)))
#else
  // Not recommended as it introduces modulo bias
  var random = random() % (end - start)
#endif

  random += start

  return random
}

// Alternatively, an easier solution would be:
/*
  func random(from start: Int, to end: Int) -> Int {
    var random = randomNumber() % (end - start)

    random += start

    return random
  }
*/
// However this approach introduces modulo bias for all systems rather than just Linux.
```

But it might have some problems:

> In order to define these workarounds, developers must utilize a few platform checks. Developers should not be forced to define platform checks for such trivial requests like this one.
>
> Unexperienced developers who rely on workarounds like these, may be pushing unsecure code that is used by tens of hundreds or thousands of users. Starting with Darwin's arc4random(3), pre macOS 10.12 (Sierra) and iOS 10, the implementation of arc4random(3) utilized the RC4 algorithm. This algorithm is now considered non-cryptographically secure due to RC4 weakness. Post macOS 10.12 (Sierra) and iOS 10, "...it was replaced with the NIST-approved AES cipher", as stated from the man pages in terminal (man arc4random). Moving on to Linux we see that using random() or rand() to generate numbers make it completely predictable as these weren't designed to be at a crypto level.
>
> In the example, it uses modulo to generate the number within the upper bound. Many developers may not realize it, but for a quick workaround, it introduces modulo bias in which modulo does not correctly distribute the probability in dividing the upper bound equally within the range.
>
> Highly inefficient as creating a new Int from a UInt32 doesn't utilize the full extent of Int's range.
>
> Could confuse some users as Foundation, AppKit, or UIKit don't provide these random functionalities.

## After Swift4.2

Well, Swift also considering this part, so they provide a powerful random API. So, the standard library will provide a default RNG. And each platform vendor will also be able to pick the specific implementation for the RNG.

## Random API

For the core API, they introduce a new protocol named `RandomNumberGenerator`. And this is used to define RNGs that acan be used within the stdlib. We could use it to generate own custom RNG.

For the default RNG implementation, there is a `SystemRandomNumberGenerator`.

The default `SystemRandomNumberGenerator` are using: 

> Apple platforms use arc4random_buf(3).
>
> Linux platforms use getrandom(2) when available; otherwise, they read from /dev/urandom.
>
> Windows uses BCryptGenRandom.

## More examples

```swift
/// Fix width integer

// Utilizes the standard library's default random
// Alias to:
// var rng = SystemRandomNumberGenerator()
// Int.random(in: 0 ..< 10, using: &rng)
let randomIntFrom0To10 = Int.random(in: 0 ..< 10)
let randomUIntFrom10Through100 = UInt.random(in: 10 ... 100, using: &myCustomRandomNumberGenerator)

// The following are examples on how to get full width integers

let randomInt = Int.random(in: .min ... .max)
let randomUInt = UInt.random(in: .min ... .max, using: &myCustomRandomNumberGenerator)

/// Bool

// Utilizes the standard library's default random
// Alias to:
// var rng = SystemRandomNumberGenerator()
// Bool.random(using: &rng)
let randomBool1 = Bool.random()
let randomBool2 = Bool.random(using: &myCustomRandomNumberGenerator)

/// Collection Type

let greetings = ["hey", "hi", "hello", "hola"]

// Utilizes the standard library's default random
// Alias to:
// var rng = SystemRandomNumberGenerator()
// greetings.randomElement(using: &rng)!
print(greetings.randomElement()!) // This returns an Optional
print(greetings.randomElement(using: &myCustomRandomNumberGenerator)!) // This returns an Optional

/// Shuffle

var greetings = ["hey", "hi", "hello", "hola"]

// Utilizes the standard library's default random
// Alias to:
// var rng = SystemRandomNumberGenerator()
// greetings.shuffle(using: &rng)
greetings.shuffle()
print(greetings) // A possible output could be ["hola", "hello", "hey", "hi"]

let numbers = 0 ..< 5
print(numbers.shuffled(using: &myCustomRandomNumberGenerator)) // A possible output could be [1, 3, 0, 4, 2]
```

## Detailed Design

The implementation can be found at [here](https://github.com/apple/swift/pull/12772)

```swift
public protocol RandomNumberGenerator {
  // This determines the functionality for producing a random number.
  // Required to implement by all RNGs.
  mutating func next() -> UInt64
}

// These sets of functions are not required and are provided by the stdlib by default
extension RandomNumberGenerator {
  // This function provides generators a way of generating other unsigned integer types
  public mutating func next<T : FixedWidthInteger & UnsignedInteger>() -> T

  // This function provides generators a mechanism for uniformly generating a number from 0 to upperBound
  // Developers can extend this function themselves and create different behaviors for different distributions
  public mutating func next<T : FixedWidthInteger & UnsignedInteger>(upperBound: T) -> T
}

// The stdlib RNG.
public struct SystemRandomNumberGenerator : RandomNumberGenerator {
  
  public init() {}

  // Conformance for `RandomNumberGenerator`, calls one of the crypto functions.
  public mutating func next() -> UInt64
  
  // We override the protocol defined one to prevent unnecessary work in generating an
  // unsigned integer that isn't a UInt64
  public mutating func next<T: FixedWidthInteger & UnsignedInteger>() -> T
}

extension Collection {
  // Returns a random element from the collection
  // Can return nil if isEmpty is true
  public func randomElement<T: RandomNumberGenerator>(
    using generator: inout T
  ) -> Element?
  
  /// Uses the standard library's default RNG
  public func randomElement() -> Element? {
    var g = SystemRandomNumberGenerator()
    return randomElement(using: &g)
  }
}

// Enables developers to use things like Int.random(in: 5 ..< 12) which does not use modulo bias.
// It is worth noting that any empty range entered here will abort the program.
// We do this to preserve a general use case design that the core team expressed.
// For those that are that unsure whether or not their range is empty or not,
// they can if/guard check whether or not the range is empty beforehand, then
// use these functions.
extension FixedWidthInteger {

  public static func random<T: RandomNumberGenerator>(
    in range: Range<Self>,
    using generator: inout T
  ) -> Self

  /// Uses the standard library's default RNG
  public static func random(in range: Range<Self>) -> Self {
    var g = SystemRandomNumberGenerator()
    return Self.random(in: range, using: &g)
  }

  public static func random<T: RandomNumberGenerator>(
    in range: ClosedRange<Self>,
    using generator: inout T
  ) -> Self
  
  /// Uses the standard library's default RNG
  public static func random(in range: ClosedRange<Self>) -> Self {
    var g = SystemRandomNumberGenerator()
    return Self.random(in: range, using: &g)
  }
}

// Enables developers to use things like Double.random(in: 5 ..< 12) which does not use modulo bias.
// It is worth noting that any empty range entered here will abort the program.
// We do this to preserve a general use case design that the core team expressed.
// For those that are that unsure whether or not their range is empty or not,
// they can simply if/guard check the bounds to make sure they can correctly form
// ranges which a random number can be formed from.
extension BinaryFloatingPoint where Self.RawSignificand : FixedWidthInteger {

  public static func random<T: RandomNumberGenerator>(
    in range: Range<Self>,
    using generator: inout T
  ) -> Self

  /// Uses the standard library's default RNG
  public static func random(in range: Range<Self>) -> Self {
    var g = SystemRandomNumberGenerator()
    return Self.random(in: range, using: &g)
  }

  public static func random<T: RandomNumberGenerator>(
    in range: ClosedRange<Self>,
    using generator: inout T
  ) -> Self
  
  /// Uses the standard library's default RNG
  public static func random(in range: ClosedRange<Self>) -> Self {
    var g = SystemRandomNumberGenerator()
    return Self.random(in: range, using: &g)
  }
}

// We add this as a convenience to something like:
// Int.random(in: 0 ... 1) == 1
// To the unexperienced developer they might have to look at this a few times to
// understand what is going on. This extension methods helps bring clarity to
// operations like these.
extension Bool {
  public static func random<T: RandomNumberGenerator>(
    using generator: inout T
  ) -> Bool
  
  /// Uses the standard library's default RNG
  public static func random() -> Bool {
    var g = SystemRandomNumberGenerator()
    return Bool.random(using: &g)
  }
}

// Shuffle API

// The shuffle API will utilize the Fisher Yates algorithm

extension Sequence {
  public func shuffled<T: RandomNumberGenerator>(
    using generator: inout T
  ) -> [Element]
  
  /// Uses the standard library's default RNG
  public func shuffled() -> [Element] {
    var g = SystemRandomNumberGenerator()
    return shuffled(using: &g)
  }
}

extension MutableCollection {
  public mutating func shuffle<T: RandomNumberGenerator>(
    using generator: inout T
  )
  
  /// Uses the standard library's default RNG
  public mutating func shuffle() {
    var g = SystemRandomNumberGenerator()
    shuffle(using: &g)
  }
}
```

#### Reference

<https://github.com/apple/swift-evolution/blob/master/proposals/0202-random-unification.md>