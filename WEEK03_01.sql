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


SELECT employees.first_name, departments.department_name
FROM employees
join departments on employees.department_id=departments.department_id
WHERE location_id =  (select location_id from locations where state = 'New Jersey' ) ;


3.ჩამოთვალეთ იმ თანამშრომლების სახელები, რომლებიც მიმაგრებულნი
არიან ნებისმიერ პროექტზე, რომლის ბიუჯეტი აღემატება $50,000-ს.

SELECT * FROM projects;

SELECT employees.first_name, projects.budget
FROM employees
JOIN projects ON employees.department_id=projects.department_id
WHERE budget > '50000';


4.იპოვეთ ყველა თანამშრომელი, რომელიც დაქირავებულია მე-15
დეპარტამენტში ყველაზე ბოლოს დაქირავებული თანამშრომლის
შემდეგ.

SELECT first_name, department_id, hire_date
FROM employees
WHERE hire_date > (
    SELECT MAX(hire_date)
    FROM employees
    WHERE department_id = 15
);