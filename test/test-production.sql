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
(1, 'Davids Cookies Mile High Peanut Butter Cake, 6.8 lbs (14 Servings)', 'Bakery & Desserts', 2, '2023-09-18', 56.99, 'in-stock'),
(2, 'The Cake Bake Shop 8 Round Carrot Cake (16-22 Servings)', 'Bakery & Desserts', 29, '2023-03-08', 159.99, 'in-stock'),
(3, 'St Michel Madeleine, Classic French Sponge Cake 100 - count', 'Bakery & Desserts', 33, '2023-05-03', 44.99, 'in-stock'),
(4, 'Davids Cookies Butter Pecan Meltaways 32 oz, 2-pack', 'Bakery & Desserts', 56, '2023-09-04', 39.99, 'in-stock'),
(5, 'Davids Cookies Premier Chocolate Cake, 7.2 lbs (Serves 14)', 'Bakery & Desserts', 84, '2023-11-04', 59.99, 'in-stock'),
(6, 'Davids Cookies Mango & Strawberry Cheesecake 2-count (28 Slices Total)', 'Bakery & Desserts', 84, '2023-10-26', 59.99, 'in-stock'),
(7, 'La Grande Galette French Butter Cookies, 1.3 lb, 6-pack', 'Bakery & Desserts', 30, '2023-11-30', 74.99, 'in-stock'),
(8, 'Davids Cookies No Sugar Added Cheesecake & Marble Truffle Cake, 2-pack (28 Slices Total)', 'Bakery & Desserts', 10, '2023-06-09', 59.99, 'in-stock'),
(9, 'Davids Cookies Brownie and Cookie Combo Pack', 'Bakery & Desserts', 100, '2023-07-11', 29.99, 'in-stock'),
(10, 'The Cake Bake Shop 8 Round Chocolate Cake (16-22 Servings)', 'Bakery & Desserts', 90, '2023-12-23', 159.99, 'in-stock'),
(11, 'Davids Cookies 10 Rainbow Cake (12 Servings)', 'Bakery & Desserts', 64, '2023-02-16', 62.99, 'in-stock'),
(12, 'The Cake Bake Shop 2 Tier Special Occasion Cake (16-22 Servings)', 'Bakery & Desserts', 60, '2023-07-19', 299.99, 'in-stock'),
(13, 'Davids Cookies 90-piece Gourmet Chocolate Chunk Frozen Cookie Dough', 'Bakery & Desserts', 44, '2023-12-14', 54.99, 'in-stock'),
(14, 'Davids Cookies Chocolate Fudge Birthday Cake, 3.75 lbs. Includes Party Pack (16 Servings)', 'Bakery & Desserts', 25, '2023-07-20', 54.99, 'in-stock'),
(15, 'Ferraras Bakery New York Cheesecake 2-pack', 'Bakery & Desserts', 2, '2023-11-21', 89.99, 'in-stock'),
(16, 'Davids Cookies Variety Cheesecakes, 2-pack (28 Slices Total)', 'Bakery & Desserts', 2, '2023-07-15', 59.99, 'in-stock'),
(17, 'Classic Cake Tiramisu Quarter Sheet Cake (14 Pre-Cut Total Slices, 4.57 Oz. Per Slice, 4 Lbs. Total Box)', 'Bakery & Desserts', 66, '2023-01-29', 89.99, 'in-stock'),
(18, 'Mary Macleods Gluten Free Shortbread Cookies Mixed Assortment 8-Pack', 'Bakery & Desserts', 4, '2023-06-06', 49.99, 'in-stock'),
(19, 'The Cake Bake Shop 8 Round Pixie Fetti Cake (16-22 Servings)', 'Bakery & Desserts', 61, '2023-03-09', 159.99, 'in-stock'),
(20, 'Classic Cake Chocolate Entremet Quarter Sheet Cake (14 Pre-Cut Total Slices, 4 Oz. Per Slice, 3.5 Lbs. Total Box)', 'Bakery & Desserts', 8, '2023-09-22', 89.99, 'in-stock'),
(21, 'Ferraras Bakery 8 in. Tiramisu Cake, 2-pack', 'Bakery & Desserts', 23, '2023-09-24', 99.99, 'in-stock'),
(22, 'Classic Cake Limoncello Quarter Sheet Cake (14 Pre-Cut Total Slices, 4 Oz. Per Slice, 3.5 Lbs Total Box)', 'Bakery & Desserts', 72, '2023-12-18', 89.99, 'in-stock'),
(23, 'deMilan Panettone Classico Tin Cake 2.2 lb Tin', 'Bakery & Desserts', 85, '2023-10-26', 24.99, 'in-stock'),
(24, 'Davids Cookies Decadent Triple Chocolate made with mini Hersheys Kisses and Reeses Peanut Butter Cup Cookies Tin – 2 Count', 'Bakery & Desserts', 96, '2023-09-23', 39.99, 'in-stock'),
(25, 'Ferraras Bakery 4 lbs. Italian Cookie Pack', 'Bakery & Desserts', 35, '2023-03-28', 72.99, 'in-stock'),
(26, 'Ferraras Bakery 48 Mini Cannolis (24 Plain Filled and 24 Hand Dipped Belgian Chocolate) - 1.5 to 2 In Length', 'Bakery & Desserts', 38, '2023-03-21', 119.99, 'in-stock'),
(27, 'Ferraras Bakery 24 Large Cannolis (12 Plain Filled and 12 Hand Dipped Belgian Chocolate)', 'Bakery & Desserts', 66, '2023-12-13', 109.99, 'in-stock'),
(28, 'Mary Macleods Shortbread, Variety Tin, 3-pack, 24 cookies per tin', 'Bakery & Desserts', 25, '2023-05-12', 99.99, 'in-stock'),
(29, 'Ferraras Bakery Rainbow Cookies 1.5 lb', 'Bakery & Desserts', 73, '2023-08-03', 34.99, 'in-stock'),
(30, 'Ferraras Bakery 2 lb Italian Cookie Tray and Struffoli', 'Bakery & Desserts', 97, '2023-06-10', 59.99, 'in-stock'),
(31, 'Tootie Pie 11 Heavenly Chocolate Pie, 2-pack', 'Bakery & Desserts', 12, '2023-03-15', 89.99, 'in-stock'),
(32, 'Tootie Pie 11 Whiskey Pecan Pie, 2-pack', 'Bakery & Desserts', 33, '2023-02-17', 89.99, 'in-stock'),
(33, 'Tootie Pie 11 Huge Original Apple Pie', 'Bakery & Desserts', 23, '2023-08-27', 59.99, 'in-stock');

INSERT INTO products (id, name, category, price, stock, expiry, status) VALUES
(1000, 'Pulp & Press Organic Cold-Pressed Wellness Shot Pack, 48-pack', 'Beverages & Water', 99.99, 95, '2023-05-03', 'in-stock'),
(1001, 'Prime Hydration+ Sticks Electrolyte Drink Mix, Variety Pack, 30-Count', 'Beverages & Water', 27.99, 74, '2023-10-27', 'in-stock'),
(1002, 'Prime Hydration Drink, Variety Pack, 16.9 fl oz, 15-count', 'Beverages & Water', 21.99, 24, '2023-05-12', 'in-stock'),
(1003, 'Alani Nu Energy Drink, Variety Pack, 12 fl oz, 18-count', 'Beverages & Water', 20.99, 79, '2023-10-05', 'in-stock'),
(1004, 'Poppi Prebiotic Soda, Variety Pack, 12 fl oz, 15-count', 'Beverages & Water', 19.99, 98, '2023-07-29', 'in-stock'),
(1005, 'Poppi Prebiotic Soda, Variety Pack, 12 fl oz, 15-count', 'Beverages & Water', 19.99, 67, '2023-08-18', 'in-stock'),
(1006, 'Kirkland Signature Bottled Water 16.9 fl oz, 40-count, 48 Case Pallet', 'Beverages & Water', 439.99, 75, '2023-02-15', 'in-stock'),
(1007, 'Kirkland Signature, Organic Almond Beverage, Vanilla, 32 fl oz, 6-Count', 'Beverages & Water', 9.99, 79, '2023-12-23', 'in-stock'),
(1008, 'Kirkland Signature, Almond Milk, 1 qt, 12-count', 'Beverages & Water', 14.99, 21, '2023-09-07', 'in-stock'),
(1009, 'Kirkland Signature, Organic Reduced Fat Chocolate Milk, 8.25 fl oz, 24-Count', 'Beverages & Water', 21.99, 92, '2023-07-15', 'in-stock'),
(1010, 'Kirkland Signature Colombian Cold Brew Coffee, 11 fl oz, 12-count', 'Beverages & Water', 18.99, 98, '2023-07-31', 'in-stock'),
(1011, 'Hint Flavored Water, Variety Pack, 16 fl oz, 21-count', 'Beverages & Water', 21.49, 7, '2023-08-26', 'in-stock'),
(1012, 'Califia Farms, Cafe Almond Milk, 32 oz, 6-Count', 'Beverages & Water', 17.99, 38, '2024-01-10', 'in-stock'),
(1013, 'Pulp and Press 3-Day Organic Cold Pressed Juice Cleanse', 'Beverages & Water', 89.99, 25, '2023-11-18', 'in-stock'),
(1014, 'Saratoga Sparkling Spring Water, 16 fl oz, 24-count', 'Beverages & Water', 23.99, 56, '2023-12-15', 'in-stock'),
(1015, 'Pure Life Purified Water, 8 fl oz, 24-count', 'Beverages & Water', 4.99, 20, '2023-05-19', 'in-stock'),
(1016, 'Fiji Natural Artesian Water, 23.7 fl oz, 12-count', 'Beverages & Water', 24.99, 85, '2023-12-17', 'in-stock'),
(1017, 'Tropicana, Apple Juice, 15.2 fl oz, 12-Count', 'Beverages & Water', 18.99, 6, '2023-12-23', 'in-stock'),
(1018, 'Olipop 12 oz Prebiotics Soda Variety Pack, 24 Count', 'Beverages & Water', 54.99, 29, '2023-01-18', 'in-stock'),
(1019, 'SO Delicious, Organic Coconut Milk, 32 oz, 6-Count', 'Beverages & Water', 12.99, 21, '2023-03-31', 'in-stock'),
(1020, 'La Colombe Draft Latte Cold Brew Coffee, Variety Pack, 9 fl oz, 12-count', 'Beverages & Water', 21.99, 29, '2023-07-20', 'in-stock'),
(1021, 'Tropicana, 100% Orange Juice, 10 fl oz, 24-Count', 'Beverages & Water', 18.99, 78, '2023-03-30', 'in-stock'),
(1022, 'Coca-Cola Mini, 7.5 fl oz, 30-count', 'Beverages & Water', 18.99, 53, '2023-09-29', 'in-stock'),
(1023, 'Joyburst Energy Variety, 12 fl oz, 18-count', 'Beverages & Water', 32.99, 54, '2023-08-19', 'in-stock'),
(1024, 'Illy Cold Brew Coffee Drink, Classico, 8.45 fl oz, 12-count', 'Beverages & Water', 29.99, 11, '2023-09-02', 'in-stock'),
(1025, 'Kirkland Signature, Organic Coconut Water, 33.8 fl oz, 9-count', 'Beverages & Water', 21.99, 79, '2023-09-26', 'in-stock'),
(1026, 'LaCroix Sparkling Water, Variety Pack, 12 fl oz, 24-count', 'Beverages & Water', 13.79, 78, '2024-01-05', 'in-stock'),
(1027, 'C4 Performance Energy Drink, Frozen Bombsicle, 16 fl oz, 12-count', 'Beverages & Water', 23.49, 38, '2023-09-23', 'in-stock'),
(1028, 'San Pellegrino Sparkling Natural Mineral Water, Unflavored, 11.15 fl oz, 24-count', 'Beverages & Water', 19.99, 28, '2023-03-23', 'in-stock'),
(1029, 'Kirkland Signature Green Tea Bags, 1.5 g, 100-count', 'Beverages & Water', 14.99, 88, '2023-03-31', 'in-stock'),
(1030, 'Horizon, Organic Whole Milk, 8 oz, 18-Count', 'Beverages & Water', 21.99, 92, '2023-12-19', 'in-stock'),
(1031, 'LaCroix Sparkling Water, Lime, 12 fl oz, 24-count', 'Beverages & Water', 13.79, 69, '2023-11-04', 'in-stock'),
(1032, 'Liquid Death Sparkling Water, 16.9 fl oz, 18-count', 'Beverages & Water', 14.99, 34, '2023-11-12', 'in-stock'),
(1033, 'Starbucks Classic Hot Cocoa Mix 30 oz, 2-pack', 'Beverages & Water', 34.99, 32, '2023-11-25', 'in-stock'),
(1034, 'VitaCup Green Tea Instant Packets with Matcha, Enhance Energy & Detox, 2-pack (48-count total)', 'Beverages & Water', 39.99, 47, '2023-03-21', 'in-stock'),
(1035, 'San Pellegrino Essenza, Variety Pack, 11.15 fl oz, 24-count', 'Beverages & Water', 19.99, 74, '2023-10-11', 'in-stock'),
(1036, 'Carnation, Evaporated Milk, 12 fl oz, 12-Count', 'Beverages & Water', 22.99, 97, '2023-09-23', 'in-stock'),
(1037, 'Sencha Naturals Everyday Matcha Green Tea Powder, 3-pack', 'Beverages & Water', 49.99, 81, '2023-02-23', 'in-stock'),
(1038, 'LaCroix Curate Commemorative Collection Sparkling Water, Variety Pack, 12 fl oz, 24-count', 'Beverages & Water', 14.99, 3, '2023-06-22', 'in-stock'),
(1039, 'Lipton, Iced Tea Mix, Lemon, 5 lbs', 'Beverages & Water', 8.99, 23, '2024-01-01', 'in-stock'),
(1040, 'San Pellegrino Italian Sparkling Drink, Variety Pack, 11.15 fl oz, 24-count', 'Beverages & Water', 23.99, 30, '2023-10-05', 'in-stock'),
(1041, 'Kirkland Signature, Organic Non-Dairy Oat Beverage, 32 oz, 6-count', 'Beverages & Water', 12.99, 15, '2023-12-29', 'in-stock'),
(1042, 'Horizon, Organic Low-fat Milk, 8 oz, 18-Count', 'Beverages & Water', 21.99, 61, '2023-09-25', 'in-stock'),
(1043, 'Vita Coco, Coconut Water, 11.1 fl oz, 18-Count', 'Beverages & Water', 23.99, 72, '2023-04-08', 'in-stock'),
(1044, 'Nestle La Lechera, Sweetened Condensed Milk, 14 oz, 6-Count', 'Beverages & Water', 15.99, 54, '2023-09-12', 'in-stock'),
(1045, 'Kirkland Signature, Organic Coconut Water, 11.1 fl oz, 12-count', 'Beverages & Water', 12.99, 66, '2023-05-04', 'in-stock'),
(1046, 'LaCroix Sparkling Water, Grapefruit, 12 fl oz, 24-count', 'Beverages & Water', 13.79, 77, '2023-12-04', 'in-stock'),
(1047, 'Celsius Sparkling Energy Drink, Variety Pack, 12 fl oz, 18-count', 'Beverages & Water', 28.99, 25, '2023-03-21', 'in-stock'),
(1048, 'Vita Coco, Coconut Water, Original, 16.9 fl oz, 12-Count', 'Beverages & Water', 27.99, 89, '2023-08-17', 'in-stock'),
(1049, 'San Pellegrino Italian Sparkling Drink, Aranciata Rossa, 11.15 fl oz, 24-count', 'Beverages & Water', 23.99, 2, '2023-10-10', 'in-stock'),
(1050, 'Vonbee Honey Citron & Ginger Tea 4.4 lb 2-pack', 'Beverages & Water', 34.99, 65, '2023-12-23', 'in-stock'),
(1051, 'Honest Kids, Organic Juice Drink, Variety Pack, 6 fl oz, 40-Count', 'Beverages & Water', 15.99, 89, '2023-07-08', 'in-stock'),
(1052, 'Lipton Original Tea Bags, 312-count', 'Beverages & Water', 12.99, 53, '2023-04-25', 'in-stock'),
(1053, 'San Pellegrino Italian Sparkling Drink, Melograno & Arancia, 11.15 fl oz, 24-count', 'Beverages & Water', 23.99, 90, '2023-09-20', 'in-stock'),
(1054, '5-hour Energy Shot, Regular Strength, Grape, 1.93 fl. oz, 24 Count', 'Beverages & Water', 39.99, 86, '2023-12-14', 'in-stock'),
(1055, 'Pepsi Mini, 7.5 fl oz, 30-count', 'Beverages & Water', 16.49, 40, '2023-12-15', 'in-stock'),
(1056, '100% Spring Water, 2.5 Gallon, 2-count, 48 Case Pallet', 'Beverages & Water', 549.99, 78, '2023-12-01', 'in-stock'),
(1057, 'Stash Tea, Variety Pack, 180-count', 'Beverages & Water', 17.49, 80, '2023-06-04', 'in-stock'),
(1058, 'C2O Coconut Water Hydration Pack, The Original, 17.5 fl oz, 15-count', 'Beverages & Water', 25.99, 83, '2023-04-30', 'in-stock'),
(1059, 'Oregon Chai, Original Organic Chai Tea Latte Concentrate, 32 fl. oz., 3-Count', 'Beverages & Water', 11.69, 84, '2023-04-15', 'in-stock'),
(1060, 'Tiesta Tea Blueberry Wild Child, 2 - 1 Pound Bags & 5.5oz Tin', 'Beverages & Water', 59.99, 61, '2023-06-27', 'in-stock'),
(1061, 'Pressed Cold-Pressed Juice & Shot Bundle -18 Bottles, 9 Juices & 9 Shots', 'Beverages & Water', 69.99, 80, '2023-11-18', 'in-stock'),
(1062, 'Ito En Jasmine Green Tea, Unsweetened, 16.9 fl oz, 12-count', 'Beverages & Water', 21.99, 94, '2023-03-28', 'in-stock'),
(1063, 'Pure Leaf Tea, Sweet Tea, 16.9 fl oz, 18-count', 'Beverages & Water', 19.99, 51, '2024-01-06', 'in-stock'),
(1064, 'Ito En Oi Ocha Unsweetened Green Tea, 16.9 fl oz, 12-count', 'Beverages & Water', 21.79, 3, '2023-05-25', 'in-stock');

INSERT INTO products (id, name, category, price, stock, expiry, status) VALUES
(2000, 'MadeGood Granola Minis, Variety Pack, 0.85 oz, 24-count', 'Breakfast', 10.49, 32, '2023-07-17', 'in-stock'),
(2001, 'Post, Honey Bunches of Oats with Almonds Cereal, 50 oz', 'Breakfast', 9.69, 33, '2023-09-05', 'in-stock'),
(2002, 'General Mills, Cheerios Cereal, Honey Nut, 27.5 oz, 2-Count', 'Breakfast', 8.19, 19, '2023-03-17', 'in-stock'),
(2003, 'Kirkland Signature Whole Grain Rolled Oats, 10 LBS', 'Breakfast', 9.99, 87, '2023-06-28', 'in-stock'),
(2004, 'NuTrail Keto Nut Granola Blueberry Cinnamon 2-Pack (22 oz each)', 'Breakfast', 28.99, 63, '2023-08-14', 'in-stock'),
(2005, 'NuTrail Keto Nut Granola Honey Nut 2-pack (22 oz. each)', 'Breakfast', 36.99, 6, '2023-10-29', 'in-stock'),
(2006, 'Quaker, Oats Old Fashioned Oatmeal, 10 lbs', 'Breakfast', 14.99, 13, '2023-07-07', 'in-stock'),
(2007, 'Cinnamon, Toast Crunch Cereal, 49.5 oz', 'Breakfast', 9.99, 90, '2023-08-13', 'in-stock'),
(2008, 'Kirkland Signature Organic Ancient Grain Granola, 35.3 oz', 'Breakfast', 10.49, 60, '2023-10-06', 'in-stock'),
(2009, 'Quaker Instant Oatmeal Cups, Variety Pack, 19.8 oz., 12-Count', 'Breakfast', 12.99, 98, '2023-07-27', 'in-stock'),
(2010, 'Idaho Spuds, Golden Grill Hashbrown Potatoes, 33.1 oz', 'Breakfast', 9.49, 40, '2023-11-17', 'in-stock'),
(2011, 'Kelloggs, Special K Red Berries Cereal, 43 oz', 'Breakfast', 12.49, 8, '2023-06-16', 'in-stock'),
(2012, 'General Mills Cereal Cup, Variety Pack, 12-count', 'Breakfast', 10.99, 35, '2023-02-27', 'in-stock'),
(2013, 'Krusteaz, Complete Buttermilk Pancake Mix, 10 lbs', 'Breakfast', 9.99, 1, '2023-08-15', 'in-stock'),
(2014, 'Quaker, Instant Oatmeal, Variety Pack, 1.51 oz, 52-Count', 'Breakfast', 11.99, 69, '2023-07-12', 'in-stock'),
(2015, 'General Mills, Cheerios Cereal, 20.35 oz, 2-Count', 'Breakfast', 9.99, 18, '2023-02-10', 'in-stock'),
(2016, 'Kelloggs Cereal Mini Boxes, Variety Pack, 25-count', 'Breakfast', 11.99, 70, '2023-12-17', 'in-stock'),
(2017, 'Kelloggs Frosted Flakes Cereal, 30.95 oz, 2-count', 'Breakfast', 10.99, 45, '2023-11-18', 'in-stock'),
(2018, 'Bisquick, Pancake & Baking Mix, 96 oz', 'Breakfast', 10.99, 4, '2023-12-18', 'in-stock'),
(2019, 'Kelloggs Cereal Cups, Family Variety Pack, 12-count', 'Breakfast', 12.69, 45, '2023-04-17', 'in-stock'),
(2020, 'Bobs Red Mill Organic Quick Cooking Steel Cut Oats, 7 lbs.', 'Breakfast', 14.99, 34, '2023-12-02', 'in-stock');

INSERT INTO products (id, name, category, price, stock, expiry, status) VALUES
(3000, '50-stem White Roses', 'Floral', 49.99, 31, '2023-02-27', 'in-stock'),
(3001, '100-stem Babys Breath', 'Floral', 74.99, 66, '2023-01-23', 'in-stock'),
(3002, 'Valentines Day Pre-Order Hugs and Kisses Arrangement', 'Floral', 59.99, 38, '2023-07-08', 'in-stock'),
(3003, 'Blushing Beauty Arrangement', 'Floral', 54.99, 20, '2023-06-12', 'in-stock'),
(3004, 'Valentines Day Pre-Order 50-stem Red Roses', 'Floral', 64.99, 17, '2023-04-06', 'in-stock'),
(3005, 'Valentines Day Pre-Order 50-stem Shades of Pink Roses', 'Floral', 64.99, 64, '2023-03-31', 'in-stock'),
(3006, 'Birthday Full of Happiness Floral Arrangement', 'Floral', 46.99, 74, '2024-01-05', 'in-stock'),
(3007, '50-stem Red Roses', 'Floral', 49.99, 79, '2023-02-03', 'in-stock'),
(3008, 'Valentines Day Pre-Order Red Romance Arrangement', 'Floral', 69.99, 75, '2023-04-23', 'in-stock'),
(3009, 'Truly Sweet Floral Arrangement', 'Floral', 59.99, 76, '2024-01-14', 'in-stock'),
(3010, '50-stem Light Pink Roses', 'Floral', 49.99, 63, '2023-10-23', 'in-stock'),
(3011, 'Valentines Day Pre-Order 50-stem Lavender Roses', 'Floral', 64.99, 22, '2023-07-01', 'in-stock'),
(3012, 'Inspire Floral Arrangement', 'Floral', 54.99, 63, '2023-07-10', 'in-stock'),
(3013, 'Tranquility Vase Arrangement', 'Floral', 49.99, 13, '2023-05-12', 'in-stock'),
(3014, 'Love You More Floral Arrangement', 'Floral', 55.99, 7, '2023-01-29', 'in-stock'),
(3015, 'Passion Vase Arrangement', 'Floral', 49.99, 26, '2023-03-06', 'in-stock'),
(3016, '24-stem Hydrangeas', 'Floral', 59.99, 75, '2023-01-31', 'in-stock'),
(3017, 'Mountain Bouquet Event Collection, 10-count', 'Floral', 99.99, 9, '2023-09-03', 'in-stock'),
(3018, 'Timeless Romance Floral Arrangement', 'Floral', 59.99, 35, '2023-03-20', 'in-stock'),
(3019, 'Valentines Day Pre-Order 50-stem Red & White Roses', 'Floral', 64.99, 93, '2023-12-31', 'in-stock'),
(3020, '50-stem Red & White Roses', 'Floral', 49.99, 76, '2023-05-12', 'in-stock'),
(3021, 'Bountiful Garden Bouquet', 'Floral', 43.99, 52, '2023-08-17', 'in-stock'),
(3022, '115-stem Floral Variety Combination', 'Floral', 99.99, 33, '2024-01-03', 'in-stock'),
(3023, 'Day Dream Vase Arrangement', 'Floral', 49.99, 91, '2023-04-14', 'in-stock'),
(3024, 'Mini Floral Centerpieces, 9-count', 'Floral', 109.99, 63, '2023-05-21', 'in-stock'),
(3025, '6 Wedding Runner, 4-pack', 'Floral', 109.99, 85, '2023-06-05', 'in-stock'),
(3026, 'Valentines Day Forever Roses', 'Floral', 129.99, 60, '2023-07-08', 'in-stock'),
(3027, '50-stem Lavender Roses', 'Floral', 49.99, 46, '2023-12-04', 'in-stock'),
(3028, 'Sunset Bliss Floral Arrangement', 'Floral', 56.99, 79, '2023-08-20', 'in-stock'),
(3029, '100-stem Fillers and Greens', 'Floral', 64.99, 41, '2023-02-07', 'in-stock'),
(3030, 'Valentines Day Cherish Forever Arrangement', 'Floral', 59.99, 44, '2023-06-14', 'in-stock'),
(3031, 'Birthday Celebration Floral Arrangement', 'Floral', 49.99, 97, '2023-12-15', 'in-stock'),
(3032, '100-stem White and Green Fillers', 'Floral', 69.99, 6, '2023-08-08', 'in-stock'),
(3033, '50-stem Shades of Pink Quad Roses', 'Floral', 49.99, 15, '2023-08-22', 'in-stock'),
(3034, 'Elegance Floral Arrangement', 'Floral', 46.99, 46, '2023-06-02', 'in-stock'),
(3035, '100-stem Carnations', 'Floral', 59.99, 45, '2023-11-27', 'in-stock'),
(3036, '50-stem Yellow Roses', 'Floral', 49.99, 28, '2023-09-21', 'in-stock'),
(3037, 'Valentines Day Pre-Order 50-stem Hot Pink / Light Pink Roses', 'Floral', 64.99, 13, '2023-05-10', 'in-stock'),
(3038, 'Mystical Garden Floral Arrangement', 'Floral', 57.99, 30, '2023-11-25', 'in-stock'),
(3039, 'Sunflower Sunshine Floral Arrangement', 'Floral', 56.99, 52, '2023-06-22', 'in-stock'),
(3040, '50-stem Hot Pink Roses', 'Floral', 49.99, 15, '2023-09-29', 'in-stock'),
(3041, '100-stem Assorted Green Fillers', 'Floral', 69.99, 13, '2023-08-20', 'in-stock'),
(3042, 'Get Well Wishes Floral Arrangement', 'Floral', 49.99, 6, '2023-04-05', 'in-stock'),
(3043, 'Fleur Floral Arrangement', 'Floral', 42.99, 35, '2023-12-16', 'in-stock'),
(3044, 'Fleur Vibrant Floral Arrangement', 'Floral', 43.99, 32, '2023-05-15', 'in-stock'),
(3045, 'Valentines Day Pre-Order Endless Love', 'Floral', 59.99, 69, '2023-12-03', 'in-stock'),
(3046, 'Fresh Wedding Garland', 'Floral', 109.99, 48, '2023-02-11', 'in-stock'),
(3047, 'Island Breeze Bouquet', 'Floral', 58.99, 52, '2023-08-30', 'in-stock'),
(3048, '80-stem Alstroemeria', 'Floral', 52.99, 23, '2023-12-25', 'in-stock'),
(3049, 'Thinking of You Floral Arrangement', 'Floral', 52.99, 100, '2023-03-20', 'in-stock'),
(3050, 'Valentines Day Pre-Order Red, White & Pink Romance Arrangement', 'Floral', 69.99, 4, '2023-05-24', 'in-stock'),
(3051, '120-stem Ranunculus', 'Floral', 179.99, 32, '2023-12-17', 'in-stock'),
(3052, 'Rose Petals', 'Floral', 74.99, 71, '2023-08-24', 'in-stock'),
(3053, 'White Garden Floral Arrangement', 'Floral', 45.99, 39, '2023-04-01', 'in-stock'),
(3054, '40-stem Sunflowers', 'Floral', 59.99, 65, '2023-11-20', 'in-stock'),
(3055, '40-stem Mini Green Hydrangeas', 'Floral', 64.99, 77, '2023-11-20', 'in-stock'),
(3056, 'Valentines Day Pre-Order Garden of Love Bouquet', 'Floral', 49.99, 78, '2023-06-11', 'in-stock'),
(3057, '60-stem Gerberas', 'Floral', 69.99, 73, '2023-09-20', 'in-stock'),
(3058, 'Valentines Day Pre-Order Red and White Romance Arrangement', 'Floral', 69.99, 63, '2023-09-26', 'in-stock'),
(3059, 'Valentines Day Pre-Order Mai Tai Tropical Bouquet', 'Floral', 56.99, 76, '2023-08-06', 'in-stock'),
(3060, 'Tranquil Garden Bouquet', 'Floral', 43.99, 59, '2023-08-08', 'in-stock'),
(3061, 'Bright and Beautiful Birthday Arrangement', 'Floral', 45.99, 94, '2023-12-16', 'in-stock'),
(3062, '30-stem Calla Lilies and 75-stem Roses', 'Floral', 119.99, 78, '2023-03-26', 'in-stock'),
(3063, 'Valentines Day Magical Love Arrangement', 'Floral', 59.99, 50, '2023-03-02', 'in-stock'),
(3064, 'Valentines Day Perfect Love', 'Floral', 49.99, 86, '2023-10-23', 'in-stock'),
(3065, 'Wildflower Floral Arrangement', 'Floral', 46.99, 22, '2023-12-28', 'in-stock'),
(3066, 'Valentines Day Pre-Order 50-stem White Roses', 'Floral', 64.99, 66, '2023-01-29', 'in-stock');

