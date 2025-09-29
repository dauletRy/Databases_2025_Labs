CREATE DATABASE advanced_lab;

\c advanced_lab;

-- Employees table: department is stored as text .
CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50) DEFAULT NULL,
    salary INTEGER DEFAULT 40000,
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(50),
    budget INTEGER,
    manager_id INTEGER
);

CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    dept_id INTEGER REFERENCES departments(dept_id),
    start_date DATE,
    end_date DATE,
    budget INTEGER
);

-- Insert sample employees and departments
INSERT INTO employees (first_name, last_name, department)
VALUES ('John', 'Doe', 'IT');

INSERT INTO employees (first_name, last_name, department, hire_date)
VALUES ('Alice', 'Smith', 'HR', '2023-05-10');

INSERT INTO departments (dept_name, budget, manager_id)
VALUES 
('IT', 150000, 1),
('HR', 80000, 2),
('Sales', 120000, 3);

-- Salary with expression: 50000 * 1.1 = 55000
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Bob', 'Williams', 'Finance', 50000 * 1.1, CURRENT_DATE);

-- Temp table for intermediate queries
CREATE TEMP TABLE temp_employees AS
SELECT * FROM employees WHERE department = 'IT';

-- Increase salary by 10% for everyone
UPDATE employees
SET salary = salary * 1.10;

-- Promote based on salary and hire date
UPDATE employees
SET status = 'Senior'
WHERE salary > 60000
  AND hire_date < '2020-01-01';

-- Reclassify departments based on salary ranges
UPDATE employees
SET department = CASE
    WHEN salary > 80000 THEN 'Management'
    WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
    ELSE 'Junior'
END;

-- Reset department if inactive
UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

-- Adjust dept budget based on average employee salary × 1.2
UPDATE departments
SET budget = (SELECT AVG(salary) * 1.2
              FROM employees
              WHERE employees.department = departments.dept_name);

-- Sales employees get 15% raise and status change
UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';

-- Remove terminated employees
DELETE FROM employees
WHERE status = 'Terminated';

-- Remove underpaid new hires with no department
DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;

-- Delete departments without employees assigned
DELETE FROM departments
WHERE dept_name NOT IN (
    SELECT DISTINCT department
    FROM employees
    WHERE department IS NOT NULL
);

-- Remove expired projects
DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;

-- Insert with NULLs, then fix or delete them
INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Null', 'Case', NULL, NULL, CURRENT_DATE, DEFAULT);

UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

DELETE FROM employees
WHERE salary IS NULL
   OR department IS NULL;

-- Insert employee only if not already existing
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
SELECT 'John', 'Doe', 'IT', 55000, CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1 FROM employees
    WHERE first_name = 'John' AND last_name = 'Doe'
);

-- Dynamic salary update depending on department budget
UPDATE employees e
SET salary = salary * (
    CASE
        WHEN (SELECT budget FROM departments d WHERE d.dept_name = e.department) > 100000
            THEN 1.10
        ELSE 1.05
    END
);

-- Bulk insert and testing updates
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES
('Emp1', 'Test', 'Sales', 40000, CURRENT_DATE),
('Emp2', 'Test', 'Sales', 42000, CURRENT_DATE),
('Emp3', 'Test', 'HR', 45000, CURRENT_DATE),
('Emp4', 'Test', 'IT', 47000, CURRENT_DATE),
('Emp5', 'Test', 'IT', 48000, CURRENT_DATE);

-- Give "Test" employees a 10% raise
UPDATE employees
SET salary = salary * 1.10
WHERE last_name = 'Test';

-- Create archive for inactive employees
CREATE TABLE IF NOT EXISTS employee_archive AS
SELECT * FROM employees WHERE 1=0;

INSERT INTO employee_archive
SELECT * FROM employees WHERE status = 'Inactive';

DELETE FROM employees WHERE status = 'Inactive';

-- Extend project deadline if dept has > 3 employees and budget > 50k
-- (need join through departments to match varchar department with dept_id)
UPDATE projects p
SET end_date = end_date + INTERVAL '30 days'
WHERE p.budget > 50000
  AND (
        SELECT COUNT(*)
        FROM employees e
        JOIN departments d ON e.department = d.dept_name
        WHERE d.dept_id = p.dept_id
      ) > 3;
