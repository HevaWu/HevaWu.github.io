---
layout: post
title: ML Reading Ch05 - Support Vector Machines
date: 2021-07-18 21:51:00
comment_id: 175
categories: [ML]
---

> Support Vector Machine (SVM) are particularly well suited for classification of complex small- or medium-sized datasets.

# Linear SVM Classification

- `large margin classification`: an SVM classifier as fitting the widest possible street (represented by the parallel dashed lines) between the classes
- `support vectors`: the instances located on the edge of the street

*NOTE: SVMs are sensitive to the feature scales. After feature scaling (e.g., using `Scikit-Learn’s StandardScaler`), the decision boundary in the right plot looks much better.*

## Soft Margin Classification

- `hard margin classification`: strictly impose that all instances must be off the street and on the right side

2 main issue with `hard margin classification`

- it only works if the data is linearly separable
- it is sensitive to outliers.

To avoid the issue, do `soft margin classification`. The objective is to find a good balance between keeping the street as large as possible and limiting the margin violations.

- `margin violations`: instances that end up in the middle of the street or even on the wrong side

When creating an SVM model using Scikit-Learn, we can specify a number of hyperparameters. C is one of those hyperparameters.
If your SVM model is overfitting, you can try regularizing it by reducing C.

*NOTE: Unlike Logistic Regression classifiers, SVM classifiers do not output probabilities for each class. The LinearSVC class regularizes the bias term, so you should center the training set first by subtracting its mean. This is automatic if you scale the data using the StandardScaler. Also make sure you set the loss hyperparameter to "hinge", as `it is not the default value`. Finally, for better performance, you should `set the dual hyperparameter to False`, unless there are more features than training instances.*

Instead of using the `LinearSVC` class, we could use the SVC class with a linear kernel. When creating the SVC model, we would write `SVC(kernel="linear", C=1)`. Or we could use the `SGDClassifier` class, with `SGDClassifier(loss="hinge", alpha=1/(m*C))`. This applies regular `Stochastic Gradient Descent` (see Chapter 4) to train a linear SVM classifier. It does not converge as fast as the LinearSVC class, but it can be useful to handle online classification tasks or huge datasets that do not fit in memory (out-of-core training).

# Nonlinear SVM Classification

One approach to handling nonlinear datasets is to add more features, such as `polynomial` features.

## Polynomial Kernel

`kernel trick`: makes it possible to get the same result as if you had added many polynomial features, even with very high-degree polynomials, without actually having to add them

*TIP: A common approach to finding the right hyperparameter values is to use grid search (see Chapter 2). It is often faster to first do a very coarse grid search, then a finer grid search around the best values found.*

## Similarity Features

Another technique to tackle nonlinear problems is to `add features computed using a similarity function`, which measures how much each instance resembles a `particular landmark`.

Gaussian Radial Basis Function (RBF):

$$
\phi_\gamma(x, \ell) = exp(-\gamma \|x-\ell \|^2)
$$

## Gaussian RBF Kernel

The similarity features method can be useful with any Machine Learning algorithm, but it may be computationally expensive to compute all the additional features, especially on large training sets.

gamma $\gamma$ acts like a regularization hyperparameter: if your model is overfitting, you should reduce it; if it is underfitting, you should increase it (similar to the C hyperparameter).

- Increasing gamma($\gamma$) makes the bell-shaped curve narrower. As a result, each instance’s range of influence is smaller: the decision boundary ends up being more irregular, wiggling around individual instances.
- a small gamma value makes the bell-shaped curve wider: instances have a larger range of influence, and the decision boundary ends up smoother

`String kernels` are sometimes used when `classifying text documents or DNA sequences` (e.g., using the string subsequence kernel or kernels based on `the Levenshtein distance`).

*TIP: How to decide which kernel to use? you should always try the linear kernel first (remember that LinearSVC is much faster than SVC(kernel="linear")), especially if the training set is very large or if it has plenty of features. If the training set is not too large, you should also try the Gaussian RBF kernel; it works well in most cases. Then if you have spare time and computing power, you can experiment with a few other kernels, using cross-validation and grid search. You’d want to experiment like that especially if there are kernels specialized for your training set’s data structure.*

## Computational Complexity

The `LinearSVC` class is based on the `liblinear library`, which implements an optimized algorithm for linear SVMs. not support the kernel trick, but it scales almost linearly with the number of training instances and the number of features. Its training time complexity is roughly $O(m × n)$.

The algorithm takes longer if you require very high precision. This is controlled by the `tolerance hyperparameter` $\varepsilon$ (called tol in Scikit-Learn). In most classification tasks, the default tolerance is fine.

The `SVC` class is based on the `libsvm` library, which implements an algorithm that `supports the kernel trick`. The training time complexity is usually between $O(m^2 × n)$ and $O(m^3 × n)$. This algorithm is perfect for complex small or medium-sized training sets. It scales well with the number of features, especially with sparse features (i.e., when each instance has few nonzero features).

Comparison of Scikit-Learn classes for SVM classification:

| Class  |  Time Complexity | Out-of-core support | Scaling required | Kernel trick |
|---|---|---|---|---|
| LinearSVC  |  $O(m × n)$ | No | Yes | No |
| SGDClassifier  |  $O(m × n)$ | Yes | Yes | No |
| CVC  |  $O(m ^2 × n)$ to $O(m^3 × n)$ | No | Yes | Yes |

# SVM Regression

SVM Regression tries to fit as many instances as possible on the street while limiting margin violations (i.e., instances off the street). The width of the street is controlled by a hyperparameter, $\varepsilon$.

Adding more training instances within the margin does not affect the model’s predictions; thus, the model is said to be $\varepsilon$`-insensitive`.

Can use Scikit-Learn’s `LinearSVR` class to perform linear SVM Regression.

The `LinearSVR` class `scales linearly` with the size of the training set (just like the LinearSVC class), while the `SVR` class `gets much too slow` when the training set grows large (just like the SVC class).

# Under the Hood

How SVMs make predictions and how their training algorithms work.
(I might watch deeper when I roughly understand how to use it.)

- <https://learning.oreilly.com/library/view/hands-on-machine-learning/9781492032632/ch05.html>

#### References

- <https://learning.oreilly.com/library/view/hands-on-machine-learning/9781492032632/ch05.html>>
