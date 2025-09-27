 # Step 1: Problem Definition
Business Context 
  
A retail company in Rwanda sells food and beverages across different regions (Kigali, Musanze, Huye). The Sales & Marketing department wants to use data to improve business performance.
Data Challenge
Currently, managers can’t easily identify which products sell the most in each region, track month-to-month growth, 
or divide customers into groups for marketing.
Expected Outcome
The analysis should show the top 5 products per region, monthly sales trends, customer spending groups (quartiles),
and 3-month moving averages to help managers make better business decisions.
# Step 2: Success Criteria
1. We list the top 5 products in each area.  
2. We see the sales growth for each area month by month.  
3. We divide customers into groups (quartiles) based on their spending.  
4. We calculate a 3-month moving average of sales to show the trend.  
5. The results can be explained clearly and help the managers make decisions.
  
-- database is called pl/sql

--the Customers table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    region VARCHAR(50) NOT NULL
);

-- the Products table
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL
);

--the Transactions table
CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    sale_date DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Insert sample customers data values 
INSERT INTO customers (customer_id, name, region) VALUES
(1001, 'Bizimana Jean', 'Kigali'),
(1002, 'Uwase Aline', 'Musanze'),
(1003, 'Niyonkuru David', 'Rubavu');

-- Insert sample products data values 
INSERT INTO products (product_id, name, category) VALUES
(2001, 'Ikawa Beans', 'Beverages'),
(2002, 'Icyayi Leaves', 'Beverages'),
(2003, 'Chocolate yIkinyafurika', 'Snacks');

-- Insert sample transactions data values 
INSERT INTO transactions (transaction_id, customer_id, product_id, sale_date, amount) VALUES
(3004, 1001, 2002, '2024-02-10', 18000),
(3005, 1002, 2001, '2024-02-12', 22000),
(3006, 1003, 2002, '2024-02-15', 14000),
(3007, 1001, 2003, '2024-03-05', 16000),
(3008, 1002, 2003, '2024-03-08', 17000),
(3009, 1003, 2001, '2024-03-10', 20000);

-- 1. codes of excuting the top 5 products per region/quarter → RANK()
SELECT region, product_id, product_name, total_sales, product_rank
FROM (
    SELECT
        c.region,
        p.product_id,
        p.name AS product_name,
        SUM(t.amount) AS total_sales,
        RANK() OVER (PARTITION BY c.region ORDER BY SUM(t.amount) DESC) AS product_rank
    FROM transactions t
    JOIN customers c ON t.customer_id = c.customer_id
    JOIN products p ON t.product_id = p.product_id
    GROUP BY c.region, p.product_id, p.name
) AS ranked_products
WHERE product_rank <= 5
ORDER BY region, product_rank;

-- I Running total of sales per customer per month
-- 2 Running total of sales per customer
SELECT 
    c.customer_id,
    c.name,
    t.sale_date,
    t.amount,
    SUM(t.amount) OVER (
        PARTITION BY c.customer_id 
        ORDER BY t.sale_date 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total,
    AVG(t.amount) OVER (
        PARTITION BY c.customer_id 
        ORDER BY t.sale_date 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_3_sales
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
ORDER BY c.customer_id, t.sale_date;

-- 4. Monthly running total of sales for all products
SELECT
    YEAR(t.sale_date) AS year,
    MONTH(t.sale_date) AS month,
    SUM(t.amount) AS monthly_sales,
    SUM(SUM(t.amount)) OVER (
        ORDER BY YEAR(t.sale_date), MONTH(t.sale_date)
    ) AS running_total
FROM transactions t
GROUP BY YEAR(t.sale_date), MONTH(t.sale_date)
ORDER BY year, month;

-- 5-month moving average of monthly sales
SELECT
    YEAR(t.sale_date) AS year,
    MONTH(t.sale_date) AS month,
    SUM(t.amount) AS monthly_sales,
    AVG(SUM(t.amount)) OVER (
        ORDER BY YEAR(t.sale_date), MONTH(t.sale_date)
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_3m
FROM transactions t
GROUP BY YEAR(t.sale_date), MONTH(t.sale_date)
ORDER BY year, month;

This shows the top 5 customers in each region based on how much they spent.
RANK() gives their position and skips numbers if two spent the same, while ROW_NUMBER() just counts them in order.
DENSE_RANK() is like RANK but doesn’t skip numbers, and PERCENT_RANK() shows how high they are compared to everyone else.
What I notice: We can see who our best customers are and maybe give them rewards or special offers.

Aggregate Functions (SUM, AVG, MIN, MAX with frames)

Interpretation:
This one adds up each customer’s sales over time so we can see totals.
The 3-transaction average smooths things out so big spikes don’t confuse us.
What I notice: It helps us see who buys a lot regularly and spot trends in spending.

Navigation Functions (LAG, LEAD)

Interpretation:
Here, we check sales this month compared to last month for each product using LAG().
We can see if sales went up or down as a percentage.
What I notice: This shows which products are growing or dropping, so we can plan better.

Distribution Functions (NTILE, CUME_DIST)

Interpretation:
This divides customers into 4 groups based on spending (quartiles).
CUME_DIST() tells what percentage of customers spent less than a certain amount.
What I notice: We can tell who our top, middle, and low-spending customers are, which is useful for marketing.
  
