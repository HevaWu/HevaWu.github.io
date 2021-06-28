---
layout: post
title: Protocol-Oriented Programming in Swift
date: 2021-06-28 22:12:00
comment_id: 169
categories: [Swift]
tag: [Protocol]
---

> At the heart of Swift's design are two incredibly powerful ideas: protocol-oriented programming and first class value semantics. Each of these concepts benefit predictability, performance, and productivity, but together they can change the way we think about programming.

## Classes

- Encapulation
- Access control
- Abstraction
- Namespace
- Expressive syntax
- Extensibility

=> `struct` and `enum` can also succeed `access control, abstraction, namespace` part

- Inherited
  - customization points and reuse

### 1. Implicit Sharing

Cocoa Collection Sharing:

> NOTE: It is not safe to modify a mutable collection while enumerating through it. Some enumerators may currently allow enumeration of a collection that is modified, but this behavior is not guaranteed to be supported in the future.

Not occurs on Swift, because Swift is `value types`, don't share. The thing we are iterating and modifying is `distinct`.

### 2. Inheritance All up in Your business

- Single inheritance weight gain
- No retroactive modeling
- Superclass may have stored properties
  - initialization required
  - clear how to interact with superclass without break superclass invariants
  - know when to override

=> promote delegation

### 3. Lost Type Relationships

```swift
class Ordered {
    func precedes(other: Ordered) -> Bool {
        // NOT GOOD
        fatalError("implement me!")
    }
}

class Label: Ordered { var text: String = "" ... }

class Number: Ordered {
    var value: Double = 0
    override func precedes(other: Ordered) -> Bool {
        // we have to downcast it to use value
        return value < (other as! Number).value
    }
}
```

If we found this `as! ASubclass`, this is a sign that a type relationship was lost. Usually due to using classes for abstraction.

A better abstraction mechanism:

- supports value types ( and classes )
- support static type relationships (and dynamic dispatch)
- non-monolithic
- supports retroactive modeling
- doesn't impose instance data on models
- doesn't impose initialization burdens on models
- makes clear what to implement

=> made `Protocol`

Swift is a Protocol-Oriented Programming Language.

## Start with Protocol

```swift
protocol Ordered {
    // use Self to identify used Type
    func preceds(other: Self) -> Bool
}

struct Number: Ordered {
    var value: Double = 0
    func precedes(other: Number) -> Bool {
        return self.value < other.value
    }
}

// use generic type
func binarySearch<T: Ordered>(sortedKeys: [T], forKey k: T) -> Int {
    ...
}
```

It's quite different with `Self` requirements.

![](/images/2021-06-28-Protocol-Oriented-Programming-in-Swift/two_worlds_protocol.png)

### Protocol Extension

Can be a requirements create customization points.

**Constrained extensions:**
-> 2 generator types might not be able to check `==`, we'd define a `where` to give it needs to allow comparison:

```swift
// use `where Generator.Element: Equatable`
extension CollectionType where Generator.Element: Equatable {
    public func indexOf(element: Generator.Element) -> Index? {
        for i in self.indices {
            // can check == now
            if self[i] == element {
                return i
            }
        }
        return nil
    }
}
```

**Retroactive adaptation:**

```swift
protocol Ordered {
    func precedes(other: Self) -> Bool
}
func binarySearch<T: Ordered>(sortedKeys: [T], forKey k: T) -> Int {...}

extension Int: Ordered {
    func precedes(other: Int) -> Bool { return self < other }
}

extension String: Ordered {
    func precedes(other: String) -> Bool { return self < other }
}
```

TO =>

```swift
extension Ordered where Self: Comparable {
    func precedes(other: String) -> Bool { return self < other }
}
```

### Bridge-Building

Build bridge between static and dynamic:

```swift
protocol Drawable {
    func isEqualTo(other: Drawable) -> Bool
    func draw()
}

extension Drawable where Self: Equatable {
    func isEqualTo(other: Drawable) -> Bool {
        if let o = other as? Self { return self == o }
        return false
    }
}
```

## When to use classes

- want implicit sharing when
  - copying or comparing instances doesn't make sense(e.g., Window)
  - instance lifetime is tied to external effects(e.g., TemporaryFile)
  - instances are just "sinks" - write-only conduits to external state (e.g., CGContext)
- Don't fight the system
  - if a framework expects you to subclass, or to pass an object, do it
  - when factoring something out of a class, consider a non-class

#### Reference

- <https://developer.apple.com/videos/play/wwdc2015/408/>
