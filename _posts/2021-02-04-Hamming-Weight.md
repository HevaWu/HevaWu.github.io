---
layout: post
title: Hamming Weight
date: 2021-02-04 15:57:00
comment_id: 138
categories: [Math]
tags: [Bit]
---

> The Hamming weight of a `string` is the number of `symbols` that are `different from the zero-symbol` of the alphabet used. It is thus equivalent to the Hamming distance from the all-zero string of the same length. 
>
> For the most typical case, a `string of bits`, this is `the number of 1's in the string`, or the `digit sum of the binary` representation of a given number and the ℓ₁ norm of a bit vector. In this binary case, it is also called the population count, popcount, sideways sum, or bit summation

## Examples of applications of the Hamming weight include

- In modular exponentiation by squaring, the number of modular multiplications required for an exponent e is log2 e + weight(e). This is the reason that the public key value e used in RSA is typically chosen to be a number of low Hamming weight.
- The Hamming weight determines path lengths between nodes in Chord distributed hash tables.
- IrisCode lookups in biometric databases are typically implemented by calculating the Hamming distance to each stored record.
- In computer chess programs using a bitboard representation, the Hamming weight of a bitboard gives the number of pieces of a given type remaining in the game, or the number of squares of the board controlled by one player's pieces, and is therefore an important contributing term to the value of a position.
- Hamming weight can be used to efficiently compute find first set using the identity ffs(x) = pop(x ^ (x-1)). This is useful on platforms such as SPARC that have hardware Hamming weight instructions but no hardware find first set instruction.
- The Hamming weight operation can be interpreted as a conversion from the unary numeral system to binary numbers.
- In implementation of some succinct data structures like bit vectors and wavelet trees.

## Implementation

```swift
// Swift Default function
func hammingWeight(_ n: Int) -> Int {
	return n.nonzeroBitCount
}

// Math logic
func hammingWeight(_ n: Int) -> Int {
	var sum = 0 
	var n = n
	while n != 0 {
		sum += 1
		n &= (n-1)
	}
	return sum
}
```

#### Reference

- <https://en.wikipedia.org/wiki/Hamming_weight>
