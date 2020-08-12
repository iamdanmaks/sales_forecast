select City, Count(Distinct DocumentId) as Sales from `twc-bi-education.sales_data_2.sale_from_2016` group by City
