import { deleteOrder } from '@/app/lib/actions';
import { PencilIcon, PlusIcon, TrashIcon } from '@heroicons/react/24/outline';
import Link from 'next/link';

export function CreateOrder({ user }: { user: boolean }) {
  console.log(user);
  return (
    <Link
      href="/dashboard/orders/create"
      className={
        user
          ? 'pointer-events-none flex h-10 items-center rounded-lg bg-blue-200 px-4 text-sm font-medium text-white transition-colors hover:bg-blue-200 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-200'
          : 'flex h-10 items-center rounded-lg bg-blue-600 px-4 text-sm font-medium text-white transition-colors hover:bg-blue-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600'
      }
      aria-disabled={user}
    >
      <span className="hidden md:block">Create Order</span>{' '}
      <PlusIcon className="h-5 md:ml-4" />
    </Link>
  );
}

export function UpdateOrder({ id, user }: { id: string; user: boolean }) {
  return (
    <Link
      href={`/dashboard/orders/${id}/edit`}
      className={
        user
          ? 'pointer-events-none rounded-md border p-2'
          : 'rounded-md border p-2 hover:bg-gray-100'
      }
      aria-disabled={user}
    >
      <PencilIcon className={user ? 'w-5 text-gray-400' : 'w-5'} />
    </Link>
  );
}

export function DeleteOrder({ id, user }: { id: string; user: boolean }) {
  const deleteOrderWithId = deleteOrder.bind(null, id);

  return (
    <form action={deleteOrderWithId}>
      <button
        className={
          user
            ? 'rounded-md border p-2'
            : 'rounded-md border p-2 hover:bg-gray-100'
        }
        disabled={user}
      >
        <span className="sr-only">Delete</span>
        <TrashIcon className={user ? 'w-5 text-gray-400' : 'w-5'} />
      </button>
    </form>
  );
}
