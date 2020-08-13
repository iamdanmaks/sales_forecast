--Создание модели для обучения без учета пиков выборки
CREATE OR REPLACE MODEL
--Создаем модель, выбираем регион для праздников Францию
  `twc-bi-education.sales_data.sales_date` OPTIONS(MODEL_TYPE='ARIMA',
    time_series_timestamp_col='Date',
    time_series_data_col='Sales',
    holiday_region='FR') AS
SELECT
  Date_Part AS Date,
  --Нормализируем данные (берем логарифм от корня)
  LN(SQRT(COUNT(DISTINCT DocumentId))) AS Sales
FROM
  `twc-bi-education.sales_data.sale`
  --выбираем нужные интервалы
WHERE
  Date_Part BETWEEN '2016-02-01'
  AND '2016-06-20'
  OR Date_Part BETWEEN '2016-08-08'
  AND '2016-09-25'
  OR Date_Part BETWEEN '2016-10-10'
  AND '2016-12-16'
  OR Date_Part BETWEEN '2017-02-10'
  AND '2017-06-10'
  OR Date_Part BETWEEN '2017-08-08'
  AND '2017-09-25'
  OR Date_Part BETWEEN '2017-10-10'
  AND '2017-11-20'
  OR Date_Part BETWEEN '2017-11-27'
  AND '2017-12-16'
  OR Date_Part BETWEEN '2018-02-05'
  AND '2018-06-10'
  OR Date_Part BETWEEN '2018-08-08'
  AND '2018-09-25'
  OR Date_Part BETWEEN '2018-10-10'
  AND '2018-11-18'
  OR Date_Part BETWEEN '2018-11-26'
  AND '2018-12-16'
  OR Date_Part BETWEEN '2019-02-05'
  AND '2019-02-28'
GROUP BY
  Date
