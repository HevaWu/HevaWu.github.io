---
layout: post
title: Swift Variadic Parameters
date: 2020-08-12 15:27:00
comment_id: 92
categories: [Swift]
tags: [Parameter]
---

> A variadic parameter accepts zero or more values of a specified type. You use a variadic parameter to specify that the parameter can be passed a varying number of input values when the function is called. Write variadic parameters by inserting three period characters (...) after the parameter’s type name.
>
> The values passed to a variadic parameter are made available within the function’s body as an array of the appropriate type. 

ex: A type of `Double...` will be treated as a constant array `[Double]` type.

```swift
func arithmeticMean(_ numbers: Double...) -> Double {
    var total: Double = 0
    for number in numbers {
        total += number
    }
    return total / Double(numbers.count)
}
arithmeticMean(1, 2, 3, 4, 5)
// returns 3.0, which is the arithmetic mean of these five numbers
arithmeticMean(3, 8.25, 18.75)
// returns 10.0, which is the arithmetic mean of these three numbers
```

**Note**
- A function may have at most one variadic parameter.
- In-out parameters cannot have default values, and variadic parameters cannot be marked as inout.

#### Reference

<https://docs.swift.org/swift-book/LanguageGuide/Functions.html>