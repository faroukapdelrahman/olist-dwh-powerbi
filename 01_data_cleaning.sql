-- ===================================================
-- Data Cleaning: product_category_name_translation
-- Fixed header row imported as data + renamed columns
-- ===================================================

DELETE FROM dbo.product_category_name_translation
WHERE Column1 = 'product_category_name';

EXEC sp_rename 'dbo.product_category_name_translation.Column1', 'product_category_name', 'COLUMN';
EXEC sp_rename 'dbo.product_category_name_translation.Column2', 'product_category_name_english', 'COLUMN';

-- Verify
SELECT COUNT(*) AS TotalRows FROM dbo.product_category_name_translation;
SELECT TOP 5 * FROM dbo.product_category_name_translation;