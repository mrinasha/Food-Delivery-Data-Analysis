use PRAC
--1. Find customers who have never ordered
--2. Average Price/dish
--3. Find the top restaurant in terms of the number of orders for a given month
--4. restaurants with monthly sales greater than x for 
--5. Show all orders with order details for a particular customer in a particular date range
--6. Find restaurants with max repeated customers 
--7. Month over month revenue growth of food delivery app
--8. Customer - favorite food
--9. Find the most loyal customers of all restaurants
--10.Month over month revenue growth of each restaurant
--11. Top 3 most paired products

select * from deliverypartner
select * from food
select * from menu
select*from orders
select * from orderdetails
select* from users
select* from restaurants

--find customers who have never ordered

select name from users
where user_id not in (select user_id from orders)


--2. Average Price/dish
select * from food
select * from menu

select f.f_name,f.type, round(avg(m.price),2) as avg_price
from food f
join menu m
on f.f_id=m.f_id
group by f.f_name,f.type
order by avg_price


--3. Find the top restaurant in terms of the number of orders for a given month

select distinct(r.r_name),r.cuisine,datepart(month, date) as months, count(o.order_id)  as ttl_orders
from restaurants r
join orders o
on  r.r_id=o.r_id
group by datepart(month, date) , r.r_name,r.cuisine
order by ttl_orders  DESC, months



--4. restaurants with monthly sales greater than 1000
--restaurants with monthly sales greater than 1000 for July

select distinct(r.r_name) as restaurant ,r.cuisine,datepart(month, date) as months, count(o.order_id)  as ttl_orders,
sum(o.amount) as revenue
from restaurants r
join orders o
on  r.r_id=o.r_id
group by  r.r_name,r.cuisine,datepart(month, date)
ORDER BY REVENUE desc


select distinct(r.r_name) as restaurant ,r.cuisine,datepart(month, o.date) as months,sum(o.amount) as ttl_revenue
from restaurants r
join orders o
on  r.r_id=o.r_id
where datepart(month, o.date)='7'
group by  r.r_name,r.cuisine,datepart(month, o.date)
having sum(o.amount)>1000



--5. Show all orders with order details for a particular customer in a particular date range

select convert(date,o.date,101) as orderdate,u.name as users,r.r_name as restaurant,f.f_name as food
from users u
join orders o
on u.user_id=o.user_id
join restaurants r
on r.r_id=o.r_id
join menu m
on r.r_id=m.r_id
join food f
on m.f_id=f.f_id
where u.name='Nitish' and 
date between  '2022-06-10' AND '2022-07-10'
order by orderdate


--7. Month over month revenue growth of food delivery app

  with cte as
  (
  select datepart(month, o.date) as month,
  sum(amount) as revenue,
  LAG(sum(amount)) over(order by  datepart(month, o.date)) preRevenue
  from orders o
  group by datepart(month, o.date)
 
  )
  select month, revenue, 
  round(((revenue-preRevenue)/preRevenue)*100,2)as 'mom revenue growth(%)' from cte
  


  --8. Customer - favorite food(IN GENERAL)
select * from food
select * from menu
select*from orders

select f.f_name as food, count(f.f_name) as count
from orders o
join menu m 
on o.r_id=m.r_id
join food f
on m.f_id=f.f_id
group by f.f_name
order by count DESC


--8. Customer - favorite food
with cte as
(
select u.name as Name,f.f_name as favourite_food, count(od.f_id) as orderCount,
rank() over(partition by u.name  order by count(od.f_id) DESC) as orderrank
from users u
join orders o
on u.user_id=o.user_id
join orderdetails od
on od.order_id=o.order_id
join menu m
on od.f_id=m.f_id
join food f
on m.f_id =f.f_id
group by u.name,f.f_name

)
select name, favourite_food, ordercount, orderrank
from cte
where orderrank =1
order by name,ordercount DESC



--9. Find the most loyal customers of all restaurants
--(defining that by most if the orders placed by a customer at a particular restaurant)

with cte as
(
select u.name as Name,r.r_name as restaurant, count(o.order_id) as ordercount,
rank() over(partition by r.r_name order by count(o.order_id) DESC) AS RANKS
from users u
join orders o
on u.user_id=o.user_id
join restaurants r
on o.r_id=r.r_id
group by u.user_id,u.name,r.r_name
--order by  restaurant , ordercount DESC
)
select name, restaurant, ordercount, ranks
from cte
where ranks=1
order by restaurant





--10.Month over month revenue growth of each restaurant

with cte as
(
SELECT
    datepart(month, o.date) as months,
    r.r_name as restaurant,
    sum(amount) as revenue,
    LAG(sum(amount)) OVER(PARTITION BY r.r_name ORDER BY datepart(month, o.date)) as preRevenue
FROM
    orders o
JOIN
    restaurants r
ON
    o.r_id = r.r_id
GROUP BY
    datepart(month, o.date),
    r.r_name
--ORDER BY
   -- r.r_name,
   -- DATEPART(month, o.date);
	)
select 
 restaurant, months, revenue,
 round((revenue-preRevenue)/ (prerevenue)*100,2) as 'mom revenue growth'
 from cte



 --11. Top 3 most paired products
select*from orders
select * from orderdetails
select * from food

SELECT 
   f1.f_name AS product1,
   f2.f_name AS product2,
   COUNT(o.order_id) AS pair_count
FROM
    orders o
JOIN 
    orderdetails od1 ON o.order_id = od1.order_id
JOIN 
    orderdetails od2 ON o.order_id = od2.order_id
JOIN
    food f1 ON f1.f_id = od1.f_id
JOIN
    food f2 ON f2.f_id = od2.f_id
WHERE
    od1.f_id < od2.f_id
GROUP BY
    f1.f_name, f2.f_name
	order by pair_count DESC





	WITH PairCounts AS (
    SELECT 
        f1.f_name AS product1,
        f2.f_name AS product2,
        COUNT(o.order_id) AS pair_count,
        RANK() OVER (ORDER BY COUNT(o.order_id) DESC) AS pair_rank
    FROM
        orders o
    JOIN 
        orderdetails od1 ON o.order_id = od1.order_id
    JOIN 
        orderdetails od2 ON o.order_id = od2.order_id
    JOIN
        food f1 ON f1.f_id = od1.f_id
    JOIN
        food f2 ON f2.f_id = od2.f_id
    WHERE
        od1.f_id < od2.f_id
    GROUP BY
        f1.f_name, f2.f_name
)
SELECT
    product1,
    product2,
    pair_count
FROM
    PairCounts
WHERE
    pair_rank <= 3;
