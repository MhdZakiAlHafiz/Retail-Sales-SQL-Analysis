# 🛒 Retail Sales Analysis with PostgreSQL

> An end-to-end SQL analytics project focused on retail sales exploration, data cleaning, business analysis, customer behavior, profitability, and time-based sales trends using PostgreSQL.

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-17-336791?style=for-the-badge&logo=postgresql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Data%20Analytics-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Data Analysis](https://img.shields.io/badge/Data%20Analysis-EDA-orange?style=for-the-badge)

---

## 📌 Project Overview

This project analyzes a retail sales dataset using **PostgreSQL** to transform raw transaction data into meaningful business insights.

The analysis covers the complete analytical workflow, starting from database and table creation, data quality checks, missing-value identification, exploratory data analysis, and basic business questions to more advanced analytical techniques.

The project demonstrates practical SQL skills including:

- Data cleaning and validation
- Aggregation and grouping
- Filtering and conditional logic
- Common Table Expressions (CTEs)
- Window Functions
- Ranking
- Customer segmentation
- Time-based analysis
- Month-over-Month (MoM) revenue analysis
- Profitability analysis
- Average Order Value (AOV) analysis

The primary objective is to demonstrate how SQL can be used not only to retrieve data, but also to answer business questions and generate actionable insights.

---

## 🎯 Business Objectives

This project aims to answer several key business questions:

1. How many transactions are available after data cleaning?
2. How many unique customers are represented in the dataset?
3. Which product categories generate the most revenue?
4. Which category has the highest gross profit margin?
5. What is the average customer age for Beauty purchases?
6. Which customers generate the highest total spending?
7. Which time period has the highest transaction volume?
8. Which months show significant revenue growth or decline?
9. How does customer purchasing behavior differ across categories?
10. What is the Average Order Value (AOV) for each category?
11. How can customers be segmented based on purchase frequency?

---

# 🗄️ Dataset & Database

### Database

- **Database Management System:** PostgreSQL
- **Table:** `retail_sales`

### Table Schema

| Column | Data Type | Description |
|---|---|---|
| `transactions_id` | `INT` | Unique transaction identifier |
| `sale_date` | `DATE` | Transaction date |
| `sale_time` | `TIME` | Transaction time |
| `customer_id` | `INT` | Customer identifier |
| `gender` | `VARCHAR(15)` | Customer gender |
| `age` | `INT` | Customer age |
| `category` | `VARCHAR(100)` | Product category |
| `quantity` | `INT` | Number of items purchased |
| `price_per_unit` | `NUMERIC` | Price per unit |
| `cogs` | `NUMERIC` | Cost of goods sold |
| `total_sale` | `NUMERIC` | Total transaction value |

### Product Categories

The dataset contains three main product categories:

- 🖥️ Electronics
- 👕 Clothing
- 💄 Beauty

---

# 🧹 1. Database Setup & Data Cleaning

## Table Creation

The `retail_sales` table was created using appropriate PostgreSQL data types, including `NUMERIC` for financial values.

```sql
DROP TABLE IF EXISTS retail_sales;

CREATE TABLE retail_sales (
    transactions_id INT PRIMARY KEY,
    sale_date DATE,
    sale_time TIME,
    customer_id INT,
    gender VARCHAR(15),
    age INT,
    category VARCHAR(100),
    quantity INT,
    price_per_unit NUMERIC,
    cogs NUMERIC,
    total_sale NUMERIC
);
```

## Initial Data Validation

The raw dataset contained:

**2,000 rows**

```sql
SELECT COUNT(*) AS total_raw_data
FROM retail_sales;
```

After checking the dataset for missing values, **13 records containing NULL values** were identified.

```sql
SELECT *
FROM retail_sales
WHERE 
    transactions_id IS NULL
    OR sale_date IS NULL
    OR sale_time IS NULL
    OR customer_id IS NULL
    OR gender IS NULL
    OR age IS NULL
    OR category IS NULL
    OR quantity IS NULL
    OR price_per_unit IS NULL
    OR cogs IS NULL
    OR total_sale IS NULL;
```

The incomplete records were removed before conducting the main analysis.

```sql
DELETE FROM retail_sales
WHERE 
    transactions_id IS NULL
    OR sale_date IS NULL
    OR sale_time IS NULL
    OR customer_id IS NULL
    OR gender IS NULL
    OR age IS NULL
    OR category IS NULL
    OR quantity IS NULL
    OR price_per_unit IS NULL
    OR cogs IS NULL
    OR total_sale IS NULL;
```

### Clean Dataset

After cleaning:

- **2,000** raw records
- **13** records with missing values
- **1,987** valid transactions
- **155** unique customers
- **3** product categories

---

# 📊 2. Exploratory Data Analysis

## Total Transactions

```sql
SELECT COUNT(*) AS total_sales
FROM retail_sales;
```

**Result:**

> **1,987 transactions**

---

## Unique Customers

```sql
SELECT COUNT(DISTINCT customer_id) AS total_unique_customers
FROM retail_sales;
```

**Result:**

> **155 unique customers**

---

## Available Product Categories

```sql
SELECT DISTINCT category
FROM retail_sales;
```

**Categories:**

- Beauty
- Clothing
- Electronics

---

# 📈 3. Foundational Business Analysis

## Q1. Sales on a Specific Date

Retrieve all transactions that occurred on November 5, 2022.

```sql
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';
```

This query demonstrates date-based filtering for transaction-level analysis.

---

## Q2. High-Quantity Clothing Sales in November 2022

```sql
SELECT *
FROM retail_sales
WHERE 
    category = 'Clothing'
    AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
    AND quantity >= 4;
```

This identifies high-volume Clothing transactions during November 2022.

---

## Q3. Revenue and Transaction Volume by Category

```sql
SELECT 
    category,
    SUM(total_sale) AS net_sale,
    COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category
ORDER BY net_sale DESC;
```

### Result

| Category | Revenue | Orders |
|---|---:|---:|
| Electronics | 311,445 | 678 |
| Clothing | 309,995 | 698 |
| Beauty | 286,790 | 611 |

### Insight

**Electronics** generated the highest total revenue at **311,445**, while **Clothing** recorded the highest number of transactions with **698 orders**.

---

## Q4. Average Age of Beauty Customers

```sql
SELECT
    ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';
```

### Result

> **Average age: 40.42 years**

---

## Q5. High-Value Transactions

Find transactions with a total sale greater than 1,000.

```sql
SELECT *
FROM retail_sales
WHERE total_sale > 1000;
```

This query can be used to identify high-value individual transactions.

---

## Q6. Transactions by Gender and Category

```sql
SELECT 
    category,
    gender,
    COUNT(*) AS total_trans
FROM retail_sales
GROUP BY category, gender
ORDER BY category;
```

### Result

| Category | Gender | Transactions |
|---|---|---:|
| Beauty | Female | 330 |
| Beauty | Male | 281 |
| Clothing | Female | 347 |
| Clothing | Male | 351 |
| Electronics | Male | 343 |
| Electronics | Female | 335 |

This provides a breakdown of transaction volume across product categories and customer gender.

---

# 📅 4. Time-Based Sales Analysis

## Q7. Highest Average Sales Month by Year

This analysis uses a **CTE** and the **RANK() window function** to identify the month with the highest average transaction value in each year.

```sql
WITH MonthlyAverage AS (
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        AVG(total_sale) AS avg_sale,
        RANK() OVER (
            PARTITION BY EXTRACT(YEAR FROM sale_date)
            ORDER BY AVG(total_sale) DESC
        ) AS rank
    FROM retail_sales
    GROUP BY 1, 2
)
SELECT 
    year,
    month,
    ROUND(avg_sale, 2) AS top_avg_sale
FROM MonthlyAverage
WHERE rank = 1;
```

### Result

| Year | Month | Average Sale |
|---:|---:|---:|
| 2022 | July | 541.34 |
| 2023 | February | 535.53 |

---

## Q8. Top 5 Customers by Total Spending

```sql
SELECT 
    customer_id,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;
```

### Result

| Rank | Customer ID | Total Spending |
|---:|---:|---:|
| 1 | 3 | 38,440 |
| 2 | 1 | 30,750 |
| 3 | 5 | 30,405 |
| 4 | 2 | 25,295 |
| 5 | 4 | 23,580 |

This analysis helps identify high-value customers based on cumulative spending.

---

## Q9. Unique Customers by Product Category

```sql
SELECT 
    category,
    COUNT(DISTINCT customer_id) AS cnt_unique_cs
FROM retail_sales
GROUP BY category;
```

### Result

| Category | Unique Customers |
|---|---:|
| Beauty | 141 |
| Clothing | 149 |
| Electronics | 144 |

---

## Q10. Transaction Volume by Time Shift

Transactions were segmented into three time periods:

- Morning
- Afternoon
- Evening

```sql
WITH hourly_sale AS (
    SELECT 
        *,
        CASE
            WHEN EXTRACT(HOUR FROM sale_time) < 12 
                THEN 'Morning'
            WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 
                THEN 'Afternoon'
            ELSE 'Evening'
        END AS shift
    FROM retail_sales
)
SELECT 
    shift,
    COUNT(*) AS total_orders
FROM hourly_sale
GROUP BY shift
ORDER BY total_orders DESC;
```

### Result

| Shift | Orders |
|---|---:|
| Evening | 1,062 |
| Morning | 548 |
| Afternoon | 377 |

### Insight

The **Evening shift** generated the highest transaction volume with **1,062 orders**, making it the most active purchasing period in the dataset.

---

# 💰 5. Advanced Business Analytics

## Q11. Category Profitability Analysis

Gross profit and gross profit margin were calculated for each category.

```sql
SELECT 
    category,
    SUM(total_sale) AS total_revenue,
    SUM(cogs) AS total_cost,
    SUM(total_sale - cogs) AS gross_profit,
    ROUND(
        (SUM(total_sale - cogs) / SUM(total_sale)) * 100,
        2
    ) AS profit_margin_pct
FROM retail_sales
GROUP BY category
ORDER BY gross_profit DESC;
```

### Result

| Category | Revenue | Cost | Gross Profit | Margin |
|---|---:|---:|---:|---:|
| Clothing | 309,995 | 64,049.75 | 245,945.25 | 79.34% |
| Electronics | 311,445 | 66,677.45 | 244,767.55 | 78.59% |
| Beauty | 286,790 | 58,200.60 | 228,589.40 | **79.71%** |

### Insight

**Electronics** generated the highest revenue, while **Beauty** achieved the highest gross profit margin at **79.71%**.

This demonstrates why revenue alone is not sufficient to evaluate category performance; profitability should also be considered.

---

# 👥 6. Customer Loyalty Segmentation

Customers were segmented based on their transaction frequency:

- **One-Time Buyer**
- **Repeat Buyer**

```sql
WITH CustomerFrequency AS (
    SELECT 
        customer_id,
        COUNT(transactions_id) AS total_visits,
        SUM(total_sale) AS total_spent
    FROM retail_sales
    GROUP BY customer_id
)
SELECT 
    CASE 
        WHEN total_visits = 1 THEN 'One-Time Buyer'
        ELSE 'Repeat Buyer'
    END AS customer_segment,
    COUNT(customer_id) AS total_customers,
    SUM(total_spent) AS segment_revenue,
    ROUND(
        (
            SUM(total_spent) /
            (SELECT SUM(total_sale) FROM retail_sales)
        ) * 100,
        2
    ) AS revenue_pct
FROM CustomerFrequency
GROUP BY 1
ORDER BY segment_revenue DESC;
```

### Result

| Customer Segment | Customers | Revenue | Revenue Share |
|---|---:|---:|---:|
| Repeat Buyer | 155 | 908,230 | 100.00% |

### Observation

Within the analyzed dataset and the defined segmentation logic, all **155 customers** fall into the Repeat Buyer segment.

This indicates that the customers represented in this dataset made multiple transactions during the analyzed period.

---

# 📈 7. Month-over-Month Revenue Growth

To analyze revenue changes between consecutive months, the `LAG()` window function was used.

```sql
WITH MonthlySales AS (
    SELECT 
        TO_CHAR(sale_date, 'YYYY-MM') AS month_year,
        SUM(total_sale) AS current_month_revenue
    FROM retail_sales
    GROUP BY 1
),
MoMGrowth AS (
    SELECT 
        month_year,
        current_month_revenue,
        LAG(current_month_revenue) OVER (
            ORDER BY month_year
        ) AS prev_month_revenue
    FROM MonthlySales
)
SELECT 
    month_year,
    current_month_revenue,
    prev_month_revenue,
    ROUND(
        (
            (current_month_revenue - prev_month_revenue)
            / prev_month_revenue
        ) * 100,
        2
    ) AS growth_pct
FROM MoMGrowth
WHERE prev_month_revenue IS NOT NULL
ORDER BY month_year;
```

### Selected Results

| Month | Revenue | MoM Growth |
|---|---:|---:|
| 2022-08 | 21,075 | -5.05% |
| 2022-09 | 61,620 | **192.38%** |
| 2022-10 | 67,735 | 9.92% |
| 2022-11 | 68,915 | 1.74% |
| 2022-12 | 71,880 | 4.30% |
| 2023-01 | 23,790 | -66.90% |
| 2023-02 | 25,170 | 5.80% |
| 2023-09 | 67,560 | **138.98%** |
| 2023-10 | 57,880 | -14.33% |

### Insight

The dataset shows significant month-to-month revenue fluctuations.

The strongest growth occurred in:

- **September 2022: +192.38%**
- **September 2023: +138.98%**

These spikes may indicate seasonal patterns or changes in purchasing activity that could be investigated further.

---

# 🛍️ 8. Shopping Cart Performance

Average Order Value (AOV) and average items per order were calculated by category.

```sql
SELECT 
    category,
    COUNT(transactions_id) AS total_transactions,
    SUM(quantity) AS total_items_sold,
    ROUND(
        SUM(quantity)::NUMERIC / COUNT(transactions_id),
        2
    ) AS avg_items_per_order,
    ROUND(
        SUM(total_sale) / COUNT(transactions_id),
        2
    ) AS average_order_value_aov
FROM retail_sales
GROUP BY category
ORDER BY average_order_value_aov DESC;
```

### Result

| Category | Transactions | Items Sold | Avg. Items / Order | AOV |
|---|---:|---:|---:|---:|
| Beauty | 611 | 1,533 | 2.51 | **469.38** |
| Electronics | 678 | 1,682 | 2.48 | 459.36 |
| Clothing | 698 | 1,780 | 2.55 | 444.12 |

### Insight

**Beauty** has the highest Average Order Value at **469.38**, despite having fewer transactions than Clothing and Electronics.

Meanwhile, **Clothing** has the highest average number of items per order at **2.55**.

---

# 💡 Key Findings

Based on the analysis, several important insights were identified.

### 1. Electronics leads in revenue

Electronics generated the highest revenue:

> **311,445**

However, Clothing generated more transactions, indicating a difference between transaction volume and revenue performance.

### 2. Beauty has the highest profit margin

Beauty achieved the highest gross profit margin:

> **79.71%**

This demonstrates that the highest-revenue category is not necessarily the most profitable category in terms of margin.

### 3. Evening is the busiest sales period

The Evening shift generated:

> **1,062 transactions**

This represents the highest transaction volume among the three analyzed time periods.

### 4. Revenue shows significant monthly volatility

The strongest MoM growth occurred in September:

- September 2022: **+192.38%**
- September 2023: **+138.98%**

Further investigation could be performed to understand the drivers behind these spikes.

### 5. Beauty has the highest AOV

Beauty recorded an AOV of:

> **469.38**

This suggests that customers purchasing Beauty products generated the highest average transaction value among the three categories.

---

# 🧠 SQL Techniques Demonstrated

This project demonstrates a range of SQL techniques relevant to Data Analyst roles.

### Basic SQL

- `SELECT`
- `WHERE`
- `ORDER BY`
- `GROUP BY`
- `DISTINCT`
- `LIMIT`
- `COUNT()`
- `SUM()`
- `AVG()`

### Data Cleaning

- `NULL` detection
- Conditional filtering
- Record removal
- Data validation

### Intermediate SQL

- `CASE WHEN`
- `EXTRACT()`
- `TO_CHAR()`
- Type casting
- Conditional aggregation

### Advanced SQL

- Common Table Expressions (**CTEs**)
- Window Functions
- `LAG()`
- `RANK()`
- `PARTITION BY`
- Customer segmentation
- Month-over-Month analysis
- Profitability analysis
- AOV calculation

---

# 🗂️ Suggested Repository Structure

```text
retail-sales-analysis/
│
├── README.md
│
├── data/
│   └── retail_sales.csv
│
├── sql/
│   └── retail_sales_analysis.sql
│
└── screenshots/
    ├── database_setup.png
    ├── data_cleaning.png
    ├── exploratory_analysis.png
    └── advanced_analysis.png
```

---

# 🛠️ Tools & Technologies

| Tool | Purpose |
|---|---|
| PostgreSQL | Database management and SQL analysis |
| SQL | Data querying and business analysis |
| pgAdmin | PostgreSQL database interface |
| GitHub | Project documentation and version control |

---

# 🚀 Future Improvements

The project can be further developed by:

- Building an interactive dashboard using **Power BI**
- Creating automated KPI reporting
- Performing customer RFM analysis
- Investigating seasonal sales patterns
- Analyzing category-level trends over time
- Creating customer lifetime value metrics
- Adding cohort analysis
- Exploring correlations between customer demographics and purchasing behavior

---

# 📌 Conclusion

This project demonstrates how **PostgreSQL and SQL can be used as analytical tools to transform transactional data into business insights**.

Starting from raw data validation and cleaning, the analysis progresses from basic exploratory queries to advanced techniques such as **CTEs, Window Functions, customer segmentation, profitability analysis, and MoM revenue growth**.

The project strengthened my practical understanding of SQL for:

> **Data Cleaning → Data Exploration → Business Analysis → Advanced Analytics → Insight Generation**

---

## 👨‍💻 About Me

**Muhammad Zaki Al Hafiz, S.Kom.**

Informatics graduate with an interest in **Data Analytics, Data Science, Machine Learning, and Business Intelligence**.

I enjoy working with data to uncover patterns, answer business questions, and turn analytical results into actionable insights.

### 📫 Connect With Me

- 💼 **LinkedIn:** [Muhammad Zaki Al Hafiz](https:www.linkedin.com/in/zakialhafiz)
- 🐙 **GitHub:** [My GitHub Profile](https://github.com//MhdZakiAlHafiz/)
- 🌐 **Portfolio:** [My Portfolio Website]([https:](https://porto-zakialhafiz.web.app/))

---

⭐ If you find this project useful, feel free to explore the repository and give it a star!