INSERT INTO products (id, name, category, price, stock, expiry, status) VALUES
(4000, 'Kirkland Signature Almonds, Milk Chocolate, 3 lb', 'Candy', 16.99, 45, '2024-01-03', 'in-stock'),
(4001, 'Kirkland Signature Raisins, Milk Chocolate, 3.4 lb', 'Candy', 15.99, 62, '2023-07-26', 'in-stock'),
(4002, 'Kinder Joy Egg, .7 oz, 12-count', 'Candy', 16.99, 80, '2023-01-23', 'in-stock'),
(4003, 'Kirkland Signature All Chocolate Bag, 90 oz,', 'Candy', 22.99, 26, '2023-06-16', 'in-stock'),
(4004, 'Motts Fruit Snacks, Assorted Fruit, 0.8 oz, 90-count', 'Candy', 10.99, 51, '2023-02-04', 'in-stock'),
(4005, 'Kinder Chocolate Mini, Milk Chocolate Candy Bar, 21.2 Oz Bulk', 'Candy', 11.99, 79, '2023-07-04', 'in-stock'),
(4006, 'Reeses Pieces, Peanut Butter, 48 oz', 'Candy', 15.99, 62, '2023-04-15', 'in-stock'),
(4007, 'Hersheys Milk Chocolate with Almonds, King Size, 18-count', 'Candy', 34.99, 21, '2023-12-12', 'in-stock'),
(4008, 'Utah Truffles Dark Chocolate Truffles With Sea Salt 16 oz, 2-pack', 'Candy', 29.99, 38, '2023-05-20', 'in-stock'),
(4009, 'Kelloggs Rice Krispies Treats, 0.78 oz, 60-count', 'Candy', 11.99, 6, '2024-01-08', 'in-stock'),
(4010, 'E.Frutti Gummi Pizza, 48-Count', 'Candy', 14.99, 58, '2023-03-03', 'in-stock'),
(4011, 'Mars Minis Chocolate Favorites, Variety Pack, 240-count', 'Candy', 24.99, 64, '2023-08-17', 'in-stock'),
(4012, 'Hersheys Milk Chocolate With Almonds, 1.45 oz, 36-count', 'Candy', 39.99, 62, '2023-08-15', 'in-stock'),
(4013, 'Utah Truffle Milk Chocolate Mint Truffles 16 oz, 2-pack', 'Candy', 29.99, 47, '2023-12-05', 'in-stock'),
(4014, 'Lindt Lindor Chocolate Truffles, Assorted Flavors, 21.2 oz', 'Candy', 15.99, 27, '2023-11-08', 'in-stock'),
(4015, 'Charms Mini Pops, Assorted Flavors, 400-count', 'Candy', 11.99, 32, '2023-06-11', 'in-stock'),
(4016, 'Chocolate Moonshine Co. Belgian Artisan Chocolate Caramel Biscuit Bark, 20 oz.', 'Candy', 44.99, 2, '2023-04-28', 'in-stock'),
(4017, 'M&Ms, Snickers and More Chocolate Candy Bars, Variety Pack, 30-count', 'Candy', 31.99, 84, '2023-09-27', 'in-stock'),
(4018, 'Ferrero Rocher, Milk Chocolate Hazelnut Candy, 21.2 oz, 48 Count', 'Candy', 17.99, 62, '2023-02-14', 'in-stock'),
(4019, 'Bouchard Belgian Napolitains Premium Dark Chocolate 32 oz,  2-pack', 'Candy', 49.99, 51, '2023-12-19', 'in-stock'),
(4020, 'Ghirardelli Chocolate Squares Premium Chocolate Assortment, 23.8 oz', 'Candy', 18.99, 32, '2023-05-28', 'in-stock'),
(4021, 'Ferrero Rocher, Milk Chocolate Hazelnut Candy, 1.3 oz, 3-count, 12-pack', 'Candy', 14.99, 100, '2023-04-04', 'in-stock'),
(4022, 'Godiva Masterpieces Assortment of Legendary Milk Chocolate 14.9 oz 4-Pack', 'Candy', 54.99, 94, '2023-12-17', 'in-stock'),
(4023, 'Charms Blow Pop, 0.65 oz, Assorted Bubble Gum Filled Pops, 100-count', 'Candy', 15.99, 73, '2023-10-27', 'in-stock'),
(4024, 'Kiss My Keto Gummy Candy Fish Friends, 6-count, 2-pack', 'Candy', 32.99, 87, '2023-01-29', 'in-stock'),
(4025, 'Chocolate Moonshine Co. Belgian Artisan Black Cherry Bourbon Bark, 20 oz.', 'Candy', 44.99, 38, '2023-05-30', 'in-stock'),
(4026, 'Kiss My Keto Gummies Tropical Rings, 6-count, 2-pack', 'Candy', 32.99, 85, '2023-09-27', 'in-stock'),
(4027, 'Topps Jumbo Push Pops, Variety Pack, 1.06 oz, 18-Count', 'Candy', 28.99, 52, '2023-04-20', 'in-stock'),
(4028, 'Reeses Peanut Butter Cups, Miniatures, 0.31 oz, 105-count', 'Candy', 12.99, 40, '2023-10-13', 'in-stock'),
(4029, 'Dove Milk Chocolate Candy Bars, Full Size, 1.44 oz, 18-count', 'Candy', 19.99, 32, '2023-09-06', 'in-stock'),
(4030, 'Ice Breakers Ice Cubes Sugar Free Gum, Arctic Grape, 40 pieces, 4 ct, 160 pieces', 'Candy', 15.49, 71, '2023-07-22', 'in-stock'),
(4031, 'Altoids Smalls Breath Mints, Sugar Free Peppermint, 0.37 oz, 9-count', 'Candy', 10.99, 37, '2023-09-03', 'in-stock'),
(4032, 'Kirkland Signature Funhouse Treats, Variety Pack, 92 oz', 'Candy', 21.99, 71, '2023-06-13', 'in-stock'),
(4033, 'Godiva Assorted Chocolate Gold Collection Gift Box 36-pieces', 'Candy', 46.99, 50, '2023-11-25', 'in-stock'),
(4034, 'Starburst Original Chewy Candy, 54 oz Jar', 'Candy', 11.49, 57, '2023-06-06', 'in-stock'),
(4035, 'Reeses Peanut Butter Cups, Milk Chocolate, 1.5 oz, 36-count', 'Candy', 39.99, 80, '2023-09-21', 'in-stock'),
(4036, 'Hersheys Kisses, Milk Chocolate, 56 oz', 'Candy', 16.39, 82, '2023-05-25', 'in-stock'),
(4037, 'Haribo Goldbears Gummi Candy, 2 oz, 24-count', 'Candy', 19.99, 76, '2023-02-13', 'in-stock'),
(4038, 'Ice Breaker Duos Mints, Strawberry and Mint, 1.3 oz, 8-count', 'Candy', 17.49, 85, '2023-11-15', 'in-stock'),
(4039, 'Skittles and Starburst Chewy Candy, Variety Pack, Full Size, 30-count', 'Candy', 29.99, 85, '2023-06-23', 'in-stock'),
(4040, 'Heath Bar, 1.4 oz, 18-count', 'Candy', 19.99, 52, '2023-03-12', 'in-stock'),
(4041, 'Fruit Gushers Fruit Flavored Snacks, Variety Pack, 0.8 oz, 42-Count', 'Candy', 15.99, 89, '2023-09-15', 'in-stock'),
(4042, 'Nutella & GO! Hazelnut and Cocoa Spread With Pretzels, 1.9 oz, 16 Pack', 'Candy', 18.99, 36, '2023-06-23', 'in-stock'),
(4043, 'Ice Breakers Cube Peppermint Gum, 40 pieces, 4-count', 'Candy', 14.99, 26, '2023-12-30', 'in-stock'),
(4044, 'AirHeads, 0.55 oz, Variety Pack, 90-count', 'Candy', 15.99, 100, '2023-02-21', 'in-stock'),
(4045, 'Sanders Dark Chocolate Sea Salt Caramels 36 oz., 2-pack', 'Candy', 34.99, 44, '2023-01-23', 'in-stock'),
(4046, 'Original Gourmet Lollipops, Variety, 50-count', 'Candy', 17.99, 34, '2023-08-21', 'in-stock'),
(4047, 'M&Ms Milk Chocolate Candy, 62 oz Jar', 'Candy', 18.99, 44, '2023-08-09', 'in-stock'),
(4048, 'Mentos Pure Fresh Sugar Free Gum, Fresh Mint, 15 Pieces, 10-count', 'Candy', 13.99, 48, '2023-03-10', 'in-stock'),
(4049, 'Hersheys Miniatures, Variety Pack, 56 oz', 'Candy', 19.99, 51, '2023-04-12', 'in-stock'),
(4050, 'Hersheys Nuggets Assortment, Variety Pack, 145-count', 'Candy', 16.39, 57, '2023-10-01', 'in-stock'),
(4051, 'Hersheys Milk Chocolate, 1.55 oz, 36-count', 'Candy', 39.99, 12, '2023-10-11', 'in-stock'),
(4052, 'Pocky Chocolate Biscuit Stick, 1.41 oz, 10-count', 'Candy', 9.99, 81, '2024-01-11', 'in-stock'),
(4053, 'Nerds Candy, Grape and Strawberry, 1.65 oz, 24-Count', 'Candy', 19.99, 27, '2023-03-20', 'in-stock'),
(4054, 'Extra Sugar Free Chewing Gum, Mint Variety Pack, 15 Sticks, 18-Count', 'Candy', 17.99, 73, '2023-12-11', 'in-stock'),
(4055, 'Kinder Bueno Mini, Chocolate and Hazelnut Cream Chocolate Bars, 17.1 oz', 'Candy', 11.99, 90, '2023-05-03', 'in-stock'),
(4056, 'Sour Punch Twists, Variety, 180-count', 'Candy', 16.99, 95, '2023-07-25', 'in-stock'),
(4057, 'Ice Breakers Sugar Free Mints, Wintergreen, 1.5 oz, 8-count', 'Candy', 16.99, 82, '2023-10-29', 'in-stock'),
(4058, 'Extra Sugar Free Chewing Gum, Sweet Watermelon, Slim Pack, 15 Sticks, 10-Count', 'Candy', 11.49, 37, '2024-01-12', 'in-stock'),
(4059, 'Hersheys Nuggets, Milk Chocolate, 52 oz, 145 pieces', 'Candy', 19.99, 92, '2023-12-18', 'in-stock'),
(4060, 'Sour Punch Straws, Strawberry, 2 oz, 24-count', 'Candy', 17.99, 38, '2023-09-24', 'in-stock'),
(4061, 'Twix Share Size Chocolate Caramel Cookie Candy Bar, 3.02 oz, 24-count', 'Candy', 44.99, 12, '2023-07-24', 'in-stock'),
(4062, 'Trident Sugar Free Gum, Cinnamon, 14 Pieces, 15-count', 'Candy', 10.99, 67, '2023-10-05', 'in-stock'),
(4063, 'E.Frutti Gummi Hot Dog, 0.35 oz, 60-count', 'Candy', 8.99, 84, '2023-02-24', 'in-stock'),
(4064, 'Trolli Sour Brite Crawlers Candy, 5 oz, 16-count', 'Candy', 24.99, 99, '2023-04-04', 'in-stock'),
(4065, 'Swedish Fish Soft & Chewy Candy, 2 oz, 24-count', 'Candy', 24.99, 80, '2023-01-16', 'in-stock'),
(4066, 'Haribo Goldbears Gummi Candy, Mini Bags, 0.4 oz, 125-count', 'Candy', 16.49, 67, '2023-04-20', 'in-stock'),
(4067, 'Life Savers Breath Mints Hard Candy, Wint-O-Green, 53.95 oz Bag', 'Candy', 10.49, 15, '2023-09-21', 'in-stock'),
(4068, 'Hi-Chew Fruit Chews, Original Mix, 30 oz', 'Candy', 11.99, 63, '2023-07-17', 'in-stock');

INSERT INTO products (id, name, category, price, stock, expiry, status) VALUES
(5000, 'Tide Pods HE Laundry Detergent Pods, Free & Gentle, 152-count', 'Cleaning Supplies', 28.99, 21, '2023-08-25', 'in-stock'),
(5001, 'Tide Pods HE Laundry Detergent Pods, Spring Meadow, 156-count', 'Cleaning Supplies', 28.99, 100, '2023-03-17', 'in-stock'),
(5002, 'Tide Ultra Concentrated Liquid Laundry Detergent, 152 Loads, 170 fl oz', 'Cleaning Supplies', 24.99, 87, '2023-11-02', 'in-stock'),
(5003, 'Swiffer Duster Heavy Duty Dusting Kit, 1 Handle + 17 Refills', 'Cleaning Supplies', 15.99, 19, '2023-05-30', 'in-stock'),
(5004, 'Swiffer Sweeper Heavy Duty Dry Sweeping Cloth Refills, 50-count', 'Cleaning Supplies', 15.99, 26, '2023-03-06', 'in-stock'),
(5005, 'Gain Ultra Concentrated +AromaBoost HE Liquid Laundry Detergent, Original, 159 Loads, 208 fl oz', 'Cleaning Supplies', 19.49, 18, '2023-03-30', 'in-stock'),
(5006, 'Dawn Platinum Advanced Power Liquid Dish Soap, 90 fl oz', 'Cleaning Supplies', 12.09, 32, '2023-10-03', 'in-stock'),
(5007, 'Cascade Platinum Plus Dishwasher Detergent Pacs, Fresh, 81-count', 'Cleaning Supplies', 19.99, 62, '2023-04-30', 'in-stock'),
(5008, 'Bounce Dryer Sheets, Outdoor Fresh, 160-count, 2-pack', 'Cleaning Supplies', 10.79, 1, '2023-06-23', 'in-stock'),
(5009, 'Lysol Disinfecting Wipes, Variety Pack, 95-count, 4-pack', 'Cleaning Supplies', 16.99, 30, '2023-10-21', 'in-stock'),
(5010, 'Downy Unstopables In-Wash Scent Booster Beads, Fresh, 34 oz', 'Cleaning Supplies', 17.89, 25, '2023-02-28', 'in-stock'),
(5011, 'Downy Ultra Concentrated HE Fabric Softener, April Fresh, 251 Loads, 170 fl oz', 'Cleaning Supplies', 13.99, 80, '2023-06-26', 'in-stock'),
(5012, 'Nellies Laundry Soda, 400 Loads', 'Cleaning Supplies', 42.99, 35, '2023-04-06', 'in-stock'),
(5013, 'Tide Advanced Power with Oxi Liquid Laundry Detergent, Original, 78 Loads, 145 fl oz', 'Cleaning Supplies', 23.99, 9, '2023-09-07', 'in-stock'),
(5014, 'Tide HE Ultra Oxi Powder Laundry Detergent, Original, 143 Loads, 250 oz', 'Cleaning Supplies', 34.99, 38, '2023-08-21', 'in-stock'),
(5015, 'Tide Pods with Ultra Oxi HE Laundry Detergent Pods, 104-count', 'Cleaning Supplies', 28.79, 49, '2023-06-12', 'in-stock'),
(5016, 'Downy Fresh Protect In-Wash Odor Defense Scent Beads, April Fresh, 34 oz', 'Cleaning Supplies', 21.49, 67, '2023-01-24', 'in-stock'),
(5017, 'Nellies Laundry Starter Pack', 'Cleaning Supplies', 54.99, 73, '2023-12-02', 'in-stock'),
(5018, 'Kirkland Signature Ultra Clean HE Liquid Laundry Detergent, 146 loads, 194 fl oz', 'Cleaning Supplies', 21.99, 70, '2023-07-29', 'in-stock'),
(5019, 'Kirkland Signature Ultra Clean Free & Clear HE Liquid Laundry Detergent, 146 loads, 194 fl oz', 'Cleaning Supplies', 19.99, 32, '2023-03-08', 'in-stock'),
(5020, 'Nellies Baby Laundry Soda, 500 Loads', 'Cleaning Supplies', 89.99, 83, '2023-03-25', 'in-stock'),
(5021, 'Kirkland Signature Ultra Clean HE Laundry Detergent Pacs, 152-count', 'Cleaning Supplies', 22.99, 2, '2023-11-29', 'in-stock'),
(5022, 'Scotch-Brite Zero Scratch Sponge, 24-count', 'Cleaning Supplies', 14.49, 77, '2023-12-22', 'in-stock'),
(5023, 'Nellies Laundry Nuggets, 350 Loads', 'Cleaning Supplies', 84.99, 53, '2023-10-08', 'in-stock'),
(5024, 'Nellies Laundry Soda, 800 Loads', 'Cleaning Supplies', 89.99, 92, '2023-10-01', 'in-stock'),
(5025, 'Scotch-Brite Heavy Duty Sponge, 24-count', 'Cleaning Supplies', 14.49, 70, '2023-03-15', 'in-stock'),
(5026, 'ECOS HE Laundry Detergent Sheets, Free & Clear, 100 Loads, 100 Sheets, 2-count', 'Cleaning Supplies', 38.99, 40, '2023-07-10', 'in-stock'),
(5027, 'ECOS HE Liquid Laundry Detergent, Magnolia & Lily, 210 Loads, 210 fl oz, 2-count', 'Cleaning Supplies', 38.99, 18, '2023-05-24', 'in-stock'),
(5028, 'Kirkland Signature Platinum Performance UltraShine Dishwasher Detergent Pacs, 115-count', 'Cleaning Supplies', 13.99, 43, '2023-08-24', 'in-stock'),
(5029, 'Kirkland Signature 10-Gallon Wastebasket Liner, Clear, 500-count', 'Cleaning Supplies', 13.99, 67, '2023-11-16', 'in-stock'),
(5030, 'Boulder Clean Laundry Detergent Sheets, Free & Clear, 160 Loads, 80 Sheets', 'Cleaning Supplies', 29.99, 61, '2023-08-31', 'in-stock'),
(5031, 'Arm & Hammer Plus OxiClean Max HE Liquid Laundry Detergent, Fresh, 200 Loads, 200 fl oz', 'Cleaning Supplies', 17.99, 1, '2023-02-14', 'in-stock'),
(5032, 'All Free & Clear Plus+ HE Liquid Laundry Detergent, 158 loads, 237 fl oz', 'Cleaning Supplies', 16.99, 86, '2023-06-25', 'in-stock'),
(5033, 'simplehuman Custom Fit Liners, 300-pack', 'Cleaning Supplies', 32.99, 36, '2023-12-30', 'in-stock'),
(5034, 'Cascade Advanced Power Liquid Dishwasher Detergent, Fresh Scent, 125 fl oz', 'Cleaning Supplies', 12.99, 32, '2023-02-24', 'in-stock'),
(5035, 'ECOS HE Liquid Laundry Detergent, Free & Clear, 210 Loads, 210 fl oz, 2-count', 'Cleaning Supplies', 38.99, 86, '2023-12-20', 'in-stock'),
(5036, 'Tide Ultra Concentrated with Downy HE Liquid Laundry Detergent, April Fresh, 110 loads, 150 fl oz', 'Cleaning Supplies', 22.99, 9, '2023-12-12', 'in-stock'),
(5037, 'Clorox Disinfecting Wipes, Variety Pack, 85-count, 5-pack', 'Cleaning Supplies', 22.99, 54, '2023-10-29', 'in-stock'),
(5038, 'Cascade Complete Dishwasher Detergent Actionpacs, 90-count', 'Cleaning Supplies', 20.89, 15, '2023-05-16', 'in-stock'),
(5039, 'The Unscented Company Liquid Laundry Detergent Refill Box, 400 Loads, 337.92 fl oz', 'Cleaning Supplies', 44.99, 32, '2023-06-04', 'in-stock'),
(5040, 'MyEcoWorld 13-gallon Compostable Food Waste Bag, 72-count', 'Cleaning Supplies', 36.99, 43, '2023-05-02', 'in-stock'),
(5041, 'Kirkland Signature Ultra Shine Liquid Dish Soap, Fresh, 90 fl oz', 'Cleaning Supplies', 9.79, 94, '2023-05-16', 'in-stock'),
(5042, 'MyEcoWorld 3-gallon Compostable Food Waste Bag, 150-count', 'Cleaning Supplies', 29.89, 66, '2023-04-21', 'in-stock'),
(5043, 'Tide Pods with Downy HE Laundry Detergent Pods, April Fresh, 104-count', 'Cleaning Supplies', 29.99, 49, '2023-10-06', 'in-stock'),
(5044, 'The Unscented Company HE Liquid Laundry Detergent Bottle & Refill Box, 478 Loads, 403.82 fl oz', 'Cleaning Supplies', 54.99, 98, '2023-06-09', 'in-stock'),
(5045, 'Nellies Dish Butter Bundle', 'Cleaning Supplies', 39.99, 97, '2023-11-16', 'in-stock'),
(5046, 'Lysol HE Laundry Sanitizer, Crisp Linen, 150 fl oz', 'Cleaning Supplies', 19.99, 97, '2023-07-18', 'in-stock'),
(5047, 'Cascade Platinum Dishwasher Detergent Actionpacs, 92-count', 'Cleaning Supplies', 24.99, 15, '2023-07-03', 'in-stock'),
(5048, 'Kirkland Signature Antibacterial Liquid Dish Soap, Green Apple, 90 fl oz', 'Cleaning Supplies', 9.49, 86, '2023-11-18', 'in-stock'),
(5049, 'Clorox Clean-Up All Purpose Cleaner with Bleach, Original, 32 oz & 180 oz Refill', 'Cleaning Supplies', 22.99, 7, '2023-02-17', 'in-stock'),
(5050, 'Boulder Clean Liquid Laundry Detergent, Citrus Breeze, 200 loads, 200 fl oz', 'Cleaning Supplies', 24.99, 54, '2023-04-09', 'in-stock'),
(5051, 'Finish Powerball Quantum Dishwasher Detergent Tabs, 100-count', 'Cleaning Supplies', 22.99, 96, '2023-05-12', 'in-stock'),
(5052, 'The Unscented Company Liquid Dish Soap Refill Box, 337.92 fl oz', 'Cleaning Supplies', 41.99, 92, '2023-02-06', 'in-stock'),
(5053, 'Kirkland Signature Flex-Tech 13-Gallon Kitchen Trash Bag, 200-count', 'Cleaning Supplies', 19.99, 95, '2023-08-19', 'in-stock'),
(5054, 'Palmolive Ultra Strength Liquid Dish Soap, 102 fl oz', 'Cleaning Supplies', 10.99, 9, '2023-08-26', 'in-stock'),
(5055, 'The Unscented Company Laundry Tabs, 300 Loads', 'Cleaning Supplies', 74.99, 41, '2023-01-29', 'in-stock'),
(5056, 'Scotch-Brite Lint Roller, 95-count, 5-pack', 'Cleaning Supplies', 17.89, 17, '2023-09-17', 'in-stock'),
(5057, 'Clear-Touch Food Handling Nitrile Gloves, 500-count', 'Cleaning Supplies', 29.99, 9, '2023-07-03', 'in-stock'),
(5058, 'Nellies Wow Mop Starter Kit', 'Cleaning Supplies', 199.99, 36, '2023-12-29', 'in-stock'),
(5059, 'O-Cedar EasyWring Spin Mop & Bucket System with 3 Refills', 'Cleaning Supplies', 42.99, 68, '2023-04-06', 'in-stock'),
(5060, 'The Unscented Company Liquid Dish Soap Bottle & Refill Box, 363.22 fl oz', 'Cleaning Supplies', 49.99, 28, '2023-07-15', 'in-stock'),
(5061, 'Kirkland Signature Fabric Softener Sheets, 250-count, 2-pack', 'Cleaning Supplies', 11.99, 75, '2023-08-06', 'in-stock'),
(5062, 'Windex Original Glass Cleaner, 32 fl oz & 169 fl oz Refill', 'Cleaning Supplies', 14.99, 56, '2023-04-29', 'in-stock'),
(5063, 'Fabuloso Multi-Purpose Cleaner, Lavender, 210 fl oz', 'Cleaning Supplies', 12.49, 15, '2023-02-18', 'in-stock'),
(5064, 'Simple Green All-Purpose Cleaner, 32 fl oz + 140 fl oz Refill', 'Cleaning Supplies', 10.99, 53, '2023-04-29', 'in-stock');

