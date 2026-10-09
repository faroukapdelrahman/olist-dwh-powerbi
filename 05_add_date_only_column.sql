-- ===================================================
-- Add date-only column to Dim_Order
-- Fixes the Dim_Date relationship: order_purchase_timestamp
-- includes time, which prevented correct matching with
-- Dim_Date's date-only date_key column
-- ===================================================

ALTER TABLE dwh.Dim_Order
ADD order_purchase_date DATE;

UPDATE dwh.Dim_Order
SET order_purchase_date = CAST(order_purchase_timestamp AS DATE);

-- Verify
SELECT TOP 5 order_id, order_purchase_timestamp, order_purchase_date 
FROM dwh.Dim_Order;