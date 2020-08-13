/* обучаем модель (ARIMA) для прогнозирования конкретной группы товаров */
CREATE OR REPLACE MODEL
  `twc-bi-education.sales_data.sales_specific_good` OPTIONS(MODEL_TYPE='ARIMA',
    -- задаём колонку с датами и данными для прогноза
    time_series_timestamp_col='Date',
    time_series_data_col='Sales',
    -- выключаем авто ариму
    AUTO_ARIMA=FALSE,
    -- задаём коэфициенты p, d ,q для модели
    NON_SEASONAL_ORDER=(5,
      2,
      5),
     -- задаём регион (Франция) для учитывания его праздников в прогнозировании
    holiday_region='FR') AS
SELECT
  -- переводим в timestamp для обучения
  TIMESTAMP(Date_Part) AS Date,
  /* нормализуем данные, чтоб уменьшить разброс значений
  берём квадратный корень от натурального логарифма уникальнх продаж за каждй день */
  SQRT(LN(COUNT(DISTINCT DocumentId))) AS Sales
FROM
  `twc-bi-education.sales_data.sale`
WHERE
  -- берём даные до 2019 года
  RetailYear < 2019
  -- фильтруем их по одному сезону, классу и подклассу, чтоб получить выборку конкретнх товаров
  AND REGEXP_CONTAINS(Season, '^*FW$')
  AND Class = '11_Intimates'
  AND Subclass1 = '1111_Lace'
GROUP BY
  Date
