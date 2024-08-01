DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

/*------------------------------ Creating Tables ------------------------------*/
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS Users (
    Id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    Role VARCHAR(20) NOT NULL CHECK (Role IN ('user', 'admin'))
);

CREATE TABLE IF NOT EXISTS Customers (
    Id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Email VARCHAR(255) NOT NULL,
    Image_url VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS Products (
    Id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Category VARCHAR(255) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    Stock INT NOT NULL,
    Expiry DATE,
    Status VARCHAR(20) CHECK (Status IN ('in-stock', 'out-of-stock'))
);

CREATE TABLE IF NOT EXISTS Snack (
   Id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    Stock INT NOT NULL,
    Expiry DATE,
    Status VARCHAR(20) CHECK (Status IN ('in-stock', 'out-of-stock')),
    FOREIGN KEY (Id) REFERENCES Products(Id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Pantry (
    Id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    Stock INT NOT NULL,
    Expiry DATE,
    Status VARCHAR(20) CHECK (Status IN ('in-stock', 'out-of-stock')),
    FOREIGN KEY (Id) REFERENCES Products(Id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Beverage (
    Id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    Stock INT NOT NULL,
    Expiry DATE ,
    Status VARCHAR(20) CHECK (Status IN ('in-stock', 'out-of-stock')),
    FOREIGN KEY (Id) REFERENCES Products(Id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Revenue (
    Month DATE NOT NULL UNIQUE,
    Revenue INT NOT NULL
);

CREATE TABLE IF NOT EXISTS Orders (
    Id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    CustomerId UUID NOT NULL,
    ProductId UUID NOT NULL,
    Quantity INT NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    Date DATE NOT NULL DEFAULT (CURRENT_DATE),
    Status VARCHAR(20) NOT NULL CHECK (Status IN ('pending', 'paid')),
    FOREIGN KEY (CustomerId) REFERENCES Customers(Id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (ProductId) REFERENCES Products(Id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public';  -- should print out all the tables we've created above ^

/*------------------------------------------- Adding Users -------------------------------------------*/

INSERT INTO Users (Id, Name, Email, Password, Role) VALUES
('1e011ff0-9426-42fe-88ab-b1f8ac0c2ea4', 'Jeremy Smith', 'jeremySmith@gmail.com', 'jeremysmith', 'admin'),
('6abf6781-121a-46f0-a6c0-7789cfc84dfc', 'Nancy Tuckett', 'nancy123@gmail.com', 'nancytuckett', 'user');

SELECT * FROM Users;

/*------------------------------------------ Adding Customers ------------------------------------------*/

INSERT INTO Customers (Id, Name, Email, Image_url) VALUES
('8740c842-16af-4f9f-a19e-f3b8c8c11eef', 'Delba de Oliveria', 'delba@oliveira.com', '/customers/delba-de-oliveira.png'),
('6ee9e3d2-59df-4663-aa15-ff9631ca4fcb', 'Lee Robinson', 'lee@robinson.com', '/customers/lee-robinson.png'),
('6e2c99aa-5d20-4471-8cab-1f00c8ade6ac', 'Hector Simpson', 'hector@simpson.com', '/customers/hector-simpson.png');

SELECT * FROM Customers;

/*------------------------------------ Auto-updating Product Status ------------------------------------*/

CREATE OR REPLACE FUNCTION update_product_status() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.Stock > 0 THEN
        NEW.Status := 'in-stock';
    ELSE
        NEW.Status := 'out-of-stock';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER update_product_status_trigger
BEFORE INSERT OR UPDATE ON Products
FOR EACH ROW
EXECUTE FUNCTION update_product_status();

CREATE TRIGGER update_snack_status_trigger
BEFORE INSERT OR UPDATE ON Snack
FOR EACH ROW
EXECUTE FUNCTION update_product_status();

CREATE TRIGGER update_pantry_status_trigger
BEFORE INSERT OR UPDATE ON Pantry
FOR EACH ROW
EXECUTE FUNCTION update_product_status();

CREATE TRIGGER update_beverage_status_trigger
BEFORE INSERT OR UPDATE ON Beverage
FOR EACH ROW
EXECUTE FUNCTION update_product_status();


/*-------------------------------------- Adding Products --------------------------------------*/

INSERT INTO Products (Id, Name, Category, Price, Stock, Expiry) VALUES
('8f5896ca-f5a5-4724-bb55-f1251aaf6e86', 'snack Signature Super Extra-Large Peanuts, 2.5 lbs', 'Snack', 8.00, 186, '2024-07-18'),
('3f349a7c-4812-4f14-8073-79fb3bad21fc', 'European Black Winter Fresh Truffles 3 oz.', 'Pantry', 189.00, 420, '2025-03-12'),
('f929dca3-6f56-48f0-914b-6f35c39bd7a3', 'Pulp & Press Organic Cold-Pressed Wellness Shot Pack, 48-pack', 'Beverage', 99.00, 935, '2024-08-07'),
('14896a3c-6062-4f5a-9edb-659b87d5ba33', 'Prime Hydration Drink, Variety Pack, 16.9 fl oz, 15-count', 'Beverage', 21.99, 187, '2024-07-31');

INSERT INTO Snack (Id, Name, Price, Stock, Expiry) VALUES
('8f5896ca-f5a5-4724-bb55-f1251aaf6e86', 'snack Signature Super Extra-Large Peanuts, 2.5 lbs', 8.00, 186, '2024-07-18');

INSERT INTO Pantry (Id, Name, Price, Stock, Expiry) VALUES 
('3f349a7c-4812-4f14-8073-79fb3bad21fc', 'European Black Winter Fresh Truffles 3 oz.', 189.00, 420, '2025-03-12');

INSERT INTO Beverage (Id, Name, Price, Stock, Expiry) VALUES 
('f929dca3-6f56-48f0-914b-6f35c39bd7a3', 'Pulp & Press Organic Cold-Pressed Wellness Shot Pack, 48-pack', 99.00, 935, '2024-08-07');

INSERT INTO Beverage (Id, Name, Price, Stock, Expiry) VALUES 
('14896a3c-6062-4f5a-9edb-659b87d5ba33', 'Prime Hydration Drink, Variety Pack, 16.9 fl oz, 15-count', 21.99, 187, '2024-07-31');

SELECT * FROM Products;
SELECT * FROM Snack;
SELECT * FROM Pantry;
SELECT * FROM Beverage;

/*--------------------------------------- Updating Products ---------------------------------------*/
UPDATE Products
SET 
    Name = 'New Snack Name',
    Price = 1.00,
    Stock = 1000,
    Expiry = '2024-07-15'
WHERE Id = '8f5896ca-f5a5-4724-bb55-f1251aaf6e86';

UPDATE Products
SET 
    Name = 'New Pantry Name',
    Price = 1.00,
    Stock = 420,
    Expiry = '2024-07-15'
WHERE Id = '3f349a7c-4812-4f14-8073-79fb3bad21fc';

UPDATE Products
SET 
    Name = 'New Beverage Name',
    Price = 1.00,
    Stock = 186,
    Expiry = '2024-07-15'
WHERE Id = 'f929dca3-6f56-48f0-914b-6f35c39bd7a3';

UPDATE Snack
SET 
    Name = 'New Snack Name',
    Price = 1.00,
    Stock = 1000,
    Expiry = '2024-07-15'
WHERE Id = '8f5896ca-f5a5-4724-bb55-f1251aaf6e86';

UPDATE Pantry
SET 
    Name = 'New Pantry Name',
    Price = 1.00,
    Stock = 420,
    Expiry = '2024-07-15'
WHERE Id = '3f349a7c-4812-4f14-8073-79fb3bad21fc';

UPDATE Beverage
SET 
    Name = 'New Beverage Name',
    Price = 1.00,
    Stock = 186,
    Expiry = '2024-07-15'
WHERE Id = 'f929dca3-6f56-48f0-914b-6f35c39bd7a3';

SELECT * FROM Products;
SELECT * FROM Snack;
SELECT * FROM Pantry;
SELECT * FROM Beverage;


/*------------------------------- Deleting Products (cascading deletions) -------------------------------*/

DELETE FROM Products WHERE Products.Id = '14896a3c-6062-4f5a-9edb-659b87d5ba33';

SELECT * FROM Products;
SELECT * FROM Beverage;  -- should have 1 entry


/*----------------------------------------- Verifying Quantity ----------------------------------------- */

CREATE OR REPLACE FUNCTION check_product_stock() RETURNS TRIGGER AS $$
DECLARE ProductStock INT;
BEGIN
    SELECT Stock INTO ProductStock FROM Products WHERE Id = NEW.ProductId;
    IF NEW.Quantity > ProductStock THEN
        RAISE EXCEPTION 'Quantity % exceeds available stock %', NEW.Quantity, ProductStock;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_stock_trigger
BEFORE INSERT ON Orders
FOR EACH ROW
EXECUTE FUNCTION check_product_stock();


/*------------------------------------------- Auto-updating Amount -------------------------------------------*/

CREATE OR REPLACE FUNCTION update_order_amount() RETURNS TRIGGER AS $$
DECLARE
    ProductPrice DECIMAL(10, 2);
BEGIN
    SELECT Price INTO ProductPrice FROM Products WHERE Id = NEW.ProductId;
    NEW.Amount := NEW.Quantity * ProductPrice;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_amount_trigger
BEFORE INSERT OR UPDATE ON Orders
FOR EACH ROW
EXECUTE FUNCTION update_order_amount();


/*---------------------------------------- Auto-updating Product Stock ----------------------------------------*/

-- reduce product stock when an order is placed
CREATE OR REPLACE FUNCTION reduce_product_stock() RETURNS TRIGGER AS $$
BEGIN
    UPDATE Products
    SET Stock = Stock - NEW.Quantity
    WHERE Id = NEW.productId;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER reduce_stock_trigger
AFTER INSERT ON Orders
FOR EACH ROW
EXECUTE FUNCTION reduce_product_stock();

-- revert the changes to product stock when an order is deleted
CREATE OR REPLACE FUNCTION revert_product_stock() RETURNS TRIGGER AS $$
    BEGIN
    UPDATE Products
    SET Stock = Stock + OLD.Quantity
    WHERE Id = OLD.productId;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER revert_stock_trigger
AFTER DELETE ON Orders
FOR EACH ROW
EXECUTE FUNCTION revert_product_stock();

-- revert then reduce the changes to product stock when an order is updated
CREATE OR REPLACE FUNCTION update_product_stock() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.ProductId <> OLD.ProductId THEN
        UPDATE Products
        SET Stock = Stock + OLD.Quantity
        WHERE Id = OLD.productId;
        UPDATE Products
        SET Stock = Stock - NEW.Quantity
        WHERE Id = NEW.ProductId;
    ELSE
        UPDATE Products
        SET Stock = Stock + OLD.Quantity - NEW.Quantity
        WHERE Id = NEW.ProductId;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_stock_trigger
AFTER UPDATE ON Orders
FOR EACH ROW
EXECUTE FUNCTION update_product_stock();


/*------------------------------------------- Auto-updating Revenue -------------------------------------------*/

CREATE OR REPLACE FUNCTION update_revenue_insert()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.Status = 'paid' THEN
        DECLARE
            OMonth DATE := DATE_TRUNC('month', NEW.Date);
        BEGIN
            INSERT INTO Revenue (Month, Revenue)
            VALUES (OMonth, NEW.Amount)
            ON CONFLICT (Month)
            DO UPDATE SET Revenue = Revenue.Revenue + EXCLUDED.Revenue;
        END;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_revenue_insert_trigger
AFTER INSERT OR UPDATE ON Orders
FOR EACH ROW
EXECUTE FUNCTION update_revenue_insert();

CREATE OR REPLACE FUNCTION update_revenue_delete()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.Status = 'paid' THEN
        DECLARE
            OMonth DATE := DATE_TRUNC('month', OLD.Date);
        BEGIN
            UPDATE Revenue
            SET Revenue = Revenue.Revenue - OLD.Amount
            WHERE Month = OMonth;

            -- Optionally remove the month entry if revenue is 0
            DELETE FROM Revenue
            WHERE Revenue = 0 AND Month = OMonth;
        END;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_revenue_delete_trigger
AFTER DELETE ON Orders
FOR EACH ROW
EXECUTE FUNCTION update_revenue_delete();

CREATE OR REPLACE FUNCTION update_revenue_update()
RETURNS TRIGGER AS $$
DECLARE
    OMonth DATE := DATE_TRUNC('month', NEW.Date);
BEGIN
    IF OLD.Status = 'paid' AND NEW.Status = 'pending' THEN
        UPDATE Revenue
        SET Revenue = Revenue.Revenue - OLD.Amount
        WHERE Month = OMonth;
        DELETE FROM Revenue
        WHERE Revenue = 0 AND Month = OMonth;
    END IF;
    IF NEW.Status = 'paid' AND OLD.Status = 'pending' THEN
        INSERT INTO Revenue (Month, Revenue)
        VALUES (OMonth, NEW.Amount)
        ON CONFLICT (Month)
        DO UPDATE SET Revenue = Revenue.Revenue + EXCLUDED.Revenue;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_revenue_update_trigger
AFTER INSERT OR UPDATE ON Orders
FOR EACH ROW
EXECUTE FUNCTION update_revenue_update();

/*---------------------------------------------- Adding Orders ----------------------------------------------*/

INSERT INTO Orders (Id, CustomerId, ProductId, Quantity, Status) VALUES
('92bf3c9b-6dac-483e-ae6d-64ad8dc10623', '8740c842-16af-4f9f-a19e-f3b8c8c11eef', '8f5896ca-f5a5-4724-bb55-f1251aaf6e86', 34, 'paid'),
('d9684896-6006-48b2-8269-b1616e2a3f22', '6ee9e3d2-59df-4663-aa15-ff9631ca4fcb', '3f349a7c-4812-4f14-8073-79fb3bad21fc', 420, 'pending'),
('78709a40-3c63-421e-833b-f0c5a6c49551', '6e2c99aa-5d20-4471-8cab-1f00c8ade6ac', 'f929dca3-6f56-48f0-914b-6f35c39bd7a3', 122, 'paid');

SELECT * FROM Orders;
SELECT * FROM Products;  -- stock should be reduced by quantity
SELECT * FROM Revenue;   -- revenue should be updated


/*---------------------------------------------- Editing Orders ----------------------------------------------*/

-- increase quantity to 40 (+6)
UPDATE Orders
SET 
    CustomerId = '8740c842-16af-4f9f-a19e-f3b8c8c11eef',
    ProductId = '8f5896ca-f5a5-4724-bb55-f1251aaf6e86',
    Quantity = 40,
    Status = 'paid'
WHERE Id = '92bf3c9b-6dac-483e-ae6d-64ad8dc10623';

-- switch customers, set status to 'paid'
UPDATE Orders
SET 
    CustomerId = '8740c842-16af-4f9f-a19e-f3b8c8c11eef',
    ProductId = '3f349a7c-4812-4f14-8073-79fb3bad21fc',
    Quantity = 420,
    Status = 'paid'
WHERE Id = 'd9684896-6006-48b2-8269-b1616e2a3f22';

-- switch product
UPDATE Orders
SET 
    CustomerId = '6e2c99aa-5d20-4471-8cab-1f00c8ade6ac',
    ProductId = '8f5896ca-f5a5-4724-bb55-f1251aaf6e86',
    Quantity = 695,
    Status = 'pending'
WHERE Id = '78709a40-3c63-421e-833b-f0c5a6c49551';

SELECT * FROM Orders;    -- orders should reflect changes
SELECT * FROM Products;  -- stock should reflect changes
SELECT * FROM Revenue;   -- revenue should increase


/*---------------------------------------------- Deleting Orders ----------------------------------------------*/

DELETE FROM Orders WHERE Orders.Id = 'd9684896-6006-48b2-8269-b1616e2a3f22';

SELECT * FROM Orders;
SELECT * FROM Products;   -- stock should be reverted to value before order was placed
SELECT * FROM Revenue;    -- revenue should decrease


/*-------------------------------------- Viewing Products, Search (filtering products) --------------------------------------*/

-- input: 'snack' --
SELECT *
FROM Products
WHERE
    Products.Id::text ILIKE '%snack%' OR 
    Products.Name ILIKE '%snack%' OR 
    Products.Category ILIKE '%snack%' OR 
    Products.Stock::text ILIKE '%snack%' OR 
    Products.Expiry::text ILIKE '%snack%' OR 
    Products.Price::text ILIKE '%snack%' OR  
    Products.Status ILIKE '%snack%'      
ORDER BY Products.Price DESC
LIMIT 6 OFFSET 0;

/*----------------- Pagination (getting total pages w/ search results) -----------------*/

-- input: 'snack' --
SELECT COUNT(*)
FROM Products
WHERE
    Products.Id::text ILIKE '%snack%' OR 
    Products.Name ILIKE '%snack%' OR 
    Products.Category ILIKE '%snack%' OR 
    Products.Stock::text ILIKE '%snack%' OR 
    Products.Expiry::text ILIKE '%snack%' OR 
    Products.Price::text ILIKE '%snack%' OR  
    Products.Status ILIKE '%snack%';   


/*-------------------------------------- Viewing 5 Best-Selling Products --------------------------------------*/   
SELECT 
    Products.Id,
    Products.Name,
    Products.Category,
    SUM(Orders.Amount) AS TotalRevenue,
    SUM(Orders.Quantity) AS TotalSold
FROM Orders
JOIN Products ON Orders.ProductId = Products.Id
WHERE Orders.Status = 'paid'
GROUP BY Products.Id, Products.Name, Products.Category
ORDER BY TotalRevenue DESC, TotalSold DESC
LIMIT 5;

/*-------------------------------------- Viewing Orders, Search (filtering orders) --------------------------------------*/

-- input: 'pending' --
SELECT
    Orders.Id,
    Orders.Quantity,
    Orders.Amount,
    Orders.Date,
    Orders.Status,
    Orders.ProductId,
    Customers.Name AS CustomerName,
    Customers.Image_url,
    Products.Name AS ProductName
FROM Orders
JOIN Customers ON Orders.CustomerId = Customers.Id
JOIN Products ON Orders.ProductId = Products.Id
WHERE
    Customers.Name ILIKE '%pending%' OR
    Products.Id::text ILIKE '%pending%' OR
    Products.Name ILIKE '%pending%' OR
    Orders.Amount::text ILIKE '%pending%' OR 
    Orders.Date::text ILIKE '%pending%' OR
    Orders.Status ILIKE '%pending%'
ORDER BY Orders.Date DESC
LIMIT 6 OFFSET 0;

/*----------------- Pagination (getting total pages w/ search results) -----------------*/

-- input: 'pending' --
SELECT COUNT(*)
FROM Orders
JOIN Customers ON Orders.CustomerId = Customers.Id
JOIN Products ON Orders.ProductId = Products.Id
WHERE
    Customers.Name ILIKE '%pending%' OR
    Products.Id::text ILIKE '%pending%' OR
    Products.Name ILIKE '%pending%' OR
    Orders.Amount::text ILIKE '%pending%' OR 
    Orders.Date::text ILIKE '%pending%' OR
    Orders.Status ILIKE '%pending%';


/*-------------------------------------- Viewing Customers, Search (filtering customers) --------------------------------------*/

-- input: 'Lee' --
SELECT
    Customers.Id,
    Customers.Name,
    Customers.Email,
    Customers.Image_url,
    COUNT(Orders.Id) AS TotalOrders,
    SUM(CASE WHEN Orders.Status = 'pending' THEN Orders.Amount ELSE 0 END) AS TotalPending,
    SUM(CASE WHEN Orders.Status = 'paid' THEN Orders.Amount ELSE 0 END) AS TotalPaid
FROM Customers
LEFT JOIN Orders ON Customers.Id = Orders.CustomerId
WHERE
    Customers.Name ILIKE '%Lee%' OR
    Customers.Email ILIKE '%Lee%'
GROUP BY Customers.Id, Customers.Name, Customers.Email, Customers.Image_url
ORDER BY Customers.Name ASC
LIMIT 6 OFFSET 0;


/*----------------- Pagination (getting total pages w/ search results) -----------------*/

-- input: 'Lee' --
SELECT COUNT(*)
FROM Customers
LEFT JOIN Orders ON Customers.Id = Orders.CustomerId
WHERE
    Customers.Name ILIKE '%Lee%' OR
    Customers.Email ILIKE '%Lee%';


/*---------------------- Product Count ----------------------*/

SELECT COUNT(*) FROM Products;
SELECT COUNT(*) FROM Snack;
SELECT COUNT(*) FROM Pantry;
SELECT COUNT(*) FROM Beverage;

/*---------------------- In Stock Count ----------------------*/

SELECT COUNT(*)
FROM Products
WHERE status = 'in-stock';


/*--------------------- Out of Stock Count ---------------------*/

SELECT COUNT(*)
FROM Products
WHERE status = 'out-of-stock';


/*---------------------- Customer Count ----------------------*/

SELECT COUNT(*) FROM Customers;


/*---------------------- Order Count ----------------------*/

SELECT COUNT(*) FROM Orders;


/*---------------------- Total Revenue ----------------------*/

SELECT SUM(Revenue) FROM Revenue;


/*---------------------- Total Pending / Paid ----------------------*/

SELECT
    SUM(CASE WHEN status = 'paid' THEN Amount ELSE 0 END) AS "paid",
    SUM(CASE WHEN status = 'pending' THEN Amount ELSE 0 END) AS "pending"
FROM Orders;