INSERT INTO products (id, name, category, price, stock, expiry, status) VALUES
(6000, 'Kirkland Signature Coffee Organic Pacific Bold K-Cup Pod, 120-count', 'Coffee', 31.99, 87, '2023-07-22', 'in-stock'),
(6001, 'Kirkland Signature Coffee Organic Summit Roast K-Cup Pod, 120-count', 'Coffee', 31.99, 67, '2023-08-22', 'in-stock'),
(6002, 'Kirkland Signature Coffee Organic Breakfast Blend K-Cup Pod, 120-count', 'Coffee', 31.99, 45, '2023-02-21', 'in-stock'),
(6003, 'Folgers Classic Roast Ground Coffee, Medium, 43.5 oz', 'Coffee', 10.29, 33, '2023-10-16', 'in-stock'),
(6004, 'Starbucks Dark French Roast K-Cup, 72-count', 'Coffee', 42.99, 58, '2023-01-28', 'in-stock'),
(6005, 'Kirkland Signature Coffee Organic House Decaf K-Cup Pod, 120-count', 'Coffee', 31.99, 79, '2023-01-30', 'in-stock'),
(6006, 'Kirkland Signature Organic Ethiopia Whole Bean Coffee, 2 lbs', 'Coffee', 19.99, 8, '2024-01-07', 'in-stock'),
(6007, 'Kirkland Signature Whole Bean Coffee, French Roast, 2.5 lbs', 'Coffee', 13.99, 66, '2023-12-10', 'in-stock'),
(6008, 'Kirkland Signature Organic Colombian Decaf Whole Bean Coffee, 2 lbs', 'Coffee', 18.99, 96, '2023-12-08', 'in-stock'),
(6009, 'Kirkland Signature Organic Sumatra Whole Bean Coffee, 2 lbs, 2-pack', 'Coffee', 42.99, 7, '2023-02-26', 'in-stock'),
(6010, 'Starbucks Coffee Single Origin Sumatra Dark Roast K-Cup, 72-count', 'Coffee', 42.99, 95, '2023-10-07', 'in-stock'),
(6011, 'Kirkland Signature Rwandan Coffee 3 lb, 2-pack', 'Coffee', 37.99, 19, '2023-02-11', 'in-stock'),
(6012, 'Peets Coffee Major Dickasons Blend Coffee, Dark Roast, Whole Bean, 2 lbs', 'Coffee', 18.99, 5, '2023-04-11', 'in-stock'),
(6013, 'Kirkland Signature House Blend Coffee, Medium Roast, Whole Bean, 2.5 lbs', 'Coffee', 17.99, 62, '2023-01-18', 'in-stock'),
(6014, 'Peets Coffee Decaf House Blend K-Cup Pod, 75-count', 'Coffee', 42.99, 82, '2023-12-01', 'in-stock'),
(6015, 'Kirkland Signature Sumatran Whole Bean Coffee 3 lb, 2-pack', 'Coffee', 44.99, 27, '2023-07-22', 'in-stock'),
(6016, 'Starbucks Pike Place Medium Roast K-Cup, 72-count', 'Coffee', 42.99, 77, '2023-01-28', 'in-stock'),
(6017, 'Kirkland Signature Colombian Supremo Coffee, Whole Bean, 3 lbs', 'Coffee', 20.99, 23, '2023-10-01', 'in-stock'),
(6018, 'Peets Coffee Major Dickasons Blend K-Cup Pod, 75-count', 'Coffee', 42.99, 82, '2023-03-25', 'in-stock'),
(6019, 'Peets Coffee Major Dickasons Blend Whole Bean, 10.5 oz Bags, 6-pack', 'Coffee', 42.99, 24, '2023-04-20', 'in-stock'),
(6020, 'Kirkland Signature Costa Rica Coffee 3 lb, 2-pack', 'Coffee', 37.99, 27, '2023-09-21', 'in-stock'),
(6021, 'Lavazza Caffe Espresso 100% Premium Arabica Coffee, Whole Bean, 2.2 lbs', 'Coffee', 17.99, 60, '2023-04-24', 'in-stock'),
(6022, 'Kirkland Signature Espresso Blend Coffee, Dark Roast, Whole Bean, 2.5 lbs', 'Coffee', 18.99, 67, '2023-08-23', 'in-stock'),
(6023, 'Starbucks Coffee Caffe Verona Dark Roast K-Cup Pod, 72-count', 'Coffee', 42.99, 47, '2023-11-15', 'in-stock'),
(6024, 'Kirkland Signature USDA Organic Whole Bean Blend 2 lb, 2-pack', 'Coffee', 29.99, 6, '2023-06-02', 'in-stock'),
(6025, 'Starbucks Coffee Veranda Blend Blonde Roast K-Cup, 72-count', 'Coffee', 42.99, 39, '2023-04-26', 'in-stock'),
(6026, 'Kirkland Signature 100% Colombian Coffee, Dark Roast, 3 lbs', 'Coffee', 14.99, 26, '2023-02-13', 'in-stock'),
(6027, 'Kirkland Signature Decaf House Blend Coffee, Medium Roast, Whole Bean, 2.5 lbs', 'Coffee', 19.99, 6, '2023-04-23', 'in-stock'),
(6028, 'Lavazza Espresso Gran Crema Whole Bean Coffee, Medium, 2.2 lbs', 'Coffee', 17.99, 54, '2023-05-20', 'in-stock'),
(6029, 'San Francisco Bay Coffee French Roast OneCup, 100-count', 'Coffee', 35.99, 44, '2024-01-04', 'in-stock'),
(6030, 'Kirkland Signature Decaffeinated Coffee, Dark Roast, 3 lbs', 'Coffee', 16.99, 47, '2023-06-02', 'in-stock'),
(6031, 'Nescafe Tasters Choice Instant Coffee, House Blend, 14 oz', 'Coffee', 18.99, 87, '2023-01-30', 'in-stock'),
(6032, 'Mayorga Buenos Dias, USDA Organic, Light Roast, Whole Bean Coffee, 2lb, 2-pack', 'Coffee', 39.99, 97, '2023-11-04', 'in-stock'),
(6033, 'Copper Moon Coffee Dark Sky Whole Bean Coffee, Dark, 5 lbs', 'Coffee', 28.99, 13, '2023-02-28', 'in-stock'),
(6034, 'Peets Coffee Org French Roast K-Cup Pod, 75-count', 'Coffee', 42.99, 18, '2023-01-27', 'in-stock'),
(6035, 'Peets Coffee Decaf Major Dickasons Ground, 10.5 oz Bags, 6-pack', 'Coffee', 42.99, 30, '2023-03-03', 'in-stock'),
(6036, 'Ruta Maya Organic Jiguani Whole Bean Coffee 5 lb', 'Coffee', 47.99, 84, '2023-10-13', 'in-stock'),
(6037, 'Peets Coffee Big Bang Ground, 10.5 oz Bags, 6-pack', 'Coffee', 42.99, 66, '2023-09-12', 'in-stock'),
(6038, 'Dunkin Donuts Original Blend, 45 oz', 'Coffee', 25.99, 64, '2023-11-20', 'in-stock'),
(6039, 'Tim Hortons Coffee Original Blend K-Cup Pod, 110-count', 'Coffee', 44.99, 3, '2023-03-11', 'in-stock'),
(6040, 'Joses Vanilla Nut Whole Bean Coffee 3 lb, 2-pack', 'Coffee', 44.99, 33, '2023-09-02', 'in-stock'),
(6041, 'The Original Donut Shop Coffee K-Cup Pod, 100-count', 'Coffee', 48.99, 35, '2023-06-14', 'in-stock'),
(6042, 'Cometeer Dark Roast Coffee, 56 Frozen Capsules', 'Coffee', 99.99, 61, '2023-03-01', 'in-stock'),
(6043, 'Dunkin Donuts, Original Blend, Medium Roast, K-Cup Pods, 72ct', 'Coffee', 41.99, 2, '2023-03-14', 'in-stock'),
(6044, 'Newmans Own Organics Coffee Special Blend K-Cup Pod, 100-count', 'Coffee', 48.99, 54, '2024-01-05', 'in-stock'),
(6045, 'Nestle Coffee-Mate Liquid Creamer, French Vanilla, 180-count', 'Coffee', 14.99, 87, '2023-04-18', 'in-stock'),
(6046, 'Kirkland Signature 100% Colombian Coffee, Dark Roast, 1.75 oz, 42-count', 'Coffee', 28.99, 86, '2023-08-06', 'in-stock'),
(6047, 'Caribou Coffee Caribou Blend K-Cup Pod, 100-count', 'Coffee', 48.99, 8, '2023-10-06', 'in-stock'),
(6048, 'Ruta Maya Organic Medium Roast Whole Bean Coffee 5 lb', 'Coffee', 44.99, 100, '2023-12-09', 'in-stock'),
(6049, 'San Francisco Bay Organic Rainforest Blend Whole Bean Coffee 3 lbs, 2-pack', 'Coffee', 56.99, 3, '2023-10-18', 'in-stock'),
(6050, 'Joses 100% Colombia Supremo Whole Bean Coffee, Medium, 3lbs, 2-pack', 'Coffee', 44.99, 1, '2023-07-25', 'in-stock'),
(6051, 'Starbucks Espresso, Espresso & Cream, 6.5 fl oz, 12-count', 'Coffee', 22.99, 26, '2023-08-04', 'in-stock'),
(6052, 'Joses 100% Organic Mayan Whole Bean Coffee 2.5 lb, 2-pack', 'Coffee', 44.99, 6, '2023-05-26', 'in-stock'),
(6053, 'San Francisco French Roast Whole Bean Coffee 3 lb, 2-pack', 'Coffee', 34.99, 54, '2023-10-28', 'in-stock'),
(6054, 'Copper Moon Costa Rica Blend, Medium Roast Whole Bean Coffee, 2 lb Bags, 2-Pack', 'Coffee', 34.99, 14, '2023-03-06', 'in-stock'),
(6055, 'Starbucks VIA Instant Colombia Coffee, Medium Roast, 26-count', 'Coffee', 19.99, 94, '2023-12-30', 'in-stock'),
(6056, 'Mayorga Cafe Cubano Roast, USDA Organic, Dark Roast, Whole Bean Coffee, 2lb, 2-pack', 'Coffee', 39.99, 97, '2023-07-25', 'in-stock'),
(6057, 'Mayorga Decaf Cafe Cubano Roast, USDA Organic, Dark Roast, Whole Bean Coffee, 2lb, 2-pack', 'Coffee', 39.99, 9, '2023-12-10', 'in-stock'),
(6058, 'Nestle Coffee-mate Liquid Creamer, Original, 180-count', 'Coffee', 12.99, 72, '2023-03-01', 'in-stock'),
(6059, 'San Francisco Bay Coffee Light Roast Cold Brew Coarse Ground Coffee, 28 oz, 2-pack', 'Coffee', 39.99, 39, '2023-11-20', 'in-stock'),
(6060, 'Parisi Artisan Coffee Bolivian Organic Blend Whole Bean 2 lb, 2-pack', 'Coffee', 36.99, 43, '2023-11-08', 'in-stock'),
(6061, 'Tullys Coffee French Roast K-Cups Pods, 100-count', 'Coffee', 48.99, 22, '2023-03-04', 'in-stock'),
(6062, 'Folgers Instant Coffee Classic Roast Coffee, 16 oz', 'Coffee', 11.99, 81, '2023-04-09', 'in-stock'),
(6063, 'VitaCup Slim Instant Coffee Packets, Boost Diet & Metabolism, 30-count', 'Coffee', 29.99, 16, '2023-05-13', 'in-stock'),
(6064, 'Tullys Coffee Hawaiian Blend K-Cups Packs, 100-count', 'Coffee', 48.99, 57, '2023-08-17', 'in-stock'),
(6065, 'Nestle Coffee-mate Coffee Creamer, Hazelnut, Pump Bottle, 50.7 fl oz', 'Coffee', 16.99, 37, '2023-11-03', 'in-stock'),
(6066, 'Caffe Vita Coffee Caffe Del Sol Blend Whole Bean, Medium Roast, 2 lb. bags, 2-pack', 'Coffee', 59.99, 85, '2023-09-09', 'in-stock'),
(6067, 'San Francisco Bay Decaf French Roast Whole Bean Coffee 2 lb, 2-pack', 'Coffee', 34.99, 83, '2023-06-14', 'in-stock'),
(6068, 'Caffe Vita Coffee Theo Blend Whole Bean, Medium-Dark Roast, 2 lb. bags, 2-pack', 'Coffee', 59.99, 2, '2023-12-05', 'in-stock'),
(6069, 'Caffe Vita Caffe Luna French Roast Whole Bean, Dark Roast, 2 lb. bags, 2-pack', 'Coffee', 59.99, 26, '2023-05-20', 'in-stock'),
(6070, 'Nestle Coffee-mate Powdered Creamer, Original, 56 oz', 'Coffee', 10.99, 94, '2023-11-11', 'in-stock');

INSERT INTO products (id, name, category, price, stock, expiry, status) VALUES
(7000, 'Tsar Nicoulai Baerii Caviar 2 oz. Gift Set', 'Deli', 99.99, 22, '2023-10-31', 'in-stock'),
(7001, 'Tsar Nicoulai Classic White Sturgeon Caviar 2 oz Gift Set', 'Deli', 119.99, 39, '2023-08-07', 'in-stock'),
(7002, 'Plaza Osetra Farmed Bulgarian Sturgeon Caviar 2 oz, 3-pack', 'Deli', 199.99, 12, '2023-07-07', 'in-stock'),
(7003, 'Giordanos Chicago Frozen 10 Deep Dish Stuffed Pizza, 3-pack', 'Deli', 89.99, 16, '2023-09-19', 'in-stock'),
(7004, 'Tsar Nicoulai Estate White Sturgeon Caviar 4.4 oz', 'Deli', 149.99, 21, '2023-01-17', 'in-stock'),
(7005, 'DArtagnan 13-piece Gourmet Roasting Ham & Luxury Charcuterie Gift Box, 12.5 lbs', 'Deli', 199.99, 72, '2023-05-24', 'in-stock'),
(7006, 'Covap Jamon Iberico Bellota Ham Leg with Stand and Knife, 15.4 lbs.', 'Deli', 649.99, 2, '2023-12-23', 'in-stock'),
(7007, 'Plaza Golden Osetra Caviar Kilo Pack, 35.2 oz', 'Deli', 1999.99, 52, '2023-02-21', 'in-stock'),
(7008, 'Noel Consorcio Serrano Ham Reserva Leg, 14 lbs', 'Deli', 109.99, 91, '2023-11-01', 'in-stock'),
(7009, 'Plaza Osetra Farmed Bulgarian Sturgeon Caviar, 2 oz Gift Set', 'Deli', 124.99, 65, '2023-01-31', 'in-stock'),
(7010, 'DArtagnan 18-month Aged Boneless Spanish Serrano Ham, 9.5 lbs', 'Deli', 249.99, 78, '2023-05-19', 'in-stock'),
(7011, 'Tsar Nicoulai Baerii Caviar 2 oz, 3-pack', 'Deli', 249.99, 87, '2023-08-03', 'in-stock'),
(7012, 'Pacific Plaza Golden Osetra Caviar 2 oz, 2-pack', 'Deli', 279.99, 86, '2023-07-09', 'in-stock'),
(7013, 'Tsar Nicoulai Caviar Tasting Flight Gift Set', 'Deli', 249.99, 19, '2023-07-09', 'in-stock'),
(7014, 'Tsar Nicoulai Estate Classic White Sturgeon Caviar 2 oz, 3-pack', 'Deli', 199.99, 46, '2023-03-18', 'in-stock'),
(7015, 'Plaza Golden Osetra 2 oz Caviar Gift Set', 'Deli', 169.99, 84, '2023-05-14', 'in-stock'),
(7016, 'Plaza Golden Osetra Caviar, 8.8 oz', 'Deli', 549.99, 20, '2023-04-25', 'in-stock'),
(7017, 'Plaza Osetra Kilo Caviar Pack', 'Deli', 1399.99, 100, '2023-02-16', 'in-stock'),
(7018, 'Plaza Osetra Farmed Bulgarian Sturgeon Caviar, 8.8 oz', 'Deli', 379.99, 79, '2023-08-16', 'in-stock'),
(7019, 'Fratelli Beretta Snack Pack, 2.5 oz, 10-pack', 'Deli', 59.99, 80, '2023-01-25', 'in-stock'),
(7020, 'Fratelli Beretta Prosciutto di Parma Boneless, DOP, minimum 14.7 lbs', 'Deli', 249.99, 40, '2023-10-18', 'in-stock');

INSERT INTO products (id, name, category, price, stock, expiry, status) VALUES
(8000, 'Cambro CamSquare 2 Quart Food Storage Container with Lid, 3-count', 'Household', 18.99, 32, '2023-09-11', 'in-stock'),
(8001, 'Cambro Square 4-Quart Food Storage Container with Lid, 3-count', 'Household', 25.99, 89, '2023-05-28', 'in-stock'),
(8002, 'Cambro Round 2-Quart Food Storage Container with Lid, 3-count', 'Household', 11.99, 97, '2023-07-07', 'in-stock'),
(8003, 'Cambro Round 4 Quart Food Storage Container with Lid, 3-count', 'Household', 12.99, 20, '2023-08-13', 'in-stock'),
(8004, 'Kirkland Signature Alkaline AA Batteries, 48-count', 'Household', 17.99, 77, '2023-04-26', 'in-stock'),
(8005, 'Duracell Coppertop Alkaline AA Batteries, 40-count', 'Household', 20.99, 19, '2023-01-25', 'in-stock'),
(8006, 'Kirkland Signature Alkaline AAA Batteries, 48-count', 'Household', 17.99, 40, '2023-04-04', 'in-stock'),
(8007, 'Duracell Coppertop Alkaline AAA Batteries, 40-count', 'Household', 20.99, 100, '2023-02-08', 'in-stock'),
(8008, 'Duracell 9V Alkaline Batteries, 8-count', 'Household', 20.99, 71, '2023-09-02', 'in-stock'),
(8009, 'Duracell D Alkaline Batteries, 14-count', 'Household', 18.99, 69, '2023-07-31', 'in-stock'),
(8010, 'Duracell C Alkaline Batteries, 14-count', 'Household', 18.99, 98, '2023-11-23', 'in-stock'),
(8011, 'Cambro CamSquare 8 Quart Food Container with Lid, 2-count', 'Household', 24.99, 26, '2023-06-11', 'in-stock'),
(8012, 'Russell 10 Cooks Knife, 2-count', 'Household', 17.99, 25, '2023-12-02', 'in-stock'),
(8013, 'Tramontina Professional 8 Restaurant Fry Pan, Nonstick Aluminum, 2 pk', 'Household', 26.99, 65, '2023-03-18', 'in-stock'),
(8014, 'Tramontina Aluminum Baking Sheet Pan, Quarter Size, 9.5L x 13W, 3 ct', 'Household', 14.99, 40, '2023-06-09', 'in-stock'),
(8015, 'Tramontina Professional 12 Restaurant Fry Pan, Nonstick Aluminum', 'Household', 27.99, 72, '2023-04-27', 'in-stock'),
(8016, 'Tramontina Professional 10 Restaurant Fry Pan, Nonstick Aluminum, 2 pk', 'Household', 36.99, 78, '2023-07-25', 'in-stock'),
(8017, 'Tramontina ProLine Windsor Oval Soup Spoon, Stainless Steel, 36-count', 'Household', 9.99, 44, '2023-07-17', 'in-stock'),
(8018, 'Tramontina ProLine Windsor Dinner Knife, Stainless Steel, 36-count', 'Household', 19.99, 28, '2023-12-01', 'in-stock'),
(8019, 'Tramontina ProLine Windsor Dinner Fork, Stainless Steel, 36-count', 'Household', 9.99, 13, '2023-03-14', 'in-stock'),
(8020, 'Taylor Waterproof Instant Read Food Thermometer, Red', 'Household', 12.99, 40, '2023-08-07', 'in-stock'),
(8021, 'Tramontina ProLine Windsor Teaspoon, Stainless Steel, 36-count', 'Household', 8.49, 83, '2023-08-02', 'in-stock'),
(8022, 'Winco Cutting Board, 12 x 18 x 1/2 - White', 'Household', 7.49, 37, '2023-09-15', 'in-stock'),
(8023, 'BIC Grip 4 Color Ball Pens with 3 Color + Pencil Set, 10-count', 'Household', 12.99, 62, '2023-03-28', 'in-stock'),
(8024, 'Nouvelle Legende Ribbed Microfiber Bar Towel, White with Green Stripe, 14 in x 18 in, 12-count', 'Household', 8.99, 41, '2023-04-26', 'in-stock'),
(8025, '3M Scotch Precision Ultra Edge 8 Scissor, 3-count', 'Household', 11.39, 42, '2023-03-26', 'in-stock'),
(8026, 'Tramontina ProLine 6 in Chefs Cleaver', 'Household', 22.99, 34, '2023-01-05', 'in-stock'),
(8027, '3M Scotch Magic Tape, 12-count', 'Household', 22.99, 73, '2023-03-01', 'in-stock'),
(8028, 'Scotch Shipping Packaging Tape with Dispenser, Heavy Duty, 1.88 x 19.4 yds, 6-count', 'Household', 12.99, 73, '2023-07-24', 'in-stock'),
(8029, 'Winco 8-3/4 Portable Can Opener with Crank Handle, Chrome Plated', 'Household', 12.99, 76, '2023-04-27', 'in-stock'),
(8030, 'Epson T502 EcoTank Ink Bottles BK/C/Y/M, Club Pack', 'Household', 49.99, 18, '2023-10-28', 'in-stock'),
(8031, 'Takeya 2-quart Beverage Pitcher 2-pack', 'Household', 26.99, 62, '2023-06-05', 'in-stock'),
(8032, 'HP 63XL High Yield Ink Cartridge, Black & Tri-Color, Combo Pack', 'Household', 93.79, 4, '2023-10-02', 'in-stock'),
(8033, 'HP 962XL High Yield Ink Cartridge, Tri-Color Pack', 'Household', 109.99, 82, '2023-03-25', 'in-stock'),
(8034, 'TOPS Perforated Legal Ruled Letter Pad, 9-count', 'Household', 17.99, 80, '2023-12-01', 'in-stock'),
(8035, 'HP 902XL High Yield Ink Cartridge, Black, 2-Count', 'Household', 91.79, 9, '2023-12-28', 'in-stock'),
(8036, 'Post-it Ruled Notes, Assorted Pastel Colors, 4 x 6 - 100 Sheets, 5 Pads', 'Household', 11.39, 84, '2023-08-31', 'in-stock'),
(8037, 'Post-it Notes, Assorted Bright Colors, 1-1/2 x 2 100 Sheets, 24 Pads', 'Household', 11.29, 34, '2023-06-07', 'in-stock'),
(8038, 'HP 62XL High Yield Ink Cartridge, Black & Tri-Color', 'Household', 93.79, 8, '2023-05-05', 'in-stock'),
(8039, 'uni-ball 207 Retractable Gel Pen, Medium Point 0.7mm, Assorted Ink Colors, 12-count', 'Household', 12.39, 81, '2023-05-16', 'in-stock'),
(8040, 'HP 64XL High Yield Ink Cartridge, Black & Tri-Color, 2-Count', 'Household', 95.79, 1, '2023-05-13', 'in-stock'),
(8041, 'Nouvelle Legende Ribbed 100% Cotton Bar Towel, White, 16 in x 19 in, 25-count', 'Household', 22.99, 86, '2023-11-07', 'in-stock'),
(8042, 'Tramontina Serving Spoons, Assorted Styles, Stainless Steel, 6-count', 'Household', 10.49, 17, '2023-07-06', 'in-stock'),
(8043, 'HP 952XL High Yield Ink Cartridge, Tri-Color Pack', 'Household', 117.79, 100, '2023-06-14', 'in-stock'),
(8044, 'Scotch Packaging Tape, General Purpose, 1.88W x 54.6 yds, 8-count', 'Household', 15.99, 91, '2023-05-26', 'in-stock'),
(8045, 'Bostitch Premium Desktop Stapler Value Pack', 'Household', 14.99, 68, '2023-10-04', 'in-stock'),
(8046, 'Scotch Heavy Duty Shipping Tape 8-pack', 'Household', 26.99, 23, '2023-05-02', 'in-stock'),
(8047, 'HP 910XL High Yield Ink Cartridge, Tri-Color Pack', 'Household', 69.79, 8, '2023-05-31', 'in-stock'),
(8048, 'Bostitch 1/4 Premium Staples, Standard Chisel Point, 5,000 Staples, 5-count', 'Household', 4.49, 8, '2023-09-18', 'in-stock'),
(8049, 'HP 67XL High Yield Ink Cartridge, Black & Tri-Color', 'Household', 52.79, 78, '2023-12-31', 'in-stock'),
(8050, 'HP 962XL High Yield Ink Cartridge, Black, 2-count', 'Household', 93.79, 92, '2023-04-29', 'in-stock'),
(8051, 'HP 952XL High Yield Ink Cartridge, Black, 2-count', 'Household', 102.79, 9, '2023-12-23', 'in-stock'),
(8052, 'HP 910XL High Yield Ink Cartridge, Black, 2-count', 'Household', 84.79, 3, '2023-06-30', 'in-stock'),
(8053, 'Pentel Twist-Erase Click Mechanical Pencil, 15-count', 'Household', 10.19, 84, '2023-12-23', 'in-stock'),
(8054, 'Scotch Heavy Duty Shipping Packaging Tape with Tape Gun Dispenser, 2 Rolls of Tape Included', 'Household', 16.49, 97, '2023-12-08', 'in-stock'),
(8055, 'Nouvelle Legende Flame Retardant Oven Mitt, Black, 2-count', 'Household', 5.49, 27, '2023-10-28', 'in-stock'),
(8056, 'Pilot G2 Gel Pen, Black, 20-pack', 'Household', 19.99, 11, '2023-10-19', 'in-stock'),
(8057, 'Pendaflex 1/3 Cut File Folder Letter Size, 150-count', 'Household', 12.99, 36, '2023-07-18', 'in-stock'),
(8058, 'TOPS 1 R-Ring View Binder 6-count', 'Household', 12.79, 15, '2023-01-12', 'in-stock'),
(8059, 'Nouvelle Legende Commercial Grade Apron, Black, 29 in x 32 in, 2-count', 'Household', 9.49, 14, '2023-06-21', 'in-stock'),
(8060, 'TOPS Non-stick 1/2 View Binder, 6-count', 'Household', 11.99, 85, '2023-02-27', 'in-stock'),
(8061, 'Pilot G2 Gel Pens Assorted Colors, 20-pack', 'Household', 19.99, 17, '2023-01-21', 'in-stock'),
(8062, 'Scotch Permanent Glue Stick, 0.28 oz, 24-count', 'Household', 8.99, 89, '2023-05-11', 'in-stock'),
(8063, 'Advantage Premium Bright Ink Jet and Laser Paper, 8.5x11 Letter, White, 24lb, 97 Bright, 1 Ream of 800 Sheets', 'Household', 10.99, 13, '2023-12-15', 'in-stock'),
(8064, 'BIC Mechanical Pencil Kit, 24 Velocity + 1 Break Resistant, 0.7mm Lead, 25-count', 'Household', 14.99, 55, '2023-02-27', 'in-stock'),
(8065, 'Post-it Notes, Canary Yellow, 3 x 3 100 Sheets, 24 Pads', 'Household', 17.99, 88, '2023-04-09', 'in-stock'),
(8066, 'Winco 9-Inch Non-Slip Locking Tongs, Stainless Steel, 4-count', 'Household', 11.99, 56, '2023-08-05', 'in-stock'),
(8067, 'BIC Ecolutions Ocean-Bound Retractable Gel Pens, Medium Point 1.0mm, Assorted Ink, 15-count', 'Household', 15.99, 8, '2023-07-24', 'in-stock'),
(8068, 'Sharpie Fine Point Permanent Marker, 25-count', 'Household', 16.99, 94, '2023-06-03', 'in-stock'),
(8069, 'Eurow Nouvelle Legende Placemats, 12-count', 'Household', 13.99, 31, '2023-11-26', 'in-stock');

INSERT INTO products (id, name, category, price, stock, expiry, status) VALUES
(9000, 'Ahi Tuna Individual Vacuum Packed Portion (26-27/6 Oz. Per Portion), 26-27 Total Packs, 10 Lbs. Total Case', 'Meat & Seafood', 149.99, 45, '2023-08-15', 'in-stock'),
(9001, 'Chicago Steak USDA Prime Beef Wet Aged Boneless Strips & Gourmet Burgers, 16 Total Count, 10 Lbs. Total', 'Meat & Seafood', 229.99, 83, '2023-12-15', 'in-stock'),
(9002, 'Alaska Home Pack Frozen Sea Cucumber - 3 Packs, 7 Lbs. Total', 'Meat & Seafood', 239.99, 56, '2023-02-06', 'in-stock'),
(9003, 'Crown Prince Smoked Oysters in Olive Oil, Fancy Whole, 3.75 oz, 6-count', 'Meat & Seafood', 14.99, 34, '2023-07-16', 'in-stock'),
(9004, 'Kansas City Steak Company USDA Choice Ribeye Steaks 18 Oz. Each (Available in 4, 8, or 12 Packs)', 'Meat & Seafood', 129.99, 78, '2023-07-21', 'in-stock'),
(9005, 'Kansas City Steak Company USDA Choice NY Strip Steaks 16 Oz. Each (Available in 4, 8, or 12 Packs)', 'Meat & Seafood', 109.99, 65, '2023-03-20', 'in-stock'),
(9006, 'Northfork Ground Bison - (10/1 Lb. Per Pack), 10 Total Packs, 10 Lbs. Total', 'Meat & Seafood', 109.99, 28, '2023-06-28', 'in-stock'),
(9007, 'Lobster With Shell Removed, (9 Oz. Per Pack), 6 Total Packs, 3.44 Lbs. Total', 'Meat & Seafood', 259.99, 31, '2023-12-04', 'in-stock'),
(9008, 'Crescent Foods Halal Hand-Cut Beef, Chicken Combo Pack - 14 Total Packs, 13.5 Lbs. Total', 'Meat & Seafood', 159.99, 29, '2023-04-06', 'in-stock'),
(9009, 'Farmer Focus Organic Boneless/Skinless Chicken Breasts, (20/8 Oz. Per Breast), 20 Total Count, 10 Lbs. Total', 'Meat & Seafood', 149.99, 68, '2023-11-26', 'in-stock'),
(9010, 'DArtagnan Green Circle Chicken - Boneless & Skinless Breasts, 12 Total Packs, 11 Lbs. Total', 'Meat & Seafood', 139.99, 59, '2023-08-02', 'in-stock'),
(9011, 'Northwest Fish 4-6 Whole Dungeness Crab, 10 lbs', 'Meat & Seafood', 209.99, 77, '2023-02-03', 'in-stock'),
(9012, 'Quality Ethnic Foods Halal Chicken Variety Pack (Drumsticks, Tenders, Boneless Breast), 12 Total Packs, 12 Lbs. Total', 'Meat & Seafood', 99.99, 24, '2023-08-30', 'in-stock'),
(9013, 'Premium Seafood Variety Pack - 20 Total Packs, Total 12.5 Lbs.', 'Meat & Seafood', 349.99, 99, '2023-09-12', 'in-stock'),
(9014, 'Northfork Elk Burger (30/5.33 Oz Per Burger), 10 Total Packs, 30-Count', 'Meat & Seafood', 109.99, 63, '2023-07-01', 'in-stock'),
(9015, 'DArtagnan Heritage Breed (6/3.25 Lbs. Per Whole Chicken), Total 6 Packs, 19.5 Lbs. Total', 'Meat & Seafood', 169.99, 60, '2023-03-11', 'in-stock'),
(9016, 'Chicago Steak - Steak & Cake - Filet Mignon, Crab Cakes, and Steak Burgers, Total 13 Packs, 6.5 Lbs. Total', 'Meat & Seafood', 199.99, 100, '2023-11-12', 'in-stock'),
(9017, 'Northwest Fish Colossal Alaskan Wild Dungeness Crab Sections, 10lbs', 'Meat & Seafood', 219.99, 24, '2023-09-01', 'in-stock'),
(9018, 'Mila Chicken Xiao Long Bao Soup Dumplings - 50 Dumplings Per Bag, 3 Bags Total', 'Meat & Seafood', 99.99, 9, '2023-03-10', 'in-stock'),
(9019, 'Kansas City Steak Company USDA Choice Combo Pack (4 Strips, 4 Filet Mignon, 4 Ribeyes), 12 Total Packs, 11.5 Lbs. Total', 'Meat & Seafood', 279.99, 41, '2023-04-04', 'in-stock'),
(9020, 'DArtagnan Extreme American Wagyu Burger Lovers Bundle 12 Total Packs, 6 Lbs. Total', 'Meat & Seafood', 159.99, 81, '2023-04-17', 'in-stock'),
(9021, 'Texas Tamale Co. Chicken Tamales 6-pack of 12 each, 72-count', 'Meat & Seafood', 89.99, 63, '2023-10-22', 'in-stock'),
(9022, 'Northwest Fish Wild Alaskan Sockeye Salmon Cheddar Bacon Burger Patties, 24-count, 9 lbs', 'Meat & Seafood', 119.99, 16, '2023-07-02', 'in-stock'),
(9023, 'Northfork Bison Burger (30/5.33 Oz Per Burger), 10 Total Packs, 30-Count', 'Meat & Seafood', 109.99, 24, '2023-01-04', 'in-stock'),
(9024, 'Coastal Seafood Frozen Lobster Tails 12 Count (6 - 8  oz.)', 'Meat & Seafood', 229.99, 31, '2023-11-28', 'in-stock'),
(9025, 'DArtagnan 13-piece Gourmet Roasting Ham & Luxury Charcuterie Gift Box, 12.5 lbs', 'Meat & Seafood', 199.99, 5, '2023-07-02', 'in-stock'),
(9026, 'Northwest Fish Alaskan Bairdi Snow Crab Sections, (10-14 / 13 Oz. Per Pack), Total 10 Lbs.', 'Meat & Seafood', 299.99, 19, '2023-11-28', 'in-stock'),
(9027, 'Authentic Wagyu Surf & Turf Pack, (2/17-20 Oz./Each Tail) Cold Water Lobster Tails with (2/13 Oz. Per Steak) Japanese A5 Wagyu Petite Striploin Steaks', 'Meat & Seafood', 279.99, 70, '2023-05-08', 'in-stock'),
(9028, 'Rastelli Bone-In Premium Pork Rib Steak, (16/8 Oz. Per Steak), 16 Total Count, 8 Lbs. Total ', 'Meat & Seafood', 199.99, 13, '2023-03-03', 'in-stock'),
(9029, 'Mila Pork Xiao Long Bao Soup Dumplings - 50 Dumplings Per Bag, 3 Bags Total', 'Meat & Seafood', 99.99, 55, '2023-08-25', 'in-stock'),
(9030, 'Rastelli USDA Choice Boneless Black Angus Prime Rib Roast, 1 Total Pack, 7 Lbs. Total', 'Meat & Seafood', 199.99, 77, '2023-09-01', 'in-stock'),
(9031, 'Silver Fern Farms 100% New Zealand Grass-Fed, Net Carbon Zero Steak Box - 10 Total Packs, 6.25 Lbs. Total', 'Meat & Seafood', 129.99, 82, '2023-03-09', 'in-stock'),
(9032, 'Authentic Wagyu Surf & Turf Pack, (2/17-20 Oz. Cold Water Lobster Tails with  (2/14 Oz.Per Steak) Japanese A5 Wagyu Ribeye Steaks', 'Meat & Seafood', 339.99, 25, '2023-11-22', 'in-stock'),
(9033, 'DArtagnan Gourmet Steak & Burger Grill Pack, 20 Total Packs, 16 Lbs. Total', 'Meat & Seafood', 399.99, 67, '2023-07-15', 'in-stock'),
(9034, 'Rastelli Market Fresh Jumbo Lump Crab Cakes (20/4 Oz. Per Crab Cake), 20 Total Count, 5 Lbs. Total', 'Meat & Seafood', 199.99, 29, '2023-12-18', 'in-stock'),
(9035, 'Rastelli Petite Filet Mignon & Jumbo Lump Crab Cake Surf & Turf, 24 Total Packs, 6.75 Total Lbs.', 'Meat & Seafood', 349.99, 100, '2023-10-26', 'in-stock'),
(9036, 'Chicago Steak Premium Angus Beef Surf & Turf, 15 Total Packs, 7 Lbs. Total', 'Meat & Seafood', 239.99, 87, '2023-02-23', 'in-stock'),
(9037, 'Chicago Steak Premium Angus Beef Burger Flight, Total 29 Packs, 14 Lbs. Total', 'Meat & Seafood', 219.99, 3, '2023-07-19', 'in-stock'),
(9038, 'Wild Alaska Snow Crab Meat (Bairdi Crab 8 oz. Pack) 12 Total Packs, 6 Lbs. Total ', 'Meat & Seafood', 279.99, 85, '2023-02-07', 'in-stock'),
(9039, 'Authentic Wagyu Kurobuta Applewood Smoked Thick Cut Bacon, 1 Pack, 3 Lbs. Total', 'Meat & Seafood', 89.99, 26, '2023-09-19', 'in-stock'),
(9040, 'Northwest Red King Salmon Portions, 12 Total Count, 1 Case Totaling 6 Lbs.', 'Meat & Seafood', 179.99, 82, '2023-05-16', 'in-stock'),
(9041, 'DArtagnan Antibiotic Free Bone-in Beef Ribeye Roast, 1 Total Pack, 19 Lbs. Total', 'Meat & Seafood', 429.99, 13, '2023-08-21', 'in-stock'),
(9042, 'Rastellis Pork Ribeye Steaks - (20/6 Oz Per Portion), 20 Total Packs, 7.5 Lbs. Total', 'Meat & Seafood', 114.99, 65, '2023-09-14', 'in-stock'),
(9043, 'Chicago Steak USDA Prime Surf & Turf, Total 14 Packs, 7 Lbs. Total', 'Meat & Seafood', 299.99, 87, '2023-02-05', 'in-stock'),
(9044, 'Ahi Tuna Mixed Pack, (12 x 6 oz. Steaks, 9 x 5.3 oz. Saku Slice Packs, 4 x 10.7 oz. Sesame Crusted Steak Packs), 25 Total Packs, 10.15 Lbs. Total', 'Meat & Seafood', 239.99, 19, '2023-01-06', 'in-stock'),
(9045, 'Mila Starter Pack Xiao Long Bao Soup Dumplings - 3 Bags, 1 Bamboo Steamer, 4 Dipping Bowls', 'Meat & Seafood', 129.99, 15, '2023-01-14', 'in-stock'),
(9046, 'Northwest Fish Wild Alaskan Sockeye Salmon Fillets, 10 lbs', 'Meat & Seafood', 219.99, 99, '2023-05-29', 'in-stock'),
(9047, 'Smoked New Zealand King Salmon, 1.1lb fillets, 2-count, 2.2 lbs total', 'Meat & Seafood', 109.99, 24, '2023-07-02', 'in-stock'),
(9048, 'Crescent Foods Halal Hand Cut Steak Locker, 16 Total Packs, 9 Lbs. Total', 'Meat & Seafood', 199.99, 78, '2023-07-11', 'in-stock'),
(9049, 'Rastelli VBites Plant-Based Vegan Meat Substitute Mega Burger 6 oz each, 24-pack, 9 lbs', 'Meat & Seafood', 99.99, 98, '2023-12-28', 'in-stock'),
(9050, 'Chicago Steak Filet Mignon & Scallop Combo, 14 Total Packs, 7 Lbs. Total', 'Meat & Seafood', 249.99, 13, '2023-10-25', 'in-stock'),
(9051, ' Northwest Fish Wild Alaskan Sockeye Salmon Fillets Total 25 Count, 1 Case Totaling 10 Lbs.', 'Meat & Seafood', 229.99, 95, '2023-01-02', 'in-stock');

