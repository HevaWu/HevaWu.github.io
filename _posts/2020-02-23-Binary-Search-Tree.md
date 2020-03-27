---
layout: post
title: Binary Search Tree
date: 2020-02-23 10:24:00
comments: true
disqus_category_id: BinarySearchTree
categories: [Algorithm, Search]
tags: [Tree, Trie]
---

Search Tree data structure support operations as `SEARCH`, `MINIMUM`, `MAXIMUM`,`PREDECESSOR`, `SUCCESSOR`, `INSERT`, `DELETE`, etc. Thus, we could use a search tree as a dictionary or a priority queue.

The time complexity of `Binary Search Tree` basic operations are in proportion to the height of Tree. For a n node complete binary search tree, the worst time complexity would be `O(lgn)`. However, if this tree is a n node linear list, the same operation would take O(n).

## Overviews

Except key and stored data, each node contains `left`, `right`, `p`, where are left children, right children, and parent. If the children and parent node are not exist, they will be set as `nil`.

The requirement:
- x is a node of binary search tree. If y is one of x's left node, then y.key <= x.key. If y is one of y's right node, then y.key >= x.key.

## Tree Walk

- `Inorder Tree Walk`: left, root, right
- `Preorder Tree Walk`: root, left, right
- `Postorder Tree Walk`: left, right, root

Time complexity: O(n)

## Search

```
// Tree-Search(x,k)
if x == NIL, or k == x.key 
	return x
if k < x.key
	return Tree-Search(x.left, k)
else return Tree-Search(x.right, k)
```

Time complexity: O(h) <- h is height of this tree

We could also use while to iterate the tree:

```
// Iterative-Tree-Search(x,k)
while x != NIL, and k != x.key
	if k < x.key
		x = x.left
	else x = x.right
return x
```

## Maximum & Minimum

```
// Tree-Minimum(x)
while x.left != nil
	x = x.left
return x

// Tree-Maximum(x)
while x.right != nil
	x = x.right
return x
```

Time complexity: O(h) <- h is height of this tree

## Successor & Predecessor

```
// Tree-Successor(x)
if x.right != nil
	return Tree-Minimum(x.right)
y = x.p
while y != nil and x == y.right
	x = y
	y = y.p
return y
```

Time complexity: O(h) <- h is height of this tree

## Insert & Delete

```
// Tree-Insert(T,z)
y = nil
x = T.root
while x != nil
	y = x
	if z.key < x.key
		x = x.left
	else x = x.right
z.p = y
if y == nil
	T.root = z
elseif z.key < y.key
	y.left = z
else y.right = z
```

Time complexity: O(h) <- h is height of this tree

```
// Transplant(T,u,v)
if u.p == nil
	T.root = v
elseif u == u.p.left
	u.p.left = v
else u.p.right == v
if v != nil
	v.p = u.p

// Tree-Delete(T,z)
if z.left == nil
	Transplant(T, z, z.right)
elseif z.right == nil
	Transplant(T, z, z.left)
else y = Tree-Minimum(z.right)
	if y.p != z
		Transplant(T, y, y.right)
		y.right = z.right
		y.right.p = y
	Transplant(T, z, y)
	y.left = z.left
	y.left.p = y
```

Time complexity: O(h) <- h is height of this tree

## Trie

> In computer science, a `trie`, also called `digital tree` or `prefix tree`, is a kind of search tree—an ordered tree data structure used to store a dynamic set or associative array `where the keys are usually strings`. Unlike a binary search tree, no node in the tree stores the key associated with that node; instead, `its position in the tree defines the key with which it is associated`. `All the descendants of a node have a common prefix` of the string associated with that node, and the root is associated with the empty string. Keys tend to be associated with leaves, though some inner nodes may correspond to keys of interest. Hence, keys are not necessarily associated with every node.

#### Reference

<https://en.wikipedia.org/wiki/Binary_search_tree>

<https://en.wikipedia.org/wiki/Trie>