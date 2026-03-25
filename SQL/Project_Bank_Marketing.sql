-- ============================================================
-- BANK MARKETING CAMPAIGN ANALYSIS
-- ============================================================

-- ============================================================
-- PHASE 1: DATA ENGINEERING
-- ============================================================

-- 1. CREATE TABLE
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    age INT,
    job VARCHAR(50),
    marital VARCHAR(20),
    education VARCHAR(20),
    default_status VARCHAR(5),
    balance INT,
    housing VARCHAR(5),
    loan VARCHAR(5),
    contact VARCHAR(20),
    day INT,
    month VARCHAR(10),
    duration INT,
    campaign INT,
    pdays INT,
    previous INT,
    poutcome VARCHAR(20),
    y VARCHAR(5)
);

-- ============================================================
-- 2. INDEXES
-- ============================================================
CREATE INDEX idx_job ON customers(job);
CREATE INDEX idx_education ON customers(education);
CREATE INDEX idx_marital ON customers(marital);
CREATE INDEX idx_loan ON customers(loan);
CREATE INDEX idx_campaign ON customers(campaign);
CREATE INDEX idx_balance ON customers(balance);
CREATE INDEX idx_poutcome ON customers(poutcome);
CREATE INDEX idx_y ON customers(y);

-- ============================================================
-- 3. DATA CLEANING
-- ============================================================

-- Check NULL values
SELECT * FROM customers
WHERE job IS NULL OR education IS NULL OR marital IS NULL;

-- Standardize text
UPDATE customers
SET job = LOWER(TRIM(job)),
    education = LOWER(TRIM(education)),
    marital = LOWER(TRIM(marital)),
    loan = LOWER(TRIM(loan)),
    y = LOWER(TRIM(y));

-- Fix invalid pdays
UPDATE customers
SET pdays = NULL
WHERE pdays = -1;

-- Remove invalid duration
DELETE FROM customers
WHERE duration < 0;

-- ============================================================
-- PHASE 2: DESCRIPTIVE ANALYTICS
-- ============================================================

-- A. OVERALL PERFORMANCE
SELECT 
    COUNT(*) AS total_customers,
    SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS total_converted,
    ROUND(SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) AS conversion_rate,
    SUM(CASE WHEN y = 'yes' THEN 195 ELSE -5 END) AS net_profit
FROM customers;

-- ============================================================
-- B. CUSTOMER INSIGHTS
-- ============================================================

-- 1. BY JOB (Top & Bottom 5)
SELECT * FROM (
    SELECT 
        job,
        COUNT(*) AS total_contacted,
        SUM(y='yes') AS total_converted,
        ROUND(SUM(y='yes')*100/COUNT(*),2) AS conversion_rate,
        DENSE_RANK() OVER (ORDER BY SUM(y='yes')*100/COUNT(*) DESC) AS top_ranked,
        DENSE_RANK() OVER (ORDER BY SUM(y='yes')*100/COUNT(*) ASC) AS bottom_ranked
    FROM customers
    GROUP BY job
) t
WHERE top_ranked <= 5 OR bottom_ranked <= 5;

-- 2. BY EDUCATION
SELECT * FROM (
    SELECT 
        education,
        COUNT(*) AS total_contacted,
        SUM(y='yes') AS total_converted,
        ROUND(SUM(y='yes')*100/COUNT(*),2) AS conversion_rate,
        RANK() OVER (ORDER BY SUM(y='yes')*100/COUNT(*) DESC) AS top_ranked,
        RANK() OVER (ORDER BY SUM(y='yes')*100/COUNT(*) ASC) AS bottom_ranked
    FROM customers
    GROUP BY education
) t
WHERE top_ranked <= 5 OR bottom_ranked <= 5;

-- 3. BY MARITAL STATUS
SELECT * FROM (
    SELECT 
        marital,
        COUNT(*) AS total_contacted,
        SUM(y='yes') AS total_converted,
        ROUND(SUM(y='yes')*100/COUNT(*),2) AS conversion_rate,
        DENSE_RANK() OVER (ORDER BY SUM(y='yes')*100/COUNT(*) DESC) AS top_ranked,
        DENSE_RANK() OVER (ORDER BY SUM(y='yes')*100/COUNT(*) ASC) AS bottom_ranked
    FROM customers
    GROUP BY marital
) t
WHERE top_ranked <= 5 OR bottom_ranked <= 5;

-- 4. BY LOAN STATUS
SELECT * FROM (
    SELECT 
        loan,
        COUNT(*) AS total_contacted,
        SUM(y='yes') AS total_converted,
        ROUND(SUM(y='yes')*100/COUNT(*),2) AS conversion_rate,
        DENSE_RANK() OVER (ORDER BY SUM(y='yes')*100/COUNT(*) DESC) AS top_ranked,
        DENSE_RANK() OVER (ORDER BY SUM(y='yes')*100/COUNT(*) ASC) AS bottom_ranked
    FROM customers
    GROUP BY loan
) t
WHERE top_ranked <= 5 OR bottom_ranked <= 5;

