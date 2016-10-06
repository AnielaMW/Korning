-- DEFINE YOUR DATABASE SCHEMA HERE
DROP TABLE IF EXISTS invoice;
DROP TABLE IF EXISTS employee;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS frequency;

CREATE TABLE invoice(
  id SERIAL PRIMARY KEY,
  employee_id INTEGER,
  customer_id INTEGER,
  product_id INTEGER,
  sale_date DATE,
  sale_amount MONEY,
  units_sold INTEGER,
  invoice_no INTEGER,
  invoice_frequency INTEGER
);

CREATE TABLE employee(
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  email VARCHAR(255)
);

CREATE TABLE customer(
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  account_no VARCHAR(255)
);

CREATE TABLE product(
  id SERIAL PRIMARY KEY,
  name VARCHAR(255)
);

CREATE TABLE frequency(
  id SERIAL PRIMARY KEY,
  frequency VARCHAR(255)
);
