-- Delete Table Already Exits
DROP TABLE IF EXISTS Inventory;

-- Create a Table for Inventory Data
CREATE TABLE Inventory (
  product_id VARCHAR(10),
  product VARCHAR(50),
  stock INT,
  reorder_level INT,
  supplier VARCHAR(50),
  price INT
);

SELECT * FROM Inventory;

-- Insert Data Into the Table
COPY Inventory(product_id,product,stock,reorder_level,supplier,price)
FROM 'D:\All\Excel Projects\Excel + PowerBI\Inventory Management Analysis Project\inventory_dataset.csv'
DELIMITER ','
CSV HEADER;

-- Data Cleaning 

-- 🏆 1. Remove Duplicate Data

-- 🔍 Check Duplicates
SELECT product_id,COUNT(*)
FROM Inventory
GROUP BY product_id
HAVING COUNT(*) > 1;

-- If Duplicate Value Present in the table

-- ❌ Delete Duplicates
DELETE FROM Inventory
  WHERE ctid NOT IN(
      SELECT MIN(ctid)
	  FROM Inventory
	  GROUP BY product_id
)

-- 🧼 2. Handle NULL Values

-- ❌ Delete Duplicates
SELECT *
FROM Inventory
WHERE price IS NULL AND stock IS NULL;

-- If the Null Values Present in the table 
UPDATE Inventory
SET stock = 0
WHERE stock IS NULL;

-- 🔤 3. Fix Text Format

-- 👉 Uppercase / Lowercase
SELECT UPPER(product),LOWER(supplier)
FROM Inventory;

-- 👉 Remove Extra Spaces
UPDATE Inventory
SET product = TRIM(product);

-- 🔢 4. Fix Wrong Data (Negative Values)

SELECT *
FROM Inventory
WHERE stock < 0;

-- 👉 Fix:
UPDATE Inventory
SET stock = 0
WHERE stock < 0;

-- Most Important Thing 

-- 📊 5. Standardize Categories (Stock Status)
SELECT stock,reorder_level,
CASE 
   WHEN stock = 0 THEN 'Pending'
   WHEN stock <= reorder_level THEN 'Low Stock'
   ELSE 'Sufficient'
END AS Stock_Status
FROM Inventory;

-- Create a Column 
ALTER TABLE Inventory
ADD stock_status VARCHAR(30);

-- Update Stock_Statius
UPDATE Inventory
SET stock_status = 
CASE 
   WHEN stock = 0 THEN 'Pending'
   WHEN stock <= reorder_level THEN 'Low Stock'
   ELSE 'Sufficient'
END;

-- 💰 6. Recalculate Inventory Value
ALTER TABLE Inventory
ADD inventory_value BIGINT;

-- Multiply of Inventory Value with Help of (Stock * Price)
SELECT stock,price,(stock * price) as Inventory_Value
FROM Inventory;

-- Update Inventory Value
UPDATE Inventory
SET inventory_value = stock * price;

-- 💰 8 . Recalculate profit margin
ALTER TABLE Inventory
ADD profit_margin NUMERIC(10,2);

-- Multiply of Inventory Value with Help of (Stock * Price)
SELECT product_id,price,(price * 0.2) as Profit_Margin
FROM Inventory;

-- Update Inventory Value
UPDATE Inventory
SET profit_margin = price * 0.2;

-- 🧠 9. Check Data Types
SELECT column_name,data_type
FROM information_schema.columns
WHERE table_name = 'inventory';

-- 🧪 10. Final Clean Data Check
SELECT * FROM Inventory;

-- Solve to Business With Data analysis

-- 1.Total Stock 
SELECT SUM(stock) AS Total_Stock
FROM Inventory;

-- 2. Total Inventory Value
SELECT SUM(stock * price) AS Total_Inventory
FROM Inventory;

-- 3. Low Stock Items
SELECT COUNT(*) AS Low_Stock_Items
FROM Inventory
WHERE stock_status = 'Low Stock';

-- 4.Pending Items
SELECT COUNT(*) AS Pending_Items
FROM Inventory
WHERE stock_status = 'Pending';

-- 5.Stock Availability % 
SELECT
      ROUND((COUNT (CASE WHEN stock > 0 THEN  1 END) * 100.0 / COUNT(*)),2)
	   AS stock_availability_percentage
FROM Inventory;

-- 6.Top 5 Products by Value
SELECT product,SUM(stock * price) AS total_value
FROM Inventory
GROUP BY product
ORDER BY total_value DESC
LIMIT 5;

-- 7. Supplier Contribution
SELECT supplier,SUM(stock) AS Supplier_Contribution
FROM Inventory
GROUP BY supplier
ORDER BY Supplier_Contribution DESC;

-- 8.Average Price
SELECT AVG(price) FROM Inventory;

-- 9.Highest Value Product
SELECT product,MAX(stock * price) AS Highest_Value_Product
FROM Inventory
GROUP BY product
ORDER BY Highest_Value_Product DESC;

-- 10.Total Stock By Product
SELECT product,SUM(stock) AS Total_Stock
FROM Inventory
GROUP BY product
ORDER BY Total_Stock DESC;

-- 11.Inventory Value By Product
SELECT product,SUM(inventory_value) AS Total_Inventory
FROM Inventory
GROUP BY product
ORDER BY Total_Inventory DESC;

-- 12.Stock Analaysis
SELECT 
    product,
	supplier,
	stock_status,
	SUM(stock) AS Total_Stock,
	SUM(reorder_level) AS Total_Reorder_Level,
	SUM(inventory_value) AS Total_Inventory_Value
FROM Inventory
GROUP BY  product,supplier,stock_status

-- 13.Supplier with Inventory Value
SELECT supplier,
         SUM(inventory_value) AS Total_Supplier_Inventor
FROM Inventory
GROUP BY supplier
ORDER BY Total_Supplier_Inventor DESC;

-- 14.Profit Margin With Product
SELECT 
    product_id,
    product,
    profit_margin
FROM Inventory
GROUP BY  product_id,product,profit_margin;

-- 15.Profit Margin With supplier
SELECT 
    product_id,
    product,
    profit_margin,
	supplier
FROM Inventory
GROUP BY  product_id,product,profit_margin,supplier;

