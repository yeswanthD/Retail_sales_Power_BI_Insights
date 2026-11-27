/*
===============================================================================
PROJECT: Maven Roasters - Retail Sales Analysis
AUTHOR: Yeswanth Doppalapudi
DATABASE: Microsoft SQL Server
SOURCE: coffee-shop-sales-revenue.csv
PERIOD: January-June 2023

PURPOSE
-------
A collection of SQL Server queries for exploring coffee shop transactions,
measuring sales performance, comparing stores and products, and identifying
time-based sales patterns.

HOW TO USE
----------
1. In SQL Server Management Studio (SSMS), create/select your practice database.
2. Import coffee-shop-sales-revenue.csv using the Import Flat File wizard.
3. Name the imported table: dbo.MavenRoastersSales
4. Confirm the imported column names and data types match the schema below.
5. Run the queries section by section.

EXPECTED SOURCE COLUMNS
-----------------------
transaction_id, transaction_date, transaction_time, transaction_qty,
store_id, store_location, product_id, unit_price, product_category,
product_type, product_detail

NOTE: Revenue is calculated as transaction_qty * unit_price. The script does
not assume a separate revenue column exists in the source file.
===============================================================================
*/

-- ============================================================================
-- 00. OPTIONAL TABLE DEFINITION
-- ============================================================================
-- Use this definition if you prefer to create the table before importing data.
-- If you use the SSMS Import Flat File wizard, inspect its inferred data types
-- and adjust them if needed. Do not create a second table with the same name.

-- CREATE TABLE dbo.MavenRoastersSales
-- (
--     transaction_id   INT            NOT NULL,
--     transaction_date DATE           NOT NULL,
--     transaction_time TIME(0)        NOT NULL,
--     transaction_qty  INT            NOT NULL,
--     store_id         INT            NOT NULL,
--     store_location   NVARCHAR(100)  NOT NULL,
--     product_id       INT            NOT NULL,
--     unit_price       DECIMAL(10, 2) NOT NULL,
--     product_category NVARCHAR(100)  NOT NULL,
--     product_type     NVARCHAR(100)  NOT NULL,
--     product_detail   NVARCHAR(200)  NOT NULL
-- );

-- ============================================================================
-- 01. DATA VALIDATION
-- ============================================================================

-- Q1. View a sample of records.
SELECT TOP (10) *
FROM dbo.MavenRoastersSales;

-- Q2. Check total rows and distinct transaction IDs.
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT transaction_id) AS distinct_transactions
FROM dbo.MavenRoastersSales;

-- Q3. Check for NULL values in important columns.
SELECT
    SUM(CASE WHEN transaction_id IS NULL THEN 1 ELSE 0 END) AS null_transaction_id,
    SUM(CASE WHEN transaction_date IS NULL THEN 1 ELSE 0 END) AS null_transaction_date,
    SUM(CASE WHEN transaction_qty IS NULL THEN 1 ELSE 0 END) AS null_quantity,
    SUM(CASE WHEN unit_price IS NULL THEN 1 ELSE 0 END) AS null_unit_price,
    SUM(CASE WHEN store_location IS NULL THEN 1 ELSE 0 END) AS null_store_location
FROM dbo.MavenRoastersSales;

-- Q4. Find duplicate transaction IDs, if any.
SELECT
    transaction_id,
    COUNT(*) AS occurrences
FROM dbo.MavenRoastersSales
GROUP BY transaction_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

-- Q5. Check for invalid quantities or prices.
SELECT *
FROM dbo.MavenRoastersSales
WHERE transaction_qty <= 0
   OR unit_price < 0;

-- ============================================================================
-- 02. OVERALL BUSINESS KPIs
-- ============================================================================

-- Q6. Calculate core business metrics.
SELECT
    SUM(transaction_qty) AS total_quantity_sold,
    COUNT(*) AS total_transaction_rows,
    COUNT(DISTINCT transaction_id) AS unique_transactions,
    CAST(SUM(transaction_qty * unit_price) AS DECIMAL(12, 2)) AS total_revenue,
    CAST(AVG(unit_price) AS DECIMAL(10, 2)) AS average_unit_price
FROM dbo.MavenRoastersSales;

