const { db } = require('@vercel/postgres');
const {
  orders,
  customers,
  revenue,
  users,
} = require('../app/lib/placeholder-data.js');
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
  organic
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
        password TEXT NOT NULL
      );
    `;

    console.log(`Created "users" table`);

    // Insert data into the "users" table
    const insertedUsers = await Promise.all(
      users.map(async (user) => {
        const hashedPassword = await bcrypt.hash(user.password, 10);
        return client.sql`
        INSERT INTO users (id, name, email, password)
        VALUES (${user.id}, ${user.name}, ${user.email}, ${hashedPassword})
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

async function seedOrders(client) {
  try {
    await client.sql`CREATE EXTENSION IF NOT EXISTS "uuid-ossp"`;

    // Create the "orders" table if it doesn't exist
    const createTable = await client.sql`
    CREATE TABLE IF NOT EXISTS orders (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    customer_id UUID NOT NULL,
    amount INT NOT NULL,
    status VARCHAR(255) NOT NULL,
    date DATE NOT NULL
  );
`;

    console.log(`Created "orders" table`);

    // Insert data into the "orders" table
    const insertedOrders = await Promise.all(
      orders.map(
        (order) => client.sql`
        INSERT INTO orders (customer_id, amount, status, date)
        VALUES (${order.customer_id}, ${order.amount}, ${order.status}, ${order.date})
        ON CONFLICT (id) DO NOTHING;
      `,
      ),
    );

    console.log(`Seeded ${insertedOrders.length} orders`);

    return {
      createTable,
      orders: insertedOrders,
    };
  } catch (error) {
    console.error('Error seeding orders:', error);
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
        name VARCHAR(200),
        category VARCHAR(255) NOT NULL,
        stock INT,
        expiry DATE,
        price DECIMAL(10, 2),
        status VARCHAR(255) NOT NULL
      );
    `;

    console.log(`Created "products" table`);

    // Insert data into the "products" table
    const insertedProducts = await Promise.all(
      products.map(
        (p) => client.sql`
        INSERT INTO products (id, name, category, stock, expiry, price, status)
        VALUES (${p.id}, ${p.name}, ${p.category}, ${p.stock}, ${p.expiry}, ${p.price}, ${p.status})
        ON CONFLICT (id) DO NOTHING;
      `,
      ),
    );

    console.log(`Seeded ${insertedProducts.length} products`);

    return {
      createTable,
      products: insertedProducts,
    };
  } catch (error) {
    console.error('Error seeding products:', error);
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
        status VARCHAR(255) NOT NULL
      )
    `;

    console.log(`Created "snacks" table`);

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

    console.log(`Updated table contraints`)

    return {
      createTable,
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
        status VARCHAR(255) NOT NULL
      );
    `;

    console.log(`Created "pantry" table`);

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

    console.log(`Updated table contraints`)

    return {
      createTable,
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
        status VARCHAR(255) NOT NULL
      );
    `;

    console.log(`Created "candy" table`);

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

    console.log(`Updated table contraints`)

    return {
      createTable,
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
        status VARCHAR(255) NOT NULL
      );
    `;

    console.log(`Created "beverages" table`);

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

    console.log(`Updated table contraints`)

    return {
      createTable,
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
        status VARCHAR(255) NOT NULL
      );
    `;

    console.log(`Created "meatAndSeafood" table`);

    // Insert data into the "meatAndSeafood" table
    const insertedMeatAndSeafood = await Promise.all(
      meatAndSeafood.map(
        (m) => client.sql`
        INSERT INTO meatAndSeafood (id, name, stock, expiry, price, status)
        VALUES (${m.id}, ${m.name}, ${m.stock}, ${m.expiry}, ${m.price}, ${m.status})
      `,
      ),
    );

    console.log(`Seeded ${insertedMeatAndSeafood.length} meat and seafood products`);

    const addConstraints = await client.sql`
      ALTER TABLE meatAndSeafood
      ADD CONSTRAINT fk_meat_and_seafood_product
      FOREIGN KEY (id)
      REFERENCES products(id)
      ON DELETE CASCADE
      ON UPDATE CASCADE;
    `;

    console.log(`Updated table contraints`)

    return {
      createTable,
      meatAndSeafood: insertedMeatAndSeafood,
      addConstraints,
    };
  } catch (error) {
    console.error('Error seeding meat and seafood products:', error);
    throw error;
  }
}

