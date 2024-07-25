'use server';

import { sql } from '@vercel/postgres';
import { AuthError } from 'next-auth';
import { signIn } from '@/auth';
import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';
import { z } from 'zod';

export type State = {
  errors?: {
    customerId?: string[];
    productId?: string[];
    quantity?: string[];
    status?: string[];
  };
  message?: string | null;
};

const FormSchema = z.object({
  id: z.string(),
  customerId: z.string({
    invalid_type_error: 'Please select a customer.',
  }),
  productId: z.string({
    invalid_type_error: 'Please select a product.',
  }),
  quantity: z.coerce
    .number()
    .gt(0, { message: 'Please enter a quantity greater than 0.' }),
  status: z.enum(['pending', 'paid'], {
    invalid_type_error: 'Please select an order status.',
  }),
  date: z.string(),
});

const CreateOrder = FormSchema.omit({ id: true, date: true });
const UpdateOrder = FormSchema.omit({ id: true, date: true });

export async function createOrder(prevState: State, formData: FormData) {
  // Validate form using Zod
  const validatedFields = CreateOrder.safeParse({
    customerId: formData.get('customerId'),
    productId: formData.get('productId'),
    quantity: formData.get('quantity'),
    status: formData.get('status'),
  });

  // If form validation fails, return errors early. Otherwise, continue.
  if (!validatedFields.success) {
    return {
      errors: validatedFields.error.flatten().fieldErrors,
      message: 'Missing Fields. Failed to Create Order.',
    };
  }

  // Prepare data for insertion into the database
  const { customerId, productId, quantity, status } = validatedFields.data;

  // Insert data into the database
  try {
    await sql`
        INSERT INTO orders (customer_id, product_id, quantity, status)
        VALUES (${customerId}, ${productId}, ${quantity}, ${status})
        `;
  } catch (error) {
    console.log(error)
    // If a database error occurs, return a more specific error.
    return {
      message: error + '. Failed to Update Order.',
    };
  }

  // Revalidate the cache for the orders page and redirect the user.
  revalidatePath('/dashboard/orders');
  redirect('/dashboard/orders');
}

export async function updateOrder(
  id: string,
  prevState: State,
  formData: FormData,
) {
  const validatedFields = UpdateOrder.safeParse({
    customerId: formData.get('customerId'),
    productId: formData.get('productId'),
    quantity: formData.get('quantity'),
    status: formData.get('status'),
  });

  if (!validatedFields.success) {
    return {
      errors: validatedFields.error.flatten().fieldErrors,
      message: 'Missing Fields. Failed to Update Order.',
    };
  }

  const { customerId, productId, quantity, status } = validatedFields.data;

  try {
    await sql`
        UPDATE orders
        SET customer_id = ${customerId}, product_id = ${productId}, quantity = ${quantity}, status = ${status}
        WHERE id = ${id}
        `;
  } catch (error) {
    console.log(error);
    return { message: error + '. Failed to Update Order.' };
  }

  revalidatePath('/dashboard/orders');
  redirect('/dashboard/orders');
}

export async function deleteOrder(id: string) {
  try {
    await sql`DELETE FROM orders WHERE id = ${id}`;
    revalidatePath('/dashboard/orders');
    return { message: 'Deleted Order.' };
  } catch (error) {
    console.log(error)
    return { message: 'Database Error: Failed to Delete Order.' };
  }
}

export async function authenticate(
  prevState: string | undefined,
  formData: FormData,
) {
  try {
    await signIn('credentials', formData);
  } catch (error) {
    if (error instanceof AuthError) {
      switch (error.type) {
        case 'CredentialsSignin':
          return 'Invalid credentials.';
        default:
          return 'Something went wrong.';
      }
    }
    throw error;
  }
}
