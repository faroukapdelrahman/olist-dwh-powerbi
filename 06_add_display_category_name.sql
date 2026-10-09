--===========================
--Add a display-friendly category name column to Dim_Product
--===========================
ALTER TABLE dwh.Dim_Product
ADD category_name_display NVARCHAR(100);

UPDATE dwh.Dim_Product
SET category_name_display = 
    UPPER(LEFT(REPLACE(category_name, '_', ' '), 1)) + 
    SUBSTRING(REPLACE(category_name, '_', ' '), 2, LEN(category_name));

-- Verify
SELECT TOP 10 category_name, category_name_display FROM dwh.Dim_Product;