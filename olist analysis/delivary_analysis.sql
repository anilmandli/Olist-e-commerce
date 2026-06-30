-- Delivery Analysis
-- 16. Average delivery time by state

select
   c.customer_state,
   round(avg(datediff((o.order_delivered_customer_date),(o.order_purchase_timestamp) )),0) as avg_delivery_days
from customers c
join orders o
      on c.customer_id = o.customer_id
where o.order_status = 'delivered' and o.order_delivered_customer_date is not null
group by c.customer_state
order by avg_delivery_days;

-- 17. Orders delivered late vs on time

select 
     count(*) as total_orders,
	 sum(case when datediff(order_estimated_delivery_date, order_delivered_customer_date ) >= 0 then 1 else 0 end) as on_time,
     round((sum(case when datediff(order_estimated_delivery_date, order_delivered_customer_date ) >= 0 then 1 else 0 end)/count(*))*100 ,2) as on_time_delivered_pct,
     sum(case when datediff(order_estimated_delivery_date, order_delivered_customer_date ) < 0  then 1 else 0 end) as delivered_late,
     round((sum(case when datediff(order_estimated_delivery_date, order_delivered_customer_date ) < 0 then 1 else 0 end)/count(*))*100 ,2) as late_delivered_pct
from orders
where order_status = 'delivered' and order_delivered_customer_date is not null;

-- 18  Difference between estimated and actual delivery date
select
     count(*) as total_delivered_orders,
     sum(case when datediff(order_estimated_delivery_date, order_delivered_customer_date) > 0 then 1 else 0 end) as arrived_early,
     sum(case when datediff(order_estimated_delivery_date, order_delivered_customer_date)  = 0 then 1 else 0 end ) as on_time,
     sum(case when datediff(order_estimated_delivery_date, order_delivered_customer_date) <  0 then 1 else 0 end ) as arrived_late
from orders 
where order_status = 'delivered' and order_delivered_customer_date is not null;

-- 19 Fastest and slowest delivering states
select
    c.customer_state as state,
    count(*) as total_delivered_orders,
     sum(case when datediff(order_estimated_delivery_date, order_delivered_customer_date) > 0 then 1 else 0 end) as arrived_early,
     sum(case when datediff(order_estimated_delivery_date, order_delivered_customer_date)  = 0 then 1 else 0 end ) as on_time,
     sum(case when datediff(order_estimated_delivery_date, order_delivered_customer_date) <  0 then 1 else 0 end ) as arrived_late,
     round((sum(case when datediff(order_estimated_delivery_date, order_delivered_customer_date) <  0 then 1 else 0 end ) / count(*))* 100,2) as late_delivered_pct
from orders 
join customers c
     on orders.customer_id = c.customer_id
where order_status = 'delivered' and order_delivered_customer_date is not null
group by c.customer_state
order by late_delivered_pct desc;

-- INSIGHT : 
-- The Regional Gap: Remote North/Northeastern states like AL (Alagoas) and MA (Maranhão) 
-- suffer from the worst shipping bottlenecks, with over 17% to 21% of orders arriving late.
    
-- The Fulfillment Center Advantage: SP (São Paulo) dominates the platform with over 40,000 orders,
-- maintaining a highly efficient late delivery rate of only 4.49% due to its local warehouse infrastructure.