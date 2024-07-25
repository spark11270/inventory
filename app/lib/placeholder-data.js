const {
  snacks,
  pantry,
  candy,
  beverages,
  meatAndSeafood,
  bakeryAndDessert,
  breakfast,
  cleaning,
  coffee,
  deli,
  floral,
  household,
  organic,
} = require('./DTO');

const users = [
  {
    name: 'Admin',
    email: 'admin@email.com',
    password: 'password',
    role: 'admin'
  },
  {
    name: 'User',
    email: 'user@email.com',
    password: 'password',
    role: 'user'
  },
];

const customers = [
  {
    id: '3958dc9e-712f-4377-85e9-fec4b6a6442a',
    name: 'Delba de Oliveira',
    email: 'delba@oliveira.com',
    image_url: '/customers/delba-de-oliveira.png',
  },
  {
    id: '3958dc9e-742f-4377-85e9-fec4b6a6442a',
    name: 'Lee Robinson',
    email: 'lee@robinson.com',
    image_url: '/customers/lee-robinson.png',
  },
  {
    id: '3958dc9e-737f-4377-85e9-fec4b6a6442a',
    name: 'Hector Simpson',
    email: 'hector@simpson.com',
    image_url: '/customers/hector-simpson.png',
  },
  {
    id: '50ca3e18-62cd-11ee-8c99-0242ac120002',
    name: 'Steven Tey',
    email: 'steven@tey.com',
    image_url: '/customers/steven-tey.png',
  },
  {
    id: '3958dc9e-787f-4377-85e9-fec4b6a6442a',
    name: 'Steph Dietz',
    email: 'steph@dietz.com',
    image_url: '/customers/steph-dietz.png',
  },
  {
    id: '76d65c26-f784-44a2-ac19-586678f7c2f2',
    name: 'Michael Novotny',
    email: 'michael@novotny.com',
    image_url: '/customers/michael-novotny.png',
  },
  {
    id: 'd6e15727-9fe1-4961-8c5b-ea44a9bd81aa',
    name: 'Evil Rabbit',
    email: 'evil@rabbit.com',
    image_url: '/customers/evil-rabbit.png',
  },
  {
    id: '126eed9c-c90c-4ef6-a4a8-fcf7408d3c66',
    name: 'Emil Kowalski',
    email: 'emil@kowalski.com',
    image_url: '/customers/emil-kowalski.png',
  },
  {
    id: 'CC27C14A-0ACF-4F4A-A6C9-D45682C144B9',
    name: 'Amy Burns',
    email: 'amy@burns.com',
    image_url: '/customers/amy-burns.png',
  },
  {
    id: '13D07535-C59E-4157-A011-F8D2EF4E0CBB',
    name: 'Balazs Orban',
    email: 'balazs@orban.com',
    image_url: '/customers/balazs-orban.png',
  },
];

const orders = [
  {
    customer_id: customers[0].id,
    product_id: snacks[0].id,
    quantity: Math.floor(snacks[0].stock / 3),
    status: 'pending',
    date: '2023-11-06',
  },
  {
    customer_id: customers[1].id,
    product_id: pantry[0].id,
    quantity: Math.floor(pantry[0].stock / 2),
    status: 'pending',
    date: '2023-12-14',
  },
  {
    customer_id: customers[4].id,
    product_id: candy[0].id,
    quantity: Math.floor(candy[0].stock / 5),
    status: 'paid',
    date: '2024-02-29',
  },
  {
    customer_id: customers[3].id,
    product_id: beverages[0].id,
    quantity: Math.floor(beverages[0].stock / 6),
    status: 'paid',
    date: '2024-02-10',
  },
  {
    customer_id: customers[5].id,
    product_id: breakfast[0].id,
    quantity: Math.floor(breakfast[0].stock / 4),
    status: 'pending',
    date: '2024-05-05',
  },
  {
    customer_id: customers[7].id,
    product_id: meatAndSeafood[0].id,
    quantity: Math.floor(meatAndSeafood[0].stock / 2),
    status: 'pending',
    date: '2024-05-16',
  },
  {
    customer_id: customers[6].id,
    product_id: bakeryAndDessert[0].id,
    quantity: Math.floor(bakeryAndDessert[0].stock / 3),
    status: 'pending',
    date: '2023-06-27',
  },
  {
    customer_id: customers[3].id,
    product_id: organic[0].id,
    quantity: Math.floor(organic[0].stock / 1.5),
    status: 'paid',
    date: '2023-09-09',
  },
  {
    customer_id: customers[4].id,
    product_id: coffee[0].id,
    quantity: Math.floor(coffee[0].stock / 8),
    status: 'paid',
    date: '2024-06-17',
  },
  {
    customer_id: customers[5].id,
    product_id: deli[0].id,
    quantity: Math.floor(deli[0].stock / 6),
    status: 'paid',
    date: '2024-06-07',
  },
  {
    customer_id: customers[1].id,
    product_id: household[0].id,
    quantity: Math.floor(household[0].stock / 3),
    status: 'paid',
    date: '2024-04-19',
  },
  {
    customer_id: customers[5].id,
    product_id: floral[0].id,
    quantity: Math.floor(floral[0].stock / 2),
    status: 'paid',
    date: '2023-10-03',
  },
  {
    customer_id: customers[2].id,
    product_id: cleaning[0].id,
    quantity: Math.floor(cleaning[0].stock / 3),
    status: 'paid',
    date: '2023-08-18',
  },
  {
    customer_id: customers[0].id,
    product_id: floral[1].id,
    quantity: Math.floor(floral[1].stock / 7),
    status: 'paid',
    date: '2024-01-04',
  },
  {
    customer_id: customers[2].id,
    product_id: beverages[1].id,
    quantity: Math.floor(beverages[1].stock / 10),
    status: 'paid',
    date: '2024-03-05',
  },
  {
    customer_id: customers[3].id,
    product_id: cleaning[1].id,
    quantity: Math.floor(cleaning[1].stock / 7),
    status: 'paid',
    date: '2024-05-18',
  },
  {
    customer_id: customers[4].id,
    product_id: floral[2].id,
    quantity: Math.floor(floral[2].stock / 10),
    status: 'paid',
    date: '2023-11-04',
  },
  {
    customer_id: customers[5].id,
    product_id: beverages[3].id,
    quantity: Math.floor(beverages[3].stock / 4),
    status: 'paid',
    date: '2023-12-05',
  },
];

module.exports = {
  users,
  customers,
  orders
};
