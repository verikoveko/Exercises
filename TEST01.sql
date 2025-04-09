
select * from courses;
select * from enrollments;
select * from professors;
select * from students;

--დავალება 1: სტუდენტების სახელები და გვარები
--დაწერეთ CTE, რომელიც დააბრუნებს ყველა სტუდენტის სრულ სახელს (first_name და last_name ერთად). mმერე გამოიყენეთ CTE, რომ დაბეჭდოთ სრული სახელები ანბანური თანმიმდევრობით.

WITH  full_name AS (
SELECT students.first_name ||' '|| students.last_name  AS student_full_name FROM students
ORDER BY students.first_name ASC)
SELECT student_full_name FROM full_name; 

--დავალება 2: A ნიშნები
--დაწერეთ CTE, რომელიც იპოვის ყველაფერს, სადაც სტუდენტმა მიიღო 'A' ნიშანი. გამოიყენეთ  CTE, რომ დააბრუნოთ სტუდენტის სახელი და კურსის დასახელება.

WITH  student_grade AS(
SELECT enrollments.student_id, enrollments.course_id 
FROM enrollments
WHERE grade = 'A'
)
 SELECT students.first_name, students.last_name, courses.course_name
 FROM student_grade
 JOIN students ON students.student_id=student_grade.student_id
 JOIN courses ON courses.course_id=student_grade.course_id
 ORDER BY students.first_name,students.last_name;

--დავალება 3: კურსების რაოდენობა
--დაწერეთ CTE, რომელიც დაითვლის რამდენი კურსი აქვს გავლილი თითოეულ სტუდენტს. შემდეგ, დააბრუნე სტუდენტები, რომლებსაც გავლილი აქვთ 2 ან მეტი კურსი.

WITH course_counts AS (
SELECT COUNT(course_id) AS course_count, student_id
FROM enrollments 
GROUP BY student_id)

SELECT students.first_name, students.last_name,course_count
FROM course_counts
JOIN students ON students.student_id=course_counts.student_id
WHERE course_count>=2
ORDER BY course_count DESC;

--დავალება 4: პროფესორების კურსების რაოდენობა
--დაწერეთ CTE, რომელიც დაითვლის თითოეული პროფესორის მიერ შეთავაზებული კურსების რაოდენობას. შემდეგ, დააბრუნეთ პროფესორის სახელი, გვარი, დეპარტამენტი და კურსების რაოდენობა.

WITH suggested_course_counts AS(
SELECT COUNT(course_id) AS course_count, professor_id
FROM courses 
GROUP BY professor_id)

SELECT professors.first_name,professors.last_name,professors.department, suggested_course_counts.course_count
FROM suggested_course_counts
JOIN professors ON professors.professor_id=suggested_course_counts.professor_id;

--დავალება 5: დეპარტამენტების სტატისტიკა
--დაწერეთ CTE, რომელიც დაითვლის თითოეულ დეპარტამენტში არსებული კურსების რაოდენობას და ჯამურ კრედიტებს. შემდეგ, დააბრუნეთ დეპარტამენტები კურსების რაოდენობის კლებადობით დალაგებული.

WITH department_cources AS (
SELECT department, COUNT(course_id) AS course_count, SUM(credits) AS sum_credits
from courses
GROUP BY department)

SELECT * FROM department_cources 
ORDER BY course_count DESC;
