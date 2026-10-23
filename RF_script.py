import time

print('start at ' + time.strftime('%D %H:%M:%S'))

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns 

from sklearn import tree
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import confusion_matrix, mean_squared_error, mean_absolute_percentage_error, r2_score, mean_absolute_error

print('start reading dataset' + time.strftime('%D %H:%M:%S'))


trainX = pd.read_csv('../trainX_train.csv', header = None)
trainX = trainX.dropna(axis=1)

print("length of trainX", len(trainX.columns)) 

trainY = pd.read_csv('../phe_train.txt', header = None)

testX = pd.read_csv('../valX.csv', header = None)
testX = testX.dropna(axis=1)

print("length of testX", len(testX.columns)) 


testY = pd.read_csv('../phe_val.txt', header = None)


TBV_train = pd.read_csv('../bv_train.txt', header = None)

TBV = pd.read_csv('../bv_val.txt', header = None)

GV_train = pd.read_csv('../gv_train.txt', header = None)

GV = pd.read_csv('../gv_val.txt', header = None)



 

rf = RandomForestRegressor(n_estimators = NUM1, max_features = NUM2, max_depth = NUM3, min_samples_leaf = NUM4, oob_score = True, random_state = 2, n_jobs = -1) 

print('start fitting training dataset' + time.strftime('%D %H:%M:%S'))

rf.fit(trainX, trainY.values.ravel())

print('fitting training dataset finished' + time.strftime('%D %H:%M:%S'))
print("--Using training dataset for prediction--")
predicted1 = rf.predict(trainX)
print("R^2", r2_score(trainY, predicted1))
print("MSE of predicted value in training dataset:", mean_squared_error(trainY, predicted1))

corr_matrix1 = np.corrcoef(trainY.values.ravel(), predicted1)
corr1 = corr_matrix1[0, 1]

corr_matrix6 = np.corrcoef(TBV_train.values.ravel(), predicted1)
corr6 = corr_matrix6[0, 1]

corr_matrix7 = np.corrcoef(GV_train.values.ravel(), predicted1)
corr7 = corr_matrix7[0, 1]



prediction_train = pd.DataFrame(predicted1)

prediction_train.to_csv('prediction_train.csv')



coefficients1 = np.polyfit(predicted1,TBV_train.values.ravel(), 1)
slope1 = coefficients1[0]
print("The bias of ebv in training dataset is:", slope1)



print("Pearson correlation coefficient between predicted value and Phenotype of training dataset:", corr1)
print("Pearson correlation coefficient between predicted value and TBV of training dataset:", corr6)
print("Pearson correlation coefficient between predicted value and GV of training dataset:", corr7)

print("--Using test dataset for prediction--")
predicted2 = rf.predict(testX)

prediction_value = pd.DataFrame(predicted2)

prediction_value.to_csv('prediction.csv')


print("R^2", r2_score(testY, predicted2))
print("MSE of predicted value in test dataset:", mean_squared_error(testY, predicted2))

corr_matrix2 = np.corrcoef(testY.values.ravel(), predicted2)
corr2 = corr_matrix2[0, 1]


print("Pearson correlation coefficient between predicted value and phenotype of test dataset:", corr2)

corr_matrix3 = np.corrcoef(TBV.values.ravel(), predicted2)
corr3 = corr_matrix3[0, 1]

print("Pearson correlation coefficient between predicted value and TBV of test dataset:", corr3)

coefficients2 = np.polyfit(predicted2,TBV.values.ravel(), 1)
slope2 = coefficients2[0]
print("The bias of ebv in test dataset is:", slope2)



corr_matrix4 = np.corrcoef(GV.values.ravel(), predicted2)
corr4 = corr_matrix4[0, 1]

print("Pearson correlation coefficient between predicted value and GV of test dataset:", corr4)




print('stop at ' + time.strftime('%D %H:%M:%S'))