from sklearn import svm, datasets
import sklearn.model_selection as model_selection
from sklearn.metrics import accuracy_score
from sklearn.metrics import f1_score
import os
from spktype21 import SPKType21

#Load the .spk dataset for AN/natural:

path = r'C:\\Users\SeanG\\github\\auditory_pathwayML\\Data\\AN\\natural'

fileList = os. listdir(path)

#spkInstance = SPKType21.open(path)

