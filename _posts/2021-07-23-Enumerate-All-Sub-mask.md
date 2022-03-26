---
layout: post
title: Enumerate All Sub-mask
date: 2021-07-23 23:00:00
comment_id: 177
categories: [Algorithm]
tags: [Bit]
---

## Enumerating All Submask by given mask

Given a bitmask m, you want to efficiently iterate through all of its submasks, that is, masks s in which only bits that were included in mask m are set.

### Pseudocode

```swift
var s = m
while s > 0 {
 // use s at here
 s = (s-1) & m
}
```

This algorithm generates all submasks of this mask in descending order, performing only two operations per iteration.

Suppose we have a current bitmask $s$, and we want to move on to the next bitmask. By subtracting from the mask $s$ one unit, we will remove the rightmost set bit and all bits to the right of it will become 1. Then we remove all the "extra" one bits that are not included in the mask $m$ and therefore can't be a part of a submask. We do this removal by using the bitwise operation $(s-1) & m$. As a result, we "cut" mask $s−1$ to determine the highest value that it can take, that is, the next submask after $s$ in descending order.

A special case is when $s=0$. After executing $s−1$ we get a mask where all bits are set (bit representation of -1), and after $(s-1) & m$ we will have that s will be equal to $m$.

**NOTE: With the mask s=0 be careful — if the loop does not end at zero, the algorithm may enter an infinite loop.**

## Time Complexity

$O(3^n)$

#### Reference

- <https://cp-algorithms.com/algebra/all-submasks.html>
