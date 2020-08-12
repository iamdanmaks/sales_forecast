WITH
  forecast_Associated AS (
  SELECT
    *
  FROM (
      SELECT
      -- конвертируем в timestamp, чтоб обьединить продажи с прогнозом аримы по датам
        TIMESTAMP(Date_Part) AS Date,
        -- выбираем уникальные продажи
        (COUNT(DISTINCT DocumentId)) AS Sales
      FROM
        `twc-bi-education.sales_data_2.sale`
      WHERE
        Date BETWEEN '2019-01-01'
        AND '2019-12-31'
        -- выбираем соответсвующие город и страну
        AND AssociateId = '95bf6961-ce6f-4c35-bd53-dac9c01d2d4d'
      GROUP BY
        Date)
    LEFT JOIN (
      SELECT
        forecast_timestamp,
        forecast_value AS Pred,
        prediction_interval_lower_bound,
        prediction_interval_upper_bound
      FROM
      -- берём прогноз из модели с ровнем уверенности в 0.9 на 365 дней
        ML.FORECAST(MODEL `twc-bi-education.sales_data_2.sales_associated`,
          STRUCT(365 AS horizon,
            0.9 AS confidence_level)))
    ON
      (Date = forecast_timestamp)
    ORDER BY
      Date) 
SELECT 
-- групируем дни в недели, начиная с субботы, чтоб не разрывать пики приходящиеся на выходные
  EXTRACT(WEEK(SATURDAY)
  FROM
    forecast_Associated.Date) AS Week,
    /* берём среднее арифметическое, поскольку данных мало и уменьшение их разброса 
  приведёт к потери в точности прогноза */
  AVG(forecast_Associated.Sales) AS Actual,
  AVG(forecast_Associated.Pred) AS Predicted
FROM
  forecast_Associated
  --группируем и сортируем по неделям
GROUP BY
  Week
