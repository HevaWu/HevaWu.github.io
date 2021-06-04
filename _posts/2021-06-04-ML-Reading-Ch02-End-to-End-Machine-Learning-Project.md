---
layout: post
title: ML Reading Ch02 - End-to-End Machine Learning Project
date: 2021-06-04 15:12:00
comment_id: 159
categories: [ML]
---

One example.

Here are the main steps you will go through:

- Look at the big picture.
- Get the data.
- Discover and visualize the data to gain insights.
- Prepare the data for Machine Learning algorithms.
- Select a model and train it.
- Fine-tune your model.
- Present your solution.
- Launch, monitor, and maintain your system.

# Working with Real Data

Here are a few places you can look to get data:

- Popular open data repositories
  - [UC Irvine Machine Learning Repository](http://archive.ics.uci.edu/ml/)
  - [Kaggle datasets](https://www.kaggle.com/datasets)
  - [Amazon’s AWS datasets](https://registry.opendata.aws/)
- Meta portals (they list open data repositories)
  - [Data Portals](http://dataportals.org/)
  - [OpenDataMonitor](http://opendatamonitor.eu/)
  - [Quandl](http://quandl.com/)
- Other pages listing many popular open data repositories
  - [Wikipedia’s list of Machine Learning datasets](https://homl.info/9)
  - [Quora.com](https://homl.info/10)
  - [The datasets subreddit](https://www.reddit.com/r/datasets)

# Look at the Big Picture

> `data pipeline`: A sequence of data processing components.
>
> Components typically run asynchronously. Each component pulls in a large amount of data, processes it, and spits out the result in another data store. Then, some time later, the next component in the pipeline pulls this data and spits out its own output. Each component is fairly `self-contained`: the interface between components is simply the data store. This makes the system simple to grasp (with the help of a data flow graph), and different teams can focus on different components.
>
> Moreover, if a component breaks down, the downstream components can often continue to run normally (at least for a while) by just using the last output from the broken component. This makes the architecture quite robust.
>
> On the other hand, a broken component can go unnoticed for some time if proper monitoring is not implemented. The data gets stale and the overall system’s performance drops.

- `multiple regression` problem: the system will use multiple features to make a prediction (it will use the district’s population, the median income, etc.)
- `univariate regression` problem: predict a single value for each district
- `multivariate regression` problem: predict multiple values per district,

## Select a Performance Measure

### RMSE

A typical performance measure for regression problems is the `Root Mean Square Error (RMSE)`. It gives an idea of how much error the system typically makes in its predictions, with a higher weight for large errors.

Root Mean Square Error (RMSE):
$$\text{RMSE(X,h)}=\sqrt{\frac{1}{m} \sum_{i=1}^m (h(x^{(i)})−y^{(i)})^2}$$

- `m` is the number of instances in the dataset you are measuring the RMSE on.
- `x(i)` is a vector of all the feature values (excluding the label) of the ith instance in the dataset, and `y(i)` is its label (the desired output value for that instance).
- `X` is a matrix containing all the feature values (excluding labels) of all instances in the dataset. There is one row per instance, and the `ith` row is equal to the `transpose of x(i)`, noted `(x(i))⊺`.
- `h` is your system’s prediction function, also called a `hypothesis`. When your system is given an instance’s feature vector x(i), it outputs a predicted value `ŷ(i) = h(x(i))` for that instance (ŷ is pronounced “y-hat”).
- `RMSE(X,h)` is the cost function measured on the set of examples using your hypothesis h

### MAE

`MAE(mean absolute error)`,  also called the average absolute deviation:
$$\text{MAE(X, h)} = \frac{1}{m} \sum_{i=1}^{m} |h(x^{(i)}) - y^{(i)}|$$

Both the `RMSE` and the `MAE` are ways to `measure the distance between two vectors`: the vector of predictions and the vector of target values. Various distance measures, or norms, are possible:

# Get the data.

## Create a Test Set

`data snooping bias`: When you estimate the generalization error using the test set, your estimate will be too optimistic, and you will launch a system that will not perform as well as expected

# Discover and visualize the data to gain insights.

## Look for correlation

`standard correlation coefficient`
- using the `corr()` method. The correlation coefficient ranges from –1 to 1. When it is close to 1, it means that there is a strong positive correlation.
- using pandas `scatter_matrix()` function

*NOTE: The correlation coefficient only measures linear correlations (“if x goes up, then y generally goes up/down”). It may completely miss out on nonlinear relationships (e.g., “if x is close to 0, then y generally goes up”)*

# Prepare the Data for Machine Learning Algorithms

## Data Cleaning

- Get rid of the corresponding districts.  use `dropna()`
- Get rid of the whole attribute. use `drop()`
- Set the values to some value (zero, the mean, the median, etc.). use `fillna()`

### SCIKIT-LEARN DESIGN

Main design principles:

- Consistency
  - All objects share a consistent and simple interface:
  - Estimators
    - Any object that can estimate some parameters based on a dataset is called an `estimator` (e.g., an imputer is an estimator). The estimation itself is performed by the `fit()` method, and it takes only a dataset as a parameter (or two for supervised learning algorithms; the second dataset contains the labels). Any other parameter needed to guide the estimation process is considered a hyperparameter (such as an imputer’s strategy), and it must be set as an instance variable (generally via a `constructor` parameter).
  - Transformers
    - Some estimators (such as an imputer) can also transform a dataset; these are called `transformers`. Once again, the API is simple: the transformation is performed by the `transform()` method with the dataset to transform as a parameter. It returns the transformed dataset. This transformation generally relies on the learned parameters, as is the case for an imputer. All transformers also have a convenience method called `fit_transform()` that is equivalent to calling fit() and then `transform()` (but sometimes `fit_transform()` is optimized and runs much faster).
  - Predictors
    - Finally, some estimators, given a dataset, are capable of making predictions; they are called `predictors`. A predictor has a `predict()` method that takes a dataset of new instances and returns a dataset of corresponding predictions. It also has a `score()` method that measures the quality of the predictions, given a test set (and the corresponding labels, in the case of supervised learning algorithms).
- Inspection
  - All the estimator’s hyperparameters are accessible directly via public instance variables (e.g., `imputer.strategy`), and all the estimator’s learned parameters are accessible via public instance variables with an underscore suffix (e.g., `imputer.statistics_`).
- Nonproliferation of classes
  - Datasets are represented as `NumPy arrays` or `SciPy sparse matrices`, instead of homemade classes. Hyperparameters are just regular Python strings or numbers.
- Composition
  - Existing building blocks are reused as much as possible. For example, it is easy to create a Pipeline estimator from an arbitrary sequence of transformers followed by a final estimator, as we will see.
- Sensible defaults
  - Scikit-Learn provides reasonable default values for most parameters, making it easy to quickly create a baseline working system.

## Handling Text and Categorical Attributes

`one-hot encoding`: only one attribute will be equal to 1 (hot), while the others will be 0 (cold).

*Tips: If a categorical attribute has a large number of possible categories (e.g., country code, profession, species), then one-hot encoding will result in a large number of input features. This may slow down training and degrade performance. If this happens, you may want to replace the categorical input with useful numerical features related to the categories. Alternatively, you could replace each category with a learnable, low-dimensional vector called an `embedding`. Each category’s representation would be learned during training.*

## Custom Transformers

You will want your transformer to work seamlessly with Scikit-Learn functionalities (such as pipelines), and since Scikit-Learn relies on duck typing (not inheritance), all you need to do is create a class and implement three methods: `fit()` (returning self), `transform()`, and `fit_transform()`.

You can get the last one for free by simply adding `TransformerMixin` as a base class. If you add `BaseEstimator` as a base class (and avoid `*args` and `**kargs` in your constructor), you will also get two extra methods (`get_params()` and `set_params()`) that will be useful for automatic hyperparameter tuning.

## Feature Scaling

There are two common ways to get all attributes to have the same scale: `min-max scaling` and `standardization`

- `Min-max scaling` (many people call this `normalization`) is the simplest: values are shifted and rescaled so that they end up ranging from 0 to 1. We do this by subtracting the min value and dividing by the max minus the min. Scikit-Learn provides a transformer called `MinMaxScaler` for this. It has a `feature_range` hyperparameter that lets you change the range if, for some reason, you don’t want 0–1.
- `Standardization` is different: first it subtracts the mean value (so standardized values always have a zero mean), and then it divides by the standard deviation so that the resulting distribution has unit variance. Unlike min-max scaling, standardization does not bound values to a specific range, which may be a problem for some algorithms (e.g., neural networks often expect an input value ranging from 0 to 1). However, standardization is much less affected by outliers. Scikit-Learn provides a transformer called `StandardScaler` for standardization.

*NOTE: As with all the transformations, it is important to fit the scalers to the training data only, not to the full dataset (including the test set). Only then can you use them to transform the training set and the test set (and new data).*

## Transformation Pipelines

Many data transformation steps that need to be executed in the right order. Fortunately, Scikit-Learn provides the `Pipeline` class to help with such sequences of transformations

# Select a model and train it.

*TIPS: You should save every model you experiment with so that you can come back easily to any model you want. Make sure you save both the hyperparameters and the trained parameters, as well as the cross-validation scores and perhaps the actual predictions as well. This will allow you to easily compare scores across model types, and compare the types of errors they make. You can easily save Scikit-Learn models by using Python’s pickle module or by using the joblib library, which is more efficient at serializing large NumPy arrays*

# Fine-tune your model.

## Grid Search

One option would be to fiddle with the hyperparameters manually, until you find a great combination of hyperparameter values. Instead, you should get `Scikit-Learn’s GridSearchCV` to search for you

*TIPS: When you have no idea what value a hyperparameter should have, a simple approach is to try out consecutive powers of 10 (or a smaller number if you want a more fine-grained search*

## Randomized Search

When the hyperparameter search space is large, it is often preferable to use `RandomizedSearchCV` instead. This class can be used in much the same way as the GridSearchCV class, but instead of trying out all possible combinations, it evaluates a given number of random combinations by selecting a random value for each hyperparameter at every iteration. This approach has two main benefits:

- If you let the randomized search run for, say, 1,000 iterations, this approach will explore 1,000 different values for each hyperparameter (instead of just a few values per hyperparameter with the grid search approach).
- Simply by setting the number of iterations, you have more control over the computing budget you want to allocate to hyperparameter search.

## Ensemble Methods

Try to combine the models that perform best. The group (or “ensemble”) will often perform better than the best individual model (just like Random Forests perform better than the individual Decision Trees they rely on), especially if the individual models make very different types of errors.

# Launch, monitor, and maintain your system

- One way to do this is to `save` the trained Scikit-Learn model (e.g., using joblib), including the full preprocessing and prediction pipeline, then load this trained model within your production environment and use it to make predictions by calling its `predict()` method.
- Alternatively, you can wrap the model within a dedicated web service that your `web application` can query through a REST API.
  - This makes it easier to upgrade your model to new versions without interrupting the main application. It also simplifies scaling, since you can start as many web services as needed and load-balance the requests coming from your web application across these web services. Moreover, it allows your web application to use any language, not just Python.
- deploy your model on the `cloud`, for example on Google Cloud AI Platform (formerly known as Google Cloud ML Engine): just save your model using joblib and upload it to Google Cloud Storage (GCS), then head over to Google Cloud AI Platform and create a new model version, pointing it to the GCS file.
  - This gives you a simple web service that takes care of load balancing and scaling for you. It takes JSON requests containing the input data (e.g., of a district) and returns JSON responses containing the predictions. You can then use this web service in your website (or whatever production environment you are using).

Something we might have to do:

- monitor your model’s live performance
  - In some cases, the model’s performance can be inferred from downstream metrics.
  - monitoring system (with or without human raters to evaluate the live model), as well as all the relevant processes to define what to do in case of failures and how to prepare for them.
- data refreshing
  - If the data keeps evolving, you will need to update your datasets and retrain your model regularly. You should probably automate the whole process as much as possible. Here are a few things you can automate:
    - Collect fresh data regularly and label it (e.g., using human raters).
    - Write a script to train the model and fine-tune the hyperparameters automatically. This script could run automatically, for example every day or every week, depending on your needs.
    - Write another script that will evaluate both the new model and the previous model on the updated test set, and deploy the model to production if the performance has not decreased (if it did, make sure you investigate why).
- evaluate the model’s input data quality
  - Sometimes performance will degrade slightly because of a poor-quality signal (e.g., a malfunctioning sensor sending random values, or another team’s output becoming stale), but it may take a while before your system’s performance degrades enough to trigger an alert. If you monitor your model’s inputs, you may catch this earlier.
- keep backups of every model you create and have the process and tools in place to roll back to a previous model quickly

#### Reference

- <https://learning.oreilly.com/library/view/hands-on-machine-learning/9781492032632/ch02.html#project_chapter>
- <https://github.com/HevaWu/handson-ml2/blob/master/02_end_to_end_machine_learning_project.ipynb>
