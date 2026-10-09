--========================
--Add delivery status column to Dim_Order
--========================
ALTER TABLE dwh.Dim_Order
ADD delivery_status NVARCHAR(20);

UPDATE dwh.Dim_Order
SET delivery_status = 
    CASE 
        WHEN order_delivered_customer_date IS NULL THEN 'Not Delivered'
        WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 'On Time'
        ELSE 'Late'
    END;

-- Verify
SELECT delivery_status, COUNT(*) AS cnt FROM dwh.Dim_Order GROUP BY delivery_status;