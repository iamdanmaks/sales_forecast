--Запрос для получения данных из прогноза без учета пиков продаж данных 
SELECT
  Week,
  ARIMA_prognose,
  Sales
FROM (
  WITH
  --Создаем вспомогательную таблицу
    forecast_without_peakes AS (
    SELECT
      *
    FROM (
        SELECT
        --Извлекаем дату и количество продаж
          TIMESTAMP(Date_Part) AS Date,
          (COUNT(DISTINCT DocumentId)) AS Sales
        FROM
          `twc-bi-education.sales_data.sale`
        WHERE
        --Делаем прогноз с марта 2019 до 2020 года 
          Date_Part BETWEEN '2019-03-01'
          AND '2019-12-31'
        GROUP BY
          Date)
      LEFT JOIN (
        SELECT
          forecast_timestamp,
          --Используем нашу оптимальную нормализацию 
          POW(EXP(forecast_value), 2) AS Pred,
          prediction_interval_lower_bound,
          prediction_interval_upper_bound
        FROM
          ML.FORECAST(MODEL `twc-bi-education.sales_data.sales_without_germany`,
            STRUCT(306 AS horizon,
              0.9 AS confidence_level)))
      ON
        (Date = forecast_timestamp)
      ORDER BY
        Date)
  SELECT
  -- По аналогии неделю начинаем с субботы
    EXTRACT(WEEK(SATURDAY)
    FROM
      forecast_without_peakes.Date) AS Week,
    EXP(AVG(LOG(GREATEST(forecast_without_peakes.Sales, 1)))) AS Sales,
    EXP(AVG(LOG(GREATEST(forecast_without_peakes.Pred, 1)))) AS ARIMA_prognose
  FROM
    forecast_without_peakes
  WHERE
  -- Вырезаем пики продаж, которые были определены эмпирическим способом
    forecast_without_peakes.Date BETWEEN '2019-02-01'
    AND '2019-06-10'
    OR forecast_without_peakes.Date BETWEEN '2019-08-08'
    AND '2019-09-25'
    OR forecast_without_peakes.Date BETWEEN '2019-10-10'
    AND '2019-11-20'
    OR forecast_without_peakes.Date BETWEEN '2019-12-01'
    AND '2019-12-16'
  GROUP BY
  --Аналогично группируем по неделям
    Week
    --Сортируем по неделям
  ORDER BY
    Week) AS Models
