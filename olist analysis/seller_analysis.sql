-- Seller Analysis
-- 11. Top 10 sellers by revenue
select s.seller_id,
       s.seller_zip_code_prefix,
       s.seller_city,
       s.seller_state,
       sum(oi.price) as total_revenue
from sellers s
join order_items oi
     on s.seller_id = oi.seller_id
join orders o
     on oi.order_id = o.order_id
where o.order_status not in ('canceled','unavailable')
group by
    oi.seller_id,
    s.seller_zip_code_prefix,
    s.seller_city,
    s.seller_state
order by total_revenue desc
limit 10;

-- 12. Top 10 sellers by number of orders
select s.seller_id,
       s.seller_zip_code_prefix,
       s.seller_city,
       s.seller_state,
       count(distinct oi.order_id) as total_orders
from sellers s
join order_items oi
     on s.seller_id = oi.seller_id
join orders o
     on oi.order_id = o.order_id
where o.order_status not in ('canceled','unavailable')
group by
    s.seller_id,
    s.seller_zip_code_prefix,
    s.seller_city,
    s.seller_state
order by total_orders desc
limit 10;

-- 13 : Average seller rating
select s.seller_id,
       count(distinct o.order_id) as total_orders,
	   round(avg(ore.review_score),2)as avg_rating_out_of_5
from sellers s
join order_items oi
   on s.seller_id = oi.seller_id
join orders o
   on oi.order_id = o.order_id
join order_reviews ore 
   on o.order_id = ore.order_id
group by s.seller_id
order by total_orders desc,avg_rating_out_of_5 desc;

-- 14. Seller distribution by state
select
     s.seller_state,
     count(s.seller_id) as total_sellers,
     round((count(s.seller_id)/sum(count(s.seller_id)) over()) * 100.0, 2) as seller_dis_pct
from sellers s
group by s.seller_state
order by seller_dis_pct desc
;

-- 15. Average delivery time per seller

select 
     oi.seller_id,
     round(avg(datediff((o.order_delivered_customer_date),(o.order_purchase_timestamp) )),0) as avg_delivery_days
from order_items oi
join orders o
    on oi.order_id = o.order_id
where o.order_status = 'delivered' and o.order_delivered_customer_date is not null
group by oi.seller_id
order by avg_delivery_days