-- Q7. Calculate average revenue per transaction.
WITH TransactionRevenue AS
(
    SELECT
        transaction_id,
        SUM(transaction_qty * unit_price) AS transaction_revenue
    FROM dbo.MavenRoastersSales
    GROUP BY transaction_id
)
SELECT
    COUNT(*) AS total_transactions,
    CAST(AVG(transaction_revenue) AS DECIMAL(10, 2)) AS average_revenue_per_transaction
FROM TransactionRevenue;

-- ============================================================================
-- 03. STORE PERFORMANCE
-- ============================================================================

-- Q8. Compare revenue and quantity across store locations.
SELECT
    store_location,
    SUM(transaction_qty) AS quantity_sold,
    COUNT(DISTINCT transaction_id) AS total_transactions,
    CAST(SUM(transaction_qty * unit_price) AS DECIMAL(12, 2)) AS total_revenue
FROM dbo.MavenRoastersSales
GROUP BY store_location
ORDER BY total_revenue DESC;

-- Q9. Calculate each store's percentage contribution to total revenue.
WITH StoreRevenue AS
(
    SELECT
        store_location,
        SUM(transaction_qty * unit_price) AS revenue
    FROM dbo.MavenRoastersSales
    GROUP BY store_location
)
SELECT
    store_location,
    CAST(revenue AS DECIMAL(12, 2)) AS revenue,
    CAST(100.0 * revenue / NULLIF(SUM(revenue) OVER (), 0) AS DECIMAL(6, 2))
        AS revenue_contribution_pct
FROM StoreRevenue
ORDER BY revenue DESC;

-- ============================================================================
-- 04. PRODUCT AND CATEGORY ANALYSIS
-- ============================================================================

-- Q10. Identify the highest-revenue product categories.
SELECT
    product_category,
    SUM(transaction_qty) AS quantity_sold,
    CAST(SUM(transaction_qty * unit_price) AS DECIMAL(12, 2)) AS total_revenue
FROM dbo.MavenRoastersSales
GROUP BY product_category
ORDER BY total_revenue DESC;

-- Q11. Find the top 10 products by revenue.
SELECT TOP (10)
    product_detail,
    product_category,
    SUM(transaction_qty) AS quantity_sold,
    CAST(SUM(transaction_qty * unit_price) AS DECIMAL(12, 2)) AS total_revenue
FROM dbo.MavenRoastersSales
GROUP BY product_detail, product_category
ORDER BY total_revenue DESC;

-- Q12. Find the most frequently purchased products by quantity.
SELECT TOP (10)
    product_detail,
    SUM(transaction_qty) AS total_quantity_sold,
    COUNT(DISTINCT transaction_id) AS transactions_containing_product
FROM dbo.MavenRoastersSales
GROUP BY product_detail
ORDER BY total_quantity_sold DESC;

-- Q13. Rank product categories by revenue.
WITH CategoryRevenue AS
(
    SELECT
        product_category,
        SUM(transaction_qty * unit_price) AS revenue
    FROM dbo.MavenRoastersSales
    GROUP BY product_category
)
SELECT
    product_category,
    CAST(revenue AS DECIMAL(12, 2)) AS revenue,
    DENSE_RANK() OVER (ORDER BY revenue DESC) AS category_rank
FROM CategoryRevenue
ORDER BY category_rank;

-- ============================================================================
-- 05. TIME-BASED SALES ANALYSIS
-- ============================================================================

-- Q14. Analyze monthly revenue and month-over-month change.
WITH MonthlySales AS
(
    SELECT
        DATEFROMPARTS(YEAR(transaction_date), MONTH(transaction_date), 1) AS sales_month,
        SUM(transaction_qty * unit_price) AS monthly_revenue
    FROM dbo.MavenRoastersSales
    GROUP BY DATEFROMPARTS(YEAR(transaction_date), MONTH(transaction_date), 1)
),
MonthlyComparison AS
(
    SELECT
        sales_month,
        monthly_revenue,
        LAG(monthly_revenue) OVER (ORDER BY sales_month) AS previous_month_revenue
    FROM MonthlySales
)
SELECT
    sales_month,
    CAST(monthly_revenue AS DECIMAL(12, 2)) AS monthly_revenue,
    CAST(previous_month_revenue AS DECIMAL(12, 2)) AS previous_month_revenue,
    CAST(
        100.0 * (monthly_revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0)
        AS DECIMAL(8, 2)
    ) AS mom_growth_pct
FROM MonthlyComparison
ORDER BY sales_month;

