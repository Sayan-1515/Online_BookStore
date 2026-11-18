# 📚 Online Bookstore Management System (MySQL)

## 📌 Project Overview

The **Online Bookstore Management System** is a database management project developed using MySQL. It is designed to manage bookstore operations, including book inventory, categories, customer information, orders, stock management, and price tracking.

This project demonstrates practical implementation of SQL concepts such as CRUD operations, joins, indexes, triggers, constraints, and database relationships.

## 🎯 Project Objectives

- Manage books and their categories.
- Maintain customer information.
- Store and manage customer orders.
- Track book inventory and stock availability.
- Automatically calculate and store book prices during ordering.
- Maintain stock movement history.
- Track changes in book prices using audit records.

## 🛠️ Technologies Used

| Technology | Purpose |
|---|---|
| MySQL | Database management |
| MySQL Workbench | SQL development and execution |
| SQL | Database operations and queries |

## 🗄️ Database Structure

**Database Name:** `BookStore_Online`

The project consists of 7 tables:

| Table Name | Description |
|---|---|
| `categories` | Stores book categories |
| `books` | Stores book details, prices and stock |
| `customers` | Stores customer information |
| `orders` | Stores customer order information |
| `order_items` | Stores individual books included in orders |
| `stock_log` | Maintains stock change history |
| `price_audit` | Records book price changes |

## 🔗 Database Relationships

- One category can contain multiple books.
- One customer can place multiple orders.
- One order can contain multiple order items.
- One book can appear in multiple order items.
- Stock logs and price audit records are associated with books.

## ⚙️ Key Features

### 1. Book Management
- Store book titles and author names.
- Manage book categories.
- Maintain book prices and available stock.
- Track publication years.

### 2. Customer Management
- Store customer names, emails, and cities.
- Maintain unique customer email addresses.
- Track customer registration timestamps.

### 3. Order Management
- Create customer orders.
- Store order dates and order statuses.
- Maintain individual order items.

### 4. Inventory Management
- Check available stock before an order item is inserted.
- Automatically reduce stock after an order item is inserted.
- Maintain stock movement records.

### 5. Price Audit Management
- Track previous book prices.
- Record updated book prices.
- Maintain price change history.

## 🔥 MySQL Concepts Implemented

This project demonstrates the following SQL concepts:

- Database Creation
- Table Creation
- Primary Key and Foreign Key
- NOT NULL and UNIQUE Constraints
- DEFAULT Constraints
- CRUD Operations
- INSERT, UPDATE and DELETE
- SELECT Queries
- Aggregate Functions
- Joins
- Subqueries
- Indexes
- Triggers
- DELIMITER
- Conditional Statements
- Data Validation

## ⚡ Triggers Implemented

| Trigger | Event | Function |
|---|---|---|
| `before_order` | BEFORE INSERT | Validates stock and automatically copies the current book price |
| `after_order_item_insert` | AFTER INSERT | Reduces available stock and creates a stock log |
| `change_audit` | AFTER UPDATE | Records old and new book prices when the price changes |

## 📂 Project Structure

```text
Online-Bookstore-Management/
│
├── README.md
│
├── Demo Project - Online Book Store.sql
│
└── Screenshots/
    ├── database_tables.png
    ├── books_data.png
    ├── orders_data.png
    ├── trigger_execution.png
    └── price_audit.png
```

## 🚀 How to Run the Project

1. Install MySQL Server and MySQL Workbench.
2. Clone or download this repository.
3. Open the `.sql` file in MySQL Workbench.
4. Execute the database creation and table creation queries.
5. Insert the sample datasets.
6. Create the required triggers.
7. Execute SQL queries to test database operations.
8. Verify the results using SELECT statements.

## 📊 Sample Database Operations

```sql
-- View all books
SELECT * FROM books;

-- View all customers
SELECT * FROM customers;

-- View all orders
SELECT * FROM orders;

-- Check available stock
SELECT title, stock
FROM books;

-- View stock history
SELECT * FROM stock_log;

-- View price change history
SELECT * FROM price_audit;
```

## 🎓 Learning Outcomes

Through this project, I gained practical experience in:

- Designing relational databases.
- Implementing primary and foreign key relationships.
- Writing SQL queries for database operations.
- Managing inventory using triggers.
- Implementing automatic data validation.
- Maintaining stock and price audit records.
- Understanding database integrity and automation.
