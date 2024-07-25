import { ArrowPathIcon } from '@heroicons/react/24/outline';
import clsx from 'clsx';
import Image from 'next/image';
import { lusitana } from '@/app/ui/fonts';
import { fetchBestSellingProducts } from '@/app/lib/data';
import { CiBacon } from 'react-icons/ci';
import { GiHotMeal } from 'react-icons/gi';
import {
  LuPopcorn,
  LuWheat,
  LuCandy,
  LuCoffee,
  LuLeaf,
  LuFlower,
} from 'react-icons/lu';
import { MdOutlineBakeryDining, MdOutlineCleanHands } from 'react-icons/md';
import { PiHouseLineBold } from 'react-icons/pi';
import { TbBottle, TbMeat } from 'react-icons/tb';

export default async function BestSellingProducts() {
  const bestProducts = await fetchBestSellingProducts();

  return (
    <div className="flex w-full flex-col md:col-span-4">
      <h2 className={`${lusitana.className} mb-4 text-xl md:text-2xl`}>
        Best Selling Products
      </h2>
      <div className="flex grow flex-col justify-between rounded-xl bg-gray-50 p-4">
        <div className="bg-white px-6">
          {bestProducts.map((product, i) => {
            return (
              <div
                key={product.id}
                className={clsx(
                  'flex flex-row items-center justify-between py-4',
                  {
                    'border-t': i !== 0,
                  },
                )}
              >
                <div className="flex items-center gap-3">
                  {product.category == 'snacks' && (
                    <LuPopcorn className="my-1 mr-1" size={22} />
                  )}
                  {product.category == 'pantry' && (
                    <LuWheat className="my-1 mr-1" size={22} />
                  )}
                  {product.category == 'candy' && (
                    <LuCandy className="my-1 mr-1" size={22} />
                  )}
                  {product.category == 'beverages' && (
                    <TbBottle className="my-1 mr-1" size={22} />
                  )}
                  {product.category == 'meatAndSeafood' && (
                    <TbMeat className="my-1 mr-1" size={22} />
                  )}
                  {product.category == 'bakeryAndDesserts' && (
                    <MdOutlineBakeryDining className="my-1 mr-1" size={22} />
                  )}
                  {product.category == 'breakfast' && (
                    <CiBacon className="my-1 mr-1" size={22} />
                  )}
                  {product.category == 'coffee' && (
                    <LuCoffee className="my-1 mr-1" size={22} />
                  )}
                  {product.category == 'deli' && (
                    <GiHotMeal className="my-1 mr-1" size={22} />
                  )}
                  {product.category == 'organic' && (
                    <LuLeaf className="my-1 mr-1" size={22} />
                  )}
                  {product.category == 'cleaning' && (
                    <MdOutlineCleanHands className="my-1 mr-1" size={22} />
                  )}
                  {product.category == 'floral' && (
                    <LuFlower className="my-1 mr-1" size={22} />
                  )}
                  {product.category == 'household' && (
                    <PiHouseLineBold className="my-1 mr-1" size={22} />
                  )}
                  <div className="min-w-0 overflow-hidden text-ellipsis">
                    <p className="truncate text-sm font-semibold md:text-base">
                      {product.name}
                    </p>
                    <p className="hidden text-sm text-gray-500 sm:block">
                      {product.category}
                    </p>
                  </div>
                </div>
                <p
                  className={`${lusitana.className} truncate text-sm font-medium md:text-base`}
                >
                  {product.price}
                </p>
              </div>
            );
          })}
        </div>
        <div className="flex items-center pb-2 pt-6">
          <ArrowPathIcon className="h-5 w-5 text-gray-500" />
          <h3 className="ml-2 text-sm text-gray-500 ">Updated just now</h3>
        </div>
      </div>
    </div>
  );
}
