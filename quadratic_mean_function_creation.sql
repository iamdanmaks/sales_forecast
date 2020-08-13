CREATE OR REPLACE FUNCTION `twc-bi-education.sales_data_2.SquaredMean`(arr ARRAY<FLOAT64>) RETURNS FLOAT64 LANGUAGE js AS """
var sum = 0;
for (var i = 0; i < arr.length; ++i) {
     sum += arr[i] * arr[i];
}
return Math.sqrt(sum / arr.length);
""";
