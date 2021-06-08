---
layout: post
title: ML Reading Ch03 - Classification
date: 2021-06-08 21:06:00
comment_id: 161
categories: [ML]
---

Classify by using MNIST dataset, which is a set of 70,000 small images of handwritten digits. Each image is labeled with the digit it represents.

# Training a Binary Classifier

`Stochastic Gradient Descent (SGD) classifier`

> This classifier has the advantage of being capable of handling very large datasets efficiently. This is in part because SGD deals with training instances independently, one at a time (which also makes SGD well suited for online learning)

*Tips: The SGDClassifier relies on randomness during training (hence the name “stochastic”). If you want reproducible results, you should set the random_state parameter.*

# Performance Measures

## Measuring accuracy by using `cross validation`

Use the `cross_val_score()` function to evaluate our SGDClassifier model, using K-fold cross-validation with three folds. **Remember that K-fold cross-validation means splitting the training set into K folds** (in this case, three), then making predictions and evaluating them on each fold using a model trained on the remaining folds.

*NOTE: Accuracy is generally not the preferred performance measure for classifiers, especially when you are dealing with skewed datasets.*

## Confusion Matrix

A much better way to evaluate the performance of a classifier is the `confusion matrix`. The general idea is to **count the number of times instances of class A are classified as class B**. For example, to know the number of times the classifier confused images of 5s with 3s, you would look in the fifth row and third column of the confusion matrix.

- `precision of the classifier:` only look at accuracy of positive predictions, `TP` is the number of true positives, and `FP` is the number of false positives.
$$
\text{precision}=\frac{TP}{TP+FP}
$$
- `recall` OR `sensitivity` OR `true positive rate (TPR)`: this is the ratio of positive instances that are correctly detected by the classifier: `FN` is the number of false negatives
$$
\text{recall}=\frac{TP}{TP+FN}
$$

## Precision and Recall

`F1 score` is the harmonic mean of precision and recall. Whereas the regular mean treats all values equally, the harmonic mean gives much more weight to low values. As a result, the classifier will only get a high F1 score if both recall and precision are high.

$$
F_{1} = \frac{2}{\frac{1}{precision}+\frac{1}{recall}} = 2 * \frac{precision * recall}{precision + recall} = \frac{TP}{TP + \frac{FN+FP}{2}}
$$

**increasing precision reduces recall, and vice versa. This is called the precision/recall trade-off.**

## Precision/Recall Trade-off

For each instance, it computes a score based on a `decision function`. If that score is greater than a threshold, it assigns the instance to the positive class; otherwise it assigns it to the negative class.

### How do you decide which threshold to use?

- First, use the `cross_val_predict()` function to get the scores of all instances in the training set, but this time specify that you want to return decision scores instead of predictions.
- With these scores, use the `precision_recall_curve()` function to compute precision and recall for all possible thresholds.
- Finally, use `Matplotlib` to plot precision and recall as functions of the threshold value

Another way to select a good precision/recall trade-off is to `plot precision directly against recall`.

*TIPS: If someone says, “Let’s reach 99% precision,” you should ask, “At what recall?”*

## The ROC Curve

The `receiver operating characteristic (ROC) curve`. Instead of plotting precision versus recall, the ROC curve `plots the true positive rate (another name for recall) against the false positive rate (FPR)`. The `FPR` is the ratio of negative instances that are incorrectly classified as positive. It is equal to 1 – the true negative rate (`TNR`), which is the ratio of negative instances that are correctly classified as negative. The `TNR` is also called specificity. Hence, the ROC curve plots sensitivity (recall) versus 1 – specificity.

*NOTE: the higher the recall (TPR), the more false positives (FPR) the classifier produces. The dotted line represents the ROC curve of a purely random classifier; a good classifier stays as far away from that line as possible (toward the top-left corner).*

One way to compare classifiers is to `measure` `the area under the curve (AUC)`. A perfect classifier will have a ROC AUC equal to 1, whereas a purely random classifier will have a ROC AUC equal to 0.5.

*Tips: prefer the precision/recall (PR) curve whenever the positive class is rare or when you care more about the false positives than the false negatives. Otherwise, use the ROC curve.*

# Multiclass Classification

`Multiclass classifiers` (also called `multinomial classifiers`) can distinguish between more than two classes.

- One way to create a system that can classify the digit images into 10 classes (from 0 to 9) is to train 10 binary classifiers, one for each digit (a 0-detector, a 1-detector, a 2-detector, and so on). Then when you want to classify an image, you get the decision score from each classifier for that image and you select the class whose classifier outputs the highest score. This is called the `one-versus-the-rest (OvR) strategy` (also called `one-versus-all`).
- Another strategy is to train a binary classifier for every pair of digits: one to distinguish 0s and 1s, another to distinguish 0s and 2s, another for 1s and 2s, and so on. This is called the `one-versus-one (OvO)` strategy. If there are N classes, you need to train N × (N – 1) / 2 classifiers. For the MNIST problem, this means training 45 binary classifiers! When you want to classify an image, you have to run the image through all 45 classifiers and see which class wins the most duels. The main `advantage` of OvO is that `each classifier only needs to be trained on the part of the training set for the two classes that it must distinguish`.

*Some algorithms (such as Support Vector Machine classifiers) scale poorly with the size of the training set. For these algorithms OvO is preferred because it is faster to train many classifiers on small training sets than to train few classifiers on large training sets. For most binary classification algorithms, however, OvR is preferred.*

*Warning: When a classifier is trained, it stores the list of target classes in its classes_ attribute, ordered by value.*

# Error Analysis

- First, look at the confusion matrix.
- Divide each value in the confusion matrix by the number of images in the corresponding class so that you can compare error rates instead of absolute numbers of errors

Analyzing the confusion matrix often gives you insights into ways to improve your classifier.

# Multilabel Classification

`Multilabel classification system`: a classification system that outputs multiple binary tags.

## How to evaluate a multilabel classifier

- One approach is to `measure the F1 score` for each individual label (or any other binary classifier metric discussed earlier), then simply compute the average score.
- One simple option is to `give each label a weight equal to its support` (i.e., the number of instances with that target label). To do this, simply set average="weighted" in the preceding code

# Multioutput Classification

`Multioutput–multiclass classification` (or simply `multioutput classification`): a generalization of multilabel classification where each label can be multiclass.

*NOTE: The line between classification and regression is sometimes blurry, such as in this example. Arguably, predicting pixel intensity is more akin to regression than to classification. Moreover, multioutput systems are not limited to classification tasks; you could even have a system that outputs multiple labels per instance, including both class labels and value labels.*

#### Reference

- <https://learning.oreilly.com/library/view/hands-on-machine-learning/9781492032632/ch03.html#classification_chapter>
- https://github.com/HevaWu/handson-ml2/blob/master/03_classification.ipynb