async function seedBakeryAndDessert(client) {
  try {
    await client.sql`CREATE EXTENSION IF NOT EXISTS "uuid-ossp"`;

    // Create the "bakeryAndDessert" table if it doesn't exist
    const createTable = await client.sql`
      CREATE TABLE IF NOT EXISTS bakeryAndDessert (
        id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
        name VARCHAR(200),
        stock INT,
        expiry DATE,
        price DECIMAL(10, 2),
        status VARCHAR(255) NOT NULL
      );
    `;

    console.log(`Created "bakeryAndDessert" table`);

    // Insert data into the "bakeryAndDesserts" table
    const insertedBakeryAndDessert = await Promise.all(
      bakeryAndDessert.map(
        (b) => client.sql`
        INSERT INTO bakeryAndDessert (id, name, stock, expiry, price, status)
        VALUES (${b.id}, ${b.name}, ${b.stock}, ${b.expiry}, ${b.price}, ${b.status})
      `,
      ),
    );

    console.log(`Seeded ${insertedBakeryAndDessert.length} bakery and dessert products`);

    const addConstraints = await client.sql`
      ALTER TABLE bakeryAndDessert
      ADD CONSTRAINT fk_bakery_and_dessert_product
      FOREIGN KEY (id)
      REFERENCES products(id)
      ON DELETE CASCADE
      ON UPDATE CASCADE;
    `;

    console.log(`Updated table contraints`)

    return {
      createTable,
      bakeryAndDessert: insertedBakeryAndDessert,
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
        status VARCHAR(255) NOT NULL
      );
    `;

    console.log(`Created "breakfast" table`);

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

    console.log(`Updated table contraints`)

    return {
      createTable,
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
        status VARCHAR(255) NOT NULL
      );
    `;

    console.log(`Created "coffee" table`);

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

    console.log(`Updated table contraints`)

    return {
      createTable,
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
        status VARCHAR(255) NOT NULL
      );
    `;

    console.log(`Created "deli" table`);

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

    console.log(`Updated table contraints`)

    return {
      createTable,
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
        status VARCHAR(255) NOT NULL
      );
    `;

    console.log(`Created "organic" table`);

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

    console.log(`Updated table contraints`)

    return {
      createTable,
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
        status VARCHAR(255) NOT NULL
      );
    `;

    console.log(`Created "cleaning" table`);

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

    console.log(`Updated table contraints`)

    return {
      createTable,
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
        status VARCHAR(255) NOT NULL
      );
    `;

    console.log(`Created "floral" table`);

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

    console.log(`Updated table contraints`)

    return {
      createTable,
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
        status VARCHAR(255) NOT NULL
      );
    `;

    console.log(`Created "household" table`);

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

    console.log(`Updated table contraints`)

    return {
      createTable,
      household: insertedHousehold,
      addConstraints,
    };
  } catch (error) {
    console.error('Error seeding household products:', error);
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
        image_url VARCHAR(255) NOT NULL
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

async function seedRevenue(client) {
  try {
    // Create the "revenue" table if it doesn't exist
    const createTable = await client.sql`
      CREATE TABLE IF NOT EXISTS revenue (
        month VARCHAR(4) NOT NULL UNIQUE,
        revenue INT NOT NULL
      );
    `;

    console.log(`Created "revenue" table`);

    // Insert data into the "revenue" table
    const insertedRevenue = await Promise.all(
      revenue.map(
        (rev) => client.sql`
        INSERT INTO revenue (month, revenue)
        VALUES (${rev.month}, ${rev.revenue})
        ON CONFLICT (month) DO NOTHING;
      `,
      ),
    );

    console.log(`Seeded ${insertedRevenue.length} revenue`);

    return {
      createTable,
      revenue: insertedRevenue,
    };
  } catch (error) {
    console.error('Error seeding revenue:', error);
    throw error;
  }
}

async function main() {
  const client = await db.connect();

  await seedUsers(client);
  await seedProducts(client);
  await seedSnacks(client);
  await seedPantry(client);
  await seedCandy(client);
  await seedBeverages(client);
  await seedMeatAndSeafood(client);
  await seedBakeryAndDessert(client);
  await seedBreakfast(client);
  await seedCoffee(client);
  await seedDeli(client);
  await seedOrganic(client);
  await seedCleaning(client);
  await seedFloral(client);
  await seedHousehold(client);
  await seedCustomers(client);
  await seedOrders(client);
  await seedRevenue(client);

  await client.end();
}

main().catch((err) => {
  console.error(
    'An error occurred while attempting to seed the database:',
    err,
  );
});
