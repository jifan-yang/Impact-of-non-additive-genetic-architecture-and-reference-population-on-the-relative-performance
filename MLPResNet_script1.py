import time
print('start at ' + time.strftime('%D %H:%M:%S'))

import os, random
import numpy as np
import tensorflow as tf

SEED = 16
os.environ['PYTHONHASHSEED'] = str(SEED)
random.seed(SEED)
np.random.seed(SEED)
tf.random.set_seed(SEED)
tf.config.experimental.enable_op_determinism()

import pandas as pd
from sklearn.metrics import mean_squared_error, r2_score
from tensorflow import keras
from tensorflow.keras import layers, regularizers
from tensorflow.keras.optimizers import Adam


print('start construct model ' + time.strftime('%D %H:%M:%S'))
def build_mlp_resnet(input_dim,
                     hidden_dim=64,
                     num_blocks=3,
                     dropout_rate=0.2,
                     l2_reg=None,
                     output_activation=None):

    inputs = keras.Input(shape=(input_dim,))
    x = inputs

    if l2_reg:
        regularizer = regularizers.l2(l2_reg)
    else:
        regularizer = None

    for _ in range(num_blocks):
        shortcut = x
        x = layers.LayerNormalization()(x)
        x = layers.Dense(hidden_dim, activation= NUM1, kernel_regularizer=regularizer)(x)
        x = layers.Dropout(dropout_rate)(x)
        x = layers.Dense(input_dim, kernel_regularizer=regularizer)(x)
        x = layers.Add()([shortcut, x])

    x = layers.LayerNormalization()(x)
    outputs = layers.Dense(1, activation=output_activation)(x)
    return keras.Model(inputs, outputs)
print('start reading dataset ' + time.strftime('%D %H:%M:%S'))

trainX = pd.read_csv('../trainX.csv', header=None).dropna(axis=1)
trainY = pd.read_csv('../pheno.txt', header=None)
testX = pd.read_csv('../test.csv', header=None).dropna(axis=1)
testY = pd.read_csv('../pheno_young.txt', header=None)

X_train = trainX.values
y_train = trainY.values
X_test = testX.values
y_test = testY.values

print("X_train shape:", X_train.shape)
print("y_train shape:", y_train.shape)
print("X_test shape:", X_test.shape)
print("y_test shape:", y_test.shape)

input_dim = X_train.shape[1]

model = build_mlp_resnet(
    input_dim=input_dim,
    hidden_dim= NUM2,        
    num_blocks= NUM3,          
    dropout_rate=0.2,
    l2_reg= NUM4           
)


optimizer = Adam(learning_rate= NUM5)
model.compile(optimizer=optimizer, loss='mean_squared_error', metrics=['mae', 'mse'])

model.summary()

# ? EarlyStopping callback
early_stop = keras.callbacks.EarlyStopping(
    patience=10,
    restore_best_weights=True,
    verbose=1
)

print('start fitting training dataset ' + time.strftime('%D %H:%M:%S'))

model.fit(
    X_train, y_train.ravel(),
    epochs=100,
    batch_size=32,
    validation_split=0.2,
    callbacks=[early_stop],
    verbose=1  # show progress
)

print('fitting training dataset finished ' + time.strftime('%D %H:%M:%S'))

print("--Using training dataset for prediction--")
predicted1 = model.predict(X_train)
print("R^2:", r2_score(y_train, predicted1))
print("MSE:", mean_squared_error(y_train, predicted1))
pd.DataFrame(predicted1).to_csv('prediction_train.csv', index=False)

print("--Using test dataset for prediction--")
predicted2 = model.predict(X_test)
print("R^2:", r2_score(y_test, predicted2))
print("MSE:", mean_squared_error(y_test, predicted2))
pd.DataFrame(predicted2).to_csv('prediction.csv', index=False)

print('stop at ' + time.strftime('%D %H:%M:%S'))