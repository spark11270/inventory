import { sql } from '@vercel/postgres';
import { unstable_noStore as noStore } from 'next/cache';
import {
  CustomerField,
  CustomersTableType,
  OrderForm,
  OrdersTable,
  LatestOrderRaw,
  User,
  Revenue,
  ProductForm,
  ProductsTable,
  ProductField,
} from './definitions';
import { formatCurrency, formatDateToLocal } from './utils';

export async function fetchRevenue() {
  noStore();

  try {
    const data = await sql<Revenue>`SELECT * FROM revenue`;

    const revenue = data.rows.map((revenue) => ({
      ...revenue,
      month: formatDateToLocal(revenue.month),
    }));

    console.log('Data fetch completed after 3 seconds.');
    console.log(revenue[0])

    return revenue;
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch revenue data.');
  }
}

export async function fetchLatestOrders() {
  noStore();

  try {
    const data = await sql<LatestOrderRaw>`
      SELECT orders.amount, customers.name, customers.image_url, customers.email, orders.id
      FROM orders
      JOIN customers ON orders.customer_id = customers.id
      ORDER BY orders.date DESC
      LIMIT 5`;

    const latestOrders = data.rows.map((order) => ({
      ...order,
      amount: formatCurrency(order.amount),
    }));
    return latestOrders;
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch the latest orders.');
  }
}

export async function fetchCardData() {
  noStore();

  try {
    const orderCountPromise = sql`SELECT COUNT(*) FROM orders`;
    const customerCountPromise = sql`SELECT COUNT(*) FROM customers`;
    const orderStatusPromise = sql`
      SELECT
      SUM(CASE WHEN status = 'paid' THEN amount ELSE 0 END) AS "paid",
      SUM(CASE WHEN status = 'pending' THEN amount ELSE 0 END) AS "pending"
      FROM orders
    `;
    const productCountPromise = sql`SELECT COUNT(*) FROM products`;
    const totalRevenuePromise = sql`
      SELECT SUM(revenue) AS total
      FROM revenue;
    `;
    const inStockCountPromise = sql`
      SELECT COUNT(*)
      FROM products
      WHERE status = 'in-stock'
    `;
    const outOfStockCountPromise = sql`
      SELECT COUNT(*)
      FROM products
      WHERE status = 'out-of-stock'
    `;

    const data = await Promise.all([
      orderCountPromise,
      customerCountPromise,
      orderStatusPromise,
      productCountPromise,
      totalRevenuePromise,
      inStockCountPromise,
      outOfStockCountPromise,
    ]);

    const numberOfOrders = Number(data[0].rows[0].count ?? '0');
    const numberOfCustomers = Number(data[1].rows[0].count ?? '0');
    const totalPaidOrders = formatCurrency(data[2].rows[0].paid ?? '0');
    const totalPendingOrders = formatCurrency(data[2].rows[0].pending ?? '0');
    const numberOfProducts = Number(data[3].rows[0].count ?? '0');
    const totalRevenue = formatCurrency(data[4].rows[0].total ?? '0');
    const totalInStock =  Number(data[5].rows[0].count ?? '0');
    const totalOutOfStock =  Number(data[6].rows[0].count ?? '0');

    return {
      numberOfCustomers,
      numberOfOrders,
      totalPaidOrders,
      totalPendingOrders,
      numberOfProducts,
      totalRevenue,
      totalInStock,
      totalOutOfStock,
    };
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch card data.');
  }
}

const ITEMS_PER_PAGE = 6;
export async function fetchFilteredOrders(query: string, currentPage: number) {
  noStore();
  const offset = (currentPage - 1) * ITEMS_PER_PAGE;

  try {
    const orders = await sql<OrdersTable>`
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
        customers.name ILIKE ${`%${query}%`} OR
        products.id::text ILIKE ${`%${query}%`} OR
        products.name ILIKE ${`%${query}%`} OR
        orders.amount::text ILIKE ${`%${query}%`} OR
        orders.date::text ILIKE ${`%${query}%`} OR
        orders.status ILIKE ${`%${query}%`}
      ORDER BY orders.date DESC
      LIMIT ${ITEMS_PER_PAGE} OFFSET ${offset}
    `;

    return orders.rows;
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch orders.');
  }
}

export async function fetchOrdersPages(query: string) {
  noStore();

  try {
    const count = await sql`SELECT COUNT(*)
    FROM orders
    JOIN customers ON orders.customer_id = customers.id
    WHERE
      customers.name ILIKE ${`%${query}%`} OR
      customers.email ILIKE ${`%${query}%`} OR
      orders.amount::text ILIKE ${`%${query}%`} OR
      orders.date::text ILIKE ${`%${query}%`} OR
      orders.status ILIKE ${`%${query}%`}
  `;

    const totalPages = Math.ceil(Number(count.rows[0].count) / ITEMS_PER_PAGE);
    return totalPages;
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch total number of orders.');
  }
}