INSERT INTO products (id, name, category, price, stock, expiry, status) VALUES
(10000, 'Kirkland Signature, Organic Chicken Stock, 32 fl oz, 6-Count', 'Organic', 11.99, 37, '2023-01-29', 'in-stock'),
(10001, 'Kirkland Signature, Organic Almond Beverage, Vanilla, 32 fl oz, 6-Count', 'Organic', 9.99, 54, '2023-02-07', 'in-stock'),
(10002, 'Kirkland Signature, Organic Extra Virgin Olive Oil, 2 L', 'Organic', 18.99, 55, '2023-09-08', 'in-stock'),
(10003, 'Kirkland Signature Organic No-Salt Seasoning, 14.5 oz', 'Organic', 9.99, 72, '2023-11-03', 'in-stock'),
(10004, 'Kirkland Signature, Organic Fruit and Vegetable Pouches, Variety Pack, 3.17 oz, 24-count', 'Organic', 14.99, 80, '2023-11-23', 'in-stock'),
(10005, 'Seeds of Change, Organic Quinoa and Brown Rice, 8.5 oz, 6-Count', 'Organic', 14.99, 55, '2023-09-27', 'in-stock'),
(10006, 'Ruta Maya Organic Jiguaní Whole Bean Coffee 5 lb', 'Organic', 47.99, 72, '2023-03-29', 'in-stock'),
(10007, 'Kirkland Signature Organic Raw Honey, 24 oz, 3-count', 'Organic', 17.99, 36, '2023-04-14', 'in-stock'),
(10008, 'Kirkland Signature Organic Pine Nuts, 1.5 lbs', 'Organic', 33.99, 56, '2023-03-21', 'in-stock'),
(10009, 'Kirkland Signature Organic Pure Maple Syrup, 33.8 oz', 'Organic', 14.99, 9, '2023-09-16', 'in-stock'),
(10010, 'Kirkland Signature, Organic Sugar, 10 lbs', 'Organic', 10.99, 9, '2023-10-03', 'in-stock'),
(10011, 'Newmans Own Organics Coffee Special Blend K-Cup Pod, 100-count', 'Organic', 48.99, 10, '2023-02-14', 'in-stock'),
(10012, 'Thai Kitchen Organic Coconut Milk, Unsweetened, 13.66 fl oz, 6-count', 'Organic', 14.99, 67, '2023-04-16', 'in-stock'),
(10013, 'Ruta Maya Organic Medium Roast Whole Bean Coffee 5 lb', 'Organic', 44.99, 74, '2023-08-22', 'in-stock'),
(10014, 'Joses 100% Organic Mayan Whole Bean Coffee 2.5 lb, 2-pack', 'Organic', 44.99, 58, '2023-09-12', 'in-stock'),
(10015, 'Kirkland Signature Organic Blue Agave, 36 oz, 2-count', 'Organic', 10.99, 72, '2023-07-07', 'in-stock'),
(10016, 'Kirkland Signature, Organic Applesauce, 3.17 oz, 24-Count', 'Organic', 12.99, 15, '2023-07-08', 'in-stock'),
(10017, 'Oregon Chai, Original Organic Chai Tea Latte Concentrate, 32 fl. oz., 3-Count', 'Organic', 11.69, 52, '2023-02-06', 'in-stock'),
(10018, 'Made in Nature Organic Berry Fusion 24 oz, 2-pack', 'Organic', 39.99, 8, '2023-07-15', 'in-stock'),
(10019, 'Kirkland Signature, Organic Soy Beverage, Vanilla, 32 fl oz, 12-Count', 'Organic', 17.99, 85, '2023-03-14', 'in-stock'),
(10020, 'Kirkland Signature, Organic Soy Beverage, Plain, 32 fl oz, 12-Count', 'Organic', 17.99, 42, '2023-09-17', 'in-stock'),
(10021, 'Kirkland Signature Organic Roasted Seaweed, 0.6 oz, 10-count', 'Organic', 11.99, 64, '2023-05-07', 'in-stock'),
(10022, 'Made In Nature Organic Calimyrna Figs 40 oz, 3-pack', 'Organic', 49.99, 69, '2023-07-13', 'in-stock'),
(10023, 'GoGo SqueeZ, Organic Applesauce, Variety Pack, 3.2 oz, 28-Count', 'Organic', 19.99, 85, '2023-09-19', 'in-stock'),
(10024, 'Garofalo, Organic Pasta, Variety Pack, 17.6 oz, 6-Count', 'Organic', 12.99, 36, '2023-08-28', 'in-stock'),
(10025, 'S&W, Organic Black Beans, 15 oz, 8-Count', 'Organic', 9.99, 75, '2023-10-21', 'in-stock'),
(10026, 'Kirkland Signature, Organic Tomato Sauce, 15 oz, 12-Count', 'Organic', 9.49, 34, '2023-08-02', 'in-stock'),
(10027, 'Ruta Maya Organic Dark Roast Coffee, 5 lbs', 'Organic', 44.99, 13, '2023-11-17', 'in-stock'),
(10028, 'S&W, Organic Garbanzo Beans, 15.5 oz, 8-Count', 'Organic', 10.99, 36, '2023-12-21', 'in-stock'),
(10029, 'Kirkland Signature, Organic 100% Juice, Variety Pack, 6.75 fl oz, 40-Count', 'Organic', 17.99, 79, '2023-02-13', 'in-stock'),
(10030, 'Mother Earth Organic Medium Roast Coffee 2 lb, 2-pack', 'Organic', 39.99, 37, '2023-05-06', 'in-stock'),
(10031, 'Kirkland Signature, Organic Tomato Paste, 6 oz, 12-Count', 'Organic', 10.99, 63, '2023-05-21', 'in-stock'),
(10032, 'Acetum Organic Apple Cider Vinegar with the Mother, 128 fl. oz.', 'Organic', 27.99, 64, '2023-02-24', 'in-stock');

INSERT INTO products (id, name, category, price, stock, expiry, status) VALUES
(11000, 'European Black Winter Fresh Truffles 3 oz.', 'Pantry & Dry Goods', 189.99, 95, '2023-04-30', 'in-stock'),
(11001, 'Manuka Health UMF 20+ (MGO 850+) Raw Manuka Honey 8.8 oz', 'Pantry & Dry Goods', 59.99, 33, '2023-11-27', 'in-stock'),
(11002, 'Kirkland Signature, Chicken Breast, 12.5 oz, 6-Count', 'Pantry & Dry Goods', 14.99, 16, '2023-05-03', 'in-stock'),
(11003, 'Skippy Peanut Butter, Creamy, 48 oz, 2-count', 'Pantry & Dry Goods', 9.69, 27, '2023-10-27', 'in-stock'),
(11004, 'Indomie Mi Goreng Instant Fried Noodles, 3 oz, 40-count', 'Pantry & Dry Goods', 23.99, 99, '2023-06-06', 'in-stock'),
(11005, 'Skippy Peanut Butter, Super Chunk, 48 oz, 2-count', 'Pantry & Dry Goods', 9.69, 35, '2023-04-10', 'in-stock'),
(11006, 'Nongshim Shin Gold Ramyun Noodle Soup with Chicken Broth, Gourmet Spicy, 3.56 oz, 6-count', 'Pantry & Dry Goods', 10.99, 62, '2023-02-10', 'in-stock'),
(11007, 'Kirkland Signature, Organic Chicken Stock, 32 fl oz, 6-Count', 'Pantry & Dry Goods', 11.99, 36, '2023-02-21', 'in-stock'),
(11008, 'Kirkland Signature, Organic Extra Virgin Olive Oil, 2 L', 'Pantry & Dry Goods', 18.99, 53, '2023-10-23', 'in-stock'),
(11009, 'Nissin, Cup Noodles, Chicken, 24-Count', 'Pantry & Dry Goods', 13.99, 38, '2023-08-16', 'in-stock'),
(11010, 'Namaste USDA Organic Gluten Free Perfect Sweet Brown Rice Flour Blend 48 oz  6-count', 'Pantry & Dry Goods', 74.99, 91, '2023-03-10', 'in-stock'),
(11011, 'Kirkland Signature Creamy Almond Butter, 27 oz', 'Pantry & Dry Goods', 7.99, 77, '2023-11-09', 'in-stock'),
(11012, 'Knorr, Chicken Bouillon, 7.9 lbs', 'Pantry & Dry Goods', 22.99, 72, '2023-05-04', 'in-stock'),
(11013, 'Season, Skinless & Boneless Sardines In Olive Oil, 4.375 oz, 6-Count', 'Pantry & Dry Goods', 10.99, 21, '2023-12-07', 'in-stock'),
(11014, 'Kirkland Signature, Extra Virgin Italian Olive Oil, 2 L', 'Pantry & Dry Goods', 18.99, 34, '2023-06-30', 'in-stock'),
(11015, 'Snapdragon, Vietnamese Pho Bowls, 2.3 oz, 9-Count', 'Pantry & Dry Goods', 14.99, 43, '2023-01-04', 'in-stock'),
(11016, 'Nongshim, Udon Noodle Soup Bowl, 9.73 oz, 6-Count', 'Pantry & Dry Goods', 22.99, 41, '2023-10-28', 'in-stock'),
(11017, 'Kirkland Signature Organic No-Salt Seasoning, 14.5 oz', 'Pantry & Dry Goods', 9.99, 49, '2023-04-14', 'in-stock'),
(11018, 'Kraft, Macaroni & Cheese Dinner Cup, 2.05 oz, 12-Count', 'Pantry & Dry Goods', 12.49, 69, '2023-09-10', 'in-stock'),
(11019, 'Bibigo, Cooked Sticky White Rice Bowls, Medium Grain, 7.4 oz, 12-Count', 'Pantry & Dry Goods', 13.49, 80, '2023-07-12', 'in-stock'),
(11020, 'Samyang, Buldak Stir-Fried Spicy Chicken Ramen, Habanero Lime, 3.88 oz, 6-Count', 'Pantry & Dry Goods', 13.99, 4, '2023-10-09', 'in-stock'),
(11021, 'Seeds of Change, Organic Quinoa and Brown Rice, 8.5 oz, 6-Count', 'Pantry & Dry Goods', 14.99, 91, '2023-07-27', 'in-stock'),
(11022, 'Kraft, Macaroni & Cheese Dinner, 7.25 oz, 18-Count', 'Pantry & Dry Goods', 18.99, 84, '2023-11-02', 'in-stock'),
(11023, 'Nongshim, Shin Ramyun Noodle Soup, 4.2 oz, 18-Count', 'Pantry & Dry Goods', 19.99, 53, '2023-01-11', 'in-stock'),
(11024, 'Chicken of the Sea, Chunk Light Premium Tuna in Water, 7 oz, 12-Count', 'Pantry & Dry Goods', 19.99, 52, '2023-08-15', 'in-stock'),
(11025, 'Kirkland Signature Semi-Sweet Chocolate Chips, 4.5 lbs', 'Pantry & Dry Goods', 13.99, 60, '2023-12-28', 'in-stock'),
(11026, 'Kirkland Signature, Refined Olive Oil, 3 Liter, 2-count', 'Pantry & Dry Goods', 52.99, 47, '2023-02-26', 'in-stock'),
(11027, 'Skippy Creamy Peanut Butter Squeeze Packets, 1.15 oz, 32-count', 'Pantry & Dry Goods', 9.99, 21, '2023-06-10', 'in-stock'),
(11028, 'Nissin, Cup Noodles, Shrimp, 2.5 oz, 24-Count', 'Pantry & Dry Goods', 13.99, 21, '2023-07-03', 'in-stock'),
(11029, 'Kraft, Grated Parmesan Cheese 4.5 lbs', 'Pantry & Dry Goods', 26.99, 72, '2023-08-08', 'in-stock'),
(11030, 'Nongshim, Tonkotsu Ramen Bowl, 3.56 oz, 6-Count', 'Pantry & Dry Goods', 10.39, 26, '2023-05-17', 'in-stock'),
(11031, 'Kirkland Signature, Organic Virgin Coconut Oil, 84 fl oz', 'Pantry & Dry Goods', 17.99, 13, '2023-09-25', 'in-stock'),
(11032, 'Kirkland Signature Organic Raw Honey, 24 oz, 3-count', 'Pantry & Dry Goods', 17.99, 55, '2023-08-29', 'in-stock'),
(11033, 'Kirkland Signature Organic Pure Maple Syrup, 33.8 oz', 'Pantry & Dry Goods', 14.99, 60, '2023-12-19', 'in-stock'),
(11034, 'Kirkland Signature, Semi-Sweet Chocolate Chips, 4.5 lbs', 'Pantry & Dry Goods', 14.99, 64, '2023-03-09', 'in-stock'),
(11035, 'Kirkland Signature, Organic Sugar, 10 lbs', 'Pantry & Dry Goods', 10.99, 80, '2023-11-15', 'in-stock'),
(11036, 'Full Thread Greek Saffron 14 Gram Jar', 'Pantry & Dry Goods', 59.99, 26, '2023-06-07', 'in-stock'),
(11037, 'Namaste Gluten Free Perfect Flour Blend, 6-pack', 'Pantry & Dry Goods', 56.99, 26, '2023-04-01', 'in-stock'),
(11038, 'TRE Olive Oil Calabrian Gift Box', 'Pantry & Dry Goods', 79.99, 72, '2023-06-25', 'in-stock'),
(11039, 'TRE Olive 2 Liter Extra Virgin Olive Oil', 'Pantry & Dry Goods', 39.99, 95, '2023-04-09', 'in-stock'),
(11040, 'Kirkland Signature, Canola Oil, 3 qt, 2-count', 'Pantry & Dry Goods', 14.99, 60, '2023-07-14', 'in-stock'),
(11041, 'Kirkland Signature, Pure Sea Salt, 30 oz', 'Pantry & Dry Goods', 3.99, 61, '2023-05-19', 'in-stock'),
(11042, 'Napa Valley Naturals USDA Organic Extra Virgin Olive Oil 25.4 oz, 6-count', 'Pantry & Dry Goods', 79.99, 80, '2023-06-18', 'in-stock'),
(11043, 'Origin 846 Unfiltered Organic Extra Virgin Olive Oil 28.6 oz, 3-pack', 'Pantry & Dry Goods', 29.99, 54, '2023-10-09', 'in-stock'),
(11044, 'Royal, Basmati Rice, 20 lbs', 'Pantry & Dry Goods', 24.99, 74, '2023-04-13', 'in-stock'),
(11045, 'Tre Olive Harvest Variety Gift Box Extra Virgin Olive Oil 3-Pack', 'Pantry & Dry Goods', 59.99, 56, '2023-01-05', 'in-stock'),
(11046, 'Manuka Health UMF 10+ (MGO 263+) Raw Manuka Honey 17.6 oz', 'Pantry & Dry Goods', 29.99, 13, '2023-07-06', 'in-stock'),
(11047, 'Kirkland Signature, Crushed Red Pepper, 10 oz', 'Pantry & Dry Goods', 4.79, 54, '2023-09-14', 'in-stock'),
(11048, 'Nissin, Hot & Spicy Noodle Bowl, Chicken, 3.32 oz, 18-Count', 'Pantry & Dry Goods', 17.49, 93, '2023-07-27', 'in-stock'),
(11049, 'Terra Delyssa First Cold Press Extra Virgin Olive Oil 3L, Tin, 2-count', 'Pantry & Dry Goods', 64.99, 44, '2023-01-22', 'in-stock'),
(11050, 'Del Monte, Canned Cut Green Beans, 14.5 oz, 12-Count', 'Pantry & Dry Goods', 12.99, 20, '2023-12-06', 'in-stock'),
(11051, 'Kirkland Signature, Vegetable Oil, 3 qt, 2-Count', 'Pantry & Dry Goods', 14.99, 65, '2023-06-09', 'in-stock'),
(11052, 'Kirkland Signature Wild Flower Honey, 5 lbs', 'Pantry & Dry Goods', 17.99, 97, '2023-11-28', 'in-stock'),
(11053, 'Del Monte, Diced Peaches, Fruit Cups, 4 oz cups, 20-Count', 'Pantry & Dry Goods', 13.99, 29, '2023-07-07', 'in-stock'),
(11054, 'Thai Kitchen Organic Coconut Milk, Unsweetened, 13.66 fl oz, 6-count', 'Pantry & Dry Goods', 14.99, 48, '2023-12-28', 'in-stock'),
(11055, 'Kirkland Signature, Organic Quinoa, 4.5 lbs', 'Pantry & Dry Goods', 10.99, 61, '2023-07-24', 'in-stock'),
(11056, 'Wild Planet, Albacore Wilda Tuna, 5 oz, 6-Count', 'Pantry & Dry Goods', 19.99, 4, '2023-04-28', 'in-stock'),
(11057, 'Ardent Mills, Harvest Hotel & Restaurant, All-Purpose Flour, 25 lbs', 'Pantry & Dry Goods', 11.99, 46, '2023-05-22', 'in-stock'),
(11058, 'Chosen Foods Avocado Oil Spray, 13.5 oz, 2-count', 'Pantry & Dry Goods', 21.99, 36, '2023-05-30', 'in-stock'),
(11059, 'Nestle La Lechera, Sweetened Condensed Milk, 14 oz, 6-Count', 'Pantry & Dry Goods', 15.99, 18, '2023-02-11', 'in-stock'),
(11060, 'Comvita UMF 25+ Special Reserve Manuka Honey 8.8 oz', 'Pantry & Dry Goods', 349.99, 73, '2023-02-15', 'in-stock'),
(11061, 'eat.art Salt and Spice Set 2-pack', 'Pantry & Dry Goods', 44.99, 72, '2023-07-28', 'in-stock'),
(11062, 'Kirkland Signature, Bacon Crumbles, 20 oz', 'Pantry & Dry Goods', 10.99, 73, '2023-05-05', 'in-stock'),
(11063, 'Nissin, Cup Noodles, Beef, 2.5 oz, 24-Count', 'Pantry & Dry Goods', 13.99, 4, '2023-03-30', 'in-stock');

INSERT INTO products (id, name, category, price, stock, expiry, status) VALUES
(12000, 'Ahi Tuna Individual Vacuum Packed Portion (26-27/6 Oz. Per Portion), 26-27 Total Packs, 10 Lbs. Total Case', 'Seafood', 149.99, 54, '2023-09-13', 'in-stock'),
(12001, 'Alaska Home Pack Frozen Sea Cucumber - 3 Packs, 7 Lbs. Total', 'Seafood', 239.99, 56, '2023-06-04', 'in-stock'),
(12002, 'Crown Prince Smoked Oysters in Olive Oil, Fancy Whole, 3.75 oz, 6-count', 'Seafood', 14.99, 68, '2023-11-21', 'in-stock'),
(12003, 'Lobster With Shell Removed, (9 Oz. Per Pack), 6 Total Packs, 3.44 Lbs. Total', 'Seafood', 259.99, 21, '2023-04-30', 'in-stock'),
(12004, 'Northwest Fish 4-6 Whole Dungeness Crab, 10 lbs', 'Seafood', 209.99, 66, '2023-12-23', 'in-stock'),
(12005, 'Premium Seafood Variety Pack - 20 Total Packs, Total 12.5 Lbs.', 'Seafood', 349.99, 86, '2023-07-28', 'in-stock'),
(12006, 'Chicago Steak - Steak & Cake - Filet Mignon, Crab Cakes, and Steak Burgers, Total 13 Packs, 6.5 Lbs. Total', 'Seafood', 199.99, 39, '2023-07-17', 'in-stock'),
(12007, 'Northwest Fish Colossal Alaskan Wild Dungeness Crab Sections, 10lbs', 'Seafood', 219.99, 92, '2023-11-20', 'in-stock'),
(12008, 'Northwest Fish Wild Alaskan Sockeye Salmon Cheddar Bacon Burger Patties, 24-count, 9 lbs', 'Seafood', 119.99, 94, '2023-12-13', 'in-stock'),
(12009, 'Coastal Seafood Frozen Lobster Tails 12 Count (6 - 8  oz.)', 'Seafood', 229.99, 51, '2023-03-04', 'in-stock'),
(12010, 'Rastelli Market Fresh Jumbo Lump Crab Cakes (20/4 Oz. Per Crab Cake), 20 Total Count, 5 Lbs. Total', 'Seafood', 199.99, 10, '2023-05-18', 'in-stock'),
(12011, 'Rastelli Petite Filet Mignon & Jumbo Lump Crab Cake Surf & Turf, 24 Total Packs, 6.75 Total Lbs.', 'Seafood', 349.99, 91, '2023-10-25', 'in-stock'),
(12012, 'Chicago Steak Premium Angus Beef Surf & Turf, 15 Total Packs, 7 Lbs. Total', 'Seafood', 239.99, 33, '2023-04-20', 'in-stock'),
(12013, 'Wild Alaska Snow Crab Meat (Bairdi Crab 8 oz. Pack) 12 Total Packs, 6 Lbs. Total', 'Seafood', 279.99, 81, '2023-07-22', 'in-stock'),
(12014, 'Northwest Red King Salmon Portions, 12 Total Count, 1 Case Totaling 6 Lbs.', 'Seafood', 179.99, 73, '2023-11-22', 'in-stock'),
(12015, 'Chicago Steak USDA Prime Surf & Turf, Total 14 Packs, 7 Lbs. Total', 'Seafood', 299.99, 50, '2023-08-13', 'in-stock'),
(12016, 'Ahi Tuna Mixed Pack, (12 x 6 oz. Steaks, 9 x 5.3 oz. Saku Slice Packs, 4 x 10.7 oz. Sesame Crusted Steak Packs), 25 Total Packs, 10.15 Lbs. Total', 'Seafood', 239.99, 66, '2023-11-11', 'in-stock'),
(12017, 'Northwest Fish Wild Alaskan Sockeye Salmon Fillets, 10 lbs', 'Seafood', 219.99, 43, '2023-07-23', 'in-stock'),
(12018, 'Smoked New Zealand King Salmon, 1.1lb fillets, 2-count, 2.2 lbs total', 'Seafood', 109.99, 93, '2023-10-29', 'in-stock'),
(12019, 'Chicago Steak Filet Mignon & Scallop Combo, 14 Total Packs, 7 Lbs. Total', 'Seafood', 249.99, 74, '2023-06-20', 'in-stock'),
(12020, 'Northwest Fish Wild Alaskan Sockeye Salmon Fillets Total 25 Count, 1 Case Totaling 10 Lbs.', 'Seafood', 229.99, 94, '2023-10-30', 'in-stock'),
(12021, 'A5 Wagyu Surf & Turf Pack, Cold Water Lobster Tails & Japanese A5 Wagyu Filet Mignon, Total 4 Packs', 'Seafood', 379.99, 0, '2023-07-23', 'out-of-stock'),
(12022, 'Wild Alaska Halibut Bits & Pieces, (8/1 lb Packs) 8 Total Packs, 8 Lbs. Total', 'Seafood', 159.99, 53, '2023-02-04', 'in-stock'),
(12023, 'Seabear Wild Sockeye & King  Smoked Salmon Fillet Duo, Total 2lbs. (1 lb each)', 'Seafood', 64.99, 5, '2023-11-24', 'in-stock'),
(12024, 'Rastelli Market Fresh Angus Beef Prime Petite Filet Mignons & Wild Caught Maine Lobster Tails, 8 Total Packs, 3 Lbs. Total', 'Seafood', 189.99, 37, '2023-04-23', 'in-stock'),
(12025, 'Trident Seafoods Smoked Sockeye Salmon, 2 Gift Packs', 'Seafood', 59.99, 39, '2023-12-27', 'in-stock'),
(12026, 'SeaBear Smoked Salmon Gift Boxes, 6 oz, 6-pack', 'Seafood', 79.99, 88, '2023-03-28', 'in-stock'),
(12027, 'Grizzly Salmon Tartare with Citrus Marinade, (14/4 Oz Packs), 14 Total Packs, Total 3.5 Lbs.', 'Seafood', 129.99, 86, '2023-12-31', 'in-stock'),
(12028, 'Sesame Crusted Ahi Tuna Steaks, 18 Total Packs, 1 Case Totaling 12 Lbs.', 'Seafood', 269.99, 23, '2023-11-29', 'in-stock'),
(12029, 'Aysen Coho Sashimi Quality Salmon Portions, (6 Oz. Portion Per Pack), 26 to 27 Total Packs, 10 Lbs. Total', 'Seafood', 169.99, 35, '2023-04-25', 'in-stock'),
(12030, 'Aysen Coho Salmon Filets, (4/2-3 Lbs. Per Filet), 4 Total Packs, 8 Lbs. Total', 'Seafood', 199.99, 16, '2023-09-06', 'in-stock'),
(12031, 'Key West Pink 16/20 Gulf Shrimp Headless Shell-On (3/2Lb Per Bag), Total 3 Packs, 6 Lbs. Total', 'Seafood', 119.99, 42, '2023-12-12', 'in-stock'),
(12032, 'Whole Cooked Cold Water Lobsters, (8-9/1.25 Lbs. Each Lobster), 1 Case Totaling 12 Lbs.', 'Seafood', 259.99, 46, '2023-03-16', 'in-stock'),
(12033, 'Northwest Fish Wild Alaskan Cod Loins Total 25 Count, 1 Case Totaling 10 Lbs.', 'Seafood', 169.99, 24, '2023-09-17', 'in-stock'),
(12034, 'Alaska Black Cod (Sable Fish) - Individual Packed Portions (19-25/6-8 Oz. Per Portion), 1 Case Totaling 10 Lbs.', 'Seafood', 269.99, 48, '2023-04-11', 'in-stock'),
(12035, 'Lobster Claws & Arms, Sustainable Wild Caught, North Atlantic, 24-40 Claws & Arms (3-5 Lb. Per.), Total 8Lb. Case', 'Seafood', 199.99, 78, '2023-02-06', 'in-stock'),
(12036, 'Coastal Seafood Live Maine Lobsters, (6/1.25 Lbs. Per Lobster) 6 Total Packs, 7.5 Lbs. Total', 'Seafood', 179.99, 37, '2023-03-02', 'in-stock'),
(12037, 'Tsar Nicoulai Caviar Sturgeon Pate 6 oz, 6-pack', 'Seafood', 59.99, 13, '2023-10-30', 'in-stock'),
(12038, 'Cristobal Salted Cod Fillets 2 lbs, 3-pack', 'Seafood', 69.97, 63, '2023-08-06', 'in-stock'),
(12039, 'Northwest Fish Sablefish Loins, Skin on, 7 oz, 23-count, 10 lbs', 'Seafood', 269.99, 34, '2023-05-11', 'in-stock'),
(12040, 'Northwest Fish Halibut Fillets, Skin-On 7-9 oz, 18-count, 10 lbs', 'Seafood', 249.99, 97, '2023-10-30', 'in-stock'),
(12041, 'Northwest Fish U-12 Sea Scallops, 6 lbs', 'Seafood', 219.99, 79, '2023-06-05', 'in-stock'),
(12042, 'American Red Snapper - Whole, Head-On, Cleaned, (5-7 Individually Vacuum Packed Portions/ 1.5-2 Lbs Per Fish) - Total 10Lbs.', 'Seafood', 189.99, 36, '2023-10-09', 'in-stock'),
(12043, 'Whole Head On, Cleaned Branzino Fish (12-18 Oz. Per Fish), Min 7 Count, 10 Lbs. Total', 'Seafood', 139.99, 44, '2023-06-10', 'in-stock'),
(12044, 'El Rey Del Pulpo, Large Cooked Octopus Tentacles, 14 oz, 6-pack, 5.25 lbs', 'Seafood', 159.99, 92, '2023-04-20', 'in-stock'),
(12045, 'Mahi Mahi Boneless, (26-27/Skinless 6 Oz. Portions Per Each Pack), 26-27 Total Packs, 1 Case Totaling 10 Lbs.', 'Seafood', 249.99, 20, '2023-05-08', 'in-stock'),
(12046, 'Tsar Nicoulai Estate Smoked Sturgeon 6 oz, 6-count, 2.25 lbs', 'Seafood', 79.99, 100, '2023-01-13', 'in-stock');

