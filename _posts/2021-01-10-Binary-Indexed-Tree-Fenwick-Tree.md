---
layout: post
title: Binary Indexed Tree (Fenwick Tree)
date: 2021-01-10 23:05:00
comment_id: 127
categories: [Algorithm]
tags: [Tree]
---

> A Fenwick tree or binary indexed tree is a data structure that can efficiently update elements and calculate prefix sums in a table of numbers.

Coding by C: 

```c
#define LSB(i) ((i) & -(i)) // zeroes all the bits except the least significant one
//One based indexing is assumed
int A[SIZE+1];

int sum(int i) // Returns the sum from index 1 to i
{
    int sum = 0;
    while (i > 0) 
        sum += A[i], i -= LSB(i);
    return sum;
}
 
void add(int i, int k) // Adds k to element with index i
{
    while (i <= SIZE) 
        A[i] += k, i += LSB(i);
}
```

Coding By Swift:

```swift
var cache = Array(repeating: 0, count: SIZE)
// Add k to element with index x
func update(_ x: Int, _ k: Int) {
	var x = x
	while x < SIZE {
		cache[x] += k
		x += (x & -x)
	}
}

// return sum from index 0 to x
func get(_ x: Int) -> Int {
	var x = x 
	var res = 0
	while x > 0 {
		res += cache[x]
		x -= (x & -x)
	}
	return res
}
```

## Background

By straightforward implementation without using bit. Example: an array is [2, 3, -1, 0, 6] the length 3 prefix [2, 3, -1] with sum 2 + 3 + -1 = 4).

2 Operations:

1. point update(i): Change value stored at index i
2. range sum(k): Find sum of a prefix of length k

```java
int a[] = {2, 1, 4, 6, -1, 5, -32, 0, 1};
void update(int i, int v)   //assigns value v to a[i]
{
    a[i] = v;   
}
int prefixsum(int k)    //calculate the sum of all a[i] such that 0 <= i < k
{
   int sum = 0;
   for(int i = 0; i < k; i++)
        sum += a[i];
   return sum;
}
```

This will out of time limit for large dataset. One efficient solution is use segment tree to perform both operation in $O(logN)$ time.

Binary Indexed Tree require less space and are very easy to implement.

## Isolate last set bit

Example: number x = 1110(in binary)

| :--: | :--: | :--: | :--: | :--: |
|Binary digit| 1 | 1 | 1(the last set bit, need to isolate it) | 0 |
|Index| 3 | 2 | 1 | 0 |

So, `x & -x` gives the last set bit in a number.

### Description

$x = a1b$ (in binary) is the number whose last set bit is we want.

$a$ is some binary sequence of any length of 1's and 0's, $b$ is some sequence of any length but of 0's only. The 1 bit between $a$ and $b$ is the last set bit.

$$\displaylines{
\begin{align}
-x & = x' + 1 \\ 
& = (a1b)' + 1 \\ 
& = a'0b' + 1 \\ 
& = a'0(0...0)' + 1 \\ 
& = a'0(1...1) + 1 \\ 
& = a'1(0...0) \\ 
& = a'1b
\end{align}
}$$

$$ \displaylines{
\begin{align}
& \ \ \ \ \ \ a1b ==> x \\ 
\& \ \ \ \ & \ \ \ \ \ \ a'1b ==> -x \\ 
&= (0...0)1(0...0)
\end{align}
} $$

Example: $x = 10(in decimal) = 1010(in binary)$, the last set bit is given by $ x\&(-x) = (10)1(0) \& (01)1(0) = 0010 = 2(in decimal) $

## Basic Idea of Binary Indexed Tree

For a given array, we can maintain an array $BIT[]$, which at any index we can store sum of some numbers of the given array. This also be called a partial sum tree.

Example: array [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]

![](/images/2021-01-10-Binary-Indexed-Tree-Fenwick-Tree/basic_idea_example.jpg)

Each enclosed box denotes the value $BIT[index]$, each $BIT[index]$ stores partial sum of some numbers.

$$ \displaylines{ 
BIT[x] = 
\begin{cases} 
a[x], if \ x \ is \ odd \\ 
a[1] + .... + a[x], if \ x \ is \ power \ of \ 2
\end{cases}
}
$$

