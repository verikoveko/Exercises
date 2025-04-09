-- პროდუქტების ცხრილი
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL CHECK (price > 0),
    stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    reorder_level INTEGER NOT NULL DEFAULT 5,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- შეკვეთების ცხრილი
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    customer_id INTEGER,
    total_amount NUMERIC(12,2),
    status VARCHAR(20) DEFAULT 'pending'
);

-- შეკვეთების დეტალების ცხრილი
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id),
    product_id INTEGER REFERENCES products(product_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL
);

-- მარაგის გაფრთხილების ცხრილი
CREATE TABLE inventory_alerts (
    alert_id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(product_id),
    alert_type VARCHAR(50),
    message TEXT,
    alert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_resolved BOOLEAN DEFAULT FALSE
);

-- ფასის ცვლილების აუდიტის ცხრილი
CREATE TABLE price_audit (
    audit_id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(product_id),
    old_price NUMERIC(10,2),
    new_price NUMERIC(10,2),
    change_percent NUMERIC(5,2),
    changed_by VARCHAR(50),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 1. მარაგის განახლების ტრიგერის ფუნქცია შეკვეთისთვის
CREATE OR REPLACE FUNCTION update_inventory_after_order()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE products
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_order_insert
AFTER INSERT ON products
FOR EACH ROW
EXECUTE FUNCTION update_inventory_after_order();


INSERT INTO products(name, description, price,stock_quantity )
VALUES ('hp','leptop', 500,10),
       ('samsung','phone', 200,7);


SELECT * FROM products;


INSERT INTO order_items (product_id, quantity,unit_price )
VALUES ('1', '4',2000),
       ('3', '15',7000),
       ('2', '3',4000);
	   
SELECT * FROM order_items;

SELECT * FROM products;


	   
SELECT * FROM order_items;

-- მარაგის განახლების ტრიგერის ფუნქციის სრული ვერსი


CREATE OR REPLACE FUNCTION update_inventory_after_order()
RETURNS TRIGGER AS $$
BEGIN
    -- შევამციროთ მარაგი შეკვეთის რაოდენობით
    UPDATE products
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
    
    -- განვაახლოთ შეკვეთის ჯამური თანხა
    UPDATE orders
    SET total_amount = COALESCE(total_amount, 0) + (NEW.quantity * NEW.unit_price)
    WHERE order_id = NEW.order_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM order_items;


-- 2. მარაგის გაფრთხილების ტრიგერის ფუნქცია
CREATE OR REPLACE FUNCTION check_inventory_levels()
RETURNS TRIGGER AS $$
BEGIN
    
    IF NEW.stock_quantity < 10 THEN
        INSERT INTO inventory_alerts (product_id, alert_message)
        VALUES (NEW.product_id, 'Inventory level is below threshold!');
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- მარაგის გაფრთხილების ტრიგერი
CREATE TRIGGER inventory_alert_trigger
AFTER UPDATE OF stock_quantity ON products
FOR EACH ROW
EXECUTE FUNCTION check_inventory_levels();

SELECT * FROM order_items;


    INSERT INTO inventory_alerts (product_id, message)
        VALUES (1, '11');

		SELECT * FROM inventory_alerts;

	--ტრიგერი, რომელიც აღრიცხავს ფასის ცვლილებას price_audit ცხრილში	

	-- 3. ფასის აუდიტის ტრიგერის ფუნქცია


	CREATE TABLE price_audit_log (
    id SERIAL PRIMARY KEY,
    product_id INT NOT NULL,
    old_price NUMERIC(10, 2),
    new_price NUMERIC(10, 2),
    change_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

	CREATE OR REPLACE FUNCTION log_price_change()
RETURNS TRIGGER AS $$
BEGIN
    
        INSERT INTO price_audit_log(product_id, old_price,new_price)
        VALUES (NEW.product_id,old.old_price,new.new_price);
    

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER price_change_audit
AFTER UPDATE OF price ON products
FOR EACH ROW
EXECUTE FUNCTION log_price_change();


SELECT * FROM products;


 INSERT INTO price_audit_log(product_id, old_price,new_price)
        VALUES (3,200,1000);
    
SELECT * FROM price_audit_log;


---ტრიგერი, რომელიც უზრუნველყოფს, რომ ფასი არ შემცირდეს 50%-ზე მეტით


-- 4. ფასის ვალიდაციის ტრიგერის ფუნქცია

CREATE OR REPLACE FUNCTION validate_price_decrease()
RETURNS TRIGGER AS $$
BEGIN
     IF new.new_price < old.old_price * 0.5 THEN
        RAISE EXCEPTION 'Price decrease greater than 50%% is not allowed. Current: %, New: %', 
                          OLD.price, NEW.price;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_price_change
BEFORE UPDATE OF price ON products
FOR EACH ROW
EXECUTE FUNCTION validate_price_decrease();


 INSERT INTO price_audit_log(product_id, old_price,new_price)
        VALUES (3,200,70);

		SELECT * FROM price_audit_log;
