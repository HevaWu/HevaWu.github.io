---
layout: post
title: Kadane's Algorithm
date: 2020-03-21 20:44:00
comments: true
disqus_category_id: KadaneAlgorithm
categories: [Algorithm]
tags: [Sum]
---

## Maximum Subarray problem

finding a contiguous subarray with the largest sum, within a given one-dimensional array A[1...n] of numbers. Formally, the task is to find indices i and j with 1 <= i <=j <= n such that sum

![sum](/images/2020-03-21-Kadane-s-Algorithm/sum.png#simulator)

is as large as possibble.

For example, for the array of values [−2, 1, −3, 4, −1, 2, 1, −5, 4], the contiguous subarray with the largest sum is [4, −1, 2, 1], with sum 6.

Some properties of this problem are:

- If the array contains all non-negative numbers, then the problem is trivial; a maximum subarray is the entire array.
- If the array contains all non-positive numbers, then a solution is any subarray of size 1 containing the maximal value of the array (or the empty subarray, if it is permitted).
- Several different sub-arrays may have the same maximum sum.

## Kadane's Algorithm

For solving maximum sum subarray problem, we could use `Kadane's algorithm`.

```python
def max_subarray(numbers):
     """Find a contiguous subarray with the largest sum."""
     best_sum = 0  # or: float('-inf')
     current_sum = 0
     for x in numbers:
         current_sum = max(0, current_sum + x)
         best_sum = max(best_sum, current_sum)
     return best_sum

# keep track of starting and ending indices

def max_subarray(numbers):
     """Find a contiguous subarray with the largest sum."""
     best_sum = 0  # or: float('-inf')
     best_start = best_end = 0  # or: None
     current_sum = 0
     for current_end, x in enumerate(numbers):
         if current_sum <= 0:
             # Start a new sequence at the current element
             current_start = current_end
             current_sum = x
         else:
             # Extend the existing sequence with the current element
             current_sum += x
 
         if current_sum > best_sum:
             best_sum = current_sum
             best_start = current_start
             best_end = current_end + 1  # the +1 is to make 'best_end' exclusive
 
     return best_sum, best_start, best_end
```

#### Reference

<https://en.wikipedia.org/wiki/Maximum_subarray_problem>