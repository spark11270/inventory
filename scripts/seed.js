const { db } = require('@vercel/postgres');
const { orders, customers, users } = require('../app/lib/placeholder-data.js');
const {
  products,
  snacks,
  pantry,
  candy,
  beverages,
  meatAndSeafood,
  bakeryAndDessert,
  breakfast,
  cleaning,
  coffee,
  deli,
  floral,
  household,
  organic,
} = require('../app/lib/DTO.js');
const bcrypt = require('bcrypt');

async function seedUsers(client) {
  try {
    await client.sql`CREATE EXTENSION IF NOT EXISTS "uuid-ossp"`;
    // Create the "users" table if it doesn't exist
    const createTable = await client.sql`
      CREATE TABLE IF NOT EXISTS users (
        id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role VARCHAR(20) NOT NULL CHECK (role IN ('user', 'admin'))
      );
    `;

    console.log(`Created "users" table`);

    // Insert data into the "users" table
    const insertedUsers = await Promise.all(
      users.map(async (user) => {
        const hashedPassword = await bcrypt.hash(user.password, 10);
        return client.sql`
        INSERT INTO users (name, email, password, role)
        VALUES (${user.name}, ${user.email}, ${hashedPassword}, ${user.role})
        ON CONFLICT (id) DO NOTHING;
      `;
      }),
    );

    console.log(`Seeded ${insertedUsers.length} users`);

    return {
      createTable,
      users: insertedUsers,
    };
  } catch (error) {
    console.error('Error seeding users:', error);
    throw error;
  }
}

async function seedProducts(client) {
  try {
    await client.sql`CREATE EXTENSION IF NOT EXISTS "uuid-ossp"`;

    // Create the "products" table if it doesn't exist
    const createTable = await client.sql`
      CREATE TABLE IF NOT EXISTS products (
        id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        category VARCHAR(255) NOT NULL,
        price DECIMAL(10, 2) NOT NULL,
        stock INT NOT NULL,
        expiry DATE,
        status VARCHAR(20) NOT NULL CHECK (status IN ('in-stock', 'out-of-stock'))
      );
    `;

    console.log(`Created "products" table`);

    // Create trigger function to update the status based on the current stock
    const createTriggerFunction = await client.sql`
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
    `;

    // Create trigger to call function before insert / update
    const createTrigger = await client.sql`
      CREATE TRIGGER update_status_trigger
      BEFORE INSERT OR UPDATE ON products
      FOR EACH ROW
      EXECUTE FUNCTION update_product_status();
    `;

    // Create trigger function to update the stock history
    // const createUpdateStockHistory = await client.sql`
    //   CREATE OR REPLACE FUNCTION update_stock_history() RETURNS TRIGGER AS $$
    //   BEGIN
    //     INSERT INTO stock_history (category, stock, valid_from, valid_to)
    //     SELECT
    //       OLD.category,
    //       OLD.stock,
    //       COALESCE((SELECT MAX(valid_to) FROM stock_history WHERE category = OLD.category), '2020-01-01'::TIMESTAMP),
    //       CURRENT_TIMESTAMP
    //     WHERE EXISTS (
    //       SELECT 1 FROM stock_history
    //       WHERE category = OLD.category AND valid_to = 'infinity'
    //     );
    //     UPDATE stock_history
    //     SET valid_to = CURRENT_TIMESTAMP
    //     WHERE category = OLD.category AND valid_to = 'infinity';
    //     INSERT INTO stock_history (category, stock, valid_from, valid_to)
    //     VALUES (NEW.category, NEW.stock, CURRENT_TIMESTAMP, 'infinity')
    //     ON CONFLICT (category, valid_from) DO NOTHING;
    //     RETURN NEW;
    //   END;
    //   $$ LANGUAGE plpgsql;
    // `;

    // // Create trigger to call function after update
    // const triggerUpdateStockHistory = await client.sql`
    //   CREATE TRIGGER update_stock_history_trigger
    //   AFTER UPDATE ON products
    //   FOR EACH ROW
    //   WHEN (OLD.stock IS DISTINCT FROM NEW.stock)
    //   EXECUTE FUNCTION update_stock_history();
    // `;

    // Insert data into the "products" table
    const insertedProducts = await Promise.all(
      products.map(
        (p) => client.sql`
        INSERT INTO products (id, name, category, stock, expiry, price)
        VALUES (${p.id}, ${p.name}, ${p.category}, ${p.stock}, ${p.expiry}, ${p.price})
        ON CONFLICT (id) DO NOTHING;
      `,
      ),
    );

    console.log(`Seeded ${insertedProducts.length} products`);

    return {
      createTable,
      createTriggerFunction,
      // createUpdateStockHistory,
      createTrigger,
      // triggerUpdateStockHistory,
      products: insertedProducts,
    };
  } catch (error) {
    console.error('Error seeding products:', error);
    throw error;
  }
}

