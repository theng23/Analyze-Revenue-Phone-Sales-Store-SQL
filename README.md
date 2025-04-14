# 📊Analyze Revenue Phone Sales Store|Big Querry, SQL
## 📑I. Introduction
### 📖 What is this project about?
- Phone Store want to grasp information about order volume, customer preferences, revenue and shopping behavior insight.
- This project contains an Phone and Accessories Sales from a Phone Store that utilize SQL on Google BigQuery.
- Focus on analyzing overview of sale and finding insight from this questions.

<details>
<summary>❓Business question:</summary>

1️⃣ How many orders per month?\
2️⃣ How many customers make purchases each month?\
3️⃣ Which brand of phone do Male and Female customers like the most? Top 3? (based on TransactionID)\
4️⃣ Which age group buys the most, Which age group brings in the most revenue?Can you draw any conclusions (use the Unit field to add up the purchase quantity)\
5️⃣ Top 3 products that bring in the highest revenue each month? Provide insight for business if any\
6️⃣ Which brand does the 26-30 customer group like?\
7️⃣ Is the 26-30 customer group ready to buy more accessories?\
8️⃣ Does each company's customer group buy accessories and insurance?\
9️⃣ Which age group has the most buying behavior in installments?\
🔟 Find the phone company that is most commonly purchased in installments

</details>

