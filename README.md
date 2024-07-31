# Getting Started

## Starting Up the PostgreSQL Database
Hosted on the cloud, no steps required!

## MySQL Commands for Creating / Mutating the Grocery Store

~~~~sql
CREATE DATABASE GroceryStore;
SHOW DATABASES; -- you should see your new groceryStore database under this list

USE GroceryStore;
~~~~

To add products to the store, run:

~~~~sql
CREATE TABLE Product (
    PId uuid PRIMARY KEY,
    PName VARCHAR(200),
    PStock INT,
    PPrice DECIMAL(10, 2)
);

SHOW TABLES; -- you should see your new table under this list
DESCRIBE tableName; -- you should see the new columns and their details
~~~~

To add items to the store, run:

~~~~sql
INSERT INTO Product(PId, PPrice, PName, PStock)
VALUES (PId PPrice, PName, PStock)

SELECT * FROM Product; -- you should see the new item's values inserted into the product table
~~~~

To update the quantity of an item in the store, run:

~~~~sql
UPDATE Product
SET PStock = PStock
WHERE PId = PId;

SELECT * FROM Product WHERE PId = PId; -- you should see that the item's quantity has been updated to PStock
~~~~

## Starting Up the Web Application

To run the development server, use command:

```bash
yarn dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

## Generating and Loading in the "Production" Dataset  

**Getting the production data**
- Download the production data (scraped from Costco's online marketplace) in the form of a .csv file from [Kaggle.com](https://www.kaggle.com/datasets/bhavikjikadara/grocery-store-dataset).
- Add .csv file to codebase: [GroceryDataset.csv](GroceryDataset.csv)

**Parsing the production data**
- Use the convert-csv-to-json library to convert the csv values to JSON format
- Iterate through the result and create new Typescript objects, converting the values from the csv file to the correct format
- Push to the products and subcategory array
- Export the products and subcategory arrays (will be pulled in seed.js where we will use it to populate the database)  
Open [DTO.js](app/lib/DTO.js) to see the code!

**Loading the data into the database data**

- We create and host the PostgreSQL database in Vercel, then add the URL and other environment variables of our database to [.env](.env). This way we can access and query our database using the SDK (more info below)
- We use the Vercel PostgreSQL SDK, which allows us to connect to the database, write postgreSQL code, as well as to query our database directly within our application code (can create and call functions that do this).

Open [seed.js](scripts/seed.js) to see the script and the code!

To load the data into the database, use command:
```bash
yarn seed
```  
This will seed your database with the data in the [GroceryDataset.csv](GroceryDataset.csv) file.  

## Trying Out Features
**To view the number of products in each category:**
-  Navigate to the dashboard by clicking the link provided above.
    You should see a number of cards displaying each category + the corresponding number of products

**To view all products in inventory:**
- Select the "Products" tab in the Side Nav.
    You should be navigated to dashboard/products
    *extra: try out the pagination* Flip through each page using arrow keys/page numbers at bottom of table to view 6 products at a time

**To search for a specific product:**
- Input the name / id value / price of the item you're searching for in the search bar
    - The query results should appear in the table

**To create + add a new product:**
- Select the "Products" tab in the Side Nav.
- Click on "Create Product"
- Fill out the form with the product information
- Select "Create Product" (the button) once finished
- Search for your item using the search bar
    - You should see your new item in the table!


## Currently Supported Features
### Regular Features
1. Viewing all products/customers/orders, filterable via search 
    Files:  
    - [fetchFilteredProducts() in data.ts](app/lib/data.ts)
    - [fetchFilteredCustomers() in data.ts](app/lib/data.ts)  
    - [fetchFilteredOrders() in data.ts](app/lib/data.ts)
    - [ProductsTable in table.tsx](app/ui/dashboard/products/table.tsx)
    - [CustomersTable in table.tsx](app/ui/dashboard/customers/table.tsx) 
    - [OrdersTable in table.tsx](app/ui/dashboard/orders/table.tsx)   

2. Viewing statistics (number of customers, total revenue, products in/out of stock, etc.)
    Files:  
    - [fetchCardData() in data.ts](app/lib/data.ts)
    - [all of cards.tsx](app/ui/dashboard/cards.tsx)

3. View the 5 best selling products
    Files:  
    - [fetchBestSellingProducts() in data.ts](app/lib/data.ts)
    - [BestSellingProducts() in best-selling.tsx](app/ui/dashboard/best-selling.tsx) 

4. Add/edit/delete a product, product status (in/out-of stock) will be automatically updated based off of the current stock value
    Files:  
    - [createTriggerFunction, triggerFunction in seedProducts() and seed functions for each category in seed.js](scripts/seed.js)
    - [createProduct() in actions.ts](app/lib/productActions.ts)
    - [updateProduct() in actions.ts](app/lib/productActions.ts)
    - [deleteProduct() in actions.ts](app/lib/productActions.ts)
    - [all of create-form.tsx](app/ui/products/create-form.tsx)
    - [all of edit-form.tsx](app/ui/products/edit-form.tsx)

5. Add/edit/delete an order, total cost when creating an order is automatically determined using the price of the product and the inputted quantity
    Files:  
    - [createUpdateAmount, triggerUpdateAmount in seedOrders() in seed.js](scripts/seed.js)
    - [createOrder() in actions.ts](app/lib/actions.ts)
    - [updateOrder() in actions.ts](app/lib/actions.ts)
    - [deleteOrder() in actions.ts](app/lib/actions.ts)
    - [all of create-form.tsx](app/ui/orders/create-form.tsx)
    - [all of edit-form.tsx](app/ui/orders/edit-form.tsx)

6. After adding/editing an order, product stock updates automatically to reflect the changes
    Files:
    - [createReduceStock, createRevertStock, createUpdateStock, triggerReduceStock, triggerRevertStock, triggerUpdateStock in seedOrders() in seed.js](scripts/seed.js)

7. After adding/editing an order, revenue updates automatically to reflect the changes
    Files:
    - [createUpdateRevenue, triggerUpdateRevenue in seedOrders() in seed.js](scripts/seed.js)


### Fancy Features
1. Pagination to load 5 items on each table and create pages at bottom for scrolling through 
    Files:  
    - [fetchProductPages(), fetchOrderPages(), fetchCustomerPages() in data.ts](app/lib/data.ts)
    - [Pagination() in pagination.ts](app/ui/dashboard/product/pagination.ts)
    - [Pagination() in pagination.ts](app/ui/dashboard/customer/pagination.ts)
    - [Pagination() in pagination.ts](app/ui/dashboard/orders/pagination.ts)

2. Login and authentication 
    Files:   
    - [seedUsers() in seed.js](scripts/seed.js)
    - [authenticate() in actions.js](app/lib/actions.ts)
    - [all of auth.config.js](auth.config.ts)
    - [all of auth.ts](auth.ts)

3. Read, write vs. read-only access control specific to admin, user roles
    Files:   
    - [auth() in Page() in page.tsx](app/dashboard/products/page.tsx)
    - [auth() in Page() in page.tsx](app/dashboard/orders/page.tsx)
    - [auth() in ProductsTable() in table.tsx](app/ui/products/table.tsx)
    - [auth() in OrdersTable() in table.tsx](app/ui/orders/table.tsx)
    - [seedUsers() in seed.js](scripts/seed.js)

4. Revenue graph shows change in revenue each month, automatically updated when new orders are added, only considers orders with status ‘paid’
    Files:   
    - [createUpdateRevenue, triggerUpdateRevenue in seedOrders() in seed.js](scripts/seed.js)
    - [fetchRevenue() in data.ts](app/lib/data.ts)
    - [RevenueChart() in revenue-chart.tsx](app/ui/dashboard/revenue-chart.tsx)
    - [generateYAxis in utils.ts](app/lib/utils.ts)

5. User friendly UI
   Files: 
   - All over the codebase, especially in the app/ui directory
   - MUI integration
   - Buttons
   - Cohesive Theme
   - heroIcons
   - Tailwind CSS
   - Skeletons of the UI components during loading

6. SQL injection vulnerability check (check that quantity selected in order is within product's available stock)
    Files: 
    - [createCheckStock, triggerCheckStock in seedOrders() in seed.js](scripts/seed.js)
