import {
  CurrencyDollarIcon,
  BanknotesIcon,
  ClockIcon,
  UserGroupIcon,
  InboxIcon,
  ShoppingBagIcon,
  CheckCircleIcon,
  XCircleIcon,
} from '@heroicons/react/24/outline';
import { lusitana } from '@/app/ui/fonts';
import { fetchCardData } from '@/app/lib/data';

const iconMap = {
  revenue: CurrencyDollarIcon,
  collected: BanknotesIcon,
  customers: UserGroupIcon,
  pending: ClockIcon,
  orders: InboxIcon,
  products: ShoppingBagIcon,
  inStock: CheckCircleIcon,
  outOfStock: XCircleIcon,
};

export default async function CardWrapper() {
  const {
    numberOfOrders,
    numberOfCustomers,
    totalPaidOrders,
    totalPendingOrders,
    numberOfProducts,
    totalRevenue,
    totalInStock,
    totalOutOfStock,
  } = await fetchCardData();

  return (
    <>
      <Card title="Collected" value={totalPaidOrders} type="collected" />
      <Card title="Pending" value={totalPendingOrders} type="pending" />
      <Card title="In Stock" value={totalInStock} type="inStock" />
      <Card title="Out of Stock" value={totalOutOfStock} type="outOfStock" />
      <Card title="Total Revenue" value={totalRevenue} type="revenue" />
      <Card title="Total Orders" value={numberOfOrders} type="orders" />
      <Card title="Total Products" value={numberOfProducts} type="products" />
      <Card
        title="Total Customers"
        value={numberOfCustomers}
        type="customers"
      />
    </>
  );
}

export function Card({
  title,
  value,
  type,
}: {
  title: string;
  value: number | string;
  type:
    | 'orders'
    | 'products'
    | 'customers'
    | 'pending'
    | 'collected'
    | 'revenue'
    | 'inStock'
    | 'outOfStock';
}) {
  const Icon = iconMap[type];

  return (
    <div className="rounded-xl bg-gray-50 p-2 shadow-sm">
      <div className="flex p-4">
        {Icon ? <Icon className="h-5 w-5 text-gray-700" /> : null}
        <h3 className="ml-2 text-sm font-medium">{title}</h3>
      </div>
      <p
        className={`${lusitana.className}
          truncate rounded-xl bg-white px-4 py-8 text-center text-2xl`}
      >
        {value}
      </p>
    </div>
  );
}
