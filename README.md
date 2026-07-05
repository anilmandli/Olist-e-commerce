# Olist E-Commerce Data Analysis

![Dashboard Preview](olist_e_commerce_dashboard.pdf)

## Project Overview

End-to-end data analytics project on the Olist Brazilian 
E-Commerce public dataset from Kaggle. This project covers 
the complete analytics workflow — from raw data loading and 
SQL analysis to interactive dashboard and Python visualization.

**Dataset:** Olist Brazilian E-Commerce Public Dataset (Kaggle)  
**Period:** 2016 – 2018  
**Scale:** 9 tables | 1.4M+ rows | 99,441 orders  
**Tools:** MySQL | Power BI | Python | Pandas | Plotly | Matplotlib

---

## Objective

To analyze customer behavior, sales trends, seller performance, 
and delivery patterns across Brazil — and translate data findings 
into actionable business recommendations.

**Core business questions answered:**
- Why do 96.88% of customers never return after their first order?
- Does delivery speed directly impact customer satisfaction?
- Which product categories and sellers drive the most revenue?
- Which regions in Brazil have the worst delivery performance?

---

## Project Structure

```
olist-ecommerce-analysis/
│
├── images/                          # Python charts and Recommendation page
│   ├── category_chart_6.png
│   ├── cohoer_retention_3.png
│   ├── customer_distribution_1.png
│   ├── installment_7.png
│   ├── monthly_revenue_5.png
│   ├── recommendation_on_olist.png
│   ├── review_vs_delivery_4.png
│   └── rfm_distribution_2.png
│
├── olist_analysis/                  # SQL query scripts
│   ├── sales_analysis.sql
│   ├── customer_analysis.sql
│   ├── seller_analysis.sql
│   ├── delivery_analysis.sql
│   ├── payment_analysis.sql
│   └── advance_matrix.sql
│
├── olist_analysis.ipynb             # Python visualizations notebook
├── olist_e_commerce_dashboard.pdf   # Power BI dashboard export
└── olist_query.pdf                  # SQL query showcase document
```

---

## Methodology

### Phase 1 — Data Setup (MySQL)
- Downloaded 9 CSV files from Kaggle
- Designed relational schema and created MySQL database
- Loaded all tables handling NULL values, encoding issues, 
  duplicate primary keys, and datetime formatting
- Verified row counts against expected dataset values

### Phase 2 — SQL Analysis (30+ Queries)
- Wrote queries across 5 analysis areas:
  sales, customers, sellers, delivery, and payments
- Used advanced SQL concepts including:
  window functions (LAG, LEAD, PERCENT_RANK),
  CTEs, subqueries, and multi-table joins
- Performed 5 advanced analyses:
  RFM segmentation, cohort retention, seller scorecard,
  product affinity, and delivery vs satisfaction correlation

### Phase 3 — Power BI Dashboard (6 Pages)
- Connected MySQL to Power BI
- Built DAX measures for calculated KPIs
- Designed 6-page interactive dashboard with:
  dynamic filtering, cross-page navigation, and drill-through
- Pages: Executive Summary | Sales | Customers | 
  Sellers | Delivery | Payments

### Phase 4 — Python Visualization (Jupyter Notebook)
- Exported SQL query results as CSV files
- Built 7 advanced charts using Matplotlib, Seaborn, and Plotly
- Charts: Brazil choropleth map, RFM segment distribution,
  cohort heatmap, delivery impact analysis, revenue trend,
  category bubble chart, payment installment distribution

---

## Key Findings

### Customer Retention Crisis
- 96.88% of customers placed only one order and never returned
- Only 2,997 out of 96,096 unique customers made repeat purchases
- Average customer lifetime value is just R$165.67
- Cohort analysis confirms retention collapses to under 0.5% 
  after the first month across all cohorts

### Delivery Drives Satisfaction
- On-time deliveries average 4.29 stars review score
- Very late deliveries (7+ days) average only 1.70 stars
- Positive review rate drops from 82.77% to 11.80% 
  when delivery is 7+ days late
- Delivery speed is the single biggest driver of 
  customer satisfaction on the platform

### Regional Delivery Gap
- Alagoas (AL) and Maranhão (MA) have late delivery rates 
  of 21.41% and 17.43% respectively
