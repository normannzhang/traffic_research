# Chicago Traffic Crash Risk Analysis

## Summarization of Project
This research explores traffic crashes in Chicago between **2019-2024**, aiming to uncover patterns that contribute to **severe crashes**, crashes that are deemed as fatal or incapacitating injuries. While only 2.53% of the crashes in this data set are severe from the specified range, they are not randomly distributed and are often linked to modifiable environmental and roadway conditions. The goal of this project is to use data and predictive modeling to help policy makers take proactive steps to reduce crash risk, especially in high-priority ZIP codes.

## Bottom Line Up Front (BLUF):

Although severe crashes are rare, they are concentrated in specific locations and strongly influenced by conditions like poor lighting, intersections, and yield signs. Using machine learning and analysis, we can predict where and when crashes are most likely to occur, allowing public officials to act before crashes happen.

## Research Goals:

- Identify which roadway and environmental conditions are most associated with crashes.
- Train and compare various machine learning models to predict severity likelihood based on input conditions.
- Generate a ZIP-level risk map to support targeted infrastructure improvements.
- Provide a tool for interactive scenario experimentations, allowing policy makers to simulate different crash conditions

## Methodology:

**Data Source:**
- City of Chicago Data Portal public crash report data (https://data.cityofchicago.org/Transportation/Traffic-Crashes-Crashes/85ca-t3if/about_data)
- Dataset contains around ~1 million crash records from 2015-2025
- Filtered to only use 2019-2024 yeares for completeness, relevancy, and consistency.

**Preprocessing Steps:**
- Removed unknown/missing values in key fields
- Standardized variables (e.g., grouped numerical speed ranges to categories, merged various road types)
- Created binary target: severe = 1, non-severe = 0
- Applied SMOTE to address data minority class imbalance.

**Models Experimented:**
- Logistic Regression
- Naive Bayes
- Random Forest (highest overall performance and average ranking)
- Decision Tree
- Multilayer Perceptron (MLP)
- XGBoost
- PCA + Random Forest
- Fine-Tuned Random Forest (RandomSearchCV)
(All models, training, and analysis can be found in the .ipynb notebook)

**Evaluation Metrics:**
- Accuracy
- ROC-AUC
- Precision
- Recall
- Feature Importance

## Dashboard Features (Developed in R Shiny):

**Background:**
- Trends overtime, total severe count, severity by specific conditions breakdown.
- Choropleth map of severe crashes by ZIP.
- Specific conditions above the average of severity.

**Risk Model:**
- Users can select crash conditions (e.g., trafficway, lighting, weather)
- Generates severity probability from trained model
- Explains top contributing risk drivers

**ZIP-Level Risk:**
- Predicts risk scores for every ZIP based on selected conditions.
- Choropleth map updates using selected conditions to show estimated crash severity risk based on ZIP/location.

## Tech Stack:
- R, Shiny, bs4Dash
- GeoJSON, shapefiles for ZIP-level boundaries
- Python, scikit-learn, pandas, numpy
- reticulate library in R for python compatability and integration of model into Shiny.

## Policy Relevance:
The development of this tool allows for city officials, planners, agencies, and policymakers to pinpoint high-risk road environments before crashes happen, test what-if scenarios to evaluate impact of policy changes, and allocate resources towards preventative interventions.

## Project Files:
- 'data', folder used to store cleaned and processed datasets (data is in .gz format to compress in size, NOTE: must gunzip *.gz to .csv format to work with the application)
- 'model', folder used to store best performing pretrained ML model (Random Forest Classifier, .pkl file)
- 'www', stores static image assets for dashboard
- 'chicago_shapefile', shapefiles for ZIP code mapping in leaflet
- 'app.R', shiny app main file
- 'init.R', global environment setup
- 'tables.R', data summary tables used for exploratory data analysis
- 'visualzations.R', ggplot and leaflet visual functions necessary for app visualization and analysis
- 'README.md', project summary and general understanding of coding structure and details


### Application was fully developed and analyzed by Norman Zhang

