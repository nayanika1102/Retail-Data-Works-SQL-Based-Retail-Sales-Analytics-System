-- Create Tables
CREATE TABLE CountryRegion (
    CountryRegionCode NVARCHAR(10) PRIMARY KEY,
    Name NVARCHAR(100)
);

CREATE TABLE StateProvince (
    StateProvinceID INT PRIMARY KEY,
    CountryRegionCode NVARCHAR(10),
    FOREIGN KEY (CountryRegionCode) REFERENCES CountryRegion(CountryRegionCode)
);

CREATE TABLE Address (
    AddressID INT PRIMARY KEY,
    City NVARCHAR(50),
    StateProvinceID INT,
    PostalCode NVARCHAR(20),
    FOREIGN KEY (StateProvinceID) REFERENCES StateProvince(StateProvinceID)
);

CREATE TABLE Person (
    BusinessEntityID INT PRIMARY KEY,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50)
);

CREATE TABLE BusinessEntityAddress (
    BusinessEntityID INT,
    AddressID INT,
    PRIMARY KEY (BusinessEntityID, AddressID),
    FOREIGN KEY (BusinessEntityID) REFERENCES Person(BusinessEntityID),
    FOREIGN KEY (AddressID) REFERENCES Address(AddressID)
);

CREATE TABLE PhoneNumberType (
    PhoneNumberTypeID INT PRIMARY KEY,
    Name NVARCHAR(50)
);

CREATE TABLE PersonPhone (
    BusinessEntityID INT,
    PhoneNumber NVARCHAR(20),
    PhoneNumberTypeID INT,
    FOREIGN KEY (BusinessEntityID) REFERENCES Person(BusinessEntityID),
    FOREIGN KEY (PhoneNumberTypeID) REFERENCES PhoneNumberType(PhoneNumberTypeID)
);

CREATE TABLE Store (
    BusinessEntityID INT PRIMARY KEY,
    Name NVARCHAR(100)
);

CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY,
    PersonID INT,
    StoreID INT,
    FOREIGN KEY (PersonID) REFERENCES Person(BusinessEntityID),
    FOREIGN KEY (StoreID) REFERENCES Store(BusinessEntityID)
);

CREATE TABLE Employee (
    BusinessEntityID INT PRIMARY KEY,
    OrganizationNode HIERARCHYID,
    FOREIGN KEY (BusinessEntityID) REFERENCES Person(BusinessEntityID)
);

CREATE TABLE SalesOrderHeader (
    SalesOrderID INT PRIMARY KEY,
    CustomerID INT,
    SalesPersonID INT,
    OrderDate DATE,
    ShipToAddressID INT,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (SalesPersonID) REFERENCES Employee(BusinessEntityID),
    FOREIGN KEY (ShipToAddressID) REFERENCES Address(AddressID)
);

CREATE TABLE ProductCategory (
    ProductCategoryID INT PRIMARY KEY,
    Name NVARCHAR(100)
);

CREATE TABLE ProductSubcategory (
    ProductSubcategoryID INT PRIMARY KEY,
    ProductCategoryID INT,
    FOREIGN KEY (ProductCategoryID) REFERENCES ProductCategory(ProductCategoryID)
);

CREATE TABLE Product (
    ProductID INT PRIMARY KEY,
    Name NVARCHAR(100),
    ProductSubcategoryID INT,
    DiscontinuedDate DATE,
    FOREIGN KEY (ProductSubcategoryID) REFERENCES ProductSubcategory(ProductSubcategoryID)
);

CREATE TABLE SalesOrderDetail (
    SalesOrderID INT,
    ProductID INT,
    UnitPrice DECIMAL(10, 2),
    OrderQty INT,
    PRIMARY KEY (SalesOrderID, ProductID),
    FOREIGN KEY (SalesOrderID) REFERENCES SalesOrderHeader(SalesOrderID),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);

CREATE TABLE ProductInventory (
    ProductID INT,
    Quantity INT,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);

CREATE TABLE Vendor (
    BusinessEntityID INT PRIMARY KEY,
    Name NVARCHAR(100)
);