async function seedStockHistory(client) {
  try {
    await client.sql`CREATE EXTENSION IF NOT EXISTS "uuid-ossp"`;

    // Create the "stock_history" table if it doesn't exist
    const createTable = await client.sql`
      CREATE TABLE IF NOT EXISTS stock_history (
        category VARCHAR(255) NOT NULL,
        stock INT NOT NULL,
        valid_from TIMESTAMP NOT NULL,
        valid_to TIMESTAMP NOT NULL,
        PRIMARY KEY (category, valid_from)
      );
    `;

    console.log(`Created "stock_history" table`);

    return {
      createTable,
    };
  } catch (error) {
    console.error('Error seeding stock history:', error);
    throw error;
  }
}

async function seedCustomers(client) {
  try {
    await client.sql`CREATE EXTENSION IF NOT EXISTS "uuid-ossp"`;

    // Create the "customers" table if it doesn't exist
    const createTable = await client.sql`
      CREATE TABLE IF NOT EXISTS customers (
        id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255) NOT NULL,
        image_url VARCHAR(255)
      );
    `;

    console.log(`Created "customers" table`);

    // Insert data into the "customers" table
    const insertedCustomers = await Promise.all(
      customers.map(
        (customer) => client.sql`
        INSERT INTO customers (id, name, email, image_url)
        VALUES (${customer.id}, ${customer.name}, ${customer.email}, ${customer.image_url})
        ON CONFLICT (id) DO NOTHING;
      `,
      ),
    );

    console.log(`Seeded ${insertedCustomers.length} customers`);

    return {
      createTable,
      customers: insertedCustomers,
    };
  } catch (error) {
    console.error('Error seeding customers:', error);
    throw error;
  }
}

async function seedOrders(client) {
  try {
    await client.sql`CREATE EXTENSION IF NOT EXISTS "uuid-ossp"`;

    // Create the "orders" table if it doesn't exist
    const createTable = await client.sql`
    CREATE TABLE IF NOT EXISTS orders (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    customer_id UUID NOT NULL REFERENCES customers(id),
    product_id UUID NOT NULL REFERENCES products(id),
    quantity INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'paid'))
  );
`;

    console.log(`Created "orders" table`);

    // Create trigger function to verify inputted quantity with current product stock
    const createCheckStock = await client.sql`
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
    `;

    // Create trigger to call function before insert / update
    const triggerCheckStock = await client.sql`
    CREATE TRIGGER check_stock_trigger
    BEFORE INSERT OR UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION check_product_stock();
    `;

    // Create trigger function to update order amount
    const createUpdateAmount = await client.sql`
    CREATE OR REPLACE FUNCTION update_order_amount() RETURNS TRIGGER AS $$
    DECLARE
      product_price DECIMAL(10, 2);
    BEGIN
      SELECT price INTO product_price FROM products WHERE id = NEW.product_id;
      NEW.amount := NEW.quantity * product_price;
      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;
    `;

    // Create trigger to call function before insert / update
    const triggerUpdateAmount = await client.sql`
      CREATE TRIGGER update_amount_trigger
      BEFORE INSERT OR UPDATE ON orders
      FOR EACH ROW
      EXECUTE FUNCTION update_order_amount();
    `;

    // Create trigger function to reduce product stock
    const createReduceStock = await client.sql`
      CREATE OR REPLACE FUNCTION reduce_product_stock() RETURNS TRIGGER AS $$
      BEGIN
        UPDATE products
        SET stock = stock - NEW.quantity
        WHERE id = NEW.product_id;
        RETURN NULL;
      END;
      $$ LANGUAGE plpgsql;
    `;

    // Create trigger to call function after insert/update
    const triggerReduceStock = await client.sql`
      CREATE TRIGGER reduce_stock_trigger
      AFTER INSERT OR UPDATE ON orders
      FOR EACH ROW
      EXECUTE FUNCTION reduce_product_stock();
    `;

    // Create trigger function to revert product stock
    const createRevertStock = await client.sql`
      CREATE OR REPLACE FUNCTION revert_product_stock() RETURNS TRIGGER AS $$
      BEGIN
        UPDATE products
        SET stock = stock + OLD.quantity
        WHERE id = OLD.product_id;
        RETURN NULL;
      END;
      $$ LANGUAGE plpgsql;
    `;

    // Create trigger to call function after delete
    const triggerRevertStockDelete = await client.sql`
      CREATE TRIGGER revert_stock_trigger_delete
      AFTER DELETE ON orders
      FOR EACH ROW
      EXECUTE FUNCTION revert_product_stock();
    `;

    // Create trigger to call function before update
    const triggerRevertStockUpdate = await client.sql`
      CREATE TRIGGER revert_stock_trigger_update
      BEFORE UPDATE ON orders
      FOR EACH ROW
      EXECUTE FUNCTION revert_product_stock();
    `;

    // Create trigger function to update revenue
    const createUpdateRevenue = await client.sql`
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
  `;

    // Create trigger to call function after an order is inserted/updated
    const triggerUpdateRevenue = await client.sql`
    CREATE TRIGGER update_revenue_trigger
    AFTER INSERT OR UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION update_revenue();
  `;

    // Insert data into the "orders" table
    const insertedOrders = await Promise.all(
      orders.map(
        (order) => client.sql`
        INSERT INTO orders (customer_id, product_id, quantity, date, status)
        VALUES (${order.customer_id}, ${order.product_id}, ${order.quantity}, ${order.date}, ${order.status})
      `,
      ),
    );

    console.log(`Seeded ${insertedOrders.length} orders`);

    return {
      createTable,
      createCheckStock,
      triggerCheckStock,
      createUpdateAmount,
      createReduceStock,
      createRevertStock,
      createUpdateRevenue,
      triggerUpdateAmount,
      triggerReduceStock,
      triggerRevertStockDelete,
      triggerRevertStockUpdate,
      triggerUpdateRevenue,
      orders: insertedOrders,
    };
  } catch (error) {
    console.error('Error seeding orders:', error);
    throw error;
  }
}