INSERT INTO products (id, name, category, price, stock, expiry, status)
VALUES
(13000, 'Kirkland Signature Super Extra-Large Peanuts, 2.5 lbs', 'Snacks', 8.99, 38, '2023-09-26', 'in-stock'),
(13001, 'Kirkland Signature Protein Bars Chocolate Peanut Butter Chunk 2.12 oz, 20-count', 'Snacks', 23.99, 13, '2023-08-28', 'in-stock'),
(13002, 'G2G 3-pack Peanut Butter Chocolate Chip Protein Bars 24-count', 'Snacks', 39.99, 75, '2023-07-08', 'in-stock'),
(13003, 'G2G 3-pack Peanut Butter Coconut Chocolate Protein Bars 24-count', 'Snacks', 39.99, 84, '2023-12-04', 'in-stock'),
(13004, 'Frito Lay Oven Baked Mix, Variety Pack, 30-count', 'Snacks', 16.99, 46, '2023-07-28', 'in-stock'),
(13005, 'Old Trapper Beef Jerky, Peppered, 10 oz', 'Snacks', 13.99, 11, '2023-06-05', 'in-stock'),
(13006, 'Old Trapper Beef Jerky, Hot & Spicy, 10 oz', 'Snacks', 13.99, 22, '2023-11-27', 'in-stock'),
(13007, 'Old Trapper Beef Jerky, Old Fashioned, 10 oz', 'Snacks', 13.99, 50, '2023-02-09', 'in-stock'),
(13008, 'Kirkland Signature Chewy Protein Bar, Peanut Butter & Semisweet Chocolate Chip, 1.41 oz, 42-Count', 'Snacks', 18.99, 18, '2023-05-26', 'in-stock'),
(13009, 'Kirkland Signature Protein Bars Chocolate Chip Cookie Dough 2.12 oz., 20-count', 'Snacks', 23.99, 91, '2023-04-16', 'in-stock'),
(13010, 'Simply Protein Crispy Bars, 1.41 oz, Variety Pack, 15-count', 'Snacks', 22.99, 59, '2023-12-03', 'in-stock'),
(13011, 'PopCorners Popped Corn Snacks Variety Pack, 1 oz, 30-Count', 'Snacks', 16.99, 28, '2023-07-24', 'in-stock'),
(13012, 'Simple Mills Almond Flour Sea Salt Crackers, 10 oz, 2-count', 'Snacks', 9.49, 86, '2023-04-24', 'in-stock'),
(13013, 'Fit Crunch Whey Protein Bar, Peanut Butter and Jelly, 1.62 oz, 18 Count', 'Snacks', 22.99, 90, '2023-07-23', 'in-stock'),
(13014, 'Pure Protein Bars, Variety Pack, 1.76 oz, 23-count', 'Snacks', 20.99, 36, '2023-04-19', 'in-stock'),
(13015, 'Kirkland Signature Protein Bars Chocolate Brownie  2.12 oz, 20-count', 'Snacks', 23.99, 93, '2023-06-27', 'in-stock'),
(13016, 'Kirkland Signature Protein Bar, Variety Pack, 2.12 oz, 20-count', 'Snacks', 22.99, 1, '2023-08-05', 'in-stock'),
(13017, 'G2G 3-pack Peanut Butter & Jelly Protein Bars, 24-count', 'Snacks', 49.99, 94, '2023-02-18', 'in-stock'),
(13018, 'Frito Lay Classic Mix, 1 oz, Variety Pack, 54-count', 'Snacks', 23.99, 58, '2023-04-13', 'in-stock'),
(13019, 'Natures Garden Organic Trail Mix Snack Packs, Variety Pack, 1.2 oz, 24-count', 'Snacks', 11.49, 17, '2023-05-31', 'in-stock'),
(13020, 'RITZ Bits Cracker Sandwiches, Cheese, 1.5 oz, 30-count', 'Snacks', 14.99, 72, '2023-01-21', 'in-stock'),
(13021, 'Kirkland Signature Nut Bars, 1.41 oz, 30-count', 'Snacks', 17.99, 42, '2023-09-02', 'in-stock'),
(13022, 'Nature Valley Protein Bar, Peanut Butter Dark Chocolate, 1.42 oz, 30-count', 'Snacks', 18.99, 90, '2023-04-02', 'in-stock'),
(13023, 'Kirkland Signature Soft & Chewy Granola Bars, 0.85 oz, 64-count', 'Snacks', 11.99, 28, '2023-03-15', 'in-stock'),
(13024, 'Pure Organic Layered Fruit Bars, Variety Pack,  0.63 oz, 28-count', 'Snacks', 11.89, 24, '2023-04-04', 'in-stock'),
(13025, 'St Michel Madeleine, Classic French Sponge Cake 100 - count', 'Snacks', 44.99, 13, '2023-03-12', 'in-stock'),
(13026, 'Nabisco Cookie & Cracker, Variety Pack, 1 oz, 40-count', 'Snacks', 14.99, 56, '2023-02-27', 'in-stock'),
(13027, 'Kirkland Signature Cashew Clusters, 2 lbs', 'Snacks', 10.99, 38, '2023-10-01', 'in-stock'),
(13028, 'No Sugar Keto Bar (12 count) 2-pack Chocolate Peanut Butter', 'Snacks', 42.99, 86, '2023-05-25', 'in-stock'),
(13029, 'Ready Protein Bar, Chocolate Peanut Butter and Sea Salt, 24-count, 2 pack', 'Snacks', 54.99, 87, '2024-01-09', 'in-stock'),
(13030, 'KIND Bar, Peanut Butter Dark Chocolate, 1.4 oz, 15-count', 'Snacks', 17.99, 52, '2023-09-14', 'in-stock'),
(13031, 'Thats it Mini Fruit Bars, 24-count', 'Snacks', 15.99, 83, '2023-08-15', 'in-stock'),
(13032, 'Chef Robert Irvines Fitcrunch Chocolate Peanut Butter Whey Protein Bars, 18-count, 1.62oz', 'Snacks', 22.99, 65, '2023-07-10', 'in-stock'),
(13033, 'Chef Robert Irvines Fit Crunch Whey Protein Bars, Mint Chocolate Chip, 18-count, 1.62 Oz', 'Snacks', 22.99, 39, '2023-11-08', 'in-stock'),
(13034, 'Power Crunch Protein Energy Bar, Strawberry Creme, 1.4 oz, 12-count', 'Snacks', 17.99, 6, '2023-09-25', 'in-stock'),
(13035, 'Shrimp Chips with Garlic and Butter 16 oz 2-pack', 'Snacks', 27.99, 92, '2023-07-17', 'in-stock'),
(13036, 'Nutter Butter Sandwich Cookies, 1.9 oz, 24-count', 'Snacks', 12.99, 91, '2023-01-23', 'in-stock'),
(13037, 'Paradise Green, Dried Ginger Chunks, 32 oz', 'Snacks', 8.99, 19, '2023-11-13', 'in-stock'),
(13038, 'Grandmas Cookies, Variety Pack, 2.5 oz, 33-count', 'Snacks', 18.99, 19, '2023-06-24', 'in-stock'),
(13039, 'Skinny Pop Popcorn, 0.65 oz, 28-count', 'Snacks', 17.99, 4, '2023-11-26', 'in-stock'),
(13040, 'Clif Bar, Crunchy Peanut Butter, 2.4 oz, 12-count', 'Snacks', 17.99, 38, '2023-11-04', 'in-stock'),
(13041, 'Lance Toasty Cracker Sandwiches, 1.29 oz, 40-count', 'Snacks', 9.99, 36, '2023-08-20', 'in-stock'),
(13042, 'Kirkland Signature Snacking Nuts, Variety Pack, 1.6 oz, 30-count', 'Snacks', 16.99, 75, '2023-11-27', 'in-stock'),
(13043, 'Planters, Cashew & Peanut, Variety Pack, 24-count', 'Snacks', 10.69, 88, '2023-11-03', 'in-stock'),
(13044, 'Annies Organic Bunny Snack Pack Baked Crackers and Graham Snacks, 1.07 oz, Variety Pack, 36-count', 'Snacks', 16.99, 30, '2023-06-24', 'in-stock'),
(13045, 'Skippy Peanut Butter & Chocolate Fudge Wafer Bar, 1.3 oz, 22-Count', 'Snacks', 13.99, 12, '2023-09-09', 'in-stock'),
(13046, 'Kirkland Signature Turkey Jerky, 13.5 oz', 'Snacks', 13.99, 54, '2023-01-27', 'in-stock'),
(13047, 'Kirkland Signature Fancy Whole Cashews, 2.5 lbs', 'Snacks', 14.99, 86, '2023-04-30', 'in-stock'),
(13048, 'Power Crunch Protein Energy Bars, Peanut Butter Creme, 1.4 oz, 12-count', 'Snacks', 17.99, 89, '2023-08-31', 'in-stock'),
(13049, 'WildRoots Coastal Berry Trail Mix, 26 oz', 'Snacks', 12.99, 66, '2023-11-15', 'in-stock'),
(13050, 'SkinnyPop Popcorn, Variety, 36-count', 'Snacks', 18.99, 61, '2023-06-09', 'in-stock'),
(13051, 'Quaker Rice Crisps, Variety Pack, 36-count', 'Snacks', 19.99, 79, '2023-10-16', 'in-stock'),
(13052, 'Kirkland Signature Trail Mix Snack Packs, 2 oz, 28-count', 'Snacks', 17.99, 25, '2023-07-10', 'in-stock'),
(13053, 'Think Thin High Protein Bar, Variety Pack, 2.1 oz, 18-count', 'Snacks', 24.49, 69, '2023-09-03', 'in-stock'),
(13054, 'G2G 3-pack Almond Chocolate Chip Protein Bars, 24-count', 'Snacks', 49.99, 18, '2023-03-29', 'in-stock'),
(13055, 'Kirkland Signature Variety Snack Box, 51-count', 'Snacks', 32.99, 43, '2023-10-02', 'in-stock'),
(13056, 'Nature Valley Crunchy Granola Bar, Oats n Honey, 1.49 oz, 49-count', 'Snacks', 17.99, 83, '2023-09-13', 'in-stock'),
(13057, 'Doritos Tortilla Chips, Nacho Cheese, 1 oz, 50-count', 'Snacks', 22.99, 72, '2023-04-21', 'in-stock'),
(13058, 'Kirkland Signature Extra Fancy Mixed Nuts, Salted, 2.5 lbs', 'Snacks', 15.99, 88, '2023-02-02', 'in-stock'),
(13059, 'Jack Links All American Beef Stick, Beef & Cheese, 1.2 oz, 16-count', 'Snacks', 19.99, 100, '2023-02-18', 'in-stock'),
(13060, 'Cheez-It Puffd Baked Snacks, Double Cheese, 0.7 oz, 36 count', 'Snacks', 19.99, 56, '2024-01-12', 'in-stock'),
(13061, 'Doritos Tortilla Chips, Nacho Cheese, 1.75 oz, 64-count', 'Snacks', 44.99, 35, '2023-12-27', 'in-stock'),
(13062, 'Nature Valley Fruit & Nut Chewy Granola Bar, Trail Mix, 1.2 oz, 48-count', 'Snacks', 17.99, 61, '2023-10-06', 'in-stock'),
(13063, 'Kirkland Signature, Whole Dried Blueberries, 20 oz', 'Snacks', 10.49, 17, '2023-08-17', 'in-stock'),
(13064, 'Power Crunch Protein Energy Bar, French Vanilla, 1.4 oz, 12-count', 'Snacks', 17.99, 85, '2023-09-01', 'in-stock'),
(13065, 'Savanna Orchards Honey Roasted Nut & Pistachios 30 oz, 2-pack', 'Snacks', 38.99, 23, '2023-10-22', 'in-stock'),
(13066, 'Power Crunch Protein Energy Bar, Triple Chocolate, 1.4 oz, 12-count', 'Snacks', 17.99, 51, '2023-06-27', 'in-stock');

INSERT INTO bakeryAndDesserts (id, name, stock, expiry, price, status) VALUES
(1, 'Davids Cookies Mile High Peanut Butter Cake, 6.8 lbs (14 Servings)', 2, '2023-09-18', 56.99, 'in-stock'),
(2, 'The Cake Bake Shop 8 Round Carrot Cake (16-22 Servings)', 29, '2023-03-08', 159.99, 'in-stock'),
(3, 'St Michel Madeleine, Classic French Sponge Cake 100 - count', 33, '2023-05-03', 44.99, 'in-stock'),
(4, 'Davids Cookies Butter Pecan Meltaways 32 oz, 2-pack', 56, '2023-09-04', 39.99, 'in-stock'),
(5, 'Davids Cookies Premier Chocolate Cake, 7.2 lbs (Serves 14)', 84, '2023-11-04', 59.99, 'in-stock'),
(6, 'Davids Cookies Mango & Strawberry Cheesecake 2-count (28 Slices Total)', 84, '2023-10-26', 59.99, 'in-stock'),
(7, 'La Grande Galette French Butter Cookies, 1.3 lb, 6-pack', 30, '2023-11-30', 74.99, 'in-stock'),
(8, 'Davids Cookies No Sugar Added Cheesecake & Marble Truffle Cake, 2-pack (28 Slices Total)', 10, '2023-06-09', 59.99, 'in-stock'),
(9, 'Davids Cookies Brownie and Cookie Combo Pack', 100, '2023-07-11', 29.99, 'in-stock'),
(10, 'The Cake Bake Shop 8 Round Chocolate Cake (16-22 Servings)', 90, '2023-12-23', 159.99, 'in-stock'),
(11, 'Davids Cookies 10 Rainbow Cake (12 Servings)', 64, '2023-02-16', 62.99, 'in-stock'),
(12, 'The Cake Bake Shop 2 Tier Special Occasion Cake (16-22 Servings)', 60, '2023-07-19', 299.99, 'in-stock'),
(13, 'Davids Cookies 90-piece Gourmet Chocolate Chunk Frozen Cookie Dough', 44, '2023-12-14', 54.99, 'in-stock'),
(14, 'Davids Cookies Chocolate Fudge Birthday Cake, 3.75 lbs. Includes Party Pack (16 Servings)', 25, '2023-07-20', 54.99, 'in-stock'),
(15, 'Ferraras Bakery New York Cheesecake 2-pack', 2, '2023-11-21', 89.99, 'in-stock'),
(16, 'Davids Cookies Variety Cheesecakes, 2-pack (28 Slices Total)', 2, '2023-07-15', 59.99, 'in-stock'),
(17, 'Classic Cake Tiramisu Quarter Sheet Cake (14 Pre-Cut Total Slices, 4.57 Oz. Per Slice, 4 Lbs. Total Box)', 66, '2023-01-29', 89.99, 'in-stock'),
(18, 'Mary Macleods Gluten Free Shortbread Cookies Mixed Assortment 8-Pack', 4, '2023-06-06', 49.99, 'in-stock'),
(19, 'The Cake Bake Shop 8 Round Pixie Fetti Cake (16-22 Servings)', 61, '2023-03-09', 159.99, 'in-stock'),
(20, 'Classic Cake Chocolate Entremet Quarter Sheet Cake (14 Pre-Cut Total Slices, 4 Oz. Per Slice, 3.5 Lbs. Total Box)', 8, '2023-09-22', 89.99, 'in-stock'),
(21, 'Ferraras Bakery 8 in. Tiramisu Cake, 2-pack', 23, '2023-09-24', 99.99, 'in-stock'),
(22, 'Classic Cake Limoncello Quarter Sheet Cake (14 Pre-Cut Total Slices, 4 Oz. Per Slice, 3.5 Lbs Total Box)', 72, '2023-12-18', 89.99, 'in-stock'),
(23, 'deMilan Panettone Classico Tin Cake 2.2 lb Tin', 85, '2023-10-26', 24.99, 'in-stock'),
(24, 'Davids Cookies Decadent Triple Chocolate made with mini Hersheys Kisses and Reeses Peanut Butter Cup Cookies Tin – 2 Count', 96, '2023-09-23', 39.99, 'in-stock'),
(25, 'Ferraras Bakery 4 lbs. Italian Cookie Pack', 35, '2023-03-28', 72.99, 'in-stock'),
(26, 'Ferraras Bakery 48 Mini Cannolis (24 Plain Filled and 24 Hand Dipped Belgian Chocolate) - 1.5 to 2 In Length', 38, '2023-03-21', 119.99, 'in-stock'),
(27, 'Ferraras Bakery 24 Large Cannolis (12 Plain Filled and 12 Hand Dipped Belgian Chocolate)', 66, '2023-12-13', 109.99, 'in-stock'),
(28, 'Mary Macleods Shortbread, Variety Tin, 3-pack, 24 cookies per tin', 25, '2023-05-12', 99.99, 'in-stock'),
(29, 'Ferraras Bakery Rainbow Cookies 1.5 lb', 73, '2023-08-03', 34.99, 'in-stock'),
(30, 'Ferraras Bakery 2 lb Italian Cookie Tray and Struffoli', 97, '2023-06-10', 59.99, 'in-stock'),
(31, 'Tootie Pie 11 Heavenly Chocolate Pie, 2-pack', 12, '2023-03-15', 89.99, 'in-stock'),
(32, 'Tootie Pie 11 Whiskey Pecan Pie, 2-pack', 33, '2023-02-17', 89.99, 'in-stock'),
(33, 'Tootie Pie 11 Huge Original Apple Pie', 23, '2023-08-27', 59.99, 'in-stock');

INSERT INTO beverages (id, name, price, stock, expiry, status) VALUES
(1000, 'Pulp & Press Organic Cold-Pressed Wellness Shot Pack, 48-pack', 99.99, 95, '2023-05-03', 'in-stock'),
(1001, 'Prime Hydration+ Sticks Electrolyte Drink Mix, Variety Pack, 30-Count', 27.99, 74, '2023-10-27', 'in-stock'),
(1002, 'Prime Hydration Drink, Variety Pack, 16.9 fl oz, 15-count', 21.99, 24, '2023-05-12', 'in-stock'),
(1003, 'Alani Nu Energy Drink, Variety Pack, 12 fl oz, 18-count', 20.99, 79, '2023-10-05', 'in-stock'),
(1004, 'Poppi Prebiotic Soda, Variety Pack, 12 fl oz, 15-count', 19.99, 98, '2023-07-29', 'in-stock'),
(1005, 'Poppi Prebiotic Soda, Variety Pack, 12 fl oz, 15-count', 19.99, 67, '2023-08-18', 'in-stock'),
(1006, 'Kirkland Signature Bottled Water 16.9 fl oz, 40-count, 48 Case Pallet', 439.99, 75, '2023-02-15', 'in-stock'),
(1007, 'Kirkland Signature, Organic Almond Beverage, Vanilla, 32 fl oz, 6-Count', 9.99, 79, '2023-12-23', 'in-stock'),
(1008, 'Kirkland Signature, Almond Milk, 1 qt, 12-count', 14.99, 21, '2023-09-07', 'in-stock'),
(1009, 'Kirkland Signature, Organic Reduced Fat Chocolate Milk, 8.25 fl oz, 24-Count', 21.99, 92, '2023-07-15', 'in-stock'),
(1010, 'Kirkland Signature Colombian Cold Brew Coffee, 11 fl oz, 12-count', 18.99, 98, '2023-07-31', 'in-stock'),
(1011, 'Hint Flavored Water, Variety Pack, 16 fl oz, 21-count', 21.49, 7, '2023-08-26', 'in-stock'),
(1012, 'Califia Farms, Cafe Almond Milk, 32 oz, 6-Count', 17.99, 38, '2024-01-10', 'in-stock'),
(1013, 'Pulp and Press 3-Day Organic Cold Pressed Juice Cleanse', 89.99, 25, '2023-11-18', 'in-stock'),
(1014, 'Saratoga Sparkling Spring Water, 16 fl oz, 24-count', 23.99, 56, '2023-12-15', 'in-stock'),
(1015, 'Pure Life Purified Water, 8 fl oz, 24-count', 4.99, 20, '2023-05-19', 'in-stock'),
(1016, 'Fiji Natural Artesian Water, 23.7 fl oz, 12-count', 24.99, 85, '2023-12-17', 'in-stock'),
(1017, 'Tropicana, Apple Juice, 15.2 fl oz, 12-Count', 18.99, 6, '2023-12-23', 'in-stock'),
(1018, 'Olipop 12 oz Prebiotics Soda Variety Pack, 24 Count', 54.99, 29, '2023-01-18', 'in-stock'),
(1019, 'SO Delicious, Organic Coconut Milk, 32 oz, 6-Count', 12.99, 21, '2023-03-31', 'in-stock'),
(1020, 'La Colombe Draft Latte Cold Brew Coffee, Variety Pack, 9 fl oz, 12-count', 21.99, 29, '2023-07-20', 'in-stock'),
(1021, 'Tropicana, 100% Orange Juice, 10 fl oz, 24-Count', 18.99, 78, '2023-03-30', 'in-stock'),
(1022, 'Coca-Cola Mini, 7.5 fl oz, 30-count', 18.99, 53, '2023-09-29', 'in-stock'),
(1023, 'Joyburst Energy Variety, 12 fl oz, 18-count', 32.99, 54, '2023-08-19', 'in-stock'),
(1024, 'Illy Cold Brew Coffee Drink, Classico, 8.45 fl oz, 12-count', 29.99, 11, '2023-09-02', 'in-stock'),
(1025, 'Kirkland Signature, Organic Coconut Water, 33.8 fl oz, 9-count', 21.99, 79, '2023-09-26', 'in-stock'),
(1026, 'LaCroix Sparkling Water, Variety Pack, 12 fl oz, 24-count', 13.79, 78, '2024-01-05', 'in-stock'),
(1027, 'C4 Performance Energy Drink, Frozen Bombsicle, 16 fl oz, 12-count', 23.49, 38, '2023-09-23', 'in-stock'),
(1028, 'San Pellegrino Sparkling Natural Mineral Water, Unflavored, 11.15 fl oz, 24-count', 19.99, 28, '2023-03-23', 'in-stock'),
(1029, 'Kirkland Signature Green Tea Bags, 1.5 g, 100-count', 14.99, 88, '2023-03-31', 'in-stock'),
(1030, 'Horizon, Organic Whole Milk, 8 oz, 18-Count', 21.99, 92, '2023-12-19', 'in-stock'),
(1031, 'LaCroix Sparkling Water, Lime, 12 fl oz, 24-count', 13.79, 69, '2023-11-04', 'in-stock'),
(1032, 'Liquid Death Sparkling Water, 16.9 fl oz, 18-count', 14.99, 34, '2023-11-12', 'in-stock'),
(1033, 'Starbucks Classic Hot Cocoa Mix 30 oz, 2-pack', 34.99, 32, '2023-11-25', 'in-stock'),
(1034, 'VitaCup Green Tea Instant Packets with Matcha, Enhance Energy & Detox, 2-pack (48-count total)', 39.99, 47, '2023-03-21', 'in-stock'),
(1035, 'San Pellegrino Essenza, Variety Pack, 11.15 fl oz, 24-count', 19.99, 74, '2023-10-11', 'in-stock'),
(1036, 'Carnation, Evaporated Milk, 12 fl oz, 12-Count', 22.99, 97, '2023-09-23', 'in-stock'),
(1037, 'Sencha Naturals Everyday Matcha Green Tea Powder, 3-pack', 49.99, 81, '2023-02-23', 'in-stock'),
(1038, 'LaCroix Curate Commemorative Collection Sparkling Water, Variety Pack, 12 fl oz, 24-count', 14.99, 3, '2023-06-22', 'in-stock'),
(1039, 'Lipton, Iced Tea Mix, Lemon, 5 lbs', 8.99, 23, '2024-01-01', 'in-stock'),
(1040, 'San Pellegrino Italian Sparkling Drink, Variety Pack, 11.15 fl oz, 24-count', 23.99, 30, '2023-10-05', 'in-stock'),
(1041, 'Kirkland Signature, Organic Non-Dairy Oat Beverage, 32 oz, 6-count', 12.99, 15, '2023-12-29', 'in-stock'),
(1042, 'Horizon, Organic Low-fat Milk, 8 oz, 18-Count', 21.99, 61, '2023-09-25', 'in-stock'),
(1043, 'Vita Coco, Coconut Water, 11.1 fl oz, 18-Count', 23.99, 72, '2023-04-08', 'in-stock'),
(1044, 'Nestle La Lechera, Sweetened Condensed Milk, 14 oz, 6-Count', 15.99, 54, '2023-09-12', 'in-stock'),
(1045, 'Kirkland Signature, Organic Coconut Water, 11.1 fl oz, 12-count', 12.99, 66, '2023-05-04', 'in-stock'),
(1046, 'LaCroix Sparkling Water, Grapefruit, 12 fl oz, 24-count', 13.79, 77, '2023-12-04', 'in-stock'),
(1047, 'Celsius Sparkling Energy Drink, Variety Pack, 12 fl oz, 18-count', 28.99, 25, '2023-03-21', 'in-stock'),
(1048, 'Vita Coco, Coconut Water, Original, 16.9 fl oz, 12-Count', 27.99, 89, '2023-08-17', 'in-stock'),
(1049, 'San Pellegrino Italian Sparkling Drink, Aranciata Rossa, 11.15 fl oz, 24-count', 23.99, 2, '2023-10-10', 'in-stock'),
(1050, 'Vonbee Honey Citron & Ginger Tea 4.4 lb 2-pack', 34.99, 65, '2023-12-23', 'in-stock'),
(1051, 'Honest Kids, Organic Juice Drink, Variety Pack, 6 fl oz, 40-Count', 15.99, 89, '2023-07-08', 'in-stock'),
(1052, 'Lipton Original Tea Bags, 312-count', 12.99, 53, '2023-04-25', 'in-stock'),
(1053, 'San Pellegrino Italian Sparkling Drink, Melograno & Arancia, 11.15 fl oz, 24-count', 23.99, 90, '2023-09-20', 'in-stock'),
(1054, '5-hour Energy Shot, Regular Strength, Grape, 1.93 fl. oz, 24 Count', 39.99, 86, '2023-12-14', 'in-stock'),
(1055, 'Pepsi Mini, 7.5 fl oz, 30-count', 16.49, 40, '2023-12-15', 'in-stock'),
(1056, '100% Spring Water, 2.5 Gallon, 2-count, 48 Case Pallet', 549.99, 78, '2023-12-01', 'in-stock'),
(1057, 'Stash Tea, Variety Pack, 180-count', 17.49, 80, '2023-06-04', 'in-stock'),
(1058, 'C2O Coconut Water Hydration Pack, The Original, 17.5 fl oz, 15-count', 25.99, 83, '2023-04-30', 'in-stock'),
(1059, 'Oregon Chai, Original Organic Chai Tea Latte Concentrate, 32 fl. oz., 3-Count', 11.69, 84, '2023-04-15', 'in-stock'),
(1060, 'Tiesta Tea Blueberry Wild Child, 2 - 1 Pound Bags & 5.5oz Tin', 59.99, 61, '2023-06-27', 'in-stock'),
(1061, 'Pressed Cold-Pressed Juice & Shot Bundle -18 Bottles, 9 Juices & 9 Shots', 69.99, 80, '2023-11-18', 'in-stock'),
(1062, 'Ito En Jasmine Green Tea, Unsweetened, 16.9 fl oz, 12-count', 21.99, 94, '2023-03-28', 'in-stock'),
(1063, 'Pure Leaf Tea, Sweet Tea, 16.9 fl oz, 18-count', 19.99, 51, '2024-01-06', 'in-stock'),
(1064, 'Ito En Oi Ocha Unsweetened Green Tea, 16.9 fl oz, 12-count', 21.79, 3, '2023-05-25', 'in-stock');

INSERT INTO breakfast (id, name, price, stock, expiry, status) VALUES
(2000, 'MadeGood Granola Minis, Variety Pack, 0.85 oz, 24-count', 10.49, 32, '2023-07-17', 'in-stock'),
(2001, 'Post, Honey Bunches of Oats with Almonds Cereal, 50 oz', 9.69, 33, '2023-09-05', 'in-stock'),
(2002, 'General Mills, Cheerios Cereal, Honey Nut, 27.5 oz, 2-Count', 8.19, 19, '2023-03-17', 'in-stock'),
(2003, 'Kirkland Signature Whole Grain Rolled Oats, 10 LBS', 9.99, 87, '2023-06-28', 'in-stock'),
(2004, 'NuTrail Keto Nut Granola Blueberry Cinnamon 2-Pack (22 oz each)', 28.99, 63, '2023-08-14', 'in-stock'),
(2005, 'NuTrail Keto Nut Granola Honey Nut 2-pack (22 oz. each)', 36.99, 6, '2023-10-29', 'in-stock'),
(2006, 'Quaker, Oats Old Fashioned Oatmeal, 10 lbs', 14.99, 13, '2023-07-07', 'in-stock'),
(2007, 'Cinnamon, Toast Crunch Cereal, 49.5 oz', 9.99, 90, '2023-08-13', 'in-stock'),
(2008, 'Kirkland Signature Organic Ancient Grain Granola, 35.3 oz', 10.49, 60, '2023-10-06', 'in-stock'),
(2009, 'Quaker Instant Oatmeal Cups, Variety Pack, 19.8 oz., 12-Count', 12.99, 98, '2023-07-27', 'in-stock'),
(2010, 'Idaho Spuds, Golden Grill Hashbrown Potatoes, 33.1 oz', 9.49, 40, '2023-11-17', 'in-stock'),
(2011, 'Kelloggs, Special K Red Berries Cereal, 43 oz', 12.49, 8, '2023-06-16', 'in-stock'),
(2012, 'General Mills Cereal Cup, Variety Pack, 12-count', 10.99, 35, '2023-02-27', 'in-stock'),
(2013, 'Krusteaz, Complete Buttermilk Pancake Mix, 10 lbs', 9.99, 1, '2023-08-15', 'in-stock'),
(2014, 'Quaker, Instant Oatmeal, Variety Pack, 1.51 oz, 52-Count', 11.99, 69, '2023-07-12', 'in-stock'),
(2015, 'General Mills, Cheerios Cereal, 20.35 oz, 2-Count', 9.99, 18, '2023-02-10', 'in-stock'),
(2016, 'Kelloggs Cereal Mini Boxes, Variety Pack, 25-count', 11.99, 70, '2023-12-17', 'in-stock'),
(2017, 'Kelloggs Frosted Flakes Cereal, 30.95 oz, 2-count', 10.99, 45, '2023-11-18', 'in-stock'),
(2018, 'Bisquick, Pancake & Baking Mix, 96 oz', 10.99, 4, '2023-12-18', 'in-stock'),
(2019, 'Kelloggs Cereal Cups, Family Variety Pack, 12-count', 12.69, 45, '2023-04-17', 'in-stock'),
(2020, 'Bobs Red Mill Organic Quick Cooking Steel Cut Oats, 7 lbs.', 14.99, 34, '2023-12-02', 'in-stock');

