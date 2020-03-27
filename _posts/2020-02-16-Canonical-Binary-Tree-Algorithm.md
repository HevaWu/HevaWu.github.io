---
layout: post
title: Canonical Binary Tree Algorithm
date: 2020-02-16 12:02:00
comments: true
disqus_category_id: CanonicalBinaryTreeAlgorithm
categories: [Algorithm]
tags: [BinaryTree]
---

> In mathematics and computer science, a `canonical, normal`, or `standard form` of a mathematical object is a standard way of presenting that object as a mathematical expression. Often, it is one which provides the simplest representation of an object and which allows it to be identified in a unique way. The distinction between "canonical" and "normal" forms varies from subfield to subfield. In most fields, a canonical form specifies a `unique representation` for every object, while a normal form simply specifies its form, without the requirement of uniqueness.[

## Pseudocode

```
void doSomethingToAllNodes(Tree root) {
	if(root) {
    	doSomethingTo(root);
        doSomethingToAllNodes(root->left);
        doSomethingToAllNodes(root->right);
	}  
}
```

The function processes all nodes in what is called a preorder traversal, where the "preorder" part means that the root of any tree is processed first. Moving the call to doSomethingTo in between or after the two recursive calls yields an inorder or postorder traversal, respectively.

#### Reference

<https://en.wikipedia.org/wiki/Canonical_form>

<http://www.cs.yale.edu/homes/aspnes/pinewiki/BinaryTrees.html>