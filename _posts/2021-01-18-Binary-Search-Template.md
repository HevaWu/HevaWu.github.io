---
layout: post
title: Binary Search Template
date: 2021-01-18 16:50:00
comment_id: 132
categories: [Algorithm]
tags: [Search]
---

> Binary search, also known as half-interval search, logarithmic search, or binary chop, is a search algorithm that finds the position of a target value within a sorted array.
>
> Binary search compares the target value to the middle element of the array. If they are not equal, the half in which the target cannot lie is eliminated and the search continues on the remaining half, again taking the middle element to compare to the target value, and repeating this until the target value is found. If the search ends with the remaining half being empty, the target is not in the array.

There are multiple templates of Binary Search, in them, most frequently we are using 3 templates:

```s
# Template 1
left = 0
right = len-1
while left <= right {
	mid = left + (right - left)/2
	if nums[mid] == target {
		return mid
	} else if nums[mid] < target {
		left = mid+1
	} else {
		right = mid-1
	}
}
# left == right + 1 now
# end

# Template 2
left = 0
right = len
while left < right {
	mid = left + (right - left)/2
	if nums[mid] < target {
		left = mid+1
	} else {
		right = mid
	}
}
# left == right now
# 1 more candidate, left, checking and end

# Template 3
left = 0
right = len-1
while left+1 < right {
	mid = left + (right - left)/2
	if nums[mid] < target {
		left = mid
	} else {
		right = mid
	}
}
# left+1 == right nonw
# 2 more candidate, left, right, checking and end
```

## Template 1 left <= right

- basic
- search condition can be determined without comparing to the neighbors(or use specific elements around it)
- `no post-processing` required, we check if elements has been found in each loop, if we reach the end, the elements is not found

## Template 2 left < right

- advanced way
- search condition need to access element's `immediate right neighbor`
- element's right neighbor determine if condition is met, then decide go left or right
- search space is at least 2 in size at each step
- `post-processing required`. loop ends when we `have 1 element left`, need to assess if remaining element meets the condition

## Template 3 left+1 < right

- alternative way
- search condition need to access element's `immediate left and right neighbor`
- element's neighbor determine if condition is met, then decide whether go left or right
- search space is at least 3 in size at each step
- `post-processing required`. loop ends when we `have 2 elements left`. need to assess if remaining elements meet the condition

## Time and Space Complexity

- Time Complexity: $O(\log n)$ where $n$ is number of elements in collection. Binary search operates by applying condition to value in th mid of search space, cutting search space in half. In the worst case, have to make $O(\log n)$ comparisons.
- Space Complexity: $O(1)$. Only need to keep track of 3 indicies, iterative solution not require other additional space.

#### Reference

- <https://en.wikipedia.org/wiki/Binary_search_algorithm>
