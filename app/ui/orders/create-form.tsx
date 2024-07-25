'use client';

import { CustomerField, ProductField } from '@/app/lib/definitions';
import Link from 'next/link';
import { useFormState } from 'react-dom';
import {
  CheckIcon,
  ClockIcon,
  ShoppingBagIcon,
  ShoppingCartIcon,
  UserCircleIcon,
} from '@heroicons/react/24/outline';
import { Button } from '@/app/ui/button';
import { createOrder } from '@/app/lib/actions';
import { useState } from 'react';
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

export default function Form({
  customers,
  products,
}: {
  customers: CustomerField[];
  products: ProductField[];
}) {
  const initialState = { message: null, errors: {} };
  const [state, dispatch] = useFormState(createOrder, initialState);
  const [selected, setSelected] = useState<string>();

  function onSelect(name: string) {
    setSelected(name);
    return;
  }

  return (
    <form action={dispatch} aria-describedby="create-error">
      <div className="rounded-md bg-gray-50 p-4 md:p-6">
        {/* Customer Name */}
        <div className="mb-4">
          <label htmlFor="customer" className="mb-2 block text-sm font-medium">
            Choose customer
          </label>
          <div className="relative">
            <select
              id="customer"
              name="customerId"
              className="peer block w-full cursor-pointer rounded-md border border-gray-200 py-2 pl-10 text-sm outline-2 placeholder:text-gray-500"
              defaultValue=""
              aria-describedby="customer-error"
            >
              <option value="" disabled>
                Select a customer
              </option>
              {customers.map((customer) => (
                <option key={customer.id} value={customer.id}>
                  {customer.name}
                </option>
              ))}
            </select>
            <UserCircleIcon className="pointer-events-none absolute left-3 top-1/2 h-[18px] w-[18px] -translate-y-1/2 text-gray-500" />
          </div>
          <div id="customer-error" aria-live="polite" aria-atomic="true">
            {state.errors?.customerId &&
              state.errors.customerId.map((error: string) => (
                <p className="mt-2 text-sm text-red-500" key={error}>
                  {error}
                </p>
              ))}
          </div>
        </div>

        <fieldset>
          <legend className="mb-2 block text-sm font-medium">
            View by category
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
        </fieldset>

        {/* Product Name */}
        <div className="mb-4">
          <label htmlFor="product" className="mb-2 block text-sm font-medium">
            Choose product
          </label>
          <div className="relative">
            <select
              id="product"
              name="productId"
              className="peer block w-full cursor-pointer rounded-md border border-gray-200 py-2 pl-10 text-sm outline-2 placeholder:text-gray-500"
              defaultValue=""
              aria-describedby="product-error"
            >
              <option value="" disabled>
                Select a product
              </option>
              {products.map(
                (product) =>
                  (!selected || product.category == selected) && (
                    <option key={product.id} value={product.id}>
                      {product.name}
                    </option>
                  ),
              )}
            </select>
            <ShoppingBagIcon className="pointer-events-none absolute left-3 top-1/2 h-[18px] w-[18px] -translate-y-1/2 text-gray-500" />
          </div>
          <div id="product-error" aria-live="polite" aria-atomic="true">
            {state.errors?.productId &&
              state.errors.productId.map((error: string) => (
                <p className="mt-2 text-sm text-red-500" key={error}>
                  {error}
                </p>
              ))}
          </div>
        </div>

        {/* Product Quantity */}
        <div className="mb-4">
          <label htmlFor="quantity" className="mb-2 block text-sm font-medium">
            Select a quantity
          </label>
          <div className="relative mt-2 rounded-md">
            <div className="relative">
              <input
                id="quantity"
                name="quantity"
                type="number"
                step="1"
                placeholder="Enter quantity"
                className="peer block w-full rounded-md border border-gray-200 py-2 pl-10 text-sm outline-2 placeholder:text-gray-500"
                aria-describedby="quantity-error"
              />
              <ShoppingCartIcon className="pointer-events-none absolute left-3 top-1/2 h-[18px] w-[18px] -translate-y-1/2 text-gray-500 peer-focus:text-gray-900" />
            </div>
          </div>
          <div id="quantity-error" aria-live="polite" aria-atomic="true">
            {state.errors?.quantity &&
              state.errors.quantity.map((error: string) => (
                <p className="mt-2 text-sm text-red-500" key={error}>
                  {error}
                </p>
              ))}
          </div>
        </div>

        {/* Order Status */}
        <fieldset>
          <legend className="mb-2 block text-sm font-medium">
            Set the order status
          </legend>
          <div className="rounded-md border border-gray-200 bg-white px-[14px] py-3">
            <div className="flex gap-4">
              <div className="flex items-center">
                <input
                  id="pending"
                  name="status"
                  type="radio"
                  value="pending"
                  className="h-4 w-4 cursor-pointer border-gray-300 bg-gray-100 text-gray-600 focus:ring-2"
                  aria-describedby="status-error"
                />
                <label
                  htmlFor="pending"
                  className="ml-2 flex cursor-pointer items-center gap-1.5 rounded-full bg-gray-100 px-3 py-1.5 text-xs font-medium text-gray-600"
                >
                  Pending <ClockIcon className="h-4 w-4" />
                </label>
              </div>
              <div className="flex items-center">
                <input
                  id="paid"
                  name="status"
                  type="radio"
                  value="paid"
                  className="h-4 w-4 cursor-pointer border-gray-300 bg-gray-100 text-gray-600 focus:ring-2"
                  aria-describedby="status-error"
                />
                <label
                  htmlFor="paid"
                  className="ml-2 flex cursor-pointer items-center gap-1.5 rounded-full bg-green-500 px-3 py-1.5 text-xs font-medium text-white"
                >
                  Paid <CheckIcon className="h-4 w-4" />
                </label>
              </div>
            </div>
          </div>
          <div id="status-error" aria-live="polite" aria-atomic="true">
            {state.errors?.status &&
              state.errors.status.map((error: string) => (
                <p className="mt-2 text-sm text-red-500" key={error}>
                  {error}
                </p>
              ))}
          </div>
        </fieldset>
      </div>
      <div id="create-error" aria-live="polite" aria-atomic="true">
        {state.message && (
          <p className="mt-2 text-sm text-red-500" key={state.message}>
            {state.message}
          </p>
        )}
      </div>
      <div className="mt-6 flex justify-end gap-4">
        <Link
          href="/dashboard/orders"
          className="flex h-10 items-center rounded-lg bg-gray-100 px-4 text-sm font-medium text-gray-600 transition-colors hover:bg-gray-200"
        >
          Cancel
        </Link>
        <Button type="submit">Create Order</Button>
      </div>
    </form>
  );
}
