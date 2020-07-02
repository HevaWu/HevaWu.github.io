---
layout: post
title: Merge Sort
date: 2019-09-22 23:19:00
comments: true
disqus_category_id: MergeSort
categories: [Algorithm]
tags: [Sort]
---

## Divide And Conquer Algorithem

Many algorithm are regression: for solving one problem, it call one or more times related function
to solve the small problems.
These algorithm are typically follow the `Divide And Conquer Method`:
Divide the original problem to several small related small problems. The solve these small problems regressively, and combine the result of these small problems.

## Step

### Divide And Conquer

1. `Divide` the original problem to small problems
2. `Solve` the small problems, these small problems are related to the original one but scale is small
3. `Combine` the result of these small problems which will be the solution of the original problem

### Merge Sort

1. `Divide`: divide array (length: n) into 2 sub-arrays (length: n/2)
2. `Solve`: use merge sort recursively sort 2 sub-arrays
3. `Combine`: combine 2 sorted sub-arrays to get the final array

### Example

![Merge_sort_algorithm_diagram](/images/2019-09-22-MergeSort/Merge_sort_algorithm_diagram.png)

## Pseudocode

```shell
Merge(A, p, q, r) <- O(r-p+1)
n1 = q - p + 1
n2 = r - q
let L[1..n1+1] and R[1..n2+1] be new arrays
for i = 1 to n1
  L[i] = A[p + i - 1]
for j = 1 to n2
  R[j] = A[q+j]
L[n1+1] = $\infty$ <- sentry
R[n2+1] = $\infty$ <- sentry
i = 1
j = 1
for k = p to r
  if L[i] <= R[j]
    A[k] = L[i]
    i = i + 1
  else A[k] = R[j]
    j = j + 1
```

```shell
Merge-Sort(A, p, r)
if p < r
  q = ⌊(p+r)/2⌋
  Merge-Sort(A, p, q)
  Merge-Sort(A, q+1, r)
  Merge(A, p, q, r)
```

## Time Complexity

The time complexity of `Merge Sort` is $O(nlog_{2}n)$.
