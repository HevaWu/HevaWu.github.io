---
layout: post
title: GCD - Euclidean algorithm
date: 2021-03-16 20:02:00
comment_id: 144
categories: [Algorithm, Math]
tags: [GCD]
---

> The `Euclidean algorithm`, or `Euclid's algorithm`, is an efficient method for `computing the greatest common divisor (GCD) of two integers (numbers)`, the largest number that divides them both without a remainder

Usage:

- reducing `fractions` to their `simplest form`
- performing `division` in `modular arithmetic`
- Computations using this algorithm form part of the `cryptographic` protocols that are used to secure internet communications, and in methods for breaking these cryptosystems by `factoring large composite numbers`
- solve `Diophantine` equations, such as finding numbers that satisfy multiple congruences according to the `Chinese remainder theorem`, to construct `continued fractions`, and to find accurate `rational approximations` to real numbers.
- a basic tool for proving theorems in `number theory` such as Lagrange's four-square theorem 
- the `uniqueness of prime factorizations`

## Pseudocode

```s
function gcd(a, b)
    while b ≠ 0
        t := b
        b := a mod b
        a := t
    return a
```

## Swift Implementation

```swift
func gcd(_ a: Int, _ b: Int) -> Int {
	var t = 0
	var a = a
	var b = b
	while b != 0 {
		t = a
		a = b
		b = t%b
	}
	return a
}
```

#### References

- <https://en.wikipedia.org/wiki/Euclidean_algorithm>
  