async function seedRevenue(client) {
  try {
    // Create the "revenue" table if it doesn't exist
    const createTable = await client.sql`
      CREATE TABLE IF NOT EXISTS revenue (
        month DATE NOT NULL UNIQUE,
        revenue INT NOT NULL
      );
    `;

    console.log(`Created "revenue" table`);

    return {
      createTable,
    };
  } catch (error) {
    console.error('Error seeding revenue:', error);
    throw error;
  }
}

async function seedSnacks(client) {
  try {
    await client.sql`CREATE EXTENSION IF NOT EXISTS "uuid-ossp"`;

    // Create the "snacks" table if it doesn't exist
    const createTable = await client.sql`
      CREATE TABLE IF NOT EXISTS snacks (
        id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
        name VARCHAR(200),
        stock INT,
        expiry DATE,
        price DECIMAL(10, 2),
        status VARCHAR(20) NOT NULL CHECK (status IN ('in-stock', 'out-of-stock'))
      )
    `;

    console.log(`Created "snacks" table`);

    // Create trigger function to update the status based on the current stock
    const createTriggerFunction = await client.sql`
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
    `;

    // Create trigger to call function before insert / update
    const createTrigger = await client.sql`
      CREATE TRIGGER update_status_trigger
      BEFORE INSERT OR UPDATE ON snacks
      FOR EACH ROW
      EXECUTE FUNCTION update_snacks_status();
    `;

    // Insert data into the "snacks" table
    const insertedSnacks = await Promise.all(
      snacks.map(
        (s) => client.sql`
        INSERT INTO snacks (id, name, stock, expiry, price, status)
        VALUES (${s.id}, ${s.name}, ${s.stock}, ${s.expiry}, ${s.price}, ${s.status})
      `,
      ),
    );

    console.log(`Seeded ${insertedSnacks.length} snacks`);

    const addConstraints = await client.sql`
      ALTER TABLE snacks
      ADD CONSTRAINT fk_snack_product
      FOREIGN KEY (id)
      REFERENCES products(id)
      ON DELETE CASCADE
      ON UPDATE CASCADE;
    `;

    console.log(`Updated table contraints`);

    return {
      createTable,
      createTriggerFunction,
      createTrigger,
      snacks: insertedSnacks,
      addConstraints,
    };
  } catch (error) {
    console.error('Error seeding snacks:', error);
    throw error;
  }
}

