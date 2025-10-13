-- LAB5
-- Student Full Name : Daulet Ryskul 
-- Student ID: 24B031979

CREATE DATABASE constraints_lab;
\c constraints_lab;

CREATE TABLE employees (
    employee_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CHECK (age BETWEEN 18 AND 65),        -- Employee must be between 18 and 65 years old
    salary NUMERIC CHECK (salary > 0)                 -- Salary must be greater than zero
);

-- Valid insertions
INSERT INTO employees VALUES (1, 'Alice', 'Johnson', 30, 5000);
INSERT INTO employees VALUES (2, 'Bob', 'Smith', 45, 7000);

--  Invalid insertion: violates age constraint
-- INSERT INTO employees VALUES (3, 'Charlie', 'Brown', 16, 4000);


--  Invalid insertion: violates salary constraint
-- INSERT INTO employees VALUES (4, 'David', 'Lee', 40, -2000);


CREATE TABLE products_catalog (
    product_id INTEGER,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK (
        regular_price > 0 AND 
        discount_price > 0 AND 
        discount_price < regular_price
    )
);

-- Valid insertions
INSERT INTO products_catalog VALUES (1, 'Laptop', 1500, 1200);
INSERT INTO products_catalog VALUES (2, 'Mouse', 50, 30);

-- Invalid insertion: discount higher than regular price
-- INSERT INTO products_catalog VALUES (3, 'Keyboard', 100, 120);

-- Invalid insertion: negative price
-- INSERT INTO products_catalog VALUES (4, 'Monitor', -200, 100);

CREATE TABLE bookings (
    booking_id INTEGER,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INTEGER CHECK (num_guests BETWEEN 1 AND 10),
    CHECK (check_out_date > check_in_date)  -- Ensure check-out is after check-in
);

-- Valid insertions
INSERT INTO bookings VALUES (1, '2025-10-10', '2025-10-15', 2);
INSERT INTO bookings VALUES (2, '2025-11-01', '2025-11-03', 5);

-- Invalid insertion: too many guests
-- INSERT INTO bookings VALUES (3, '2025-11-01', '2025-11-02', 12);

-- Invalid insertion: check-out before check-in
-- INSERT INTO bookings VALUES (4, '2025-11-05', '2025-11-03', 2);

CREATE TABLE customers (
    customer_id INTEGER NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,                          -- Phone can be NULL
    registration_date DATE NOT NULL
);

-- Valid insertions
INSERT INTO customers VALUES (1, 'john@example.com', '123456789', '2025-10-01');
INSERT INTO customers VALUES (2, 'maria@example.com', NULL, '2025-10-10');
-- (phone is allowed to be NULL — this insert is valid)

-- Invalid insertion: missing NOT NULL field
-- INSERT INTO customers VALUES (3, NULL, '999999', '2025-10-02');

CREATE TABLE inventory (
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);

-- Valid insertions
INSERT INTO inventory VALUES (1, 'Monitor', 15, 300, NOW());
INSERT INTO inventory VALUES (2, 'Keyboard', 50, 40, NOW());

-- Invalid insertion: quantity negative
-- INSERT INTO inventory VALUES (3, 'Mouse', -10, 20, NOW());

-- Invalid insertion: unit_price zero
-- INSERT INTO inventory VALUES (4, 'USB Cable', 30, 0, NOW());

-- Invalid insertion: NULL in NOT NULL column
-- INSERT INTO inventory VALUES (5, NULL, 10, 15, NOW());


CREATE TABLE users (
    user_id INTEGER,
    username TEXT UNIQUE,  -- username must be unique
    email TEXT UNIQUE,     -- email must also be unique
    created_at TIMESTAMP
);

-- Valid insertions
INSERT INTO users VALUES (1, 'alex99', 'alex99@mail.com', NOW());
INSERT INTO users VALUES (2, 'nina_k', 'nina.k@example.com', NOW());

-- Invalid insertion: duplicate username
-- INSERT INTO users VALUES (3, 'alex99', 'alex_new@mail.com', NOW());

-- Invalid insertion: duplicate email
-- INSERT INTO users VALUES (4, 'tommy', 'nina.k@example.com', NOW());

CREATE TABLE course_enrollments (
    enrollment_id INTEGER,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,
    CONSTRAINT unique_student_course UNIQUE (student_id, course_code, semester)
    -- student_id + course_code + semester must be unique
);

