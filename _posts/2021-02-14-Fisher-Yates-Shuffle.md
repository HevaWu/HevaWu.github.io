---
layout: post
title: Fisher-Yates Shuffle
date: 2021-02-14 18:39:00
comment_id: 139
categories: [Algorithm]
tags: [Random, Shuffle]
---

> The Fisher–Yates shuffle is an algorithm for generating a random permutation of a finite sequence—in plain terms, the algorithm shuffles the sequence
>
> The algorithm effectively puts all the elements into a hat; it continually `determines the next element by randomly drawing an element` from the hat until no elements remain. The algorithm produces an unbiased permutation: `every permutation is equally likely`. The modern version of the algorithm is efficient: it takes time proportional to the number of items being shuffled and `shuffles them in place`.

## Algorithm

1. Write down the numbers from 1 through N.
2. Pick a random number k between one and the number of unstruck numbers remaining (inclusive).
3. Counting from the low end, strike out the kth number not yet struck out, and write it down at the end of a separate list.
4. Repeat from step 2 until all the numbers have been struck out.
5. The sequence of numbers written down in step 3 is now a random permutation of the original numbers.

## Pseudocode

```s
-- To shuffle an array a of n elements (indices 0..n-1):
for i from n−1 downto 1 do
     j ← random integer such that 0 ≤ j ≤ i
     exchange a[j] and a[i]

-- To shuffle an array a of n elements (indices 0..n-1):
for i from 0 to n−2 do
     j ← random integer such that i ≤ j < n
     exchange a[i] and a[j]
```

## Swift Implementation

```swift
func shuffle() -> [Int] {
	let n = original.count
	var res = original
	for i in 0..<n {
		res.swapAt(i, Int.random(in: i..<n))
	}
	return res
}
```

#### Reference

- <https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle>
