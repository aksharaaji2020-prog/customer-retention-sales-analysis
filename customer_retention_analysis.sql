-- Customer Retention & Sales Analysis
-- Dataset: customer_retention_sales_1000_orders.csv
-- Purpose: Sales performance, customer retention and business analysis

-- 1. Total revenue
SELECT SUM(Order_Value) AS total_revenue
FROM orders;

-- 2. Total number of orders
SELECT COUNT(*) AS total_orders
FROM orders;

-- 3. Total unique customers
SELECT COUNT(DISTINCT Customer_ID) AS total_customers
FROM orders;

-- 4. Average order value
SELECT AVG(Order_Value) AS average_order_value
FROM orders;

-- 5. Revenue by region
SELECT
    Region,
    SUM(Order_Value) AS revenue
FROM orders
GROUP BY Region
ORDER BY revenue DESC;

-- 6. Revenue by category
SELECT
    Category,
    SUM(Order_Value) AS revenue
FROM orders
GROUP BY Category
ORDER BY revenue DESC;

-- 7. Monthly revenue trend
SELECT
    DATE_FORMAT(Order_Date, '%Y-%m') AS order_month,
    SUM(Order_Value) AS monthly_revenue
FROM orders
GROUP BY DATE_FORMAT(Order_Date, '%Y-%m')
ORDER BY order_month;

-- 8. Number of orders by region
SELECT
    Region,
    COUNT(*) AS total_orders
FROM orders
GROUP BY Region
ORDER BY total_orders DESC;

-- 9. Average order value by customer segment
SELECT
    Customer_Segment,
    AVG(Order_Value) AS average_order_value
FROM orders
GROUP BY Customer_Segment
ORDER BY average_order_value DESC;

-- 10. Retained vs not-retained orders
SELECT
    Retention_Status,
    COUNT(*) AS order_count
FROM orders
GROUP BY Retention_Status;

-- 11. Customer retention by region
-- COUNT(DISTINCT Customer_ID) is used because retention is a customer-level metric.
SELECT
    Region,
    Retention_Status,
    COUNT(DISTINCT Customer_ID) AS customers
FROM orders
GROUP BY Region, Retention_Status
ORDER BY Region, Retention_Status;

-- 12. Customers with more than 3 orders
SELECT
    Customer_ID,
    COUNT(*) AS order_count
FROM orders
GROUP BY Customer_ID
HAVING COUNT(*) > 3
ORDER BY order_count DESC;

-- 13. Top 10 customers by total spending
SELECT
    Customer_ID,
    SUM(Order_Value) AS total_spent
FROM orders
GROUP BY Customer_ID
ORDER BY total_spent DESC
LIMIT 10;

-- 14. Average rating by category
SELECT
    Category,
    AVG(Rating) AS average_rating
FROM orders
GROUP BY Category
ORDER BY average_rating DESC;

-- 15. Complaint count by region
SELECT
    Region,
    SUM(Complaint_Count) AS total_complaints
FROM orders
GROUP BY Region
ORDER BY total_complaints DESC;

-- 16. Average delivery time by region
SELECT
    Region,
    AVG(Delivery_Time_Days) AS average_delivery_days
FROM orders
GROUP BY Region
ORDER BY average_delivery_days DESC;

-- 17. Customers whose total spending is above the average customer spending
WITH customer_spending AS (
    SELECT
        Customer_ID,
        SUM(Order_Value) AS total_spent
    FROM orders
    GROUP BY Customer_ID
)
SELECT
    Customer_ID,
    total_spent
FROM customer_spending
WHERE total_spent > (
    SELECT AVG(total_spent)
    FROM customer_spending
)
ORDER BY total_spent DESC;

-- 18. Rank customers by total spending
WITH customer_spending AS (
    SELECT
        Customer_ID,
        SUM(Order_Value) AS total_spent
    FROM orders
    GROUP BY Customer_ID
)
SELECT
    Customer_ID,
    total_spent,
    RANK() OVER (ORDER BY total_spent DESC) AS spending_rank
FROM customer_spending
ORDER BY spending_rank;

-- 19. Rank products by revenue within each category
WITH product_revenue AS (
    SELECT
        Category,
        Product,
        SUM(Order_Value) AS revenue
    FROM orders
    GROUP BY Category, Product
)
SELECT
    Category,
    Product,
    revenue,
    RANK() OVER (
        PARTITION BY Category
        ORDER BY revenue DESC
    ) AS category_rank
FROM product_revenue
ORDER BY Category, category_rank;

-- 20. Monthly revenue with previous month's revenue
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(Order_Date, '%Y-%m') AS order_month,
        SUM(Order_Value) AS revenue
    FROM orders
    GROUP BY DATE_FORMAT(Order_Date, '%Y-%m')
)
SELECT
    order_month,
    revenue,
    LAG(revenue) OVER (ORDER BY order_month) AS previous_month_revenue
FROM monthly_revenue
ORDER BY order_month;

-- 21. Monthly revenue growth percentage
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(Order_Date, '%Y-%m') AS order_month,
        SUM(Order_Value) AS revenue
    FROM orders
    GROUP BY DATE_FORMAT(Order_Date, '%Y-%m')
),
revenue_with_previous AS (
    SELECT
        order_month,
        revenue,
        LAG(revenue) OVER (ORDER BY order_month) AS previous_month_revenue
    FROM monthly_revenue
)
SELECT
    order_month,
    revenue,
    previous_month_revenue,
    ROUND(
        (revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0) * 100,
        2
    ) AS growth_percentage
FROM revenue_with_previous
ORDER BY order_month;

-- 22. Products generating above-average revenue
WITH product_revenue AS (
    SELECT
        Product,
        SUM(Order_Value) AS revenue
    FROM orders
    GROUP BY Product
)
SELECT
    Product,
    revenue
FROM product_revenue
WHERE revenue > (
    SELECT AVG(revenue)
    FROM product_revenue
)
ORDER BY revenue DESC;