-- Valid insertions
INSERT INTO course_enrollments VALUES (1, 1001, 'CS101', 'Fall2025');
INSERT INTO course_enrollments VALUES (2, 1002, 'CS101', 'Fall2025');
INSERT INTO course_enrollments VALUES (3, 1001, 'CS101', 'Spring2026');

-- Invalid insertion: same student, course, and semester
-- INSERT INTO course_enrollments VALUES (4, 1001, 'CS101', 'Fall2025');

DROP TABLE IF EXISTS users;

CREATE TABLE users (
    user_id INTEGER,
    username TEXT,
    email TEXT,
    created_at TIMESTAMP,
    CONSTRAINT unique_username UNIQUE (username),
    CONSTRAINT unique_email UNIQUE (email)
);

-- Valid insertions
INSERT INTO users VALUES (1, 'sara_01', 'sara@example.com', NOW());
INSERT INTO users VALUES (2, 'michael02', 'michael@example.com', NOW());

-- Invalid: duplicate username
-- INSERT INTO users VALUES (3, 'sara_01', 'new_sara@example.com', NOW());

-- Invalid: duplicate email
-- INSERT INTO users VALUES (4, 'johnny', 'michael@example.com', NOW());

CREATE TABLE departments (
    dept_id INTEGER PRIMARY KEY,  -- unique identifier for each department
    dept_name TEXT NOT NULL,
    location TEXT
);

--  Valid insertions
INSERT INTO departments VALUES (10, 'Human Resources', 'Building A');
INSERT INTO departments VALUES (20, 'Finance', 'Building B');
INSERT INTO departments VALUES (30, 'IT', 'Building C');

--  Invalid insertion: duplicate primary key
-- INSERT INTO departments VALUES (10, 'Sales', 'Building D');

--  Invalid insertion: NULL primary key
-- INSERT INTO departments VALUES (NULL, 'Marketing', 'Building E');

CREATE TABLE student_courses (
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id, course_id)
    -- student_id and course_id uniquely identifies each record
);

-- Valid insertions
INSERT INTO student_courses VALUES (2001, 101, '2025-09-10', 'A');
INSERT INTO student_courses VALUES (2001, 102, '2025-09-15', 'B');
INSERT INTO student_courses VALUES (2002, 101, '2025-09-12', 'A-');

-- Invalid insertion: duplicate composite key
-- INSERT INTO student_courses VALUES (2001, 101, '2025-09-18', 'B+');

-- Difference between UNIQUE and PRIMARY KEY:
--    - PRIMARY KEY uniquely identifies each record in the table and cannot be NULL.
--    - UNIQUE constraint also ensures uniqueness but allows NULL values (except when combined with NOT NULL).
--    - Each table can only have one PRIMARY KEY, but it can have multiple UNIQUE constraints.

-- When to use single-column vs. composite PRIMARY KEY:
--    - Single-column PK is best when one attribute uniquely identifies each record (e.g., dept_id).
--    - Composite PK is used when no single column can uniquely identify a record, but a combination can (e.g., student_id + course_id).

-- Why only one PRIMARY KEY but multiple UNIQUE constraints:
--    - A table can only have one "main" identifier (PRIMARY KEY) that defines entity uniqueness.
--    - However, other columns or combinations can also be required to be unique for business logic (e.g., email, username), hence multiple UNIQUEs are allowed.


CREATE TABLE employees_dept (
    emp_id INTEGER PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id),
    hire_date DATE
);

--Valid insertions (departments 10, 20, 30 exist)
INSERT INTO employees_dept VALUES (101, 'Alice Brown', 10, '2025-01-10');
INSERT INTO employees_dept VALUES (102, 'Mark Lewis', 30, '2025-03-22');

-- Invalid insertion: dept_id 50 does not exist in departments
-- INSERT INTO employees_dept VALUES (103, 'Nina Fox', 50, '2025-04-01');

CREATE TABLE authors (
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);

CREATE TABLE publishers (
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);

CREATE TABLE books (
    book_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors(author_id),
    publisher_id INTEGER REFERENCES publishers(publisher_id),
    publication_year INTEGER,
    isbn TEXT UNIQUE
);

-- Insert sample authors
INSERT INTO authors VALUES (1, 'J.K. Rowling', 'UK');
INSERT INTO authors VALUES (2, 'George R.R. Martin', 'USA');

-- Insert sample publishers
INSERT INTO publishers VALUES (1, 'Bloomsbury', 'London');
INSERT INTO publishers VALUES (2, 'Bantam Books', 'New York');

