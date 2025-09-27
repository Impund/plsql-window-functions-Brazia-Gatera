 # Step 1: Problem Definition
Business Context 
A retail company in Rwanda sells food and beverages across different regions (Kigali, Musanze, Huye). The Sales & Marketing department wants to use data to improve business performance.
Data Challenge
Currently, managers can’t easily identify which products sell the most in each region, track month-to-month growth, or divide customers into groups for marketing.
Expected Outcome
The analysis should show the top 5 products per region, monthly sales trends, customer spending groups (quartiles), and 3-month moving averages to help managers make better business decisions.
# Step 2: Success Criteria
1. We list the top 5 products in each area.  
2. We see the sales growth for each area month by month.  
3. We divide customers into groups (quartiles) based on their spending.  
4. We calculate a 3-month moving average of sales to show the trend.  
5. The results can be explained clearly and help the managers make decisions.
CREATE TABLE customers (
    customer_id NUMBER PRIMARY KEY,   -- unique ID
    name VARCHAR2(100) NOT NULL,     -- customer full name
    region VARCHAR2(50) NOT NULL     -- location/region
);
CREATE TABLE products (
    product_id NUMBER PRIMARY KEY,    -- unique ID
    name VARCHAR2(100) NOT NULL,     -- product name
    category VARCHAR2(50) NOT NULL   -- product category
);
CREATE TABLE transactions (
    transaction_id NUMBER PRIMARY KEY,    -- unique ID
    customer_id NUMBER REFERENCES customers(customer_id),  -- FK to customers
    product_id NUMBER REFERENCES products(product_id),    -- FK to products
    sale_date DATE NOT NULL,              -- date of transaction
    amount NUMBER(10,2) NOT NULL         -- amount sold
); 

INSERT INTO customers (customer_id, name, region) VALUES
(1001, 'Bizimana Jean', 'Kigali'),
(1002, 'Uwase Aline', 'Musanze'),
(1003, 'Niyonkuru David', 'Rubavu');

INSERT INTO products (product_id, name, category) VALUES
(2001, 'Ikawa Beans', 'Beverages'),
(2002, 'Icyayi Leaves', 'Beverages'),
(2003, 'Chocolate y’Ikinyafurika', 'Snacks');

INSERT INTO transactions (transaction_id, customer_id, product_id, sale_date, amount) VALUES
(3001, 1001, 2001, TO_DATE('2024-01-15','YYYY-MM-DD'), 25000),
(3002, 1002, 2002, TO_DATE('2024-01-16','YYYY-MM-DD'), 15000),
(3003, 1003, 2003, TO_DATE('2024-01-17','YYYY-MM-DD'), 12000);
SELECT 
    c.customer_id,
    c.name,
    SUM(t.amount) AS total_revenue,
    ROW_NUMBER() OVER (ORDER BY SUM(t.amount) DESC) AS row_num
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_revenue DESC;
SELECT 
    c.customer_id,
    c.name,
    SUM(t.amount) AS total_revenue,
    RANK() OVER (ORDER BY SUM(t.amount) DESC) AS rank
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_revenue DESC;

SELECT 
    c.customer_id,
    c.name,
    SUM(t.amount) AS total_revenue,
    DENSE_RANK() OVER (ORDER BY SUM(t.amount) DESC) AS dense_rank
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_revenue DESC;

SELECT 
    c.customer_id,
    c.name,
    SUM(t.amount) AS total_revenue,
    PERCENT_RANK() OVER (ORDER BY SUM(t.amount) DESC) AS percent_rank
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_revenue DESC;

-- Running total of sales per customer per month
SELECT 
    customer_id,
    sale_date,
    amount,
    SUM(amount) OVER (PARTITION BY customer_id ORDER BY sale_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total,
    AVG(amount) OVER (PARTITION BY customer_id ORDER BY sale_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_3_sales
FROM transactions
ORDER BY customer_id, sale_date;

-- Calculate monthly sales growth for each product
SELECT 
    product_id,
    EXTRACT(MONTH FROM sale_date) AS month,
    SUM(amount) AS monthly_sales,
    LAG(SUM(amount)) OVER (PARTITION BY product_id ORDER BY EXTRACT(MONTH FROM sale_date)) AS previous_month_sales,
    (SUM(amount) - LAG(SUM(amount)) OVER (PARTITION BY product_id ORDER BY EXTRACT(MONTH FROM sale_date))) / LAG(SUM(amount)) OVER (PARTITION BY product_id ORDER BY EXTRACT(MONTH FROM sale_date)) * 100 AS growth_percent
FROM transactions
GROUP BY product_id, EXTRACT(MONTH FROM sale_date)
ORDER BY product_id, month;

-- Divide customers into quartiles based on total spending
SELECT 
    customer_id,
    SUM(amount) AS total_spent,
    NTILE(4) OVER (ORDER BY SUM(amount) DESC) AS quartile,
    CUME_DIST() OVER (ORDER BY SUM(amount) DESC) AS cumulative_distribution
FROM transactions
GROUP BY customer_id
ORDER BY total_spent DESC;

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
  