INSERT INTO floral (id, name, price, stock, status) VALUES
(3000, '50-stem White Roses', 49.99, 31, 'in-stock'),
(3001, '100-stem Babys Breath', 74.99, 66, 'in-stock'),
(3002, 'Valentines Day Pre-Order Hugs and Kisses Arrangement', 59.99, 38, 'in-stock'),
(3003, 'Blushing Beauty Arrangement', 54.99, 20, 'in-stock'),
(3004, 'Valentines Day Pre-Order 50-stem Red Roses', 64.99, 17, 'in-stock'),
(3005, 'Valentines Day Pre-Order 50-stem Shades of Pink Roses', 64.99, 64, 'in-stock'),
(3006, 'Birthday Full of Happiness Floral Arrangement', 46.99, 74, 'in-stock'),
(3007, '50-stem Red Roses', 49.99, 79, 'in-stock'),
(3008, 'Valentines Day Pre-Order Red Romance Arrangement', 69.99, 75, 'in-stock'),
(3009, 'Truly Sweet Floral Arrangement', 59.99, 76, 'in-stock'),
(3010, '50-stem Light Pink Roses', 49.99, 63, 'in-stock'),
(3011, 'Valentines Day Pre-Order 50-stem Lavender Roses', 64.99, 22, 'in-stock'),
(3012, 'Inspire Floral Arrangement', 54.99, 63, 'in-stock'),
(3013, 'Tranquility Vase Arrangement', 49.99, 13, 'in-stock'),
(3014, 'Love You More Floral Arrangement', 55.99, 7, 'in-stock'),
(3015, 'Passion Vase Arrangement', 49.99, 26, 'in-stock'),
(3016, '24-stem Hydrangeas', 59.99, 75, 'in-stock'),
(3017, 'Mountain Bouquet Event Collection, 10-count', 99.99, 9, 'in-stock'),
(3018, 'Timeless Romance Floral Arrangement', 59.99, 35, 'in-stock'),
(3019, 'Valentines Day Pre-Order 50-stem Red & White Roses', 64.99, 93, 'in-stock'),
(3020, '50-stem Red & White Roses', 49.99, 76, 'in-stock'),
(3021, 'Bountiful Garden Bouquet', 43.99, 52, 'in-stock'),
(3022, '115-stem Floral Variety Combination', 99.99, 33, 'in-stock'),
(3023, 'Day Dream Vase Arrangement', 49.99, 91, 'in-stock'),
(3024, 'Mini Floral Centerpieces, 9-count', 109.99, 63, 'in-stock'),
(3025, '6 Wedding Runner, 4-pack', 109.99, 85, 'in-stock'),
(3026, 'Valentines Day Forever Roses', 129.99, 60, 'in-stock'),
(3027, '50-stem Lavender Roses', 49.99, 46, 'in-stock'),
(3028, 'Sunset Bliss Floral Arrangement', 56.99, 79, 'in-stock'),
(3029, '100-stem Fillers and Greens', 64.99, 41, 'in-stock'),
(3030, 'Valentines Day Cherish Forever Arrangement', 59.99, 44, 'in-stock'),
(3031, 'Birthday Celebration Floral Arrangement', 49.99, 97, 'in-stock'),
(3032, '100-stem White and Green Fillers', 69.99, 6, 'in-stock'),
(3033, '50-stem Shades of Pink Quad Roses', 49.99, 15, 'in-stock'),
(3034, 'Elegance Floral Arrangement', 46.99, 46, 'in-stock'),
(3035, '100-stem Carnations', 59.99, 45, 'in-stock'),
(3036, '50-stem Yellow Roses', 49.99, 28, 'in-stock'),
(3037, 'Valentines Day Pre-Order 50-stem Hot Pink / Light Pink Roses', 64.99, 13, 'in-stock'),
(3038, 'Mystical Garden Floral Arrangement', 57.99, 30, 'in-stock'),
(3039, 'Sunflower Sunshine Floral Arrangement', 56.99, 52, 'in-stock'),
(3040, '50-stem Hot Pink Roses', 49.99, 15, 'in-stock'),
(3041, '100-stem Assorted Green Fillers', 69.99, 13, 'in-stock'),
(3042, 'Get Well Wishes Floral Arrangement', 49.99, 6, 'in-stock'),
(3043, 'Fleur Floral Arrangement', 42.99, 35, 'in-stock'),
(3044, 'Fleur Vibrant Floral Arrangement', 43.99, 32, 'in-stock'),
(3045, 'Valentines Day Pre-Order Endless Love', 59.99, 69, 'in-stock'),
(3046, 'Fresh Wedding Garland', 109.99, 48, 'in-stock'),
(3047, 'Island Breeze Bouquet', 58.99, 52, 'in-stock'),
(3048, '80-stem Alstroemeria', 52.99, 23, 'in-stock'),
(3049, 'Thinking of You Floral Arrangement', 52.99, 100, 'in-stock'),
(3050, 'Valentines Day Pre-Order Red, White & Pink Romance Arrangement', 69.99, 4, 'in-stock'),
(3051, '120-stem Ranunculus', 179.99, 32, 'in-stock'),
(3052, 'Rose Petals', 74.99, 71, 'in-stock'),
(3053, 'White Garden Floral Arrangement', 45.99, 39, 'in-stock'),
(3054, '40-stem Sunflowers', 59.99, 65, 'in-stock'),
(3055, '40-stem Mini Green Hydrangeas', 64.99, 77, 'in-stock'),
(3056, 'Valentines Day Pre-Order Garden of Love Bouquet', 49.99, 78, 'in-stock'),
(3057, '60-stem Gerberas', 69.99, 73, 'in-stock'),
(3058, 'Valentines Day Pre-Order Red and White Romance Arrangement', 69.99, 63, 'in-stock'),
(3059, 'Valentines Day Pre-Order Mai Tai Tropical Bouquet', 56.99, 76, 'in-stock'),
(3060, 'Tranquil Garden Bouquet', 43.99, 59, 'in-stock'),
(3061, 'Bright and Beautiful Birthday Arrangement', 45.99, 94, 'in-stock'),
(3062, '30-stem Calla Lilies and 75-stem Roses', 119.99, 78, 'in-stock'),
(3063, 'Valentines Day Magical Love Arrangement', 59.99, 50, 'in-stock'),
(3064, 'Valentines Day Perfect Love', 49.99, 86, 'in-stock'),
(3065, 'Wildflower Floral Arrangement', 46.99, 22, 'in-stock'),
(3066, 'Valentines Day Pre-Order 50-stem White Roses', 64.99, 66, 'in-stock');

INSERT INTO Candy (id, name, price, stock, expiry, status) VALUES
(4000, 'Kirkland Signature Almonds, Milk Chocolate, 3 lb', 16.99, 45, '2024-01-03', 'in-stock'),
(4001, 'Kirkland Signature Raisins, Milk Chocolate, 3.4 lb', 15.99, 62, '2023-07-26', 'in-stock'),
(4002, 'Kinder Joy Egg, .7 oz, 12-count', 16.99, 80, '2023-01-23', 'in-stock'),
(4003, 'Kirkland Signature All Chocolate Bag, 90 oz,', 22.99, 26, '2023-06-16', 'in-stock'),
(4004, 'Motts Fruit Snacks, Assorted Fruit, 0.8 oz, 90-count', 10.99, 51, '2023-02-04', 'in-stock'),
(4005, 'Kinder Chocolate Mini, Milk Chocolate Candy Bar, 21.2 Oz Bulk', 11.99, 79, '2023-07-04', 'in-stock'),
(4006, 'Reeses Pieces, Peanut Butter, 48 oz', 15.99, 62, '2023-04-15', 'in-stock'),
(4007, 'Hersheys Milk Chocolate with Almonds, King Size, 18-count', 34.99, 21, '2023-12-12', 'in-stock'),
(4008, 'Utah Truffles Dark Chocolate Truffles With Sea Salt 16 oz, 2-pack', 29.99, 38, '2023-05-20', 'in-stock'),
(4009, 'Kelloggs Rice Krispies Treats, 0.78 oz, 60-count', 11.99, 6, '2024-01-08', 'in-stock'),
(4010, 'E.Frutti Gummi Pizza, 48-Count', 14.99, 58, '2023-03-03', 'in-stock'),
(4011, 'Mars Minis Chocolate Favorites, Variety Pack, 240-count', 24.99, 64, '2023-08-17', 'in-stock'),
(4012, 'Hersheys Milk Chocolate With Almonds, 1.45 oz, 36-count', 39.99, 62, '2023-08-15', 'in-stock'),
(4013, 'Utah Truffle Milk Chocolate Mint Truffles 16 oz, 2-pack', 29.99, 47, '2023-12-05', 'in-stock'),
(4014, 'Lindt Lindor Chocolate Truffles, Assorted Flavors, 21.2 oz', 15.99, 27, '2023-11-08', 'in-stock'),
(4015, 'Charms Mini Pops, Assorted Flavors, 400-count', 11.99, 32, '2023-06-11', 'in-stock'),
(4016, 'Chocolate Moonshine Co. Belgian Artisan Chocolate Caramel Biscuit Bark, 20 oz.', 44.99, 2, '2023-04-28', 'in-stock'),
(4017, 'M&Ms, Snickers and More Chocolate Candy Bars, Variety Pack, 30-count', 31.99, 84, '2023-09-27', 'in-stock'),
(4018, 'Ferrero Rocher, Milk Chocolate Hazelnut Candy, 21.2 oz, 48 Count', 17.99, 62, '2023-02-14', 'in-stock'),
(4019, 'Bouchard Belgian Napolitains Premium Dark Chocolate 32 oz,  2-pack', 49.99, 51, '2023-12-19', 'in-stock'),
(4020, 'Ghirardelli Chocolate Squares Premium Chocolate Assortment, 23.8 oz', 18.99, 32, '2023-05-28', 'in-stock'),
(4021, 'Ferrero Rocher, Milk Chocolate Hazelnut Candy, 1.3 oz, 3-count, 12-pack', 14.99, 100, '2023-04-04', 'in-stock'),
(4022, 'Godiva Masterpieces Assortment of Legendary Milk Chocolate 14.9 oz 4-Pack', 54.99, 94, '2023-12-17', 'in-stock'),
(4023, 'Charms Blow Pop, 0.65 oz, Assorted Bubble Gum Filled Pops, 100-count', 15.99, 73, '2023-10-27', 'in-stock'),
(4024, 'Kiss My Keto Gummy Candy Fish Friends, 6-count, 2-pack', 32.99, 87, '2023-01-29', 'in-stock'),
(4025, 'Chocolate Moonshine Co. Belgian Artisan Black Cherry Bourbon Bark, 20 oz.', 44.99, 38, '2023-05-30', 'in-stock'),
(4026, 'Kiss My Keto Gummies Tropical Rings, 6-count, 2-pack', 32.99, 85, '2023-09-27', 'in-stock'),
(4027, 'Topps Jumbo Push Pops, Variety Pack, 1.06 oz, 18-Count', 28.99, 52, '2023-04-20', 'in-stock'),
(4028, 'Reeses Peanut Butter Cups, Miniatures, 0.31 oz, 105-count', 12.99, 40, '2023-10-13', 'in-stock'),
(4029, 'Dove Milk Chocolate Candy Bars, Full Size, 1.44 oz, 18-count', 19.99, 32, '2023-09-06', 'in-stock'),
(4030, 'Ice Breakers Ice Cubes Sugar Free Gum, Arctic Grape, 40 pieces, 4 ct, 160 pieces', 15.49, 71, '2023-07-22', 'in-stock'),
(4031, 'Altoids Smalls Breath Mints, Sugar Free Peppermint, 0.37 oz, 9-count', 10.99, 37, '2023-09-03', 'in-stock'),
(4032, 'Kirkland Signature Funhouse Treats, Variety Pack, 92 oz', 21.99, 71, '2023-06-13', 'in-stock'),
(4033, 'Godiva Assorted Chocolate Gold Collection Gift Box 36-pieces', 46.99, 50, '2023-11-25', 'in-stock'),
(4034, 'Starburst Original Chewy Candy, 54 oz Jar', 11.49, 57, '2023-06-06', 'in-stock'),
(4035, 'Reeses Peanut Butter Cups, Milk Chocolate, 1.5 oz, 36-count', 39.99, 80, '2023-09-21', 'in-stock'),
(4036, 'Hersheys Kisses, Milk Chocolate, 56 oz', 16.39, 82, '2023-05-25', 'in-stock'),
(4037, 'Haribo Goldbears Gummi Candy, 2 oz, 24-count', 19.99, 76, '2023-02-13', 'in-stock'),
(4038, 'Ice Breaker Duos Mints, Strawberry and Mint, 1.3 oz, 8-count', 17.49, 85, '2023-11-15', 'in-stock'),
(4039, 'Skittles and Starburst Chewy Candy, Variety Pack, Full Size, 30-count', 29.99, 85, '2023-06-23', 'in-stock'),
(4040, 'Heath Bar, 1.4 oz, 18-count', 19.99, 52, '2023-03-12', 'in-stock'),
(4041, 'Fruit Gushers Fruit Flavored Snacks, Variety Pack, 0.8 oz, 42-Count', 15.99, 89, '2023-09-15', 'in-stock'),
(4042, 'Nutella & GO! Hazelnut and Cocoa Spread With Pretzels, 1.9 oz, 16 Pack', 18.99, 36, '2023-06-23', 'in-stock'),
(4043, 'Ice Breakers Cube Peppermint Gum, 40 pieces, 4-count', 14.99, 26, '2023-12-30', 'in-stock'),
(4044, 'AirHeads, 0.55 oz, Variety Pack, 90-count', 15.99, 100, '2023-02-21', 'in-stock'),
(4045, 'Sanders Dark Chocolate Sea Salt Caramels 36 oz., 2-pack', 34.99, 44, '2023-01-23', 'in-stock'),
(4046, 'Original Gourmet Lollipops, Variety, 50-count', 17.99, 34, '2023-08-21', 'in-stock'),
(4047, 'M&Ms Milk Chocolate Candy, 62 oz Jar', 18.99, 44, '2023-08-09', 'in-stock'),
(4048, 'Mentos Pure Fresh Sugar Free Gum, Fresh Mint, 15 Pieces, 10-count', 13.99, 48, '2023-03-10', 'in-stock'),
(4049, 'Hersheys Miniatures, Variety Pack, 56 oz', 19.99, 51, '2023-04-12', 'in-stock'),
(4050, 'Hersheys Nuggets Assortment, Variety Pack, 145-count', 16.39, 57, '2023-10-01', 'in-stock'),
(4051, 'Hersheys Milk Chocolate, 1.55 oz, 36-count', 39.99, 12, '2023-10-11', 'in-stock'),
(4052, 'Pocky Chocolate Biscuit Stick, 1.41 oz, 10-count', 9.99, 81, '2024-01-11', 'in-stock'),
(4053, 'Nerds Candy, Grape and Strawberry, 1.65 oz, 24-Count', 19.99, 27, '2023-03-20', 'in-stock'),
(4054, 'Extra Sugar Free Chewing Gum, Mint Variety Pack, 15 Sticks, 18-Count', 17.99, 73, '2023-12-11', 'in-stock'),
(4055, 'Kinder Bueno Mini, Chocolate and Hazelnut Cream Chocolate Bars, 17.1 oz', 11.99, 90, '2023-05-03', 'in-stock'),
(4056, 'Sour Punch Twists, Variety, 180-count', 16.99, 95, '2023-07-25', 'in-stock'),
(4057, 'Ice Breakers Sugar Free Mints, Wintergreen, 1.5 oz, 8-count', 16.99, 82, '2023-10-29', 'in-stock'),
(4058, 'Extra Sugar Free Chewing Gum, Sweet Watermelon, Slim Pack, 15 Sticks, 10-Count', 11.49, 37, '2024-01-12', 'in-stock'),
(4059, 'Hersheys Nuggets, Milk Chocolate, 52 oz, 145 pieces', 19.99, 92, '2023-12-18', 'in-stock'),
(4060, 'Sour Punch Straws, Strawberry, 2 oz, 24-count', 17.99, 38, '2023-09-24', 'in-stock'),
(4061, 'Twix Share Size Chocolate Caramel Cookie Candy Bar, 3.02 oz, 24-count', 44.99, 12, '2023-07-24', 'in-stock'),
(4062, 'Trident Sugar Free Gum, Cinnamon, 14 Pieces, 15-count', 10.99, 67, '2023-10-05', 'in-stock'),
(4063, 'E.Frutti Gummi Hot Dog, 0.35 oz, 60-count', 8.99, 84, '2023-02-24', 'in-stock'),
(4064, 'Trolli Sour Brite Crawlers Candy, 5 oz, 16-count', 24.99, 99, '2023-04-04', 'in-stock'),
(4065, 'Swedish Fish Soft & Chewy Candy, 2 oz, 24-count', 24.99, 80, '2023-01-16', 'in-stock'),
(4066, 'Haribo Goldbears Gummi Candy, Mini Bags, 0.4 oz, 125-count', 16.49, 67, '2023-04-20', 'in-stock'),
(4067, 'Life Savers Breath Mints Hard Candy, Wint-O-Green, 53.95 oz Bag', 10.49, 15, '2023-09-21', 'in-stock'),
(4068, 'Hi-Chew Fruit Chews, Original Mix, 30 oz', 11.99, 63, '2023-07-17', 'in-stock');

INSERT INTO cleaning (id, name, price, stock, status) VALUES
(5000, 'Tide Pods HE Laundry Detergent Pods, Free & Gentle, 152-count', 28.99, 21, 'in-stock'),
(5001, 'Tide Pods HE Laundry Detergent Pods, Spring Meadow, 156-count', 28.99, 100, 'in-stock'),
(5002, 'Tide Ultra Concentrated Liquid Laundry Detergent, 152 Loads, 170 fl oz', 24.99, 87, 'in-stock'),
(5003, 'Swiffer Duster Heavy Duty Dusting Kit, 1 Handle + 17 Refills', 15.99, 19, 'in-stock'),
(5004, 'Swiffer Sweeper Heavy Duty Dry Sweeping Cloth Refills, 50-count', 15.99, 26, 'in-stock'),
(5005, 'Gain Ultra Concentrated +AromaBoost HE Liquid Laundry Detergent, Original, 159 Loads, 208 fl oz', 19.49, 18, 'in-stock'),
(5006, 'Dawn Platinum Advanced Power Liquid Dish Soap, 90 fl oz', 12.09, 32, 'in-stock'),
(5007, 'Cascade Platinum Plus Dishwasher Detergent Pacs, Fresh, 81-count', 19.99, 62, 'in-stock'),
(5008, 'Bounce Dryer Sheets, Outdoor Fresh, 160-count, 2-pack', 10.79, 1, 'in-stock'),
(5009, 'Lysol Disinfecting Wipes, Variety Pack, 95-count, 4-pack', 16.99, 30, 'in-stock'),
(5010, 'Downy Unstopables In-Wash Scent Booster Beads, Fresh, 34 oz', 17.89, 25, 'in-stock'),
(5011, 'Downy Ultra Concentrated HE Fabric Softener, April Fresh, 251 Loads, 170 fl oz', 13.99, 80, 'in-stock'),
(5012, 'Nellies Laundry Soda, 400 Loads', 42.99, 35, 'in-stock'),
(5013, 'Tide Advanced Power with Oxi Liquid Laundry Detergent, Original, 78 Loads, 145 fl oz', 23.99, 9, 'in-stock'),
(5014, 'Tide HE Ultra Oxi Powder Laundry Detergent, Original, 143 Loads, 250 oz', 34.99, 38, 'in-stock'),
(5015, 'Tide Pods with Ultra Oxi HE Laundry Detergent Pods, 104-count', 28.79, 49, 'in-stock'),
(5016, 'Downy Fresh Protect In-Wash Odor Defense Scent Beads, April Fresh, 34 oz', 21.49, 67, 'in-stock'),
(5017, 'Nellies Laundry Starter Pack', 54.99, 73, 'in-stock'),
(5018, 'Kirkland Signature Ultra Clean HE Liquid Laundry Detergent, 146 loads, 194 fl oz', 21.99, 70, 'in-stock'),
(5019, 'Kirkland Signature Ultra Clean Free & Clear HE Liquid Laundry Detergent, 146 loads, 194 fl oz', 19.99, 32, 'in-stock'),
(5020, 'Nellies Baby Laundry Soda, 500 Loads', 89.99, 83, 'in-stock'),
(5021, 'Kirkland Signature Ultra Clean HE Laundry Detergent Pacs, 152-count', 22.99, 2, 'in-stock'),
(5022, 'Scotch-Brite Zero Scratch Sponge, 24-count', 14.49, 77, 'in-stock'),
(5023, 'Nellies Laundry Nuggets, 350 Loads', 84.99, 53, 'in-stock'),
(5024, 'Nellies Laundry Soda, 800 Loads', 89.99, 92, 'in-stock'),
(5025, 'Scotch-Brite Heavy Duty Sponge, 24-count', 14.49, 70, 'in-stock'),
(5026, 'ECOS HE Laundry Detergent Sheets, Free & Clear, 100 Loads, 100 Sheets, 2-count', 38.99, 40, 'in-stock'),
(5027, 'ECOS HE Liquid Laundry Detergent, Magnolia & Lily, 210 Loads, 210 fl oz, 2-count', 38.99, 18, 'in-stock'),
(5028, 'Kirkland Signature Platinum Performance UltraShine Dishwasher Detergent Pacs, 115-count', 13.99, 43, 'in-stock'),
(5029, 'Kirkland Signature 10-Gallon Wastebasket Liner, Clear, 500-count', 13.99, 67, 'in-stock'),
(5030, 'Boulder Clean Laundry Detergent Sheets, Free & Clear, 160 Loads, 80 Sheets', 29.99, 61, 'in-stock'),
(5031, 'Arm & Hammer Plus OxiClean Max HE Liquid Laundry Detergent, Fresh, 200 Loads, 200 fl oz', 17.99, 1, 'in-stock'),
(5032, 'All Free & Clear Plus+ HE Liquid Laundry Detergent, 158 loads, 237 fl oz', 16.99, 86, 'in-stock'),
(5033, 'simplehuman Custom Fit Liners, 300-pack', 32.99, 36, 'in-stock'),
(5034, 'Cascade Advanced Power Liquid Dishwasher Detergent, Fresh Scent, 125 fl oz', 12.99, 32, 'in-stock'),
(5035, 'ECOS HE Liquid Laundry Detergent, Free & Clear, 210 Loads, 210 fl oz, 2-count', 38.99, 86, 'in-stock'),
(5036, 'Tide Ultra Concentrated with Downy HE Liquid Laundry Detergent, April Fresh, 110 loads, 150 fl oz', 22.99, 9, 'in-stock'),
(5037, 'Clorox Disinfecting Wipes, Variety Pack, 85-count, 5-pack', 22.99, 54, 'in-stock'),
(5038, 'Cascade Complete Dishwasher Detergent Actionpacs, 90-count', 20.89, 15, 'in-stock'),
(5039, 'The Unscented Company Liquid Laundry Detergent Refill Box, 400 Loads, 337.92 fl oz', 44.99, 32, 'in-stock'),
(5040, 'MyEcoWorld 13-gallon Compostable Food Waste Bag, 72-count', 36.99, 43, 'in-stock'),
(5041, 'Kirkland Signature Ultra Shine Liquid Dish Soap, Fresh, 90 fl oz', 9.79, 94, 'in-stock'),
(5042, 'MyEcoWorld 3-gallon Compostable Food Waste Bag, 150-count', 29.89, 66, 'in-stock'),
(5043, 'Tide Pods with Downy HE Laundry Detergent Pods, April Fresh, 104-count', 29.99, 49, 'in-stock'),
(5044, 'The Unscented Company HE Liquid Laundry Detergent Bottle & Refill Box, 478 Loads, 403.82 fl oz', 54.99, 98, 'in-stock'),
(5045, 'Nellies Dish Butter Bundle', 39.99, 97, 'in-stock'),
(5046, 'Lysol HE Laundry Sanitizer, Crisp Linen, 150 fl oz', 19.99, 97, 'in-stock'),
(5047, 'Cascade Platinum Dishwasher Detergent Actionpacs, 92-count', 24.99, 15, 'in-stock'),
(5048, 'Kirkland Signature Antibacterial Liquid Dish Soap, Green Apple, 90 fl oz', 9.49, 86, 'in-stock'),
(5049, 'Clorox Clean-Up All Purpose Cleaner with Bleach, Original, 32 oz & 180 oz Refill', 22.99, 7, 'in-stock'),
(5050, 'Boulder Clean Liquid Laundry Detergent, Citrus Breeze, 200 loads, 200 fl oz', 24.99, 54, 'in-stock'),
(5051, 'Finish Powerball Quantum Dishwasher Detergent Tabs, 100-count', 22.99, 96, 'in-stock'),
(5052, 'The Unscented Company Liquid Dish Soap Refill Box, 337.92 fl oz', 41.99, 92, 'in-stock'),
(5053, 'Kirkland Signature Flex-Tech 13-Gallon Kitchen Trash Bag, 200-count', 19.99, 95, 'in-stock'),
(5054, 'Palmolive Ultra Strength Liquid Dish Soap, 102 fl oz', 10.99, 9, 'in-stock'),
(5055, 'The Unscented Company Laundry Tabs, 300 Loads', 74.99, 41, 'in-stock'),
(5056, 'Scotch-Brite Lint Roller, 95-count, 5-pack', 17.89, 17, 'in-stock'),
(5057, 'Clear-Touch Food Handling Nitrile Gloves, 500-count', 29.99, 9, 'in-stock'),
(5058, 'Nellies Wow Mop Starter Kit', 199.99, 36, 'in-stock'),
(5059, 'O-Cedar EasyWring Spin Mop & Bucket System with 3 Refills', 42.99, 68, 'in-stock'),
(5060, 'The Unscented Company Liquid Dish Soap Bottle & Refill Box, 363.22 fl oz', 49.99, 28, 'in-stock'),
(5061, 'Kirkland Signature Fabric Softener Sheets, 250-count, 2-pack', 11.99, 75, 'in-stock'),
(5062, 'Windex Original Glass Cleaner, 32 fl oz & 169 fl oz Refill', 14.99, 56, 'in-stock'),
(5063, 'Fabuloso Multi-Purpose Cleaner, Lavender, 210 fl oz', 12.49, 15, 'in-stock'),
(5064, 'Simple Green All-Purpose Cleaner, 32 fl oz + 140 fl oz Refill', 10.99, 53, 'in-stock');

