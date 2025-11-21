USE FoodOrderingDB;

-- PROBLEM STATEMENT - 1 --
-- Top 5 highest-rated restaurants --
select restaurant_id, name, cuisine, rating, city from Restaurants
order by rating desc
limit 5;

-- PROBLEM STATEMENT - 2 --
-- Total revenue per restaurant --
SELECT r.restaurant_id, r.name,
    COALESCE(SUM(o.total_amount), 0) AS total_revenue
FROM Restaurants r
LEFT JOIN Orders o ON o.restaurant_id = r.restaurant_id
AND o.status = 'Delivered'
GROUP BY r.restaurant_id , r.name
ORDER BY total_revenue DESC;

-- PROBLEM STATEMENT - 3 --
-- Average order value (AOV) overall and per city --
select r.city , round(avg(o.total_amount),2) as avg_order_value
from Restaurants r
join Orders o on o.restaurant_id = r.restaurant_id 
where o.status = 'Delivered'
group by r.city;

-- PROBLEM STATEMENT - 4 --
-- Most-ordered menu items (top 10) --
select m.item_id, m.name, sum(oi.quantity) as total_quantity
from MenuItems m
left join OrderItems oi on oi.item_id = m.item_id
group by m.item_id, m.name
order by total_quantity desc
limit 10;

-- PROBLEM STATEMENT - 5 --
-- Customers with no orders --
select c.user_id, c.full_name, c.email
from Customers c
left join Orders o on o.user_id = c.user_id
where o.order_id is null;

-- PROBLEM STATEMENT - 6 --
-- Orders and their items (detailed invoice for a given order) --
select oi.order_id, m.name as item_name, oi.quantity, oi.price,
       (oi.quantity * oi.price) as line_total
from OrderItems oi
join MenuItems m on oi.item_id = m.item_id
where oi.order_id = 1;

-- PROBLEM STATEMENT - 7 --
-- Percentage of vegetarian menu items per restaurant --
select m.restaurant_id, r.name, 
Round(100.0 * sum(case
when m.is_veg then 1 else 0 end) / count(*), 2) as veg_percent
from MenuItems m
join Restaurants r on m.restaurant_id = r.restaurant_id
group by m.restaurant_id, r.name
order by veg_percent desc;

-- PROBLEM STATEMENT - 8 --
-- Daily order counts for a date range --
select date(order_time) as order_date, count(*) as order_count
from Orders
where order_time between '2025-01-10 12:30:00' AND '2025-02-10 23:59:59'
group by order_date
order by order_date;

-- PROBLEM STATEMENT - 9 --
-- Count of cancelled orders and cancellation rate --
select 
  sum(case 
  when status = 'Cancelled'
  then 1 else 0 end) as cancelled_count,
  count(*) as total_orders,
  round(100.0 * sum(case
  when status = 'Cancelled' 
  then 1 else 0 end) / count(*),2) as cancellation_rate_percent
from Orders;

-- PROBLEM STATEMENT - 10 --
-- Top customers by spend --
select c.user_id, c.full_name, 
coalesce(sum(o.total_amount),0) as total_spent
from Customers c
left join Orders o on c.user_id = o.user_id 
and o.status = 'Delivered'
group by c.user_id, c.full_name
order by total_spent DESC
limit 10;

-- PROBLEM STATEMENT - 11 --
-- Menu price distribution (buckets) --
select
  case
    when price <= 100 THEN '<=100'
    when price between 101 and 300 then '101-300'
    when price between 301 and 600 then '301-600'
    else '>600'
  end as price_bucket,
  count(*) as items_count
from MenuItems
group by price_bucket
order by MIN(price);

-- PROBLEM STATEMENT - 12 --
-- Find inconsistent orders (orders where sum of order items ≠ Orders.total_amount) --
select o.order_id, o.total_amount,
       coalesce(sum(oi.quantity * oi.price),0) as items_sum,
       (o.total_amount - coalesce(sum(oi.quantity * oi.price),0)) as difference
from Orders o
left join OrderItems oi on o.order_id = oi.order_id
group by o.order_id, o.total_amount
having coalesce(o.total_amount,0) <> coalesce(SUM(oi.quantity * oi.price),0);

-- PROBLEM STATEMENT - 13 --
-- Find orders placed at peak dinner hours (7–10 PM) --
select order_id, user_id, restaurant_id, order_time, total_amount
from Orders
where time(order_time) between '19:00:00' and '22:00:00';

