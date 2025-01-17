/*
  Q1.How many orders per month?
*/
SELECT
  FORMAT_DATE('%Y %m',PARSE_DATE('%Y %m %d',DatePurchase)) AS month
  ,COUNT(DISTINCT TransactionID) AS count_order --count order 
FROM
  `hackathon-446917.midterm_SQL.hackaton_phones_sales`
GROUP BY 
  month
ORDER BY
  month
;


/*
  Q2. How many customers make purchases each month?
*/

SELECT
  FORMAT_DATE('%Y %m',PARSE_DATE('%Y %m %d',DatePurchase)) month
  ,COUNT(DISTINCT CustomerCode) so_khach_hang --count customer make purchase
FROM
  `hackathon-446917.midterm_SQL.hackaton_phones_sales`
GROUP BY 
  month
ORDER BY 
  month
;


/*
  Q3. Which brand of phone do Male and Female customers like the most?
  Top 3? (based on TransactionID)
*/

WITH sales_by_gender_brand AS ( --find customer group purchase phone
    SELECT
        SexType
        ,ProductBrand
        ,COUNT(DISTINCT TransactionID) AS transaction_count --count transaction
    FROM
        `hackathon-446917.midterm_SQL.hackaton_phones_sales`
    GROUP BY
        SexType
        ,ProductBrand
)
,ranked_gender_brand AS ( --ranking top 3 Male and Female customers
    SELECT
        SexType
        ,ProductBrand
        ,transaction_count
        ,DENSE_RANK() OVER(PARTITION BY SexType ORDER BY transaction_count DESC) AS brand_rank
    FROM
        sales_by_gender_brand
)
SELECT
    SexType
    ,ProductBrand
    ,transaction_count
    ,brand_rank
FROM
    ranked_gender_brand
WHERE
    brand_rank <= 3 --get top3 customer Male and Female
ORDER BY
    SexType
    ,brand_rank
;


/*
  Q4: Which age group buys the most, Which age group brings in the most revenue?
  Can you draw any conclusions (use the Unit field to add up the purchase quantity)
*/

WITH sales_by_age AS ( --Find total unit by age group
  SELECT
    YearOldRange
    ,SUM(ps.Unit + acc.Unit) AS total_units
    ,SUM((ps.Unit * ps.SalesValue) + (acc.Unit * acc.SalesValue)) AS total_revenue
  FROM
    `hackathon-446917.midterm_SQL.hackaton_phones_sales` ps
  LEFT JOIN
    `hackathon-446917.midterm_SQL.hackaton_accessories_sales` acc
  ON
    ps.TransactionID = acc.TransactionID
  GROUP BY
    YearOldRange
)
,ranked_sales_by_age AS (--Ranking age group
  SELECT
    YearOldRange
    ,total_units
    ,total_revenue
    ,DENSE_RANK() OVER(ORDER BY total_units DESC) AS rank_units
    ,DENSE_RANK() OVER(ORDER BY total_revenue DESC) AS rank_revenue
  FROM
    sales_by_age
)
SELECT
  YearOldRange
  ,total_units
  ,total_revenue
  ,rank_units
  ,rank_revenue
FROM
  ranked_sales_by_age
ORDER BY
  rank_units;


 /*
  Q5: Top 3 products that bring in the highest revenue each month? Provide insight for business if any
 */ 

WITH raw_data AS ( --Get revenue by month and prodct
  SELECT
    FORMAT_DATE('%Y %m',PARSE_DATE('%Y %m %d',DatePurchase)) AS month
    ,ProductName
    ,SUM(SalesValue) AS revenue
  FROM 
    `hackathon-446917.midterm_SQL.hackaton_phones_sales`
  GROUP BY
    month
    ,Productname
  ORDER BY
    month DESC
    ,revenue DESC
)
,ranking_revenue AS ( --Ranking by month
  SELECT
    month
    ,ProductName
    ,revenue
    ,DENSE_RANK() OVEr(PARTITION BY month ORDER BY revenue DESC) AS rk
  FROM raw_data
)


