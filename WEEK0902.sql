-- მომხმარებლების ცხრილი
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    registration_date DATE NOT NULL,
    subscription_type VARCHAR(20) CHECK (subscription_type IN ('free', 'basic', 'premium'))
);

-- პროდუქტების ცხრილი
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- შეკვეთების ცხრილი
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    order_date TIMESTAMP NOT NULL,
    status VARCHAR(20) CHECK (status IN ('pending', 'processed', 'shipped', 'delivered', 'cancelled')),
    total_amount DECIMAL(10,2) NOT NULL
);

-- შეკვეთის დეტალების ცხრილი
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id),
    product_id INTEGER REFERENCES products(product_id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL
);

-- სასაწყობე მოძრაობების ცხრილი
CREATE TABLE warehouse_movements (
    movement_id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(product_id),
    movement_type VARCHAR(20) CHECK (movement_type IN ('IN', 'OUT')),
    quantity INTEGER NOT NULL,
    movement_date TIMESTAMP NOT NULL,
    notes TEXT
);
მონაცემების სატესტო ჩანაწერები
sql-- მომხმარებლების მონაცემები
INSERT INTO users (email, full_name, registration_date, subscription_type) VALUES
('giorgi.k@example.com', 'გიორგი კიკნაძე', '2023-01-15', 'premium'),
('nino.b@example.com', 'ნინო ბერიძე', '2023-02-20', 'basic'),
('davit.m@example.com', 'დავით მაისურაძე', '2023-03-10', 'free'),
('ana.g@example.com', 'ანა გვინჩიძე', '2023-04-05', 'premium'),
('luka.t@example.com', 'ლუკა თოდუა', '2023-05-01', 'basic');

-- პროდუქტების მონაცემები
INSERT INTO products (product_name, category, price, stock_quantity) VALUES
('ლეპტოპი Dell XPS', 'ელექტრონიკა', 2500.00, 15),
('სმარტფონი iPhone 13', 'ელექტრონიკა', 1800.00, 25),
('წიგნი SQL', 'წიგნები', 45.00, 100),
('კლავიატურა Logitech', 'აქსესუარები', 120.00, 50),
('მონიტორი Samsung', 'ელექტრონიკა', 450.00, 30);

-- შეკვეთების მონაცემები
INSERT INTO orders (user_id, order_date, status, total_amount) VALUES
(1, '2023-06-15 10:30:00', 'delivered', 2620.00),
(2, '2023-06-16 14:20:00', 'shipped', 1920.00),
(3, '2023-06-17 09:15:00', 'processed', 165.00),
(1, '2023-06-18 16:45:00', 'pending', 450.00),
(4, '2023-06-19 11:00:00', 'delivered', 2500.00);

-- შეკვეთის დეტალების მონაცემები
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 2500.00),
(1, 4, 1, 120.00),
(2, 2, 1, 1800.00),
(2, 4, 1, 120.00),
(3, 3, 1, 45.00),
(3, 4, 1, 120.00),
(4, 5, 1, 450.00),
(5, 1, 1, 2500.00);

-- სასაწყობე მონაცემები
INSERT INTO warehouse_movements (product_id, movement_type, quantity, movement_date, notes) VALUES
(1, 'IN', 50, '2023-06-01 08:00:00', 'ახალი პარტია'),
(1, 'OUT', 5, '2023-06-15 10:30:00', 'გაყიდვა'),
(2, 'IN', 30, '2023-06-02 09:00:00', 'იმპორტი'),
(2, 'OUT', 3, '2023-06-16 14:20:00', 'გაყიდვა'),
(3, 'IN', 100, '2023-06-03 10:00:00', 'ახალი ტირაჟი');
დავალებები
დავალება 1: Views-ის შექმნა
შექმენით View სახელწოდებით customer_order_summary, რომელიც აჩვენებს:

მომხმარებლის სრულ სახელს
ელ.ფოსტას
შეკვეთების რაოდენობას
ჯამურ დახარჯულ თანხას
უკანასკნელი შეკვეთის თარიღს

მოთხოვნები:

View უნდა აჩვენებდეს მხოლოდ იმ მომხმარებლებს, ვისაც აქვს მინიმუმ ერთი შეკვეთა
მონაცემები უნდა იყოს დალაგებული ჯამური დახარჯული თანხის კლებადობით

CREATE OR REPLACE VIEW customer_orders AS
SELECT
	full_name,
	email, 
	COUNT(orders.order_id) AS quantity,
	COALESCE(SUM(orders.total_amount), 0) as total_amount,
	MAX(orders.order_date) AS order_date
FROM users
	INNER JOIN orders ON orders.user_id = users.user_id
GROUP BY users.full_name, users.email, users.user_id
ORDER BY total_amount DESC;

SELECT *
FROM customer_orders
WHERE quantity >= 2; 


დავალება 2: კომპლექსური View
შექმენით View სახელწოდებით product_sales_analytics, რომელიც აჩვენებს:

პროდუქტის დასახელებას
კატეგორიას
-გაყიდული რაოდენობა (ჯამური)
-საშუალო გაყიდვის ფასი
მთლიანი შემოსავალი
მარაგის მიმდინარე რაოდენობა
შეკვეთების რაოდენობა, სადაც ეს პროდუქტი მონაწილეობს

მოთხოვნები:

გამოიყენეთ JOIN-ები products, order_items და orders ცხრილებს შორის
დაითვალეთ მხოლოდ წარმატებული შეკვეთები (სტატუსი: 'processed', 'shipped', 'delivered')

SELECT * FROM products;
SELECT * FROM order_items;
SELECT * FROM  orders;


drop view if exists product_sales_analytics;

CREATE OR REPLACE VIEW product_sales_analytics AS
SELECT products.product_name, 
       products.category,
	   COUNT(orders.order_id) AS sum_sale_quantity,
	   COALESCE(avg(order_items.unit_price), 0) as avg_unit_price,
	   COALESCE(SUM(order_items.unit_price), 0) as order_total_amount,
	   products.stock_quantity,	 
	   orders.status  
	   from products
	   join order_items on products.product_id=order_items.product_id
	   join orders on order_items.order_id=orders.order_id
	   group by products.product_name, products.category,   products.product_id, order_items.order_id,orders.order_id;

	SELECT *
FROM product_sales_analytics
WHERE status = 'shipped';

