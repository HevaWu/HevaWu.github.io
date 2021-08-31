---
layout: post
title: Ch07 - Ensemble Learning and Random Forests
date: 2021-08-31 21:34:00
comment_id: 191
categories: [ML]
---

- `ensemble`: A group of predictors
- `Random Forest`: ensemble of Decision Trees. obtain the predictions of all the individual trees, then predict the class that gets the most votes

# Voting Classifiers

`hard voting classifier`: aggregate the predictions of each classifier and predict the class that gets the most votes.

*TIP: `Ensemble methods work best when the predictors are as independent from one another as possible`. One way to get diverse classifiers is to train them using very different algorithms. This increases the chance that they will make very different types of errors, improving the ensemble’s accuracy.*

`soft voting`: If all classifiers are able to estimate class probabilities, then you can tell Scikit-Learn to predict the class with the highest class probability, averaged over all the individual classifiers.

`soft voting` often achieves `higher performance` than `hard voting` because it gives more weight to highly confident votes.

# Bagging and Pasting

Another approach is to use the same training algorithm for every predictor and train them on different random subsets of the training set.

- When sampling is performed `with replacement`, this method is called `bagging`
- When sampling is performed `without replacement`, it is called `pasting`.

## Bagging and Pasting in Scikit-Learn

Scikit-Learn offers a simple API for both bagging and pasting with the `BaggingClassifier` class (or `BaggingRegressor` for regression).

*NOTE: The BaggingClassifier `automatically performs soft voting` instead of hard voting if the `base classifier can estimate` class probabilities*

## Out-of-Bag Evaluation

With bagging, some instances may be sampled several times for any given predictor, while others may not be sampled at all. By default a BaggingClassifier samples `m training instances` with replacement (`bootstrap=True`), where m is the size of the training set.

`out-of-bag(oob) instances`: instances that are not sampled

In Scikit-Learn, you can set `oob_score=True` when creating a `BaggingClassifier` to request an automatic oob evaluation after training. The resulting evaluation score is available through the `oob_score_ variable`. The oob decision function for each training instance is also available through the `oob_decision_function_` variable.

# Random Patches and Random Subspaces

The BaggingClassifier class supports sampling the features as well.

- `max_features` and `bootstrap_features`: for feature sampling
- `max_samples` and `bootstrap`: for instance sampling

`Random Patches method`: Sampling both training instances and features.

`Random Subspaces method`: Keeping all training instances (by setting `bootstrap=False` and `max_samples=1.0`) but sampling features (by setting `bootstrap_features to True` and/or `max_features to a value smaller than 1.0`)

# Random Forests

`Random Forest` is an ensemble of Decision Trees.generally trained via the `bagging` method (or sometimes pasting), typically with `max_samples set to the size of the training set`. Use `RandomForestClassifier` for classification task, use `RandomForestRegressor` for regression tasks.

The Random Forest algorithm introduces extra randomness when growing trees, it searches for the best feature among a random subset of features.

## Extra-Trees

`Extremely Randomized Trees ensemble` (or `Extra-Trees`): using random thresholds for each feature. Use `ExtraTreesClassifier` for classification task, use `ExtraTreesRegressor` for regression tasks.

## Feature Importance

Scikit-Learn `measures a feature’s importance` by looking at `how much the tree nodes that use that feature reduce impurity on average` (across all trees in the forest). More precisely, it is a weighted average, where each node’s weight is equal to the number of training samples that are associated with it. We can access result using `feature_importances_` variable.

# Boosting

`Boosting`: any Ensemble method that can combine several weak learners into a strong learner.

## AdaBoost

`AdaBoost` for `Adaptive Boosting`. pay a bit more attention to the training instances that the predecessor underfitted.

When training an AdaBoost classifier, the algorithm first trains a base classifier (such as a Decision Tree) and uses it to make predictions on the training set. The algorithm then increases the relative weight of misclassified training instances. Then it trains a second classifier, using the updated weights, and again makes predictions on the training set, updates the instance weights, and so on. This

*WARN: it `cannot be parallelized` (or only partially), since each predictor can only be trained after the previous predictor has been trained and evaluated. As a result, it `does not scale as well as bagging or pasting`.*

Scikit-Learn uses a multiclass version of AdaBoost called `SAMME` (which stands for `Stagewise Additive Modeling using a Multiclass Exponential loss function`). When there are just two classes, SAMME is equivalent to AdaBoost. If the predictors can estimate class probabilities (i.e., if they have a `predict_proba()` method), Scikit-Learn can use a variant of SAMME called `SAMME.R` (the R stands for “Real”), which relies on class probabilities rather than predictions and generally performs better.

## Gradient Boosting

`Gradient Boosting`: works by sequentially adding predictors to an ensemble, each one correcting its predecessor. Tries to fit the new predictor to the residual errors made by the previous predictor.

A simpler way to train GBRT ensembles is to use Scikit-Learn’s `GradientBoostingRegressor` class.

The `learning_rate` hyperparameter scales the contribution of each tree. If you set it to a low value, such as 0.1, you will need more trees in the ensemble to fit the training set, but the predictions will usually generalize better. This is a regularization technique called `shrinkage`.

In order to find the optimal number of trees, you can use `early stopping`. A simple way to implement this is to use the `staged_predict()` method: it returns an iterator over the predictions made by the ensemble at each stage of training (with one tree, two trees, etc.).

It is also possible to implement early stopping by actually stopping training early (instead of training a large number of trees first and then looking back to find the optimal number). By setting `warm_start=True`.

`Stochastic Gradient Boosting`: The `GradientBoostingRegressor` class also supports a `subsample` hyperparameter, which specifies the fraction of training instances to be used for training each tree.

# Stacking

`Stacking`(`stacked generalization`): train a model to perform the aggregation of all predictors in an ensemble

`blender`(or `meta learner`): the final predictor of stacking.

To train the blender, a common approach is to use a `hold-out set`.

- First, the training set is split into two subsets. The first subset is used to train the predictors in the first layer.
- Next, the first layer’s predictors are used to make predictions on the second (held-out) set.For each instance in the hold-out set, there are three predicted values. We can create a new training set using these predicted values as input features (which makes this new training set 3D), and keeping the target values. The blender is trained on this new training set, so it learns to predict the target value, given the first layer’s predictions.

The trick is to `split the training set into three subsets`:

- the first one is used to train the first layer
- the second one is used to create the training set used to train the second layer (using predictions made by the predictors of the first layer)
- the third one is used to create the training set to train the third layer (using predictions made by the predictors of the second layer).

Once this is done, we can make a prediction for a new instance by going through each layer sequentially.

#### References

- https://learning.oreilly.com/library/view/hands-on-machine-learning/9781492032632/ch07.html
