---
layout: post
title: Swift Sort
date: 2020-02-08 15:14:00
comments: true
disqus_category_id: SwiftSort
categories: [Swift]
tags: [Sort]
---

We could sort any mutable collection of elements that conform to `Comparable` property by calling `sort()` method. Element are sorted in ascending order.

```swift
var students = ["Kofi", "Abena", "Peter", "Kweku", "Akosua"]
students.sort()
print(students)
// Prints "["Abena", "Akosua", "Kofi", "Kweku", "Peter"]"
```

For sorting the elements by descending order:

```swift
students.sort(by: >)
print(students)
// Prints "["Peter", "Kweku", "Kofi", "Akosua", "Abena"]"
```

The complexity of this method is `O(n log n)`, where n is the length of the collection.

## Algorithm

Before Swift5, Swift are using `IntroSort` algorithm:

- If element <= 20, use `Insertion Sort` with complexity of `On^2` in worst case but it might also have `O(n)` case
- If element large, use `QuickSort` with complexity of `O`(n log n)`

`IntroSort` could avoid: if the `QuickSort` tree are too deep(`2 * floor(log2(array.count))`), it will exchange to `Heapsort`.

`IntroSort` greedy try to provide the best algorithm by the case, under memory storage part, usually, it is worse than normal sorting algorithm. Also, `IntroSort` are unstable, though `InsertionSort` are stable, `QuickSort` and `HeapSort` are not. If the order of same element are important, then this is not a good idea.

After Swift, Swift are using `TimSort` algorithm:

- Use `InsertionSort` for small part
- Merge these part by `MergeSort`

Since `InsertionSort` & `MergeSort` are stable, so `TimSort` are also stable. It's complexity is `O(n log n)`

#### References

<https://developer.apple.com/documentation/swift/array/1688499-sort>

<https://github.com/apple/swift/blob/master/test/Prototypes/IntroSort.swift>

<https://en.wikipedia.org/wiki/Timsort>
