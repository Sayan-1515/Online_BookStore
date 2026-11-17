create database BookStore_Online;
use BookStore_Online;
set sql_safe_updates = 0;
-- Create tables

create table categories
(
category_id int primary key ,
category_name varchar(50) NOT NULL unique
);

create table books
(
book_id int primary key ,
title varchar(50)  not null,
author varchar(50) not null,
price int ,
stock int default 0,
published_year year,
category_id int ,

foreign key(category_id) references categories(category_id)
);

create table customers 
(
customer_id int primary key,
fullName varchar(50) not null,
email varchar(20) unique not null,
city varchar(20) not null,
created_at timestamp default current_timestamp
);
alter table customers 
modify email varchar(40);


create table orders
(
order_id int primary key auto_increment,
order_date timestamp default current_timestamp,
status enum("placed", "shipped", "canceled"),
customer_id int,

foreign key(customer_id ) references customers(customer_id)
);

create table order_items
(
item_id int primary key auto_increment,
order_id int,
quantity int not null,
book_id int ,
unit_price decimal(10,2) default 0,

foreign key(order_id) references orders(order_id),
foreign key(book_id) references books(book_id)
);

create table stock_log (
 log_id int auto_increment primary key,
 book_id int not null,
 change_qty int not null,
 reason VARCHAR(60),
 logged_at timestamp default current_timestamp
);

CREATE TABLE price_audit (
 audit_id int auto_increment primary key,
 book_id int not null,
 old_price decimal(10,2) not null,
 new_price decimal(10,2) not null ,
 changed_at timestamp default current_timestamp
);

show tables;

-- Create Indexes 
create index idx_books_title on books(title);
create index idx_order_date on orders(order_date);
create index idx_customer_city on customers(city);

show indexes from books;


-- Data Insert 

INSERT INTO categories (category_id, category_name) VALUES
(1, 'Programming'),
(2, 'Databases'),
(3, 'Fiction'),
(4, 'Biography'),
(5, 'Self-Help'),
(6, 'Data Science'),
(7, 'History');

INSERT INTO books
(book_id, title, author, category_id, price, stock, published_year)
VALUES
(1, 'Python Crash Course', 'Eric Matthes', 1, 599, 40, 2023),
(2, 'Learning SQL', 'Alan Beaulieu', 2, 550, 30, 2020),
(3, 'Wings of Fire', 'A. P. J. Abdul Kalam', 4, 250, 50, 1999),
(4, 'The Alchemist', 'Paulo Coelho', 3, 299, 45, 1988),
(5, 'Pather Panchali', 'Bibhutibhushan Bandyopadhyay', 3, 220, 25, 1929),
(6, 'Clean Code', 'Robert C. Martin', 1, 650, 20, 2008),
(7, 'Atomic Habits', 'James Clear', 5, 399, 60, 2018),
(8, 'Data Science from Scratch', 'Joel Grus', 6, 720, 15, 2019),
(9, 'Feluda Samagra', 'Satyajit Ray', 3, 350, 35, 1992),
(10, 'Ikigai', 'Hector Garcia', 5, 280, 40, 2016),
(11, 'SQL Cookbook', 'Anthony Molinaro', 2, 680, 18, 2005),
(12, 'The Discovery of India', 'Jawaharlal Nehru', 7, 450, 22, 1946);

INSERT INTO customers
(customer_id, fullName, email, city)
VALUES
(1, 'Ananya Sen', 'ananya.sen@example.com', 'Kolkata'),
(2, 'Rahul Das', 'rahul.das@example.com', 'Howrah'),
(3, 'Priya Ghosh', 'priya.ghosh@example.com', 'Kolkata'),
(4, 'Arjun Mitra', 'arjun.mitra@example.com', 'Durgapur'),
(5, 'Sneha Roy', 'sneha.roy@example.com', 'Kolkata'),
(6, 'Imran Sheikh', 'imran.sheikh@example.com', 'Siliguri'),
(7, 'Debjani Paul', 'debjani.paul@example.com', 'Howrah'),
(8, 'Rohit Banerjee', 'rohit.banerjee@example.com', 'Kolkata');

-- Create triggers

--  1: before an item is saved, check stock and copy the current book price
delimiter //
create trigger before_order 
before insert on order_items
for each row 
begin
    declare v_price decimal(8,2);
    declare v_stock int ;
    
    select price, stock into v_price ,v_stock
    from books 
    where book_id = new.book_id ;
    
    if v_stock < new.quantity then 
    signal sqlstate  "45000"
    set message_text = "Out of stock" ;
    end if;
    
    set new.unit_price = v_price ;
end //
delimiter ;

-- 2: after an item is saved, reduce stock and write a stock log row
delimiter //
create trigger trg_items_after_insert
after insert on order_items
for each row
begin
    update books
    set stock = stock - new.quantity
    where book_id = new.book_id;

    insert into stock_log (book_id, change_qty, reason)
    values (
        new.book_id,
        -new.quantity,
        concat('order #', new.order_id)
    );
end //
delimiter ;

-- 3: whenever a book price changes, keep an audit record
delimiter //
create trigger change_audit
after update on books 
for each row 
begin 
    if old.price = new.price then 
    insert into price_audit(book_id, old_price, new_price)
    value (old.book_id , old.price, new.price);
end if ;
end //
delimiter ;

