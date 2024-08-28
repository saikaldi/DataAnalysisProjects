-- find top 10 highest revenue generating product
SELECT product_id, SUM(sale_price) AS sales 
FROM df_orders
GROUP BY product_id
ORDER BY sales DESC
LIMIT 10;


-- find top 5 highest selling product in each region
with cte as(
SELECT region, product_id, SUM(sale_price) AS sales 
FROM df_orders
GROUP BY region, product_id)
SELECT * FROM (
SELECT *
, row_number() over(partition by region order by sales desc) as rn
from cte) A   
where rn<=5;

-- find month over month growth comparison for 2022 sales eg: jan 2022 vs jan 23
WITH cte AS (
    SELECT EXTRACT(YEAR FROM order_date) AS order_year, 
           EXTRACT(MONTH FROM order_date) AS order_month, 
           SUM(sale_price) AS sales 
    FROM df_orders
    GROUP BY order_year, order_month
)
SELECT order_month,
       SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
       SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month;

-- for each category which month had the highest sales
WITH cte AS (
    SELECT category, 
           TO_CHAR(order_date, 'YYYYMM') AS order_year_month, 
           SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY category, TO_CHAR(order_date, 'YYYYMM')
)
SELECT category, 
       order_year_month, 
       sales
FROM (
    SELECT category, 
           order_year_month, 
           sales, 
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY sales DESC) AS rn
    FROM cte
) AS ranked_sales
WHERE rn = 1
ORDER BY category;














