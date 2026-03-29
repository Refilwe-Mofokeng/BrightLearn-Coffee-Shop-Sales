
SELECT transaction_date,
      dayname(transaction_date) AS day_name, 
      monthname(transaction_date) AS month_name, 
      CASE WHEN monthname(transaction_date) IN ('Jan', 'Feb') THEN 'Summer'
           WHEN monthname(transaction_date) IN ('Mar','Apr', 'May') THEN 'Autumn'
           WHEN monthname(transaction_date) IN ('Jun') THEN 'Winter'
           END AS season,
      dayofmonth(transaction_date) AS day_of_month, -- allows us to extract the day of month was the transaction performed
      date_format(transaction_time, 'HH:mm:ss') AS purchase_time, -- allows us to extract the time from the transaction time column

      CASE when dayname(transaction_date) IN ('Sat', 'Sun') then 'Weekend'
           else 'Weekday'
      END AS day_classification, --- creating a categorical column based on the day of the week

      CASE WHEN date_format(transaction_time, 'HH:mm:ss') BETWEEN '05:00:00' AND '08:59:59' THEN '01. Morning Rush' 
           WHEN date_format(transaction_time, 'HH:mm:ss') BETWEEN '09:00:00' AND '11:59:59' THEN '02. Mid-Morning' 
           WHEN date_format(transaction_time, 'HH:mm:ss') BETWEEN '12:00:00' AND '16:59:59' THEN '03. Afternoon'
           WHEN date_format(transaction_time, 'HH:mm:ss') BETWEEN '17:00:00' AND '18:59:59' THEN '04. Evening'
           ELSE '05. Night'
           END AS time_buckets, -- creating a categorical column based on the time buckets

-- Counts: normally use "id" to perform a count
      COUNT(DISTINCT transaction_id) AS number_of_sales, --- count different transactions (because of the group by function, it would give me number of sales per day)
      COUNT(DISTINCT product_id) AS number_of_products, 
-- Revenue
      SUM(transaction_qty * unit_price) AS revenue_per_day, --- this is aggregated, therefore it would give me the revenue for each day

      CASE when SUM(transaction_qty * unit_price) <= 50 Then '01. Low Spend'
           when SUM(transaction_qty * unit_price) BETWEEN 51 AND 100 THEN '02. Med Spend'
           else '03. High Spend'
      END AS spend_buckets,
      
-- Categorical columns - we don't aggregate, (add to Group by)
      store_location,
      product_category,
      product_type,
      product_detail
   
FROM workspace.default.coffeeshop_analysis
GROUP BY transaction_date, --- "group by" the columns that were not aggregated in our select statement
         dayname(transaction_date),
         monthname(transaction_date),
         CASE WHEN monthname(transaction_date) IN ('Jan', 'Feb') THEN 'Summer'
              WHEN monthname(transaction_date) IN ('Mar','Apr', 'May') THEN 'Autumn'
              WHEN monthname(transaction_date) IN ('Jun') THEN 'Winter'
              END,
         store_location,
         product_category,
         product_type,
         product_detail,
         date_format(transaction_time, 'HH:mm:ss'),
      CASE WHEN date_format(transaction_time, 'HH:mm:ss') BETWEEN '05:00:00' AND '08:59:59' THEN '01. Morning Rush' 
           WHEN date_format(transaction_time, 'HH:mm:ss') BETWEEN '09:00:00' AND '11:59:59' THEN '02. Mid-Morning' 
           WHEN date_format(transaction_time, 'HH:mm:ss') BETWEEN '12:00:00' AND '16:59:59' THEN '03. Afternoon'
           WHEN date_format(transaction_time, 'HH:mm:ss') BETWEEN '17:00:00' AND '18:59:59' THEN '04. Evening'
           ELSE '05. Night'
           END,
         CASE when dayname(transaction_date) IN ('Sat', 'Sun') then 'Weekend'
              else 'Weekday'
         END, 
         dayofmonth(transaction_date);
         
