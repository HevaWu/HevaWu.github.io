---
layout: post
title: Newton's Method to Solve Integer Square Root
date: 2021-01-16 20:27:00
comment_id: 131
categories: [Math, Algorithm, Number Theory]
tags: [Computation]
---

The integer square root of a positive integer $n$ is the positive integer $m >= \sqrt{n}$.

One way of calculating $\sqrt{n}$ is to use Newton's method. Here is the formula:

$$
\begin{cases}
& x_{k+1} = { 1 \over 2 }(x_k + {n \over x_k}), k >= 0, x_0 > 0 \\
& stop \ when \ \left | x_{k+1} - x_k \right | < 1 \\
& ensure \ \lfloor x_{k+1} \rfloor = \lfloor \sqrt{n} \rfloor
\end{cases}
$$

## C Implementation

```c
// Square root of integer
unsigned long int_sqrt ( unsigned long s )
{
	unsigned long x0 = s >> 1;				// Initial estimate
	// Sanity check
	if ( x0 )
	{
		unsigned long x1 = ( x0 + s / x0 ) >> 1;	// Update
		while ( x1 < x0 )				// This also checks for cycle
		{
			x0 = x1;
			x1 = ( x0 + s / x0 ) >> 1;
		}
		return x0;
	}
	else
	{
		return s;
	}
}
```

## Swift Implementation

```swift
func int_sqrt(_ x: Int) -> Int {
	if x == 0 { return 0 }
	var r = x >> 1
	while r*r > x {
		r = (r + x/r) >> 1
	}
	return r
}
```

#### Reference

- <https://en.wikipedia.org/wiki/Integer_square_root#Using_only_integer_division>
