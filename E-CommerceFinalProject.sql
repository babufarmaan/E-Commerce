create database if not exists e_commerece;
use e_commerece;
select * from customers;
select * from orderdetails;
select * from orders;
select * from products;
alter table customers
-- data cleaning part
rename column `ï»¿customer_id` to `customer_id`;
alter table orderdetails
rename column `ï»¿order_id` to `order_id`;
alter table orders
rename column `ï»¿` to `order_id`;
alter table products
rename column `ï»¿product_id` to `product_id`;

-- describe 
describe customers;
describe orderdetails;
describe orders;
describe products;

-- Identify the top 3 cities with the highest number of customers
-- to determine key markets for targeted marketing and logistic optimization

select location,count(location) as counting from customers
group by location 
order by counting desc
limit 3;
-- delhi ,chennai,jaipur is good for marketing 


-- Determine the distribution of customers by the number of orders placed. This
-- insight will help in segmenting customers into one-time buyers, occasional
-- shoppers, and regular customers for tailored marketing strategies.
select * from orders;
with helper as(
select customer_id, count(order_id) no_of_orders from orders
group by customer_id 
order by no_of_orders
)
select no_of_orders as numberofOrders , count(customer_id) as customercount from helper
group by no_of_orders;

-- Identify products where the average purchase quantity per order is 2 but with a high total revenue,
-- suggesting premium product trends.
select * from orderdetails;
with helper as (
select product_id , avg(Quantity) as  AvgQuantity , sum(Quantity*price_per_unit) as  TotalRevenue 
from orderdetails
group by product_id
)
select product_id , avgquantity , totalRevenue
from helper
where avgquantity = 2 
order by totalRevenue desc;


select * from products;




-- For each product category, calculate the unique number of customers purchasing from it.
--  This will help understand which categories have wider appeal across the customer base.
WITH category_customers AS (
  SELECT
    p.category AS Category,
    od.order_id,
    o.customer_id
  FROM OrderDetails od
  JOIN Products p ON od.product_id = p.product_id
  JOIN Orders o ON od.order_id = o.order_id
)
SELECT
  Category,
  COUNT(DISTINCT customer_id) AS UniqueCustomers
FROM category_customers
GROUP BY Category
ORDER BY UniqueCustomers DESC;
-- Analyze the month-on-month percentage change in total sales to identify growth trends.
select * from orders;
with helper as(
select date_format(order_date , '%Y-%m') as month , sum(total_amount) as totalsales from orders
group by month
order by month asc 
) ,helper2 as (
select month , totalsales , lag(totalsales)over() as previous_m_s from helper)
select month ,totalSales, (((totalsales-previous_m_s)/previous_m_s)*100.0) as percentchange from helper2;

-- List products purchased by less than 40% of the customer base,
-- indicating potential mismatches between inventory and customer interest.
WITH total_customers AS (
  SELECT COUNT(*) AS total_cust
  FROM Customers
),
product_customer_counts AS (
  SELECT
    p.product_id,
    p.name,
    COUNT(DISTINCT o.customer_id) AS uniquecustomercount
  FROM Products p
  JOIN OrderDetails od ON od.product_id = p.product_id
  JOIN Orders o ON o.order_id = od.order_id
  GROUP BY p.product_id, p.name
)
SELECT
  pcc.product_id,
  pcc.name,
  pcc.uniquecustomercount
FROM product_customer_counts pcc
JOIN total_customers tc ON 1=1
WHERE pcc.uniquecustomercount * 100.0 / tc.total_cust < 40.0;






select * from orders;
with helper as(
select  min(date_format(order_Date,'%Y-%m')) as mini ,customer_id from orders
group by customer_id
order by mini
)
select mini as firstPurchaseMonth , count(customer_id) as TotalNewCustomers
 from helper
 group by firstpurchaseMonth
 order by firstpurchaseMonth;
 -- Identify the months with the highest sales volume, aiding in planning for stock levels,
 -- marketing efforts, and staffing in anticipation of peak demand periods.
 -- select * from orders;
select date_format(order_Date , '%Y-%m') as month , sum(total_amount) as totalSales from
orders
group by month
order by totalSales desc
limit 3;