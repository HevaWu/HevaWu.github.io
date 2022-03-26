---
layout: post
title: Boyer–Moore Majority Vote
date: 2021-02-24 19:56:00
comment_id: 141
categories: [Algorithm]
tags: [Array]
---

> The Boyer–Moore majority vote algorithm is an algorithm for finding the majority of a sequence of elements using linear time and constant space
>
> The algorithm finds a majority element, if there is one: that is, an element that occurs repeatedly for more than half of the elements of the input.

## Idea

- Initialize an element m and a counter i with i = 0
- For each element x of the input sequence:
  - If i = 0, then assign m = x and i = 1
  - else if m = x, then assign i = i + 1
  - else assign i = i − 1
- Return m

### Swift implementation

```swift
// we garanteed only one majority element in nums array
func majorityElement(_ nums: [Int]) -> Int {
	var pick = nums[0]
	var count = 0
	
	for num in nums {
		if count == 0 { pick = num }
		count += (num == pick ? 1 : -1)
	}
	
	return pick
}
```

## Time Complexity

It only go through array once, which takes time $O(n)$. And it will only use constant extra space $O(1)$ to store counter.

#### References

- https://en.wikipedia.org/wiki/Boyer%E2%80%93Moore_majority_vote_algorithm