async function seedPantry(client) {
  try {
    await client.sql`CREATE EXTENSION IF NOT EXISTS "uuid-ossp"`;

    // Create the "pantry" table if it doesn't exist
    const createTable = await client.sql`
      CREATE TABLE IF NOT EXISTS pantry (
        id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
        name VARCHAR(200),
        stock INT,
        expiry DATE,
        price DECIMAL(10, 2),
        status VARCHAR(20) NOT NULL CHECK (status IN ('in-stock', 'out-of-stock'))
      );
    `;

    console.log(`Created "pantry" table`);

    // Create trigger function to update the status based on the current stock
    const createTriggerFunction = await client.sql`
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
    `;

    // Create trigger to call function before insert / update
    const createTrigger = await client.sql`
      CREATE TRIGGER update_status_trigger
      BEFORE INSERT OR UPDATE ON pantry
      FOR EACH ROW
      EXECUTE FUNCTION update_pantry_status();
    `;

    // Insert data into the "pantry" table
    const insertedPantry = await Promise.all(
      pantry.map(
        (p) => client.sql`
        INSERT INTO pantry (id, name, stock, expiry, price, status)
        VALUES (${p.id}, ${p.name}, ${p.stock}, ${p.expiry}, ${p.price}, ${p.status})
      `,
      ),
    );

    console.log(`Seeded ${insertedPantry.length} pantry products`);

    const addConstraints = await client.sql`
      ALTER TABLE pantry
      ADD CONSTRAINT fk_pantry_product
      FOREIGN KEY (id)
      REFERENCES products(id)
      ON DELETE CASCADE
      ON UPDATE CASCADE;
    `;

    console.log(`Updated table contraints`);

    return {
      createTable,
      createTriggerFunction,
      createTrigger,
      pantry: insertedPantry,
      addConstraints,
    };
  } catch (error) {
    console.error('Error seeding pantry products:', error);
    throw error;
  }
}

async function seedCandy(client) {
  try {
    await client.sql`CREATE EXTENSION IF NOT EXISTS "uuid-ossp"`;

    // Create the "candy" table if it doesn't exist
    const createTable = await client.sql`
      CREATE TABLE IF NOT EXISTS candy (
        id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
        name VARCHAR(200),
        stock INT,
        expiry DATE,
        price DECIMAL(10, 2),
        status VARCHAR(20) NOT NULL CHECK (status IN ('in-stock', 'out-of-stock'))
      );
    `;

    console.log(`Created "candy" table`);

    // Create trigger function to update the status based on the current stock
    const createTriggerFunction = await client.sql`
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
    `;

    // Create trigger to call function before insert / update
    const createTrigger = await client.sql`
      CREATE TRIGGER update_status_trigger
      BEFORE INSERT OR UPDATE ON candy
      FOR EACH ROW
      EXECUTE FUNCTION update_candy_status();
    `;

    // Insert data into the "candy" table
    const insertedCandy = await Promise.all(
      candy.map(
        (c) => client.sql`
        INSERT INTO candy (id, name, stock, expiry, price, status)
        VALUES (${c.id}, ${c.name}, ${c.stock}, ${c.expiry}, ${c.price}, ${c.status})
      `,
      ),
    );

    console.log(`Seeded ${insertedCandy.length} candy products`);

    const addConstraints = await client.sql`
      ALTER TABLE candy
      ADD CONSTRAINT fk_candy_product
      FOREIGN KEY (id)
      REFERENCES products(id)
      ON DELETE CASCADE
      ON UPDATE CASCADE;
    `;

    console.log(`Updated table contraints`);

    return {
      createTable,
      createTriggerFunction,
      createTrigger,
      candy: insertedCandy,
      addConstraints,
    };
  } catch (error) {
    console.error('Error seeding candy products:', error);
    throw error;
  }
}

async function seedBeverages(client) {
  try {
    await client.sql`CREATE EXTENSION IF NOT EXISTS "uuid-ossp"`;

    // Create the "beverages" table if it doesn't exist
    const createTable = await client.sql`
      CREATE TABLE IF NOT EXISTS beverages (
        id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
        name VARCHAR(200),
        stock INT,
        expiry DATE,
        price DECIMAL(10, 2),
        status VARCHAR(20) NOT NULL CHECK (status IN ('in-stock', 'out-of-stock'))
      );
    `;

    console.log(`Created "beverages" table`);

    // Create trigger function to update the status based on the current stock
    const createTriggerFunction = await client.sql`
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
    `;

    // Create trigger to call function before insert / update
    const createTrigger = await client.sql`
      CREATE TRIGGER update_status_trigger
      BEFORE INSERT OR UPDATE ON beverages
      FOR EACH ROW
      EXECUTE FUNCTION update_beverages_status();
    `;

    // Insert data into the "beverages" table
    const insertedBeverages = await Promise.all(
      beverages.map(
        (b) => client.sql`
        INSERT INTO beverages (id, name, stock, expiry, price, status)
        VALUES (${b.id}, ${b.name}, ${b.stock}, ${b.expiry}, ${b.price}, ${b.status})
      `,
      ),
    );

    console.log(`Seeded ${insertedBeverages.length} beverages`);

    const addConstraints = await client.sql`
      ALTER TABLE beverages
      ADD CONSTRAINT fk_beverage_product
      FOREIGN KEY (id)
      REFERENCES products(id)
      ON DELETE CASCADE
      ON UPDATE CASCADE;
    `;

    console.log(`Updated table contraints`);

    return {
      createTable,
      createTriggerFunction,
      createTrigger,
      beverages: insertedBeverages,
      addConstraints,
    };
  } catch (error) {
    console.error('Error seeding beverages:', error);
    throw error;
  }
}

