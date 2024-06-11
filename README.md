This is a [Next.js](https://nextjs.org/) project bootstrapped with [`create-next-app`](https://github.com/vercel/next.js/tree/canary/packages/create-next-app).

# Getting Started

## Starting Up the MySQL Database

To connect to the MySQL server, run:

```bash
mysql -u root
```

To create a sample database, run:

~~~~sql
CREATE DATABASE databaseName;
SHOW DATABASES; -- you should see your new database under this list

USE databaseName;
CREATE TABLE tableName
(
    columnName columnType
    ...
);

SHOW TABLES; -- you should see your new table under this list
DESCRIBE tableName; -- you should see the new columns and their details
~~~~

To populate the database, run:

~~~~sql
INSERT INTO tableName ( columnName, ... ) VALUES
  ( columnValue, ... ),
    ...
SELECT * FROM tableName; -- you should see all your new values inserted into the table
~~~~

## Starting Up the Web Application

To run the development server, use command:

```bash
npm run dev
# or
yarn dev
# or
pnpm dev
# or
bun dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.