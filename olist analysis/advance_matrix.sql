-- 1. RFM Analysis (Customer Segmentation)
-- Segment customers into Champions, Loyal, At Risk, Lost based on Recency, Frequency, Monetary value
-- Recency 
with recency as (
select
       distinct c.customer_unique_id,
       max(o.order_purchase_timestamp) over(partition by c.customer_unique_id) as last_purchase_date,
	   last_value(o.order_purchase_timestamp) over(order by o.order_purchase_timestamp 
       rows between unbounded preceding and unbounded following) as last_purchase,
       datediff((last_value(o.order_purchase_timestamp) over(order by o.order_purchase_timestamp
       rows between unbounded preceding and unbounded following)),
       (max(o.order_purchase_timestamp) over(partition by c.customer_unique_id))) as days_ago
from customers c
join orders o
    on c.customer_id = o.customer_id
where o.order_status not in ('canceled','unavailable') 
)
select r.*,
      case
           when r.days_ago <=20 then 5
           when r.days_ago <=40 then 4
           when r.days_ago <=60 then 3
           when r.days_ago <=120 then 2
           else 1
           end as Recency_score
from recency r
order by Recency_score desc
;
-- Frequency

with frequency as (
select
    distinct c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    count(*) as total_orders
from customers c
join orders o
    on c.customer_id = o.customer_id
where o.order_status not in ('canceled','unavailable')  
  -- and o.order_purchase_timestamp
  -- between '2017-10-17 22:35:13' and '2018-10-17 17:30:18'
group by c.customer_unique_id,
         c.customer_city,
         c.customer_state
order by total_orders desc
)
select f.*,
    case 
       when f.total_orders > 5 then 5 
       when f.total_orders >= 4 then 4
       when f.total_orders >= 3 then 3
       when f.total_orders >= 2 then 2
       else 1
       end as Frequency_Score
from frequency f
;

-- Monetary
with Monetary as (
select 
    c.customer_unique_id,
    sum(oi.price + oi.freight_value) as total_spent
from customers c
join orders o
on c.customer_id = o.customer_id
join order_items oi
on o.order_id = oi.order_id
where o.order_status not in ('canceled', 'unavailable')
group by c.customer_unique_id
) 
select m.*,
case 
    when m.total_spent >= 10000 then 5
    when m.total_spent >= 6000 then 4
    when m.total_spent >= 3000 then 3
    when m.total_spent >= 1000 then 2
    else 1
    end as Monetary_Score
from monetary m
order by monetary_score desc
;
    
-- Final Query

with max_dataset_date as (
     select max(order_purchase_timestamp) as max_date from orders
),
 raw_rfm_metrics as (
	select
        c.customer_unique_id,
        datediff((SELECT max_date FROM max_dataset_date), MAX(o.order_purchase_timestamp)) AS raw_recency,
        COUNT(DISTINCT o.order_id) AS raw_frequency,
        SUM(oi.price + oi.freight_value) AS raw_monetary
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY c.customer_unique_id
),
rfm_scores AS (
     SELECT 
        customer_unique_id,
        raw_recency,
        raw_frequency,
        raw_monetary,
		CASE 
            WHEN raw_recency <= 30 THEN 5
            WHEN raw_recency <= 90 THEN 4
            WHEN raw_recency <= 180 THEN 3
            WHEN raw_recency <= 360 THEN 2
            ELSE 1 
        END AS R_score,
        CASE 
            WHEN raw_frequency >= 5 THEN 5
            WHEN raw_frequency >= 3 THEN 4
            WHEN raw_frequency = 2 THEN 3
            WHEN raw_frequency = 1 AND raw_monetary > 1500 THEN 2 
            ELSE 1 
		END AS F_score,
		CASE 
            WHEN raw_monetary >= 7500 THEN 5
            WHEN raw_monetary >= 5000 THEN 4
            WHEN raw_monetary >= 3000 THEN 3
            WHEN raw_monetary >= 1000 THEN 2
            ELSE 1 
        END AS M_score
    FROM raw_rfm_metrics
),
combined_rfm as (
     SELECT *,
        CONCAT(R_score, F_score, M_score) AS rfm_code
    FROM rfm_scores
)
SELECT 
    customer_unique_id,
    raw_recency AS days_since_last_order,
    raw_frequency AS total_orders,
    ROUND(raw_monetary, 2) AS lifetime_spend,
    rfm_code,
    CASE 
        WHEN rfm_code IN ('555', '554', '545', '455', '454', '544') THEN 'Champions'
        WHEN rfm_code LIKE '5__' OR rfm_code LIKE '4__' AND (F_score >= 3 OR M_score >= 3) THEN 'Loyal Customers'
        WHEN R_score = 1 AND F_score >= 4 AND M_score >= 4 THEN 'Cant Lose Them'
        WHEN rfm_code IN ('311', '322', '312', '321') THEN 'About to Sleep'
        WHEN rfm_code IN ('111', '112', '121', '122', '211') THEN 'Lost / Hibernating'
        ELSE 'Regular Customers'
    END AS customer_segment
