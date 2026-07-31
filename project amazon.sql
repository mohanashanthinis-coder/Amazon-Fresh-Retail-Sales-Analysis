create database amazon;
select * from amazon.customers;
select * from amazon.order_details;
select * from amazon.orders;
select * from amazon.products;
select * from amazon.reviews;
select * from amazon.suppliers;

-- TASK 3 --
-- retrieve all customers from a specific city --
select * from amazon.customers
where city ='Bettyport';

-- fetch all the proudcts under fruits category --
select * from amazon.products
where category='fruits';

-- Task 4: Write DDL statements to recreate the Customers table with the following constraints:
-- CustomerID as the primary key.
-- Ensure Age cannot be null and must be greater than 18.
-- Add a unique constraint for Name.

alter table amazon.customers
modify age int not null;

alter table amazon.customers
add constraint chk_age
check (age>=18);

alter table amazon.customers
add constraint uq_name
unique (name);

-- task 5Insert 3 new rows into the Products table using INSERT statements.
insert into amazon.products 
(productID,ProductName,category,SubCategory,PricePerUnit,StockQuantity,supplierID) values
('021ddaafa-5dbc-4d92-acd9-8a78b4158667','enter dair','dairy','sub-dairy-3',999,287,'833a86c4-88c3-42cb-a39d-8c71ce83156767'),
('030ff542-d5f6-4355-9654-90ae0e38702c','word fruit','fruits','sub-fruits-4',354,234,'7bdf582a-c54d-45b9-a4ea-2018f5ef970f'),
('04c600c0-b84f-4de8-a71e-205567c610eb','find mea','meat','sub-meat-3',456,345,'1cd26290-be3e-4bc7-bed55-c0d0ece13a4b');

-- 6 Update the stock quantity of a product where ProductID matches a specific ID.
DESC amazon.products;
USE amazon;
UPDATE products
SET StockQuantity = 100
WHERE ProductID = '021ddaafa-5dbc-4d92-acd9-8a78b4158667';

-- 7 Delete a supplier from the Suppliers table where their city matches a specific value.
SET SQL_SAFE_UPDATES = 0;
DELETE FROM suppliers
WHERE City = 'South Ana';
SET SQL_SAFE_UPDATES = 1;

-- Task 8: Use SQL constraints to:
-- Add a CHECK constraint to ensure that ratings in the Reviews table are between 1 and 5.

alter table amazon.reviews
add constraint chk_rtng 
check (rating between 1 and 5);

-- -- Add a DEFAULT constraint for the PrimeMember column in the Customers table (default value: "No").

ALTER TABLE amazon.customers
MODIFY COLUMN PrimeMember VARCHAR(10) DEFAULT 'No';

-- 9 WHERE clause to find orders placed after 2024-01-01.
select * from amazon.orders where orderdate >'2024-01-01';

-- HAVING clause to list products with average ratings greater than 4.
select productid,avg(rating) as avg_rating from amazon.reviews
group by ProductID having avg(rating)>4;

-- GROUP BY and ORDER BY clauses to rank products by total sales.
select productid,sum(quantity*UnitPrice) as totalsales from amazon.order_details
group by ProductID order by totalsales desc;

-- 10 calculate each customer's total spending
SELECT c.CustomerID,c.Name,SUM(o.OrderAmount) AS TotalSpending FROM amazon.customers c
JOIN amazon.orders o
ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.Name;


-- Rank customers based on their spending.
select c.customerID,c.name,sum(o.orderamount) as totalspending,rank() over(partition by CustomerID order by sum(o.orderamount) desc) as rankamount
from amazon.customers c
join amazon.orders o
ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.Name;

-- Identify customers who have spent more than ₹5,000.
select c.customerid,c.name,sum(o.orderamount) as totalspending from amazon.customers c 
join amazon.orders o
ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.Name
having totalspending>5000;

-- task 11 Join the Orders and OrderDetails tables to calculate total revenue per order.
select o.orderid,sum(o.orderamount*od.unitprice-od.discount) as totalrevenue
from amazon.orders o
join amazon.order_details od
on o.OrderID=od.orderid
group by o.OrderID;

-- Identify customers who placed the most orders in a specific time period.
select c.customerid,c.name,count(o.orderid) as totalorders 
from amazon.customers c
join amazon.orders o
on o.customerid=c.CustomerID
where o.orderdate between '1-1-2024' and '1-1-2025'
group by c.customerid,c.name
order by totalorders desc;

-- Find the supplier with the most products in stock.
select productid,productname,supplierid,sum(stockquantity) as totalstock from amazon.products
group by productid,productname,supplierid order by totalstock desc limit 30;

-- task 12 Separate product categories and subcategories into a new table.
-- -- Create foreign keys to maintain relationships.
create table amazon.product_categories (
categoryid int auto_increment primary key,
category varchar(100),
subcategory varchar(100));

DESC amazon.products;

INSERT INTO amazon.product_categories (category, subcategory)
SELECT DISTINCT category, subcategory
FROM amazon.products;

ALTER TABLE amazon.products
ADD CategoryID INT;

ALTER TABLE amazon.products
ADD CONSTRAINT fk_product_category
FOREIGN KEY (CategoryID)
REFERENCES amazon.product_categories(CategoryID);


-- Task 13: Write a subquery to:
-- Identify the top 3 products based on sales revenue.

select productid,sum(quantity*unitprice) as salesrevenue from amazon.order_details
group by ProductID order by salesrevenue desc limit 3;

SELECT p.ProductID,p.ProductName,t.SalesRevenue
FROM amazon.products p
JOIN (SELECT ProductID,SUM(Quantity * UnitPrice) AS SalesRevenue
FROM amazon.order_details GROUP BY ProductID ORDER BY SalesRevenue DESC LIMIT 3) t
ON p.ProductID = t.ProductID;

---- Find customers who haven’t placed any orders yet.
select customerid,name from customers where CustomerID not in (select CustomerID from orders);

-- Task 14: Provide actionable insights:
-- Which cities have the highest concentration of Prime members?

Select City,COUNT(CustomerID) AS PrimeMembers FROM amazon.customers
WHERE PrimeMember = 'Yes' GROUP BY City
ORDER BY PrimeMembers DESC;

--  What are the top 3 most frequently ordered categories?

SELECT p.Category,COUNT(od.OrderID) AS TotalOrders
FROM amazon.order_details od
JOIN amazon.products p
ON od.ProductID = p.ProductID
GROUP BY p.Category
ORDER BY TotalOrders DESC
LIMIT 3;



