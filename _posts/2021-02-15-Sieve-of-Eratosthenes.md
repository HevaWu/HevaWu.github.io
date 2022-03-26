---
layout: post
title: Sieve of Eratosthenes
date: 2021-02-15 19:56:00
comment_id: 140
categories: [Algorithm]
tags: [Prime]
---

> The sieve of Eratosthenes is an ancient algorithm for `finding all prime numbers` up to any given limit.

![](/images/2021-02-15-Sieve-of-Eratosthenes/Sieve_of_Eratosthenes_animation.gif)

## Idea

1. Create a list of consecutive integers from 2 through n: (2, 3, 4, ..., n).
2. Initially, let p equal 2, the smallest prime number.
3. Enumerate the multiples of p by counting in increments of p from 2p to n, and mark them in the list (these will be 2p, 3p, 4p, ...; the p itself should not be marked).
4. Find the smallest number in the list greater than p that is not marked. If there was no such number, stop. Otherwise, let p now equal this new number (which is the next prime), and repeat from step 3.
5. When the algorithm terminates, the numbers remaining not marked in the list are all the primes below n.

## Pseudocode

```s
algorithm Sieve of Eratosthenes is
    input: an integer n > 1.
    output: all prime numbers from 2 through n.

    let A be an array of Boolean values, indexed by integers 2 to n,
    initially all set to true.
    
    for i = 2, 3, 4, ..., not exceeding \sqrt{n} do
        if A[i] is true
            for j = i^2, i^2+i, i^2+2i, i^2+3i, ..., not exceeding n do
                A[j] := false

    return all i such that A[i] is true.
```

## Swift Implementation

```swift
func countPrimes(_ n: Int) -> Int {
	guard n > 2 else { return 0 }
	var isPrime = Array(repeating: true, count: n)
	
	var i = 2
	while i*i < n {
		defer { i += 1 }
		
		if !isPrime[i] { 
			continue 
		}
		
		var j = i*i
		while j < n {
			isPrime[j] = false
			j += i
		}
	}
	
	var count = 0
	for i in 2..<n {
		if isPrime[i] {
			count += 1
		}
	}
	return count
}
```

### Segmented sieve

1. Divide the range 2 through n into segments of some size $\Delta ≤ \sqrt{n}$.
2. Find the primes in the first (i.e. the lowest) segment, using the regular sieve.
3. For each of the following segments, in increasing order, with m being the segment's topmost value, find the primes in it as follows:
	1. Set up a Boolean array of size $\Delta$, and
	2. Mark as non-prime the positions in the array corresponding to the multiples of each prime $p ≤ \sqrt{m}$ found so far, by calculating the lowest multiple of p between $m - \Delta$ and m, and enumerating its multiples in steps of p as usual. The remaining positions correspond to the primes in the segment, since the square of a prime in the segment is not in the segment (for k ≥ 1, one has ${\displaystyle (k\Delta +1)^{2}>(k+1)\Delta }$).

### Incremental sieve

$$
primes = [2, 3, ...] \ [[p^2, p^2+p, ...] \ for \ p \ in \ primes],
$$

## Time Complexity

The bit complexity of the algorithm is $O(n (log n) (log log n))$ bit operations with a memory requirement of $O(n)$.

#### Reference

- <https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes#Algorithmic_complexity>