-- Q15. Compare weekday and weekend sales.
SELECT
    CASE
        WHEN DATEDIFF(DAY, '19000101', transaction_date) % 7 IN (5, 6)
            THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    SUM(transaction_qty) AS quantity_sold,
    COUNT(DISTINCT transaction_id) AS total_transactions,
    CAST(SUM(transaction_qty * unit_price) AS DECIMAL(12, 2)) AS total_revenue
FROM dbo.MavenRoastersSales
GROUP BY
    CASE
        WHEN DATEDIFF(DAY, '19000101', transaction_date) % 7 IN (5, 6)
            THEN 'Weekend'
        ELSE 'Weekday'
    END
ORDER BY total_revenue DESC;

-- Q16. Find the busiest sales hours based on transaction count.
SELECT
    DATEPART(HOUR, transaction_time) AS sales_hour,
    COUNT(DISTINCT transaction_id) AS total_transactions,
    SUM(transaction_qty) AS quantity_sold,
    CAST(SUM(transaction_qty * unit_price) AS DECIMAL(12, 2)) AS total_revenue
FROM dbo.MavenRoastersSales
GROUP BY DATEPART(HOUR, transaction_time)
ORDER BY total_transactions DESC;

-- Q17. Analyze revenue by day of week.
SELECT
    DATENAME(WEEKDAY, transaction_date) AS day_name,
    COUNT(DISTINCT transaction_id) AS total_transactions,
    CAST(SUM(transaction_qty * unit_price) AS DECIMAL(12, 2)) AS total_revenue
FROM dbo.MavenRoastersSales
GROUP BY DATENAME(WEEKDAY, transaction_date), DATEPART(WEEKDAY, transaction_date)
ORDER BY DATEPART(WEEKDAY, transaction_date);

-- ============================================================================
-- 06. ADVANCED SQL: CTEs AND WINDOW FUNCTIONS
-- ============================================================================

-- Q18. Calculate a running total of daily revenue.
WITH DailySales AS
(
    SELECT
        transaction_date,
        SUM(transaction_qty * unit_price) AS daily_revenue
    FROM dbo.MavenRoastersSales
    GROUP BY transaction_date
)
SELECT
    transaction_date,
    CAST(daily_revenue AS DECIMAL(12, 2)) AS daily_revenue,
    CAST(
        SUM(daily_revenue) OVER (
            ORDER BY transaction_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS DECIMAL(14, 2)
    ) AS running_revenue
FROM DailySales
ORDER BY transaction_date;

-- Q19. Find the top 3 products within each category using DENSE_RANK.
WITH ProductSales AS
(
    SELECT
        product_category,
        product_detail,
        SUM(transaction_qty * unit_price) AS revenue
    FROM dbo.MavenRoastersSales
    GROUP BY product_category, product_detail
),
RankedProducts AS
(
    SELECT
        product_category,
        product_detail,
        revenue,
        DENSE_RANK() OVER (
            PARTITION BY product_category
            ORDER BY revenue DESC
        ) AS product_rank
    FROM ProductSales
)
SELECT
    product_category,
    product_detail,
    CAST(revenue AS DECIMAL(12, 2)) AS revenue,
    product_rank
FROM RankedProducts
WHERE product_rank <= 3
ORDER BY product_category, product_rank;

-- Q20. Identify each store's best-performing product category.
WITH StoreCategorySales AS
(
    SELECT
        store_location,
        product_category,
        SUM(transaction_qty * unit_price) AS revenue
    FROM dbo.MavenRoastersSales
    GROUP BY store_location, product_category
),
RankedStoreCategories AS
(
    SELECT
        store_location,
        product_category,
        revenue,
        ROW_NUMBER() OVER (
            PARTITION BY store_location
            ORDER BY revenue DESC
        ) AS category_position
    FROM StoreCategorySales
)
SELECT
    store_location,
    product_category AS top_category,
    CAST(revenue AS DECIMAL(12, 2)) AS category_revenue
FROM RankedStoreCategories
WHERE category_position = 1
ORDER BY store_location;

-- ============================================================================
-- END OF ANALYSIS
-- ============================================================================
-- Suggested next steps:
-- 1. Compare the SQL results with the Python EDA outputs.
-- 2. Reconcile total revenue before building Power BI measures.
-- 3. Turn the strongest findings into dashboard visuals and recommendations.
