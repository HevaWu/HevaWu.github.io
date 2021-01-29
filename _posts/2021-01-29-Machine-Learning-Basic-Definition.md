---
layout: post
title: Machine Learning Basic Definition
date: 2021-01-29 21:34:00
comment_id: 136
categories: [ML]
tags: [Definition]
---

> Machine learning (ML) is the study of computer algorithms that improve automatically through experience.

I'd like to list some definition around ML, which can searchable later.

- `Supervised Learning`: In a supervised learning task, the data sample would contain a target attribute $y$, also known as ground truth. And the task is to learn a function $F$, that takes the non-target attributes X and output a value that approximates the target attribute, i.e. $F(X) \approx y$
- `Unsupervised Learning`: do not have the ground truth in an unsupervised learning task. ex:
  - **Clustering**: given a data set, one can cluster the samples into groups, based on the similarities among the samples within the data set. 
  - **Association**: given a data set, the association task is to uncover the hidden association patterns among the attributes of a sample.
- `Semi-supervised Learning`: the data set is massive but the labeled sample are few, one might find the application of both supervised and unsupervised learning
- `Classification Model`: the output of a machine learning model is discrete values, e.g. a boolean value
- `Regression Model`: the model that outputs continuous values
- `Data-Centric Workflow`: The workflow to build a machine learning model is centralized around the data.
![](/images/2021-01-29-Machine-Learning-Basic-Definition/centric_flow.png)
  - **Training process**: select one of the machine learning algorithms, and start to feed the algorithm with the prepared training data
  - **Testing process**: test the model with the reserved testing data
  - **hyper-parameter tuning**: go back to the training process and tune some parameters that are exposed by the model that we selected. The reason that it is highlighted as 'hyper' is because the parameters that we tune are the outermost interface that we interact with the model, which would eventually have impacts on the underlying parameters of the model.
- `Underfitting`: the one that does not fit well with the training data, i.e. significantly deviated from the ground truth. 
- `Overfitting`: the one that fits well with the training data, i.e. little or no error, however it does not generalized well to the unseen data.
- `Bias`: a learner’s tendency to consistently learn the same wrong thing. A learner (algorithm) on the example ${(\vec{x_i}, t_i)}$ is defined as $B(\vec{x_i}) = L(y_m, t_i)$, where ${y_m}$
is the main prediction, ${t_i}$ is the target value, and $L$ is the loss function.
- `Variance`: the tendency to learn random things unrelated to the real signal.a learner (algorithm) on the example ${(\vec{x_i}, t_i)}$ is defined as $V(\vec{x_i}) = E_S(L(y_m, y))$, where ${y_m}$ is the main prediction, yy is a prediction produced from a model that is trained on a training set ${s \in S}$, ${L}$ is the loss function, and $E_S$ is the average function over the list of loss values. 

#### Reference

- <https://en.wikipedia.org/wiki/Machine_learning>
