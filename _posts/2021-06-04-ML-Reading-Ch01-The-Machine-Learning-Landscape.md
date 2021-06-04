---
layout: post
title: ML Reading Ch01 - The Machine Learning Landscape
date: 2021-06-04 10:30:00
comment_id: 158
categories: [ML]
---

# Types of Machine Learning Systems

- Whether or not they are trained with human supervision (supervised, unsupervised, semisupervised, and Reinforcement Learning)
- Whether or not they can learn incrementally on the fly (online versus batch learning)
- Whether they work by simply comparing new data points to known data points, or instead by detecting patterns in the training data and building a predictive model, much like scientists do (instance-based versus model-based learning)

## Supervised/Unsupervised Learning

There are four major categories: supervised learning, unsupervised learning, semisupervised learning, and Reinforcement Learning.

### SUPERVISED LEARNING

In `supervised learning`, the training set you feed to the algorithm includes the desired solutions, called `labels`.

Here are some of the most important supervised learning algorithms:

- k-Nearest Neighbors
- Linear Regression
- Logistic Regression
- Support Vector Machines (SVMs)
- Decision Trees and Random Forests
- Neural networks2

### UNSUPERVISED LEARNING

In `unsupervised learning`, as you might guess, the training data is `unlabeled`. The system tries to learn without a teacher.

Here are some of the most important unsupervised learning algorithms:

- Clustering
  - K-Means
  - DBSCAN
  - Hierarchical Cluster Analysis (HCA)
- Anomaly detection and novelty detection
  - One-class SVM
  - Isolation Forest
- Visualization and dimensionality reduction
  - Principal Component Analysis (PCA)
  - Kernel PCA
  - Locally Linear Embedding (LLE)
  - t-Distributed Stochastic Neighbor Embedding (t-SNE)
- Association rule learning
  - Apriori
  - Eclat

Related Task:
- `dimensionality reduction`, in which the goal is to simplify the data without losing too much information. One way to do this is to merge several correlated features into one.
  - for example, a car’s mileage may be strongly correlated with its age, so the dimensionality reduction algorithm will merge them into one feature that represents the car’s wear and tear. This is called `feature extraction`.
  - *Tips: It is often a good idea to try to reduce the dimension of your training data using a dimensionality reduction algorithm before you feed it to another Machine Learning algorithm (such as a supervised learning algorithm). It will run much faster, the data will take up less disk and memory space, and in some cases it may also perform better.*
- `anomaly detection`.
  - for example, detecting unusual credit card transactions to prevent fraud, catching manufacturing defects, or automatically removing outliers from a dataset before feeding it to another learning algorithm. The system is shown mostly normal instances during training, so it learns to recognize them; then, when it sees a new instance, it can tell whether it looks like a normal one or whether it is likely an anomaly.
- `Association rule learning`, the goal is to dig into large amounts of data and discover interesting relations between attributes.
  - for example, suppose you own a supermarket. Running an association rule on your sales logs may reveal that people who purchase barbecue sauce and potato chips also tend to buy steak. Thus, you may want to place these items close to one another

### SEMISUPERVISED LEARNING

`Semisupervised learning`: labeling data is usually time-consuming and costly, you will often have plenty of unlabeled instances, and few labeled instances. Some algorithms can deal with data that’s partially labeled.

ex: Google Photos, are good examples of this. Once you upload all your family photos to the service, it automatically recognizes that the same person A shows up in photos 1, 5, and 11, while another person B shows up in photos 2, 5, and 7. This is the unsupervised part of the algorithm (clustering). Now all the system needs is for you to tell it who these people are. Just add one label per person4 and it is able to name everyone in every photo, which is useful for searching photos.

### REINFORCEMENT LEARNING

`Reinforcement Learning`: The learning system, called an agent in this context, can observe the environment, select and perform actions, and get rewards in return (or penalties in the form of negative rewards). It must then learn by itself what is the best strategy, called a `policy`, to get the most reward over time. A policy defines what action the agent should choose when it is in a given situation.

ex: many robots implement Reinforcement Learning algorithms to learn how to walk. DeepMind’s AlphaGo program is also a good example of Reinforcement Learning: it made the headlines in May 2017 when it beat the world champion Ke Jie at the game of Go. It learned its winning policy by analyzing millions of games, and then playing many games against itself.

## Batch and Online Learning

The system can learn incrementally from a stream of incoming data.

### BATCH LEARNING

In `batch learning`, the system is incapable of learning incrementally: it must be `trained using all the available data`. This will generally take a lot of time and computing resources, so it is typically done offline. First the system is trained, and then it is launched into production and runs without learning anymore; it just applies what it has learned. This is called `offline learning`.

*NOTE: when we want system to know new data, we need to train new version of system. The training can be automated easy(only update dataset), but training might take many hours and also require resources.*

> if your system needs to be able to learn autonomously and it has limited resources (e.g., a smartphone application or a rover on Mars), then carrying around large amounts of training data and taking up a lot of resources to train for hours every day is a showstopper.

### ONLINE LEARNING

`online learning`: train the system incrementally by `feeding it data instances sequentially`, either `individually` or in small groups called `mini-batches`. Each learning step is fast and cheap, so the system can learn about new data on the fly, as it arrives

Good option for:

- systems that `receive data as a continuous flow` (e.g., stock prices) and need to adapt to change rapidly or autonomously.
- `limited computing resources`: once an online learning system has learned about new data instances, it does not need them anymore, so you can discard them (unless you want to be able to roll back to a previous state and “replay” the data). This can save a huge amount of space.
- train systems on huge datasets that cannot fit in one machine’s main memory (this is called `out-of-core learning`). The algorithm loads part of the data, runs a training step on that data, and repeats the process until it has run on all of the data
  - *NOTE: Out-of-core learning is usually done offline (i.e., not on the live system), so online learning can be a confusing name. Think of it as incremental learning.*

