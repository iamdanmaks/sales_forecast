WITH
  RealPastSales AS (
  SELECT
    TIMESTAMP(Date_Part) AS Date,
    COUNT(DISTINCT DocumentId) AS Sales
  FROM
    `twc-bi-education.sales_data_2.sale_from_2016`
  WHERE
    RetailYear BETWEEN 2015 AND 2019
  GROUP BY
    Date),
  MeanAndStd AS (
  SELECT
    AVG(Sales) AS mean,
    STDDEV(Sales) AS std
  FROM
    RealPastSales),
  MaxAndMin AS (
  SELECT
    MAX(Sales) AS max,
    MIN(Sales) AS min
  FROM
    RealPastSales
  WHERE
    Date BETWEEN '2018-01-01'
    AND '2018-12-31'),
  PredictionComparisonByDates AS (
  SELECT
    *
  FROM (
      -- выбираем продажи с 17 октября до конца года
    SELECT
      TIMESTAMP(Date_Part) AS Date,
      COUNT(DISTINCT DocumentId) AS Sales
    FROM
      `twc-bi-education.sales_data_2.sale`
    WHERE
      RetailYear = 2019
    GROUP BY
      Date)
    -- джойним реальне продажи с прогнозом
  LEFT JOIN (
    SELECT
      forecast_timestamp,
      -- денормализуем полученные прогнозы (берём экспоненту квадрата прогноза)
      (forecast_value * std) + mean AS Pred,
    FROM
      -- прогнозируем на 77 дней с уровнем уверенности в 80%
      ML.FORECAST(MODEL `twc-bi-education.sales_data_2.sales_us`,
        STRUCT(365 AS horizon,
          0.8 AS confidence_level)),
      MeanAndStd)
  ON
    (Date = forecast_timestamp)
  ORDER BY
    Date),
  -- спрогнозируем эти дат оригинальной моделью
  OriginalModelPrediction AS (
  SELECT
    forecast_timestamp,
    -- денормализуем результат
    (POW(forecast_value, 2) * (max - min)) + min AS Pred_original
  FROM
    -- предсказываем на 306 дней с уровнем уверенности в 80%
    ML.FORECAST(MODEL `twc-bi-education.sales_data_2.sales_us_2018`,
      STRUCT(365 AS horizon,
        0.8 AS confidence_level)),
    MaxAndMin),
  -- объединяем все прогнозы и настоящие продажи в одну таблицу по датам
  GeneralComparison AS (
  SELECT
    *
  FROM
    PredictionComparisonByDates
  LEFT JOIN
    OriginalModelPrediction
  ON
    (PredictionComparisonByDates.Date = OriginalModelPrediction.forecast_timestamp))
SELECT
  -- группируем по неделям, начиная с субботы
  EXTRACT(WEEK
  FROM
    Date) AS Week,
  -- берём среднее геометрическое по неделям
  AVG(Sales) AS Sales,
  AVG(Pred) AS ARIMA_full,
  AVG(Pred_original) AS ARIMA_2018
FROM
  GeneralComparison
GROUP BY
  Week
