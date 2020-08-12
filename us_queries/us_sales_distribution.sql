SELECT Date_Part, COUNT(DISTINCT DocumentId) as Sales FROM `twc-bi-education.sales_data_2.sale_from_2016` WHERE Date_Part BETWEEN '2016-01-01' AND '2019-12-31' GROUP BY Date_Part
