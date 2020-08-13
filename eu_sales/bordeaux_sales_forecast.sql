-- Запрос на получения прогноза данных во втором по количеству продаж городе французком Бордо
-- Создаем вспомогательную таблтцу
WITH
  forecast_Bordeaux AS (
  SELECT
    *
  FROM (
      SELECT
      -- конвертируем в timestamp, чтоб обьединить продажи с прогнозом аримы по датам
        TIMESTAMP(Date_Part) AS Date,
        -- выбираем уникальные продажи
        (COUNT(DISTINCT DocumentId)) AS Sales
      FROM
        `twc-bi-education.sales_data.sale`
      WHERE
      -- фильтруем все продажи, чтоб они были только с марта 2019 года по 2020 год
        Date_Part BETWEEN '2019-03-01'
        AND '2019-12-31'
        --выбираем соответсвующие город и страну
        AND City = 'BORDEAUX'
        AND Country = 'France'
      GROUP BY
        Date)
    LEFT JOIN (
      SELECT
        forecast_timestamp,
        -- восстанавливаем нормализованные предсказания
        SQRT(POW(2, forecast_value)) AS Pred,
        prediction_interval_lower_bound,
        prediction_interval_upper_bound
      FROM
      -- берём прогноз из модели с ровнем уверенности в 0.9 на 306 дней
        ML.FORECAST(MODEL `twc-bi-education.sales_data.bordeaux_sales`,
          STRUCT(306 AS horizon,
            0.9 AS confidence_level)))
    ON
      (Date = forecast_timestamp)
    ORDER BY
      Date) 
SELECT 
-- групируем дни в недели, начиная с субботы, чтоб не разрывать пики приходящиеся на выходные
  EXTRACT(WEEK(SATURDAY)
  FROM
    forecast_Bordeaux.Date) AS Week,
    /* берём среднее арифметическое, поскольку данных мало и уменьшение их разброса 
  приведёт к потери в точности прогноза */
  AVG(forecast_Bordeaux.Sales) AS Actual,
  AVG(forecast_Bordeaux.Pred) AS Predicted
FROM
  forecast_Bordeaux
  --группируем и сортируем по неделям
GROUP BY
  Week
