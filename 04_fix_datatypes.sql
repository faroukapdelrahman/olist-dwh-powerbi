--Fix price and freight_value data types to DECIMAL for accurate financial calculations

ALTER TABLE dwh.Fact_OrderItems
ALTER COLUMN price DECIMAL(10,2);

ALTER TABLE dwh.Fact_OrderItems
ALTER COLUMN freight_value DECIMAL(10,2);

-- Verify
SELECT TOP 5 order_id, price, freight_value FROM dwh.Fact_OrderItems;