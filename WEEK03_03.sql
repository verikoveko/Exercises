დავალება 1: ძირითადი Subquery-ები WHERE პირობაში

1. იპოვეთ ყველა თანამშრომელი, რომელიც იღებს საშუალო ხელფასზე
მეტს.

SELECT * FROM employees;

SELECT employees.first_name, salary
FROM employees
WHERE salary >(SELECT AVG(salary) FROM employees);

SELECT * FROM departments;


SELECT * FROM locations;

2.იპოვეთ ყველა თანამშრომელი, რომელიც მუშაობს 'New Jersey'-ში მდებარე
დეპარტამენტში.

SELECT first_name
FROM employees
WHERE department_id IN (SELECT department_id FROM departments
WHERE location_id IN ( SELECT location_id FROM locations
WHERE state = 'New Jersey'));


3.ჩამოთვალეთ იმ თანამშრომლების სახელები, რომლებიც მიმაგრებულნი
არიან ნებისმიერ პროექტზე, რომლის ბიუჯეტი აღემატება $50,000-ს.

SELECT * FROM projects;
SELECT * FROM employees;

 --way 1
SELECT employees.first_name, projects.budget
FROM employees
JOIN projects ON employees.department_id=projects.department_id
WHERE budget > '50000';

--way 2
SELECT first_name
FROM employees
WHERE department_id IN (SELECT department_id FROM projects
WHERE budget > '50000');

4.იპოვეთ ყველა თანამშრომელი, რომელიც დაქირავებულია მე-15
დეპარტამენტში ყველაზე ბოლოს დაქირავებული თანამშრომლის
შემდეგ.

SELECT first_name, department_id, hire_date
FROM employees
WHERE hire_date > ( SELECT MAX(hire_date) FROM employees WHERE department_id = 15);

დავალება 2: Subquery-ები FROM პირობაში

1. ჩამოთვალეთ დეპარტამენტები, რომლებსაც ჰყავთ დეპარტამენტებში
თანამშრომელთა საშუალო რაოდენობაზე მეტი თანამშრომელი.

SELECT * FROM employees;

SELECT department_id
FROM ( SELECT department_id, COUNT(*) AS employee_count FROM employees  GROUP BY department_id) AS dept_counts
WHERE employee_count > (  SELECT AVG(employee_count)  FROM (   SELECT COUNT(*) AS employee_count 
FROM employees GROUP BY department_id ) AS avg_counts);


2. იპოვეთ ყველაზე მაღალანაზღაურებადი 1 თანამშრომელი თითოეულ
დეპარტამენტში.
SELECT * FROM employees;


SELECT first_name
FROM (SELECT *, RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS high_salary from employees) employees
WHERE high_salary  <=1;

3. გამოთვალეთ პროექტებზე თითოეული თანამშრომლისთვის 
მიკუთვნებული საათების საშუალო რაოდენობა, შემდეგ ჩამოთვალეთ ის
თანამშრომლები, რომლებსაც მიკუთვნებული აქვთ ამ საშუალოზე მეტი
საათი.

-----

დავალება 3: Subquery-ები შედარების ოპერატორებით
1. იპოვეთ ყველა დეპარტამენტი, რომელსაც ჰყავს 'legal' დეპარტამენტზე
მეტი თანამშრომელი.
SELECT * FROM employees;

SELECT department_id, COUNT(*) AS count_department_id
FROM employees
GROUP BY department_id
HAVING COUNT(*) > (  SELECT COUNT(*) FROM employees
WHERE department_id = 16);

2. ჩამოთვალეთ თანამშრომლები, რომელთა ხელფასი უფრო მაღალია,
ვიდრე ნებისმიერი თანამშრომლის 'legal' დეპარტამენტში.

SELECT * FROM departments;
SELECT * FROM employees;

SELECT employee_id,salary,department_id
FROM employees
where salary > any (select salary from employees where department_id='16')

3. იპოვეთ თანამშრომლები, რომლებიც არ არიან მიმაგრებულნი არცერთ
პროექტზე.
SELECT * FROM employee_projects;

SELECT employee_id
FROM employees
WHERE employee_id NOT IN (
    SELECT employee_id FROM employee_projects WHERE employee_id IS NOT NULL);

	დავალება 4: Subquery-ები EXISTS და NOT EXISTS-ით
	
1. იპოვეთ ყველა დეპარტამენტი, რომელსაც ჰყავს მინიმუმ ერთი
თანამშრომელი $4000ზე მეტი ხელფასით.

SELECT department_id
FROM employees
WHERE EXISTS ( SELECT employee_id WHERE salary > '4000');
EXISTS

2. ჩამოთვალეთ იმ მენეჯერების სახელები, რომლებიც მართავენ
თანამშრომლებს, რომლებიც მიმაგრებულნი არიან $50 000-ზე მეტი
ბიუჯეტის მქონე პროექტებზე.

SELECT manager_id
FROM employees
WHERE EXISTS (SELECT project_id FROM projects WHERE employees.department_id=projects.department_id  AND BUDGET > '50000' );


3. იპოვეთ დეპარტამენტები, რომლებსაც არ აქვთ მიკუთვნებული არცერთი
პროექტი.

SELECT * FROM departments;
SELECT * FROM projects;
INSERT INTO departments VALUES ('17', 'HR', '3')



SELECT department_name
FROM departments d
WHERE NOT EXISTS (
    SELECT 1 
    FROM projects p
    WHERE p.department_id = d.department_id
);

