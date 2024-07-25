'use server';

import { sql } from '@vercel/postgres';
import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';
import { z } from 'zod';
import { v4 as uuidv4 } from 'uuid';

export type State = {
  errors?: {
    name?: string[];
    category?: string[];
    price?: string[];
    stock?: string[];
    expiry?: string[];
  };
  message?: string | null;
};

const FormSchema = z.object({
  id: z.string(),
  name: z.string({
    required_error: 'Please input a name',
  }),
  category: z.enum(
    [
      'snacks',
      'pantry',
      'candy',
      'beverages',
      'meatAndSeafood',
      'bakeryAndDesserts',
      'breakfast',
      'coffee',
      'deli',
      'organic',
      'cleaning',
      'floral',
      'household',
    ],
    {
      invalid_type_error: 'Please select a category',
    },
  ),
  price: z.coerce
    .number()
    .gt(0, { message: 'Please enter an amount greater than $0.' }),
  stock: z.coerce.number().gt(-1, { message: 'Please enter a valid amount.' }),
  expiry: z.coerce
    .date()
    .refine((data) => data > new Date(), {
      message: 'Expiry date must be in the future',
    }),
});

const CreateProduct = FormSchema.omit({ id: true });
const UpdateProduct = FormSchema;

export async function createProduct(prevState: State, formData: FormData) {
  // Validate form using Zod
  const validatedFields = CreateProduct.safeParse({
    name: formData.get('name'),
    category: formData.get('category'),
    price: formData.get('price'),
    stock: formData.get('stock'),
    expiry: formData.get('expiry'),
  });

  // If form validation fails, return errors early. Otherwise, continue.
  if (!validatedFields.success) {
    return {
      errors: validatedFields.error.flatten().fieldErrors,
      message: 'Missing Fields. Failed to Create Product.',
    };
  }

  // Prepare data for insertion into the database
  const { name, category, price, stock, expiry } = validatedFields.data;
  const id = uuidv4();
  const expiryDate = expiry.toDateString();

  // Insert data into the database
  try {
    switch (category) {
      case 'snacks':
        await sql`
            INSERT INTO products (id, name, category, stock, price, expiry)
            VALUES (${id}, ${name}, ${category}, ${stock}, ${price}, ${expiryDate})
            `;
        await sql`
            INSERT INTO snacks (id, name, stock, price, expiry)
            VALUES (${id}, ${name}, ${stock}, ${price}, ${expiryDate})
            `;
        break;
      case 'candy':
        await sql`
            INSERT INTO products (id, name, category, stock, price, expiry)
            VALUES (${id}, ${name}, ${category}, ${stock}, ${price}, ${expiryDate})
            `;
        await sql`
            INSERT INTO candy (id, name, stock, price, expiry)
            VALUES (${id}, ${name}, ${stock}, ${price}, ${expiryDate})
            `;
        break;
      case 'pantry':
        await sql`
            INSERT INTO products (id, name, category, stock, price, expiry)
            VALUES (${id}, ${name}, ${category}, ${stock}, ${price}, ${expiryDate})
            `;
        await sql`
            INSERT INTO pantry (id, name, stock, price, expiry)
            VALUES (${id}, ${name}, ${stock}, ${price}, ${expiryDate})
            `;
        break;
      case 'beverages':
        await sql`
            INSERT INTO products (id, name, category, stock, price, expiry)
            VALUES (${id}, ${name}, ${category}, ${stock}, ${price}, ${expiryDate})
            `;
        await sql`
            INSERT INTO beverages (id, name, stock, price, expiry)
            VALUES (${id}, ${name}, ${stock}, ${price}, ${expiryDate})
            `;
        break;
      case 'meatAndSeafood':
        await sql`
            INSERT INTO products (id, name, category, stock, price, expiry)
            VALUES (${id}, ${name}, ${category}, ${stock}, ${price}, ${expiryDate})
            `;
        await sql`
            INSERT INTO pmeatAndSeafood (id, name, stock, price, expiry)
            VALUES (${id}, ${name}, ${stock}, ${price}, ${expiryDate})
            `;
        break;
      case 'bakeryAndDesserts':
        await sql`
            INSERT INTO products (id, name, category, stock, price, expiry)
            VALUES (${id}, ${name}, ${category}, ${stock}, ${price}, ${expiryDate})
            `;
        await sql`
            INSERT INTO bakeryAndDesserts (id, name, stock, price, expiry)
            VALUES (${id}, ${name}, ${stock}, ${price}, ${expiryDate})
            `;
        break;
      case 'breakfast':
        await sql`
            INSERT INTO products (id, name, category, stock, price, expiry)
            VALUES (${id}, ${name}, ${category}, ${stock}, ${price}, ${expiryDate})
            `;
        await sql`
            INSERT INTO breakfast (id, name, stock, price, expiry)
            VALUES (${id}, ${name}, ${stock}, ${price}, ${expiryDate})
            `;
        break;
      case 'coffee':
        await sql`
            INSERT INTO products (id, name, category, stock, price, expiry)
            VALUES (${id}, ${name}, ${category}, ${stock}, ${price}, ${expiryDate})
            `;
        await sql`
            INSERT INTO coffee (id, name, stock, price, expiry)
            VALUES (${id}, ${name}, ${stock}, ${price}, ${expiryDate})
            `;
        break;
      case 'deli':
        await sql`
            INSERT INTO products (id, name, category, stock, price, expiry)
            VALUES (${id}, ${name}, ${category}, ${stock}, ${price}, ${expiryDate})
            `;
        await sql`
            INSERT INTO deli (id, name, stock, price, expiry)
            VALUES (${id}, ${name}, ${stock}, ${price}, ${expiryDate})
            `;
        break;
      case 'organic':
        await sql`
            INSERT INTO products (id, name, category, stock, price, expiry)
            VALUES (${id}, ${name}, ${category}, ${stock}, ${price}, ${expiryDate})
            `;
        await sql`
            INSERT INTO organic (id, name, stock, price, expiry)
            VALUES (${id}, ${name}, ${stock}, ${price}, ${expiryDate})
            `;
        break;
      case 'cleaning':
        await sql`
            INSERT INTO products (id, name, stock, category, price)
            VALUES (${id}, ${name}, ${category}, ${stock}, ${price})
            `;
        await sql`
            INSERT INTO cleaning (id, name, stock, price)
            VALUES (${id}, ${name}, ${stock}, ${price})
            `;
        break;
      case 'floral':
        await sql`
            INSERT INTO products (id, name, stock, category, price)
            VALUES (${id}, ${name}, ${category}, ${stock}, ${price})
            `;
        await sql`
            INSERT INTO floral (id, name, stock, price)
            VALUES (${id}, ${name}, ${stock}, ${price})
            `;
        break;
      case 'household':
        await sql`
            INSERT INTO products (id, name, stock, category, price)
            VALUES (${id}, ${name}, ${category}, ${stock}, ${price})
            `;
        await sql`
            INSERT INTO household (id, name, stock, price)
            VALUES (${id}, ${name}, ${stock}, ${price})
            `;
        break;
    }
  } catch (error) {
    // If a database error occurs, return a more specific error.
    console.log(error);
    return {
      message: 'Database Error: Failed to Create Product.',
    };
  }

  // Revalidate the cache for the products page and redirect the user.
  revalidatePath('/dashboard/products');
  redirect('/dashboard/products');
}

