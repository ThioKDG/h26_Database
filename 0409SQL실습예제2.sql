-- 문제 24
-- 1 employee와 departments 테이블에 저장된 튜플의 개수를 출력하시오
SELECT (SELECT COUNT(*) FROM employees) AS "사원수",
       (SELECT COUNT(*) FROM departments) AS "부서수"
from dual;

-- 2 employees 테이블에 대한 employee_id, job_id, hire_date 를 출력하시오
select employee_id, job_id, hire_date
from employees;

-- 3 employees 테이블에서 salary가 12,000 이상인 last_name과 department_id를 last_name에 대하여 오름차순으로 출력하시오.
select last_name, department_id
from employees
where salary >= 12000
order by last_name asc;

-- 4 부서번호가 20 혹은 50인 직원의 last_name department_id를 last_name에 대하여 오름차순 출력
select last_name, department_id
from employees
where department_id = 20 or department_id = 50
order by last_name asc;

-- 5 last_name의 세 번째에 a가 들어가는 직원의 last_name을 출력하시오
select last_name
from employees
where last_name like '__a%';

-- 6같은 일을 하는 사람의 수를 세어 출력하시오
select job_id, count(*)
from employees
group by job_id;

-- 7 급여의 최대값과 최소값의 차이를 구하시오
select max(salary) - min(salary)
from employees;

-- 8 toronto 에서 일하는 직원의 last_name, job, department_id, department_name을 출력
SELECT e.last_name, e.job_id, e.department_id, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN locations l ON d.location_id = l.location_id
WHERE l.city = 'Toronto';

-- 부속질의
-- 1 전체 직원 평균 급여보다 많이 받는 지원의 last_name과 salary를 출력하시오 
select last_name, salary
from employees
where salary > (select avg(salary) from employees);

-- 2 De Haan과 같은 job_id를 가진 직원의 last_name과 job_id를 출력하시오
select last_name, job_id
from employees
where job_id = (select job_id
                  from employees
                 where last_name='De Haan');
                 
                 
-- 3 부셔별 최고 급여를 받는 직원의 last_name, department_id를 출력하시오
SELECT last_name, department_id, salary
FROM employees e1
WHERE salary = (SELECT MAX(salary)
                FROM employees e2
                WHERE e1.department_id = e2.department_id);

-- 4 it부서 직원의 평균 급여보다 많이 받는 직원의 last_name과 salary를 출력
select last_name, salary
from employees
WHERE salary > (SELECT AVG(salary) FROM employees WHERE department_id = 60);

-- 5 직무 이력이 있는 직원의 last_name과 현재 job_id를 출력하시오
SELECT last_name, job_id
FROM employees
WHERE employee_id IN (SELECT employee_id FROM job_history);

-- 6 직무 이력이 없는 직원의 last_name 과 employee_id를 출력
SELECT last_name, employee_id
FROM employees
WHERE employee_id NOT IN (SELECT employee_id FROM job_history);

-- 7 급여가 자신이 속한 부서 평균보다 높은 직원의 이름, 급여, 부서번호를 출력 
SELECT e1.first_name || ' ' || e1.last_name AS name, e1.salary, e1.department_id
FROM employees e1
WHERE e1.salary > (SELECT AVG(e2.salary)
                   FROM employees e2
                   WHERE e2.department_id = e1.department_id);
                   
-- 8 Kochhar(101)를 관리자로 두는 직원의 이름과 급여를 출력하시오.
SELECT first_name || ' ' || last_name AS name, salary
FROM employees
WHERE manager_id = (SELECT employee_id 
                    FROM employees 
                    WHERE last_name = 'Kochhar' AND employee_id = 101);
                    
-- 9 급여 최상위 3명의 last_name과 salary를 출력하시오
SELECT last_name, salary
FROM (SELECT last_name, salary FROM employees ORDER BY salary DESC)
WHERE ROWNUM <= 3;

-- 10 FI_ACCOUNT 직원 중 급여가 FI_ACCOUNT 평균보다 높은 직원을 출력하시오.
SELECT *
FROM employees
WHERE job_id = 'FI_ACCOUNT'
  AND salary > (SELECT AVG(salary) 
                FROM employees 
                WHERE job_id = 'FI_ACCOUNT');
                