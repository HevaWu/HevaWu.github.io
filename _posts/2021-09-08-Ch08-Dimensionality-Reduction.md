---
layout: post
title: Ch08 - Dimensionality Reduction
date: 2021-09-08 22:02:00
comment_id: 194
categories: [ML]
tags: [Hands-On Machine Learning]
---

`curse of dimensionality`: Not only do all these features make training extremely slow, but they can also make it much harder to find a good solution.

*WARN: if training is too slow, you should first try to train your system with the original data before considering using dimensionality reduction. In some cases, reducing the dimensionality of the training data may filter out some noise and unnecessary details and thus result in higher performance, but in general it won’t; it will just speed up training.*

Dimensionality reduction useful for `speed up training` and `data visualization`.

The more dimensions the training set has, the greater the risk of overfitting it.

# Main Approaches for Dimensionality Reduction

Two main approaches to reducing dimensionality: `projection` and `Manifold Learning`.

## Projection

Training instances are `not spread out uniformly` across all dimensions. Many features are almost `constant`, while others are `highly correlated`. As a result, all training instances lie within (or close to) a much lower-dimensional `subspace` of the high-dimensional space.

projection is not always the best approach to dimensionality reduction. In many cases the subspace may twist and turn, such as in the famous `Swiss roll toy dataset`. ⬇️

![](/images/2021-09-08-Ch08-Dimensionality-Reduction/mls2_0804.png)

## Manifold Learning

A `d-dimensional manifold` is a part of an n-dimensional space (where d < n) that locally resembles a d-dimensional hyperplane. In the case of the Swiss roll, d = 2 and n = 3: it locally resembles a 2D plane, but it is rolled in the third dimension.

- `Manifold Learning`: modeling the manifold on which the training instances lie
- `Manifold assumption/Manifold Hypothesis`: most real-world high-dimensional datasets lie close to a much lower-dimensional manifold.
- implicit assumption: the task at hand (e.g., classification or regression) will be simpler if expressed in the lower-dimensional space of the manifold.
  - this implicit assumption does not always hold

Reducing the dimensionality of your training set before training a model will usually speed up training, but it may not always lead to a better or simpler solution.

# PCA

`PCA(Principal Component Analysis)` is by far the most popular dimensionality reduction algorithm.

First it identifies the hyperplane that lies closest to the data, and then it projects the data onto it.

## Preserving the variance

`Select the axis that preserves the maximum amount of variance`, as it will most likely lose less information than the other projections.

## Principal Components

The $i^{th}$ axis is called the $i^{th}$ `principal component(PC)`.

*NOTE: `For each principal component, PCA finds a zero-centered unit vector pointing in the direction of the PC`. Since two opposing unit vectors lie on the same axis, the direction of the unit vectors returned by PCA is not stable. However, they will generally still lie on the same axes. In some cases, a pair of unit vectors may even rotate or swap (if the variances along these two axes are close), but the plane they define will generally remain the same.*

`Singular Value Decomposition (SVD)`: help finding principle components of training set. SVD can decompose the training set matrix $X$ into the matrix multiplication of three matrices $U \sum V^\top$, where $V$ contains the unit vectors that define all the principal components that we are looking for.

Principle Components Matrix:

$$
V = \begin{pmatrix}
    | & | & & | \\
    c_1 & c_2 & ... & c_n \\
    | & | & & |
    \end{pmatrix}
$$

Use NumPy’s `svd()` function to obtain all the principal components of the training set.

*WARN: PCA assumes that the `dataset is centered` around the origin.*

#### References

- <https://learning.oreilly.com/library/view/hands-on-machine-learning/9781492032632/ch08.html>