CREATE TABLE ProductVendor (
    ProductID INT,
    BusinessEntityID INT,
    PRIMARY KEY (ProductID, BusinessEntityID),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
    FOREIGN KEY (BusinessEntityID) REFERENCES Vendor(BusinessEntityID)
);

CREATE TABLE PurchaseOrderDetail (
    PurchaseOrderID INT,
    ProductID INT,
    OrderQty INT,
    PRIMARY KEY (PurchaseOrderID, ProductID),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);

-- Insert sample data
-- Countries
INSERT INTO CountryRegion VALUES ('US', 'United States'), ('UK', 'United Kingdom'), ('FR', 'France'), ('CA', 'Canada');

-- StateProvince
INSERT INTO StateProvince VALUES (1, 'US'), (2, 'UK'), (3, 'FR'), (4, 'CA');

-- Address
INSERT INTO Address VALUES (1, 'New York', 1, '10001'), (2, 'London', 2, 'E1'), (3, 'Paris', 3, '75001'), (4, 'Toronto', 4, 'M5H');

-- Person
INSERT INTO Person VALUES (1, 'John', 'Doe'), (2, 'Jane', 'Smith'), (3, 'Alice', 'Brown'), (100, 'Manager', 'One'), (101, 'Employee', 'One');

-- Store
INSERT INTO Store VALUES (1, 'AlphaN'), (2, 'BetaX');

-- BusinessEntityAddress
INSERT INTO BusinessEntityAddress VALUES (1, 1), (2, 2), (3, 3), (100, 1), (101, 2);

-- Phone Types
INSERT INTO PhoneNumberType VALUES (1, 'FAX'), (2, 'MOBILE');

-- Phones
INSERT INTO PersonPhone VALUES (1, '1234567890', 2), (2, NULL, 1), (100, '5551001001', 2), (101, '5551011011', 2);

-- Customer
INSERT INTO Customer VALUES (1, 1, 1), (2, 2, 2), (3, 3, NULL);

-- Product Categories and Subcategories
INSERT INTO ProductCategory VALUES (1, 'Beverages');
INSERT INTO ProductSubcategory VALUES (1, 1);

-- Product
INSERT INTO Product VALUES (1, 'Chai', 1, NULL), (2, 'Tofu', 1, '1998-01-01'), (3, 'Apple Juice', 1, NULL);

-- Product Inventory
INSERT INTO ProductInventory VALUES (1, 100), (2, 5), (3, 9);

-- Vendor
INSERT INTO Vendor VALUES (1, 'Specialty Biscuits, Ltd.');

-- ProductVendor
INSERT INTO ProductVendor VALUES (1, 1), (2, 1);

-- PurchaseOrderDetail
INSERT INTO PurchaseOrderDetail VALUES (1, 1, 10), (2, 2, 5);

-- Employees
INSERT INTO Employee VALUES 
(100, HIERARCHYID::GetRoot()), 
(101, HIERARCHYID::GetRoot().GetDescendant(NULL, NULL));

-- Sales Orders
INSERT INTO SalesOrderHeader VALUES 
(10, 1, 100, '1996-12-31', 1), 
(11, 2, 101, '1997-01-01', 2), 
(12, 3, 100, '1997-06-15', 3);

-- Sales Order Details
INSERT INTO SalesOrderDetail VALUES 
(10, 1, 20.00, 15), 
(10, 3, 10.00, 5), 
(11, 2, 30.00, 20), 
(12, 2, 30.00, 30);

-- Queries
-- 1. List of all customers
SELECT * FROM Customer;

-- 2. List of all customers where store name ending in N
SELECT c.* 
FROM Customer c
JOIN Store s ON c.StoreID = s.BusinessEntityID
WHERE s.Name LIKE '%N';

-- 3. List of all customers who live in Berlin or London
SELECT DISTINCT c.*
FROM Customer c
JOIN Person pp ON c.PersonID = pp.BusinessEntityID
JOIN BusinessEntityAddress bea ON pp.BusinessEntityID = bea.BusinessEntityID
JOIN Address a ON bea.AddressID = a.AddressID
WHERE a.City IN ('Berlin', 'London');

