# PL/SQL Window Functions 
Names: IMPUNDU GATERA Brazia
ID: 29057

## Business Problem / Objective
This project analyzes sales data for a retail company to identify top products per region, track monthly revenue trends, and segment customers for targeted marketing. The goal is to provide actionable insights to improve business decisions and customer targeting.

## Database Schema
The database consists of three related tables with their corresponding values 
PK means primary key
FK means foreign key 

**Customers**  
- `customer_id` (PK)  
- `name`  
- `region`  

**Products**  
- `product_id` (PK)  
- `name`  
- `category`  

**Transactions**  
- `transaction_id` (PK)  
- `customer_id` (FK)  
- `product_id` (FK)  
- `sale_date`  
- `amount`  

**ER Diagram:** it's in the screenshots folder you can access it 

## Queries / Window Functions Implemented

1. **RANK()**  
   - Shows the top 5 customers by total revenue.  
   - Example query:  
     ```sql
     -- Rank customers by revenue
     SELECT customer_id, SUM(amount) AS total_sales,
            RANK() OVER (ORDER BY SUM(amount) DESC) AS rank
     FROM transactions
     GROUP BY customer_id;
     ```
   - Interpretation: This query identifies the highest spending customers.For ex: Customer 1001 is the top spender, indicating key customers for marketing focus.

2. **SUM() OVER()**  
   - Computes running monthly totals of sales to analyze trends.  
   - Interpretation: Running totals show that revenue increased steadily from January to March, reflecting positive sales growth.

3. **LAG()**  
   - Compares sales month-over-month to track growth.  
   - Interpretation: Using LAG, we see February sales decreased by 10% compared to January, likely due to fluatuations of the seasons
    
4. **NTILE(4)**  
   - Divides customers into quartiles based on spending.  
   - Interpretation: Top 25% of customers generate the majority of revenue, highlighting important segments for targeted promotions.

5. **Additional Window Functions**  
   - `ROW_NUMBER()`, `DENSE_RANK()`, `PERCENT_RANK()`, `AVG() OVER()`, `MIN()`, `MAX()`, `LEAD()`, `CUME_DIST()`  
   - Each is implemented with comments in the SQL script and corresponding screenshots in the `screenshots/` folder.

## Results Analysis
**Descriptive:**  
- Revenue increased steadily from January to March.  
- The top customers contribute disproportionately to total sales.  
- Some products are consistently top-selling in specific regions.

**Diagnostic:**  
- Increased revenue is likely due to seasonal demand and regional promotions.  
- High-spending customers align with frequent purchases and premium products.  
- Certain product categories perform better in particular regions.

**Prescriptive**
- Focus marketing campaigns on top quartile customers.  
- Ensure stock availability of top-selling products in key regions.  
- Monitor slow-moving products and consider promotions or discounts.

## References
1. Oracle Documentation – [https://docs.oracle.com](https://docs.oracle.com)  
2. W3Schools SQL Tutorial – [https://www.w3schools.com/sql/](https://www.w3schools.com/sql/)  
3. GeeksforGeeks – SQL Window Functions – [https://www.geeksforgeeks.org/sql-window-functions/](https://www.geeksforgeeks.org/sql-window-functions/)  

## Academic Integrity Statement
All sources were properly cited. Implementations and analysis represent original work.
---

