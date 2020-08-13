  /* обучаем модель (ARIMA) для прогнозирования продаж в США */
CREATE OR REPLACE MODEL
  `twc-bi-education.sales_data_2.sales_us` OPTIONS(MODEL_TYPE='ARIMA',
    -- задаём колонку с датами и данными для прогноза
    time_series_timestamp_col='Date',
    time_series_data_col='Sales',
    -- задаём регион (США) для учитывания его праздников в прогнозировании
    holiday_region='US') AS
SELECT
  -- переводим в timestamp для обучения
  TIMESTAMP(Date_Part) AS Date,
  /* применяем z-масштабирование */ 
  ML.STANDARD_SCALER(COUNT(DISTINCT DocumentId)) OVER() AS Sales
FROM
  `twc-bi-education.sales_data_2.sale_from_2016`
WHERE
  -- берём даные до 2019 года
  RetailYear < 2019
  AND RetailYear > 2015
GROUP BY
  Date