INSERT INTO coffee (id, name, price, stock, expiry, status) VALUES
(6000, 'Kirkland Signature Coffee Organic Pacific Bold K-Cup Pod, 120-count', 31.99, 87, '2023-07-22', 'in-stock'),
(6001, 'Kirkland Signature Coffee Organic Summit Roast K-Cup Pod, 120-count', 31.99, 67, '2023-08-22', 'in-stock'),
(6002, 'Kirkland Signature Coffee Organic Breakfast Blend K-Cup Pod, 120-count', 31.99, 45, '2023-02-21', 'in-stock'),
(6003, 'Folgers Classic Roast Ground Coffee, Medium, 43.5 oz', 10.29, 33, '2023-10-16', 'in-stock'),
(6004, 'Starbucks Dark French Roast K-Cup, 72-count', 42.99, 58, '2023-01-28', 'in-stock'),
(6005, 'Kirkland Signature Coffee Organic House Decaf K-Cup Pod, 120-count', 31.99, 79, '2023-01-30', 'in-stock'),
(6006, 'Kirkland Signature Organic Ethiopia Whole Bean Coffee, 2 lbs', 19.99, 8, '2024-01-07', 'in-stock'),
(6007, 'Kirkland Signature Whole Bean Coffee, French Roast, 2.5 lbs', 13.99, 66, '2023-12-10', 'in-stock'),
(6008, 'Kirkland Signature Organic Colombian Decaf Whole Bean Coffee, 2 lbs', 18.99, 96, '2023-12-08', 'in-stock'),
(6009, 'Kirkland Signature Organic Sumatra Whole Bean Coffee, 2 lbs, 2-pack', 42.99, 7, '2023-02-26', 'in-stock'),
(6010, 'Starbucks Coffee Single Origin Sumatra Dark Roast K-Cup, 72-count', 42.99, 95, '2023-10-07', 'in-stock'),
(6011, 'Kirkland Signature Rwandan Coffee 3 lb, 2-pack', 37.99, 19, '2023-02-11', 'in-stock'),
(6012, 'Peets Coffee Major Dickasons Blend Coffee, Dark Roast, Whole Bean, 2 lbs', 18.99, 5, '2023-04-11', 'in-stock'),
(6013, 'Kirkland Signature House Blend Coffee, Medium Roast, Whole Bean, 2.5 lbs', 17.99, 62, '2023-01-18', 'in-stock'),
(6014, 'Peets Coffee Decaf House Blend K-Cup Pod, 75-count', 42.99, 82, '2023-12-01', 'in-stock'),
(6015, 'Kirkland Signature Sumatran Whole Bean Coffee 3 lb, 2-pack', 44.99, 27, '2023-07-22', 'in-stock'),
(6016, 'Starbucks Pike Place Medium Roast K-Cup, 72-count', 42.99, 77, '2023-01-28', 'in-stock'),
(6017, 'Kirkland Signature Colombian Supremo Coffee, Whole Bean, 3 lbs', 20.99, 23, '2023-10-01', 'in-stock'),
(6018, 'Peets Coffee Major Dickasons Blend K-Cup Pod, 75-count', 42.99, 82, '2023-03-25', 'in-stock'),
(6019, 'Peets Coffee Major Dickasons Blend Whole Bean, 10.5 oz Bags, 6-pack', 42.99, 24, '2023-04-20', 'in-stock'),
(6020, 'Kirkland Signature Costa Rica Coffee 3 lb, 2-pack', 37.99, 27, '2023-09-21', 'in-stock'),
(6021, 'Lavazza Caffe Espresso 100% Premium Arabica Coffee, Whole Bean, 2.2 lbs', 17.99, 60, '2023-04-24', 'in-stock'),
(6022, 'Kirkland Signature Espresso Blend Coffee, Dark Roast, Whole Bean, 2.5 lbs', 18.99, 67, '2023-08-23', 'in-stock'),
(6023, 'Starbucks Coffee Caffe Verona Dark Roast K-Cup Pod, 72-count', 42.99, 47, '2023-11-15', 'in-stock'),
(6024, 'Kirkland Signature USDA Organic Whole Bean Blend 2 lb, 2-pack', 29.99, 6, '2023-06-02', 'in-stock'),
(6025, 'Starbucks Coffee Veranda Blend Blonde Roast K-Cup, 72-count', 42.99, 39, '2023-04-26', 'in-stock'),
(6026, 'Kirkland Signature 100% Colombian Coffee, Dark Roast, 3 lbs', 14.99, 26, '2023-02-13', 'in-stock'),
(6027, 'Kirkland Signature Decaf House Blend Coffee, Medium Roast, Whole Bean, 2.5 lbs', 19.99, 6, '2023-04-23', 'in-stock'),
(6028, 'Lavazza Espresso Gran Crema Whole Bean Coffee, Medium, 2.2 lbs', 17.99, 54, '2023-05-20', 'in-stock'),
(6029, 'San Francisco Bay Coffee French Roast OneCup, 100-count', 35.99, 44, '2024-01-04', 'in-stock'),
(6030, 'Kirkland Signature Decaffeinated Coffee, Dark Roast, 3 lbs', 16.99, 47, '2023-06-02', 'in-stock'),
(6031, 'Nescafe Tasters Choice Instant Coffee, House Blend, 14 oz', 18.99, 87, '2023-01-30', 'in-stock'),
(6032, 'Mayorga Buenos Dias, USDA Organic, Light Roast, Whole Bean Coffee, 2lb, 2-pack', 39.99, 97, '2023-11-04', 'in-stock'),
(6033, 'Copper Moon Coffee Dark Sky Whole Bean Coffee, Dark, 5 lbs', 28.99, 13, '2023-02-28', 'in-stock'),
(6034, 'Peets Coffee Org French Roast K-Cup Pod, 75-count', 42.99, 18, '2023-01-27', 'in-stock'),
(6035, 'Peets Coffee Decaf Major Dickasons Ground, 10.5 oz Bags, 6-pack', 42.99, 30, '2023-03-03', 'in-stock'),
(6036, 'Ruta Maya Organic Jiguani Whole Bean Coffee 5 lb', 47.99, 84, '2023-10-13', 'in-stock'),
(6037, 'Peets Coffee Big Bang Ground, 10.5 oz Bags, 6-pack', 42.99, 66, '2023-09-12', 'in-stock'),
(6038, 'Dunkin Donuts Original Blend, 45 oz', 25.99, 64, '2023-11-20', 'in-stock'),
(6039, 'Tim Hortons Coffee Original Blend K-Cup Pod, 110-count', 44.99, 3, '2023-03-11', 'in-stock'),
(6040, 'Joses Vanilla Nut Whole Bean Coffee 3 lb, 2-pack', 44.99, 33, '2023-09-02', 'in-stock'),
(6041, 'The Original Donut Shop Coffee K-Cup Pod, 100-count', 48.99, 35, '2023-06-14', 'in-stock'),
(6042, 'Cometeer Dark Roast Coffee, 56 Frozen Capsules', 99.99, 61, '2023-03-01', 'in-stock'),
(6043, 'Dunkin Donuts, Original Blend, Medium Roast, K-Cup Pods, 72ct', 41.99, 2, '2023-03-14', 'in-stock'),
(6044, 'Newmans Own Organics Coffee Special Blend K-Cup Pod, 100-count', 48.99, 54, '2024-01-05', 'in-stock'),
(6045, 'Nestle Coffee-Mate Liquid Creamer, French Vanilla, 180-count', 14.99, 87, '2023-04-18', 'in-stock'),
(6046, 'Kirkland Signature 100% Colombian Coffee, Dark Roast, 1.75 oz, 42-count', 28.99, 86, '2023-08-06', 'in-stock'),
(6047, 'Caribou Coffee Caribou Blend K-Cup Pod, 100-count', 48.99, 8, '2023-10-06', 'in-stock'),
(6048, 'Ruta Maya Organic Medium Roast Whole Bean Coffee 5 lb', 44.99, 100, '2023-12-09', 'in-stock'),
(6049, 'San Francisco Bay Organic Rainforest Blend Whole Bean Coffee 3 lbs, 2-pack', 56.99, 3, '2023-10-18', 'in-stock'),
(6050, 'Joses 100% Colombia Supremo Whole Bean Coffee, Medium, 3lbs, 2-pack', 44.99, 1, '2023-07-25', 'in-stock'),
(6051, 'Starbucks Espresso, Espresso & Cream, 6.5 fl oz, 12-count', 22.99, 26, '2023-08-04', 'in-stock'),
(6052, 'Joses 100% Organic Mayan Whole Bean Coffee 2.5 lb, 2-pack', 44.99, 6, '2023-05-26', 'in-stock'),
(6053, 'San Francisco French Roast Whole Bean Coffee 3 lb, 2-pack', 34.99, 54, '2023-10-28', 'in-stock'),
(6054, 'Copper Moon Costa Rica Blend, Medium Roast Whole Bean Coffee, 2 lb Bags, 2-Pack', 34.99, 14, '2023-03-06', 'in-stock'),
(6055, 'Starbucks VIA Instant Colombia Coffee, Medium Roast, 26-count', 19.99, 94, '2023-12-30', 'in-stock'),
(6056, 'Mayorga Cafe Cubano Roast, USDA Organic, Dark Roast, Whole Bean Coffee, 2lb, 2-pack', 39.99, 97, '2023-07-25', 'in-stock'),
(6057, 'Mayorga Decaf Cafe Cubano Roast, USDA Organic, Dark Roast, Whole Bean Coffee, 2lb, 2-pack', 39.99, 9, '2023-12-10', 'in-stock'),
(6058, 'Nestle Coffee-mate Liquid Creamer, Original, 180-count', 12.99, 72, '2023-03-01', 'in-stock'),
(6059, 'San Francisco Bay Coffee Light Roast Cold Brew Coarse Ground Coffee, 28 oz, 2-pack', 39.99, 39, '2023-11-20', 'in-stock'),
(6060, 'Parisi Artisan Coffee Bolivian Organic Blend Whole Bean 2 lb, 2-pack', 36.99, 43, '2023-11-08', 'in-stock'),
(6061, 'Tullys Coffee French Roast K-Cups Pods, 100-count', 48.99, 22, '2023-03-04', 'in-stock'),
(6062, 'Folgers Instant Coffee Classic Roast Coffee, 16 oz', 11.99, 81, '2023-04-09', 'in-stock'),
(6063, 'VitaCup Slim Instant Coffee Packets, Boost Diet & Metabolism, 30-count', 29.99, 16, '2023-05-13', 'in-stock'),
(6064, 'Tullys Coffee Hawaiian Blend K-Cups Packs, 100-count', 48.99, 57, '2023-08-17', 'in-stock'),
(6065, 'Nestle Coffee-mate Coffee Creamer, Hazelnut, Pump Bottle, 50.7 fl oz', 16.99, 37, '2023-11-03', 'in-stock'),
(6066, 'Caffe Vita Coffee Caffe Del Sol Blend Whole Bean, Medium Roast, 2 lb. bags, 2-pack', 59.99, 85, '2023-09-09', 'in-stock'),
(6067, 'San Francisco Bay Decaf French Roast Whole Bean Coffee 2 lb, 2-pack', 34.99, 83, '2023-06-14', 'in-stock'),
(6068, 'Caffe Vita Coffee Theo Blend Whole Bean, Medium-Dark Roast, 2 lb. bags, 2-pack', 59.99, 2, '2023-12-05', 'in-stock'),
(6069, 'Caffe Vita Caffe Luna French Roast Whole Bean, Dark Roast, 2 lb. bags, 2-pack', 59.99, 26, '2023-05-20', 'in-stock'),
(6070, 'Nestle Coffee-mate Powdered Creamer, Original, 56 oz', 10.99, 94, '2023-11-11', 'in-stock');

INSERT INTO deli (id, name, price, stock, expiry, status) VALUES
(7000, 'Tsar Nicoulai Baerii Caviar 2 oz. Gift Set', 99.99, 22, '2023-10-31', 'in-stock'),
(7001, 'Tsar Nicoulai Classic White Sturgeon Caviar 2 oz Gift Set', 119.99, 39, '2023-08-07', 'in-stock'),
(7002, 'Plaza Osetra Farmed Bulgarian Sturgeon Caviar 2 oz, 3-pack', 199.99, 12, '2023-07-07', 'in-stock'),
(7003, 'Giordanos Chicago Frozen 10 Deep Dish Stuffed Pizza, 3-pack', 89.99, 16, '2023-09-19', 'in-stock'),
(7004, 'Tsar Nicoulai Estate White Sturgeon Caviar 4.4 oz', 149.99, 21, '2023-01-17', 'in-stock'),
(7005, 'DArtagnan 13-piece Gourmet Roasting Ham & Luxury Charcuterie Gift Box, 12.5 lbs', 199.99, 72, '2023-05-24', 'in-stock'),
(7006, 'Covap Jamon Iberico Bellota Ham Leg with Stand and Knife, 15.4 lbs.', 649.99, 2, '2023-12-23', 'in-stock'),
(7007, 'Plaza Golden Osetra Caviar Kilo Pack, 35.2 oz', 1999.99, 52, '2023-02-21', 'in-stock'),
(7008, 'Noel Consorcio Serrano Ham Reserva Leg, 14 lbs', 109.99, 91, '2023-11-01', 'in-stock'),
(7009, 'Plaza Osetra Farmed Bulgarian Sturgeon Caviar, 2 oz Gift Set', 124.99, 65, '2023-01-31', 'in-stock'),
(7010, 'DArtagnan 18-month Aged Boneless Spanish Serrano Ham, 9.5 lbs', 249.99, 78, '2023-05-19', 'in-stock'),
(7011, 'Tsar Nicoulai Baerii Caviar 2 oz, 3-pack', 249.99, 87, '2023-08-03', 'in-stock'),
(7012, 'Pacific Plaza Golden Osetra Caviar 2 oz, 2-pack', 279.99, 86, '2023-07-09', 'in-stock'),
(7013, 'Tsar Nicoulai Caviar Tasting Flight Gift Set', 249.99, 19, '2023-07-09', 'in-stock'),
(7014, 'Tsar Nicoulai Estate Classic White Sturgeon Caviar 2 oz, 3-pack', 199.99, 46, '2023-03-18', 'in-stock'),
(7015, 'Plaza Golden Osetra 2 oz Caviar Gift Set', 169.99, 84, '2023-05-14', 'in-stock'),
(7016, 'Plaza Golden Osetra Caviar, 8.8 oz', 549.99, 20, '2023-04-25', 'in-stock'),
(7017, 'Plaza Osetra Kilo Caviar Pack', 1399.99, 100, '2023-02-16', 'in-stock'),
(7018, 'Plaza Osetra Farmed Bulgarian Sturgeon Caviar, 8.8 oz', 379.99, 79, '2023-08-16', 'in-stock'),
(7019, 'Fratelli Beretta Snack Pack, 2.5 oz, 10-pack', 59.99, 80, '2023-01-25', 'in-stock'),
(7020, 'Fratelli Beretta Prosciutto di Parma Boneless, DOP, minimum 14.7 lbs', 249.99, 40, '2023-10-18', 'in-stock');

INSERT INTO household (id, name, price, stock, status) VALUES
(8000, 'Cambro CamSquare 2 Quart Food Storage Container with Lid, 3-count', 18.99, 32, 'in-stock'),
(8001, 'Cambro Square 4-Quart Food Storage Container with Lid, 3-count', 25.99, 89, 'in-stock'),
(8002, 'Cambro Round 2-Quart Food Storage Container with Lid, 3-count', 11.99, 97, 'in-stock'),
(8003, 'Cambro Round 4 Quart Food Storage Container with Lid, 3-count', 12.99, 20, 'in-stock'),
(8004, 'Kirkland Signature Alkaline AA Batteries, 48-count', 17.99, 77, 'in-stock'),
(8005, 'Duracell Coppertop Alkaline AA Batteries, 40-count', 20.99, 19, 'in-stock'),
(8006, 'Kirkland Signature Alkaline AAA Batteries, 48-count', 17.99, 40, 'in-stock'),
(8007, 'Duracell Coppertop Alkaline AAA Batteries, 40-count', 20.99, 100, 'in-stock'),
(8008, 'Duracell 9V Alkaline Batteries, 8-count', 20.99, 71, 'in-stock'),
(8009, 'Duracell D Alkaline Batteries, 14-count', 18.99, 69, 'in-stock'),
(8010, 'Duracell C Alkaline Batteries, 14-count', 18.99, 98, 'in-stock'),
(8011, 'Cambro CamSquare 8 Quart Food Container with Lid, 2-count', 24.99, 26, 'in-stock'),
(8012, 'Russell 10 Cooks Knife, 2-count', 17.99, 25, 'in-stock'),
(8013, 'Tramontina Professional 8 Restaurant Fry Pan, Nonstick Aluminum, 2 pk', 26.99, 65, 'in-stock'),
(8014, 'Tramontina Aluminum Baking Sheet Pan, Quarter Size, 9.5L x 13W, 3 ct', 14.99, 40, 'in-stock'),
(8015, 'Tramontina Professional 12 Restaurant Fry Pan, Nonstick Aluminum', 27.99, 72, 'in-stock'),
(8016, 'Tramontina Professional 10 Restaurant Fry Pan, Nonstick Aluminum, 2 pk', 36.99, 78, 'in-stock'),
(8017, 'Tramontina ProLine Windsor Oval Soup Spoon, Stainless Steel, 36-count', 9.99, 44, 'in-stock'),
(8018, 'Tramontina ProLine Windsor Dinner Knife, Stainless Steel, 36-count', 19.99, 28, 'in-stock'),
(8019, 'Tramontina ProLine Windsor Dinner Fork, Stainless Steel, 36-count', 9.99, 13, 'in-stock'),
(8020, 'Taylor Waterproof Instant Read Food Thermometer, Red', 12.99, 40, 'in-stock'),
(8021, 'Tramontina ProLine Windsor Teaspoon, Stainless Steel, 36-count', 8.49, 83, 'in-stock'),
(8022, 'Winco Cutting Board, 12 x 18 x 1/2 - White', 7.49, 37, 'in-stock'),
(8023, 'BIC Grip 4 Color Ball Pens with 3 Color + Pencil Set, 10-count', 12.99, 62, 'in-stock'),
(8024, 'Nouvelle Legende Ribbed Microfiber Bar Towel, White with Green Stripe, 14 in x 18 in, 12-count', 8.99, 41, 'in-stock'),
(8025, '3M Scotch Precision Ultra Edge 8 Scissor, 3-count', 11.39, 42, 'in-stock'),
(8026, 'Tramontina ProLine 6 in Chefs Cleaver', 22.99, 34, 'in-stock'),
(8027, '3M Scotch Magic Tape, 12-count', 22.99, 73, 'in-stock'),
(8028, 'Scotch Shipping Packaging Tape with Dispenser, Heavy Duty, 1.88 x 19.4 yds, 6-count', 12.99, 73, 'in-stock'),
(8029, 'Winco 8-3/4 Portable Can Opener with Crank Handle, Chrome Plated', 12.99, 76, 'in-stock'),
(8030, 'Epson T502 EcoTank Ink Bottles BK/C/Y/M, Club Pack', 49.99, 18, 'in-stock'),
(8031, 'Takeya 2-quart Beverage Pitcher 2-pack', 26.99, 62, 'in-stock'),
(8032, 'HP 63XL High Yield Ink Cartridge, Black & Tri-Color, Combo Pack', 93.79, 4, 'in-stock'),
(8033, 'HP 962XL High Yield Ink Cartridge, Tri-Color Pack', 109.99, 82, 'in-stock'),
(8034, 'TOPS Perforated Legal Ruled Letter Pad, 9-count', 17.99, 80, 'in-stock'),
(8035, 'HP 902XL High Yield Ink Cartridge, Black, 2-Count', 91.79, 9, 'in-stock'),
(8036, 'Post-it Ruled Notes, Assorted Pastel Colors, 4 x 6 - 100 Sheets, 5 Pads', 11.39, 84, 'in-stock'),
(8037, 'Post-it Notes, Assorted Bright Colors, 1-1/2 x 2 100 Sheets, 24 Pads', 11.29, 34, 'in-stock'),
(8038, 'HP 62XL High Yield Ink Cartridge, Black & Tri-Color', 93.79, 8, 'in-stock'),
(8039, 'uni-ball 207 Retractable Gel Pen, Medium Point 0.7mm, Assorted Ink Colors, 12-count', 12.39, 81, 'in-stock'),
(8040, 'HP 64XL High Yield Ink Cartridge, Black & Tri-Color, 2-Count', 95.79, 1, 'in-stock'),
(8041, 'Nouvelle Legende Ribbed 100% Cotton Bar Towel, White, 16 in x 19 in, 25-count', 22.99, 86, 'in-stock'),
(8042, 'Tramontina Serving Spoons, Assorted Styles, Stainless Steel, 6-count', 10.49, 17, 'in-stock'),
(8043, 'HP 952XL High Yield Ink Cartridge, Tri-Color Pack', 117.79, 100, 'in-stock'),
(8044, 'Scotch Packaging Tape, General Purpose, 1.88W x 54.6 yds, 8-count', 15.99, 91, 'in-stock'),
(8045, 'Bostitch Premium Desktop Stapler Value Pack', 14.99, 68, 'in-stock'),
(8046, 'Scotch Heavy Duty Shipping Tape 8-pack', 26.99, 23, 'in-stock'),
(8047, 'HP 910XL High Yield Ink Cartridge, Tri-Color Pack', 69.79, 8, 'in-stock'),
(8048, 'Bostitch 1/4 Premium Staples, Standard Chisel Point, 5,000 Staples, 5-count', 4.49, 8, 'in-stock'),
(8049, 'HP 67XL High Yield Ink Cartridge, Black & Tri-Color', 52.79, 78, 'in-stock'),
(8050, 'HP 962XL High Yield Ink Cartridge, Black, 2-count', 93.79, 92, 'in-stock'),
(8051, 'HP 952XL High Yield Ink Cartridge, Black, 2-count', 102.79, 9, 'in-stock'),
(8052, 'HP 910XL High Yield Ink Cartridge, Black, 2-count', 84.79, 3, 'in-stock'),
(8053, 'Pentel Twist-Erase Click Mechanical Pencil, 15-count', 10.19, 84, 'in-stock'),
(8054, 'Scotch Heavy Duty Shipping Packaging Tape with Tape Gun Dispenser, 2 Rolls of Tape Included', 16.49, 97, 'in-stock'),
(8055, 'Nouvelle Legende Flame Retardant Oven Mitt, Black, 2-count', 5.49, 27, 'in-stock'),
(8056, 'Pilot G2 Gel Pen, Black, 20-pack', 19.99, 11, 'in-stock'),
(8057, 'Pendaflex 1/3 Cut File Folder Letter Size, 150-count', 12.99, 36, 'in-stock'),
(8058, 'TOPS 1 R-Ring View Binder 6-count', 12.79, 15, 'in-stock'),
(8059, 'Nouvelle Legende Commercial Grade Apron, Black, 29 in x 32 in, 2-count', 9.49, 14, 'in-stock'),
(8060, 'TOPS Non-stick 1/2 View Binder, 6-count', 11.99, 85, 'in-stock'),
(8061, 'Pilot G2 Gel Pens Assorted Colors, 20-pack', 19.99, 17, 'in-stock'),
(8062, 'Scotch Permanent Glue Stick, 0.28 oz, 24-count', 8.99, 89, 'in-stock'),
(8063, 'Advantage Premium Bright Ink Jet and Laser Paper, 8.5x11 Letter, White, 24lb, 97 Bright, 1 Ream of 800 Sheets', 10.99, 13, 'in-stock'),
(8064, 'BIC Mechanical Pencil Kit, 24 Velocity + 1 Break Resistant, 0.7mm Lead, 25-count', 14.99, 55, 'in-stock'),
(8065, 'Post-it Notes, Canary Yellow, 3 x 3 100 Sheets, 24 Pads', 17.99, 88, 'in-stock'),
(8066, 'Winco 9-Inch Non-Slip Locking Tongs, Stainless Steel, 4-count', 11.99, 56, 'in-stock'),
(8067, 'BIC Ecolutions Ocean-Bound Retractable Gel Pens, Medium Point 1.0mm, Assorted Ink, 15-count', 15.99, 8, 'in-stock'),
(8068, 'Sharpie Fine Point Permanent Marker, 25-count', 16.99, 94, 'in-stock'),
(8069, 'Eurow Nouvelle Legende Placemats, 12-count', 13.99, 31, 'in-stock');

INSERT INTO meatandseafood (id, name, price, stock, expiry, status) VALUES
(9000, 'Ahi Tuna Individual Vacuum Packed Portion (26-27/6 Oz. Per Portion), 26-27 Total Packs, 10 Lbs. Total Case', 149.99, 45, '2023-08-15', 'in-stock'),
(9001, 'Chicago Steak USDA Prime Beef Wet Aged Boneless Strips & Gourmet Burgers, 16 Total Count, 10 Lbs. Total', 229.99, 83, '2023-12-15', 'in-stock'),
(9002, 'Alaska Home Pack Frozen Sea Cucumber - 3 Packs, 7 Lbs. Total', 239.99, 56, '2023-02-06', 'in-stock'),
(9003, 'Crown Prince Smoked Oysters in Olive Oil, Fancy Whole, 3.75 oz, 6-count', 14.99, 34, '2023-07-16', 'in-stock'),
(9004, 'Kansas City Steak Company USDA Choice Ribeye Steaks 18 Oz. Each (Available in 4, 8, or 12 Packs)', 129.99, 78, '2023-07-21', 'in-stock'),
(9005, 'Kansas City Steak Company USDA Choice NY Strip Steaks 16 Oz. Each (Available in 4, 8, or 12 Packs)', 109.99, 65, '2023-03-20', 'in-stock'),
(9006, 'Northfork Ground Bison - (10/1 Lb. Per Pack), 10 Total Packs, 10 Lbs. Total', 109.99, 28, '2023-06-28', 'in-stock'),
(9007, 'Lobster With Shell Removed, (9 Oz. Per Pack), 6 Total Packs, 3.44 Lbs. Total', 259.99, 31, '2023-12-04', 'in-stock'),
(9008, 'Crescent Foods Halal Hand-Cut Beef, Chicken Combo Pack - 14 Total Packs, 13.5 Lbs. Total', 159.99, 29, '2023-04-06', 'in-stock'),
(9009, 'Farmer Focus Organic Boneless/Skinless Chicken Breasts, (20/8 Oz. Per Breast), 20 Total Count, 10 Lbs. Total', 149.99, 68, '2023-11-26', 'in-stock'),
(9010, 'DArtagnan Green Circle Chicken - Boneless & Skinless Breasts, 12 Total Packs, 11 Lbs. Total', 139.99, 59, '2023-08-02', 'in-stock'),
(9011, 'Northwest Fish 4-6 Whole Dungeness Crab, 10 lbs', 209.99, 77, '2023-02-03', 'in-stock'),
(9012, 'Quality Ethnic Foods Halal Chicken Variety Pack (Drumsticks, Tenders, Boneless Breast), 12 Total Packs, 12 Lbs. Total', 99.99, 24, '2023-08-30', 'in-stock'),
(9013, 'Premium Seafood Variety Pack - 20 Total Packs, Total 12.5 Lbs.', 349.99, 99, '2023-09-12', 'in-stock'),
(9014, 'Northfork Elk Burger (30/5.33 Oz Per Burger), 10 Total Packs, 30-Count', 109.99, 63, '2023-07-01', 'in-stock'),
(9015, 'DArtagnan Heritage Breed (6/3.25 Lbs. Per Whole Chicken), Total 6 Packs, 19.5 Lbs. Total', 169.99, 60, '2023-03-11', 'in-stock'),
(9016, 'Chicago Steak - Steak & Cake - Filet Mignon, Crab Cakes, and Steak Burgers, Total 13 Packs, 6.5 Lbs. Total', 199.99, 100, '2023-11-12', 'in-stock'),
(9017, 'Northwest Fish Colossal Alaskan Wild Dungeness Crab Sections, 10lbs', 219.99, 24, '2023-09-01', 'in-stock'),
(9018, 'Mila Chicken Xiao Long Bao Soup Dumplings - 50 Dumplings Per Bag, 3 Bags Total', 99.99, 9, '2023-03-10', 'in-stock'),
(9019, 'Kansas City Steak Company USDA Choice Combo Pack (4 Strips, 4 Filet Mignon, 4 Ribeyes), 12 Total Packs, 11.5 Lbs. Total', 279.99, 41, '2023-04-04', 'in-stock'),
(9020, 'DArtagnan Extreme American Wagyu Burger Lovers Bundle 12 Total Packs, 6 Lbs. Total', 159.99, 81, '2023-04-17', 'in-stock'),
(9021, 'Texas Tamale Co. Chicken Tamales 6-pack of 12 each, 72-count', 89.99, 63, '2023-10-22', 'in-stock'),
(9022, 'Northwest Fish Wild Alaskan Sockeye Salmon Cheddar Bacon Burger Patties, 24-count, 9 lbs', 119.99, 16, '2023-07-02', 'in-stock'),
(9023, 'Northfork Bison Burger (30/5.33 Oz Per Burger), 10 Total Packs, 30-Count', 109.99, 24, '2023-01-04', 'in-stock'),
(9024, 'Coastal Seafood Frozen Lobster Tails 12 Count (6 - 8  oz.)', 229.99, 31, '2023-11-28', 'in-stock'),
(9025, 'DArtagnan 13-piece Gourmet Roasting Ham & Luxury Charcuterie Gift Box, 12.5 lbs', 199.99, 5, '2023-07-02', 'in-stock'),
(9026, 'Northwest Fish Alaskan Bairdi Snow Crab Sections, (10-14 / 13 Oz. Per Pack), Total 10 Lbs.', 299.99, 19, '2023-11-28', 'in-stock'),
(9027, 'Authentic Wagyu Surf & Turf Pack, (2/17-20 Oz./Each Tail) Cold Water Lobster Tails with (2/13 Oz. Per Steak) Japanese A5 Wagyu Petite Striploin Steaks', 279.99, 70, '2023-05-08', 'in-stock'),
(9028, 'Rastelli Bone-In Premium Pork Rib Steak, (16/8 Oz. Per Steak), 16 Total Count, 8 Lbs. Total ', 199.99, 13, '2023-03-03', 'in-stock'),
(9029, 'Mila Pork Xiao Long Bao Soup Dumplings - 50 Dumplings Per Bag, 3 Bags Total', 99.99, 55, '2023-08-25', 'in-stock'),
(9030, 'Rastelli USDA Choice Boneless Black Angus Prime Rib Roast, 1 Total Pack, 7 Lbs. Total', 199.99, 77, '2023-09-01', 'in-stock'),
(9031, 'Silver Fern Farms 100% New Zealand Grass-Fed, Net Carbon Zero Steak Box - 10 Total Packs, 6.25 Lbs. Total', 129.99, 82, '2023-03-09', 'in-stock'),
(9032, 'Authentic Wagyu Surf & Turf Pack, (2/17-20 Oz. Cold Water Lobster Tails with  (2/14 Oz.Per Steak) Japanese A5 Wagyu Ribeye Steaks', 339.99, 0, '2023-11-22', 'out-of-stock'),
(9033, 'DArtagnan Gourmet Steak & Burger Grill Pack, 20 Total Packs, 16 Lbs. Total', 399.99, 67, '2023-07-15', 'in-stock'),
(9034, 'Rastelli Market Fresh Jumbo Lump Crab Cakes (20/4 Oz. Per Crab Cake), 20 Total Count, 5 Lbs. Total', 199.99, 29, '2023-12-18', 'in-stock'),
(9035, 'Rastelli Petite Filet Mignon & Jumbo Lump Crab Cake Surf & Turf, 24 Total Packs, 6.75 Total Lbs.', 349.99, 100, '2023-10-26', 'in-stock'),
(9036, 'Chicago Steak Premium Angus Beef Surf & Turf, 15 Total Packs, 7 Lbs. Total', 239.99, 87, '2023-02-23', 'in-stock'),
(9037, 'Chicago Steak Premium Angus Beef Burger Flight, Total 29 Packs, 14 Lbs. Total', 219.99, 3, '2023-07-19', 'in-stock'),
(9038, 'Wild Alaska Snow Crab Meat (Bairdi Crab 8 oz. Pack) 12 Total Packs, 6 Lbs. Total ', 279.99, 85, '2023-02-07', 'in-stock'),
(9039, 'Authentic Wagyu Kurobuta Applewood Smoked Thick Cut Bacon, 1 Pack, 3 Lbs. Total', 89.99, 26, '2023-09-19', 'in-stock'),
(9040, 'Northwest Red King Salmon Portions, 12 Total Count, 1 Case Totaling 6 Lbs.', 179.99, 82, '2023-05-16', 'in-stock'),
(9041, 'DArtagnan Antibiotic Free Bone-in Beef Ribeye Roast, 1 Total Pack, 19 Lbs. Total', 429.99, 13, '2023-08-21', 'in-stock'),
(9042, 'Rastellis Pork Ribeye Steaks - (20/6 Oz Per Portion), 20 Total Packs, 7.5 Lbs. Total', 114.99, 65, '2023-09-14', 'in-stock'),
(9043, 'Chicago Steak USDA Prime Surf & Turf, Total 14 Packs, 7 Lbs. Total', 299.99, 87, '2023-02-05', 'in-stock'),
(9044, 'Ahi Tuna Mixed Pack, (12 x 6 oz. Steaks, 9 x 5.3 oz. Saku Slice Packs, 4 x 10.7 oz. Sesame Crusted Steak Packs), 25 Total Packs, 10.15 Lbs. Total', 239.99, 19, '2023-01-06', 'in-stock'),
(9045, 'Mila Starter Pack Xiao Long Bao Soup Dumplings - 3 Bags, 1 Bamboo Steamer, 4 Dipping Bowls', 129.99, 15, '2023-01-14', 'in-stock'),
(9046, 'Northwest Fish Wild Alaskan Sockeye Salmon Fillets, 10 lbs', 219.99, 99, '2023-05-29', 'in-stock'),
(9047, 'Smoked New Zealand King Salmon, 1.1lb fillets, 2-count, 2.2 lbs total', 109.99, 24, '2023-07-02', 'in-stock'),
(9048, 'Crescent Foods Halal Hand Cut Steak Locker, 16 Total Packs, 9 Lbs. Total', 199.99, 78, '2023-07-11', 'in-stock'),
(9049, 'Rastelli VBites Plant-Based Vegan Meat Substitute Mega Burger 6 oz each, 24-pack, 9 lbs', 99.99, 98, '2023-12-28', 'in-stock'),
(9050, 'Chicago Steak Filet Mignon & Scallop Combo, 14 Total Packs, 7 Lbs. Total', 249.99, 13, '2023-10-25', 'in-stock'),
(9051, ' Northwest Fish Wild Alaskan Sockeye Salmon Fillets Total 25 Count, 1 Case Totaling 10 Lbs.', 229.99, 95, '2023-01-02', 'in-stock');

