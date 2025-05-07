გაქვთ "საბანკო სისტემის" ბაზა, რომლის Schema უნდა შქენათ:
ცხრილი customers (კლიენტები):
CREATE TABLE customers(
	customer_id SERIAL PRIMARY KEY,
	first_name VARCHAR(100) NOT NULL,
	last_name VARCHAR(100) NOT NULL,
	email VARCHAR(255) UNIQUE NOT NULL,
	phone VARCHAR(20),
	registration_date TIMESTAMP DEFAULT NOW()
);
ცხრილი accounts (ანგარიშები):
CREATE TABLE accounts (
	account_id SERIAL PRIMARY KEY,
	customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
	account_type VARCHAR(50),
	balance DECIMAL(15,2) DEFAULT 0.00 NOT NULL,
	opening_date DATE NOT NULL,
	status VARCHAR(20) CHECK (status IN ('active', 'suspended', 'pending'))
);
ცხრილი transactions (ტრანზაქციები):
CREATE TABLE transactions (
	transaction_id SERIAL PRIMARY KEY,
	account_id INTEGER NOT NULL REFERENCES accounts(account_id),
	transaction_type VARCHAR(50),
	amount DECIMAL(12,2) NOT NULL,
	description TEXT,
	transaction_date TIMESTAMP DEFAULT NOW(),
	status VARCHAR(20) DEFAULT ('completed','pending')
);

SELECT * FROM customers;
SELECT * FROM transactions;
SELECT * FROM accounts;
INSERT INTO customers (first_name, last_name, email, phone, registration_date) VALUES
('Giorgi', 'Shengelia', 'giorgi.shengelia@example.com', '+995555123456', '2023-01-15 10:30:00'),
('Mariam', 'Kapanadze', 'mariam.kapanadze@example.com', '+995599987654', '2023-03-22 14:20:00'),
('Nino', 'Gogoladze', 'nino.gogoladze@example.com', '+995577456789', '2023-06-10 09:15:00'),
('Luka', 'Tsereteli', 'luka.tsereteli@example.com', '+995593321654', '2024-02-01 11:45:00'),
('Ana', 'Japaridze', 'ana.japaridze@example.com', '+995591234567', '2024-05-01 16:00:00');

INSERT INTO accounts (customer_id, account_type, balance, opening_date, status) VALUES
(1, 'Savings', 1500.75, '2023-02-01', 'active'),
(1, 'Checking', 320.50, '2023-02-10', 'active'),
(2, 'Savings', 5000.00, '2023-04-01', 'active'),
(2, 'Investment', 10000.25, '2023-05-15', 'active'),
(3, 'Checking', 750.30, '2023-07-01', 'active'),
(4, 'Savings', 2000.00, '2024-02-15', 'active'),
(4, 'Checking', 100.00, '2024-03-01', 'suspended'),
(5, 'Savings', 300.45, '2024-05-10', 'active');

INSERT INTO transactions (account_id, transaction_type, amount, description, transaction_date, status) VALUES
(1, 'Deposit', 1000.00, 'Initial deposit', '2023-02-02 09:00:00', 'completed'),
(1, 'Withdrawal', 200.25, 'ATM withdrawal', '2023-03-15 12:30:00', 'completed'),
(2, 'Transfer', 150.00, 'Transfer to savings', '2023-03-01 14:00:00', 'completed'),
(3, 'Deposit', 3000.00, 'Salary deposit', '2023-04-02 10:00:00', 'completed'),
(3, 'Withdrawal', 500.00, 'Online purchase', '2023-04-20 16:45:00', 'completed'),
(4, 'Deposit', 8000.00, 'Investment fund', '2023-05-16 11:20:00', 'completed'),
(5, 'Deposit', 500.00, 'Cash deposit', '2023-07-02 08:30:00', 'completed'),
(6, 'Deposit', 1500.00, 'Bonus deposit', '2024-02-16 13:15:00', 'completed'),
(7, 'Withdrawal', 50.00, 'Pending withdrawal', '2024-03-10 15:00:00', 'pending'),
(8, 'Deposit', 200.00, 'Gift deposit', '2024-05-11 09:45:00', 'completed');


SELECT * FROM customers;
SELECT * FROM transactions;
SELECT * FROM accounts;

მოძებნეთ ყველა კლიენტი და მათი ანგარიშები:

თითოეული კლიენტის სახელი, გვარი, email
მათი ანგარიშების რაოდენობა
ანგარიშების სტატუსი
ჯამური ბალანსი

