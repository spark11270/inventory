'use client';

import { ProductForm } from '@/app/lib/definitions';
import {
  ArchiveBoxIcon,
  CheckIcon,
  ClockIcon,
  CurrencyDollarIcon,
} from '@heroicons/react/24/outline';
import Link from 'next/link';
import { Button } from '@/app/ui/button';
import { updateProduct } from '@/app/lib/productActions';
import { useFormState } from 'react-dom';
import { useState } from 'react';
import { PiHouseLineBold } from 'react-icons/pi';
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
import { TbBottle, TbMeat } from 'react-icons/tb';

export default function EditProductForm({ product }: { product: ProductForm }) {
  const initialState = { message: null, errors: {} };
  const updateProductWithId = updateProduct.bind(null, product.id);
  const [state, dispatch] = useFormState(updateProductWithId, initialState);
  const [selected, setSelected] = useState<string>();

  function onSelect(name: string) {
    setSelected(name);
    return;
  }

  console.log('here', product.id);

  return (
    <form action={dispatch} aria-describedby="update-error">
      <div className="rounded-md bg-gray-50 p-4 md:p-6">
        {/* Product Name */}
        <div className="mb-4">
          <label htmlFor="name" className="mb-2 block text-sm font-medium">
            Set product name
          </label>
          <div className="relative mt-2 rounded-md">
            <div className="relative">
              <input
                id="name"
                name="name"
                type="string"
                placeholder="Enter product name"
                defaultValue={product.name}
                className="peer block w-full rounded-md border border-gray-200 py-2 pl-10 text-sm outline-2 placeholder:text-gray-500"
                aria-describedby="name-error"
              />
              <CurrencyDollarIcon className="pointer-events-none absolute left-3 top-1/2 h-[18px] w-[18px] -translate-y-1/2 text-gray-500 peer-focus:text-gray-900" />
            </div>
          </div>
          <div id="name-error" aria-live="polite" aria-atomic="true">
            {state.errors?.name &&
              state.errors.name.map((error: string) => (
                <p className="mt-2 text-sm text-red-500" key={error}>
                  {error}
                </p>
              ))}
          </div>
        </div>

        {/* Category */}
        <fieldset>
          <legend className="mb-2 block text-sm font-medium">
            Select category
          </legend>
          <div className="rounded-md border border-gray-200 bg-white px-[14px] py-3">
            <div className="flex flex-wrap gap-4">
              <div className="flex items-center">
                <input
                  id="snacks"
                  name="category"
                  type="radio"
                  value="snacks"
                  onChange={() => onSelect('snacks')}
                  defaultChecked={product.category === 'snacks'}
                  className="h-4 w-4 cursor-pointer border-gray-300 bg-gray-100 text-gray-600 focus:ring-2"
                  aria-describedby="category-error"
                />
                <label
                  htmlFor="snacks"
                  className="ml-2 flex cursor-pointer items-center gap-1.5 rounded-full bg-gray-100 px-3 py-1.5 text-xs font-medium text-gray-600"
                >
                  Snacks <LuPopcorn size={15} />
                  {selected == 'snacks' && <CheckIcon className="h-4 w-4" />}
                </label>
              </div>
              <div className="flex items-center">
                <input
                  id="pantry"
                  name="category"
                  type="radio"
                  value="pantry"
                  onChange={() => onSelect('pantry')}
                  defaultChecked={product.category === 'pantry'}
                  className="h-4 w-4 cursor-pointer border-gray-300 bg-gray-100 text-gray-600 focus:ring-2"
                  aria-describedby="category-error"
                />
                <label
                  htmlFor="pantry"
                  className="ml-2 flex cursor-pointer items-center gap-1.5 rounded-full bg-gray-100 px-3 py-1.5 text-xs font-medium text-gray-600"
                >
                  Pantry Products <LuWheat size={15} />
                  {selected == 'pantry' && <CheckIcon className="h-4 w-4" />}
                </label>
              </div>
              <div className="flex items-center">
                <input
                  id="beverages"
                  name="category"
                  type="radio"
                  value="beverages"
                  onChange={() => onSelect('beverages')}
                  defaultChecked={product.category === 'beverages'}
                  className="h-4 w-4 cursor-pointer border-gray-300 bg-gray-100 text-gray-600 focus:ring-2"
                  aria-describedby="category-error"
                />
                <label
                  htmlFor="beverages"
                  className="ml-2 flex cursor-pointer items-center gap-1.5 rounded-full bg-gray-100 px-3 py-1.5 text-xs font-medium text-gray-600"
                >
                  Beverages <TbBottle size={15} />
                  {selected == 'beverages' && <CheckIcon className="h-4 w-4" />}
                </label>
              </div>
              <div className="flex items-center">
                <input
                  id="candy"
                  name="category"
                  type="radio"
                  value="candy"
                  onChange={() => onSelect('candy')}
                  defaultChecked={product.category === 'candy'}
                  className="h-4 w-4 cursor-pointer border-gray-300 bg-gray-100 text-gray-600 focus:ring-2"
                  aria-describedby="category-error"
                />
                <label
                  htmlFor="candy"
                  className="ml-2 flex cursor-pointer items-center gap-1.5 rounded-full bg-gray-100 px-3 py-1.5 text-xs font-medium text-gray-600"
                >
                  Candy <LuCandy size={15} />
                  {selected == 'candy' && <CheckIcon className="h-4 w-4" />}
                </label>
              </div>
              <div className="flex items-center">
                <input
                  id="breakfast"
                  name="category"
                  type="radio"
                  value="breakfast"
                  onChange={() => onSelect('breakfast')}
                  defaultChecked={product.category === 'breakfast'}
                  className="h-4 w-4 cursor-pointer border-gray-300 bg-gray-100 text-gray-600 focus:ring-2"
                  aria-describedby="category-error"
                />
                <label
                  htmlFor="breakfast"
                  className="ml-2 flex cursor-pointer items-center gap-1.5 rounded-full bg-gray-100 px-3 py-1.5 text-xs font-medium text-gray-600"
                >
                  Breakfast <CiBacon size={15} />
                  {selected == 'breakfast' && <CheckIcon className="h-4 w-4" />}
                </label>
              </div>
              <div className="flex items-center">
                <input
                  id="meatAndSeafood"
                  name="category"
                  type="radio"
                  value="meatAndSeafood"
                  onChange={() => onSelect('meatAndSeafood')}
                  defaultChecked={product.category === 'meatAndSeafood'}
                  className="h-4 w-4 cursor-pointer border-gray-300 bg-gray-100 text-gray-600 focus:ring-2"
                  aria-describedby="category-error"
                />
                <label
                  htmlFor="meatAndSeafood"
                  className="ml-2 flex cursor-pointer items-center gap-1.5 rounded-full bg-gray-100 px-3 py-1.5 text-xs font-medium text-gray-600"
                >
                  Meat & Seafood <TbMeat size={15} />
                  {selected == 'meatAndSeafood' && (
                    <CheckIcon className="h-4 w-4" />
                  )}
                </label>
              </div>
              <div className="flex items-center">
                <input
                  id="bakeryAndDesserts"
                  name="category"
                  type="radio"
                  value="bakeryAndDesserts"
                  onChange={() => onSelect('bakeryAndDesserts')}
                  defaultChecked={product.category === 'bakeryAndDesserts'}
                  className="h-4 w-4 cursor-pointer border-gray-300 bg-gray-100 text-gray-600 focus:ring-2"
                  aria-describedby="category-error"
                />
                <label
                  htmlFor="bakeryAndDesserts"
                  className="ml-2 flex cursor-pointer items-center gap-1.5 rounded-full bg-gray-100 px-3 py-1.5 text-xs font-medium text-gray-600"
                >
                  Bakery & Desserts <MdOutlineBakeryDining size={15} />
                  {selected == 'bakeryAndDesserts' && (
                    <CheckIcon className="h-4 w-4" />
                  )}
                </label>
              </div>
              <div className="flex items-center">
                <input
                  id="coffee"
                  name="category"
                  type="radio"
                  value="coffee"
                  onChange={() => onSelect('coffee')}
                  defaultChecked={product.category === 'coffee'}
                  className="h-4 w-4 cursor-pointer border-gray-300 bg-gray-100 text-gray-600 focus:ring-2"
                  aria-describedby="category-error"
                />
                <label
                  htmlFor="coffee"
                  className="ml-2 flex cursor-pointer items-center gap-1.5 rounded-full bg-gray-100 px-3 py-1.5 text-xs font-medium text-gray-600"
                >
                  Coffee <LuCoffee size={15} />
                  {selected == 'coffee' && <CheckIcon className="h-4 w-4" />}
                </label>
              </div>
              <div className="flex items-center">
                <input
                  id="deli"
                  name="category"
                  type="radio"
                  value="deli"
                  onChange={() => onSelect('deli')}
                  defaultChecked={product.category === 'deli'}
                  className="h-4 w-4 cursor-pointer border-gray-300 bg-gray-100 text-gray-600 focus:ring-2"
                  aria-describedby="category-error"
                />
                <label
                  htmlFor="deli"
                  className="ml-2 flex cursor-pointer items-center gap-1.5 rounded-full bg-gray-100 px-3 py-1.5 text-xs font-medium text-gray-600"
                >
                  Deli <GiHotMeal size={15} />
                  {selected == 'deli' && <CheckIcon className="h-4 w-4" />}
                </label>
              </div>
              <div className="flex items-center">
                <input
                  id="organic"
                  name="category"
                  type="radio"
                  value="organic"
                  onChange={() => onSelect('organic')}
                  defaultChecked={product.category === 'organic'}
                  className="h-4 w-4 cursor-pointer border-gray-300 bg-gray-100 text-gray-600 focus:ring-2"
                  aria-describedby="category-error"
                />
                <label
                  htmlFor="organic"
                  className="ml-2 flex cursor-pointer items-center gap-1.5 rounded-full bg-gray-100 px-3 py-1.5 text-xs font-medium text-gray-600"
                >
                  Organic <LuLeaf size={15} />
                  {selected == 'organic' && <CheckIcon className="h-4 w-4" />}
                </label>
              </div>
              <div className="flex items-center">
                <input
                  id="cleaning"
                  name="category"
                  type="radio"
                  value="cleaning"
                  onChange={() => onSelect('cleaning')}
                  defaultChecked={product.category === 'cleaning'}
                  className="h-4 w-4 cursor-pointer border-gray-300 bg-gray-100 text-gray-600 focus:ring-2"
                  aria-describedby="category-error"
                />
                <label
                  htmlFor="cleaning"
                  className="ml-2 flex cursor-pointer items-center gap-1.5 rounded-full bg-gray-100 px-3 py-1.5 text-xs font-medium text-gray-600"
                >
                  Cleaning Supplies <MdOutlineCleanHands size={15} />
                  {selected == 'cleaning' && <CheckIcon className="h-4 w-4" />}
                </label>
              </div>
              <div className="flex items-center">
                <input
                  id="floral"
                  name="category"
                  type="radio"
                  value="floral"
                  onChange={() => onSelect('floral')}
                  defaultChecked={product.category === 'floral'}
                  className="h-4 w-4 cursor-pointer border-gray-300 bg-gray-100 text-gray-600 focus:ring-2"
                  aria-describedby="category-error"
                />
                <label
                  htmlFor="floral"
                  className="ml-2 flex cursor-pointer items-center gap-1.5 rounded-full bg-gray-100 px-3 py-1.5 text-xs font-medium text-gray-600"
                >
                  Floral <LuFlower size={15} />
                  {selected == 'floral' && <CheckIcon className="h-4 w-4" />}
                </label>
              </div>
              <div className="flex items-center">
                <input
                  id="household"
                  name="category"
                  type="radio"
                  value="household"
                  onChange={() => onSelect('household')}
                  defaultChecked={product.category === 'household'}
                  className="h-4 w-4 cursor-pointer border-gray-300 bg-gray-100 text-gray-600 focus:ring-2"
                  aria-describedby="category-error"
                />
                <label
                  htmlFor="household"
                  className="ml-2 flex cursor-pointer items-center gap-1.5 rounded-full bg-gray-100 px-3 py-1.5 text-xs font-medium text-gray-600"
                >
                  Household Supplies <PiHouseLineBold size={15} />
                  {selected == 'household' && <CheckIcon className="h-4 w-4" />}
                </label>
              </div>
            </div>
          </div>
          <div id="category-error" aria-live="polite" aria-atomic="true">
            {state.errors?.category &&
              state.errors.category.map((error: string) => (
                <p className="mt-2 text-sm text-red-500" key={error}>
                  {error}
                </p>
              ))}
          </div>
        </fieldset>

        {/* Price */}
        <div className="mb-4">
          <label htmlFor="price" className="mb-2 block text-sm font-medium">
            Set price
          </label>
          <div className="relative mt-2 rounded-md">
            <div className="relative">
              <input
                id="price"
                name="price"
                type="number"
                step="0.01"
                placeholder="Enter USD price"
                defaultValue={product.price}
                className="peer block w-full rounded-md border border-gray-200 py-2 pl-10 text-sm outline-2 placeholder:text-gray-500"
                aria-describedby="price-error"
              />
              <CurrencyDollarIcon className="pointer-events-none absolute left-3 top-1/2 h-[18px] w-[18px] -translate-y-1/2 text-gray-500 peer-focus:text-gray-900" />
            </div>
          </div>
          <div id="price-error" aria-live="polite" aria-atomic="true">
            {state.errors?.price &&
              state.errors.price.map((error: string) => (
                <p className="mt-2 text-sm text-red-500" key={error}>
                  {error}
                </p>
              ))}
          </div>
        </div>

        {/* Product Stock */}
        <div className="mb-4">
          <label htmlFor="stock" className="mb-2 block text-sm font-medium">
            Set stock
          </label>
          <div className="relative mt-2 rounded-md">
            <div className="relative">
              <input
                id="stock"
                name="stock"
                type="number"
                step="1"
                placeholder="Enter stock quantity"
                defaultValue={product.stock}
                className="peer block w-full rounded-md border border-gray-200 py-2 pl-10 text-sm outline-2 placeholder:text-gray-500"
                aria-describedby="stock-error"
              />
              <ArchiveBoxIcon className="pointer-events-none absolute left-3 top-1/2 h-[18px] w-[18px] -translate-y-1/2 text-gray-500 peer-focus:text-gray-900" />
            </div>
          </div>
          <div id="stock-error" aria-live="polite" aria-atomic="true">
            {state.errors?.stock &&
              state.errors.stock.map((error: string) => (
                <p className="mt-2 text-sm text-red-500" key={error}>
                  {error}
                </p>
              ))}
          </div>
        </div>

        {/* Product Expiry */}
        <div className="mb-4">
          <label htmlFor="expiry" className="mb-2 block text-sm font-medium">
            Set expiry
          </label>
          <div className="relative mt-2 rounded-md">
            <div className="relative">
              <input
                id="expiry"
                name="expiry"
                type="string"
                placeholder="Enter expiry date (YYYY-MM-DD)"
                defaultValue={product.expiry}
                className="peer block w-full rounded-md border border-gray-200 py-2 pl-10 text-sm outline-2 placeholder:text-gray-500"
                aria-describedby="expiry-error"
              />
              <ClockIcon className="pointer-events-none absolute left-3 top-1/2 h-[18px] w-[18px] -translate-y-1/2 text-gray-500 peer-focus:text-gray-900" />
            </div>
          </div>
          <div id="expiry-error" aria-live="polite" aria-atomic="true">
            {state.errors?.expiry &&
              state.errors.expiry.map((error: string) => (
                <p className="mt-2 text-sm text-red-500" key={error}>
                  {error}
                </p>
              ))}
          </div>
        </div>
      </div>
      <div id="update-error" aria-live="polite" aria-atomic="true">
        {state.message && (
          <p className="mt-2 text-sm text-red-500" key={state.message}>
            {state.message}
          </p>
        )}
      </div>
      <div className="mt-6 flex justify-end gap-4">
        <Link
          href="/dashboard/products"
          className="flex h-10 items-center rounded-lg bg-gray-100 px-4 text-sm font-medium text-gray-600 transition-colors hover:bg-gray-200"
        >
          Cancel
        </Link>
        <Button type="submit">Edit Product</Button>
      </div>
    </form>
  );
}
