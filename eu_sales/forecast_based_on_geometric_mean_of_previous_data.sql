--Запрос в котором мы помимо прочего сравниваем прогноз арима модели со средним геометрическим по предыдущим годам
WITH
--создаем талицу для аримы
  main_tab AS (
    SELECT
      *
    FROM (
    --делаем всё аналогично с предыдущими
      SELECT
        TIMESTAMP(Date_Part) AS Date,
        (COUNT(DISTINCT DocumentId)) AS Sales
      FROM
        `twc-bi-education.sales_data.sale`
      WHERE
        Date_Part BETWEEN '2019-03-01'
        AND '2019-12-31'
      GROUP BY
        Date)
    LEFT JOIN (
      SELECT
        forecast_timestamp,
        POW(EXP(forecast_value), 2) AS Pred,
        prediction_interval_lower_bound,
        prediction_interval_upper_bound
      FROM
        ML.FORECAST(MODEL `twc-bi-education.sales_data.sale_model`,
          STRUCT(306 AS horizon,
            0.9 AS confidence_level)))
    ON
      (Date = forecast_timestamp)
    ORDER BY
      Date) ,
  geom_mean AS (
  -- в данном подзапросе мы считаем среднее за предыдущие года
  SELECT
    Date_Part AS Date,
    COUNT(DISTINCT DocumentId) AS Sales
  FROM
    `twc-bi-education.sales_data.sale`
  WHERE
  --смотрим на все даты за исключением 29 февраля, так как 2019 не высокосный
    Date_Part < '2019-03-01'
    AND Date_Part != '2016-02-29'
  GROUP BY
    Date
  ORDER BY
    Date),
  Union_tab AS (
  SELECT
  --вытаскиваем даты
    TIMESTAMP(CONCAT("2019", "-", CAST(EXTRACT(MONTH
          FROM
            Date) AS String), "-", CAST(EXTRACT(Day
          FROM
            Date) AS String))) AS Day,
            --берем среднее геометрическое по датам
    EXP(AVG(LOG(GREATEST(SQRT(LOG(Sales, 10)), 1)))) AS AvgSales
  FROM
    geom_mean
  GROUP BY
    Day),
  output_tab AS (
  SELECT
    *
  FROM
    main_tab
  LEFT JOIN
    Union_tab
  ON
    (Date = Day))
SELECT
-- аналогично считаем с того же дня
  EXTRACT(WEEK(Saturday)
  FROM
    output_tab.Date) AS Week,
    --выводим продажи, прогноз аримы и значения нашей модели
  EXP(AVG(LOG(GREATEST(output_tab.Sales, 1)))) AS Sales,
  EXP(AVG(LOG(GREATEST(output_tab.Pred, 1)))) AS ARIMA_prognose,
  EXP(AVG(LOG(GREATEST(POW(10, POW(output_tab.AvgSales, 2)), 1)))) AS GeomMeanForecast
FROM
  output_tab
GROUP BY
  Week
