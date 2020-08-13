/* создаём модель (ARIMA) для прогнозирования всех продаж, 
убрав продажи в Германии, потому что они прекратились в ферале 2018-го 
и не влияют на актуальне даты */
CREATE OR REPLACE MODEL
  `twc-bi-education.sales_data.sales_without_germany` OPTIONS(MODEL_TYPE='ARIMA',
    time_series_timestamp_col='Date',
    time_series_data_col='Sales',
    -- выбираем регион (Франция) для праздников
    holiday_region='FR') AS
SELECT
  TIMESTAMP(Date_Part) AS Date,
  -- нормализуем уникальные продажи (берём натуральный логарифм от корня продаж)
  LN(SQRT(COUNT(DISTINCT DocumentId))) AS Sales
FROM
  `twc-bi-education.sales_data.sale`
WHERE
  -- берём продажи до марта 2019-го без Германии
  Date_Part < '2019-03-01'
  AND Country != 'Germany'
GROUP BY
  Date
