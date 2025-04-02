 INSERT INTO customers VALUES
 (1,'John Smith','john@axample.com', '2020-01-15'),
 (2,'Mary Johnson','mary@axample.com','2020-03-20'),
 (3,'Robert Brown','robert@axample.com', '2020-05-10'),
 (4,'atricia Devis','patricia@axample.com', '2021-02-05'),
 (5,'Michael Miller','michael@axample.com', '2021-04-18');

    SELECT * FROM  customers;
    
 INSERT INTO orders VALUES
 (101, 1,'2022-01-10', 150.50),
 (102, 2,'2022-01-15', 200.75),
 (103, 1,'2022-02-20', 75.25),
 (104, 3,'2022-03-05', 300.00),
 (105, 2,'2022-03-10', 125.50),
 (106, 4,'2022-04-15', 85.75),
 (107, 1,'2022-05-20', 220.50),
 (108, 5,'2022-06-10', 175.25),
 (109, 3,'2022-07-05', 95.50),
 (110, 2,'2022-08-15', 330.75);
 
     SELECT * FROM  orders;
  
  INSERT INTO order_items VALUES
  (1001, 101, 'Leptop', 1, 120.50),
  (1002, 101, 'Mouse', 1, 30.50),
  (1003, 102, 'Monitor', 1, 200.50),
  (1004, 103, 'Keyboard', 1, 25.50),
  (1005, 104, 'Printer', 1, 100.50),
  (1006, 104, 'Ink Cartridge', 2, 30.50),
  (1007, 105, 'External Hard Drive', 1, 15.50),
  (1008, 106, 'UsbCabel', 3, 170.50),
  (1009, 106, 'Mousepad', 2, 45.50),
  (1010, 107, 'Wireless Headphones', 1, 200.50),
  (1011, 108, 'Tablet', 1, 100.00),
  (1012, 109, 'Phone Charger', 3, 200.00),
  (1013, 109, 'Screen Protector', 2, 300.50),
  (1014, 110, 'Gaming Concole', 1, 125.50),
  (1015, 110, 'Game Controler', 1, 75.50);
  
     SELECT * FROM  order_items;
     
  INSERT INTO employees VALUES
  (1, 'James Wilson', NULL, '2015-01-10', 'Executive', 120000.00),
  (2, 'Jennifer Thomas', 1, '2015-03-15', 'HR', 85000.00),
  (3, 'Devid Martinez', 1, '2016-05-20', 'Finance', 90000.00),
  (4, 'Susan Anderson', 1, '2016-08-10', 'IT', 95000.00),
  (5, 'Rochard Teylor', 2, '2017-02-15', 'HR', 65000.00),
  (6, 'Linda Garcia', 2, '2017-06-20', 'HR', 67000.00),
  (7, 'Carles Rodriguez', 3, '2018-01-10', 'Finance', 72000.00),
  (8, 'Elizabeth Lewes', 3, '2018-04-15', 'Finance', 70000.00),
  (9, 'Joseph Lee', 4, '2019-03-20', 'IT', 75000.00),
  (10, 'Margaret Walker', 4, '2019-07-10', 'IT', 80000.00),
  (11, 'Thomas Hall', 5, '2020-01-15', 'HR', 55000.00),
  (12, 'Nancy Allen', 7, '2020-05-20', 'Finance', 60000.00),
  (13, 'Daniel Young', 9, '2021-02-10', 'IT', 62000.00),
  (14, 'Lisa King', 9, '2021-06-15', 'IT', 63000.00),
  (15, 'Paul Wright', 10, '2022-01-20', 'IT', 58000.00);  

 
     SELECT * FROM  Employees;
     
     ---1. მარტივი CTE
     
     WITH top_customers AS (
       SELECT * FROM order_items WHERE quantity > 2)
       
       SELECT * from top_customers;
       
   -- 2. აგრეგაცია CTE-სთან
   
       WITH sum_order_amount AS (
           SELECT customer_id, SUM(total_amount) as sum_total_amount from orders group by customer_id)
           
       SELECT * FROM  sum_order_amount WHERE sum_total_amount >300;
       
    ---3. JOIN CTE - სთან
    
    WITH old_customers AS (
       SELECT * FROM customers WHERE join_date < '2021-01-01')
       
       SELECT order_items.product_name,order_items.order_id,orders.customer_id
       FROM orders
       JOIN  customers ON customers.customer_id=orders.customer_id
       JOIN  old_customers ON old_customers.customer_id=orders.customer_id
       JOIN  order_items ON order_items.order_id=orders.order_id;
       
       
       --4. მრავლობითი CTE 
       
       WITH customer_order AS (
     SELECT customer_id, SUM(total_amount) AS sum_total_amount
     FROM orders GROUP BY customer_id),
      
      
      orderSales AS (
      SELECT customer_id, AVG(total_amount) AS avg_total_amount
    FROM orders
    GROUP BY customer_id)
    
     SELECT customer_id, sum_total_amount
    FROM customer_order
    WHERE sum_total_amount > (SELECT AVG(avg_total_amount) FROM orderSales);

    --5. რეკურსიული CTE - ორგანიზაციული სტრუქტურა
    WITH RECURSIVE EmployeeHierarchy AS (
    SELECT employee_id, employee_name, manager_id, 1 AS Level
    FROM Employees
    WHERE employee_id = 1

    UNION ALL

    SELECT e.employee_id, e.employee_name, e.manager_id, eh.Level + 1
    FROM Employees e
    INNER JOIN EmployeeHierarchy eh ON e.manager_id = eh.employee_id
    )
    SELECT employee_id, employee_name, Level
   FROM EmployeeHierarchy;


  --6. Window Functions CTE-სთან

    WITH customer_spending AS (
    SELECT  c.customer_id, c.customer_name, SUM(o.total_amount) AS total_spent,
    RANK() OVER (ORDER BY SUM(o.total_amount) DESC) AS spending_rank
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_name)

   SELECT customer_id, customer_name, total_spent, spending_rank
   FROM customer_spending
   WHERE spending_rank <= 3;