FROM combined_rfm
order by rfm_code desc
;

-- 2. Cohort Analysis
-- Track retention of customers who first purchased in the same month

-- select
--      concat(monthname(o.order_purchase_timestamp),
--      year(o.order_purchase_timestamp)) as cohort_month,
--      count(distinct c.customer_unique_id) as new_customers
-- from customers c
-- join orders o
--    on c.customer_id = o.customer_id
-- group by cohort_month;

WITH customer_first_purchase AS (
SELECT 
    c.customer_unique_id,
    min(date_format(o.order_purchase_timestamp, '%y-%m-01')) as cohort_month
from customers c
join orders o on c.customer_id = o.customer_id
where o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY c.customer_unique_id
),
 cohort_sizes as (
  select 
     cohort_month,
     count(distinct customer_unique_id) as cohort_size
from customer_first_purchase
group by cohort_month
),
customer_activities as (
 select
     fp.cohort_month,
     c.customer_unique_id,
     period_diff(
       DATE_FORMAT(o.order_purchase_timestamp, '%Y%m'), 
	   DATE_FORMAT(fp.cohort_month, '%Y%m')
     ) as month_number
  from customers c 
  join orders o 
      on c.customer_id = o.customer_id
  join customer_first_purchase fp 
      on c.customer_unique_id = fp.customer_unique_id
where o.order_status not in ('canceled','unavailable')
),
cohort_retention as (
   select
       ca.cohort_month,
       cs.cohort_size,
       ca.month_number,
       count(distinct ca.customer_unique_id) as active_customers
   from customer_activities ca
   join cohort_sizes cs 
        on ca.cohort_month = cs.cohort_month
	group by ca.cohort_month, cs.cohort_size,ca.month_number
)
select
   date_format(cohort_month, '%b %y') as `Cohort Month`,
   cohort_size as `Size (New Users)`,
   '100%' as `Month 0`,
    CONCAT(ROUND((SUM(CASE WHEN month_number = 1 THEN active_customers ELSE 0 END) / cohort_size) * 100, 1), '%') AS `Month 1`,
    CONCAT(ROUND((SUM(CASE WHEN month_number = 2 THEN active_customers ELSE 0 END) / cohort_size) * 100, 1), '%') AS `Month 2`,
    CONCAT(ROUND((SUM(CASE WHEN month_number = 3 THEN active_customers ELSE 0 END) / cohort_size) * 100, 1), '%') AS `Month 3`,
    CONCAT(ROUND((SUM(CASE WHEN month_number = 4 THEN active_customers ELSE 0 END) / cohort_size) * 100, 1), '%') AS `Month 4`
from cohort_retention
group by cohort_month, cohort_size
order by cohort_month ;
   
-- 3. Product Affinity / Cross-sell Analysis
-- Which products are frequently bought together in the same order
WITH product_pairs AS (
    SELECT
        o1.product_id AS product_a,
        o2.product_id AS product_b,
        COUNT(*) AS times_bought_together
    FROM order_items o1
    JOIN order_items o2 
        ON o1.order_id = o2.order_id 
        AND o1.product_id < o2.product_id 
    GROUP BY o1.product_id, o2.product_id
)
SELECT 
    pp.times_bought_together,
    pp.product_a,
    t1.product_category_name_english AS category_product_a,
    pp.product_b,
    t2.product_category_name_english AS category_product_b
