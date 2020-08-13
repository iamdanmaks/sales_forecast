WITH
  -- берём настоящие продажи за март - декабрь 2019 по датам
  PredictionComparisonByDates AS (
  SELECT
    *
  FROM (
    SELECT
      TIMESTAMP(Date_Part) AS Date,
      COUNT(DISTINCT DocumentId) AS Sales
    FROM
      `twc-bi-education.sales_data.sale`
    WHERE
      Date_Part BETWEEN '2019-03-01'
      AND '2019-12-31'
    GROUP BY
      Date)
  -- джойним по датам с прогнозом модели
  LEFT JOIN (
    SELECT
      forecast_timestamp,
      -- денормализуем прогнозы
      POW(EXP(forecast_value), 2) AS Pred
    FROM
      -- прогнозируем на 306 дней с уровнем уверенности в 80%
      ML.FORECAST(MODEL `twc-bi-education.sales_data.sales_without_germany`,
        STRUCT(306 AS horizon,
          0.8 AS confidence_level)))
  ON
    (Date = forecast_timestamp) )
SELECT
  -- группируем по неделям, начиная с субботы
  EXTRACT(WEEK(SATURDAY)
  FROM
    Date) AS Week,
  -- считаем среднее гармоническое за каждую неделю
  `twc-bi-education.sales_data.HarmonicMean`(ARRAY_AGG(CAST(Sales AS float64))) AS Sales,
  `twc-bi-education.sales_data.HarmonicMean`(ARRAY_AGG(Pred)) AS ARIMA_prognose
FROM
  PredictionComparisonByDates
GROUP BY
  Week
