  -- Получаем реальные продажи и прогноз модели по заданм датам
WITH
  PredictionComparisonByDates AS (
  SELECT
    *
  FROM (
    SELECT
      -- конвертируем в timestamp, чтоб заджойнить продажи с прогнозом аримы по датам
      TIMESTAMP(date_part) AS date,
      -- выбираем уникальные продажи
      (COUNT(DISTINCT documentid)) AS sales
    FROM
      `twc-bi-education.sales_data.sale`
    WHERE
      -- фильтруем все продажи, чтоб они были только в 2019-м год
      date_part BETWEEN '2019-01-01'
      AND '2019-12-31'
      -- товары должны быть в сезоне осень-зима
      AND REGEXP_CONTAINS(season, '^*FW$')
      -- товар соответствуют классу интимных товаров
      AND class = '11_Intimates'
      -- товары соответствуют подклассу кружевного белья
      AND subclass1 = '1111_Lace'
    GROUP BY
      date)
  LEFT JOIN (
    SELECT
      forecast_timestamp,
      -- восстанавливаем нормализованные предсказания (возводим в квадрат и береём экспоненту)
      EXP(POW(forecast_value, 2)) AS pred,
    FROM
      -- берём прогноз из модели с ровнем уверенности в 0.8 на 365 дней
      ml.foreCAST(model `twc-bi-education.sales_data.sales_specific_good`,
        STRUCT(365 AS horizon,
          0.8 AS confidence_level)))
  ON
    -- джойним по датам
    (date = forecast_timestamp) )
  -- считаем прогноз по неделям, чтоб уменьшить ошибку в показаниях модели
SELECT
  -- групируем дни в недели, начиная с субботы, чтоб не разрывать пики приходящиеся на выходные
  EXTRACT(week(saturday)
  FROM
    date) AS week,
  /* берём среднее арифметическое, поскольку данных мало и уменьшение их разброса 
  приведёт к потери в точности прогноза */
  AVG(sales) AS sales,
  AVG(pred) AS arima_forecast
FROM
  PredictionComparisonByDates
GROUP BY
  week
