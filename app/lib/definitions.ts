export type User = {
  id: string;
  name: string;
  email: string;
  password: string;
};

export type Customer = {
  id: string;
  name: string;
  email: string;
  image_url: string;
};

export type Product = {
  id: string;
  name: string;
  category: string;
  price: string;
  stock: number;
  expiry: string;
  status: 'in-stock' | 'out-of-stock';
};

export type Order = {
  id: string;
  customer_id: string;
  amount: number;
  date: string;
  status: 'pending' | 'paid';
};

export type Revenue = {
  month: string;
  revenue: number;
};

export type LatestOrder = {
  id: string;
  name: string;
  image_url: string;
  email: string;
  amount: string;
};

export type LatestOrderRaw = Omit<LatestOrder, 'amount'> & {
  amount: number;
};

export type OrdersTable = {
  id: string;
  customer_id: string;
  name: string;
  email: string;
  image_url: string;
  date: string;
  amount: number;
  status: 'pending' | 'paid';
};

export type ProductsTable = {
  id: string;
  name: string;
  category: string;
  price: number;
  expiry: string;
  status: 'in-stock' | 'out-of-stock';
};

export type CustomersTableType = {
  id: string;
  name: string;
  email: string;
  image_url: string;
  total_orders: number;
  total_pending: number;
  total_paid: number;
};

export type FormattedCustomersTable = {
  id: string;
  name: string;
  email: string;
  image_url: string;
  total_orders: number;
  total_pending: string;
  total_paid: string;
};

export type CustomerField = {
  id: string;
  name: string;
};

export type OrderForm = {
  id: string;
  customer_id: string;
  amount: number;
  status: 'pending' | 'paid';
};

export type ProductForm = {
  id: string;
  name: string;
  category: Category;
  stock: number;
  price: number;
};