async function seedMeatAndSeafood(client) {
  try {
    await client.sql`CREATE EXTENSION IF NOT EXISTS "uuid-ossp"`;

    // Create the "meatAndSeafood" table if it doesn't exist
    const createTable = await client.sql`
      CREATE TABLE IF NOT EXISTS meatAndSeafood (
        id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
        name VARCHAR(200),
        stock INT,
        expiry DATE,
        price DECIMAL(10, 2),
        status VARCHAR(20) NOT NULL CHECK (status IN ('in-stock', 'out-of-stock'))
      );
    `;

    console.log(`Created "meatAndSeafood" table`);

    // Create trigger function to update the status based on the current stock
    const createTriggerFunction = await client.sql`
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
    `;

    // Create trigger to call function before insert / update
    const createTrigger = await client.sql`
      CREATE TRIGGER update_status_trigger
      BEFORE INSERT OR UPDATE ON meatAndSeafood
      FOR EACH ROW
      EXECUTE FUNCTION update_meatAndSeafood_status();
    `;

    // Insert data into the "meatAndSeafood" table
    const insertedMeatAndSeafood = await Promise.all(
      meatAndSeafood.map(
        (m) => client.sql`
        INSERT INTO meatAndSeafood (id, name, stock, expiry, price, status)
        VALUES (${m.id}, ${m.name}, ${m.stock}, ${m.expiry}, ${m.price}, ${m.status})
      `,
      ),
    );

    console.log(
      `Seeded ${insertedMeatAndSeafood.length} meat and seafood products`,
    );

    const addConstraints = await client.sql`
      ALTER TABLE meatAndSeafood
      ADD CONSTRAINT fk_meat_and_seafood_product
      FOREIGN KEY (id)
      REFERENCES products(id)
      ON DELETE CASCADE
      ON UPDATE CASCADE;
    `;

    console.log(`Updated table contraints`);

    return {
      createTable,
      createTriggerFunction,
      createTrigger,
      meatAndSeafood: insertedMeatAndSeafood,
      addConstraints,
    };
  } catch (error) {
    console.error('Error seeding meat and seafood products:', error);
    throw error;
  }
}

async function seedBakeryAndDesserts(client) {
  try {
    await client.sql`CREATE EXTENSION IF NOT EXISTS "uuid-ossp"`;

    // Create the "bakeryAndDesserts" table if it doesn't exist
    const createTable = await client.sql`
      CREATE TABLE IF NOT EXISTS bakeryAndDesserts (
        id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
        name VARCHAR(200),
        stock INT,
        expiry DATE,
        price DECIMAL(10, 2),
        status VARCHAR(20) NOT NULL CHECK (status IN ('in-stock', 'out-of-stock'))
      );
    `;

    console.log(`Created "bakeryAndDesserts" table`);

    // Create trigger function to update the status based on the current stock
    const createTriggerFunction = await client.sql`
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
    `;

    // Create trigger to call function before insert / update
    const createTrigger = await client.sql`
      CREATE TRIGGER update_status_trigger
      BEFORE INSERT OR UPDATE ON bakeryAndDesserts
      FOR EACH ROW
      EXECUTE FUNCTION update_snacks_status();
    `;

    // Insert data into the "bakeryAndDesserts" table
    const insertedBakeryAndDesserts = await Promise.all(
      bakeryAndDessert.map(
        (b) => client.sql`
        INSERT INTO bakeryAndDesserts (id, name, stock, expiry, price, status)
        VALUES (${b.id}, ${b.name}, ${b.stock}, ${b.expiry}, ${b.price}, ${b.status})
      `,
      ),
    );

    console.log(
      `Seeded ${insertedBakeryAndDesserts.length} bakery and dessert products`,
    );

    const addConstraints = await client.sql`
      ALTER TABLE bakeryAndDesserts
      ADD CONSTRAINT fk_bakery_and_dessert_product
      FOREIGN KEY (id)
      REFERENCES products(id)
      ON DELETE CASCADE
      ON UPDATE CASCADE;
    `;

    console.log(`Updated table contraints`);

    return {
      createTable,
      createTriggerFunction,
      createTrigger,
      bakeryAndDessert: insertedBakeryAndDesserts,
      addConstraints,
    };
  } catch (error) {
    console.error('Error seeding bakery and dessert products:', error);
    throw error;
  }
}