- São Paulo (SP) maintains only 4.49% late delivery rate 
  due to local warehouse infrastructure
- Remote northeastern states suffer the worst 
  shipping bottlenecks

### Seller Performance Concentration
- Top performing sellers are heavily concentrated in 
  São Paulo state
- 51.79% of sellers fall in average performer tier
- Only 8.29% reach top performer status
- Proximity to logistics infrastructure directly drives 
  both faster delivery and higher review scores

### Revenue and Sales Patterns
- Total revenue: R$15.84M across the dataset period
- Peak month: August 2018 with 11,200+ orders
- Health Beauty and Bed Bath Table are top categories 
  by both volume and revenue
- Credit card dominates payments at 73.92% usage with 
  average 3.51 installments per order

---

## Business Recommendations

1. **Fix Customer Retention**
   Launch a post-purchase email campaign within 7 days 
   targeting the 96.88% one-time customers. Even converting 
   5% to repeat buyers would significantly impact revenue.

2. **Improve Delivery in Remote States**
   Partner with local logistics providers in northeastern 
   states where late delivery exceeds 17-21% to directly 
   improve customer satisfaction scores.

3. **Reward High Performing Sellers**
   Create an incentive program rewarding sellers for fast 
   delivery and high review scores to grow quality supply 
   beyond the São Paulo concentration.

4. **Reduce Freight Costs on Bulky Categories**
   Home comfort, flowers, and furniture categories carry 
   shipping costs of 37-54% of product price. Negotiating 
   bulk freight rates would make these categories more 
   competitive.

---

## Dashboard

📊 **Interactive Power BI Dashboard:** [View Dashboard](https://drive.google.com/file/d/11Nj48oXJkPfrZ2AzVTIrTrXHi6Yw7BOJ/view?usp=sharing)

**Dashboard Pages:**

| Page | Description |
|------|-------------|
| Executive Summary | Overall KPIs and revenue trend |
| Sales Analysis | Monthly trends, heatmap, top categories |
| Customer Analysis | Retention, city distribution, Brazil map |
| Seller Analysis | Performance scorecard, revenue ranking |
| Delivery Analysis | Delay impact on review scores by state |
| Payment Analysis | Payment method and installment patterns |

---

## SQL Highlights

**Advanced queries written:**

| Query | Concepts Used |
|-------|--------------|
| Monthly Order Growth | LAG window function, CTEs |
| RFM Customer Segmentation | CASE, PERCENT_RANK, nested CTEs |
| Cohort Retention Analysis | DATE_FORMAT, PERIOD_DIFF, pivot |
| Seller Performance Scorecard | PERCENT_RANK, weighted scoring |
| Delivery vs Review Score | DATEDIFF, CASE bucketing, aggregation |
| Product Affinity Analysis | Self JOIN, COUNT, LIMIT |

---

## Python Visualizations

**Charts built in Jupyter Notebook:**

| Chart | Library | Insight |
|-------|---------|---------|
| Brazil Customer Map | Plotly | SP dominates with 41K+ customers |
| RFM Segment Distribution | Matplotlib | Most customers are regular or lost |
| Cohort Retention Heatmap | Seaborn | Retention under 0.5% after month 1 |
| Delivery vs Review | Matplotlib | Score drops 4.29 to 1.70 when late |
| Monthly Revenue Trend | Matplotlib | Peak August 2018, R$1.74M |
| Category Bubble Chart | Matplotlib | Health Beauty leads in volume |
| Payment Installments | Matplotlib | Credit card avg 3.51 installments |

---

## How to Run This Project

**Requirements:**
```
Python 3.8+
MySQL 8.0
Power BI Desktop (free)

Python libraries:
pip install pandas matplotlib seaborn plotly scipy kaleido
```

**Steps:**
1. Download the Olist dataset from Kaggle
2. Run SQL scripts in order from the olist_analysis folder
3. Open olist_analysis.ipynb in Jupyter Notebook
4. Export query results as CSV files to the project folder
5. Run all cells in the notebook

**Dataset link:**
https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

---

## Connect

**LinkedIn:** (https://www.linkedin.com/in/anil-mandli-aa24783b1/)
**GitHub:** (https://github.com/anilmandli/Olist-e-commerce)
