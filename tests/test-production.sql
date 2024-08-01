DROP DATABASE TestStore;
CREATE DATABASE TestStore;
USE TestStore;

/*---------- Creating Tables ----------*/

/* should be uuid, but uuid is specific to PostgreSQL so will replace wiht CHAR(36) for testing purposes:

CREATE EXTENSION IF NOT EXISTS 'uuid-ossp';
CREATE TABLE IF NOT EXISTS Product (
    PId uuid PRIMARY KEY, -> PId CHAR(36) PRIMARY KEY,
    PName VARCHAR(200),
    PStock INT,
    PExpiry DATE,
    PPrice DECIMAL(10, 2)
);

*/

CREATE TABLE IF NOT EXISTS Product (
    PId CHAR(36) PRIMARY KEY,
    PName VARCHAR(200),
    PStock INT,
    PPrice DECIMAL(10, 2)
);

CREATE TABLE IF NOT EXISTS Snack (
    PId CHAR(36) PRIMARY KEY,
    PName VARCHAR(200),
    PStock INT,
    PExpiry DATE,
    PPrice DECIMAL(10, 2),
    FOREIGN KEY (PId) REFERENCES Product(PId)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Pantry (
    PId CHAR(36) PRIMARY KEY,
    PName VARCHAR(200),
    PStock INT,
    PExpiry DATE,
    PPrice DECIMAL(10, 2),
    FOREIGN KEY (PId) REFERENCES Product(PId)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Beverage (
    PId CHAR(36) PRIMARY KEY,
    PName VARCHAR(200),
    PStock INT,
    PExpiry DATE,
    PPrice DECIMAL(10, 2),
    FOREIGN KEY (PId) REFERENCES Product(PId)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Candy (
    PId CHAR(36) PRIMARY KEY,
    PName VARCHAR(200),
    PStock INT,
    PExpiry DATE,
    PPrice DECIMAL(10, 2),
    FOREIGN KEY (PId) REFERENCES Product(PId)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS MeatAndSeafood (
    PId CHAR(36) PRIMARY KEY,
    PName VARCHAR(200),
    PStock INT,
    PExpiry DATE,
    PPrice DECIMAL(10, 2),
    FOREIGN KEY (PId) REFERENCES Product(PId)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS BakeryAndDessert (
    PId CHAR(36) PRIMARY KEY,
    PName VARCHAR(200),
    PStock INT,
    PExpiry DATE,
    PPrice DECIMAL(10, 2),
    FOREIGN KEY (PId) REFERENCES Product(PId)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Breakfast (
    PId CHAR(36) PRIMARY KEY,
    PName VARCHAR(200),
    PStock INT,
    PExpiry DATE,
    PPrice DECIMAL(10, 2),
    FOREIGN KEY (PId) REFERENCES Product(PId)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Coffee (
    PId CHAR(36) PRIMARY KEY,
    PName VARCHAR(200),
    PStock INT,
    PExpiry DATE,
    PPrice DECIMAL(10, 2),
    FOREIGN KEY (PId) REFERENCES Product(PId)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Deli (
    PId CHAR(36) PRIMARY KEY,
    PName VARCHAR(200),
    PStock INT,
    PExpiry DATE,
    PPrice DECIMAL(10, 2),
    FOREIGN KEY (PId) REFERENCES Product(PId)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Organic (
    PId CHAR(36) PRIMARY KEY,
    PName VARCHAR(200),
    PStock INT,
    PExpiry DATE,
    PPrice DECIMAL(10, 2),
    FOREIGN KEY (PId) REFERENCES Product(PId)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Cleaning (
    PId CHAR(36) PRIMARY KEY,
    PName VARCHAR(200),
    PStock INT,
    PPrice DECIMAL(10, 2),
    FOREIGN KEY (PId) REFERENCES Product(PId)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Floral (
    PId CHAR(36) PRIMARY KEY,
    PName VARCHAR(200),
    PStock INT,
    PPrice DECIMAL(10, 2),
    FOREIGN KEY (PId) REFERENCES Product(PId)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Household (
    PId CHAR(36) PRIMARY KEY,
    PName VARCHAR(200),
    PStock INT,
    PPrice DECIMAL(10, 2),
    FOREIGN KEY (PId) REFERENCES Product(PId)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


/*---------------------------------------------- Adding Products ----------------------------------------------*/

INSERT INTO Product (PId, PName, PStock, PPrice) VALUES
('8f5896ca-f5a5-4724-bb55-f1251aaf6e86', 'Kirkland Signature Super Extra-Large Peanuts, 2.5 lbs', 186, 8.00),
('3f349a7c-4812-4f14-8073-79fb3bad21fc', 'European Black Winter Fresh Truffles 3 oz.', 420, 189.00),
('f929dca3-6f56-48f0-914b-6f35c39bd7a3', 'Pulp & Press Organic Cold-Pressed Wellness Shot Pack, 48-pack', 935, 99.00),
('630f5f15-d1d3-4a6f-bfae-517625cf2507', 'Kirkland Signature Almonds, Milk Chocolate, 3 lb', 21, 16.00),
('fb8880b1-1983-4ea2-9a54-64dd46204d0e', 'Ahi Tuna Individual Vacuum Packed Portion (26-27/6 Oz. Per Portion), 26-27 Total Packs, 10 Lbs. Total Case', 251, 129),
('695a4d1c-2a1f-42e8-807b-0812921f2c26', 'David’s Cookies Mile High Peanut Butter Cake, 6.8 lbs (14 Servings)', 487, 56.00),
('15dfd813-1da9-477e-a104-551a70ab640e', 'MadeGood Granola Minis, Variety Pack, 0.85 oz, 24-count', 402, 10.00),
('d80c0fcc-22c5-434e-bf05-c1ef50086be5', 'Kirkland Signature Coffee Organic Pacific Bold K-Cup Pod, 120-count', 587, 31.00),
('aed74592-25f4-462a-b03b-54f8ee411a0f', 'Tsar Nicoulai Baerii Caviar 2 oz. Gift Set', 260, 99.00),
('36197f0f-c63c-4fc6-9f62-05c321858687', 'Kirkland Signature, Organic Chicken Stock, 32 fl oz, 6-Count', 706, 11.00),
('9f658d15-cabe-4e40-b3a9-9b96b96f01e6', 'Tide Pods HE Laundry Detergent Pods, Free & Gentle, 152-count', 483, 28.00),
('ef3b5b79-20a1-4d8b-817b-ce0e075fe7d3', '50-stem White Roses', 982, 49.00),
('04d5cc4e-b82c-4dfb-acd7-6bfa7ed58c67', 'Cambro CamSquare 2 Quart Food Storage Container with Lid, 3-count', 56, 18.00);

INSERT INTO Snack (PId, PName, PStock, PExpiry, PPrice) VALUES
('8f5896ca-f5a5-4724-bb55-f1251aaf6e86', 'Kirkland Signature Super Extra-Large Peanuts, 2.5 lbs', 186, '2024-07-18', 8.00);

INSERT INTO Pantry (PId, PName, PStock, PExpiry, PPrice) VALUES 
('3f349a7c-4812-4f14-8073-79fb3bad21fc', 'European Black Winter Fresh Truffles 3 oz.', 420, '2025-03-12', 189.00);

INSERT INTO Beverage (PId, PName, PStock, PExpiry, PPrice) VALUES 
('f929dca3-6f56-48f0-914b-6f35c39bd7a3', 'Pulp & Press Organic Cold-Pressed Wellness Shot Pack, 48-pack', 935, '2024-08-07', 99.00);

INSERT INTO Candy (PId, PName, PStock, PExpiry, PPrice) VALUES 
('630f5f15-d1d3-4a6f-bfae-517625cf2507', 'Kirkland Signature Almonds, Milk Chocolate, 3 lb', 21, '2024-07-24', 16.00);

INSERT INTO MeatAndSeafood (PId, PName, PStock, PExpiry, PPrice) VALUES 
('fb8880b1-1983-4ea2-9a54-64dd46204d0e', 'Ahi Tuna Individual Vacuum Packed Portion (26-27/6 Oz. Per Portion), 26-27 Total Packs, 10 Lbs. Total Case', 251, '2024-07-19', 129);

INSERT INTO BakeryAndDessert (PId, PName, PStock, PExpiry, PPrice) VALUES 
('695a4d1c-2a1f-42e8-807b-0812921f2c26', 'David’s Cookies Mile High Peanut Butter Cake, 6.8 lbs (14 Servings)', 487, '2024-010-18', 56.00);

INSERT INTO Breakfast (PId, PName, PStock, PExpiry, PPrice) VALUES 
('15dfd813-1da9-477e-a104-551a70ab640e', 'MadeGood Granola Minis, Variety Pack, 0.85 oz, 24-count', 402, '2024-08-05', 10.00);

INSERT INTO Coffee (PId, PName, PStock, PExpiry, PPrice) VALUES 
('d80c0fcc-22c5-434e-bf05-c1ef50086be5', 'Kirkland Signature Coffee Organic Pacific Bold K-Cup Pod, 120-count', 587, '2024-10-11', 31.00);

INSERT INTO Deli (PId, PName, PStock, PExpiry, PPrice) VALUES 
('aed74592-25f4-462a-b03b-54f8ee411a0f', 'Tsar Nicoulai Baerii Caviar 2 oz. Gift Set', 260, '2024-07-29', 99.00);

INSERT INTO Organic (PId, PName, PStock, PExpiry, PPrice) VALUES 
('36197f0f-c63c-4fc6-9f62-05c321858687', 'Kirkland Signature, Organic Chicken Stock, 32 fl oz, 6-Count', 706, '2024-08-02', 11.00);

INSERT INTO Cleaning (PId, PName, PStock, PPrice) VALUES 
('9f658d15-cabe-4e40-b3a9-9b96b96f01e6', 'Tide Pods HE Laundry Detergent Pods, Free & Gentle, 152-count', 483, 28.00);

INSERT INTO Floral (PId, PName, PStock, PPrice) VALUES 
('ef3b5b79-20a1-4d8b-817b-ce0e075fe7d3', '50-stem White Roses', 982, 49.00);

INSERT INTO Household (PId, PName, PStock, PPrice) VALUES 
('04d5cc4e-b82c-4dfb-acd7-6bfa7ed58c67', 'Cambro CamSquare 2 Quart Food Storage Container with Lid, 3-count', 56, 18.00);

SELECT * FROM Product;
SELECT * FROM Snack;
SELECT * FROM Pantry;
SELECT * FROM Beverage;
SELECT * FROM Candy;
SELECT * FROM MeatAndSeafood;
SELECT * FROM BakeryAndDessert;
SELECT * FROM Coffee;
SELECT * FROM Deli;
SELECT * FROM Organic;
SELECT * FROM Cleaning;
SELECT * FROM Floral;
SELECT * FROM Household;


/*---------------------- Product Count ----------------------*/

SELECT COUNT(*) FROM Product; -- should be 13
-- should all be 1 --
SELECT COUNT(*) FROM Snack;
SELECT COUNT(*) FROM Pantry;
SELECT COUNT(*) FROM Beverage;
SELECT COUNT(*) FROM Candy;
SELECT COUNT(*) FROM MeatAndSeafood;
SELECT COUNT(*) FROM BakeryAndDessert;
SELECT COUNT(*) FROM Coffee;
SELECT COUNT(*) FROM Deli;
SELECT COUNT(*) FROM Organic;
SELECT COUNT(*) FROM Cleaning;
SELECT COUNT(*) FROM Floral;
SELECT COUNT(*) FROM Household;


/*----------------- Search (filtering products) -----------------*/


/* should be ::text and ILIKE, but these operators are specific to PostgreSQL so will replace with Lower(CAST()) and LIKE for testing purposes:

SELECT *
FROM Product
WHERE
    Product.PId::text ILIKE '%kirkland%' OR      -> Lower(CAST(Product.PId AS CHAR)) LIKE '%kirkland%' OR
    Product.PName ILIKE '%kirkland%' OR          -> Lower(Product.PName) LIKE '%kirkland%' OR
    Product.PStock::text ILIKE '%kirkland%' OR   -> Lower(CAST(Product.PStock AS CHAR)) LIKE '%kirkland%' OR
    Product.PPrice::text ILIKE '%kirkland%'      -> Lower(CAST(Product.PPrice AS CHAR)) LIKE '%kirkland%' OR
ORDER BY Product.PPrice DESC;

*/

-- input: 'Kirkland' --
SELECT *
FROM Product
WHERE
    Lower(CAST(Product.PId AS CHAR)) LIKE '%kirkland%' OR
    Lower(Product.PName) LIKE '%kirkland%' OR
    Lower(CAST(Product.PStock AS CHAR)) LIKE '%kirkland%' OR
    Lower(CAST(Product.PPrice AS CHAR)) LIKE '%kirkland%'
ORDER BY Product.PPrice DESC;


/*----------------- Pagination (getting total pages w/ search results) -----------------*/

-- input: 'Kirkland' --
SELECT COUNT(*)
FROM Product
WHERE
    Lower(CAST(Product.PId AS CHAR)) LIKE '%kirkland%' OR
    Lower(Product.PName) LIKE '%kirkland%' OR
    Lower(CAST(Product.PStock AS CHAR)) LIKE '%kirkland%' OR
    Lower(CAST(Product.PPrice AS CHAR)) LIKE '%kirkland%';


/*----------------- Updating Products -----------------*/

UPDATE Snack
SET 
    PName = 'New Snack Name',
    PStock = 1,
    PExpiry = '2024-07-15',
    PPrice = 1.00
WHERE PId = '8f5896ca-f5a5-4724-bb55-f1251aaf6e86';

UPDATE Pantry
SET 
    PName = 'New Pantry Name',
    PStock = 1,
    PExpiry = '2024-07-15',
    PPrice = 1.00
WHERE PId = '3f349a7c-4812-4f14-8073-79fb3bad21fc';

UPDATE Beverage
SET 
    PName = 'New Beverage Name',
    PStock = 1,
    PExpiry = '2024-07-15',
    PPrice = 1.00
WHERE PId = 'f929dca3-6f56-48f0-914b-6f35c39bd7a3';

UPDATE Candy
SET 
    PName = 'New Candy Name',
    PStock = 1,
    PExpiry = '2024-07-15',
    PPrice = 1.00
WHERE PId = '630f5f15-d1d3-4a6f-bfae-517625cf2507';

UPDATE MeatAndSeafood
SET 
    PName = 'New Meat and Seafood Name',
    PStock = 1,
    PExpiry = '2024-07-15',
    PPrice = 1.00
WHERE PId = 'fb8880b1-1983-4ea2-9a54-64dd46204d0e';

UPDATE BakeryAndDessert
SET 
    PName = 'New Bakery and Dessert Name',
    PStock = 1,
    PExpiry = '2024-07-15',
    PPrice = 1.00
WHERE PId = '695a4d1c-2a1f-42e8-807b-0812921f2c26';

UPDATE Breakfast
SET 
    PName = 'New Breakfast Name',
    PStock = 1,
    PExpiry = '2024-07-15',
    PPrice = 1.00
WHERE PId = '15dfd813-1da9-477e-a104-551a70ab640e';

UPDATE Coffee
SET 
    PName = 'New Coffee Name',
    PStock = 1,
    PExpiry = '2024-07-15',
    PPrice = 1.00
WHERE PId = 'd80c0fcc-22c5-434e-bf05-c1ef50086be5';

UPDATE Deli
SET 
    PName = 'New Deli Name',
    PStock = 1,
    PExpiry = '2024-07-15',
    PPrice = 1.00
WHERE PId = 'aed74592-25f4-462a-b03b-54f8ee411a0f';

UPDATE Organic
SET 
    PName = 'New Organic Name',
    PStock = 1,
    PExpiry = '2024-07-15',
    PPrice = 1.00
WHERE PId = '36197f0f-c63c-4fc6-9f62-05c321858687';

UPDATE Cleaning
SET 
    PName = 'New Cleaning Name',
    PStock = 1,
    PPrice = 1.00
WHERE PId = '9f658d15-cabe-4e40-b3a9-9b96b96f01e6';

UPDATE Floral
SET 
    PName = 'New Floral Name',
    PStock = 1,
    PPrice = 1.00
WHERE PId = 'ef3b5b79-20a1-4d8b-817b-ce0e075fe7d3';

UPDATE Household
SET 
    PName = 'New Household Name',
    PStock = 1,
    PPrice = 1.00
WHERE PId = '04d5cc4e-b82c-4dfb-acd7-6bfa7ed58c67';

SELECT * FROM Snack;
SELECT * FROM Pantry;
SELECT * FROM Beverage;
SELECT * FROM Candy;
SELECT * FROM MeatAndSeafood;
SELECT * FROM BakeryAndDessert;
SELECT * FROM Coffee;
SELECT * FROM Deli;
SELECT * FROM Organic;
SELECT * FROM Cleaning;
SELECT * FROM Floral;
SELECT * FROM Household;


/*------------- Deleting Products (cascading deletions) -------------*/

DELETE FROM Product WHERE Product.PId = '8f5896ca-f5a5-4724-bb55-f1251aaf6e86';

DELETE FROM Product WHERE Product.PId = '3f349a7c-4812-4f14-8073-79fb3bad21fc';

DELETE FROM Product WHERE Product.PId = 'f929dca3-6f56-48f0-914b-6f35c39bd7a3';

DELETE FROM Product WHERE Product.PId = '630f5f15-d1d3-4a6f-bfae-517625cf2507';

DELETE FROM Product WHERE Product.PId = 'fb8880b1-1983-4ea2-9a54-64dd46204d0e';

DELETE FROM Product WHERE Product.PId = '695a4d1c-2a1f-42e8-807b-0812921f2c26';

DELETE FROM Product WHERE Product.PId = '15dfd813-1da9-477e-a104-551a70ab640e';

DELETE FROM Product WHERE Product.PId = 'd80c0fcc-22c5-434e-bf05-c1ef50086be5';

DELETE FROM Product WHERE Product.PId = 'aed74592-25f4-462a-b03b-54f8ee411a0f';

DELETE FROM Product WHERE Product.PId = '36197f0f-c63c-4fc6-9f62-05c321858687';

DELETE FROM Product WHERE Product.PId = '9f658d15-cabe-4e40-b3a9-9b96b96f01e6';

DELETE FROM Product WHERE Product.PId = 'ef3b5b79-20a1-4d8b-817b-ce0e075fe7d3';

DELETE FROM Product WHERE Product.PId = '04d5cc4e-b82c-4dfb-acd7-6bfa7ed58c67';

-- should all be empty --
SELECT * FROM Snack;
SELECT * FROM Pantry;
SELECT * FROM Beverage;
SELECT * FROM Candy;
SELECT * FROM MeatAndSeafood;
SELECT * FROM BakeryAndDessert;
SELECT * FROM Coffee;
SELECT * FROM Deli;
SELECT * FROM Organic;
SELECT * FROM Cleaning;
SELECT * FROM Floral;
SELECT * FROM Household;