async function seedBreakfast(client) {
  try {
    await client.sql`CREATE EXTENSION IF NOT EXISTS "uuid-ossp"`;

    // Create the "breakfast" table if it doesn't exist
    const createTable = await client.sql`
      CREATE TABLE IF NOT EXISTS breakfast (
        id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
        name VARCHAR(200),
        stock INT,
        expiry DATE,
        price DECIMAL(10, 2),
        status VARCHAR(20) NOT NULL CHECK (status IN ('in-stock', 'out-of-stock'))
      );
    `;

    console.log(`Created "breakfast" table`);

    // Create trigger function to update the status based on the current stock
    const createTriggerFunction = await client.sql`
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
    `;

    // Create trigger to call function before insert / update
    const createTrigger = await client.sql`
      CREATE TRIGGER update_status_trigger
      BEFORE INSERT OR UPDATE ON breakfast
      FOR EACH ROW
      EXECUTE FUNCTION update_breakfast_status();
    `;

    // Insert data into the "breakfast" table
    const insertedBreakfast = await Promise.all(
      breakfast.map(
        (b) => client.sql`
        INSERT INTO breakfast (id, name, stock, expiry, price, status)
        VALUES (${b.id}, ${b.name}, ${b.stock}, ${b.expiry}, ${b.price}, ${b.status})
      `,
      ),
    );

    console.log(`Seeded ${insertedBreakfast.length} breakfast products`);

    const addConstraints = await client.sql`
      ALTER TABLE breakfast
      ADD CONSTRAINT fk_breakfast_product
      FOREIGN KEY (id)
      REFERENCES products(id)
      ON DELETE CASCADE
      ON UPDATE CASCADE;
    `;

    console.log(`Updated table contraints`);

    return {
      createTable,
      createTriggerFunction,
      createTrigger,
      breakfast: insertedBreakfast,
      addConstraints,
    };
  } catch (error) {
    console.error('Error seeding breakfast products:', error);
    throw error;
  }
}

async function seedCoffee(client) {
  try {
    await client.sql`CREATE EXTENSION IF NOT EXISTS "uuid-ossp"`;

    // Create the "coffee" table if it doesn't exist
    const createTable = await client.sql`
      CREATE TABLE IF NOT EXISTS coffee (
        id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
        name VARCHAR(200),
        stock INT,
        expiry DATE,
        price DECIMAL(10, 2),
        status VARCHAR(20) NOT NULL CHECK (status IN ('in-stock', 'out-of-stock'))
      );
    `;

    console.log(`Created "coffee" table`);

    // Create trigger function to update the status based on the current stock
    const createTriggerFunction = await client.sql`
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
    `;

    // Create trigger to call function before insert / update
    const createTrigger = await client.sql`
      CREATE TRIGGER update_status_trigger
      BEFORE INSERT OR UPDATE ON coffee
      FOR EACH ROW
      EXECUTE FUNCTION update_coffee_status();
    `;

    // Insert data into the "coffee" table
    const insertedCoffee = await Promise.all(
      coffee.map(
        (c) => client.sql`
        INSERT INTO coffee (id, name, stock, expiry, price, status)
        VALUES (${c.id}, ${c.name}, ${c.stock}, ${c.expiry}, ${c.price}, ${c.status})
      `,
      ),
    );

    console.log(`Seeded ${insertedCoffee.length} coffee products`);

    const addConstraints = await client.sql`
      ALTER TABLE coffee
      ADD CONSTRAINT fk_coffee_product
      FOREIGN KEY (id)
      REFERENCES products(id)
      ON DELETE CASCADE
      ON UPDATE CASCADE;
    `;

    console.log(`Updated table contraints`);

    return {
      createTable,
      createTriggerFunction,
      createTrigger,
      coffee: insertedCoffee,
      addConstraints,
    };
  } catch (error) {
    console.error('Error seeding coffee products:', error);
    throw error;
  }
}

