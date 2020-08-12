WITH
Tab1 AS (SELECT
  -- переводим в timestamp для обучения
  TIMESTAMP(Date_Part) AS Date,
  COUNT(DISTINCT DocumentId) AS Sales
FROM
  `twc-bi-education.sales_data_2.sale_from_2016`
WHERE
  -- берём даные до 2019 года
  RetailYear < 2019 AND RetailYear > 2015
GROUP BY
  Date),
  
z_transform AS (select AVG(Sales) as mean, STDDEV(Sales) as std from Tab1),

min_max AS (select max(Sales) as max, min(Sales) as min from Tab1 where Date between '2018-01-01' and '2018-12-31'),

  PredictionComparisonByDates AS (
  SELECT
    *
  FROM (
    SELECT
      TIMESTAMP(Date_Part) AS Date,
      COUNT(DISTINCT DocumentId) AS Sales
    FROM
      `twc-bi-education.sales_data_2.sale`
    WHERE
      RetailYear = 2019
    GROUP BY
      Date)
  -- джойним реальные продажи с прогнозом модели обученной на данных с 2016 по 2018
  LEFT JOIN (
    SELECT
      forecast_timestamp,
      -- денормализуем полученные прогнозы (домножаем на среднеквадратичное отклонение и прибавляем мат ожидание)
      (forecast_value * std) + mean AS Pred,
    FROM
      -- прогнозируем на 365 дней с уровнем уверенности в 80%
      ML.FORECAST(MODEL `twc-bi-education.sales_data_2.sales_us`,
        STRUCT(365 AS horizon,
          0.8 AS confidence_level)), z_transform)
  ON
    (Date = forecast_timestamp)
  ORDER BY
    Date),
  -- спрогнозируем эти даты моделью натренированной на 2018 году
  OriginalModelPrediction AS (
  SELECT
    forecast_timestamp,
    -- денормализуем результат после minmax преобразования
    (pow(forecast_value, 2) * (max - min)) + min AS Pred_original
  FROM
    -- предсказываем на 306 дней с уровнем уверенности в 80%
    ML.FORECAST(MODEL `twc-bi-education.sales_data_2.sales_us_2018`,
      STRUCT(365 AS horizon,
        0.8 AS confidence_level)), min_max),
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
  -- группируем по неделям
  EXTRACT(WEEK
  FROM
    Date) AS Week,
  -- берём среднее арифметическое по неделям
  AVG(Sales) AS Sales,
  AVG(Pred) AS ARIMA_full,
  AVG(Pred_original) AS ARIMA_2018
FROM
  GeneralComparison
GROUP BY Week