-- Insert sample books with valid FKs
INSERT INTO books VALUES (1, 'Harry Potter', 1, 1, 1997, '978-0747532743');
INSERT INTO books VALUES (2, 'A Game of Thrones', 2, 2, 1996, '978-0553103540');

-- Invalid insertion: author_id does not exist
-- INSERT INTO books VALUES (3, 'Unknown Book', 5, 1, 2020, '000-0000000000');

CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE products_fk (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);

CREATE TABLE order_items (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk(product_id),
    quantity INTEGER CHECK (quantity > 0)
);

-- Insert sample data
INSERT INTO categories VALUES (1, 'Electronics'), (2, 'Clothing');
INSERT INTO products_fk VALUES (1, 'Laptop', 1), (2, 'T-shirt', 2);
INSERT INTO orders VALUES (100, '2025-10-10');
INSERT INTO order_items VALUES (1, 100, 1, 2), (2, 100, 2, 1);

-- Try to delete a category that has products
-- DELETE FROM categories WHERE category_id = 1;
-- (Fails - ON DELETE RESTRICT prevents deleting a category referenced in products_fk)

-- Delete an order and observe CASCADE effect
DELETE FROM orders WHERE order_id = 100;
-- (This automatically deletes related rows from order_items due to ON DELETE CASCADE)

-- Check the remaining order_items
-- SELECT * FROM order_items;
-- (Empty, all order_items linked to order_id=100 deleted automatically)


CREATE TABLE ecom_customers (
    customer_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,                -- unique email for each customer
    phone TEXT,
    registration_date DATE NOT NULL
);

CREATE TABLE ecom_products (
    product_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC NOT NULL CHECK (price >= 0), -- price must be non-negative
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE ecom_orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES ecom_customers(customer_id) ON DELETE CASCADE,
    order_date DATE NOT NULL,
    total_amount NUMERIC NOT NULL CHECK (total_amount >= 0),
    status TEXT NOT NULL CHECK (
        status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')
    )
);

CREATE TABLE ecom_order_details (
    order_detail_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES ecom_orders(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES ecom_products(product_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price > 0)
);


INSERT INTO ecom_customers (name, email, phone, registration_date) VALUES
('Alice Carter', 'alice@mail.com', '111222333', '2025-01-15'),
('Bob Martin', 'bob@mail.com', '222333444', '2025-02-01'),
('Charlie Day', 'charlie@mail.com', NULL, '2025-02-10'),
('Diana Prince', 'diana@mail.com', '333444555', '2025-03-05'),
('Ethan Hunt', 'ethan@mail.com', '444555666', '2025-03-15');

INSERT INTO ecom_products (name, description, price, stock_quantity) VALUES
('Laptop', 'Gaming laptop with RTX 4070', 1500, 10),
('Mouse', 'Wireless mouse', 30, 100),
('Keyboard', 'Mechanical keyboard', 80, 50),
('Monitor', '27-inch 4K display', 400, 20),
('Headphones', 'Noise cancelling', 200, 30);

INSERT INTO ecom_orders (customer_id, order_date, total_amount, status) VALUES
(1, '2025-10-01', 1530, 'shipped'),
(2, '2025-10-02', 110, 'processing'),
(3, '2025-10-03', 200, 'pending'),
(4, '2025-10-04', 400, 'delivered'),
(5, '2025-10-05', 80, 'cancelled');

INSERT INTO ecom_order_details (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 1500),
(1, 2, 1, 30),
(2, 3, 1, 80),
(3, 5, 1, 200),
(4, 4, 1, 400);

-- Constraint Tests

--Invalid duplicate email
-- INSERT INTO ecom_customers (name, email, phone, registration_date)
-- VALUES ('Fake', 'alice@mail.com', '555666777', '2025-10-06');
-- (violates UNIQUE constraint on ecom_customers.email)

--Invalid product with negative stock
-- INSERT INTO ecom_products (name, description, price, stock_quantity)
-- VALUES ('Faulty Item', 'bad data', 100, -5);
-- (violates CHECK constraint "stock_quantity >= 0")

-- Invalid order status
-- INSERT INTO ecom_orders (customer_id, order_date, total_amount, status)
-- VALUES (1, '2025-10-06', 100, 'waiting');
-- (violates CHECK constraint on ecom_orders.status)

-- Test ON DELETE CASCADE for orders → order_details
DELETE FROM ecom_orders WHERE order_id = 3;
-- (Deleting order_id=3 automatically deletes related records from ecom_order_details)

-- SELECT * FROM ecom_order_details WHERE order_id = 3;
-- (No rows found → CASCADE works correctly)
