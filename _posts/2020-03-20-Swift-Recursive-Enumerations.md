---
layout: post
title: Swift Recursive Enumerations
date: 2020-03-20 20:06:00
comments: true
disqus_category_id: SwiftRecursiveEnumerations
categories: [Swift]
tags: [Enum]
---

In Swift, we could use recursive enumeration to iterate instance of a enumeration to another enumeration cases. By adding `indirect` before it, we could simply do it, it tells the compiler to insert the necessary layer of indirection. ex:

```swift
enum ArithmeticExpression {
    case number(Int)
    indirect case addition(ArithmeticExpression, ArithmeticExpression)
    indirect case multiplication(ArithmeticExpression, ArithmeticExpression)
}

// OR

indirect enum ArithmeticExpression {
    case number(Int)
    case addition(ArithmeticExpression, ArithmeticExpression)
    case multiplication(ArithmeticExpression, ArithmeticExpression)
}

// Test

let five = ArithmeticExpression.number(5)
let four = ArithmeticExpression.number(4)
let sum = ArithmeticExpression.addition(five, four)
let product = ArithmeticExpression.multiplication(sum, ArithmeticExpression.number(2))

func evaluate(_ expression: ArithmeticExpression) -> Int {
    switch expression {
    case let .number(value):
        return value
    case let .addition(left, right):
        return evaluate(left) + evaluate(right)
    case let .multiplication(left, right):
        return evaluate(left) * evaluate(right)
    }
}

print(evaluate(product))
// Prints "18"
```

#### Reference

https://docs.swift.org/swift-book/LanguageGuide/Enumerations.html