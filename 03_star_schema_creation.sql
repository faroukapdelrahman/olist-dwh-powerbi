--=============================
--Create dwh schema for warehouse tables
--=============================
CREATE SCHEMA dwh;

--================================
--Create Dim TABLES
--================================
--Create Dim_Date (built from scratch to cover the order date range)

CREATE TABLE dwh.Dim_Date (
    date_key DATE PRIMARY KEY,
    year INT,
    month INT,
    month_name VARCHAR(20),
    day INT,
    day_name VARCHAR(20),
    quarter INT
);

DECLARE @StartDate DATE = '2016-01-01';
DECLARE @EndDate DATE = '2019-12-31';

WHILE @StartDate <= @EndDate
BEGIN
    INSERT INTO dwh.Dim_Date (date_key, year, month, month_name, day, day_name, quarter)
    VALUES (
        @StartDate,
        YEAR(@StartDate),
        MONTH(@StartDate),
        DATENAME(MONTH, @StartDate),
        DAY(@StartDate),
        DATENAME(WEEKDAY, @StartDate),
        DATEPART(QUARTER, @StartDate)
    );
    SET @StartDate = DATEADD(DAY, 1, @StartDate);
END;
-- Verify --
SELECT COUNT(*) AS TotalDates FROM dwh.Dim_Date;
--======================================
--Create dwh.Dim_Customer from staging table
SELECT 
    customer_id,
    customer_unique_id,
    customer_city,
    customer_state,
    customer_zip_code_prefix
INTO dwh.Dim_Customer
FROM dbo.customers;

-- Add primary key
ALTER TABLE dwh.Dim_Customer
ADD CONSTRAINT PK_Dim_Customer PRIMARY KEY (customer_id);

-- Verify
SELECT COUNT(*) AS TotalCustomers FROM dwh.Dim_Customer;
--======================================
--Create dwh.Dim_Product joined with category translation
SELECT 
    p.product_id,
    ISNULL(t.product_category_name_english, 'unknown') AS category_name,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
INTO dwh.Dim_Product
FROM dbo.products p
LEFT JOIN dbo.product_category_name_translation t
    ON p.product_category_name = t.product_category_name;

-- Add primary key
ALTER TABLE dwh.Dim_Product
ADD CONSTRAINT PK_Dim_Product PRIMARY KEY (product_id);

-- Verify
SELECT COUNT(*) AS TotalProducts FROM dwh.Dim_Product;
SELECT COUNT(*) AS UnknownCategoryCount FROM dwh.Dim_Product WHERE category_name = 'unknown';
--Investigate products with category but no matching translation
SELECT DISTINCT p.product_category_name
FROM dbo.products p
LEFT JOIN dbo.product_category_name_translation t
    ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND t.product_category_name IS NULL;
  --Fix Dim_Product for the two untranslated categories
UPDATE dwh.Dim_Product
SET category_name = 'PC Gamer'
WHERE product_id IN (
    SELECT product_id FROM dbo.products 
    WHERE product_category_name = 'pc_gamer'
);

UPDATE dwh.Dim_Product
SET category_name = 'Portable Kitchen Appliances'
WHERE product_id IN (
    SELECT product_id FROM dbo.products 
    WHERE product_category_name = 'portateis_cozinha_e_preparadores_de_alimentos'
);

-- Verify: unknown count should now be close to 610
SELECT COUNT(*) AS UnknownCategoryCount FROM dwh.Dim_Product WHERE category_name = 'unknown';
--======================================
--Create dwh.Dim_Seller from staging table
SELECT 
    seller_id,
    seller_city,
    seller_state,
    seller_zip_code_prefix
INTO dwh.Dim_Seller
FROM dbo.sellers;

-- Add primary key
ALTER TABLE dwh.Dim_Seller
ADD CONSTRAINT PK_Dim_Seller PRIMARY KEY (seller_id);

-- Verify
SELECT COUNT(*) AS TotalSellers FROM dwh.Dim_Seller;
--======================================
--Create dwh.Dim_Order from staging table
SELECT 
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_delivered_customer_date,
    order_estimated_delivery_date
INTO dwh.Dim_Order
FROM dbo.orders;

-- Add primary key
ALTER TABLE dwh.Dim_Order
ADD CONSTRAINT PK_Dim_Order PRIMARY KEY (order_id);

-- Verify
SELECT COUNT(*) AS TotalOrders FROM dwh.Dim_Order;
--===============================================
--CREATE FACTS TABLES
--===============================================
--create dwh.Fact_OrderItems from staging table
SELECT 
    order_id,
    order_item_id,
    product_id,
    seller_id,
    price,
    freight_value
INTO dwh.Fact_OrderItems
FROM dbo.order_items;

--Add composite primary key to Fact_OrderItems
ALTER TABLE dwh.Fact_OrderItems
ADD CONSTRAINT PK_Fact_OrderItems PRIMARY KEY (order_id, order_item_id);

-- Verify
SELECT COUNT(*) AS TotalOrderItems FROM dwh.Fact_OrderItems;
--======================================
--Create dwh.Fact_Payments from staging table
SELECT 
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
INTO dwh.Fact_Payments
FROM dbo.order_payments;

-- Add composite primary key
ALTER TABLE dwh.Fact_Payments
ADD CONSTRAINT PK_Fact_Payments PRIMARY KEY (order_id, payment_sequential);

-- Verify
SELECT COUNT(*) AS TotalPayments FROM dwh.Fact_Payments;
--======================================
--Create dwh.Fact_Reviews from staging table
SELECT 
    review_id,
    order_id,
    review_score,
    review_creation_date,
    review_answer_timestamp
INTO dwh.Fact_Reviews
FROM dbo.order_reviews;

--Add composite primary key to Fact_Reviews
ALTER TABLE dwh.Fact_Reviews
ADD CONSTRAINT PK_Fact_Reviews PRIMARY KEY (review_id, order_id);

-- Verify
SELECT COUNT(*) AS TotalReviews FROM dwh.Fact_Reviews;