-- 4. List of all customers who live in UK or USA
SELECT DISTINCT c.*
FROM Customer c
JOIN Person pp ON c.PersonID = pp.BusinessEntityID
JOIN BusinessEntityAddress bea ON pp.BusinessEntityID = bea.BusinessEntityID
JOIN Address a ON bea.AddressID = a.AddressID
JOIN StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name IN ('United Kingdom', 'United States');

-- 5. List of all products sorted by product name
SELECT * FROM Product ORDER BY Name;

-- 6. List of all products where product name starts with an A
SELECT * FROM Product WHERE Name LIKE 'A%';

-- 7. List of customers who ever placed an order
SELECT DISTINCT c.*
FROM Customer c
JOIN SalesOrderHeader soh ON c.CustomerID = soh.CustomerID;

-- 8. List of Customers who live in London and have bought chai
SELECT DISTINCT c.*
FROM Customer c
JOIN SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Product p ON sod.ProductID = p.ProductID
JOIN Person pp ON c.PersonID = pp.BusinessEntityID
JOIN BusinessEntityAddress bea ON pp.BusinessEntityID = bea.BusinessEntityID
JOIN Address a ON bea.AddressID = a.AddressID
WHERE a.City = 'London' AND p.Name = 'Chai';

-- 9. List of customers who never place an order
SELECT * FROM Customer
WHERE CustomerID NOT IN (SELECT CustomerID FROM SalesOrderHeader);

-- 10. List of customers who ordered Tofu
SELECT DISTINCT c.*
FROM Customer c
JOIN SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Product p ON sod.ProductID = p.ProductID
WHERE p.Name = 'Tofu';

-- 11. Details of first order of the system
SELECT TOP 1 * FROM SalesOrderHeader ORDER BY OrderDate;

-- 12. Find the details of most expensive order date
SELECT TOP 1 soh.*, SUM(sod.UnitPrice * sod.OrderQty) AS TotalAmount
FROM SalesOrderHeader soh
JOIN SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY soh.SalesOrderID, soh.CustomerID, soh.SalesPersonID, soh.OrderDate, soh.ShipToAddressID
ORDER BY TotalAmount DESC;

-- 13. For each order get the OrderID and Average quantity of items in that order
SELECT SalesOrderID, AVG(CAST(OrderQty AS DECIMAL)) AS AvgQuantity
FROM SalesOrderDetail
GROUP BY SalesOrderID;

-- 14. For each order get the orderID, minimum quantity and maximum quantity for that order
SELECT SalesOrderID, MIN(OrderQty) AS MinQuantity, MAX(OrderQty) AS MaxQuantity
FROM SalesOrderDetail
GROUP BY SalesOrderID;

-- 15. Get a list of all managers and total number of employees who report to them
SELECT 
    m.BusinessEntityID AS ManagerID, 
    COUNT(e.BusinessEntityID) AS NumberOfEmployees
FROM Employee e
JOIN Employee m ON e.OrganizationNode.GetAncestor(1) = m.OrganizationNode
GROUP BY m.BusinessEntityID;

-- 16. Get the OrderID and the total quantity for each order that has a total quantity of greater than 300
SELECT SalesOrderID, SUM(OrderQty) AS TotalQuantity
FROM SalesOrderDetail
GROUP BY SalesOrderID
HAVING SUM(OrderQty) > 300;

-- 17. List of all orders placed on or after 1996/12/31
SELECT * FROM SalesOrderHeader WHERE OrderDate >= '1996-12-31';

-- 18. List of all orders shipped to Canada
SELECT soh.*
FROM SalesOrderHeader soh
JOIN Address a ON soh.ShipToAddressID = a.AddressID
JOIN StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name = 'Canada';

-- 19. List of all orders with order total > 200
SELECT soh.*, SUM(sod.UnitPrice * sod.OrderQty) AS OrderTotal
FROM SalesOrderHeader soh
JOIN SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY soh.SalesOrderID, soh.CustomerID, soh.SalesPersonID, soh.OrderDate, soh.ShipToAddressID
HAVING SUM(sod.UnitPrice * sod.OrderQty) > 200;

