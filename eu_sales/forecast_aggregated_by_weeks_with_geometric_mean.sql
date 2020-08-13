/* прогнозируем продажи по неделям на 2019 год 
беря среднее геометрическое прогнозов за неделю */
WITH
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
  LEFT JOIN (
    SELECT
      forecast_timestamp,
      -- восстанавливаем прогноз беря экспоненту и возводя во вторую степень
      POW(EXP(forecast_value), 2) AS Pred
    FROM
      -- берём прогноз на 306 дней с уровнем уверенности в 80%
      ML.FORECAST(MODEL `twc-bi-education.sales_data.sales_without_germany`,
        STRUCT(306 AS horizon,
          0.8 AS confidence_level)))
  ON
    (Date = forecast_timestamp) )
SELECT
  -- групирем  по неделям начиная с субботы по аналогии с другими запросами
  EXTRACT(WEEK(SATURDAY)
  FROM
    Date) AS Week,
  -- берём среднее геометрическое за каждую неделю, чтоб уменьшить разброс
  EXP(AVG(LOG(GREATEST(Sales, 1)))) AS Sales,
  EXP(AVG(LOG(GREATEST(Pred, 1)))) AS ARIMA_forecast
FROM
  PredictionComparisonByDates
GROUP BY
  Week
