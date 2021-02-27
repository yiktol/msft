-- Display all Customers
USE BikeStores;
GO
SELECT *
FROM sales.customers
ORDER BY last_name ASC;
_____________________________

-- Display newly added Customer
USE BikeStores;
GO
SELECT *
FROM sales.customers
WHERE last_name='Tolentino';
______________________________

-- Delete Customer
DELETE 
FROM sales.customers 
WHERE last_name='Tolentino';



-- ====  
-- Enable Database for CDC template   
-- ====  
USE BikeStores;  
GO  
EXEC sys.sp_cdc_enable_db  
GO  

-- =======  
-- Disable Database for Change Data Capture template   
-- =======  
USE BikeStores; 
GO  
EXEC sys.sp_cdc_disable_db  
GO  



USE BikeStores;           
CREATE USER dms_user FOR LOGIN dms_user; 
ALTER ROLE [db_datareader] ADD MEMBER dms_user; 
GRANT VIEW DATABASE STATE to dms_user ; 