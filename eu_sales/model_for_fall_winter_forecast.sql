/* берём реальные продажи и прогноз с 17 октября, 
чтоб проверить влияние дообучения на предсказание 
сдвинувшегося осеннего пика в 2019 */
WITH
  PredictionComparisonByDate AS (
  SELECT
    *
  FROM (
    SELECT
      TIMESTAMP(Date_Part) AS Date,
      COUNT(DISTINCT DocumentId) AS Sales
    FROM
      `twc-bi-education.sales_data.sale`
    WHERE
      -- берём дни с 17 октября 2019 года и до конца 2019-го
      Date_Part BETWEEN '2019-10-17'
      AND '2019-12-31'
    GROUP BY
      Date)
  LEFT JOIN (
    SELECT
      forecast_timestamp,
      --убираем нормализацию, возводя в квадрат и беря экспоненту от прогноза
      EXP(POW(forecast_value, 2)) AS Pred,
    FROM
      -- предсказываем на 77 дней с уровнем уверенности в 80%
      ML.FORECAST(MODEL `twc-bi-education.sales_data.refitted_model`,
        STRUCT(77 AS horizon,
          0.8 AS confidence_level)))
  ON
    (Date = forecast_timestamp)
  ORDER BY
    Date)
SELECT
  -- группируем по неделям, начиная с субботы, по аналогии с другими запросами
  EXTRACT(WEEK(SATURDAY)
  FROM
    Date) AS Week,
  -- берём геометрическое среднее, чтоб уменьшить разброс в данных
  EXP(AVG(LOG(GREATEST(Sales, 1)))) AS Sales,
  EXP(AVG(LOG(GREATEST(Pred, 1)))) AS ARIMA_forecast
FROM
  PredictionComparisonByDate
GROUP BY
  Week
