-- ===================================================
-- Data Quality Check: orders table
-- ===================================================

-- Check for NULLs in key columns
SELECT 
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END) AS null_status,
    SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS null_purchase_date,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS null_delivered_date,
    SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END) AS null_estimated_date
FROM dbo.orders;

--Check order status breakdown for orders with missing delivery date
SELECT order_status, COUNT(*) AS cnt
FROM dbo.orders
WHERE order_delivered_customer_date IS NULL
GROUP BY order_status
ORDER BY cnt DESC;
--Investigate delivered orders with missing delivery date
SELECT order_id, customer_id, order_status, 
       order_purchase_timestamp, order_delivered_customer_date, order_estimated_delivery_date
FROM dbo.orders
WHERE order_status = 'delivered' 
  AND order_delivered_customer_date IS NULL;

-- Check for duplicate order_id IN orders table
SELECT order_id, COUNT(*) AS cnt
FROM dbo.orders
GROUP BY order_id
HAVING COUNT(*) > 1;
--========================================
--Check for NULLs in key columns of order_items
--========================================
SELECT 
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS null_seller_id,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS null_price,
    SUM(CASE WHEN freight_value IS NULL THEN 1 ELSE 0 END) AS null_freight
FROM dbo.order_items;
--Check for negative or zero price/freight in order_items
SELECT COUNT(*) AS invalid_price_rows
FROM dbo.order_items
WHERE price <= 0 OR freight_value < 0;
--=========================================
--Check for NULLs and duplicates in customers
--=========================================
SELECT 
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN customer_unique_id IS NULL THEN 1 ELSE 0 END) AS null_unique_id,
    SUM(CASE WHEN customer_city IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN customer_state IS NULL THEN 1 ELSE 0 END) AS null_state,
    SUM(CASE WHEN customer_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS null_zip
FROM dbo.customers;
--Check for duplicate customer_id
SELECT customer_id, COUNT(*) AS cnt
FROM dbo.customers
GROUP BY customer_id
HAVING COUNT(*) > 1;
--=========================================
--Check for NULLs in key columns of products
--=========================================
SELECT 
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS null_category,
    SUM(CASE WHEN product_weight_g IS NULL THEN 1 ELSE 0 END) AS null_weight,
    SUM(CASE WHEN product_length_cm IS NULL THEN 1 ELSE 0 END) AS null_length,
    SUM(CASE WHEN product_height_cm IS NULL THEN 1 ELSE 0 END) AS null_height,
    SUM(CASE WHEN product_width_cm IS NULL THEN 1 ELSE 0 END) AS null_width
FROM dbo.products;
--Check for duplicate product_id
SELECT product_id, COUNT(*) AS cnt
FROM dbo.products
GROUP BY product_id
HAVING COUNT(*) > 1;
--=========================================
--Check for NULLs and duplicates in sellers
--=========================================
SELECT 
    SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS null_seller_id,
    SUM(CASE WHEN seller_city IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN seller_state IS NULL THEN 1 ELSE 0 END) AS null_state,
    SUM(CASE WHEN seller_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS null_zip
FROM dbo.sellers;
--Check for duplicate seller_id
SELECT seller_id, COUNT(*) AS cnt
FROM dbo.sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;
--=========================================
--Check for NULLs in key columns of order_payments
--=========================================
SELECT 
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN payment_type IS NULL THEN 1 ELSE 0 END) AS null_payment_type,
    SUM(CASE WHEN payment_installments IS NULL THEN 1 ELSE 0 END) AS null_installments,
    SUM(CASE WHEN payment_value IS NULL THEN 1 ELSE 0 END) AS null_payment_value
FROM dbo.order_payments;
-- Check for invalid payment values
SELECT COUNT(*) AS invalid_rows
FROM dbo.order_payments
WHERE payment_value < 0 OR payment_installments < 0;
--Check distinct payment types
SELECT payment_type, COUNT(*) AS cnt
FROM dbo.order_payments
GROUP BY payment_type
ORDER BY cnt DESC;

--=========================================
--Check for NULLs in key columns of order_reviews
--=========================================
SELECT 
    SUM(CASE WHEN review_id IS NULL THEN 1 ELSE 0 END) AS null_review_id,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN review_score IS NULL THEN 1 ELSE 0 END) AS null_score,
    SUM(CASE WHEN review_comment_title IS NULL THEN 1 ELSE 0 END) AS null_title,
    SUM(CASE WHEN review_comment_message IS NULL THEN 1 ELSE 0 END) AS null_message
FROM dbo.order_reviews;
--Check review_score value range
SELECT review_score, COUNT(*) AS cnt
FROM dbo.order_reviews
GROUP BY review_score
ORDER BY review_score;
--Check for duplicate review_id
SELECT review_id, COUNT(*) AS cnt
FROM dbo.order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1;
--Check if duplicate review_id rows are identical or different
SELECT review_id, COUNT(DISTINCT order_id) AS distinct_orders, COUNT(*) AS total_rows
FROM dbo.order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1
ORDER BY total_rows DESC;
---->>>>
--Document review_id duplication behavior (no fix needed)
----<<<<
-- Note: review_id can repeat across different order_id values.
-- This is expected behavior in the raw Olist dataset, not an import error.
-- Verified: every duplicated review_id maps to distinct order_ids (no true duplicate rows).
-- No cleaning action taken.
--=========================================
--check on geolocation and category translation tables
--=========================================
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT geolocation_zip_code_prefix) AS distinct_zips
FROM dbo.geolocation;
--
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT product_category_name) AS distinct_categories
FROM dbo.product_category_name_translation;