/* ==============================================================================
   PROYEK ANALISIS DATA RETAIL (SQL PORTFOLIO)
   ------------------------------------------------------------------------------
   Tujuan: Menganalisis tren penjualan, profitabilitas kategori, dan perilaku 
           pelanggan menggunakan PostgreSQL.
   Fokus Analitik: Data Cleaning, Agregasi Dasar, Window Functions, & CTE.
============================================================================== */

-- ==============================================================================
-- FASE 1: PERSIAPAN DATABASE & TABEL
-- ==============================================================================

-- Buat tabel (Drop jika sudah ada agar tidak error saat di-run ulang)
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

-- Note: Lakukan IMPORT data menggunakan pgAdmin (Import/Export tool) ke tabel ini.

-- Cek apakah data berhasil diimpor
SELECT * FROM retail_sales LIMIT 10;

-- Hitung total baris awal sebelum dibersihkan
SELECT COUNT(*) AS total_raw_data FROM retail_sales;


-- ==============================================================================
-- FASE 2: PEMBERSIHAN DATA (DATA CLEANING)
-- ==============================================================================

-- Mengidentifikasi transaksi yang memiliki nilai NULL (hilang)
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

-- Menghapus baris yang memiliki nilai NULL untuk menjaga kualitas analisis
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

-- Cek jumlah baris setelah dibersihkan
SELECT COUNT(*) AS total_clean_data FROM retail_sales;


-- ==============================================================================
-- FASE 3: EKSPLORASI DATA DASAR (DATA EXPLORATION)
-- ==============================================================================

-- 1. Berapa total transaksi yang kita miliki?
SELECT COUNT(*) AS total_sales FROM retail_sales;

-- 2. Berapa banyak pelanggan unik yang berbelanja?
SELECT COUNT(DISTINCT customer_id) AS total_unique_customers FROM retail_sales;

-- 3. Kategori produk apa saja yang tersedia?
SELECT DISTINCT category FROM retail_sales;


-- ==============================================================================
-- FASE 4: MENJAWAB PERTANYAAN BISNIS DASAR (TUTORIAL BASE)
-- ==============================================================================

-- Q.1: Ambil semua data transaksi penjualan yang terjadi pada tanggal '2022-11-05'
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';

-- Q.2: Ambil semua transaksi dengan kategori 'Clothing' dan jumlah terjual >= 4 pada Nov 2022
SELECT *
FROM retail_sales
WHERE 
    category = 'Clothing'
    AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
    AND quantity >= 4;

-- Q.3: Hitung total pendapatan (net_sale) dan jumlah pesanan untuk setiap kategori
SELECT 
    category,
    SUM(total_sale) AS net_sale,
    COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category
ORDER BY net_sale DESC;

-- Q.4: Berapa rata-rata umur pelanggan yang membeli produk 'Beauty'?
SELECT
    ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';

-- Q.5: Temukan semua transaksi yang total penjualannya (total_sale) di atas 1000
SELECT * 
FROM retail_sales
WHERE total_sale > 1000;

-- Q.6: Hitung total transaksi berdasarkan gender pada masing-masing kategori
SELECT 
    category,
    gender,
    COUNT(*) AS total_trans
FROM retail_sales
GROUP BY category, gender
ORDER BY category;

-- Q.7: Hitung rata-rata penjualan per bulan dan cari bulan dengan rata-rata penjualan tertinggi di tiap tahun
WITH MonthlyAverage AS (
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        AVG(total_sale) AS avg_sale,
        RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS rank
    FROM retail_sales
    GROUP BY 1, 2
)
SELECT year, month, ROUND(avg_sale, 2) AS top_avg_sale
FROM MonthlyAverage
WHERE rank = 1;

-- Q.8: Cari Top 5 Pelanggan berdasarkan total uang yang dihabiskan
SELECT 
    customer_id,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;

-- Q.9: Berapa jumlah pelanggan unik untuk masing-masing kategori produk?
SELECT 
    category,    
    COUNT(DISTINCT customer_id) AS cnt_unique_cs
FROM retail_sales
GROUP BY category;

-- Q.10: Buat segmentasi waktu (Shift) dan hitung jumlah transaksi di tiap shift
WITH hourly_sale AS (
    SELECT 
        *,
        CASE
            WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
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


-- ==============================================================================
-- FASE 5: ANALISIS LANJUTAN & KEBAHARUAN (ADVANCED ANALYTICS)
-- ==============================================================================

-- Q.11: Profitabilitas Kategori (Menghitung Gross Profit Margin riil per kategori)
SELECT 
    category,
    SUM(total_sale) AS total_revenue,
    SUM(cogs) AS total_cost,
    SUM(total_sale - cogs) AS gross_profit,
    ROUND((SUM(total_sale - cogs) / SUM(total_sale)) * 100, 2) AS profit_margin_pct
FROM retail_sales
GROUP BY category
ORDER BY gross_profit DESC;


-- Q.12: Segmentasi Loyalitas Pelanggan (One-Time Buyer vs Repeat Buyer)
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
    ROUND((SUM(total_spent) / (SELECT SUM(total_sale) FROM retail_sales)) * 100, 2) AS revenue_pct
FROM CustomerFrequency
GROUP BY 1
ORDER BY segment_revenue DESC;


-- Q.13: Pertumbuhan Pendapatan Bulan-ke-Bulan (Month-over-Month Growth)
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
        LAG(current_month_revenue) OVER(ORDER BY month_year) AS prev_month_revenue
    FROM MonthlySales
)
SELECT 
    month_year,
    current_month_revenue,
    prev_month_revenue,
    ROUND(((current_month_revenue - prev_month_revenue) / prev_month_revenue) * 100, 2) AS growth_pct
FROM MoMGrowth
WHERE prev_month_revenue IS NOT NULL
ORDER BY month_year;


-- Q.14: Kinerja Keranjang Belanja (Average Order Value & Items per Order per Category)
SELECT 
    category,
    COUNT(transactions_id) AS total_transactions,
    SUM(quantity) AS total_items_sold,
    ROUND(SUM(quantity)::NUMERIC / COUNT(transactions_id), 2) AS avg_items_per_order,
    ROUND(SUM(total_sale) / COUNT(transactions_id), 2) AS average_order_value_aov
FROM retail_sales
GROUP BY category
ORDER BY average_order_value_aov DESC;

/* ==============================================================================
   END OF SCRIPT
============================================================================== */