async function seedDeli(client) {
  try {
    await client.sql`CREATE EXTENSION IF NOT EXISTS "uuid-ossp"`;

    // Create the "deli" table if it doesn't exist
    const createTable = await client.sql`
      CREATE TABLE IF NOT EXISTS deli (
        id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
        name VARCHAR(200),
        stock INT,
        expiry DATE,
        price DECIMAL(10, 2),
        status VARCHAR(20) NOT NULL CHECK (status IN ('in-stock', 'out-of-stock'))
      );
    `;

    console.log(`Created "deli" table`);

    // Create trigger function to update the status based on the current stock
    const createTriggerFunction = await client.sql`
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
    `;

    // Create trigger to call function before insert / update
    const createTrigger = await client.sql`
      CREATE TRIGGER update_status_trigger
      BEFORE INSERT OR UPDATE ON deli
      FOR EACH ROW
      EXECUTE FUNCTION update_deli_status();
    `;

    // Insert data into the "deli" table
    const insertedDeli = await Promise.all(
      deli.map(
        (d) => client.sql`
        INSERT INTO deli (id, name, stock, expiry, price, status)
        VALUES (${d.id}, ${d.name}, ${d.stock}, ${d.expiry}, ${d.price}, ${d.status})
      `,
      ),
    );

    console.log(`Seeded ${insertedDeli.length} deli products`);

    const addConstraints = await client.sql`
      ALTER TABLE deli
      ADD CONSTRAINT fk_deli_product
      FOREIGN KEY (id)
      REFERENCES products(id)
      ON DELETE CASCADE
      ON UPDATE CASCADE;
    `;

    console.log(`Updated table contraints`);

    return {
      createTable,
      createTriggerFunction,
      createTrigger,
      deli: insertedDeli,
      addConstraints,
    };
  } catch (error) {
    console.error('Error seeding deli products:', error);
    throw error;
  }
}

async function seedOrganic(client) {
  try {
    await client.sql`CREATE EXTENSION IF NOT EXISTS "uuid-ossp"`;

    // Create the "organic" table if it doesn't exist
    const createTable = await client.sql`
      CREATE TABLE IF NOT EXISTS organic (
        id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
        name VARCHAR(200),
        stock INT,
        expiry DATE,
        price DECIMAL(10, 2),
        status VARCHAR(20) NOT NULL CHECK (status IN ('in-stock', 'out-of-stock'))
      );
    `;

    console.log(`Created "organic" table`);

    // Create trigger function to update the status based on the current stock
    const createTriggerFunction = await client.sql`
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
    `;

    // Create trigger to call function before insert / update
    const createTrigger = await client.sql`
      CREATE TRIGGER update_status_trigger
      BEFORE INSERT OR UPDATE ON organic
      FOR EACH ROW
      EXECUTE FUNCTION update_organic_status();
    `;

    // Insert data into the "organic" table
    const insertedOrganic = await Promise.all(
      organic.map(
        (o) => client.sql`
        INSERT INTO organic (id, name, stock, expiry, price, status)
        VALUES (${o.id}, ${o.name}, ${o.stock}, ${o.expiry}, ${o.price}, ${o.status})
      `,
      ),
    );

    console.log(`Seeded ${insertedOrganic.length} organic products`);

    const addConstraints = await client.sql`
      ALTER TABLE organic
      ADD CONSTRAINT fk_organic_product
      FOREIGN KEY (id)
      REFERENCES products(id)
      ON DELETE CASCADE
      ON UPDATE CASCADE;
    `;

    console.log(`Updated table contraints`);

    return {
      createTable,
      createTriggerFunction,
      createTrigger,
      organic: insertedOrganic,
      addConstraints,
    };
  } catch (error) {
    console.error('Error seeding organic products:', error);
    throw error;
  }
}

async function seedCleaning(client) {
  try {
    await client.sql`CREATE EXTENSION IF NOT EXISTS "uuid-ossp"`;

    // Create the "cleaning" table if it doesn't exist
    const createTable = await client.sql`
      CREATE TABLE IF NOT EXISTS cleaning (
        id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
        name VARCHAR(200),
        stock INT,
        price DECIMAL(10, 2),
        status VARCHAR(20) NOT NULL CHECK (status IN ('in-stock', 'out-of-stock'))
      );
    `;

    console.log(`Created "cleaning" table`);

    // Create trigger function to update the status based on the current stock
    const createTriggerFunction = await client.sql`
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
    `;

    // Create trigger to call function before insert / update
    const createTrigger = await client.sql`
      CREATE TRIGGER update_status_trigger
      BEFORE INSERT OR UPDATE ON cleaning
      FOR EACH ROW
      EXECUTE FUNCTION update_cleaning_status();
    `;

    // Insert data into the "cleaning" table
    const insertedCleaning = await Promise.all(
      cleaning.map(
        (c) => client.sql`
        INSERT INTO cleaning (id, name, stock, price, status)
        VALUES (${c.id}, ${c.name}, ${c.stock}, ${c.price}, ${c.status})
      `,
      ),
    );

    console.log(`Seeded ${insertedCleaning.length} cleaning products`);

    const addConstraints = await client.sql`
      ALTER TABLE cleaning
      ADD CONSTRAINT fk_cleaning_product
      FOREIGN KEY (id)
      REFERENCES products(id)
      ON DELETE CASCADE
      ON UPDATE CASCADE;
    `;

    console.log(`Updated table contraints`);

    return {
      createTable,
      createTriggerFunction,
      createTrigger,
      cleaning: insertedCleaning,
      addConstraints,
    };
  } catch (error) {
    console.error('Error seeding cleaning products:', error);
    throw error;
  }
}

