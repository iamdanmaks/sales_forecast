  -- обучаем модель (ARIMA) для более точного прогнозирования продаж осенью
CREATE OR REPLACE MODEL
  `twc-bi-education.sales_data.refitted_model` OPTIONS(MODEL_TYPE='ARIMA',
    time_series_timestamp_col='Date',
    time_series_data_col='Sales',
    -- задаём регион (Франция) для учитывания праздников
    holiday_region='FR') AS
SELECT
  Date_Part AS Date,
  /* нормализуем данные, чтоб уменьшить разброс, 
  беря корень квадратнй от натуральног логарифма уникальных продаж за день */
  SQRT(LN(COUNT(DISTINCT DocumentId))) AS Sales
FROM
  `twc-bi-education.sales_data.sale`
WHERE
  /* берём данные до начала нового осеннего пика, 
  который сдвинулся с конца сентября на середину октября */
  Date_Part < '2019-10-16'
GROUP BY
  Date
