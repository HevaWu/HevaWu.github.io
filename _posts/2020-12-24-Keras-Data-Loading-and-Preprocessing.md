---
layout: post
title: Keras Data Loading and Preprocessing
date: 2020-12-24 14:46:00
comment_id: 121
categories: [Python, Keras]
tags: [Data, Preprocess]
---

Recently I'd like to try to train some customize module. And I found this tools -> Keras. It seems running based on TensorFlow, but it can help generating deep learning tools quickly with the high-productive interface. I'd like to memo something I learned at here.

# Data loading & preprocessing

> Neural networks don't process raw data, like text files, encoded JPEG image files, or CSV files. They process vectorized & standardized representations.

- Text files: read into string tensors, then split into words. The words need to be indexed & turned into integer tensors
- Images: read and decoded into integer tensors, then converted to floating point and normalized to small values(usually between 0 and 1)
- CSV data: parsed, with numerical features converted to floating point tensors and categorical features indexed and converted into integer tensors. Then each feature typically needs to be normalized to zero-mean and unit-variance

## Data loading

Keras models accept three types of inputs:

- NumPy arrays: good option if the data fits in memory
- TensorFlow Dataset objects: high-performance option, more suitable for dataset that do not fit in memory and that are streamed from disk or from a distributed filesystem
- Python generators: yield batches of data(such as custom subclasses of the keras.utils.Sequence class)

If it is a large dataset and you training on GPU(s), consider using `Dataset` objects since they will take care of performance-critical details, such as:

- Asynchronously preprocessing your data on CPU while your GPU is busy, and buffering it into a queue.
- Prefetching data on GPU memory so it's immediately available when the GPU has finished processing the previous batch, so you can reach full GPU utilization.

### Keras utilities turn raw data into `Dataset`

```python
# turn image files sorted into class-specific folders into a labeled dataset of image tensors
tf.keras.preprocessing.image_dataset_from_directory

# turn text files sorted into class-specific folders into a labeled dataset of image tensors
tf.keras.preprocessing.text_dataset_from_directory

# load structured data from CSV files
tf.data.experimental.make_csv_dataset
```

### Example

```python
# Obtaining a labeled dataset from image files on disk

# main_directory/
# ...class_a/
# ......a_image_1.jpg
# ......a_image_2.jpg
# ...class_b/
# ......b_image_1.jpg
# ......b_image_2.jpg

# Create a dataset.
dataset = keras.preprocessing.image_dataset_from_directory(
  'path/to/main_directory', batch_size=64, image_size=(200, 200))

# For demonstration, iterate over the batches yielded by the dataset.
for data, labels in dataset:
   print(data.shape)  # (64, 200, 200, 3)
   print(data.dtype)  # float32
   print(labels.shape)  # (64,)
   print(labels.dtype)  # int32

# The label of a sample is the rank of its folder in alphanumeric order. Naturally, 
# this can also be configured explicitly by passing, e.g. class_names=['class_a', 
# 'class_b'], in which cases label 0 will be class_a and 1 will be class_b.

# Obtaining a labeled dataset from "text files" on disk

dataset = keras.preprocessing.text_dataset_from_directory(
  'path/to/main_directory', batch_size=64)

# For demonstration, iterate over the batches yielded by the dataset.
for data, labels in dataset:
   print(data.shape)  # (64,)
   print(data.dtype)  # string
   print(labels.shape)  # (64,)
   print(labels.dtype)  # int32
```

## Data preprocessing

