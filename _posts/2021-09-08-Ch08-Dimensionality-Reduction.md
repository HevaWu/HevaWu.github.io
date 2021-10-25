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

## Projecting Down to d Dimensions

Once you have identified all the principal components, you can reduce the dimensionality of the dataset down to d dimensions by projecting it onto the hyperplane defined by the first d principal components.

Projecting the training set down to d dimensions:

$$
\text{X}_{d-proj} = \text{X}\text{W}_d
$$

## Using Scikit-Learn

Scikit-Learn’s `PCA` class uses `SVD decomposition` to implement PCA.

## Explained Variance Ratio

`explained variance ratio`: indicates the proportion of the dataset’s variance that lies along each principal component. available via `explained_variance_ratio_` variable

## Choosing the Right Number of Dimensions

Example of preserve 95% of training set's variance, and use auto-pick right number of dimensions

```python
# option 1
pca = PCA()
pca.fit(X_train)
cumsum = np.cumsum(pca.explained_variance_ratio_)
d = np.argmax(cumsum >= 0.95) + 1
pca = PCA(n_components = d) # run again

# option 2
pca = PCA(n_components=0.95)
```

## PCA for Compression

After dimensionality reduction, the training set takes up much less space.

It's also possible to `decompress` the reduced dataset back to original dimensions by applying the `inverse` transformation of PCA projection. NOTE, this will not give back original data, this will only likely close to original data.

`reconstruction error`: The mean squared distance between the original data and the reconstructed data (compressed and then decompressed)

PCA inverse transformation, back to the original number of dimensions:

$$
\text{X}_{recovered} = \text{X}_{d-proj}\text{W}^{\top}
$$

## Randomized PCA

`Randomized PCA`: quickly finds an approximation of the first d principal components. Set it with `svd_solver="randomized"` in Scikit-Learn

Its computational complexity is O(m × d2) + O(d3), instead of O(m × n2) + O(n3) for the full SVD approach, so it is dramatically faster than full SVD when d is much smaller than n.

```python
rnd_pca = PCA(n_components=154, svd_solver="randomized")
X_reduced = rnd_pca.fit_transform(X_train)
```

By default, `svd_solver` is actually set to `"auto"`: Scikit-Learn automatically uses the randomized PCA algorithm `if m or n is greater than 500 and d is less than 80% of m or n`, or else it uses the full SVD approach. If you want to force Scikit-Learn to use full SVD, you can set the `svd_solver` hyperparameter to `"full"`.

## Incremental PCA

`Incremental PCA (IPCA)`: split the training set into mini-batches and feed an IPCA algorithm one mini-batch at a time.

*NOTE: use `partial_fit()` with mini-batch, rather than fit().*

Numpy's `memmap`: allows you to manipulate a large array stored in a binary file on disk as if it were entirely in memory; the class loads only the data it needs in memory, when it needs it.

# Kernel PCA

`Kernel PCA(kPCA)`: implicitly maps instances into a very high-dimensional space (called the feature space), enabling nonlinear classification and regression with Support Vector Machines. Use `from sklearn.decomposition import KernelPCA` in Scikit-Learn

## Selecting a Kernel and Tuning Hyperparameters

### Approach 1:

1. dimensionality reduction
2. grid search to select best kernel and gamma

### Approach 2:

select the kernel and hyperparameters that yield the lowest reconstruction error.

*NOTE: if we could invert the linear PCA step for a given instance in the reduced space, the reconstructed point would lie in feature space, not in the original space (e.g., like the one represented by an X in the diagram).*

**How to perform reconstruction**

train a supervised regression model, with projected instances as the training set and the original instances as the targets. In Scikit-Lean, set `fit_inverse_transform = TRUE` will do this automatically

## LLE

`LLE(Locally Linear Embedding)`: non linear dimensionality reduction(NLDR) technique.

- works by first measuring how each training instance linearly relates to its closest neighbors (c.n.), and then looking for a low-dimensional representation of the training set where these local relationships are best preserved (more details shortly).

### Algorithm

Step1: Linearly modeling local relationships

for each training instance $x^{(i)}$, the algorithm identifies its $k$ closest neighbors (in the preceding code $k = 10$), then tries to reconstruct $x^{(i)}$ as a linear function of these neighbors.

$$
\hat{W} = \text{argmin} \sum_{i=1}^m(x^{(i)} - \sum_{j=1}^m w_{i,j} x^{(j)})^2 \\
\text{subject to}

\begin{cases}
w_{i,j} = 0 \text{   if x(j) is not one of the k c.n. of x(i)} \\
\sum_{j=1}^{m} w_{i,j} = 1 \text{   for i = 1,2, ..., m}
\end{cases}
$$

Step 2: Reducing dimensionality while preserving relationships

$$
\hat{Z} = \text{argmin} \sum_{i=1}^m(z^{(i)} - \sum_{j=1}^m \hat{w_{i,j}} x^{(j)})^2
$$

Time Complexit: $O(m log(m)n log(k))$ for finding $k$ nearest neighbors, $O(mnk^3)$ for optimizing the weight, and $O(dm^2)$ for constructing low dimensional representations.

The last step $m^2$ make this algorithm scale poorly to very large datasets.

# Other Dimensionality Reduction techniques

- `Random Projections`: projects the data to a lower-dimensional space using a random linear projection.
- `Multidimensional Scaling (MDS)`: Reduces dimensionality while trying to preserve the distances between the instances.
- `Isomap`: Creates a graph by connecting each instance to its nearest neighbors, then reduces dimensionality while trying to preserve the geodesic distances between the instances.
- `t-Distributed Stochastic Neighbor Embedding (t-SNE)`: Reduces dimensionality while trying to keep similar instances close and dissimilar instances apart.
- `Linear Discriminant Analysis (LDA)`: Is a classification algorithm, but during training it learns the most discriminative axes between the classes, and these axes can then be used to define a hyperplane onto which to project the data.

#### References

- <https://learning.oreilly.com/library/view/hands-on-machine-learning/9781492032632/ch08.html>
