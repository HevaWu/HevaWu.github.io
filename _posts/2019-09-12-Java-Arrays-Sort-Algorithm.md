---
layout: post
title: Java Arrays Sort Algorithm
date: 2019-09-12 10:57:00
comments: true
disqus_category_id: JavaArraysSortAlgorithm
categories: [Sort, Java, Arrays]
tags: [Sort, Java, Arrays, Dual Pivot Quick Sort, Merge Sort]
---

`java.util.Arrays` uses

- quicksort(dual pivot quick sort) : primitive types such as `int`
- mergesort : for objects that implement `Comparable` or use the `Comparator`

quicksort <- fast
mergesort <- stable

Dual pivot quicksort is a combination of insertion sort and quick sort. Insertion sort has faster runtime when the number of elements t obe sorted is small, double pivot quicksort uses this fact thus when the number of elements is <= 47 Java performs insertion sort under the hood.

When input size array is larger than 47 Java uses `Doubl pivot quicksort`.

## Dual Pivot Quick Sort

Single pivot quick sort takes a pivot from one of the ends of the array and partitioning the array, so that all elements which at the left side are less than or equal to the pivot, and all elements which at the right side are greater than pivot.

The idea of dual pivot quick sort is to take two pivots. One in the left end of the array and the second, in the right end of array. The left pivot must be less than or equal to the right pivot, if it is not, we swap them. Then begin partitioning the array into 3 parts:

- In the first part, all elements will be less than the left pivot.
- In the second part, all elements will be greater or equal to the left pivot and also will be less than or equal to the right pivot
- In the third part, all elements will be greater than the right pivot

| < LP | LP | LP<= & <= RP | RP | RP < |

Dual pivot quick sort is typlically faster than traditional single pivot quicksort. This algorithm offers `O(n log(n))` performance on many data sets that cause other quicksorts to degrade to quadratic performance.

![dual_pivot_quick_sort](/images/2019-09-12-Java-Arrays-Sort-Algorithm/dual_pivot_quick_sort.png)

### Reference

[Why java.util.Arrays uses Two Sorting Algorithms](https://cafe.elharo.com/programming/java-programming/why-java-util-arrays-uses-two-sorting-algorithms/)
[Dual Pivot Quick Sort](https://www.geeksforgeeks.org/dual-pivot-quicksort/)