FROM product_pairs pp
JOIN products p1 ON pp.product_a = p1.product_id
LEFT JOIN product_category_translation t1 ON p1.product_category_name = t1.product_category_name
JOIN products p2 ON pp.product_b = p2.product_id
LEFT JOIN product_category_translation t2 ON p2.product_category_name = t2.product_category_name
ORDER BY pp.times_bought_together DESC
LIMIT 10;

-- 4. Seller Performance Scorecard
-- Rank sellers by combining revenue, delivery time, review score, and order count into one score
WITH seller_order_aggregates AS (
    SELECT 
        seller_id,
        order_id,
        SUM(price + freight_value) AS order_value
    FROM order_items
    GROUP BY seller_id, order_id
),
seller_metrics AS (
    SELECT
        s.seller_id,
        s.seller_city,
        s.seller_state,
        COUNT(DISTINCT o.order_id) AS total_orders,
        ROUND(SUM(soa.order_value), 2) AS total_revenue,
        ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 2) AS avg_delivery_days,
        ROUND(AVG(r.review_score), 2) AS avg_review_score
    FROM sellers s
    JOIN seller_order_aggregates soa ON s.seller_id = soa.seller_id
    JOIN orders o ON soa.order_id = o.order_id
    JOIN order_reviews r ON o.order_id = r.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
    GROUP BY s.seller_id, s.seller_city, s.seller_state
    -- HAVING total_orders >= 10 
),
seller_ranked AS (
   
    SELECT *,
        PERCENT_RANK() OVER (ORDER BY total_revenue ASC) AS revenue_rank,      
        PERCENT_RANK() OVER (ORDER BY avg_delivery_days DESC) AS delivery_rank, 
        PERCENT_RANK() OVER (ORDER BY avg_review_score ASC) AS review_rank      
    FROM seller_metrics
)
SELECT
    seller_id,
    seller_city,
    seller_state,
    total_orders,
    total_revenue,
    avg_delivery_days,
    avg_review_score,
    ROUND((revenue_rank * 0.4) + (delivery_rank * 0.3) + (review_rank * 0.3), 4) AS performance_score,
    CASE
        WHEN (revenue_rank * 0.4 + delivery_rank * 0.3 + review_rank * 0.3) >= 0.75 THEN 'Top Performer'
        WHEN (revenue_rank * 0.4 + delivery_rank * 0.3 + review_rank * 0.3) >= 0.50 THEN 'Average Performer'
        WHEN (revenue_rank * 0.4 + delivery_rank * 0.3 + review_rank * 0.3) >= 0.25 THEN 'Below Average'
        ELSE 'Poor Performer'
    END AS performance_tier
FROM seller_ranked
ORDER BY performance_score DESC;

-- 5. Delivery Performance vs Review Score
-- Does late delivery directly cause lower review scores? Prove it with data
WITH delivery_sentiment_matrix AS (
    SELECT
        o.order_id,
        r.review_score,
        DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp) AS actual_delivery_days,
        DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) AS delivery_delay_days,
        -- Categorize shipping windows clearly based on consumer expectation buffers
        CASE
            WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date 
                 THEN 'On Time / Early'
            WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) <= 3 
                 THEN 'Slightly Late (1-3 days)'
            WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) <= 7 
                 THEN 'Late (4-7 days)'
            ELSE 'Very Late (7+ days)'
        END AS delivery_status
    FROM orders o
    JOIN order_reviews r ON o.order_id = r.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
)
SELECT
    delivery_status,
    COUNT(*) AS total_orders,
    ROUND(AVG(review_score), 2) AS avg_review_score,
    ROUND(AVG(actual_delivery_days), 2) AS avg_actual_days,
    ROUND(AVG(delivery_delay_days), 2) AS avg_delay_days,
    SUM(CASE WHEN review_score >= 4 THEN 1 ELSE 0 END) AS positive_reviews,
    SUM(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END) AS negative_reviews,
    ROUND((SUM(CASE WHEN review_score >= 4 THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS positive_review_pct
FROM delivery_sentiment_matrix
GROUP BY delivery_status
ORDER BY avg_delay_days ASC;