-- 5. BALANCE SEGMENTATION
SELECT * FROM (
    SELECT 
        CASE 
            WHEN balance < 0 THEN 'Negative'
            WHEN balance <= 1363 THEN 'Low'
            ELSE 'High'
        END AS balance_range,
        COUNT(*) AS total_contacted,
        SUM(y='yes') AS total_converted,
        ROUND(SUM(y='yes')*100/COUNT(*),2) AS conversion_rate,
        DENSE_RANK() OVER (ORDER BY SUM(y='yes')*100/COUNT(*) DESC) AS top_ranked,
        DENSE_RANK() OVER (ORDER BY SUM(y='yes')*100/COUNT(*) ASC) AS bottom_ranked
    FROM customers
    GROUP BY balance_range
) t
WHERE top_ranked <= 5 OR bottom_ranked <= 5;


-- 6. BY MONTH
SELECT * FROM (
    SELECT 
        month,
        COUNT(*) AS total_contacted,
        SUM(y='yes') AS total_converted,
        ROUND(SUM(y='yes')*100/COUNT(*),2) AS conversion_rate,
        DENSE_RANK() OVER (ORDER BY SUM(y='yes')*100/COUNT(*) DESC) AS top_ranked,
        DENSE_RANK() OVER (ORDER BY SUM(y='yes')*100/COUNT(*) ASC) AS bottom_ranked
    FROM customers
    GROUP BY month
) t
WHERE top_ranked <= 5 OR bottom_ranked <= 5;

-- 7. CAMPAIGN FREQUENCY
SELECT * FROM (
    SELECT 
        CASE 
            WHEN campaign BETWEEN 1 AND 2 THEN '1-2 calls'
            WHEN campaign = 3 THEN '3 calls'
            ELSE 'More than 3'
        END AS campaign_group,
        COUNT(*) AS total_contacted,
        SUM(y='yes') AS total_converted,
        ROUND(SUM(y='yes')*100/COUNT(*),2) AS conversion_rate,
        DENSE_RANK() OVER (ORDER BY SUM(y='yes')*100/COUNT(*) DESC) AS top_ranked,
        DENSE_RANK() OVER (ORDER BY SUM(y='yes')*100/COUNT(*) ASC) AS bottom_ranked
    FROM customers
    GROUP BY campaign_group
) t
WHERE top_ranked <= 5 OR bottom_ranked <= 5;

-- ============================================================
-- C. CONTACT STRATEGY ANALYSIS
-- ============================================================

-- Campaign impact
SELECT 
    campaign,
    COUNT(*) AS total_customers,
    SUM(y='yes') AS converted,
    ROUND(SUM(y='yes')*100/COUNT(*),2) AS conversion_rate
FROM customers
GROUP BY campaign
ORDER BY conversion_rate DESC;

-- Duration impact
SELECT
    CASE 
        WHEN duration = 0 THEN 'Not Contacted'
        WHEN duration <= 100 THEN 'Quick Reject'
        WHEN duration <= 300 THEN 'Average'
        WHEN duration <= 500 THEN 'Above Average'
        ELSE 'Long Call'
    END AS duration_group,
    COUNT(*) AS total,
    ROUND(SUM(y='yes')*100/COUNT(*),2) AS conversion_rate
FROM customers
GROUP BY duration_group
ORDER BY conversion_rate DESC;

-- ============================================================
-- D. RISK PROFILING
-- ============================================================

-- High balance NOT subscribed
SELECT 
    COUNT(*) AS total,
    SUM(y='no') AS not_subscribed
FROM customers
WHERE balance > 1400;

-- Low balance subscribed
SELECT 
    COUNT(*) AS total,
    SUM(y='yes') AS subscribed
FROM customers
WHERE balance BETWEEN 1 AND 700;

-- Heavily contacted but unsuccessful
SELECT 
    COUNT(*) AS total,
    SUM(y='no') AS not_subscribed
FROM customers
WHERE campaign > 3;

-- ============================================================
-- PHASE 3: PROFIT OPTIMIZATION
-- ============================================================

-- Historical profit
SELECT 
    COUNT(*) AS total_customers,
    SUM(y='yes') AS converted,
    SUM(y='no') AS not_converted,
    SUM(CASE WHEN y='yes' THEN 195 ELSE -5 END) AS net_profit
FROM customers;

-- Targeted strategy
SELECT 
    COUNT(*) AS total_customers,
    SUM(y='yes') AS converted,
    ROUND(SUM(y='yes')*100/COUNT(*),2) AS conversion_rate,
    SUM(CASE WHEN y='yes' THEN 195 ELSE -5 END) AS net_profit
FROM customers
WHERE balance > 1363
AND campaign <= 3
AND loan = 'no'
AND poutcome = 'success';

-- Ranked strategy (Top 20,000 customers)
WITH ranked_customers AS (
    SELECT *,
    (RANK() OVER (ORDER BY balance DESC) +
     RANK() OVER (ORDER BY duration DESC) +
     RANK() OVER (ORDER BY campaign ASC)) AS score
    FROM customers
)

SELECT 
    COUNT(*) AS total_customers,
    SUM(y='yes') AS converted,
    ROUND(SUM(y='yes')*100/COUNT(*),2) AS conversion_rate,
    SUM(CASE WHEN y='yes' THEN 195 ELSE -5 END) AS net_profit
FROM (
    SELECT * FROM ranked_customers
    ORDER BY score ASC
    LIMIT 20000
) t;

-- ============================================================
-- END OF PROJECT
-- ============================================================