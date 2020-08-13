--Создаем функцию для подсчета среднего гармонического среднее гармоническое =  n / (1/a_1 + 1/a_n + ... + 1/a_n)
CREATE FUNCTION `twc-bi-education.sales_data.HarmonicMean`(arr ARRAY<FLOAT64>)
     RETURNS FLOAT64 LANGUAGE js AS """
var sum_of_reciprocals = 0;
for (var i = 0; i < arr.length; ++i) {
     sum_of_reciprocals += 1 / arr[i];
}
return arr.length / sum_of_reciprocals;
""";