INSERT INTO orders (customer_id, order_date) VALUES
(1, '2026-08-05 10:30:00'),
(2, '2026-08-18 14:15:00'),
(3, '2026-09-02 09:45:00'),
(1, '2026-09-14 16:20:00'),
(4, '2026-09-21 11:05:00'),
(5, '2026-10-03 13:40:00'),
(6, '2026-10-12 18:10:00'),
(2, '2026-10-25 12:00:00'),
(7, '2026-11-02 15:30:00'),
(3, '2026-11-08 17:45:00');

-- unit_price is NOT supplied: the BEFORE INSERT trigger fills it
INSERT INTO order_items (order_id, book_id, quantity) VALUES
(1, 1, 1), (1, 2, 1),
(2, 7, 2),
(3, 3, 1), (3, 4, 1), (3, 10, 1),
(4, 6, 1),
(5, 8, 1), (5, 11, 1),
(6, 5, 2), (6, 9, 1),
(7, 7, 1), (7, 12, 1),
(8, 1, 2),
(9, 2, 1), (9, 4, 2),
(10, 7, 3);


-- Quaries

-- all books in a price range
select * from books 
where price between 300 and 500;

-- books whose title contains the word SQL
select * from books 
where title like "%SQL%" ;

-- distinct cities of customers
select distinct city from customers;

--  books with their category names (INNER JOIN)
select * from books b
inner join categories c
on b.category_id = c.category_id ;

--  who placed which order (JOIN) 
select c.fullName,o.order_id  from orders o
inner join customers c
on o.customer_id = c.customer_id;

-- 5 most expensive books
select title, price
from books
order by price desc
limit 5;

-- books sorted by category then by title
select c.category_name, b.title
from books b
join categories c
on c.category_id = b.category_id
order by c.category_name, b.title;

-- customers per city
select city, count(*) as customers
from customers
group by city
order by customers desc, city;


-- number of titles and average price per category
select c.category_name, count(*) as titles, round(avg(b.price), 2) as avg_price
from books b
join categories c on c.category_id = b.category_id
group by c.category_name
order by titles desc, c.category_name;


-- monthly revenue
select date_format(o.order_date, '%Y-%m') as sales_month,
       sum(oi.quantity * oi.unit_price) as revenue
from orders o
join order_items oi on oi.order_id = o.order_id
group by sales_month
order by sales_month;


-- customers who spent more than 1000 (having filters groups)
select c.fullName, sum(oi.quantity * oi.unit_price) as total_spent
from customers c
join orders o 
on o.customer_id = c.customer_id
join order_items oi 
on oi.order_id = o.order_id
group by c.customer_id, c.fullName
having total_spent > 1000
order by total_spent desc;


-- best selling books (top 5 by units sold)
select b.title, sum(oi.quantity) as units_sold
from order_items oi
join books b on b.book_id = oi.book_id
group by b.book_id, b.title
order by units_sold desc, b.title
limit 5;


-- customers who never ordered (left join + is null)
select c.customer_id, c.fullName
from customers c
left join orders o 
on o.customer_id = c.customer_id
where o.order_id is null;


-- Update 
-- mark the first seven orders as shipped
update orders
set status = 'shipped'
where order_id between 1 and 7;


-- 10 percent price hike for programming books (trigger writes price_audit)
update books
set price = round(price * 1.10, 2)
where category_id = (
    select category_id
    from categories
    where category_name = 'programming'
);


-- restock books that are running low
update books
set stock = stock + 25
where stock < 20;

-- count orders by status
select status, count(*) as orders
from orders
group by status;

-- view price audit records
select * from price_audit;

-- check selected books
select book_id, title, price, stock
from books
where book_id in (1, 6, 8, 11);

-- Views
-- create order summary view
create view v_order_summary as
select o.order_id,
       c.fullName,
       c.city,
       o.order_date,
       o.status,
       sum(oi.quantity) as total_items,
       sum(oi.quantity * oi.unit_price) as order_total
from orders o
join customers c on c.customer_id = o.customer_id
join order_items oi on oi.order_id = o.order_id
group by o.order_id, c.fullName, c.city, o.order_date, o.status;


-- create category sales view
create view v_category_sales as
select c.category_name,
       sum(oi.quantity) as units_sold,
       sum(oi.quantity * oi.unit_price) as revenue
from order_items oi
join books b on b.book_id = oi.book_id
join categories c on c.category_id = b.category_id
group by c.category_name;


-- create low stock view
create view v_low_stock as
select book_id, title, stock
from books
where stock < 25;

-- display order summary
select *
from v_order_summary
order by order_id;

-- display category sales
select *
from v_category_sales
order by revenue desc;

-- display low stock books
select *
from v_low_stock
order by stock;

-- Transection
-- a) successful order, one item removed with a savepoint
start transaction;
insert into orders (customer_id)
values (8);

set @new_order = last_insert_id();

insert into order_items (order_id, book_id, quantity)
values (@new_order, 2, 1);

savepoint after_first_item;

insert into order_items (order_id, book_id, quantity)
values (@new_order, 6, 1);

rollback to savepoint after_first_item;
commit;

select oi.order_id, b.title, oi.quantity, oi.unit_price
from order_items oi
join books b on b.book_id = oi.book_id
where oi.order_id = @new_order;

-- b) failed order: the trigger blocks 999 copies, rollback undoes everything
start transaction;

insert into orders (customer_id)
values (8);

insert into order_items (order_id, book_id, quantity)
values (last_insert_id(), 8, 999);
rollback;

select count(*) as orders_of_customer_8
from orders
where customer_id = 8;

select book_id, title, stock
from books
where book_id in (2, 6, 8);

SELECT * FROM stock_log ORDER BY log_id DESC LIMIT 6;
SELECT COUNT(*) AS stock_log_rows FROM stock_log;