WITH
  PredictionComparisonByDates AS (
  SELECT
    *
  FROM (
    -- выбираем продажи с 17 октября до конца года
    SELECT
      TIMESTAMP(Date_Part) AS Date,
      COUNT(DISTINCT DocumentId) AS Sales
    FROM
      `twc-bi-education.sales_data.sale`
    WHERE
      Date_Part BETWEEN '2019-10-17'
      AND '2019-12-31'
    GROUP BY
      Date)
  -- джойним реальне продажи с прогнозом
  LEFT JOIN (
    SELECT
      forecast_timestamp,
      -- денормализуем полученные прогнозы (берём экспоненту квадрата прогноза)
      EXP(POW(forecast_value, 2)) AS Pred,
    FROM
      -- прогнозируем на 77 дней с уровнем уверенности в 80%
      ML.FORECAST(MODEL `twc-bi-education.sales_data.refitted_model`,
        STRUCT(77 AS horizon,
          0.8 AS confidence_level)))
  ON
    (Date = forecast_timestamp)
  ORDER BY
    Date),
  -- спрогнозируем эти дат оригинальной моделью
  OriginalModelPrediction AS (
  SELECT
    forecast_timestamp,
    -- денормализуем результат
    POW(EXP(forecast_value), 2) AS Pred_original
  FROM
    -- предсказываем на 306 дней с уровнем уверенности в 80%
    ML.FORECAST(MODEL `twc-bi-education.sales_data.sale_model`,
      STRUCT(306 AS horizon,
        0.8 AS confidence_level))
  WHERE
    -- берём предсказания только от 17 октября
    forecast_timestamp >= '2019-10-17'),
  -- объединяем все прогнозы и настоящие продажи в одну таблицу по датам
  GeneralComparison AS (
  SELECT
    *
  FROM
    PredictionComparisonByDates
  LEFT JOIN
    OriginalModelPrediction
  ON
    (PredictionComparisonByDates.Date = OriginalModelPrediction.forecast_timestamp))
SELECT
  -- группируем по неделям, начиная с субботы
  EXTRACT(WEEK(SATURDAY)
  FROM
    Date) AS Week,
  -- берём среднее геометрическое по неделям
  EXP(AVG(LOG(GREATEST(Sales, 1)))) AS Sales,
  EXP(AVG(LOG(GREATEST(Pred, 1)))) AS ARIMA_prognose_refitted,
  EXP(AVG(LOG(GREATEST(Pred_original, 1)))) AS ARIMA_prognose_original
FROM
  GeneralComparison
GROUP BY
  Week
