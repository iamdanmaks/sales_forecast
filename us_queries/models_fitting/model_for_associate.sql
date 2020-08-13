CREATE OR REPLACE MODEL
  `twc-bi-education.sales_data_2.sales_associated` OPTIONS(MODEL_TYPE='ARIMA',
    -- задаём колонку с датами и данными для прогноза
    time_series_timestamp_col='Date',
    time_series_data_col='Sales',
     -- задаём регион (Франция) для учитывания его праздников в прогнозировании
    holiday_region='US') AS
SELECT
  -- переводим в timestamp для обучения
  TIMESTAMP(Date_Part) AS Date,
  /* нормализуем данные, чтоб уменьшить разброс значений
  берём квадратный корень от натурального логарифма уникальнх продаж за каждй день */
  COUNT(DISTINCT DocumentId) AS Sales
FROM
  `twc-bi-education.sales_data_2.sale_from_2016`
WHERE
  -- берём даные до 2019 года
  -- фильтруем их по одному сезону, классу и подклассу, чтоб получить выборку конкретнх товаров
 AssociateId = '95bf6961-ce6f-4c35-bd53-dac9c01d2d4d'
GROUP BY
  Date