export async function fetchOrderById(id: string) {
  noStore();

  try {
    const orders = await sql<OrderForm>`
      SELECT
        orders.id,
        orders.customer_id,
        orders.product_id,
        orders.quantity,
        orders.amount,
        orders.status,
        products.category
      FROM orders
      JOIN products ON orders.product_id = products.id
      WHERE orders.id = ${id};
    `;

    return orders.rows[0];
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch order.');
  }
}

export async function fetchProducts() {
  noStore();

  try {
    const products = await sql<ProductField>`
      SELECT id, name, category 
      FROM products
      ORDER BY products.name DESC
      `;

    return products.rows;
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch products.');
  }
}

export async function fetchFilteredProducts(
  query: string,
  currentPage: number,
) {
  noStore();
  const offset = (currentPage - 1) * ITEMS_PER_PAGE;

  try {
    const products = await sql<ProductsTable>`
      SELECT *
      FROM products
      WHERE
        products.id::text ILIKE ${`%${query}%`} OR
        products.name ILIKE ${`%${query}%`} OR
        products.category ILIKE ${`%${query}%`} OR
        products.stock::text ILIKE ${`%${query}%`} OR
        products.expiry::text ILIKE ${`%${query}%`} OR
        products.price::text ILIKE ${`%${query}%`} OR
        products.status ILIKE ${`%${query}%`}
      ORDER BY products.name DESC
      LIMIT ${ITEMS_PER_PAGE} OFFSET ${offset}
    `;

    return products.rows;
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch products.');
  }
}

export async function fetchProductsPages(query: string) {
  noStore();

  try {
    const count = await sql`
    SELECT COUNT(*)
    FROM products
    WHERE
      products.id::text ILIKE ${`%${query}%`} OR
      products.name ILIKE ${`%${query}%`} OR
      products.category ILIKE ${`%${query}%`} OR
      products.stock::text ILIKE ${`%${query}%`} OR
      products.expiry::text ILIKE ${`%${query}%`} OR
      products.price::text ILIKE ${`%${query}%`} OR
      products.status ILIKE ${`%${query}%`}
  `;

    const totalPages = Math.ceil(Number(count.rows[0].count) / ITEMS_PER_PAGE);
    return totalPages;
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch total number of products.');
  }
}

export async function fetchProductById(id: string) {
  noStore();

  try {
    const products = await sql<ProductForm>`
      SELECT *
      FROM products
      WHERE products.id = ${id};
    `;

    return products.rows[0];
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch product.');
  }
}

export async function fetchCustomers() {
  try {
    const data = await sql<CustomerField>`
      SELECT
        id,
        name
      FROM customers
      ORDER BY name ASC
    `;

    const customers = data.rows;
    return customers;
  } catch (err) {
    console.error('Database Error:', err);
    throw new Error('Failed to fetch all customers.');
  }
}

export async function fetchFilteredCustomers(
  query: string,
  currentPage: number,
) {
  noStore();
  const offset = (currentPage - 1) * ITEMS_PER_PAGE;

  try {
    const data = await sql<CustomersTableType>`
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
		  customers.name ILIKE ${`%${query}%`} OR
        customers.email ILIKE ${`%${query}%`}
		GROUP BY customers.id, customers.name, customers.email, customers.image_url
		ORDER BY customers.name ASC
    LIMIT ${ITEMS_PER_PAGE} OFFSET ${offset}
	  `;

    const customers = data.rows.map((customer) => ({
      ...customer,
      total_pending: formatCurrency(customer.total_pending),
      total_paid: formatCurrency(customer.total_paid),
    }));

    return customers;
  } catch (err) {
    console.error('Database Error:', err);
    throw new Error('Failed to fetch customer table.');
  }
}

export async function fetchCustomersPages(query: string) {
  noStore();

  try {
    const count = await sql`SELECT COUNT(*)
    FROM customers
		WHERE
		  customers.name ILIKE ${`%${query}%`} OR
      customers.email ILIKE ${`%${query}%`}
  `;

    const totalPages = Math.ceil(Number(count.rows[0].count) / ITEMS_PER_PAGE);
    return totalPages;
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch total number of customers.');
  }
}

export async function getUser(email: string) {
  try {
    const user = await sql`SELECT * FROM users WHERE email=${email}`;
    return user.rows[0] as User;
  } catch (error) {
    console.error('Failed to fetch user:', error);
    throw new Error('Failed to fetch user.');
  }
}
