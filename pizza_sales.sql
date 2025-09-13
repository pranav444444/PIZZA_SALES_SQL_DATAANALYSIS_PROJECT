create database pizzahut;

-- creating table "orders" as it has large number of records 
CREATE TABLE ORDERS
(
 order_id int NOT NULL,
 order_date date NOT NULL,
 order_time time NOT NULL,
 PRIMARY KEY(order_id)
 );
 -- rerun this particular line set global... after you close and open this server again.Don't forget to do this.
 SET GLOBAL local_infile = 1;

 LOAD DATA LOCAL INFILE "D:\\DATAANALYSIS_SQL project\\pizza_sales\\orders.csv" 
 INTO TABLE ORDERS
 FIELDS TERMINATED BY ','
 ENCLOSED BY '"'
 LINES TERMINATED BY '\r\n'
 IGNORE 1 ROWS;
 
-- creating table "order_details" as it has large number of records 
 
CREATE TABLE ORDER_DETAILS
(
 order_details_id int NOT NULL,
 order_id int NOT NULL,
 pizza_id text NOT NULL,
 quantity int NOT NULL,
 PRIMARY KEY(order_details_id)
 );
 
 LOAD DATA LOCAL INFILE "D:\\DATAANALYSIS_SQL project\\pizza_sales\\order_details.csv" 
 INTO TABLE ORDER_DETAILS
 FIELDS TERMINATED BY ','
 ENCLOSED BY '"'
 LINES TERMINATED BY '\r\n'
 IGNORE 1 ROWS;
 
 -- Q-1)Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;
 
 -- Q-2)Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id;
    
    -- Q-3)Identify the highest-priced pizza.
  SELECT 
    pt.name, p.price
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- Q-4)Identify the most common pizza size ordered.
SELECT 
    p.size, COUNT(od.order_details_id) AS orders
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY orders DESC
LIMIT 1;

-- Q-5) List the top 5 most ordered pizza types along with their quantities.(multiple joins)
SELECT 
    pt.name, SUM(od.quantity) AS quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY quantity DESC
LIMIT 5;

-- Q-6)Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pt.category, SUM(od.quantity) AS total_quantity
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_quantity DESC;

-- Q-7)Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS Hours, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY Hours;

-- Q-8) Find how much pizzas are there for each categories
SELECT 
    category, COUNT(name) AS pizzas
FROM
    pizza_types
GROUP BY category;

-- Q-9)Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0) AS average_quantity_perday
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS quantity
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.order_date) AS order_qauntity;
    
    -- Q-10)Determine the top 3 most ordered pizza types based on revenue.
    SELECT 
    pt.name, SUM((od.quantity * p.price)) AS total_revenue
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 3;

-- Q-11)Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pt.category,
    ROUND((SUM(od.quantity * p.price) / (SELECT 
                    SUM(od2.quantity * p2.price)
                FROM
                    order_details od2
                        JOIN
                    pizzas p2 ON od2.pizza_id = p2.pizza_id)) * 100,
            2) AS revenue_percent
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY revenue_percent DESC;

-- Q-12)Analyze the cumulative revenue generated over time.

select order_date,sum(total_revenue) over (order by order_date) as cum_revenue
from
(select o.order_date,sum((od.quantity*p.price)) as total_revenue
from orders o join order_details od
on o.order_id=od.order_id
join pizzas p
on od.pizza_id=p.pizza_id
group by o.order_date) as sales;

-- Q-13)Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category,name,total_revenue from
(select category ,name,total_revenue,
rank() over(partition by category order by total_revenue desc )as ran from 
(SELECT 
    pt.category,pt.name, SUM((od.quantity * p.price)) AS total_revenue
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category,pt.name) as A) as B where ran<=3;



    
 
 
 

 
 
 
 
 
 



 