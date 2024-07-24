const { faker } = require('@faker-js/faker');
const { v4: uuidv4 } = require('uuid')
const csvToJson = require('convert-csv-to-json');

const products = [];
const snacks = [];
const pantry = [];
const candy = [];
const beverages = [];
const meatAndSeafood = [];
const bakeryAndDessert = [];
const breakfast = [];
const cleaning = [];
const coffee = [];
const deli = [];
const floral = [];
const household = [];
const organic = [];


let result = csvToJson.fieldDelimiter(',')
                        .formatValueByType()
                        .supportQuotedField(true)
                        .getJsonFromCsv('/Users/sharonpark/School/cs338/inventory/GroceryDataset.csv');

result.map(r => {

    let stock = Math.floor( Math.random() * 1000 );
    let expiry = faker.date.soon();

    const product = {
        id: uuidv4(),
        name: r.Title,
        stock: stock,
        price: parseInt(r.Price.slice(1), 10),
        status: stock > 0 ? 'in-stock' : 'out-of-stock',
    };

    if (r.SubCategory == 'Snacks') {
        products.push({
            ...product,
            category: 'snacks',
            expiry: expiry,
        });
        snacks.push({
            ...product,
            expiry: expiry,
        });
    }

    if (r.SubCategory == 'Pantry & Dry Goods') {
        products.push({
            ...product,
            category: 'pantry',
            expiry: expiry,
        });
        pantry.push({
            ...product,
            expiry: expiry,
        });
    }

    if (r.SubCategory == 'Candy') {
        products.push({
            ...product,
            category: 'candy',
            expiry: expiry,
        });
        candy.push({
            ...product,
            expiry: expiry,
        });
    }

    if (r.SubCategory == 'Beverages & Water') {
        products.push({
            ...product,
            category: 'beverages',
            expiry: expiry,
        });
        beverages.push({
            ...product,
            expiry: expiry,
        });
    }

    if (r.SubCategory == 'Meat & Seafood') {
        products.push({
            ...product,
            category: 'meatAndSeafood',
            expiry: expiry,
        });
        meatAndSeafood.push({
            ...product,
            expiry: expiry,
        });
    }

    if (r.SubCategory == 'Bakery & Desserts') {
        products.push({
            ...product,
            category: 'bakeryAndDesserts',
            expiry: expiry,
        });
        bakeryAndDessert.push({
            ...product,
            expiry: expiry,
        });
    }

    if (r.SubCategory == 'Breakfast') {
        products.push({
            ...product,
            category: 'breakfast',
            expiry: expiry,
        });
        breakfast.push({
            ...product,
            expiry: expiry,
        });
    }

    if (r.SubCategory == 'Coffee') {
        products.push({
            ...product,
            category: 'coffee',
            expiry: expiry,
        });
        coffee.push({
            ...product,
            expiry: expiry,
        });
    }

    if (r.SubCategory == 'Deli') {
        products.push({
            ...product,
            category: 'deli',
            expiry: expiry,
        });
        deli.push({
            ...product,
            expiry: expiry,
        });
    }

    if (r.SubCategory == 'Organic') {
        products.push({
            ...product,
            category: 'organic',
            expiry: expiry,
        });
        organic.push({
            ...product,
            expiry: expiry,
        });
    }

    if (r.SubCategory == 'Cleaning Supplies') {
        products.push({
            ...product,
            category: 'cleaning',
            expiry: null,
        });
        cleaning.push(product);
    }

    if (r.SubCategory == 'Floral') {
        products.push({
            ...product,
            category: 'floral',
            expiry: null,
        });
        floral.push(product);
    }

    if (r.SubCategory == 'Household') {
        products.push({
            ...product,
            category: 'household',
            expiry: null,
        });
        household.push(product);
    }
});

module.exports = { 
    products,
    snacks,
    pantry,
    candy,
    beverages,
    meatAndSeafood,
    bakeryAndDessert,
    breakfast,
    coffee,
    deli,
    organic,
    cleaning,
    floral,
    household
};
