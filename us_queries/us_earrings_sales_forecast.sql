/* прогнозируем продажи по неделям на 2019 год 
беря среднее квадратичное прогнозов за неделю */
WITH
  PredictionComparisonByDates AS (
  SELECT
    *
  FROM (
    SELECT
      TIMESTAMP(Date_Part) AS Date,
      COUNT(DISTINCT DocumentId) AS Sales
    FROM
      `twc-bi-education.sales_data_2.sale_from_2016`
    WHERE
      Class = 'Earrings'
  AND RetailPrice > 5
  AND RetailYear = 2019
    GROUP BY
      Date)
  LEFT JOIN (
    SELECT
      forecast_timestamp,
      -- восстанавливаем прогноз возводя во вторую степень и беря экспоненту
      EXP(POW(forecast_value, 2)) AS Pred
    FROM
      -- берём прогноз на 306 дней с уровнем уверенности в 80%
      ML.FORECAST(MODEL `twc-bi-education.sales_data_2.sales_us_earrings`,
        STRUCT(365 AS horizon,
          0.8 AS confidence_level)))
  ON
    (Date = forecast_timestamp) )
SELECT
  -- групирем  по неделям начиная с субботы по аналогии с другими запросами
  EXTRACT(WEEK
  FROM
    Date) AS Week,
  -- берём среднее квадратичное за каждую неделю, чтоб уменьшить разброс
  `twc-bi-education.sales_data_2.SquaredMean`(array_agg(cast(Sales as float64))) AS Sales,
  `twc-bi-education.sales_data_2.SquaredMean`(array_agg(cast(Pred as float64))) AS ARIMA_forecast
FROM
  PredictionComparisonByDates
GROUP BY
  Week