SELECT customers.first_name, customers.last_name,customers.email,count(account_id) AS count_account_id,SUM(balance) AS sum_balance,accounts.status
FROM customers
JOIN accounts ON customers.customer_id=accounts.customer_id
GROUP BY customers.customer_id,accounts.status;

LEFT JOIN გამოყენებით, იპოვეთ:

ყველა კლიენტი, მათი ანგარიშების რაოდენობით (იმ კლიენტების ჩათვლით, რომლებსაც არ აქვთ ანგარიშები)
კლიენტებს, რომლებსაც არ აქვთ "active" ანგარიშები

SELECT customers.first_name,count(account_id) AS count_account_id, accounts.status
FROM customers 
LEFT JOIN accounts ON customers.customer_id=accounts.customer_id
WHERE STATUS NOT IN ('active')
GROUP BY customers.customer_id,accounts.status;

INNER JOIN გამოყენებით:

მოძებნეთ კლიენტები, რომლებსაც აქვთ ტრანზაქციები უკანასკნელი 30 დღის განმავლობაში

SELECT customers.first_name, transactions.transaction_date
FROM customers 
JOIN accounts ON customers.customer_id=accounts.customer_id
JOIN transactions ON accounts.account_id=transactions.account_id
WHERE transactions.status = 'completed' and transaction_date BETWEEN (
    SELECT MAX(transaction_date) FROM transactions
) - INTERVAL '30 days' AND (
    SELECT MAX(transaction_date) FROM transactions
);




დაალაგეთ კლიენტები:

იმ კლიენტების სია, რომლებიც რეგისტრირებულები არიან უკანასკნელი 6 თვის განმავლობაში, დალაგებული რეგისტრაციის თარიღით (კლებადობით)
კლიენტების სია მათი ჯამური ბალანსით, დალაგებული ბალანსით ზრდადი


SELECT customers.first_name,registration_date,SUM(balance) AS sum_balance
FROM customers
JOIN accounts ON customers.customer_id=accounts.customer_id
WHERE registration_date BETWEEN (SELECT MAX(registration_date) FROM customers) - INTERVAL '6 month' AND ( SELECT MAX(registration_date) FROM customers)
GROUP BY customers.customer_id
ORDER BY registration_date DESC, sum_balance ASC;


ORDER BY:

ანგარიშები, რომლებიც დალაგებულია ტიპის მიხედვით (checking, savings, business), შემდეგ ბალანსის მიხედვით (კლებადობით)
ტრანზაქციები, დალაგებული თარიღის მიხედვით (უახლესისგან უძველესისკენ) და თანხის მიხედვით (დიდიდან პატარისკენ)





SELECT accounts.account_id,
	   accounts.account_type, 
	   SUM(balance) AS sum_balance,
	   MIN(accounts.opening_date) AS opening_date,
	   SUM(amount) AS sum_amount
FROM accounts
JOIN transactions ON accounts.account_id=transactions.account_id
GROUP BY accounts.account_id, accounts.account_type
ORDER by account_type , sum_balance DESC, opening_date ASC, sum_amount DESC;
 

ცხრილი transactions (ტრანზაქციები):
კლიენტების გაანალიზება:

რამდენი ანაგარიშია თითოეული ტიპის (checking, savings, business)?
რა არის საშუალო ბალანსი ანგარიშების ტიპის მიხედვით?
თითოეული კლიენტისთვის დათვალეთ მათი ანგარიშების რაოდენობა, მოიდენითოეული ტიპისთვის გამოთვალეთ ჯამური ბალანსი
--1
SELECT account_type,COUNT(account_id) AS count_account_id
FROM accounts
GROUP BY account_type;
--2
SELECT account_type,AVG(balance) AS avg_balance
FROM accounts
GROUP BY account_type;
--3

SELECT customers.customer_id,count(account_id), SUM(balance) AS sum_balance
FROM customers
JOIN accounts ON customers.customer_id=accounts.customer_id
GROUP BY customers.customer_id;


შექმენით ფუნქციები:

get_account_balance(account_id INTEGER):

დააბრუნოს ანგარიშის მიმდინარე ბალანსი
თუ ანგარიში არ არსებობს, დააბრუნოს NULL


calculate_total_balance_by_type(account_type VARCHAR):

დათვალოს და დააბრუნოს გამოცემული ტიპის ყველა ანგარიშის ჯამური ბალანსი


get_customers_with_high_balance(threshold DECIMAL):

დააბრუნოს იმ კლიენტების სია, რომლების ჯამური ბალანსი აღემატება threshold-ს
დააბრუნოს TABLE ტიპით (customer_id, full_name, total_balance)

