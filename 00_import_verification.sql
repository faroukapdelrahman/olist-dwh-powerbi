select 'customers' as "table name", count(*) "number of rows" from  [dbo].[customers] union all
select 'geolocation' , count(*)  from [dbo].[geolocation] union all
select 'order_items' , count(*)  from [dbo].[order_items] union all
select 'order_payments' , count(*)  from [dbo].[order_payments] union all
select 'order_reviews' , count(*)from [dbo].[order_reviews] union all
select 'orders' , count(*)  from [dbo].[orders] union all
select 'product_category_name_translation' , count(*) from [dbo].[product_category_name_translation] union all
select 'products' , count(*)  from [dbo].[products] union all
select 'sellers', count(*)  from sellers