INSERT INTO organic (id, name, price, stock, expiry, status) VALUES
(10000, 'Kirkland Signature, Organic Chicken Stock, 32 fl oz, 6-Count', 11.99, 37, '2023-01-29', 'in-stock'),
(10001, 'Kirkland Signature, Organic Almond Beverage, Vanilla, 32 fl oz, 6-Count', 9.99, 54, '2023-02-07', 'in-stock'),
(10002, 'Kirkland Signature, Organic Extra Virgin Olive Oil, 2 L', 18.99, 55, '2023-09-08', 'in-stock'),
(10003, 'Kirkland Signature Organic No-Salt Seasoning, 14.5 oz', 9.99, 72, '2023-11-03', 'in-stock'),
(10004, 'Kirkland Signature, Organic Fruit and Vegetable Pouches, Variety Pack, 3.17 oz, 24-count', 14.99, 80, '2023-11-23', 'in-stock'),
(10005, 'Seeds of Change, Organic Quinoa and Brown Rice, 8.5 oz, 6-Count', 14.99, 55, '2023-09-27', 'in-stock'),
(10006, 'Ruta Maya Organic Jiguaní Whole Bean Coffee 5 lb', 47.99, 72, '2023-03-29', 'in-stock'),
(10007, 'Kirkland Signature Organic Raw Honey, 24 oz, 3-count', 17.99, 36, '2023-04-14', 'in-stock'),
(10008, 'Kirkland Signature Organic Pine Nuts, 1.5 lbs', 33.99, 56, '2023-03-21', 'in-stock'),
(10009, 'Kirkland Signature Organic Pure Maple Syrup, 33.8 oz', 14.99, 9, '2023-09-16', 'in-stock'),
(10010, 'Kirkland Signature, Organic Sugar, 10 lbs', 10.99, 9, '2023-10-03', 'in-stock'),
(10011, 'Newmans Own Organics Coffee Special Blend K-Cup Pod, 100-count', 48.99, 10, '2023-02-14', 'in-stock'),
(10012, 'Thai Kitchen Organic Coconut Milk, Unsweetened, 13.66 fl oz, 6-count', 14.99, 67, '2023-04-16', 'in-stock'),
(10013, 'Ruta Maya Organic Medium Roast Whole Bean Coffee 5 lb', 44.99, 74, '2023-08-22', 'in-stock'),
(10014, 'Joses 100% Organic Mayan Whole Bean Coffee 2.5 lb, 2-pack', 44.99, 58, '2023-09-12', 'in-stock'),
(10015, 'Kirkland Signature Organic Blue Agave, 36 oz, 2-count', 10.99, 72, '2023-07-07', 'in-stock'),
(10016, 'Kirkland Signature, Organic Applesauce, 3.17 oz, 24-Count', 12.99, 15, '2023-07-08', 'in-stock'),
(10017, 'Oregon Chai, Original Organic Chai Tea Latte Concentrate, 32 fl. oz., 3-Count', 11.69, 52, '2023-02-06', 'in-stock'),
(10018, 'Made in Nature Organic Berry Fusion 24 oz, 2-pack', 39.99, 8, '2023-07-15', 'in-stock'),
(10019, 'Kirkland Signature, Organic Soy Beverage, Vanilla, 32 fl oz, 12-Count', 17.99, 85, '2023-03-14', 'in-stock'),
(10020, 'Kirkland Signature, Organic Soy Beverage, Plain, 32 fl oz, 12-Count', 17.99, 42, '2023-09-17', 'in-stock'),
(10021, 'Kirkland Signature Organic Roasted Seaweed, 0.6 oz, 10-count', 11.99, 64, '2023-05-07', 'in-stock'),
(10022, 'Made In Nature Organic Calimyrna Figs 40 oz, 3-pack', 49.99, 69, '2023-07-13', 'in-stock'),
(10023, 'GoGo SqueeZ, Organic Applesauce, Variety Pack, 3.2 oz, 28-Count', 19.99, 85, '2023-09-19', 'in-stock'),
(10024, 'Garofalo, Organic Pasta, Variety Pack, 17.6 oz, 6-Count', 12.99, 36, '2023-08-28', 'in-stock'),
(10025, 'S&W, Organic Black Beans, 15 oz, 8-Count', 9.99, 75, '2023-10-21', 'in-stock'),
(10026, 'Kirkland Signature, Organic Tomato Sauce, 15 oz, 12-Count', 9.49, 34, '2023-08-02', 'in-stock'),
(10027, 'Ruta Maya Organic Dark Roast Coffee, 5 lbs', 44.99, 13, '2023-11-17', 'in-stock'),
(10028, 'S&W, Organic Garbanzo Beans, 15.5 oz, 8-Count', 10.99, 36, '2023-12-21', 'in-stock'),
(10029, 'Kirkland Signature, Organic 100% Juice, Variety Pack, 6.75 fl oz, 40-Count', 17.99, 79, '2023-02-13', 'in-stock'),
(10030, 'Mother Earth Organic Medium Roast Coffee 2 lb, 2-pack', 39.99, 37, '2023-05-06', 'in-stock'),
(10031, 'Kirkland Signature, Organic Tomato Paste, 6 oz, 12-Count', 10.99, 63, '2023-05-21', 'in-stock'),
(10032, 'Acetum Organic Apple Cider Vinegar with the Mother, 128 fl. oz.', 27.99, 64, '2023-02-24', 'in-stock');

INSERT INTO pantry (id, name, price, stock, expiry, status) VALUES
(11000, 'European Black Winter Fresh Truffles 3 oz.', 189.99, 95, '2023-04-30', 'in-stock'),
(11001, 'Manuka Health UMF 20+ (MGO 850+) Raw Manuka Honey 8.8 oz', 59.99, 33, '2023-11-27', 'in-stock'),
(11002, 'Kirkland Signature, Chicken Breast, 12.5 oz, 6-Count', 14.99, 16, '2023-05-03', 'in-stock'),
(11003, 'Skippy Peanut Butter, Creamy, 48 oz, 2-count', 9.69, 27, '2023-10-27', 'in-stock'),
(11004, 'Indomie Mi Goreng Instant Fried Noodles, 3 oz, 40-count', 23.99, 99, '2023-06-06', 'in-stock'),
(11005, 'Skippy Peanut Butter, Super Chunk, 48 oz, 2-count', 9.69, 35, '2023-04-10', 'in-stock'),
(11006, 'Nongshim Shin Gold Ramyun Noodle Soup with Chicken Broth, Gourmet Spicy, 3.56 oz, 6-count', 10.99, 62, '2023-02-10', 'in-stock'),
(11007, 'Kirkland Signature, Organic Chicken Stock, 32 fl oz, 6-Count', 11.99, 36, '2023-02-21', 'in-stock'),
(11008, 'Kirkland Signature, Organic Extra Virgin Olive Oil, 2 L', 18.99, 53, '2023-10-23', 'in-stock'),
(11009, 'Nissin, Cup Noodles, Chicken, 24-Count', 13.99, 38, '2023-08-16', 'in-stock'),
(11010, 'Namaste USDA Organic Gluten Free Perfect Sweet Brown Rice Flour Blend 48 oz  6-count', 74.99, 91, '2023-03-10', 'in-stock'),
(11011, 'Kirkland Signature Creamy Almond Butter, 27 oz', 7.99, 77, '2023-11-09', 'in-stock'),
(11012, 'Knorr, Chicken Bouillon, 7.9 lbs', 22.99, 72, '2023-05-04', 'in-stock'),
(11013, 'Season, Skinless & Boneless Sardines In Olive Oil, 4.375 oz, 6-Count', 10.99, 21, '2023-12-07', 'in-stock'),
(11014, 'Kirkland Signature, Extra Virgin Italian Olive Oil, 2 L', 18.99, 34, '2023-06-30', 'in-stock'),
(11015, 'Snapdragon, Vietnamese Pho Bowls, 2.3 oz, 9-Count', 14.99, 43, '2023-01-04', 'in-stock'),
(11016, 'Nongshim, Udon Noodle Soup Bowl, 9.73 oz, 6-Count', 22.99, 41, '2023-10-28', 'in-stock'),
(11017, 'Kirkland Signature Organic No-Salt Seasoning, 14.5 oz', 9.99, 49, '2023-04-14', 'in-stock'),
(11018, 'Kraft, Macaroni & Cheese Dinner Cup, 2.05 oz, 12-Count', 12.49, 69, '2023-09-10', 'in-stock'),
(11019, 'Bibigo, Cooked Sticky White Rice Bowls, Medium Grain, 7.4 oz, 12-Count', 13.49, 80, '2023-07-12', 'in-stock'),
(11020, 'Samyang, Buldak Stir-Fried Spicy Chicken Ramen, Habanero Lime, 3.88 oz, 6-Count', 13.99, 4, '2023-10-09', 'in-stock'),
(11021, 'Seeds of Change, Organic Quinoa and Brown Rice, 8.5 oz, 6-Count', 14.99, 91, '2023-07-27', 'in-stock'),
(11022, 'Kraft, Macaroni & Cheese Dinner, 7.25 oz, 18-Count', 18.99, 84, '2023-11-02', 'in-stock'),
(11023, 'Nongshim, Shin Ramyun Noodle Soup, 4.2 oz, 18-Count', 19.99, 53, '2023-01-11', 'in-stock'),
(11024, 'Chicken of the Sea, Chunk Light Premium Tuna in Water, 7 oz, 12-Count', 19.99, 52, '2023-08-15', 'in-stock'),
(11025, 'Kirkland Signature Semi-Sweet Chocolate Chips, 4.5 lbs', 13.99, 60, '2023-12-28', 'in-stock'),
(11026, 'Kirkland Signature, Refined Olive Oil, 3 Liter, 2-count', 52.99, 47, '2023-02-26', 'in-stock'),
(11027, 'Skippy Creamy Peanut Butter Squeeze Packets, 1.15 oz, 32-count', 9.99, 21, '2023-06-10', 'in-stock'),
(11028, 'Nissin, Cup Noodles, Shrimp, 2.5 oz, 24-Count', 13.99, 21, '2023-07-03', 'in-stock'),
(11029, 'Kraft, Grated Parmesan Cheese 4.5 lbs', 26.99, 72, '2023-08-08', 'in-stock'),
(11030, 'Nongshim, Tonkotsu Ramen Bowl, 3.56 oz, 6-Count', 10.39, 26, '2023-05-17', 'in-stock'),
(11031, 'Kirkland Signature, Organic Virgin Coconut Oil, 84 fl oz', 17.99, 13, '2023-09-25', 'in-stock'),
(11032, 'Kirkland Signature Organic Raw Honey, 24 oz, 3-count', 17.99, 55, '2023-08-29', 'in-stock'),
(11033, 'Kirkland Signature Organic Pure Maple Syrup, 33.8 oz', 14.99, 60, '2023-12-19', 'in-stock'),
(11034, 'Kirkland Signature, Semi-Sweet Chocolate Chips, 4.5 lbs', 14.99, 64, '2023-03-09', 'in-stock'),
(11035, 'Kirkland Signature, Organic Sugar, 10 lbs', 10.99, 80, '2023-11-15', 'in-stock'),
(11036, 'Full Thread Greek Saffron 14 Gram Jar', 59.99, 26, '2023-06-07', 'in-stock'),
(11037, 'Namaste Gluten Free Perfect Flour Blend, 6-pack', 56.99, 26, '2023-04-01', 'in-stock'),
(11038, 'TRE Olive Oil Calabrian Gift Box', 79.99, 72, '2023-06-25', 'in-stock'),
(11039, 'TRE Olive 2 Liter Extra Virgin Olive Oil', 39.99, 95, '2023-04-09', 'in-stock'),
(11040, 'Kirkland Signature, Canola Oil, 3 qt, 2-count', 14.99, 60, '2023-07-14', 'in-stock'),
(11041, 'Kirkland Signature, Pure Sea Salt, 30 oz', 3.99, 61, '2023-05-19', 'in-stock'),
(11042, 'Napa Valley Naturals USDA Organic Extra Virgin Olive Oil 25.4 oz, 6-count', 79.99, 80, '2023-06-18', 'in-stock'),
(11043, 'Origin 846 Unfiltered Organic Extra Virgin Olive Oil 28.6 oz, 3-pack', 29.99, 54, '2023-10-09', 'in-stock'),
(11044, 'Royal, Basmati Rice, 20 lbs', 24.99, 74, '2023-04-13', 'in-stock'),
(11045, 'Tre Olive Harvest Variety Gift Box Extra Virgin Olive Oil 3-Pack', 59.99, 56, '2023-01-05', 'in-stock'),
(11046, 'Manuka Health UMF 10+ (MGO 263+) Raw Manuka Honey 17.6 oz', 29.99, 13, '2023-07-06', 'in-stock'),
(11047, 'Kirkland Signature, Crushed Red Pepper, 10 oz', 4.79, 54, '2023-09-14', 'in-stock'),
(11048, 'Nissin, Hot & Spicy Noodle Bowl, Chicken, 3.32 oz, 18-Count', 17.49, 93, '2023-07-27', 'in-stock'),
(11049, 'Terra Delyssa First Cold Press Extra Virgin Olive Oil 3L, Tin, 2-count', 64.99, 44, '2023-01-22', 'in-stock'),
(11050, 'Del Monte, Canned Cut Green Beans, 14.5 oz, 12-Count', 12.99, 20, '2023-12-06', 'in-stock'),
(11051, 'Kirkland Signature, Vegetable Oil, 3 qt, 2-Count', 14.99, 65, '2023-06-09', 'in-stock'),
(11052, 'Kirkland Signature Wild Flower Honey, 5 lbs', 17.99, 97, '2023-11-28', 'in-stock'),
(11053, 'Del Monte, Diced Peaches, Fruit Cups, 4 oz cups, 20-Count', 13.99, 29, '2023-07-07', 'in-stock'),
(11054, 'Thai Kitchen Organic Coconut Milk, Unsweetened, 13.66 fl oz, 6-count', 14.99, 48, '2023-12-28', 'in-stock'),
(11055, 'Kirkland Signature, Organic Quinoa, 4.5 lbs', 10.99, 61, '2023-07-24', 'in-stock'),
(11056, 'Wild Planet, Albacore Wilda Tuna, 5 oz, 6-Count', 19.99, 4, '2023-04-28', 'in-stock'),
(11057, 'Ardent Mills, Harvest Hotel & Restaurant, All-Purpose Flour, 25 lbs', 11.99, 46, '2023-05-22', 'in-stock'),
(11058, 'Chosen Foods Avocado Oil Spray, 13.5 oz, 2-count', 21.99, 36, '2023-05-30', 'in-stock'),
(11059, 'Nestle La Lechera, Sweetened Condensed Milk, 14 oz, 6-Count', 15.99, 18, '2023-02-11', 'in-stock'),
(11060, 'Comvita UMF 25+ Special Reserve Manuka Honey 8.8 oz', 349.99, 73, '2023-02-15', 'in-stock'),
(11061, 'eat.art Salt and Spice Set 2-pack', 44.99, 72, '2023-07-28', 'in-stock'),
(11062, 'Kirkland Signature, Bacon Crumbles, 20 oz', 10.99, 73, '2023-05-05', 'in-stock'),
(11063, 'Nissin, Cup Noodles, Beef, 2.5 oz, 24-Count', 13.99, 4, '2023-03-30', 'in-stock');

INSERT INTO snacks (id, name, price, stock, expiry, status) VALUES
(13000, 'Kirkland Signature Super Extra-Large Peanuts, 2.5 lbs', 8.99, 38, '2023-09-26', 'in-stock'),
(13001, 'Kirkland Signature Protein Bars Chocolate Peanut Butter Chunk 2.12 oz, 20-count', 23.99, 13, '2023-08-28', 'in-stock'),
(13002, 'G2G 3-pack Peanut Butter Chocolate Chip Protein Bars 24-count', 39.99, 75, '2023-07-08', 'in-stock'),
(13003, 'G2G 3-pack Peanut Butter Coconut Chocolate Protein Bars 24-count', 39.99, 84, '2023-12-04', 'in-stock'),
(13004, 'Frito Lay Oven Baked Mix, Variety Pack, 30-count', 16.99, 46, '2023-07-28', 'in-stock'),
(13005, 'Old Trapper Beef Jerky, Peppered, 10 oz', 13.99, 11, '2023-06-05', 'in-stock'),
(13006, 'Old Trapper Beef Jerky, Hot & Spicy, 10 oz', 13.99, 22, '2023-11-27', 'in-stock'),
(13007, 'Old Trapper Beef Jerky, Old Fashioned, 10 oz', 13.99, 50, '2023-02-09', 'in-stock'),
(13008, 'Kirkland Signature Chewy Protein Bar, Peanut Butter & Semisweet Chocolate Chip, 1.41 oz, 42-Count', 18.99, 18, '2023-05-26', 'in-stock'),
(13009, 'Kirkland Signature Protein Bars Chocolate Chip Cookie Dough 2.12 oz., 20-count', 23.99, 91, '2023-04-16', 'in-stock'),
(13010, 'Simply Protein Crispy Bars, 1.41 oz, Variety Pack, 15-count', 22.99, 59, '2023-12-03', 'in-stock'),
(13011, 'PopCorners Popped Corn Snacks Variety Pack, 1 oz, 30-Count', 16.99, 28, '2023-07-24', 'in-stock'),
(13012, 'Simple Mills Almond Flour Sea Salt Crackers, 10 oz, 2-count', 9.49, 86, '2023-04-24', 'in-stock'),
(13013, 'Fit Crunch Whey Protein Bar, Peanut Butter and Jelly, 1.62 oz, 18 Count', 22.99, 90, '2023-07-23', 'in-stock'),
(13014, 'Pure Protein Bars, Variety Pack, 1.76 oz, 23-count', 20.99, 36, '2023-04-19', 'in-stock'),
(13015, 'Kirkland Signature Protein Bars Chocolate Brownie  2.12 oz, 20-count', 23.99, 93, '2023-06-27', 'in-stock'),
(13016, 'Kirkland Signature Protein Bar, Variety Pack, 2.12 oz, 20-count', 22.99, 1, '2023-08-05', 'in-stock'),
(13017, 'G2G 3-pack Peanut Butter & Jelly Protein Bars, 24-count', 49.99, 94, '2023-02-18', 'in-stock'),
(13018, 'Frito Lay Classic Mix, 1 oz, Variety Pack, 54-count', 23.99, 58, '2023-04-13', 'in-stock'),
(13019, 'Natures Garden Organic Trail Mix Snack Packs, Variety Pack, 1.2 oz, 24-count', 11.49, 17, '2023-05-31', 'in-stock'),
(13020, 'RITZ Bits Cracker Sandwiches, Cheese, 1.5 oz, 30-count', 14.99, 72, '2023-01-21', 'in-stock'),
(13021, 'Kirkland Signature Nut Bars, 1.41 oz, 30-count', 17.99, 42, '2023-09-02', 'in-stock'),
(13022, 'Nature Valley Protein Bar, Peanut Butter Dark Chocolate, 1.42 oz, 30-count', 18.99, 90, '2023-04-02', 'in-stock'),
(13023, 'Kirkland Signature Soft & Chewy Granola Bars, 0.85 oz, 64-count', 11.99, 28, '2023-03-15', 'in-stock'),
(13024, 'Pure Organic Layered Fruit Bars, Variety Pack,  0.63 oz, 28-count', 11.89, 24, '2023-04-04', 'in-stock'),
(13025, 'St Michel Madeleine, Classic French Sponge Cake 100 - count', 44.99, 13, '2023-03-12', 'in-stock'),
(13026, 'Nabisco Cookie & Cracker, Variety Pack, 1 oz, 40-count', 14.99, 56, '2023-02-27', 'in-stock'),
(13027, 'Kirkland Signature Cashew Clusters, 2 lbs', 10.99, 38, '2023-10-01', 'in-stock'),
(13028, 'No Sugar Keto Bar (12 count) 2-pack Chocolate Peanut Butter', 42.99, 86, '2023-05-25', 'in-stock'),
(13029, 'Ready Protein Bar, Chocolate Peanut Butter and Sea Salt, 24-count, 2 pack', 54.99, 87, '2024-01-09', 'in-stock'),
(13030, 'KIND Bar, Peanut Butter Dark Chocolate, 1.4 oz, 15-count', 17.99, 52, '2023-09-14', 'in-stock'),
(13031, 'Thats it Mini Fruit Bars, 24-count', 15.99, 83, '2023-08-15', 'in-stock'),
(13032, 'Chef Robert Irvines Fitcrunch Chocolate Peanut Butter Whey Protein Bars, 18-count, 1.62oz', 22.99, 65, '2023-07-10', 'in-stock'),
(13033, 'Chef Robert Irvines Fit Crunch Whey Protein Bars, Mint Chocolate Chip, 18-count, 1.62 Oz', 22.99, 39, '2023-11-08', 'in-stock'),
(13034, 'Power Crunch Protein Energy Bar, Strawberry Creme, 1.4 oz, 12-count', 17.99, 6, '2023-09-25', 'in-stock'),
(13035, 'Shrimp Chips with Garlic and Butter 16 oz 2-pack', 27.99, 92, '2023-07-17', 'in-stock'),
(13036, 'Nutter Butter Sandwich Cookies, 1.9 oz, 24-count', 12.99, 91, '2023-01-23', 'in-stock'),
(13037, 'Paradise Green, Dried Ginger Chunks, 32 oz', 8.99, 19, '2023-11-13', 'in-stock'),
(13038, 'Grandmas Cookies, Variety Pack, 2.5 oz, 33-count', 18.99, 19, '2023-06-24', 'in-stock'),
(13039, 'Skinny Pop Popcorn, 0.65 oz, 28-count', 17.99, 4, '2023-11-26', 'in-stock'),
(13040, 'Clif Bar, Crunchy Peanut Butter, 2.4 oz, 12-count', 17.99, 38, '2023-11-04', 'in-stock'),
(13041, 'Lance Toasty Cracker Sandwiches, 1.29 oz, 40-count', 9.99, 36, '2023-08-20', 'in-stock'),
(13042, 'Kirkland Signature Snacking Nuts, Variety Pack, 1.6 oz, 30-count', 16.99, 75, '2023-08-20', 'in-stock'),
(13043, 'Planters, Cashew & Peanut, Variety Pack, 24-count', 10.69, 88, '2023-11-03', 'in-stock'),
(13044, 'Annies Organic Bunny Snack Pack Baked Crackers and Graham Snacks, 1.07 oz, Variety Pack, 36-count', 16.99, 30, '2023-06-24', 'in-stock'),
(13045, 'Skippy Peanut Butter & Chocolate Fudge Wafer Bar, 1.3 oz, 22-Count', 13.99, 12, '2023-09-09', 'in-stock'),
(13046, 'Kirkland Signature Turkey Jerky, 13.5 oz', 13.99, 54, '2023-01-27', 'in-stock'),
(13047, 'Kirkland Signature Fancy Whole Cashews, 2.5 lbs', 14.99, 86, '2023-04-30', 'in-stock'),
(13048, 'Power Crunch Protein Energy Bars, Peanut Butter Creme, 1.4 oz, 12-count', 17.99, 89, '2023-08-31', 'in-stock'),
(13049, 'WildRoots Coastal Berry Trail Mix, 26 oz', 12.99, 66, '2023-11-15', 'in-stock'),
(13050, 'SkinnyPop Popcorn, Variety, 36-count', 18.99, 61, '2023-06-09', 'in-stock'),
(13051, 'Quaker Rice Crisps, Variety Pack, 36-count', 19.99, 79, '2023-10-16', 'in-stock'),
(13052, 'Kirkland Signature Trail Mix Snack Packs, 2 oz, 28-count', 17.99, 25, '2023-07-10', 'in-stock'),
(13053, 'Think Thin High Protein Bar, Variety Pack, 2.1 oz, 18-count', 24.49, 69, '2023-09-03', 'in-stock'),
(13054, 'G2G 3-pack Almond Chocolate Chip Protein Bars, 24-count', 49.99, 18, '2023-03-29', 'in-stock'),
(13055, 'Kirkland Signature Variety Snack Box, 51-count', 32.99, 43, '2023-10-02', 'in-stock'),
(13056, 'Nature Valley Crunchy Granola Bar, Oats n Honey, 1.49 oz, 49-count', 17.99, 83, '2023-09-13', 'in-stock'),
(13057, 'Doritos Tortilla Chips, Nacho Cheese, 1 oz, 50-count', 22.99, 72, '2023-04-21', 'in-stock'),
(13058, 'Kirkland Signature Extra Fancy Mixed Nuts, Salted, 2.5 lbs', 15.99, 88, '2023-02-02', 'in-stock'),
(13059, 'Jack Links All American Beef Stick, Beef & Cheese, 1.2 oz, 16-count', 19.99, 100, '2023-02-18', 'in-stock'),
(13060, 'Cheez-It Puffd Baked Snacks, Double Cheese, 0.7 oz, 36 count', 19.99, 56, '2024-01-12', 'in-stock'),
(13061, 'Doritos Tortilla Chips, Nacho Cheese, 1.75 oz, 64-count', 44.99, 35, '2023-12-27', 'in-stock'),
(13062, 'Nature Valley Fruit & Nut Chewy Granola Bar, Trail Mix, 1.2 oz, 48-count', 17.99, 61, '2023-10-06', 'in-stock'),
(13063, 'Kirkland Signature, Whole Dried Blueberries, 20 oz', 10.49, 17, '2023-08-17', 'in-stock'),
(13064, 'Power Crunch Protein Energy Bar, French Vanilla, 1.4 oz, 12-count', 17.99, 85, '2023-09-01', 'in-stock'),
(13065, 'Savanna Orchards Honey Roasted Nut & Pistachios 30 oz, 2-pack', 38.99, 23, '2023-10-22', 'in-stock'),
(13066, 'Power Crunch Protein Energy Bar, Triple Chocolate, 1.4 oz, 12-count', 17.99, 51, '2023-06-27', 'in-stock');

INSERT INTO users (id, name, email, password, role) VALUES
(1, 'Admin', 'admin@email.com', 'password', 'admin'),
(2, 'User', 'user@email.com', 'password', 'user');

INSERT INTO customers (id, name, email, image_url) VALUES
(1, 'Delba de Oliveira', 'delba@oliveira.com', '/customers/delba-de-oliveira.png'),
(2, 'Lee Robinson', 'lee@robinson.com', '/customers/lee-robinson.png'),
(3, 'Hector Simpson', 'hector@simpson.com', '/customers/hector-simpson.png'),
(4, 'Steven Tey', 'steven@tey.com', '/customers/steven-tey.png'),
(5, 'Steph Dietz', 'steph@dietz.com', '/customers/steph-dietz.png'),
(6, 'Michael Novotny', 'michael@novotny.com', '/customers/michael-novotny.png'),
(7, 'Evil Rabbit', 'evil@rabbit.com', '/customers/evil-rabbit.png'),
(8, 'Emil Kowalski', 'emil@kowalski.com', '/customers/emil-kowalski.png'),
(9, 'Amy Burns', 'amy@burns.com', '/customers/amy-burns.png'),
(10, 'Balazs Orban', 'balazs@orban.com', '/customers/balazs-orban.png');

INSERT INTO orders (id, customer_id, product_id, quantity, amount, date, status)
VALUES 
(1, 1, 13000, 20, 8.99, '2023-11-06', 'pending'),
(2, 2, 11000, 47, 189.99, '2023-12-14', 'pending'),
(3, 5, 4000, 27, 16.99, '2024-02-29', 'paid'),
(4, 4, 1000, 22, 99.99, '2024-02-10', 'paid');

select count(*) from products;

-- R6 --
-- Filtered search with pagination for products with 'Kirkland' --
SELECT *
FROM products
WHERE
products.id::text ILIKE '%Kirkland%' OR
products.name ILIKE '%Kirkland%' OR
products.category ILIKE '%Kirkland%' OR
products.stock::text ILIKE '%Kirkland%' OR
products.expiry::text ILIKE '%Kirkland%' OR
products.price::text ILIKE '%Kirkland%' OR
products.status ILIKE '%Kirkland%'
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
select * from products where id = 1005;

UPDATE products
SET name = 'Test', price = 99.99, stock = 50
WHERE id = 1005;

select * from products where id = 1005;

-- delete product --
DELETE FROM products WHERE id = 1005;

select * from products where id = 1005;

-- R8 --
-- inserting a new order --
select * from orders where id = 5;

INSERT INTO orders (id, customer_id, product_id, quantity, amount, date, status)
VALUES (5, 6, 2000, 8, 10.49, '2024-05-05', 'pending');

select * from orders where id = 5;

-- editing order --
UPDATE orders
SET status = 'paid'
WHERE id = 5;

select * from orders where id = 5;

-- deleting order --
DELETE FROM orders WHERE id = 5;

select * from orders where id = 5;

-- R9 --
-- inserting a new order --
select products.stock from products where products.id = 2000;

INSERT INTO orders (id, customer_id, product_id, quantity, amount, date, status)
VALUES (5, 6, 2000, 8, 50.99, '2024-05-05', 'pending');

select products.stock from products where products.id = 2000;

-- editing order --
UPDATE orders
SET quantity = 5, status = 'paid'
WHERE id = 5;

select products.stock from products where products.id = 2000;

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
