WITH
  SalesTill2020 AS (
  SELECT
    Date_Part,
    COUNT(DISTINCT DocumentId) AS Sales
  FROM
    `twc-bi-education.sales_data.sale`
  WHERE
    Date_Part < '2020-01-01'
  GROUP BY
    Date_Part),
  ProbabilityCTE AS (
  SELECT
    Sales,
    COUNT(Sales) AS StateFreq
  FROM
    SalesTill2020
  GROUP BY
    Sales ),
  StateEntropyCTE AS (
  SELECT
    Sales,
    1.0*StateFreq / SUM(StateFreq) OVER () AS StateProbability
  FROM
    ProbabilityCTE )
SELECT
  'sales' AS Variable,
  (-1)*SUM(StateProbability * LOG(StateProbability,2)) AS TotalEntropy,
  LOG(COUNT(*),2) AS MaxPossibleEntropy,
  100 * ((-1)*SUM(StateProbability * LOG(StateProbability,2))) / (LOG(COUNT(*),2)) AS PctOfMaxPossibleEntropy
FROM
  StateEntropyCTE
