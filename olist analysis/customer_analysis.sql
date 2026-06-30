-- 6. Total unique customers by state
select
	customer_state,
    count(distinct(customer_unique_id)) as total_customer
from customers
group by customer_state
order by total_customer desc;

-- 7. Repeat customers vs one time customers
--        2997         vs       93099
-- one time customers
select count(*) from (
select
    customer_unique_id,
    count(*) as log_in
from customers
group by customer_unique_id
having log_in = 1
) as x;
-- repeat customers
select count(*) from (
select
    customer_unique_id,
    count(*) as log_in
from customers
group by customer_unique_id
having log_in > 1
) as x;


-- combine answer
with customer_order_counts as (
select
     customer_unique_id,
     count(*) as total_orders
from customers
group by customer_unique_id
)
select
    sum(case when total_orders = 1 then 1 else 0 end) as one_time_customers,
    round((sum(case when total_orders = 1 then 1 else 0 end) / count(*)) * 100, 2) as one_time_pct,
    sum(case when total_orders > 1 then 1 else 0 end) as repeat_customers,
    round((sum(case when total_orders > 1 then 1 else 0 end) / count(*)) * 100, 2) as repeat_pct,
    count(*) as total_customers
from customer_order_counts;
-- INSIGHT : Olist has a severe customer retention problem.

-- 8. Average customer spending  "Average Customer Spending"(also known as Customer Lifetime Value or CLV)
with customer_liftime_spend as(
select 
    c.customer_unique_id,
    sum(oi.price + oi.freight_value) as total_spent_by_customer
from customers c
join orders o
on c.customer_id = o.customer_id
join order_items oi
on o.order_id = oi.order_id
where o.order_status not in ('canceled', 'unavailable')
group by c.customer_unique_id

)
select
    round(avg(total_spent_by_customer),2) as avg_customer_liftime_spending
from customer_liftime_spend;

-- 9. Customer distribution by city
select
    customer_city,
    count(distinct customer_unique_id) as total_customers,
    round((count(distinct customer_unique_id) / sum(count(distinct customer_unique_id)) over())*100,2) as customer_pct_share
from customers 
group by customer_city
order by total_customers desc;

-- 10. Time between first and second purchase

with customer_purchase_timeline as (
    select
        c.customer_unique_id,
        o.order_purchase_timestamp as first_purchase_date,
        lead(o.order_purchase_timestamp) over (
            PARTITION BY c.customer_unique_id 
            ORDER BY o.order_purchase_timestamp
        ) AS second_purchase_date,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_unique_id 
            ORDER BY o.order_purchase_timestamp
        ) AS purchase_rank
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
)
SELECT 
    customer_unique_id,
    first_purchase_date,
    second_purchase_date,
    DATEDIFF(second_purchase_date, first_purchase_date) AS days_between_purchases
FROM customer_purchase_timeline
WHERE purchase_rank = 1 
  AND second_purchase_date IS NOT NULL; 

-- Did all these run without errors?
-- What were the key findings? (e.g., which state has most customers? What's the average days between repeat purchases? Which city dominates?)
-- How many customers actually made a second purchase (non-NULL in query 10)?

     