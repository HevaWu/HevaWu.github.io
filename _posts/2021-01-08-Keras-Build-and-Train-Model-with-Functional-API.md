---
layout: post
title: Keras Build and Train Model with Functional API
date: 2021-01-08 23:05:00
comment_id: 125
categories: [Python, Keras]
tags: [Model, Layer, Train]
---

- A "layer" is a simple input-output transformation (such as the scaling & center-cropping transformations above).
- A "model" is a directed acyclic graph of layers. You can think of a model as a "bigger layer" that encompasses multiple sublayers and that can be trained via exposure to data.

# Build Model

## Input

At first, we need to specify the shape of the inputs. If any dimension of the input can vary, we can specify it as `None`.

```python
# input for 200*200 rgb image
inputs = keras.Input(shape=(200, 200, 3))

# Let's say we expect our inputs to be RGB images of arbitrary size
inputs = keras.Input(shape=(None, None, 3))
```

## Layer

After define inputs, chain layer transformations on top of the inputs, until final output:

```python
from tensorflow.keras import layers

# Center-crop images to 150x150
x = CenterCrop(height=150, width=150)(inputs)
# Rescale images to [0, 1]
x = Rescaling(scale=1.0 / 255)(x)

# Apply some convolution and pooling layers
x = layers.Conv2D(filters=32, kernel_size=(3, 3), activation="relu")(x)
x = layers.MaxPooling2D(pool_size=(3, 3))(x)
x = layers.Conv2D(filters=32, kernel_size=(3, 3), activation="relu")(x)
x = layers.MaxPooling2D(pool_size=(3, 3))(x)
x = layers.Conv2D(filters=32, kernel_size=(3, 3), activation="relu")(x)

# Apply global average pooling to get flat feature vectors
x = layers.GlobalAveragePooling2D()(x)

# Add a dense classifier on top
num_classes = 10
outputs = layers.Dense(num_classes, activation="softmax")(x)
```

## Model

Once defined the directed acyclic graph of layers that turns inputs into outputs, we can init the `Model` object:

```python
model = keras.Model(inputs=inputs, outputs=outputs)

# call model on batches of data
data = np.random.randint(0, 256, size=(64,200,200,3).astype("float32"))
processed_data = model(data)
print(process_data.shape)
# (64, 10)

# print summary of how data get transformed at each stage of model
# the output shape displayed for each layer includes the batch size, When batch size is None, it indicates our model can process batches of any size
model.summary()

# Model: "model"
# _________________________________________________________________
# Layer (type)                 Output Shape              Param #   
# =================================================================
# input_1 (InputLayer)         [(None, None, None, 3)]   0         
# _________________________________________________________________
# center_crop_1 (CenterCrop)   (None, 150, 150, 3)       0         
# _________________________________________________________________
# rescaling_1 (Rescaling)      (None, 150, 150, 3)       0         
# _________________________________________________________________
# conv2d (Conv2D)              (None, 148, 148, 32)      896       
# _________________________________________________________________
# max_pooling2d (MaxPooling2D) (None, 49, 49, 32)        0         
# _________________________________________________________________
# conv2d_1 (Conv2D)            (None, 47, 47, 32)        9248      
# _________________________________________________________________
# max_pooling2d_1 (MaxPooling2 (None, 15, 15, 32)        0         
# _________________________________________________________________
# conv2d_2 (Conv2D)            (None, 13, 13, 32)        9248      
# _________________________________________________________________
# global_average_pooling2d (Gl (None, 32)                0         
# _________________________________________________________________
# dense (Dense)                (None, 10)                330       
# =================================================================
# Total params: 19,722
# Trainable params: 19,722
# Non-trainable params: 0
# _________________________________________________________________
```

# Train Model

## optimizer and loss

Before call `fit()`, we need to specify optimizer and a loss function by using `compile()`:

```python
model.compile(optimizer=keras.optimizers.RMSprop(learning_rate=1e-3),
              loss=keras.losses.CategoricalCrossentropy())

# loss and optimizer can be specified via string identifiers(in this case, the default constructor argument values are used)
model.compile(optimizer='rmsprop', loss='categorical_crossentropy')
```

## fit the model

Besides data, we have to specify 2 key parameters:

- `batch_size`: get sliced with batches of samples
- `epochs`: iterate times over the data during training

```python
# example that fitting a model with NumPy data
model.fit(numpy_array_of_samples, numpy_array_of_labels,
          batch_size=32, epochs=10)
```

# Example

Learn to classify MNIST digits:

```python
# Get the data as Numpy arrays
(x_train, y_train), (x_test, y_test) = keras.datasets.mnist.load_data()

# Build a simple model
inputs = keras.Input(shape=(28, 28))
x = layers.experimental.preprocessing.Rescaling(1.0 / 255)(inputs)
x = layers.Flatten()(x)
x = layers.Dense(128, activation="relu")(x)
x = layers.Dense(128, activation="relu")(x)
outputs = layers.Dense(10, activation="softmax")(x)
model = keras.Model(inputs, outputs)
model.summary()

# Compile the model
model.compile(optimizer="adam", loss="sparse_categorical_crossentropy")

# Train the model for 1 epoch from Numpy data
batch_size = 64
print("Fit on NumPy data")
history = model.fit(x_train, y_train, batch_size=batch_size, epochs=1)

# Train the model for 1 epoch using a dataset
dataset = tf.data.Dataset.from_tensor_slices((x_train, y_train)).batch(batch_size)
print("Fit on Dataset")
history = model.fit(dataset, epochs=1)

# .history dict contains per-epoch timeseries of metrics values(here we have only one metric, the loss, and one epoch, so we only get a single scalar)
print(history.history)
# {'loss': [0.11384169012308121]}
```

