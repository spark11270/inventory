CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('user', 'admin'))
);

CREATE TABLE IF NOT EXISTS products (
    id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL,
    expiry DATE,
    status VARCHAR(20) CHECK (status IN ('in-stock', 'out-of-stock'))
);

CREATE OR REPLACE FUNCTION update_product_status() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.stock > 0 THEN
        NEW.status := 'in-stock';
    ELSE
        NEW.status := 'out-of-stock';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_status_trigger
BEFORE INSERT OR UPDATE ON products
FOR EACH ROW
EXECUTE FUNCTION update_product_status();

CREATE TABLE IF NOT EXISTS stock_history (
    category VARCHAR(255) NOT NULL,
    stock INT NOT NULL,
    valid_from TIMESTAMP NOT NULL,
    valid_to TIMESTAMP NOT NULL,
    PRIMARY KEY (category, valid_from)
);

CREATE TABLE IF NOT EXISTS customers (
    id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    image_url VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS orders (
    id INT PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES products(id),
    product_id INT NOT NULL REFERENCES products(id),
    quantity INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'paid'))
);

CREATE OR REPLACE FUNCTION check_product_stock() RETURNS TRIGGER AS $$
DECLARE
    product_stock INT;
BEGIN
    SELECT stock INTO product_stock FROM products WHERE id = NEW.product_id;
    IF NEW.quantity > product_stock THEN
        RAISE EXCEPTION 'Quantity % exceeds available stock %', NEW.quantity, product_stock;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_stock_trigger
BEFORE INSERT OR UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION check_product_stock();

CREATE OR REPLACE FUNCTION update_order_amount() RETURNS TRIGGER AS $$
DECLARE
    product_price DECIMAL(10, 2);
BEGIN
    SELECT price INTO product_price FROM products WHERE id = NEW.product_id;
    NEW.amount := NEW.quantity * product_price;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_amount_trigger
BEFORE INSERT OR UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION update_order_amount();

CREATE OR REPLACE FUNCTION reduce_product_stock() RETURNS TRIGGER AS $$
BEGIN
    UPDATE products
    SET stock = stock - NEW.quantity
    WHERE id = NEW.product_id;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER reduce_stock_trigger
AFTER INSERT ON orders
FOR EACH ROW
EXECUTE FUNCTION reduce_product_stock();

CREATE OR REPLACE FUNCTION revert_product_stock() RETURNS TRIGGER AS $$
BEGIN
    UPDATE products
    SET stock = stock + OLD.quantity
    WHERE id = OLD.product_id;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER revert_stock_trigger
AFTER DELETE ON orders
FOR EACH ROW
EXECUTE FUNCTION revert_product_stock();

CREATE OR REPLACE FUNCTION update_product_stock() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.product_id <> OLD.product_id THEN
        UPDATE products
        SET stock = stock + OLD.quantity
        WHERE id = OLD.product_id;
        UPDATE products
        SET stock = stock - NEW.quantity
        WHERE id = NEW.product_id;
    ELSE
        UPDATE products
        SET stock = stock + OLD.quantity - NEW.quantity
        WHERE id = NEW.product_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_stock_trigger
AFTER UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION update_product_stock();

CREATE OR REPLACE FUNCTION update_revenue() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'paid' THEN
        INSERT INTO revenue (month, revenue)
        SELECT
            DATE_TRUNC('month', NEW.date) AS month,
            COALESCE(SUM(amount), 0) AS revenue
        FROM orders
        WHERE DATE_TRUNC('month', date) = DATE_TRUNC('month', NEW.date)
        ON CONFLICT (month) DO UPDATE SET revenue = EXCLUDED.revenue;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_revenue_trigger
AFTER INSERT OR UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION update_revenue();

CREATE TABLE IF NOT EXISTS revenue (
    month DATE NOT NULL UNIQUE,
    revenue INT NOT NULL
);

CREATE TABLE IF NOT EXISTS snacks (
    id INT PRIMARY KEY,
    name VARCHAR(200),
    stock INT,
    expiry DATE,
    price DECIMAL(10, 2),
    status VARCHAR(20) CHECK (status IN ('in-stock', 'out-of-stock'))
);

CREATE OR REPLACE FUNCTION update_snacks_status() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.stock > 0 THEN
        NEW.status := 'in-stock';
    ELSE
        NEW.status := 'out-of-stock';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_status_trigger
