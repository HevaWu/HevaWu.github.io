---
layout: post
title: Swift Modulo Operation
date: 2020-12-09 20:54:00
comment_id: 116
categories: [[Math, Swift]
tags: [Operation]
---

Though Swift provide the `remainder` operator(%), however, we cannot directly this operator to calculate the negative numbers modulo operation. Here is the official doc:

> The remainder operator (%) is also known as a modulo operator in other languages. However, its behavior in Swift for negative numbers means that, strictly speaking, it’s a remainder rather than a modulo operation.

Let's check some test code:

```swift
/*
To determine the answer for a % b, the % operator calculates the following equation and returns remainder as its output:
a = (b x some multiplier) + remainder
where some multiplier is the largest number of multiples of b that will fit inside a.
*/

// 9 = (4 x 2) + 1
9 % 4    // equals 1

// -9 = (4 x -2) + -1
-9 % 4   // equals -1
```

We can found that `-9 % 4 ` return `-1`, rather than `3`. So Swift remainder operation (%) is actually a dividend sign rather than modulo. We have to define our own functions for getting correct modulo:

```swift
func mod(_ a: Int, _ n: Int) -> Int {
    precondition(n > 0, "modulus must be positive")
    let r = a % n
    return r >= 0 ? r : r + n
}
```

#### Reference

- <https://docs.swift.org/swift-book/LanguageGuide/BasicOperators.html>
- <https://en.wikipedia.org/wiki/Modulo_operation>