Important parameter:

- `learning rate`: how fast they should adapt to changing data
  - If you set a high learning rate, then your system will rapidly adapt to new data, but it will also tend to quickly forget the old data (you don’t want a spam filter to flag only the latest kinds of spam it was shown).
  - Conversely, if you set a low learning rate, the system will have more inertia; that is, it will learn more slowly, but it will also be less sensitive to noise in the new data or to sequences of nonrepresentative data points (outliers).

*NOTE: A big challenge with online learning is that if bad data is fed to the system, the system’s performance will gradually decline. If it’s a live system, your clients will notice.*

## Instance-Based VS Model-Based Learning

### INSTANCE-BASED LEARNING

`instance-based learning`: the system learns the examples by `heart`, then generalizes to new cases by using a `similarity measure` to compare them to the learned examples (or a subset of them).

### MODEL-BASED LEARNING

`model-based learning`: generalize from `a set of examples` is to build a model of these examples and then use that model to make predictions

Example 1-1. Training and running a `linear model` using Scikit-Learn

```python
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import sklearn.linear_model

# Load the data
oecd_bli = pd.read_csv("oecd_bli_2015.csv", thousands=',')
gdp_per_capita = pd.read_csv("gdp_per_capita.csv",thousands=',',delimiter='\t',
                             encoding='latin1', na_values="n/a")


# Prepare the data
country_stats = prepare_country_stats(oecd_bli, gdp_per_capita)
X = np.c_[country_stats["GDP per capita"]]
y = np.c_[country_stats["Life satisfaction"]]

# Visualize the data
country_stats.plot(kind='scatter', x="GDP per capita", y='Life satisfaction')
plt.show()

# Select a linear model
model = sklearn.linear_model.LinearRegression()

# for use K-nearest neighbor regression:
# import sklearn.neighbors
# model = sklearn.neighbors.KNeighborsRegressor(
#     n_neighbors=3)

# Train the model
model.fit(X, y)

# Make a prediction for Cyprus
X_new = [[22587]]  # Cyprus's GDP per capita
print(model.predict(X_new)) # outputs [[ 5.96242338]]
```

# Main Challenges of Machine Learning

- Insufficient Quantity of Training Data
- Nonrepresentative Training Data
  - if the sample is too small, you will have `sampling noise` (i.e., nonrepresentative data as a result of chance),
  - but even very large samples can be nonrepresentative if the sampling method is flawed. This is called `sampling bias`
- Poor-Quality Data
- Irrelevant Features
  - `feature engineering`, involves the following steps:
    - `Feature selection` (selecting the most useful features to train on among existing features)
    - `Feature extraction` (combining existing features to produce a more useful one⁠—as we saw earlier, dimensionality reduction algorithms can help)
    - Creating new features by gathering new data
- Overfitting the Training Data
  - the model performs well on the training data, but it does not generalize well
  - possible solutions
    - Simplify the model by selecting one with fewer parameters (e.g., a linear model rather than a high-degree polynomial model), by reducing the number of attributes in the training data, or by constraining the model.
    - Gather more training data.
    - Reduce the noise in the training data (e.g., fix data errors and remove outliers).
  - `regularization`
    - Constraining a model to make it simpler and reduce the risk of overfitting
  - `hyperparameter`
    - a parameter of a learning algorithm (not of the model). it is not affected by the learning algorithm itself; it must be set prior to training and remains constant during training.
    - If you set the regularization hyperparameter to a very large value, you will get an almost flat model (a slope close to zero); the learning algorithm will almost certainly not overfit the training data, but it will be less likely to find a good solution
- Underfitting the Training Data
  - occurs when your model is too simple to learn the underlying structure of the data.
  - options to fix the problem
    - Select a more powerful model, with more parameters.
    - Feed better features to the learning algorithm (feature engineering).
    - Reduce the constraints on the model (e.g., reduce the regularization hyperparameter).

# Testing and Validating

Split your data into two sets: the `training set` and the `test set`. As these names imply, you train your model using the training set, and you test it using the test set. The error rate on new cases is called the `generalization error` (or out-of-sample error), and by evaluating your model on the test set, you get an estimate of this error. This value tells you how well your model will perform on instances it has never seen before.

If the training error is low (i.e., your model makes few mistakes on the training set) but the generalization error is high, it means that your model is overfitting the training data.

*Tips: It is common to use `80% of the data for training and hold out 20% for testing`. However, this depends on the size of the dataset: if it contains 10 million instances, then holding out 1% means your test set will contain 100,000 instances, probably more than enough to get a good estimate of the generalization error.*

## Hyperparameter Tuning and Model Selection

Evaluating the model.

how do you choose the value of the regularization hyperparameter? One option is to train 100 different models using 100 different values for this hyperparameter.

**What if perform more errors?**

`holdout validation`: hold out part of the training set to evaluate several candidate models and select the best one. The new held-out set is called the `validation set` (or sometimes the development set, or dev set). More specifically, you train multiple models with various hyperparameters on the reduced training set (i.e., the full training set minus the validation set), and you select the model that performs best on the validation set. After this holdout validation process, you train the best model on the full training set (including the validation set), and this gives you the final model. Lastly, you evaluate this final model on the test set to get an estimate of the generalization error.

**What if validation set is too small or too large?**

`cross-validation`: using many small validation sets. Each model is evaluated once per validation set after it is trained on the rest of the data. By averaging out all the evaluations of a model, you get a much more accurate measure of its performance.

#### Reference

- <https://learning.oreilly.com/library/view/hands-on-machine-learning/9781492032632/ch01.html#landscape_chapter>
