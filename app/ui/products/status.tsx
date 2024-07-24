import { CheckIcon, XCircleIcon } from '@heroicons/react/24/outline';
import clsx from 'clsx';

export default function ProductStatus({ status }: { status: string }) {
  return (
    <span
      className={clsx(
        'inline-flex items-center rounded-full px-2 py-1 text-xs',
        {
          'bg-red-500 text-white': status === 'out-of-stock',
          'bg-green-500 text-white': status === 'in-stock',
        },
      )}
    >
      {status === 'out-of-stock' ? (
        <>
          Out of Stock
          <XCircleIcon className="ml-1 w-4 text-white" />
        </>
      ) : null}
      {status === 'in-stock' ? (
        <>
          In Stock
          <CheckIcon className="ml-1 w-4 text-white" />
        </>
      ) : null}
    </span>
  );
}