SELECT
  *
FROM 
  ranking_revenue
WHERE 
  rk <= 3
ORDER BY 
  month
  ,rk
;


/*
  Q6:Which brand does the 26-30 customer group like?
*/

WITH raw_data AS (
  SELECT
    YearOldRange
    ,ProductBrand
    ,SUM(Unit) AS quantity
  FROM 
    `hackathon-446917.midterm_SQL.hackaton_phones_sales`
  WHERE 
    YearOldRange = '26-30'
  GROUP BY
  YearOldRange
  ,ProductBrand
  ORDER BY 
    quantity desc
)

SELECT
  YearOldRange
  ,ProductBrand
  ,quantity
  ,DENSE_RANK() OVER(ORDER BY quantity DESC) AS rk
FROM
  raw_data
ORDER BY 
  rk
;

/*
  Q7: Is the 26-30 customer group ready to buy more accessories?
*/

WITH raw_data AS ( --Find age group data 26-30
  SELECT
    ps.TransactionID
    ,ps.YearOldRange
    ,ps.ProductName
    ,acc.Accessories_name
    ,acc.Accessories_subname
    ,acc.SalesValue
  FROM 
    `hackathon-446917.midterm_SQL.hackaton_phones_sales` ps
  LEFT JOIN
    `hackathon-446917.midterm_SQL.hackaton_accessories_sales` acc
  USING(transactionID)
  ORDER BY 
    ps.TransactionID
)

SELECT  
  YearOldRange
 ,COUNT(Accessories_name) AS accessories_sale --count the number of Accessories_name
 ,COUNT(*) AS total --count total
 ,COUNT(Accessories_name)/COUNT(*)*100.0 AS rate_access --rate of customers buying accessories
FROM
  raw_data
GROUP BY
  YearOldRange
ORDER BY
  rate_access desc
;

/*
 Q8: Does each company's customer group buy accessories and insurance?
*/

WITH raw_data AS (--check how many people by accessories and insurance
  SELECT
    ps.TransactionID
    ,ps.YearOldRange
    ,ps.ProductName
    ,ps.ProductBrand
    ,acc.Accessories_name
    ,acc.Accessories_subname
    ,acc.SalesValue
  FROM
    `hackathon-446917.midterm_SQL.hackaton_phones_sales` ps
  LEFT JOIN
    `hackathon-446917.midterm_SQL.hackaton_accessories_sales` acc
  USING(transactionID)
  ORDER BY
    ps.TransactionID
)


SELECT
  ProductBrand
  ,COUNT(Accessories_name) AS accessories_sale
  ,COUNT(*) as total
  ,COUNT(Accessories_name)/COUNT(*)*100.0 AS rate_buy_acces --rate customer who buy accessories, insurance
FROM
  raw_data
GROUP BY
  ProductBrand
ORDER BY 
  rate_buy_acces desc
  ,ProductBrand asc
;

/*
  Q9. Which age group has the most buying behavior in installments?
*/


SELECT
  YearOldRange
  ,COUNT(Bank) installments
  ,COUNT(*) total_orders
  ,COUNT(Bank)/COUNT(*) AS rate_installments
FROM
  `hackathon-446917.midterm_SQL.hackaton_phones_sales`
GROUP BY
  YearOldRange
ORDER BY
  rate_installments desc
;

/*
 Q10: Find the phone company that is most commonly purchased in installments
*/

SELECT
  ProductBrand
  ,COUNT(Bank) installments
  ,COUNT(*) total_orders
  ,COUNT(Bank)/COUNT(*) AS rate_installments
FROM  
  `hackathon-446917.midterm_SQL.hackaton_phones_sales`
GROUP BY
  ProductBrand
ORDER BY 
  rate_installments desc
;