async function seedFloral(client) {
  try {
    await client.sql`CREATE EXTENSION IF NOT EXISTS "uuid-ossp"`;

    // Create the "floral" table if it doesn't exist
    const createTable = await client.sql`
      CREATE TABLE IF NOT EXISTS floral (
        id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
        name VARCHAR(200),
        stock INT,
        price DECIMAL(10, 2),
        status VARCHAR(20) NOT NULL CHECK (status IN ('in-stock', 'out-of-stock'))
      );
    `;

    console.log(`Created "floral" table`);

    // Create trigger function to update the status based on the current stock
    const createTriggerFunction = await client.sql`
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
    `;

    // Create trigger to call function before insert / update
    const createTrigger = await client.sql`
      CREATE TRIGGER update_status_trigger
      BEFORE INSERT OR UPDATE ON floral
      FOR EACH ROW
      EXECUTE FUNCTION update_floral_status();
    `;

    // Insert data into the "floral" table
    const insertedFloral = await Promise.all(
      floral.map(
        (f) => client.sql`
        INSERT INTO floral (id, name, stock, price, status)
        VALUES (${f.id}, ${f.name}, ${f.stock}, ${f.price}, ${f.status})
      `,
      ),
    );

    console.log(`Seeded ${insertedFloral.length} floral products`);

    const addConstraints = await client.sql`
      ALTER TABLE floral
      ADD CONSTRAINT fk_floral_product
      FOREIGN KEY (id)
      REFERENCES products(id)
      ON DELETE CASCADE
      ON UPDATE CASCADE;
    `;

    console.log(`Updated table contraints`);

    return {
      createTable,
      createTriggerFunction,
      createTrigger,
      floral: insertedFloral,
      addConstraints,
    };
  } catch (error) {
    console.error('Error seeding floral products:', error);
    throw error;
  }
}

async function seedHousehold(client) {
  try {
    await client.sql`CREATE EXTENSION IF NOT EXISTS "uuid-ossp"`;

    // Create the "household" table if it doesn't exist
    const createTable = await client.sql`
      CREATE TABLE IF NOT EXISTS household (
        id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
        name VARCHAR(200),
        stock INT,
        price DECIMAL(10, 2),
        status VARCHAR(20) NOT NULL CHECK (status IN ('in-stock', 'out-of-stock'))
      );
    `;

    console.log(`Created "household" table`);

    // Create trigger function to update the status based on the current stock
    const createTriggerFunction = await client.sql`
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
    `;

    // Create trigger to call function before insert / update
    const createTrigger = await client.sql`
      CREATE TRIGGER update_status_trigger
      BEFORE INSERT OR UPDATE ON household
      FOR EACH ROW
      EXECUTE FUNCTION update_household_status();
    `;

    // Insert data into the "household" table
    const insertedHousehold = await Promise.all(
      household.map(
        (h) => client.sql`
        INSERT INTO household (id, name, stock, price, status)
        VALUES (${h.id}, ${h.name}, ${h.stock}, ${h.price}, ${h.status})
      `,
      ),
    );

    console.log(`Seeded ${insertedHousehold.length} household products`);

    const addConstraints = await client.sql`
      ALTER TABLE household
      ADD CONSTRAINT fk_household_product
      FOREIGN KEY (id)
      REFERENCES products(id)
      ON DELETE CASCADE
      ON UPDATE CASCADE;
    `;

    console.log(`Updated table contraints`);

    return {
      createTable,
      createTriggerFunction,
      createTrigger,
      household: insertedHousehold,
      addConstraints,
    };
  } catch (error) {
    console.error('Error seeding household products:', error);
    throw error;
  }
}

async function main() {
  const client = await db.connect();

  await seedUsers(client);
  await seedCustomers(client);
  await seedStockHistory(client);
  await seedProducts(client);
  await seedSnacks(client);
  await seedPantry(client);
  await seedCandy(client);
  await seedBeverages(client);
  await seedMeatAndSeafood(client);
  await seedBakeryAndDesserts(client);
  await seedBreakfast(client);
  await seedCoffee(client);
  await seedDeli(client);
  await seedOrganic(client);
  await seedCleaning(client);
  await seedFloral(client);
  await seedHousehold(client);
  await seedRevenue(client);
  await seedOrders(client);

  await client.end();
}

main().catch((err) => {
  console.error(
    'An error occurred while attempting to seed the database:',
    err,
  );
});
