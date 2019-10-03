---
layout: post
title: Insertion Sort
date: 2019-02-17 00:14:00
comments: true
disqus_category_id: InsertionSort
categories: [Algorithm, Sort]
tags: [Insertion Sort, Sort]
---

Let's see the introduction from the [wiki](https://en.wikipedia.org/wiki/Insertion_sort)

> Insertion sort is a simple sorting algorithm that builds the final sorted array (or list) one item at a time. It is much less efficient on large lists than more advanced algorithms such as quicksort, heapsort, or merge sort. However, insertion sort provides several advantages:
>
> Simple implementation: Jon Bentley shows a three-line C version, and a five-line optimized version[2]
> Efficient for (quite) small data sets, much like other quadratic sorting algorithms
> More efficient in practice than most other simple quadratic (i.e., O(n2)) algorithms
such as selection sort or bubble sort
> Adaptive, i.e., efficient for data sets that are already substantially sorted: the
time complexity is O(kn) when each element in the input is no more than k places away
from its sorted position
> Stable; i.e., does not change the relative order of elements with equal keys
> In-place; i.e., only requires a constant amount O(1) of additional memory space
> Online; i.e., can sort a list as it receives it

Insertion Sort is quite useful for sorting a few elements. The idea is:
- Start from the 2nd element, we start comparing it with the former sorted one. Until we found a proper place to put it.

For sorting an array A, we sort the elements inside A. During sorting, it will only have **constant elements** ourside of the array. When `Insertion Sort` is finished, the output array will be the sorted array.

Let's check the code together:
```swift
func insertionSort(array: [Int]) -> [Int] {
    var output: [Int] = array
    for index in 1...output.count-1 {
        let current = output[index]
        var j = index - 1
        while j >= 0 && output[j] > current {
            output[j+1] = output[j]
            j = j - 1
        }
        output[j+1] = current
    }
    return output
}
```

And if we add this run this code :
```swift
let A: [Int] = [4,5,7,9,0,3,1,4,6,8]
let sortedA = insertionSort(array: A)
// output: [0, 1, 3, 4, 4, 5, 6, 7, 8, 9]
```

After reading the code, we could quickly find it worst time-complexity is O(n^2).
This is the simplest sorting algorithm, and I will introduce other sorting algorithm in the future. :satisfied:
