---
layout: post
title: Union Find
date: 2020-02-15 11:21:00
comment_id: 52
categories: [Algorithm]
tags: [UnionFind]
---

Some application needs to seperate n element into `disjoint set`. Almostly it needs 2 operations:

- Find the set contains specific element
- Union 2 set

## Basic Operations

A `disjiont-set` data structure maintain a disjoint dynamic set. We use one `representative` to mark each set. We hope some operations as:

- `MAKE-SET(x)`: build a new set, and the only element in it is x, since each set is disjoint, so x will not appear in another set
- `UNION(x,y)`: union the set contains x & set contains y. The representative of the new set might be the old x set or y set representative, but it might not.
- `FIND-SET(x)`: return a pointer to representative of the only set which contains element x.

## Use Linked List to Disjoint Set

Each set might use its own linked list to show. Each set contains `head` & `tail`. `head` point to the first element in the list, `trail` point the last one.

Use this method, `MAKE-SET` & `FIND-SET` is very convenience, only need to take `O(1)` time for `MAKE-SET` and use pointer on `FIND-SET`.

But the `UNION` take more time. ex: prepare merge x list & y list, link y to the tail of x is okay, but for each element in y, we need to update the pointer to the set representative, and this will take long time. Thus, for most of time ,we link the shorter one to the longer time.

By using the simple `weighted union heuristic`, a set contains m `MAKE-SET`, `UNION-SET`, `FIND-SET operations` will take `O(+nlgn)` time.

## Disjoint Set Forest

For faster, we could use root tree to show the set. Each node contains one element, each tree represent a set. In `disjoint-set forest`, each member only point to its parent.

### How to optimize time complexity

- Union by rank

It looks same as weighted linked list. Let the root contains less node point to the root contains more node.

- Path compression

[a->b->c->d->e->f] => [f->a, f->b, f->c, f->d, f->e]

### Implementation

```
// MAKE-SET(x)
x.p = x
x.rank = 0

// UNION(x,y)
LINK(FIND-SET(x), FIND-SET(y))

// LINK(x,y)
if x.rank > y.rank
	y.p = x
else 
	x.p = y
	if x.rank == y.rank
		y.rank = y.rank + 1

// FIND-SET(x)
if x != x.p
	x.p = FIND-SET(x.p)
return x.p
```
