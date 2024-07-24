import Image from 'next/image';
import { UpdateProduct, DeleteProduct } from '@/app/ui/products/buttons';
import ProductStatus from '@/app/ui/products/status';
import { formatDateToLocal, formatCurrency } from '@/app/lib/utils';
import { fetchFilteredProducts } from '@/app/lib/data';
import { LuCandy, LuFlower, LuPopcorn, LuWheat, LuCoffee, LuLeaf } from 'react-icons/lu';
import { FaBacon, } from 'react-icons/fa';
import { TbMeat, TbBottle } from 'react-icons/tb';
import { PiHouseLineBold } from 'react-icons/pi';
import { CiBacon } from 'react-icons/ci';
import { MdOutlineBakeryDining, MdOutlineCleanHands, MdOutlineOtherHouses } from 'react-icons/md';
import { GiFruitBowl, GiHotMeal } from 'react-icons/gi';


export default async function ProductsTable({
  query,
  currentPage,
}: {
  query: string;
  currentPage: number;
}) {
  const products = await fetchFilteredProducts(query, currentPage);

  return (
    <div className="mt-6 flow-root">
      <div className="inline-block min-w-full align-middle">
        <div className="rounded-lg bg-gray-50 p-2 md:pt-0">
          <div className="md:hidden">
            {products?.map((product) => (
              <div
                key={product.id}
                className="mb-2 w-full rounded-md bg-white p-4"
              >
                <div className="flex items-center justify-between border-b pb-4">
                  <div>
                    <div className="mb-2 flex items-center">
                      { product.category == 'snacks' && <LuPopcorn className="mr-1 my-1" size={22}/> }
                      { product.category == 'pantry' && <LuWheat className="mr-1 my-1" size={22}/>  }
                      { product.category == 'candy' && <LuCandy className="mr-1 my-1" size={22}/>  }
                      { product.category == 'beverages' && <TbBottle className="mr-1 my-1" size={22}/>  }
                      { product.category == 'meatAndSeafood' && <TbMeat className="mr-1 my-1" size={22}/>  }
                      { product.category == 'bakeryAndDesserts' && <MdOutlineBakeryDining className="mr-1 my-1" size={22}/>  }
                      { product.category == 'breakfast' && <CiBacon className="mr-1 my-1" size={22}/>  }
                      { product.category == 'coffee' && <LuCoffee className="mr-1 my-1" size={22}/>  }
                      { product.category == 'deli' && <GiHotMeal className="mr-1 my-1" size={22}/>  }
                      { product.category == 'organic' && <LuLeaf className="mr-1 my-1" size={22}/>  }
                      { product.category == 'cleaning' && <MdOutlineCleanHands className="mr-1 my-1" size={22}/>  }
                      { product.category == 'floral' && <LuFlower className="mr-1 my-1" size={22}/>  }
                      { product.category == 'household' && <PiHouseLineBold className="mr-1 my-1" size={22}/>  }
                      <p>{product.name}</p>
                    </div>
                    <p className="text-sm text-gray-500">{product.category}</p>
                  </div>
                  <ProductStatus status={product.status} />
                </div>
                <div className="flex w-full items-center justify-between pt-4">
                  <div>
                    <p className="text-xl font-medium">
                      {formatCurrency(product.price)}
                    </p>
                    <p>{product.expiry && formatDateToLocal(product.expiry)}</p>
                  </div>
                  <div className="flex justify-end gap-2">
                    {/* <UpdateProduct id={product.id} />
                    <DeleteProduct id={product.id} /> */}
                  </div>
                </div>
              </div>
            ))}
          </div>
          <table className="hidden min-w-full text-gray-900 md:table">
            <thead className="rounded-lg text-left text-sm font-normal">
              <tr>
                <th scope="col" className="px-4 py-5 font-medium sm:pl-6">
                  Product
                </th>
                <th scope="col" className="px-3 py-5 font-medium">
                  Category
                </th>
                <th scope="col" className="px-3 py-5 font-medium">
                  Price
                </th>
                <th scope="col" className="px-3 py-5 font-medium">
                  Expiry
                </th>
                <th scope="col" className="px-3 py-5 font-medium">
                  Status
                </th>
                <th scope="col" className="relative py-3 pl-6 pr-3">
                  <span className="sr-only">Edit</span>
                </th>
              </tr>
            </thead>
            <tbody className="bg-white">
              {products?.map((product) => (
                <tr
                  key={product.id}
                  className="w-full border-b py-3 text-sm last-of-type:border-none [&:first-child>td:first-child]:rounded-tl-lg [&:first-child>td:last-child]:rounded-tr-lg [&:last-child>td:first-child]:rounded-bl-lg [&:last-child>td:last-child]:rounded-br-lg"
                >
                  <td className="whitespace-nowrap py-3 pl-6 pr-3">
                    <div className="flex items-center gap-3">
                      { product.category == 'snacks' && <LuPopcorn className="mr-1 my-1" size={22}/> }
                      { product.category == 'pantry' && <LuWheat className="mr-1 my-1" size={22}/>  }
                      { product.category == 'candy' && <LuCandy className="mr-1 my-1" size={22}/>  }
                      { product.category == 'beverages' && <TbBottle className="mr-1 my-1" size={22}/>  }
                      { product.category == 'meatAndSeafood' && <TbMeat className="mr-1 my-1" size={22}/>  }
                      { product.category == 'bakeryAndDesserts' && <MdOutlineBakeryDining className="mr-1 my-1" size={22}/>  }
                      { product.category == 'breakfast' && <CiBacon className="mr-1 my-1" size={22}/>  }
                      { product.category == 'coffee' && <LuCoffee className="mr-1 my-1" size={22}/>  }
                      { product.category == 'deli' && <GiHotMeal className="mr-1 my-1" size={22}/>  }
                      { product.category == 'organic' && <LuLeaf className="mr-1 my-1" size={22}/>  }
                      { product.category == 'cleaning' && <MdOutlineCleanHands className="mr-1 my-1" size={22}/>  }
                      { product.category == 'floral' && <LuFlower className="mr-1 my-1" size={22}/>  }
                      { product.category == 'household' && <PiHouseLineBold className="mr-1 my-1" size={22}/>  }
                      <p>{product.name}</p>
                    </div>
                  </td>
                  <td className="whitespace-nowrap px-3 py-3">
                    {product.category}
                  </td>
                  <td className="whitespace-nowrap px-3 py-3">
                    {formatCurrency(product.price)}
                  </td>
                  <td className="whitespace-nowrap px-3 py-3">
                    {product.expiry && formatDateToLocal(product.expiry)}
                  </td>
                  <td className="whitespace-nowrap px-3 py-3">
                    <ProductStatus status={product.status} />
                  </td>
                  <td className="whitespace-nowrap py-3 pl-6 pr-3">
                    <div className="flex justify-end gap-3">
                      <UpdateProduct id={product.id} />
                      <DeleteProduct id={product.id} />
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