Every index $i$ in the $BIT[]$ array stores the cumulative sum from $ i \ to \  i-(1 << r) + 1 $ (both inclusive), where $r$ represents the last set bit in index $i$.

$$ \displaylines{ 
& first \ 12 \ numbers = BIT[12] + BIT[8] = (a[12]+...+a[9]) + (a[8]+...+a[1]) \\
& first \ 6 \ numbers = BIT[6] + BIT[4] = (a[6]+a[5]) + (a[4]+...+a[1])
}
$$

### Construct Tree

$BIT[]$ is array of size $1+a[]$, initially is 0. Call $update()$ operation to construct the Binary Indexed Tree

```java
//add "delta" at index "x"
void update(int x, int delta) {      
    for(; x <= n; x += x&-x)
          BIT[x] += delta;
}
```

Example: call $update(13, 2)$, $13, 14, 16$ cover index 13, we need to add 2 to them also.

$$\displaylines{ 
& BIT[13] += 2 \\ 
& ==> isolate \ last \ set \ bit \ of \ 13(1101), i.e. x += x \& (-x) \\
& ==> Last \ bit \ of \ 13 \ is \ 1, x = 13+1 = 14, update \ BIT[14] \\
& BIT[14] += 2 \\
& ==> 14(1110), isolate \ last \ bit \ and \ add \ to \ 14, x=14+2=16(10000), update \ BIT[16] \\
& BIT[16] += 2
}$$

In this way, $update()$ operation update all indices of $BIT[]$ which cover index $x$ and maintain $BIT[]$. The loop runs at most the number of bits in index $x(<= n)$, so the update operation takes at most $O(log_{2}n)$ time.

### Query Prefix Sum

```java
//returns the sum of first x elements in given array a[]
int query(int x) {
     int sum = 0;
     for(; x > 0; x -= x&-x)
         sum += BIT[x];
     return sum;
}
```

Example: call $query(14)$

$$ \displaylines{
& ==> initial \ sum \\
& sum = 0 \\
& ==> x=14(1110), add \ BIT[14] \\
& sum = BIT[14] = (a[14]+a[13]) \\
& ==> isolate \ last \ set \ bit \ from 14(1110) -> 2(10), and \ subtract \ it \ from \ x \\
& x = 14-2 = 12 \\
& ==> add \ BIT[12] \\
& sum = BIT[14] + BIT[12] = (a[14]+a[13]) + (a[12]+...+a[9]) \\
& ==> isolate \ last \ set \ bit \ from 12(1100) -> 4(100), and \ subtract \ it \ from \ x \\
& x = 12-4 = 8 \\
& ==> add \ BIT[8] \\
& sum = BIT[14] + BIT[12] + BIT[8] = (a[14]+a[13]) + (a[12]+...+a[9]) + (a[8]+...+a[1]) \\
& ==> isolate \ last \ set \ bit \ from 8(100) -> 8(1000), and \ subtract \ it \ from \ x \\
& x = 8-8 = 0 \\
& ==> x=0, break/end \ the \ loop, return \ sum
}$$

The loop iterates at most number of bits in $x$, which will be at most $n$ (the size of given array). So query operation takes $O(log_{2}n)$ time.

## When to use

Before going for Binary Indexed tree to perform operations over range, better to confirm:

> - Associative. i.e f(f(a, b), c) = f(a, f(b, c)) this is true even for seg-tree
> - Has an inverse. eg:
>   - addition has inverse subtraction (this example we have discussed)
>   - Multiplication has inverse division
>   - gcd() has no inverse, so we can’t use BIT to calculate range gcd’s
>   - sum of matrices has inverse
>   - product of matrices would have inverse if it is given that matrices are degenerate i.e. determinant of any matrix is not equal to 0

- Space Complexity: $O(N)$ where N is array size
- Time Complexity: $O(logN)$ for each operation(update, query)
- Applications:
  - Binary Indexed trees are used to implement the arithmetic coding algorithm.
  - Binary Indexed Tree can be used to count inversions in an arry in $O(N * logN)$ time

#### Reference

- <https://www.hackerearth.com/practice/notes/binary-indexed-tree-or-fenwick-tree/>
- <https://en.wikipedia.org/wiki/Fenwick_tree>
