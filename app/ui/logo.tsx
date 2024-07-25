import { ShoppingCartIcon } from '@heroicons/react/24/outline';
import { lusitana } from '@/app/ui/fonts';

export default function Logo() {
  return (
    <div
      className={`${lusitana.className} flex flex-row items-center leading-none text-white`}
    >
      <ShoppingCartIcon
        className="h-12 w-12 rotate-[15deg]"
        width={40}
        height={40}
      />
    </div>
  );
}
