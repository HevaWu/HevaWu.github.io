---
layout: post
title: Ch06 - Decision Trees
date: 2021-08-30 22:36:00
comment_id: 190
categories: [ML]
tag: [Hands-On Machine Learning]
---

Visualize trained decision tree by using `export_graphviz()` to output a graph definition file (with extension of `.dot`). Then use `dot` command-line tool from Graphviz package to convert dot file to variety of formats.

```s
$ dot -Tpng xxx.dot -o xxx.png
```

# Making Predictions

`gini` attribute measures its `impurity`: a node is “pure” (gini=0) if all training instances it applies to belong to the same class.

$$
G_i = 1 - \sum_{k=1}^n p_{i,k}^2
$$

- $p_{i,k}$ is the ratio of class $k$ instances among the training instances in the $i^{th}$ node.

*NOTE: Scikit-Learn uses the `CART` algorithm, which `produces only binary trees`: nonleaf nodes always have two children (i.e., questions only have yes/no answers). However, other algorithms such as ID3 can produce Decision Trees with nodes that have more than two children.*

# The CART Training Algorithm

CART(Classification and Regression Tree (CART)): The algorithm works by first splitting the training set into two subsets using a single feature $k$ and a threshold $t_k$.

How does it choose $k$ and $t_k$? It searches for the pair $(k, t_k)$ that produces the purest subsets (weighted by their size).

CART cost function for classification:

$$
J(k, t_k) = \frac{m_{left}}{m} G_{left} + \frac{m_{right}}{m} G_{right} \\
\text{where }
\begin{cases}
G_{left/right} \text{ measures the impurity of the left/right subset} \\
m_{left/right} \text{ is the number of instances in the left/right subset}
\end{cases}
$$

It stops recursing once it reaches the maximum depth (defined by the `max_depth` hyperparameter), or if it cannot find a split that will reduce impurity. A few other hyperparameters (described in a moment) control additional stopping conditions (`min_samples_split`, `min_samples_leaf`, `min_weight_fraction_leaf`, and `max_leaf_nodes`).

# Computational Complexity

Decision Trees generally are approximately balanced, so traversing the Decision Tree requires going through roughly $O(log_2(m))$ nodes. Since each node only requires checking the value of one feature, `the overall prediction complexity` is $O(log_2(m))$, independent of the number of features.

Comparing all features on all samples at each node results in a training complexity of $O(n × m log_2(m))$.

For `small training sets` (less than a few thousand instances), Scikit-Learn `can speed up` training `by presorting` the data (set `presort=True`)

# Gini Impurity or Entropy

By default, Gini impurity measure is used. Can select `entropy` impurity by `set criterion to "entropy"`

A set’s entropy is zero when it contains instances of only one class. Definition:

$$
H_i = - \sum_{k=1,p_{i,k}\not ={0}}^n {p_{i,k}log_2(p_{i,k})}
$$

Difference use Gini impurity or entopy:
- most of the time it does not make a big difference: they lead to similar trees. Gini impurity is slightly faster to compute, so it is a good default
- when they differ, Gini impurity tends to isolate the most frequent class in its own branch of the tree, while `entropy tends to produce slightly more balanced trees`

# Regularization Hyperparameters

- `nonparametric model`: the number of parameters is not determined prior to training, so the model structure is free to stick closely to the data
- `parametric model`: has a predetermined number of parameters

Regularization: to avoid overfitting the training data. Generally you can at least restrict the maximum depth of the Decision Tree.

# Regression

Tries to split the training set in a way that minimizes the MSE.

CART cost function for Regression

$$
J(k, t_k) = \frac{m_{left}}{m} MSE_{left} + \frac{m_{right}}{m} MSE_{right} \\
\text{where }
\begin{cases}
MSE_{node} = \sum_{i \in node}(\hat{y}_{node}-y^{(i)})^2  \\
\hat{y}_{node} = \frac{1}{m_{node}} \sum_{i \in node}y^{(i)}
\end{cases}
$$

# Instability

Limitations of Decision Trees:

- **sensitive to training set rotation**. One way to limit this problem is to `use Principal Component Analysis`, which often results in a better orientation of the training data.
- **sensitive to small variations in the training data**. `Random Forests` can limit this instability by averaging predictions over many trees

#### References

- <https://learning.oreilly.com/library/view/hands-on-machine-learning/9781492032632/ch06.html#idm45022163595992>