export async function updateProduct(
  id: string,
  prevState: State,
  formData: FormData,
) {
  const validatedFields = UpdateProduct.safeParse({
    name: formData.get('name'),
    category: formData.get('category'),
    price: formData.get('price'),
    stock: formData.get('stock'),
    expiry: formData.get('expiry'),
  });

  if (!validatedFields.success) {
    return {
      errors: validatedFields.error.flatten().fieldErrors,
      message: 'Missing Fields. Failed to Update Product.',
    };
  }

  const { name, category, price, stock, expiry } = validatedFields.data;
  const expiryDate = expiry.toDateString();

  try {
    switch (category) {
      case 'snacks':
        await sql`
            UPDATE products
            SET name = ${name}, price = ${price}, stock = ${stock}, expiry = ${expiryDate}
            WHERE id = ${id}
            `;
        await sql`
            UPDATE snacks
            SET name = ${name}, price = ${price}, stock = ${stock}, expiry = ${expiryDate}
            WHERE id = ${id}
            `;
        break;
      case 'candy':
        await sql`
            UPDATE products
            SET name = ${name}, price = ${price}, stock = ${stock}, expiry = ${expiryDate}
            WHERE id = ${id}
            `;
        await sql`
            UPDATE candy
            SET name = ${name}, price = ${price}, stock = ${stock}, expiry = ${expiryDate}
            WHERE id = ${id}
            `;
        break;
      case 'pantry':
        await sql`
            UPDATE products
            SET name = ${name}, price = ${price}, stock = ${stock}, expiry = ${expiryDate}
            WHERE id = ${id}
            `;
        await sql`
            UPDATE pantry
            SET name = ${name}, price = ${price}, stock = ${stock}, expiry = ${expiryDate}
            WHERE id = ${id}
            `;
        break;
      case 'beverages':
        await sql`
            UPDATE products
            SET name = ${name}, price = ${price}, stock = ${stock}, expiry = ${expiryDate}
            WHERE id = ${id}
            `;
        await sql`
            UPDATE beverages
            SET name = ${name}, price = ${price}, stock = ${stock}, expiry = ${expiryDate}
            WHERE id = ${id}
            `;
        break;
      case 'meatAndSeafood':
        await sql`
            UPDATE products
            SET name = ${name}, price = ${price}, stock = ${stock}, expiry = ${expiryDate}
            WHERE id = ${id}
            `;
        await sql`
            UPDATE meatAndSeafood
            SET name = ${name}, price = ${price}, stock = ${stock}, expiry = ${expiryDate}
            WHERE id = ${id}
            `;
        break;
      case 'bakeryAndDesserts':
        await sql`
            UPDATE products
            SET name = ${name}, price = ${price}, stock = ${stock}, expiry = ${expiryDate}
            WHERE id = ${id}
            `;
        await sql`
            UPDATE bakeryAndDesserts
            SET name = ${name}, price = ${price}, stock = ${stock}, expiry = ${expiryDate}
            WHERE id = ${id}
            `;
        break;
      case 'breakfast':
        await sql`
            UPDATE products
            SET name = ${name}, price = ${price}, stock = ${stock}, expiry = ${expiryDate}
            WHERE id = ${id}
            `;
        await sql`
            UPDATE breakfast
            SET name = ${name}, price = ${price}, stock = ${stock}, expiry = ${expiryDate}
            WHERE id = ${id}
            `;
        break;
      case 'coffee':
        await sql`
            UPDATE products
            SET name = ${name}, price = ${price}, stock = ${stock}, expiry = ${expiryDate}
            WHERE id = ${id}
            `;
        await sql`
            UPDATE coffee
            SET name = ${name}, price = ${price}, stock = ${stock}, expiry = ${expiryDate}
            WHERE id = ${id}
            `;
        break;
      case 'deli':
        await sql`
            UPDATE products
            SET name = ${name}, price = ${price}, stock = ${stock}, expiry = ${expiryDate}
            WHERE id = ${id}
            `;
        await sql`
            UPDATE deli
            SET name = ${name}, price = ${price}, stock = ${stock}, expiry = ${expiryDate}
            WHERE id = ${id}
            `;
        break;
      case 'organic':
        await sql`
            UPDATE products
            SET name = ${name}, price = ${price}, stock = ${stock}, expiry = ${expiryDate}
            WHERE id = ${id}
            `;
        await sql`
            UPDATE organic
            SET name = ${name}, price = ${price}, stock = ${stock}, expiry = ${expiryDate}
            WHERE id = ${id}
            `;
        break;
      case 'cleaning':
        await sql`
            UPDATE products
            SET name = ${name}, price = ${price}, stock = ${stock}
            WHERE id = ${id}
            `;
        await sql`
            UPDATE cleaning
            SET name = ${name}, price = ${price}, stock = ${stock}
            WHERE id = ${id}
            `;
        break;
      case 'floral':
        await sql`
            UPDATE products
            SET name = ${name}, price = ${price}, stock = ${stock}
            WHERE id = ${id}
            `;
        await sql`
            UPDATE floral
            SET name = ${name}, price = ${price}, stock = ${stock}
            WHERE id = ${id}
            `;
        break;
      case 'household':
        await sql`
            UPDATE products
            SET name = ${name}, price = ${price}, stock = ${stock}
            WHERE id = ${id}
            `;
        await sql`
            UPDATE household
            SET name = ${name}, price = ${price}, stock = ${stock}
            WHERE id = ${id}
            `;
        break;
    }
  } catch (error) {
    return { message: 'Database Error: Failed to Update Product.' };
  }

  revalidatePath('/dashboard/products');
  redirect('/dashboard/products');
}

export async function deleteProduct(id: string) {
  try {
    await sql`DELETE FROM products WHERE id = ${id}`;
    revalidatePath('/dashboard/products');
    return { message: 'Deleted Product.' };
  } catch (error) {
    return { message: 'Database Error: Failed to Delete Product.' };
  }
}
