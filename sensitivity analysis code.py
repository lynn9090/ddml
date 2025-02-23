import numpy as np
import pandas as pd
from sklearn.linear_model import LinearRegression
from sklearn.ensemble import RandomForestRegressor, RandomForestClassifier
from sklearn.neural_network import MLPRegressor, MLPClassifier
from sklearn.linear_model import Ridge
from sklearn.linear_model import LassoCV
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import make_pipeline
import doubleml as dml

file_path = r"C:\Users\lenovo\Desktop\12699\data.csv" 
data = pd.read_csv(file_path)

data.head() 
y_col = 'resilience'  
d_col = 'digital' 
X_cols = ['age', 'age_sq', 'edu', 'farmtime', 'health', 'party', 'labor',
          'plant_demons', 'farmland_area', 'consolidation', 'certification',
          'income', 'agtraing', 'emtraing', 'insurance', 'loan', 'water',
          'coll_economic', 'distance', 'capabilities', 'drought', 'frost',
          'credit', 'policy', 'technology_support'] 

data_dml = dml.DoubleMLData(data, y_col=y_col, d_cols=d_col, x_cols=X_cols)

data_dml

np.random.seed(42)

#(3)
learner_l = LinearRegression()
learner_m = LinearRegression()
#(4)
learner_l = RandomForestRegressor(n_estimators=100,  max_features=1, min_samples_leaf=1)
learner_m = RandomForestClassifier(n_estimators=100,  max_features=1, min_samples_leaf=1)
#(5)
learner_l = MLPRegressor(hidden_layer_sizes=(50, 50), max_iter=200)
learner_m = MLPClassifier(hidden_layer_sizes=(50, 50), max_iter=200)
#(6)
learner_l = Ridge(alpha=1.0) 
learner_m = Ridge(alpha=1.0)
#(7)
Cs = 0.0001*np.logspace(0, 4, 10)
learner_l = make_pipeline(StandardScaler(), LassoCV(cv=5, max_iter=1000))
learner_m = make_pipeline(StandardScaler(), LassoCV(cv=5, max_iter=1000))


dml_obj = dml.DoubleMLPLR(data_dml, ml_l=learner_l, ml_m=learner_m, n_folds=5, n_rep=1)
dml_obj.fit()  
dml_obj.fit(store_predictions=True)

print(" DoubleMLPLR :")
print(dml_obj)


print("confint:")
print(dml_obj.confint())

print("sensitivity analysis:")
dml_obj.sensitivity_analysis(cf_y=0.04, cf_d=0.03)  
print(dml_obj.sensitivity_summary)  

dml_obj.sensitivity_plot()
