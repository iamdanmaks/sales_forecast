/* обучаем модель (ARIMA) для прогнозирования на основе 2018 года */
CREATE OR REPLACE MODEL
  `twc-bi-education.sales_data_2.sales_us_2018` OPTIONS(MODEL_TYPE='ARIMA',
    -- задаём колонку с датами и данными для прогноза
    time_series_timestamp_col='Date',
    time_series_data_col='Sales',
     -- задаём регион (США) для учитывания его праздников в прогнозировании
    holiday_region='US') AS
SELECT
  -- переводим в timestamp для обучения
  TIMESTAMP(Date_Part) AS Date,
  /* нормализуем данные, чтоб уменьшить разброс значений
  берём квадратный корень от minmax смаштабированого значения */
  SQRT(ML.MIN_MAX_SCALER(COUNT(DISTINCT DocumentId)) OVER()) AS Sales
FROM
  `twc-bi-education.sales_data_2.sale_from_2016`
WHERE
  -- берём даные с 2018-го и до 2019 года
  RetailYear = 2018
GROUP BY
  Date