-- 20. List of countries and sales made in each country
SELECT cr.Name AS Country, SUM(sod.UnitPrice * sod.OrderQty) AS TotalSales
FROM SalesOrderHeader soh
JOIN SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Address a ON soh.ShipToAddressID = a.AddressID
JOIN StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.Name;

-- 21. List of Customer ContactName and number of orders they placed
SELECT pp.FirstName + ' ' + pp.LastName AS ContactName, COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM Customer c
JOIN SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Person pp ON c.PersonID = pp.BusinessEntityID
GROUP BY pp.FirstName, pp.LastName;

-- 22. List of customer contact names who have placed more than 3 orders
SELECT pp.FirstName + ' ' + pp.LastName AS ContactName
FROM Customer c
JOIN SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Person pp ON c.PersonID = pp.BusinessEntityID
GROUP BY pp.FirstName, pp.LastName
HAVING COUNT(soh.SalesOrderID) > 3;

-- 23. List of discontinued products which were ordered between 1/1/1997 and 1/1/1998
SELECT DISTINCT p.*
FROM Product p
JOIN SalesOrderDetail sod ON p.ProductID = sod.ProductID
JOIN SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
WHERE p.DiscontinuedDate IS NOT NULL 
  AND soh.OrderDate BETWEEN '1997-01-01' AND '1998-01-01';

-- 24. List of employee firstname, lastname, supervisor FirstName, LastName
SELECT
    e.BusinessEntityID AS EmployeeID,
    p.FirstName AS EmployeeFirstName,
    p.LastName AS EmployeeLastName,
    m.BusinessEntityID AS ManagerID,
    pm.FirstName AS ManagerFirstName,
    pm.LastName AS ManagerLastName
FROM Employee AS e
INNER JOIN Person AS p ON e.BusinessEntityID = p.BusinessEntityID
LEFT JOIN Employee AS m ON e.OrganizationNode.GetAncestor(1) = m.OrganizationNode
LEFT JOIN Person AS pm ON m.BusinessEntityID = pm.BusinessEntityID;

-- 25. List of Employees id and total sale conducted by employee
SELECT e.BusinessEntityID, SUM(sod.UnitPrice * sod.OrderQty) AS TotalSales
FROM Employee e
JOIN SalesOrderHeader soh ON e.BusinessEntityID = soh.SalesPersonID
JOIN SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY e.BusinessEntityID;

-- 26. List of employees whose FirstName contains character a
SELECT 
    e.BusinessEntityID,
    p.FirstName,
    p.LastName
FROM Employee e
JOIN Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE p.FirstName LIKE '%a%';

-- 27. List of managers who have more than four people reporting to them
SELECT 
    m.BusinessEntityID AS ManagerID,
    pm.FirstName AS ManagerFirstName,
    pm.LastName AS ManagerLastName,
    COUNT(e.BusinessEntityID) AS NumberOfReports
FROM Employee e
JOIN Employee m ON e.OrganizationNode.GetAncestor(1) = m.OrganizationNode
JOIN Person pm ON m.BusinessEntityID = pm.BusinessEntityID
GROUP BY m.BusinessEntityID, pm.FirstName, pm.LastName
HAVING COUNT(e.BusinessEntityID) > 4;

-- 28. List of Orders and ProductNames
SELECT soh.SalesOrderID, p.Name AS ProductName
FROM SalesOrderHeader soh
JOIN SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Product p ON sod.ProductID = p.ProductID;

-- 29. List of orders placed by the best customer
SELECT soh.*
FROM SalesOrderHeader soh
JOIN (
    SELECT TOP 1 CustomerID, SUM(sod.UnitPrice * sod.OrderQty) AS TotalSpent
    FROM SalesOrderHeader soh
    JOIN SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    GROUP BY CustomerID
    ORDER BY TotalSpent DESC
) AS BestCustomer ON soh.CustomerID = BestCustomer.CustomerID;

-- 30. List of orders placed by customers who do not have a Fax number
SELECT soh.*
FROM SalesOrderHeader soh
JOIN Customer c ON soh.CustomerID = c.CustomerID
LEFT JOIN PersonPhone pp ON c.PersonID = pp.BusinessEntityID AND pp.PhoneNumberTypeID = 1 -- FAX
WHERE pp.PhoneNumber IS NULL;

