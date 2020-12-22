---
layout: post
title: Lagrange's four-square theorem
date: 2020-12-22 21:20:00
comment_id: 120
categories: [Swift, Math, Theorem]
tags: [Square, Perfect Square]
---

> Lagrange's four-square theorem, also known as Bachet's conjecture, states that `every natural number can be represented as the sum of four integer squares`. That is, the squares form an additive basis of order four.

## Swift Check The least number of Perfect square numbers which sum to n

The idea is:

```s
- there are only 4 possible results: 1 2 3 4
- return 1 when n isSquare
- return 4: n is 4^k*(8*m+7)
    1. check n % 4 == 0
    2. check n % 8 == 7   return 4
- return 2: n = i*i + j*j
    isSquare(n-i*i)  --- return true, is 2
    for reduce checking, keep n-i*i >0 
    for(int i = 0; i <= (int)(sqrt(n)); ++i)
    eg: 50, did not need to check until 50, only need to check until 7( sqrt(50) )
- else return 3
```

Implementation: 

```swift
func numSquares(_ n: Int) -> Int {
	if n <= 0 { return 0 }
	var n = n
	
	// check if num is square nnum
	let isSquare: (Int) -> Bool = { num in
		let sqrtRoot = Int(Double(num).squareRoot())
		return sqrtRoot*sqrtRoot == num
	}
	
	if isSquare(n) { return 1 }
	
	while n % 4 == 0 {
		n >>= 2
	}
	
	if n % 8 == 7 {
		return 4
	}
	
	let sqrtRoot = Int(Double(n).squareRoot())
	for i in 1...sqrtRoot {
		if isSquare(n-i*i) {
			return 2
		}
	}
	
	return 3
}
```

#### Reference

- <https://en.wikipedia.org/wiki/Lagrange%27s_four-square_theorem>
