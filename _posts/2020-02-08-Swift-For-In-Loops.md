---
layout: post
title: Swift For In Loops
date: 2020-02-08 12:02:00
comments: true
disqus_category_id: SwiftForInLoops
categories: [Swift]
tags: [Control Flow]
---

Swift provide `For-In` loop to iterate over a sequence, such as items in an arrary, ranges of numbers, or characters in a string. Here we list the ways:

```swift
/// For array
let names = ["Anna", "Alex", "Brian", "Jack"]
for name in names {
    print("Hello, \(name)!")
}
// Hello, Anna!
// Hello, Alex!
// Hello, Brian!
// Hello, Jack!

/// For dictionary
let numberOfLegs = ["spider": 8, "ant": 6, "cat": 4]
for (animalName, legCount) in numberOfLegs {
    print("\(animalName)s have \(legCount) legs")
}
// cats have 4 legs
// ants have 6 legs
// spiders have 8 legs

/// with numeric range
for index in 1...5 {
    print("\(index) times 5 is \(index * 5)")
}
// 1 times 5 is 5
// 2 times 5 is 10
// 3 times 5 is 15
// 4 times 5 is 20
// 5 times 5 is 25

/// ignonre values by using underscore
let base = 3
let power = 10
var answer = 1
for _ in 1...power {
    answer *= base
}
print("\(base) to the power of \(power) is \(answer)")
// Prints "3 to the power of 10 is 59049"

/// Rannge operators
let minutes = 60
for tickMark in 0..<minutes {
    // render the tick mark each minute (60 times)
}


/// stride to skip the unwanted marks
let minuteInterval = 5
for tickMark in stride(from: 0, to: minutes, by: minuteInterval) {
    // render the tick mark every 5 minutes (0, 5, 10, 15 ... 45, 50, 55)
}
```

#### Reference

https://docs.swift.org/swift-book/LanguageGuide/ControlFlow.html
