---
layout: post
title: Fast Exponentiation Algorithms
date: 2021-03-28 16:42:00
comment_id: 146
categories: [Algorithm, Math]
---

The normal power function would be like:

```swift
func expo(_ a: Int, _ b: Int) -> Int {
    var res = 1
    var b = b
    while b != 0 {
        res *= a
        b -= 1
    }
    return res
}
```

This algorithm take $O(n)$ time.

This could be improved by using [`Exponentiation by squaring`](https://en.wikipedia.org/wiki/Exponentiation_by_squaring), which will take $O(\log n)$ time.

> `exponentiating by squaring` is a general method for fast computation of large positive integer powers of a number, or more generally of an element of a semigroup, like a polynomial or a square matrix.
>
> Some variants are commonly referred to as square-and-multiply algorithms or binary exponentiation. These can be of quite general use, for example in `modular arithmetic` or `powering of matrices`. For semigroups for which additive notation is commonly used, like `elliptic curves` used in cryptography, this method is also referred to as `double-and-add`.

Here is its basic idea:

$$
x^{n}={
    \begin{cases}
    1, & \text{if } n = 0 \\
    {\frac{1}{x}}^{-n}, & \text{if } n < 0 \\
    x\,(x^{2})^{\frac {n-1}{2}}, & \text{if } n \text{ is odd.} \\
    (x^{2})^{\frac {n}{2}}, & \text{if } n \text{ is even.}
    \end{cases}
    }
$$

## Swift Implementation

```swift
func expo(_ a: Int, _ b: Int) -> Int {
    var res = 1
    var a = a
    var b = b
    while b != 0 {
        if b & 1 == 1 {
            res *= a
        }
        b >>= 1
        a *= a
    }
    return res
}
```

#### Refernces

- <https://www.programminglogic.com/fast-exponentiation-algorithms/>
- <https://en.wikipedia.org/wiki/Exponentiation_by_squaring>