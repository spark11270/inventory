import Form from '@/app/ui/orders/create-form';
import Breadcrumbs from '@/app/ui/orders/breadcrumbs';
import { fetchCustomers, fetchProducts } from '@/app/lib/data';

export default async function Page() {
  const customers = await fetchCustomers();
  const products = await fetchProducts();

  return (
    <main>
      <Breadcrumbs
        breadcrumbs={[
          { label: 'Orders', href: '/dashboard/orders' },
          {
            label: 'Create Order',
            href: '/dashboard/orders/create',
            active: true,
          },
        ]}
      />
      <Form customers={customers} products={products} />
    </main>
  );
}