BEFORE INSERT OR UPDATE ON snacks
FOR EACH ROW
EXECUTE FUNCTION update_snacks_status();

ALTER TABLE snacks
ADD CONSTRAINT fk_snack_product
FOREIGN KEY (id)
REFERENCES products(id)
ON DELETE CASCADE
ON UPDATE CASCADE;

CREATE TABLE IF NOT EXISTS pantry (
    id INT PRIMARY KEY,
    name VARCHAR(200),
    stock INT,
    expiry DATE,
    price DECIMAL(10, 2),
    status VARCHAR(20) CHECK (status IN ('in-stock', 'out-of-stock'))
);

CREATE OR REPLACE FUNCTION update_pantry_status() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.stock > 0 THEN
        NEW.status := 'in-stock';
    ELSE
        NEW.status := 'out-of-stock';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_status_trigger
BEFORE INSERT OR UPDATE ON pantry
FOR EACH ROW
EXECUTE FUNCTION update_pantry_status();

ALTER TABLE pantry
ADD CONSTRAINT fk_pantry_product
FOREIGN KEY (id)
REFERENCES products(id)
ON DELETE CASCADE
ON UPDATE CASCADE;

CREATE TABLE IF NOT EXISTS candy (
    id INT PRIMARY KEY,
    name VARCHAR(200),
    stock INT,
    expiry DATE,
    price DECIMAL(10, 2),
    status VARCHAR(20) CHECK (status IN ('in-stock', 'out-of-stock'))
);

CREATE OR REPLACE FUNCTION update_candy_status() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.stock > 0 THEN
        NEW.status := 'in-stock';
    ELSE
        NEW.status := 'out-of-stock';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_status_trigger
BEFORE INSERT OR UPDATE ON candy
FOR EACH ROW
EXECUTE FUNCTION update_candy_status();

ALTER TABLE candy
ADD CONSTRAINT fk_candy_product
FOREIGN KEY (id)
REFERENCES products(id)
ON DELETE CASCADE
ON UPDATE CASCADE;

CREATE TABLE IF NOT EXISTS beverages (
    id INT PRIMARY KEY,
    name VARCHAR(200),
    stock INT,
    expiry DATE,
    price DECIMAL(10, 2),
    status VARCHAR(20) CHECK (status IN ('in-stock', 'out-of-stock'))
);

CREATE OR REPLACE FUNCTION update_beverages_status() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.stock > 0 THEN
        NEW.status := 'in-stock';
    ELSE
        NEW.status := 'out-of-stock';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_status_trigger
BEFORE INSERT OR UPDATE ON beverages
FOR EACH ROW
EXECUTE FUNCTION update_beverages_status();

ALTER TABLE beverages
ADD CONSTRAINT fk_beverage_product
FOREIGN KEY (id)
REFERENCES products(id)
ON DELETE CASCADE
ON UPDATE CASCADE;

CREATE TABLE IF NOT EXISTS meatAndSeafood (
    id INT PRIMARY KEY,
    name VARCHAR(200),
    stock INT,
    expiry DATE,
    price DECIMAL(10, 2),
    status VARCHAR(20) CHECK (status IN ('in-stock', 'out-of-stock'))
);

CREATE OR REPLACE FUNCTION update_meatAndSeafood_status() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.stock > 0 THEN
        NEW.status := 'in-stock';
    ELSE
        NEW.status := 'out-of-stock';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_status_trigger
BEFORE INSERT OR UPDATE ON meatAndSeafood
FOR EACH ROW
EXECUTE FUNCTION update_meatAndSeafood_status();

ALTER TABLE meatAndSeafood
ADD CONSTRAINT fk_meat_and_seafood_product
FOREIGN KEY (id)
REFERENCES products(id)
ON DELETE CASCADE
ON UPDATE CASCADE;

CREATE TABLE IF NOT EXISTS bakeryAndDesserts (
    id INT PRIMARY KEY,
    name VARCHAR(200),
    stock INT,
    expiry DATE,
    price DECIMAL(10, 2),
    status VARCHAR(20) CHECK (status IN ('in-stock', 'out-of-stock'))
);

CREATE OR REPLACE FUNCTION update_bakeryAndDesserts_status() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.stock > 0 THEN
        NEW.status := 'in-stock';
    ELSE
        NEW.status := 'out-of-stock';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_status_trigger
    BEFORE INSERT OR UPDATE ON bakeryAndDesserts
    FOR EACH ROW
    EXECUTE FUNCTION update_bakeryAndDesserts_status();

