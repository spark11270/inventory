import Form from '@/app/ui/orders/edit-form';
import Breadcrumbs from '@/app/ui/orders/breadcrumbs';
import { fetchOrderById, fetchCustomers, fetchProducts } from '@/app/lib/data';
import { notFound } from 'next/navigation';

export default async function Page({ params }: { params: { id: string } }) {
  const id = params.id;
  const [order, customers, products] = await Promise.all([
    fetchOrderById(id),
    fetchCustomers(),
    fetchProducts(),
  ]);

  if (!order) {
    notFound();
  }

  return (
    <main>
      <Breadcrumbs
        breadcrumbs={[
          { label: 'Orders', href: '/dashboard/orders' },
          {
            label: 'Edit Order',
            href: `/dashboard/orders/${id}/edit`,
            active: true,
          },
        ]}
      />
      <Form order={order} customers={customers} products={products} />
    </main>
  );
}
