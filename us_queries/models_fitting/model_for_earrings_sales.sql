CREATE OR REPLACE MODEL
  `twc-bi-education.sales_data_2.sales_us_earrings` OPTIONS(MODEL_TYPE='ARIMA',
    -- задаём колонку с датами и данными для прогноза
    time_series_timestamp_col='Date',
    time_series_data_col='Sales',
    -- задаём регион (США) для учитывания его праздников в прогнозировании
    holiday_region='US') AS
SELECT
  TIMESTAMP(Date_Part) AS Date,
  SQRT(LN(COUNT(DISTINCT DocumentId))) AS Sales
FROM
  `twc-bi-education.sales_data_2.sale_from_2016`
WHERE
  Class = 'Earrings'
  AND RetailPrice > 5
  AND RetailYear BETWEEN 2016
  AND 2018
GROUP BY
  Date