# Others

## Keep track of performance metrics

If we want to keep track of metrics such as: classification accuracy, precision, recall, AUC, etc. Also, we want to monitor these metrics not only on the training data, but also on a validation set.

### Monitoring metrics

Pass a list of metric objects to `compile()`:

```python
model.compile(
    optimizer="adam",
    loss="sparse_categorical_crossentropy",
    metrics=[keras.metrics.SparseCategoricalAccuracy(name="acc")],
)
history = model.fit(dataset, epochs=1)
```

### Passing validation data to fit()

Pass validation data to `fit()` to monitor the validation loss & validation metrics. Validation metrics get reported at the end of each epoch:

```python
val_dataset = tf.data.Dataset.from_tensor_slices((x_test, y_test)).batch(batch_size)
history = model.fit(dataset, epochs=1, validation_data=val_dataset)
```

## Use callbacks for checkpointing (and more)

If training goes on for more than few minutes, better to save the model at regular intervals during training. In the later, we can use the saved models to restart training in case the training process crashes.

```python
# use `callbacks` to periodically save the model
callbacks = [
    keras.callbacks.ModelCheckpoint(
        filepath='path/to/my/model_{epoch}',
        save_freq='epoch')
]
model.fit(dataset, epochs=2, callbacks=callbacks)
```

## Monitoring training progress with TensorBoard

`TensorBoard` can display realtime graphs of the metrics and more.

```python
callbacks = [
    keras.callbacks.TensorBoard(log_dir='./logs')
]
model.fit(dataset, epochs=2, callbacks=callbacks)

# launch a TensorBoard instance that can open in the browser to monitor the logs getting written to the location:
from tensorboard import notebook
notebook.list() # View open TensorBoard instances
# Control TensorBoard display. If no port is provided, 
# the most recently launched TensorBoard is used
notebook.display(port=6006, height=1000)
```

## Evaluate test performance & generate predictions on new data

```python
# via evaluate()
loss, acc = model.evaluate(val_dataset)  # returns loss and metrics
print("loss: %.2f" % loss)
print("acc: %.2f" % acc)
# 157/157 [==============================] - 0s 688us/step - loss: 0.1041 - acc: 0.9692
# loss: 0.10
# acc: 0.97

# via predict()
predictions = model.predict(val_dataset)
print(predictions.shape)
# (10000, 10)
```

## Custom training with fit()

By default, `fit()` is configured for supervised learning. We can also provide own implementation of the `Model.train_step()` for different training loop.

```python
# example that reimplements what fit() normally does:
class CustomModel(keras.Model):
  def train_step(self, data):
    # Unpack the data. Its structure depends on your model and
    # on what you pass to `fit()`.
    x, y = data
    with tf.GradientTape() as tape:
      y_pred = self(x, training=True)  # Forward pass
      # Compute the loss value
      # (the loss function is configured in `compile()`)
      loss = self.compiled_loss(y, y_pred,
                                regularization_losses=self.losses)
    # Compute gradients
    trainable_vars = self.trainable_variables
    gradients = tape.gradient(loss, trainable_vars)
    # Update weights
    self.optimizer.apply_gradients(zip(gradients, trainable_vars))
    # Update metrics (includes the metric that tracks the loss)
    self.compiled_metrics.update_state(y, y_pred)
    # Return a dict mapping metric names to current value
    return {m.name: m.result() for m in self.metrics}

# Construct and compile an instance of CustomModel
inputs = keras.Input(shape=(32,))
outputs = keras.layers.Dense(1)(inputs)
model = CustomModel(inputs, outputs)
model.compile(optimizer='adam', loss='mse', metrics=[...])

# Just use `fit` as usual
model.fit(dataset, epochs=3, callbacks=...)
```

## Debug model with eager execution

For custom training steps or custom layers, we need to debug them. By default, Keras models are compiled to highly-optimized computation graphs that deliver fast execution times.
=> That means the Python code we write is not the code actually executing. And this introduces a layer of indirection that make debugging hard.

We might want to print each statement to see what the data looks like after each operation. This can be achieved by running model eagerly.

> With eager execution, the Python code you write is the code that gets executed.

```python
model.compile(optimizer='adam', loss='mse', run_eagerly=True)
```

This might make model significantly slower. Once debugging finished, we'd better switch it back off.

## Speed up training with multiple GPUs

Keras also support multi-GPU training and distributed multi-worker training. via `tf.distribute` API.

If there multiple GPUs on the machine, we can train the model by:

```python
# 1. Create a MirroredStrategy.
strategy = tf.distribute.MirroredStrategy()

# 2. Building & Compiling model inside strategy scopy
# Open a strategy scope.
with strategy.scope():
  # Everything that creates variables should be under the strategy scope.
  # In general this is only model construction & `compile()`.
  model = Model(...)
  model.compile(...)

# 3. Call fit() & evaluate() on a dataset as usual
# Train the model on all available devices.
train_dataset, val_dataset, test_dataset = get_dataset()
model.fit(train_dataset, epochs=2, validation_data=val_dataset)

# Test the model on all available devices.
model.evaluate(test_dataset)
```

## Do preprocess sync on-device VS async on host CPU

> Having preprocessing happen as part of the model during training is great if you want to do on-device preprocessing, for instance, GPU-accelerated feature normalization or image augmentation. But there are kinds of preprocessing that are not suited to this setup: in particular, text preprocessing with the TextVectorization layer. Due to its sequential nature and due to the fact that it can only run on CPU, it's often a good idea to do asynchronous preprocessing.
>
> With asynchronous preprocessing, your preprocessing operations will run on CPU, and the preprocessed samples will be buffered into a queue while your GPU is busy with previous batch of data. The next batch of preprocessed samples will then be fetched from the queue to the GPU memory right before the GPU becomes available again (prefetching). This ensures that preprocessing will not be blocking and that your GPU can run at full utilization.

```python
# async ->  use dataset.map to inject preprocess operation into data pipeline

# Example training data, of dtype `string`.
samples = np.array([["This is the 1st sample."], ["And here's the 2nd sample."]])
labels = [[0], [1]]

# Prepare a TextVectorization layer.
vectorizer = TextVectorization(output_mode="int")
vectorizer.adapt(samples)

# Asynchronous preprocessing: the text vectorization is part of the tf.data pipeline.
# First, create a dataset
dataset = tf.data.Dataset.from_tensor_slices((samples, labels)).batch(2)
# Apply text vectorization to the samples
dataset = dataset.map(lambda x, y: (vectorizer(x), y))
# Prefetch with a buffer size of 2 batches
dataset = dataset.prefetch(2)

# Our model should expect sequences of integers as inputs
inputs = keras.Input(shape=(None,), dtype="int64")
x = layers.Embedding(input_dim=10, output_dim=32)(inputs)
outputs = layers.Dense(1)(x)
model = keras.Model(inputs, outputs)

model.compile(optimizer="adam", loss="mse", run_eagerly=True)
model.fit(dataset)
# 1/1 [==============================] - 0s 13ms/step - loss: 0.5028
# <tensorflow.python.keras.callbacks.History at 0x147777490>

# sync -> do text vectorization as part of the model

# Our dataset will yield samples that are strings
dataset = tf.data.Dataset.from_tensor_slices((samples, labels)).batch(2)

# Our model should expect strings as inputs
inputs = keras.Input(shape=(1,), dtype="string")
x = vectorizer(inputs)
x = layers.Embedding(input_dim=10, output_dim=32)(x)
outputs = layers.Dense(1)(x)
model = keras.Model(inputs, outputs)

model.compile(optimizer="adam", loss="mse", run_eagerly=True)
model.fit(dataset)
# 1/1 [==============================] - 0s 16ms/step - loss: 0.5258
# <tensorflow.python.keras.callbacks.History at 0x1477b1910>

# After training, export end-to-end model
inputs = keras.Input(shape=(1,), dtype='string')
x = vectorizer(inputs)
outputs = trained_model(x)
end_to_end_model = keras.Model(inputs, outputs)
```

- When training text models on CPU, generally no see any performance difference between 2 setup
- When training on GPU, doing async buffered preprocessing on the host CPU while GPU is running the model itself can result a significant `speedup`

## Find best model configuration with `hyperparameter` tuning

Use Keras Tuner to find best hyperparameter for our Keras model.

```python
# Inside this function, replace any value you want to tune with a call to hyperparameter sampling methods, e.g. hp.Int() or hp.Choice()
# return a compiled model
def build_model(hp):
    inputs = keras.Input(shape=(784,))
    x = layers.Dense(
        units=hp.Int('units', min_value=32, max_value=512, step=32),
        activation='relu'))(inputs)
    outputs = layers.Dense(10, activation='softmax')(x)
    model = keras.Model(inputs, outputs)
    model.compile(
        optimizer=keras.optimizers.Adam(
            hp.Choice('learning_rate',
                      values=[1e-2, 1e-3, 1e-4])),
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy'])
    return model

# instantiate a tuner object specifying your optimization objective and other search parameters
import kerastuner
tuner = kerastuner.tuners.Hyperband(
  build_model,
  objective='val_loss',
  max_epochs=100,
  max_trials=200,
  executions_per_trial=2,
  directory='my_dir')

# start search, take same arguments as Model.fit()
tuner.search(dataset, validation_data=val_dataset)

# retrieve best model(s)
models = tuner.get_best_models(num_models=2)
# OR
tuner.results_summary()
```

#### Reference

- <https://keras.io/api/>
- <https://keras.io/guides/functional_api/>
- <https://keras.io/guides/training_with_built_in_methods/>
