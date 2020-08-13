-- создаём модель (ARIMA) для прогнозирования французским онлайн продаж
CREATE OR REPLACE MODEL
  `twc-bi-education.sales_data.online_sales` OPTIONS(MODEL_TYPE='ARIMA',
    time_series_timestamp_col='Date',
    time_series_data_col='Sales',
    -- задаём регион (Франция) для учитывания праздников
    holiday_region='FR') AS
SELECT
  TIMESTAMP(Date_Part) AS Date,
  -- не выполняем нормализацию, поскольку данных мало и их разброс невелик
  COUNT(DISTINCT DocumentId) AS Sales
FROM
  `twc-bi-education.sales_data.sale`
WHERE
  -- берём продажи до марта 2019-го
  Date_Part < '2019-03-01'
  -- фильтруем по французским онлайн продажам
  AND City IS NULL
  AND Country = 'France'
  AND IsWebReceipt IS TRUE
GROUP BY
  Date
