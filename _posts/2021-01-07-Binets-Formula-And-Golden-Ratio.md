---
layout: post
title: Binet's Formula And Golden Ratio
date: 2021-01-07 21:54:00
comment_id: 124
categories: [Math, Formula, Swift]
tags: [Fibonacci, Golden Ratio]
---

> In mathematics, the Fibonacci numbers, commonly denoted Fn, form a sequence, called the Fibonacci sequence, such that each number is the sum of the two preceding ones, starting from 0 and 1. That is, F0 = 0, F1 = 1, Fn = Fn-1 + Fn-2
>
> The beginning of the sequence is thus:
> 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, ...

Fibonacci numbers have a closed form expression, which is Binet's formula.

![](/images/2021-01-07-Binets-Formula-And-Golden-Ratio/formula.png)

## Swift Implementation

```swift
// we will use Darwin module to help calculating some math functions
import Darwin
func fibonacci(_ n: Int) -> Int {
    if n<=1 { return n }
    let goldenRatio: Double = (1+Double(5).squareRoot())/2
    return Int((pow(goldenRatio, Double(n))/Double(5).squareRoot()).rounded())
}
```

#### Reference

- <https://demonstrations.wolfram.com/GeneralizedFibonacciSequenceAndTheGoldenRatio/>
- <https://en.wikipedia.org/wiki/Fibonacci_number>