ALTER TABLE bakeryAndDesserts
    ADD CONSTRAINT fk_bakery_and_dessert_product
    FOREIGN KEY (id)
    REFERENCES products(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

CREATE TABLE IF NOT EXISTS breakfast (
    id INT PRIMARY KEY,
    name VARCHAR(200),
    stock INT,
    expiry DATE,
    price DECIMAL(10, 2),
    status VARCHAR(20) CHECK (status IN ('in-stock', 'out-of-stock'))
);

CREATE OR REPLACE FUNCTION update_breakfast_status() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.stock > 0 THEN
        NEW.status := 'in-stock';
    ELSE
        NEW.status := 'out-of-stock';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_status_trigger
    BEFORE INSERT OR UPDATE ON breakfast
    FOR EACH ROW
    EXECUTE FUNCTION update_breakfast_status();

ALTER TABLE breakfast
    ADD CONSTRAINT fk_breakfast_product
    FOREIGN KEY (id)
    REFERENCES products(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

CREATE TABLE IF NOT EXISTS coffee (
    id INT PRIMARY KEY,
    name VARCHAR(200),
    stock INT,
    expiry DATE,
    price DECIMAL(10, 2),
    status VARCHAR(20) CHECK (status IN ('in-stock', 'out-of-stock'))
);

CREATE OR REPLACE FUNCTION update_coffee_status() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.stock > 0 THEN
        NEW.status := 'in-stock';
    ELSE
        NEW.status := 'out-of-stock';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_status_trigger
    BEFORE INSERT OR UPDATE ON coffee
    FOR EACH ROW
    EXECUTE FUNCTION update_coffee_status();

ALTER TABLE coffee
    ADD CONSTRAINT fk_coffee_product
    FOREIGN KEY (id)
    REFERENCES products(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

CREATE TABLE IF NOT EXISTS deli (
    id INT PRIMARY KEY,
    name VARCHAR(200),
    stock INT,
    expiry DATE,
    price DECIMAL(10, 2),
    status VARCHAR(20) CHECK (status IN ('in-stock', 'out-of-stock'))
);

CREATE OR REPLACE FUNCTION update_deli_status() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.stock > 0 THEN
        NEW.status := 'in-stock';
    ELSE
        NEW.status := 'out-of-stock';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_status_trigger
    BEFORE INSERT OR UPDATE ON deli
    FOR EACH ROW
    EXECUTE FUNCTION update_deli_status();

ALTER TABLE deli
    ADD CONSTRAINT fk_deli_product
    FOREIGN KEY (id)
    REFERENCES products(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

CREATE TABLE IF NOT EXISTS organic (
    id INT PRIMARY KEY,
    name VARCHAR(200),
    stock INT,
    expiry DATE,
    price DECIMAL(10, 2),
    status VARCHAR(20) CHECK (status IN ('in-stock', 'out-of-stock'))
);

CREATE OR REPLACE FUNCTION update_organic_status() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.stock > 0 THEN
        NEW.status := 'in-stock';
    ELSE
        NEW.status := 'out-of-stock';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_status_trigger
    BEFORE INSERT OR UPDATE ON organic
    FOR EACH ROW
    EXECUTE FUNCTION update_organic_status();

ALTER TABLE organic
    ADD CONSTRAINT fk_organic_product
    FOREIGN KEY (id)
    REFERENCES products(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

CREATE TABLE IF NOT EXISTS cleaning (
    id INT PRIMARY KEY,
    name VARCHAR(200),
    stock INT,
    price DECIMAL(10, 2),
    status VARCHAR(20) CHECK (status IN ('in-stock', 'out-of-stock'))
);

CREATE OR REPLACE FUNCTION update_cleaning_status() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.stock > 0 THEN
        NEW.status := 'in-stock';
    ELSE
        NEW.status := 'out-of-stock';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_status_trigger
    BEFORE INSERT OR UPDATE ON cleaning
    FOR EACH ROW
    EXECUTE FUNCTION update_cleaning_status();

ALTER TABLE cleaning
    ADD CONSTRAINT fk_cleaning_product
    FOREIGN KEY (id)
    REFERENCES products(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

CREATE TABLE IF NOT EXISTS floral (
    id INT PRIMARY KEY,
    name VARCHAR(200),
    stock INT,
    price DECIMAL(10, 2),
    status VARCHAR(20) CHECK (status IN ('in-stock', 'out-of-stock'))
);

CREATE OR REPLACE FUNCTION update_floral_status() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.stock > 0 THEN
        NEW.status := 'in-stock';
    ELSE
        NEW.status := 'out-of-stock';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_status_trigger
    BEFORE INSERT OR UPDATE ON floral
    FOR EACH ROW
    EXECUTE FUNCTION update_floral_status();

ALTER TABLE floral
    ADD CONSTRAINT fk_floral_product
    FOREIGN KEY (id)
    REFERENCES products(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

CREATE TABLE IF NOT EXISTS household (
    id INT PRIMARY KEY,
    name VARCHAR(200),
    stock INT,
    price DECIMAL(10, 2),
    status VARCHAR(20) CHECK (status IN ('in-stock', 'out-of-stock'))
);

CREATE OR REPLACE FUNCTION update_household_status() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.stock > 0 THEN
        NEW.status := 'in-stock';
    ELSE
        NEW.status := 'out-of-stock';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_status_trigger
    BEFORE INSERT OR UPDATE ON household
    FOR EACH ROW
    EXECUTE FUNCTION update_household_status();

ALTER TABLE household
    ADD CONSTRAINT fk_household_product
    FOREIGN KEY (id)
    REFERENCES products(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

INSERT INTO products (id, name, category, stock, expiry, price, status) VALUES
(1, 'cookies', 'Bakery & Desserts', 2, '2023-09-18', 56.99, 'in-stock'),
(2, 'cake', 'Bakery & Desserts', 29, '2023-03-08', 159.99, 'in-stock'),
(3, 'muffins', 'Bakery & Desserts', 33, '2023-05-03', 44.99, 'in-stock'),
(4, 'bread', 'Bakery & Desserts', 56, '2023-09-04', 39.99, 'in-stock'),
(5, 'croissant', 'Bakery & Desserts', 84, '2023-11-04', 59.99, 'in-stock'),
(6, 'danish', 'Bakery & Desserts', 84, '2023-10-26', 59.99, 'in-stock'),
(7, 'pie', 'Bakery & Desserts', 30, '2023-11-30', 74.99, 'in-stock'),
(8, 'cupcakes', 'Bakery & Desserts', 10, '2023-06-09', 59.99, 'in-stock'),
(9, 'baguette', 'Bakery & Desserts', 100, '2023-07-11', 29.99, 'in-stock'),
(10, 'brownie', 'Bakery & Desserts', 0, '2023-12-23', 159.99, 'out-of-stock');

INSERT INTO bakeryAndDesserts (id, name, stock, expiry, price, status) VALUES
(1, 'cookies', 2, '2023-09-18', 56.99, 'in-stock'),
(2, 'cake', 29, '2023-03-08', 159.99, 'in-stock'),
(3, 'muffins', 33, '2023-05-03', 44.99, 'in-stock'),
(4, 'bread', 56, '2023-09-04', 39.99, 'in-stock'),
(5, 'croissant', 84, '2023-11-04', 59.99, 'in-stock'),
(6, 'danish', 84, '2023-10-26', 59.99, 'in-stock'),
(7, 'pie', 30, '2023-11-30', 74.99, 'in-stock'),
(8, 'cupcakes', 10, '2023-06-09', 59.99, 'in-stock'),
(9, 'baguette', 100, '2023-07-11', 29.99, 'in-stock'),
(10, 'brownie', 0, '2023-12-23', 159.99, 'out-of-stock');

INSERT INTO users (id, name, email, password, role) VALUES
(1, 'Admin', 'admin@email.com', 'password', 'admin'),
(2, 'User', 'user@email.com', 'password', 'user');

INSERT INTO customers (id, name, email, image_url) VALUES
(1, 'Delba de Oliveira', 'delba@oliveira.com', '/customers/delba-de-oliveira.png'),
(2, 'Lee Robinson', 'lee@robinson.com', '/customers/lee-robinson.png'),
(3, 'Hector Simpson', 'hector@simpson.com', '/customers/hector-simpson.png');

INSERT INTO orders (id, customer_id, product_id, quantity, amount, date, status)
VALUES 
(1, 1, 1, 2, 8.99, '2023-11-06', 'pending'),
(2, 2, 2, 20, 189.99, '2023-12-14', 'pending');

select count(*) from products;

-- R6 --
-- Filtered search with pagination for products with 'Kirkland' --
SELECT *
FROM products
WHERE
products.id::text ILIKE '%cake%' OR
products.name ILIKE '%cake%' OR
products.category ILIKE '%cake%' OR
products.stock::text ILIKE '%cake%' OR
products.expiry::text ILIKE '%cake%' OR
products.price::text ILIKE '%cake%' OR
products.status ILIKE '%cake%'
ORDER BY products.stock DESC
LIMIT 5 OFFSET 10;

-- Filtered search with pagination for customers for 'Lee' --
SELECT
customers.id,
customers.name,
customers.email,
customers.image_url,
COUNT(orders.id) AS total_orders,
SUM(CASE WHEN orders.status = 'pending' THEN orders.amount ELSE 0 END) AS total_pending,
SUM(CASE WHEN orders.status = 'paid' THEN orders.amount ELSE 0 END) AS total_paid
FROM customers
LEFT JOIN orders ON customers.id = orders.customer_id
WHERE
customers.name ILIKE '%Lee%' OR
customers.email ILIKE '%Lee%'
GROUP BY customers.id, customers.name, customers.email, customers.image_url
ORDER BY customers.name ASC
LIMIT 5 OFFSET 0;

-- Filtered search with pagination for Orders with 'Lee' --
SELECT
orders.id,
orders.quantity,
orders.amount,
orders.date,
orders.status,
orders.product_id,
customers.name AS customer_name,
customers.image_url,
products.name AS product_name
FROM orders
JOIN customers ON orders.customer_id = customers.id
JOIN products ON orders.product_id = products.id
WHERE
customers.name ILIKE '%Lee%' OR
products.id::text ILIKE '%Lee%' OR
products.name ILIKE '%Lee%' OR
orders.amount::text ILIKE '%Lee%' OR
orders.date::text ILIKE '%Lee%' OR
orders.status ILIKE '%Lee%'
ORDER BY orders.date DESC
LIMIT 5 OFFSET 0;

-- R7 --
-- edit product --
select * from products where id = 5;

UPDATE products
SET name = 'Test', price = 99.99, stock = 50
WHERE id = 5;

select * from products where id = 5;

-- delete product --
DELETE FROM products WHERE id = 5;

select * from products where id = 5;

-- R8 --
-- inserting a new order --
select * from orders where id = 3;

INSERT INTO orders (id, customer_id, product_id, quantity, amount, date, status)
VALUES (3, 3, 3, 27, 16.99, '2024-02-29', 'paid');

select * from orders where id = 3;

-- editing order --
UPDATE orders
SET quantity = 5, status = 'pending'
WHERE id = 3;

select * from orders where id = 3;

-- deleting order --
DELETE FROM orders WHERE id = 3;

select * from orders where id = 3;

-- R9 --
-- inserting a new order --
select products.stock from products where products.id = 3;

INSERT INTO orders (id, customer_id, product_id, quantity, amount, date, status)
VALUES (3, 3, 3, 27, 16.99, '2024-02-29', 'paid');

select products.stock from products where products.id = 3;

-- editing order --
UPDATE orders
SET quantity = 3, status = 'paid'
WHERE id = 3;

select products.stock from products where products.id = 3;

-- R10 --
-- Get 3 best selling products --
SELECT 
products.id,
products.name,
products.category,
SUM(orders.amount) AS total_revenue,
SUM(orders.quantity) AS total_sold
FROM orders
JOIN products ON orders.product_id = products.id
WHERE orders.status = 'paid'
GROUP BY products.id, products.name, products.category
ORDER BY total_revenue DESC, total_sold DESC
LIMIT 3;

-- R11 --
-- Display a variety of information about the data --
-- orders --
SELECT COUNT(*) FROM orders;

-- customers --
SELECT COUNT(*) FROM customers;

-- products --
SELECT COUNT(*) FROM products;

-- total revenue --
SELECT SUM(revenue) AS total
FROM revenue;

-- paid / pending --
SELECT
SUM(CASE WHEN status = 'paid' THEN amount ELSE 0 END) AS "paid",
SUM(CASE WHEN status = 'pending' THEN amount ELSE 0 END) AS "pending"
FROM orders;

-- in stock --
SELECT COUNT(*)
FROM products
WHERE status = 'in-stock';

-- out of stock --
SELECT COUNT(*)
FROM products
WHERE status = 'out-of-stock';
