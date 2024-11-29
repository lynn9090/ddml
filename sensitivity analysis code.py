import matplotlib.pyplot as plt
from doubleml import DoubleMLData, DoubleMLPLR
from sklearn.ensemble import RandomForestRegressor
import pandas as pd
import numpy as np

# CSV data
data_path = "data.csv"
data = pd.read_csv(data_path)

# y, d, X
y_col = 'relilience'
d_col = 'digital'
X_cols = ['age', 'age_sq', 'edu', 'farmtime', 'health', 'party', 'labor', 
          'plant_demons', 'farmland_area', 'consolidation', 'certification', 
          'income', 'agtraing', 'emtraing', 'insurance', 'loan', 'water', 
          'coll_economic', 'distance', 'capabilities', 'drought', 'frost', 
          'credit', 'policy', 'technology_support']

# DoubleML
obj_dml_data = DoubleMLData(data, y_col, d_col, X_cols)

# learner
ml_l = RandomForestRegressor()
ml_m = RandomForestRegressor()

#DoubleMLPLR
dml_plr = DoubleMLPLR(obj_dml_data, ml_l, ml_m)

# fit
dml_plr.fit()

# sensitivity analysis
sensitivity_analysis = dml_plr.sensitivity_analysis(cf_y=0.03, cf_d=0.03, rho=1.0, level=0.95)



