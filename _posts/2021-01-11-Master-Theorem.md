---
layout: post
title: Master Theorem
date: 2021-01-11 18:44:00
comment_id: 129
categories: [Math, Algorithm, Theorem]
tags: [Divide And Conquer]
---

> In the analysis of algorithms, the master theorem for divide-and-conquer recurrences provides an asymptotic analysis (using Big O notation) for recurrence relations of types that occur in the analysis of many divide and conquer algorithms.

Consider a problem that can be recursively solved by:

```s
procedure p(input x of size n):
    if n < some constant k:
        Solve x directly without recursion
    else:
        Create a subproblems of x, each having size n/b
        Call procedure p recursively on each subproblem
        Combine the results from the subproblems
```

The runtime of above algorithm would be:

$$T(n) = {aT({n \over b})+f(n)}$$

where $f(n)$ is the time to create the subproblems and combine their results. Further represent $f(n) \ as \ O(n^d) \ where \ d >= 0$

## Formulation

Master Theorem provides 3 formulas:

$$\displaylines{
1. & if a > b^d, i.e. d < log_{b}a = {log_{2}a \over log_2{b}}, then \ T(n) = O(n^{log_{b}a}) \\
2. & if a = b^d, i.e. d = log_{b}a = {log_{2}a \over log_2{b}}, then \ T(n) = O(n^dlogn)) = O(n^{log_{b}a}logn) \\
3. & if a < b^d, i.e. d > log_{b}a = {log_{2}a \over log_2{b}}, then \ T(n) = O(n^d)
}$$

So, generally, we are comparing $f(n)$ and $n^{log_{b}a}$, if $n^{log_{b}a}$ is larger, this is case1. If $f(n)$ is larger, this is case 3. If these 2 are equal, append log to it, this is case 2.

## Example

**1. $T(n) = O(n^{log_{b}a})$**

For [finding maximum depth of Binary Tree](https://en.wikipedia.org/wiki/Binary_tree), solve it by DFS, we need to find maximum depth of the given binary tree. The parameter in Master Theorem is:

- $b = 2$ => problem divided into 2 halves, left, right
- $a = 2$  => both subproblem needed to be solved
- $f(n) = O(1), d = 0$
  - => split problems in DFS is constant, since input is already organized as a collection of subproblem, i.e. children subtrees
  - => combine result from recursion calls is also constant

Therefore, the complexity for DFS recursion find depth of Binary Tree is: $d < log_{b}a, i.e. 0 < log_{2}2 = 1, T(n) = O(n^{log_{b}a}) = O(n)$

**2. $T(n) = O(n^dlogn)) = O(n^{log_{b}a}logn)$**

For [binary search algorithm](https://en.m.wikipedia.org/wiki/Binary_search_algorithm), which is a search algorithm that finds the position of target value in sorted array. The parameter in Master Theorem is:

- $b = 2$ => problem divided into 2 halves, left, right
- $a = 1$  => only one of the subproblem needed to be solved
- $f(n) = O(1), d = 0$
  - => split problems into 2 halves are constant, since input is sorted array and on can refer to a range of elements by index without iterating through array
  - => combine result from recursion calls is also constant, since we can simply return result of subproblem without further processing 

Therefore, the complexity for binary search algorithm is: $d = log_{b}a, i.e. 0 = log_{2}1, T(n) = O(n^dlogn)) = O(logn)$

**3. $T(n) = O(n^d)$**

For [quickselect](https://en.wikipedia.org/wiki/Quickselect), which is an algorithm that selects the $k$th largest/smallest element in an unsorted list. Quickselect algorithm partitions input list with certain pivot. Assume each time partition input into halves exactly, i.e. the chosen pivot is median of the input. The parameter in Master Theorem is:

- $b = 2$ => problem divided into 2 halves
- $a = 1$  => only need to look into one of the partitions
- $f(n) = O(n), d = 1$
  - => take $O(n)$ complexity to partition the input each time

Therefore, the complexity for quickselect is: $d = 1 > log_{2}1, T(n) = O(n^d) = O(n)$

However, Master Theorem has its limitations, it only applies to cases where the subproblem are of equal size. ex: we cannot apply it to Fibonacci number algorithm, where the problem is divided into 2 subproblem of different size.

#### Reference

- <https://en.wikipedia.org/wiki/Master_theorem_(analysis_of_algorithms)>
