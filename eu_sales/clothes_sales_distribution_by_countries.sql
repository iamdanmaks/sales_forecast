WITH
  Tab1 AS (
  SELECT
    *
  FROM (
    SELECT
      TIMESTAMP(Date_Part) AS Date1,
      (COUNT(DISTINCT DocumentId)) AS Sales_France
    FROM
      `twc-bi-education.sales_data.sale`
    WHERE
      Country = 'France'
    GROUP BY
      Date1)
  LEFT JOIN (
    SELECT
      TIMESTAMP(Date) AS Date2,
      (COUNT(DISTINCT DocumentId)) AS Sales_Germany
    FROM
      `twc-bi-education.sales_data.sale`
    WHERE
      Country = 'Germany'
    GROUP BY
      Date)
  ON
    (Date1 = Date2)
  ORDER BY
    Date1),
  Tab2 AS (
  SELECT
    *
  FROM (
    SELECT
      TIMESTAMP(Date_Part) AS Date3,
      (COUNT(DISTINCT DocumentId)) AS Sales_Belgium
    FROM
      `twc-bi-education.sales_data.sale`
    WHERE
      Country = 'Belgium'
    GROUP BY
      Date3)
  LEFT JOIN (
    SELECT
      TIMESTAMP(Date_Part) AS Date4,
      (COUNT(DISTINCT DocumentId)) AS Sales_Macao
    FROM
      `twc-bi-education.sales_data.sale`
    WHERE
      Country = 'Macao, SAR China'
    GROUP BY
      Date4)
  ON
    (Date3 = Date4)
  ORDER BY
    Date3)
SELECT
  *
FROM
  Tab1
LEFT JOIN
  Tab2
ON
  (Tab1.Date1 = Tab2.Date3)
ORDER BY
  Tab1.Date1
