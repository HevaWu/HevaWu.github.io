---
layout: post
title: Swift LazySequence
date: 2020-08-14 20:57:00
comment_id: 94
categories: [Swift]
tags: [Sequence]
---

## LazySequence

> A sequence containing the same elements as a Base sequence, but on which some operations such as map and filter are implemented lazily.

## LazySequenceProtocol

> A sequence on which normally-eager sequence operations are implemented lazily.
> 
> Lazy sequences can be used to avoid needless storage allocation and computation, because they use an underlying sequence for storage and compute their elements on demand.

ex:

```swift
let doubled = [1, 2, 3].lazy.map { $0 * 2 }
// return [2, 4, 6]
```

> Sequence operations that take closure arguments, such as map(_:) and filter(_:), are normally eager: They use the closure immediately and return a new array. When you use the lazy property, you give the standard library explicit permission to store the closure and the sequence in the result, and defer computation until it is needed.

It would be helpful if we want to check things quickly. ex:

```swift
let doubled = [1, 2, 3].lazy.map { num -> Int in
    print("=== M \(num)")
    return num * 2
}.first
// print --> === M 1
// return 2
// the later 2, 3 will not come into map, because `first` already means this loop is finished
```

## Add New Lazy Operations

> To add a new lazy sequence operation, extend this protocol with a method that returns a lazy wrapper that itself conforms to LazySequenceProtocol. 

```swift
extension Sequence {
    /// Returns an array containing the results of
    ///
    ///   p.reduce(initial, nextPartialResult)
    ///
    /// for each prefix `p` of `self`, in order from shortest to
    /// longest. For example:
    ///
    ///     (1..<6).scan(0, +) // [0, 1, 3, 6, 10, 15]
    ///
    /// - Complexity: O(n)
    func scan<Result>(
        _ initial: Result,
        _ nextPartialResult: (Result, Element) -> Result
    ) -> [Result] {
        var result = [initial]
        for x in self {
            result.append(nextPartialResult(result.last!, x))
        }
        return result
    }
}

// build a sequence type that lazily computes the elements in the result of a scan:
struct LazyScanSequence<Base: Sequence, Result>
    : LazySequenceProtocol
{
    let initial: Result
    let base: Base
    let nextPartialResult:
        (Result, Base.Element) -> Result

    struct Iterator: IteratorProtocol {
        var base: Base.Iterator
        var nextElement: Result?
        let nextPartialResult:
            (Result, Base.Element) -> Result
        
        mutating func next() -> Result? {
            return nextElement.map { result in
                nextElement = base.next().map {
                    nextPartialResult(result, $0)
                }
                return result
            }
        }
    }
    
    func makeIterator() -> Iterator {
        return Iterator(
            base: base.makeIterator(),
            nextElement: initial as Result?,
            nextPartialResult: nextPartialResult)
    }
}

// give all lazy sequences a lazy scan(_:_:) method:
extension LazySequenceProtocol {
    func scan<Result>(
        _ initial: Result,
        _ nextPartialResult: @escaping (Result, Element) -> Result
    ) -> LazyScanSequence<Self, Result> {
        return LazyScanSequence(
            initial: initial, base: self, nextPartialResult: nextPartialResult)
    }
}

// With this type and extension method, you can call .lazy.scan(_:_:) on any sequence to create a lazily computed scan. The resulting LazyScanSequence is itself lazy, too, so further sequence operations also defer computation.
```

Without lazy, if we normally call the sequence function, the value will never unexpectedly dropped or deferred.

#### Reference

<https://developer.apple.com/documentation/swift/lazysequence>

<https://developer.apple.com/documentation/swift/lazysequenceprotocol>
