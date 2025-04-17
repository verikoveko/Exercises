-- Riders table
CREATE TABLE riders (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    phone VARCHAR(20)
);

-- Drivers table
CREATE TABLE drivers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    license_number VARCHAR(50) UNIQUE
);

-- Trips table
CREATE TABLE trips (
    id SERIAL PRIMARY KEY,
    rider_id INT REFERENCES riders(id),
    driver_id INT REFERENCES drivers(id),
    pickup_location VARCHAR(255),
    dropoff_location VARCHAR(255),
    pickup_time TIMESTAMP,
    dropoff_time TIMESTAMP,
    fare NUMERIC(10, 2)
);

-- Indexes
CREATE INDEX idx_trips_driver_id ON trips(driver_id);
CREATE INDEX idx_trips_rider_id ON trips(rider_id);
CREATE INDEX idx_trips_pickup_time ON trips(pickup_time);


-- Insert riders
INSERT INTO riders (name, phone) VALUES
('Alice', '555-0001'),
('Bob', '555-0002'),
('Charlie', '555-0003');

-- Insert drivers
INSERT INTO drivers (name, license_number) VALUES
('David', 'ABC123'),
('Eva', 'XYZ789');

-- Insert trips
INSERT INTO trips (rider_id, driver_id, pickup_location, dropoff_location, pickup_time, dropoff_time, fare) VALUES
(1, 1, 'A St', 'B Ave', '2024-04-17 08:00', '2024-04-17 08:30', 12.50),
(2, 2, 'C Blvd', 'D Rd', '2024-04-17 09:00', '2024-04-17 09:20', 9.75),
(3, 1, 'E Ln', 'F Ct', '2024-04-17 10:00', '2024-04-17 10:25', 14.20),
(1, 2, 'G Way', 'H Dr', '2024-04-17 11:00', '2024-04-17 11:15', 7.00),
(2, 1, 'I Pkwy', 'J Blvd', '2024-04-17 12:00', '2024-04-17 12:45', 15.60);

INSERT INTO trips (rider_id, driver_id, pickup_location, dropoff_location, pickup_time, dropoff_time, fare)
SELECT
    (SELECT id FROM riders ORDER BY random() LIMIT 1),
    (SELECT id FROM drivers ORDER BY random() LIMIT 1),
    'Street ' || chr(65 + (random()*25)::int),
    'Avenue ' || chr(65 + (random()*25)::int),
    pickup_time,
    pickup_time + ((random() * 50 + 10) * interval '1 minute'),
    round((random()*20 + 5)::numeric, 2)
FROM (
    SELECT
        timestamp '2022-01-01 00:00:00' +
        (random() * (timestamp '2024-12-31 23:59:59' - timestamp '2022-01-01 00:00:00')) AS pickup_time
    FROM generate_series(1, 1000)
) AS t;

EXPLAIN ANALYZE
SELECT d.name AS driver_name,
       COUNT(t.id) AS trip_count,
       AVG(t.fare) AS avg_fare
FROM drivers d
JOIN trips t ON d.id = t.driver_id
GROUP BY d.name
ORDER BY trip_count DESC;


---იპოვეთ ტოპ 3 საუკეთესო მძღოლი, რომლებმაც გამოიმუშავეს ყველაზე მეტი ჯამური თანხა 2024 წლის მარტში.

SELECT * FROM riders;

SELECT * FROM drivers;
SELECT * FROM trips;

EXPLAIN ANALYZE
SELECT driver_id, drivers. name, SUM(trips.fare)
FROM trips
JOIN drivers ON drivers.id=trips.driver_id
WHERE pickup_time BETWEEN '2024-04-01' AND '2024-04-30'
GROUP BY driver_id , drivers. name
LIMIT 3;
