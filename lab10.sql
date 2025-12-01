CREATE TABLE accounts (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  balance DECIMAL(10,2) DEFAULT 0.00
);

CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  shop VARCHAR(100) NOT NULL,
  product VARCHAR(100) NOT NULL,
  price DECIMAL(10,2) NOT NULL
);

INSERT INTO accounts (name, balance) VALUES
 ('Alice', 1000.00),
 ('Bob', 500.00),
 ('Wally', 750.00);

INSERT INTO products (shop, product, price) VALUES
 ('Joe''s Shop', 'Coke', 2.50),
 ('Joe''s Shop', 'Pepsi', 3.00);


BEGIN;
UPDATE accounts SET balance = balance - 100.00 WHERE name = 'Alice';
UPDATE accounts SET balance = balance + 100.00 WHERE name = 'Bob';
COMMIT;

--a. alice=900,bob=600
--b. to ensure atomicity: both operations succeed or none
--c. crash - money disappears


BEGIN;
UPDATE accounts SET balance = balance - 500.00 WHERE name = 'Alice';
SELECT * FROM accounts WHERE name = 'Alice';
ROLLBACK;
SELECT * FROM accounts WHERE name = 'Alice';

--a. 400
--b. 900
--c. used when an error happens mid-transaction

BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE name='Alice';
SAVEPOINT my_savepoint;
UPDATE accounts SET balance = balance + 100 WHERE name='Bob';

ROLLBACK TO my_savepoint;

UPDATE accounts SET balance = balance + 100 WHERE name='Wally';
COMMIT;

SELECT * FROM accounts;

--a. alice 800, bob 600, wally 850
--b. bob was credited temporarily but rolled back,so final=unchanged
--c. savepoints avoid restarting whole transaction

BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM products WHERE shop='Joe''s Shop';
SELECT * FROM products WHERE shop='Joe''s Shop';
COMMIT;

BEGIN;
DELETE FROM products WHERE shop='Joe''s Shop';
INSERT INTO products (shop, product, price)
VALUES ('Joe''s Shop', 'Fanta', 3.50);
COMMIT;


--a. read commited: before = coke/pepsi; after=fanta only
--b. serializable: always sees original data
--c. read commited allows phantoms

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT MAX(price), MIN(price) FROM products WHERE shop='Joe''s Shop';

SELECT MAX(price), MIN(price) FROM products WHERE shop='Joe''s Shop';
COMMIT;

BEGIN;
INSERT INTO products (shop, product, price)
VALUES ('Joe''s Shop', 'Sprite', 4.00);
COMMIT;
--a. terminal 1 does not see sprite
--b. phantom read=new rows appear between two reads
--c. serializable prevents phantoms

BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM products WHERE shop='Joe''s Shop';
SELECT * FROM products WHERE shop='Joe''s Shop';
SELECT * FROM products WHERE shop='Joe''s Shop';
COMMIT;

BEGIN;
UPDATE products SET price = 99.99 WHERE product='Fanta';
ROLLBACK;

--a. yes, t1 sees 99.99-dirty read
--b. dirty read=reading uncommitted data
--c. read uncommited is unsafe  should be avoided


BEGIN;


DO $$
DECLARE
    bob_balance DECIMAL;
BEGIN
    SELECT balance INTO bob_balance FROM accounts WHERE name='Bob';

    IF bob_balance >= 200 THEN
        UPDATE accounts SET balance = balance - 200 WHERE name='Bob';
        UPDATE accounts SET balance = balance + 200 WHERE name='Wally';
    ELSE
        RAISE NOTICE 'Bob does not have enough funds.';
    END IF;
END $$;


COMMIT;

SELECT * FROM accounts;

BEGIN;
INSERT INTO products (shop, product, price) VALUES ('Joe''s Shop', 'Fanta', 3.50);
SAVEPOINT sp1;
UPDATE products SET price = 4.00 WHERE product='Fanta';
SAVEPOINT sp2;
DELETE FROM products WHERE product='Fanta';
ROLLBACK TO sp1;
COMMIT;
SELECT * FROM products;
--final state: water exists

BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
UPDATE accounts SET balance = balance - 300 WHERE name='Alice';

BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
UPDATE accounts SET balance = balance - 800 WHERE name='Alice';

COMMIT;
COMMIT;
SELECT * FROM accounts;
--read commited: both see same initial balance -overdraft possible
--serializable- second one gets serialization error

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT MAX(price), MIN(price) FROM products WHERE shop='Joe''s Shop';
SELECT MAX(price), MIN(price) FROM products WHERE shop='Joe''s Shop';
COMMIT;

--1
-- Atomic: either full transfer or none
-- Consistent: constraints stay valid
-- Isolated: concurrent users don’t interfere
-- Durable: committed data survives crash
--2
-- COMMIT = save changes; ROLLBACK = undo
--3
-- SAVEPOINT = partial rollback inside transaction
--4
-- Read uncommitted – dirty reads allowed
-- Read committed – no dirty reads
-- Repeatable read – no non-repeatable reads
-- Serializable – no phantoms
--5
-- Dirty read = uncommitted read; allowed in READ UNCOMMITTED
--6
-- Non-repeatable read → same row read twice → values differ
-- 7
-- Phantom read = new rows appear; prevented only in SERIALIZABLE
-- 8
-- READ COMMITTED is faster; SERIALIZABLE is slow
-- 9
-- Transactions prevent race conditions & inconsistent updates
-- 10
-- Uncommitted data is lost on crash

-- Conclusion:
-- During this laboratory work, I learned that transactions allow multiple SQL operations to be executed
-- as a single logical unit, ensuring data integrity. I understood the ACID properties:
-- Atomicity ensures that either all operations succeed or none do;
-- Consistency guarantees that the database remains in a valid state;
-- Isolation prevents concurrent transactions from interfering with each other;
-- Durability ensures that committed changes persist even after a system crash.
-- I practiced using COMMIT, ROLLBACK, and SAVEPOINT to control transactions and observed how
-- different isolation levels affect concurrency, including phenomena like dirty reads, non-repeatable reads,
-- and phantom reads. Overall, transactions are essential for maintaining reliable and consistent database operations.




