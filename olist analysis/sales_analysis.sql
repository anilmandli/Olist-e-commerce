-- 1.Total revenue by year and month
select year(o.order_purchase_timestamp) as years,
	   month(o.order_purchase_timestamp) as month_no,
       monthname(o.order_purchase_timestamp) as month_name,
	   sum(oi.price) as total_revenue
from order_items oi
join orders o on oi.order_id = o.order_id
where o.order_status not in ('canceled','unavailable')
group by month_no,
         month_name,
		 years
order by years,
         month_no
;

-- 2. Average order value over time
select 
   YEAR(o.order_purchase_timestamp) AS years,
   MONTH(o.order_purchase_timestamp) AS month_no,
   MONTHNAME(o.order_purchase_timestamp) AS month_name,
   avg(x.total_value) as avg_value
from orders o
join (
 select 
     order_id,
     sum(price + freight_value) as total_value
 from order_items
 group by order_id
) as x on o.order_id = x.order_id
where o.order_status not in ('canceled','unavailable')
group by
    years,
	month_no,
    month_name
order by 
    years,
    month_no;

-- 3. Number of orders per month (growth trend)
with num_of_orders as (
     select 
          year(order_purchase_timestamp) as years,
          month(order_purchase_timestamp) as month_no,
	      monthname(order_purchase_timestamp) as month_name,
          count(*) as total_orders,
          sum(case when order_status = 'delivered' then 1 else 0 end) as successful_deliveries,
          lag(count(*),1,0) 
          over(order by year(order_purchase_timestamp),
                        month(order_purchase_timestamp)) as prev_mon_orders
from orders
group by 
  year(order_purchase_timestamp), 
  month(order_purchase_timestamp), 
  monthname(order_purchase_timestamp)
)
select n.*,
       (n.total_orders - n.prev_mon_orders) as growth_absolute,
       round(((n.total_orders - n.prev_mon_orders) / 
                 nullif(n.prev_mon_orders,0)) * 100, 2) as growth_pct
from num_of_orders n
order by 
     n.years,
     n.month_no;
     
-- 4. Revenue by product category
select
     t.product_category_name_english,
     p.product_category_name,
     sum(oi.price) as total_revenue
from products p
join order_items oi
    on p.product_id = oi.product_id
join orders o 
    on oi.order_id = o.order_id
join product_category_translation t 
    on p.product_category_name = t.product_category_name
where o.order_status not in ('canceled','unavailable')
group by p.product_category_name
order by total_revenue desc;


-- 5. Top 10 best selling products
select
     p.product_id,
     t.product_category_name_english as product_category,
     count(*) as units_sold,
     sum(oi.price) as total_revenue
from products p
join order_items oi
    on p.product_id = oi.product_id
join orders o 
    on oi.order_id = o.order_id
left join product_category_translation t 
    on p.product_category_name = t.product_category_name
where o.order_status not in ('canceled','unavailable')
group by p.product_id,product_category
order by units_sold desc
limit 10;

-- 6.Top 10 Products and Their Sellers

with top_10_products as (
   select
       oi.product_id,
       count(*) as total_units_sold
   from order_items oi
   join orders o
      on oi.order_id = o.order_id
	where o.order_status not in ('canceled','unavailable')
group by oi.product_id
order by total_units_sold desc
limit 10
)
select
    tp.product_id,
    tp.total_units_sold as product_overall_sales,
    oi.seller_id,
    s.seller_city,
    s.seller_state,
    count(*) as units_sold_by_this_seller,
    round((count(*) / tp.total_units_sold) * 100,2) as seller_marker_share_pct
from order_items oi
join orders o 
    on oi.order_id = o.order_id
join sellers s 
    on oi.seller_id = s.seller_id
join top_10_products tp 
    on oi.product_id = tp.product_id
where o.order_status not in ('canceled','unavailable')
group by 
    tp.product_id,
    tp.total_units_sold,
    oi.seller_id,
    s.seller_city,
    s.seller_state
order by
   tp.total_units_sold desc,
   units_sold_by_this_seller desc;
   
-- 7 Freight Cost Ratio by Product Category 
select
    t.product_category_name_english as category,
    round(avg(oi.freight_value), 2) as avg_freight_cost,
    round(avg(oi.price), 2) as avg_product_price,
    round(sum(oi.freight_value) / sum(oi.price) * 100, 2) as freight_pct_of_price
from order_items oi
join products p on oi.product_id = p.product_id
join product_category_translation t 
    on p.product_category_name = t.product_category_name
group by t.product_category_name_english
having count(*) >= 30
order by freight_pct_of_price desc
limit 10;
-- What were some interesting findings (highest revenue month, top product, etc.)?