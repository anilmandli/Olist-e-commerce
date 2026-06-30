-- Payment Analysis
-- 20. Most used payment methods
select
    payment_type,
    count(*) as total_used_method
from order_payments
join orders o
    on order_payments.order_id = o.order_id
where order_status not in ('canceled','unavailable')
group by payment_type;

-- 21. Average installments per order
select 
        round(avg(x.total),1) as avg_installments
from (select
   order_id,
   max(payment_installments) as total
   from 
   order_payments
   group by order_id
) as x;

-- 22. Revenue by payment type
select 
     op.payment_type,
     sum(op.payment_value) as total_revenue
from order_payments op
join orders o
    on op.order_id = o.order_id
where o.order_status not in ('canceled','unavailable')
group by op.payment_type
;

WITH payment_ratios AS (
    -- Step 1: Find the total payment value and split ratios per order
    SELECT 
        order_id,
        payment_type,
        payment_value,
        SUM(payment_value) OVER(PARTITION BY order_id) AS total_order_checkout,
        payment_value / NULLIF(SUM(payment_value) OVER(PARTITION BY order_id), 0) AS payment_share_ratio
    FROM order_payments
),
item_totals AS (
    -- Step 2: Get clean product-only revenue per order
    SELECT 
        order_id,
        SUM(price) AS pure_product_revenue
    FROM order_items
    GROUP BY order_id
)
-- Step 3: Multiply the payment split ratio by the product-only revenue
SELECT 
    pr.payment_type,
    ROUND(SUM(pr.payment_share_ratio * it.pure_product_revenue), 2) AS split_product_revenue
FROM payment_ratios pr
JOIN item_totals it ON pr.order_id = it.order_id
JOIN orders o ON pr.order_id = o.order_id
WHERE o.order_status NOT IN ('canceled','unavailable')
GROUP BY pr.payment_type
ORDER BY split_product_revenue DESC;

-- Review Analysis
-- 23. Average review score by category
SELECT
   t.product_category_name_english AS product_category,
   ROUND(AVG(ore.review_score), 1) AS avg_review_score
FROM order_reviews ore
JOIN order_items oi ON ore.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN product_category_translation t ON p.product_category_name = t.product_category_name
GROUP BY t.product_category_name_english
ORDER BY avg_review_score DESC;

-- 24. Distribution of review scores (1 to 5)
select
 count(*) as total_review,
 sum(case when review_score = 1 then 1 else 0 end) as score_1,
 round((sum(case when review_score = 1 then 1 else 0 end)/count(*))*100,2) as score_1_pct,
 sum(case when review_score = 2 then 1 else 0 end) as score_2,
 round((sum(case when review_score = 2 then 1 else 0 end)/count(*))*100,2) as score_2_pct,
 sum(case when review_score = 3 then 1 else 0 end) as score_3,
 round((sum(case when review_score = 3 then 1 else 0 end)/count(*))*100,2) as score_3_pct,
 sum(case when review_score = 4 then 1 else 0 end) as score_4,
 round((sum(case when review_score = 4 then 1 else 0 end)/count(*))*100,2) as score_4_pct,
 sum(case when review_score = 5 then 1 else 0 end) as score_5,
 round((sum(case when review_score = 5 then 1 else 0 end)/count(*))*100,2) as score_5_pct
from 
order_reviews;
-- Business Insight:"U-Shape" distribution. E-commerce platforms usually see a lot of 5-star reviews (happy customers) 
-- and a sudden spike in 1-star reviews (angry customers), with very few 2, 3, or 4-star choices in between.

-- 25. Correlation between delivery time and review score
     
SELECT 
    CASE 
        WHEN DATEDIFF(o.order_estimated_delivery_date, o.order_delivered_customer_date) >= 0 THEN 'On-Time / Early'
        ELSE 'Delivered Late'
    END AS delivery_status,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(AVG(ore.review_score), 2) AS average_customer_rating,
    -- Tracks what % of these orders suffered from a terrible 1-Star rating
    ROUND((SUM(CASE WHEN ore.review_score = 1 THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS 1_star_rate_pct
FROM orders o
JOIN order_reviews ore ON o.order_id = ore.order_id
WHERE o.order_status = 'delivered' 
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY 1;


    