-- 31. List of Postal codes where the product Tofu was shipped
SELECT DISTINCT a.PostalCode
FROM SalesOrderHeader soh
JOIN SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Product p ON sod.ProductID = p.ProductID
JOIN Address a ON soh.ShipToAddressID = a.AddressID
WHERE p.Name = 'Tofu';

-- 32. List of product Names that were shipped to France
SELECT DISTINCT p.Name
FROM SalesOrderHeader soh
JOIN SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Product p ON sod.ProductID = p.ProductID
JOIN Address a ON soh.ShipToAddressID = a.AddressID
JOIN StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name = 'France';

-- 33. List of ProductNames and Categories for the supplier 'Specialty Biscuits, Ltd.'
SELECT p.Name AS ProductName, pc.Name AS CategoryName
FROM Product p
JOIN ProductVendor pv ON p.ProductID = pv.ProductID
JOIN Vendor v ON pv.BusinessEntityID = v.BusinessEntityID
JOIN ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
WHERE v.Name = 'Specialty Biscuits, pvt ltd';

SELECT p.* 
FROM Product p
LEFT JOIN SalesOrderDetail sod ON p.ProductID = sod.ProductID
WHERE sod.ProductID IS NULL;

-- 35. List of products where units in stock is less than 10 and units on order are 0
SELECT p.ProductID, p.Name, pi.Quantity
FROM Product p
JOIN ProductInventory pi ON p.ProductID = pi.ProductID
LEFT JOIN (
    SELECT ProductID, SUM(OrderQty) AS TotalOrdered
    FROM PurchaseOrderDetail
    GROUP BY ProductID
) AS pod ON p.ProductID = pod.ProductID
WHERE pi.Quantity < 10
AND (pod.TotalOrdered IS NULL OR pod.TotalOrdered = 0);

-- 36. List of top 10 countries by sales
SELECT TOP 10
    cr.Name AS ShipCountry,
    SUM(sod.UnitPrice * sod.OrderQty) AS TotalSales
FROM SalesOrderHeader soh
JOIN SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Address a ON soh.ShipToAddressID = a.AddressID
JOIN StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.Name
ORDER BY TotalSales DESC;

-- 37. Number of orders each employee has taken for customers with CustomerIDs between 1 and 3
SELECT soh.SalesPersonID, COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM SalesOrderHeader soh
WHERE soh.CustomerID BETWEEN 1 AND 3
GROUP BY soh.SalesPersonID;

-- 38. Orderdate of most expensive order
SELECT TOP 1 soh.OrderDate
FROM SalesOrderHeader soh
JOIN SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY soh.SalesOrderID, soh.OrderDate
ORDER BY SUM(sod.UnitPrice * sod.OrderQty) DESC;

-- 39. Product name and total revenue from that product
SELECT p.Name AS ProductName, SUM(sod.UnitPrice * sod.OrderQty) AS TotalRevenue
FROM Product p
JOIN SalesOrderDetail sod ON p.ProductID = sod.ProductID
GROUP BY p.Name;

-- 40. Supplierid and number of products offered
SELECT pv.BusinessEntityID AS SupplierID, COUNT(pv.ProductID) AS NumberOfProducts
FROM ProductVendor pv
GROUP BY pv.BusinessEntityID;

-- 41. Top ten customers based on their business
SELECT TOP 10
    ISNULL(p.FirstName + ' ' + p.LastName, s.Name) AS CustomerName,
    c.CustomerID,
    SUM(sod.UnitPrice * sod.OrderQty) AS TotalSpent
FROM Customer c
LEFT JOIN Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Store s ON c.StoreID = s.BusinessEntityID
JOIN SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY c.CustomerID, p.FirstName, p.LastName, s.Name
ORDER BY TotalSpent DESC;

-- 42. What is the total revenue of the company
SELECT SUM(sod.UnitPrice * sod.OrderQty) AS TotalRevenue
FROM SalesOrderDetail sod;