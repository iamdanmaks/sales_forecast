--Запрос, который выводит прогноз для города с наибольшим количеством продаж 
WITH
  Paris_model AS (
  SELECT
    *
  FROM (
  --делаем всё аналогично
    SELECT
      TIMESTAMP(Date_Part) AS Date,
      (COUNT(DISTINCT DocumentId)) AS Sales
    FROM
      `twc-bi-education.sales_data.sale`
    WHERE
      Date_Part BETWEEN '2019-03-01'
      AND '2019-12-31'
      --выбираем  город и страну
      AND TRIM(City) = 'PARIS'
      AND Country = 'France'
    GROUP BY
      Date)
  LEFT JOIN (
    SELECT
      forecast_timestamp,
      EXP(forecast_value) AS Pred,
      prediction_interval_lower_bound,
      prediction_interval_upper_bound
    FROM
      ML.FORECAST(MODEL `twc-bi-education.sales_data.paris_sales`,
        STRUCT(306 AS horizon,
          0.9 AS confidence_level)))
  ON
    (Date = forecast_timestamp) )
SELECT
  EXTRACT(WEEK(SATURDAY)
  FROM
    Paris_model.Date) AS Week,
  EXP(AVG(LOG(GREATEST(Paris_model.Sales, 1)))) AS Sales,
  EXP(AVG(LOG(GREATEST(Paris_model.Pred, 1)))) AS ARIMA_prognose
FROM
  Paris_model
GROUP BY
  Week