- Tokenization of string data, followed by token indexing.
- Feature normalization.
- Rescaling the data to small values (in general, input values to a neural network should be close to zero -- typically we expect either data with zero-mean and unit-variance, or data in the [0, 1] range.

> The ideal model should expect as input something as close as possible to raw data: an image model should expect RGB pixel values in the `[0, 255]` range, and a text model should accept strings of `utf-8` characters.

Keras can do in-model data preprocessing via preprocessing layers:

- Vectorizing raw strings of text via the `TextVectorization` layer
  - `TextVectorization` holds an index mapping words or tokens to integer indices
- Feature normalization via the `Normalization` layer
  - `Normalization` holds the mean and variance of your features
- Image rescaling, cropping, or image data augmentation

### Example

**Turning strings into sequences of integer word indices**

```python
from tensorflow.keras.layers.experimental.preprocessing import TextVectorization

# Example training data, of dtype `string`.
training_data = np.array([["This is the 1st sample."], ["And here's the 2nd sample."]])

# Create a TextVectorization layer instance. It can be configured to either
# return integer token indices, or a dense token representation (e.g. multi-hot
# or TF-IDF). The text standardization and text splitting algorithms are fully
# configurable.
vectorizer = TextVectorization(output_mode="int")

# Calling `adapt` on an array or dataset makes the layer generate a vocabulary
# index for the data, which can then be reused when seeing new data.
vectorizer.adapt(training_data)

# After calling adapt, the layer is able to encode any n-gram it has seen before
# in the `adapt()` data. Unknown n-grams are encoded via an "out-of-vocabulary"
# token.
integer_data = vectorizer(training_data)
print(integer_data)
# tf.Tensor(
# [[4 5 2 9 3]
#  [7 6 2 8 3]], shape=(2, 5), dtype=int64)
```

**Turning strings into sequences of one-hot encoded bigrams**

```python
from tensorflow.keras.layers.experimental.preprocessing import TextVectorization

# Example training data, of dtype `string`.
training_data = np.array([["This is the 1st sample."], ["And here's the 2nd sample."]])

# Create a TextVectorization layer instance. It can be configured to either
# return integer token indices, or a dense token representation (e.g. multi-hot
# or TF-IDF). The text standardization and text splitting algorithms are fully
# configurable.
vectorizer = TextVectorization(output_mode="binary", ngrams=2)

# Calling `adapt` on an array or dataset makes the layer generate a vocabulary
# index for the data, which can then be reused when seeing new data.
vectorizer.adapt(training_data)

# After calling adapt, the layer is able to encode any n-gram it has seen before
# in the `adapt()` data. Unknown n-grams are encoded via an "out-of-vocabulary"
# token.
integer_data = vectorizer(training_data)
print(integer_data)
# tf.Tensor(
# [[0. 1. 1. 1. 1. 0. 1. 1. 1. 0. 0. 0. 0. 0. 0. 1. 1.]
#  [0. 1. 1. 0. 0. 1. 0. 0. 0. 1. 1. 1. 1. 1. 1. 0. 0.]], shape=(2, 17), dtype=float32)
```

**normalizing features**

```python
from tensorflow.keras.layers.experimental.preprocessing import Normalization

# Example image data, with values in the [0, 255] range
training_data = np.random.randint(0, 256, size=(64, 200, 200, 3)).astype("float32")

normalizer = Normalization(axis=-1)
normalizer.adapt(training_data)

normalized_data = normalizer(training_data)
print("var: %.4f" % np.var(normalized_data))
print("mean: %.4f" % np.mean(normalized_data))
# var: 1.0000
# mean: -0.0000
```

**rescaling & center-cropping images**

Both the Rescaling layer and the CenterCrop layer are stateless, so it isn't necessary to call adapt() in this case.

```python
from tensorflow.keras.layers.experimental.preprocessing import CenterCrop
from tensorflow.keras.layers.experimental.preprocessing import Rescaling

# Example image data, with values in the [0, 255] range
training_data = np.random.randint(0, 256, size=(64, 200, 200, 3)).astype("float32")

cropper = CenterCrop(height=150, width=150)
scaler = Rescaling(scale=1.0 / 255)

output_data = scaler(cropper(training_data))
print("shape:", output_data.shape)
print("min:", np.min(output_data))
print("max:", np.max(output_data))
# shape: (64, 150, 150, 3)
# min: 0.0
# max: 1.0
```

#### Reference

- <https://keras.io/about/>
- <https://keras.io/getting_started/intro_to_keras_for_engineers/>