## 📂II. Dataset
Database for this project: [Phone_Database.xlsx](https://docs.google.com/spreadsheets/d/1Ms8F8yRGleDEtMX8yzEiABcDXqjFpQSY/edit?usp=sharing&ouid=116080139477453316139&rtpof=true&sd=true)
<br> **TABLE SCHEMA:**

<details>
<summary>Phone_Sale:</summary>
  
| Field Name | Data Type |
|-------|-------|
|TransactionID|STRING|
|CustomerCode|STRING|
|ProductName|STRING|
|ProductBrand|STRING|
|DatePurchase|STRING|
|GeographicalArea|STRING|
|Payment_Method|STRING|
|Bank|STRING|
|Color|STRING|
|Carrier|STRING|
|SexType|STRING|
|YearOldRange|STRING|
|Unitprice|INTEGER|
|SalesValue|INTEGER|
|Unit|INTEGER|

</details>

<details>
<summary>Accessories_Sales:</summary> 
  
| Field Name | Data Type |
|-------|-------|
| TransactionID | STRING |
|CustomerCode|STRING|
|Accessories_name|STRING|
|Accessories_subname|STRING|
|Unitprice|INTEGER|
|Unit|INTEGER|
|SalesValue|INTEGER|

</details>

## ⚒️III. Exploring the Dataset
In this project, I will write 10 query in BigQuery and used Phone_Database.
### **Q1.How many orders per month?**
- SQL Code
``` sql
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
```
- Results: <br>

|month  |count_order|
|-------|-----------|
|2015 01|16963      |
|2015 02|19999      |
|2015 03|17944      |
|2015 04|19570      |
|2015 05|20830      |

**Conclusion:** Order volume fluctuates, peaking in May (20,830) and dipping in January (16,963). Seasonal demand or promotions may influence these shifts.

###  Q2. How many customers make purchases each month?
- SQL Code

``` sql
SELECT
  FORMAT_DATE('%Y %m',PARSE_DATE('%Y %m %d',DatePurchase)) month
  ,COUNT(DISTINCT CustomerCode) AS count_customers --count customer make purchase
FROM
  `hackathon-446917.midterm_SQL.hackaton_phones_sales`
GROUP BY 
  month
ORDER BY 
  month
;
```
- Results: <br>

|month  |count_customers|
|-------|-------------|
|2015 01|16130        |
|2015 02|19217        |
|2015 03|17132        |
|2015 04|18828        |
|2015 05|19934        |

**Conclusion:** Order volume fluctuates from 16,963 in January to 20,830 in May, showing an overall upward trend with occasional dips, likely influenced by seasonality or promotions.

###  **Q3. Which brand of phone do Male and Female customers like the most? Top 3? (based on TransactionID)**
- SQL Code
```sql
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
```

- Results:

|SexType|ProductBrand|transaction_count|brand_rank|
|-------|------------|-----------------|----------|
|Male    |SAMSUNG     |15895            |1         |
|Male    |NOKIA       |9869             |2         |
|Male    |Q-SMART     |8395             |3         |
|Female     |SAMSUNG     |18320            |1         |
|Female     |NOKIA       |7715             |2         |
|Female     |Q-SMART     |7136             |3         |

**Conclusion:**

###  **Q4: Which age group buys the most, Which age group brings in the most revenue?Can you draw any conclusions (use the Unit field to add up the purchase quantity)**
- SQL Code
```sql 
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
```
- Results:

|YearOldRange|total_units|total_revenue|rank_units|rank_revenue|
|------------|-----------|-------------|----------|------------|
|26-30       |43516      |128660298500 |1         |2           |
|31-35       |15389      |216179303600 |2         |1           |
|36-40       |9642       |101302253500 |3         |3           |
|Under 21     |2380       |9850497000   |4         |4           |
|Over 40     |1466       |5130143500   |5         |5           |
|21-25       |1462       |4272092000   |6         |6           |

**Conclusion** <br>
- The 26-30 age group is the age group that buys the most and has the second highest revenue after the 30-35 age group. This is a young age group and always follows the trend of updating new phone lines and accessories on the market, the life cycle of a product is short. However, the financial capacity of this group is not as strong as the 31-35 age group, so the products purchased by the 26-30 group will be at a lower price.

- The 31-35 age group is the leading age group in terms of revenue, and ranks second in terms of quantity sold. This age group has strong financial capacity, is willing to pay for more expensive products, equivalent to higher quality and a longer life cycle than the 26-30 group.

### **Q5: Top 3 products that bring in the highest revenue each month? Provide insight for business if any**
- SQL Code
```sql
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
```
<details>
<summary>Results:</summary>

|month  |ProductName|revenue|rk |
|-------|-----------|-------|---|
|2015 01|Galaxy Note II N7100 Marble White|6325813000|1  |
|2015 01|Galaxy Note II N7100 Titan Gray|4961552500|2  |
|2015 01|Lumia 620 Black|3325739500|3  |
|2015 02|Galaxy Note II N7100 Marble White|5035073000|1  |
|2015 02|Galaxy Note II N7100 Titan Gray|3909001000|2  |
|2015 02|Lumia 620 Black|3892467000|3  |
|2015 03|Galaxy Note II N7100 Marble White|3578831000|1  |
|2015 03|Lumia 520 Black|3306246000|2  |
|2015 03|S5360(Toroto) White|2811021000|3  |
|2015 04|Lumia 520 Black|7704350000|1  |
|2015 04|Galaxy S3 Mini I8190 Marble White|4254747000|2  |
|2015 04|Lumia 720 Black|2949279000|3  |
|2015 05|Lumia 520 Black|8159257000|1  |
|2015 05|Galaxy S4 (I9500)White|5415746500|2  |
|2015 05|Galaxy S3 Mini I8190 Marble White|3901046000|3  |

</details>

**Conclusion**
- Sales of products fluctuate greatly from month to month, showing that the mobile phone market is very competitive and changing rapidly.
- Galaxy Note II N7100 Marble White was the top selling product in January, February and March 2015. However, its sales decreased from January to March.
- Lumia 520 Black surpassed Galaxy Note II N7100 Marble White to become the highest selling product in April and May 2015. This shows the change in consumer preferences.
- Galaxy S3 Mini I8190 Marble White and Lumia 720 Black were also products with high sales in April and May, but did not reach the top position.


### **Q6: Which brand does the 26-30 customer group like?**
- SQL Code
```sql
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
```
Results: <br>
|YearOldRange|ProductBrand|quantity|rk |
|------------|------------|--------|---|
|26-30       |SAMSUNG     |21184   |1  |
|26-30       |Q-SMART     |10010   |2  |
|26-30       |NOKIA       |9129    |3  |
|26-30       |Mobiistar   |5582    |4  |
|26-30       |LENOVO      |3090    |5  |
|26-30       |SONY        |2790    |6  |
|26-30       |LG          |1836    |7  |
|26-30       |HTC         |1751    |8  |
|26-30       |Q-MOBILE    |810     |9  |
|26-30       |APPLE IPHONE|786     |10 |
|26-30       |BLACKBERRY  |55      |11 |
|26-30       |HUAWEI      |15      |12 |
|26-30       |F-MOBILE    |6       |13 |
|26-30       |ALCATEL     |1       |14 |


**Conclusion:**
- The results table shows that the top 3 favorite phone brands of the 26-30 customer group are Samsung, Q-Smart and Nokia. Samsung accounts for the largest sales volume of the 3 brands.
- The company's marketing campaign for the 26-30 customer group should focus on Samsung. Especially if 26-30 is the main customer group.
If the inventory of Q-Smart and Nokia is high and the company wants to reduce it and shift its focus to Samsung and new brands, the company can consider a promotional campaign for these phone lines to attract more buyers


### **Q7: Is the 26-30 customer group ready to buy more accessories?**
- SQL Code
```sql
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
  WHERE 
    YearOldRange = '26-30'
  ORDER BY 
    ps.TransactionID
)

SELECT  
  YearOldRange
 ,COUNT(Accessories_name) AS accessories_sale --count the number of Accessories_name
 ,COUNT(*) AS total --count total
 ,ROUND(COUNT(Accessories_name)/COUNT(*)*100.0,2) AS rate_access --rate of customers buying accessories
from
  raw_data
group by 
  YearOldRange
;
```
Results: <br>
|YearOldRange|accessories_sale|total|rate_access|
|------------|----------------|-----|-----------|
|Over 40     |731             |1911 |38.25|
|26-30       |21491           |56309|38.17|
|21-25       |725             |1929 |37.58|
|Under 21     |1159            |3175 |36.5|
|31-35       |7107            |19621|36.22|
|36-40       |4428            |12361|35.82|


**Conclusion**
- With a rate of 38.16%, the rate of customers from 26-30 willing to buy more accessories is also quite high, however the rate of customers over 40 is higher at 38.25%. So to optimize profits, you can consider approaching this customer group.
### **Q8: Does each company's customer group buy accessories and insurance?**
- SQL Code
```sql
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
  ,COUNT(Accessories_name)/COUNT(*) AS rate_buy_acces --rate customer who buy accessories, insurance
FROM
  raw_data
GROUP BY
  ProductBrand
ORDER BY 
  ProductBrand
;
```
Results: <br>
|ProductBrand|accessories_sale|total|rate_buy_acces|
|------------|----------------|-----|--------------|
|APPLE IPHONE|1318            |1318 |100.0         |
|BLACKBERRY  |108             |108  |100.0         |
|SAMSUNG     |34215           |34215|100.0         |
|ALCATEL     |0               |1    |0.0           |
|F-MOBILE    |0               |13   |0.0           |
|HTC         |0               |2987 |0.0           |
|HUAWEI      |0               |24   |0.0           |
|LENOVO      |0               |5410 |0.0           |
|LG          |0               |3155 |0.0           |
|Mobiistar   |0               |8986 |0.0           |
|NOKIA       |0               |17584|0.0           |
|Q-MOBILE    |0               |1332 |0.0           |
|Q-SMART     |0               |15531|0.0           |
|SONY        |0               |4642 |0.0           |

**Conclusion**
- Customers from SAMSUNG, BLACKBERRY, APPLE IPHONE alway willing buy accessories with 100% rate.
- Other Product Brand have 0% rate so need to improve accessory products and adjust marketing strategies for these brands. Or consider stopping the accessory business of these brands.

### **Q9. Which age group has the most buying behavior in installments?**
- SQL Code
```sql
SELECT
  YearOldRange
  ,COUNT(Bank) installments
  ,COUNT(*) total_orders
  ,ROUND(COUNT(Bank)/COUNT(*)*100.0,2) AS rate_installments
FROM
  `hackathon-446917.midterm_SQL.hackaton_phones_sales`
GROUP BY
  YearOldRange
ORDER BY
  rate_installments desc
;
```
Results:<br>
|YearOldRange|installments|total_orders|rate_installments|
|------------|------------|------------|-----------------|
|31-35       |1549        |19621       |7.89|
|Under 21     |218         |3175        |6.87|
|26-30       |3616        |56309       |6.42|
|21-25       |121         |1929        |6.27|
|Over 40     |119         |1911        |6.23|
|36-40       |759         |12361       |6.14|

**Conclusion**
- The 31-35 age group has the highest rate of installment usage at 7.89%, suggesting a preference for financing options.
- The Under 21 age group follows closely behind at 6.87%, indicating younger consumers may also rely on installment plans despite lower total orders.
- The 26-30 age group has the highest total orders (56,309), but a lower installment rate (6.42%), suggesting fewer users opt for financing compared to younger groups.

### **Q10: Find the phone company that is most commonly purchased in installments**
```sql
SELECT
  ProductBrand
  ,COUNT(Bank) installments
  ,COUNT(*) total_orders
  ,ROUND(COUNT(Bank)/COUNT(*)*100.0,2) AS rate_installments
FROM  
  `hackathon-446917.midterm_SQL.hackaton_phones_sales`
GROUP BY
  ProductBrand
ORDER BY 
  rate_installments desc
;
```
Results: <br>
|ProductBrand|installments|total_orders|rate_installments|
|------------|------------|------------|-----------------|
|APPLE IPHONE|169         |1318        |12.82|
|SONY        |586         |4642        |12.62|
|HTC         |323         |2987        |10.81|
|NOKIA       |1851        |17584       |10.53|
|LG          |283         |3155        |8.97|
|LENOVO      |355         |5410        |6.56|
|SAMSUNG     |2232        |34215       |6.52|
|BLACKBERRY  |4           |108         |3.7|
|Q-SMART     |464         |15531       |2.99|
|Mobiistar   |115         |8986        |1.28|
|Q-MOBILE    |0           |1332        |0.0              |
|F-MOBILE    |0           |13          |0.0              |
|HUAWEI      |0           |24          |0.0              |
|ALCATEL     |0           |1           |0.0              |


**Conclusion:** 
- Apple iPhone and Sony have the highest installment usage rates, at 12.82% and 12.62% respectively, despite having fewer total orders than brands like Nokia and Samsung.
- Nokia and HTC also show relatively high installment usage rates at 10.53% and 10.81%.
- Meanwhile, brands like Q-Smart, Mobistar, and Q-Mobile have significantly lower installment rates, indicating less reliance on financing options.



## 🔎IV. Conclusion 
👉🏻 Provide insight for store which brand have a highest revenue. These findings can inform decisions such as inventory management, marketing campaigns, personalized offering.\
👉🏻 The Phone and Accessories Sales analysis provides valuable insights into customer behavior, order trends, and revenue patterns.\
👉🏻 The project uncovers key metrics that aid in optimizing sales strategies and improving the shopping experience.
