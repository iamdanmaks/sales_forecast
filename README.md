# Sales Forecast Project Using Google's Big Query and Python

This repository contains the research on sales forecast for one year using Google's Big Query and Data Studio. SQL, Python and some JS were used to complete given tasks.

Folder **eu_sales** contains SQL queries for dataset with some clothes sales in Europe and Asia. The task was to build a model for forecasting sales with high accuracy. **ARIMA** model from Big Query was used to perform it. All the queries for models creation can be found in **eu_sales/models_fitting**. Other queries are used to either predict sales for some period or to reearch some dependencies in dataset, which can help get better forecast score. There is code for general sales model, models for different cities sales and online sales, model for specific type of goods and model trained without outliers. Forecast is performed either daily or weekly by aggregating the predictions by weeks with different mean functions.

Folder **us_sales** contain SQL queries for dataset with gifts sales in USA. The task is similar to previous; build a forecast model with **ARIMA**. All the queries for models creation are contained in **us_sales/models_fitting**. Other queries are used to predict sales and to get better understanding of data used for this task. There are four models: general model trained on data from 2016 to 2018, general model trained strictly on 2018, model for most efficient associate sales forecasting and model for predicting earrings sales. Forecast can be done daily or weekly by aggregating the predictions by weeks with different mean functions.

**Custom_functions** folder contains UDF-functions for Big Query on JS to count harmonic and qudratic means.

**Model_info** provides you with functions to get ARIMA coefficients and features. **shannon_entropy.sql** is SQL script to count Shannon entropy of data. It was used to check data for difficulty of forecasting.

**Notebooks** folder contains Jupyter Notebooks with some additional research on time series stationarity. You can find code to count **Sample Entropy** there. Also, the **ADF test** was done in these notebooks, which prooved the stationarity of given data. **Test for seasonality** was performed there too. It showed that data is pretty similar each half a year.

Data studio reports links:
* [First one](https://datastudio.google.com/reporting/9ddc4bbd-a368-4d96-aca7-9b7ca15a66a1)
* [Second one](https://datastudio.google.com/reporting/a948f72b-a16e-4dea-adc0-d93683820566)
