-- 문제 1
-- 고객별 주문 정보 그룹화함 
CREATE VIEW v_cust_order_summary AS
SELECT c.name AS 고객이름, SUM(o.saleprice) AS 총주문금액, COUNT(o.orderid) AS 주문횟수
FROM Customer c, Orders o
WHERE c.custid = o.custid
GROUP BY c.name;

-- 문제 2
-- 도서별 판매 내역 집계함 
CREATE VIEW v_book_sales AS
SELECT b.bookname AS 도서명, b.publisher AS 출판사, COUNT(o.orderid) AS 판매된총수량, SUM(o.saleprice) AS 총판매금액
FROM Book b, Orders o
WHERE b.bookid = o.bookid
GROUP BY b.bookname, b.publisher;

-- 문제 3
-- 최근 주문일 추출 위해 MAX 사용함 
CREATE VIEW v_cust_last_order AS
SELECT c.name, c.address, MAX(o.orderdate) AS 최근주문일
FROM Customer c, Orders o
WHERE c.custid = o.custid
GROUP BY c.name, c.address;

-- 문제 4
-- 정가(price)보다 판매가(saleprice)가 낮은 경우 필터링함 
CREATE VIEW v_discounted_orders AS
SELECT o.orderid AS 주문번호, c.name AS 고객이름, b.bookname AS 도서명, b.price AS 정가, o.saleprice AS 판매가, (b.price - o.saleprice) AS 할인금액
FROM Customer c, Book b, Orders o
WHERE c.custid = o.custid AND b.bookid = o.bookid AND b.price > o.saleprice;

-- 문제 5
-- 출판사별 통계 계산함 
CREATE VIEW V_publisher_stats AS
SELECT publisher AS 출판사, AVG(price) AS 평균판매가, MAX(price) AS 최고판매가
FROM Book
GROUP BY publisher;

-- 문제 6
-- 그룹화 후 합계 조건 위해 HAVING 사용함 
CREATE VIEW v_vip_customer AS
SELECT c.name, SUM(o.saleprice) AS 총주문금액
FROM Customer c, Orders o
WHERE c.custid = o.custid
GROUP BY c.name
HAVING SUM(o.saleprice) >= 30000;

-- 문제 7
-- 2024년 데이터만 필터링함 
CREATE VIEW v_orders_2024 AS
SELECT c.name AS 고객이름, b.bookname AS 도서명, o.saleprice AS 판매가격, o.orderdate AS 주문일자
FROM Customer c, Book b, Orders o
WHERE c.custid = o.custid AND b.bookid = o.bookid
AND o.orderdate BETWEEN '2024-01-01' AND '2024-12-31';

-- 문제 8
-- 주문 테이블에 없는 도서 찾기 위해 서브쿼리 사용함 
CREATE VIEW v_unsold_books AS
SELECT bookname, publisher, price
FROM Book
WHERE bookid NOT IN (SELECT bookid FROM Orders);

-- 문제 9
-- 상관 서브쿼리로 각 고객의 최대 금액 도서 매칭함 
CREATE VIEW v_cust_max_order AS
SELECT c.name AS 고객이름, b.bookname AS 도서명, o.saleprice AS 최고구매금액
FROM Customer c, Book b, Orders o
WHERE c.custid = o.custid AND b.bookid = o.bookid
AND o.saleprice = (SELECT MAX(saleprice) FROM Orders o2 WHERE o2.custid = o.custid);

-- 문제 10
-- 인라인 뷰로 도서별 평균가 미리 계산 후 조인함 
CREATE VIEW v_book_price_compare AS
SELECT b.bookname AS 도서명, c.name AS 고객이름, o.saleprice AS 판매가, avg_table.avg_price AS 도서평균판매가, (o.saleprice - avg_table.avg_price) AS 차이
FROM Customer c, Book b, Orders o, (SELECT bookid, AVG(saleprice) AS avg_price FROM Orders GROUP BY bookid) avg_table
WHERE c.custid = o.custid AND b.bookid = o.bookid AND b.bookid = avg_table.bookid;/


-- 문제 1
-- 출판사별 판매 실적 집계함 
CREATE VIEW v_publisher_sales AS
SELECT b.publisher AS 출판사, COUNT(o.orderid) AS 판매도서수, SUM(o.saleprice) AS 총판매금액
FROM Book b, Orders o
WHERE b.bookid = o.bookid
GROUP BY b.publisher;

-- 문제 2
-- HAVING절 서브쿼리로 전체 평균과 비교함 
CREATE VIEW v_above_avg_customer AS
SELECT c.name AS 고객이름, AVG(o.saleprice) AS 평균구매금액
FROM Customer c, Orders o
WHERE c.custid = o.custid
GROUP BY c.name
HAVING AVG(o.saleprice) > (SELECT AVG(saleprice) FROM Orders);

-- 문제 3
-- 조회 결과 정렬 포함함 
CREATE VIEW v_orders_detail AS
SELECT b.bookname AS 도서명, c.name AS 고객이름, o.orderdate AS 주문일자, o.saleprice AS 판매가격
FROM Customer c, Book b, Orders o
WHERE c.custid = o.custid AND b.bookid = o.bookid
ORDER BY o.saleprice DESC;

-- 문제 4
-- 주문 횟수 2회 이상 필터링함 
CREATE VIEW v_frequent_customer AS
SELECT c.name, COUNT(o.orderid) AS 주문횟수
FROM Customer c, Orders o
WHERE c.custid = o.custid
GROUP BY c.name
HAVING COUNT(o.orderid) >= 2;

-- 문제 5
-- 서브쿼리로 고객별 마지막 주문일자 도서 찾음 
CREATE VIEW v_last_ordered_book AS
SELECT c.name AS 고객이름, b.bookname AS 도서명, o.orderdate AS 주문일자
FROM Customer c, Book b, Orders o
WHERE c.custid = o.custid AND b.bookid = o.bookid
AND o.orderdate = (SELECT MAX(orderdate) FROM Orders o2 WHERE o2.custid = o.custid);

-- 문제 6
-- 할인된 경우만 추출하여 출판사별 평균 계산함 
CREATE VIEW v_publisher_discount_rate AS
SELECT b.publisher, AVG((b.price - o.saleprice) / b.price * 100) AS 평균할인율
FROM Book b, Orders o
WHERE b.bookid = o.bookid AND b.price > o.saleprice
GROUP BY b.publisher
ORDER BY 평균할인율 DESC;

-- 문제 7
-- LEFT JOIN과 CASE문으로 주문 여부 판별함 
CREATE VIEW v_customer_order_status AS
SELECT DISTINCT c.name AS 고객이름,
CASE WHEN o.orderid IS NULL THEN '주문없음' ELSE '주문있음' END AS 주문여부
FROM Customer c LEFT JOIN Orders o ON c.custid = o.custid;

-- 문제 8
-- 날짜 함수로 년, 월 추출하여 집계함 
CREATE VIEW v_monthly_sales AS
SELECT TO_CHAR(orderdate, 'YYYY') AS 년도, TO_CHAR(orderdate, 'MM') AS 월, SUM(saleprice) AS 총판매금액, COUNT(orderid) AS 주문건수
FROM Orders
GROUP BY TO_CHAR(orderdate, 'YYYY'), TO_CHAR(orderdate, 'MM');

-- 문제 9
-- 동일 출판사 도서 종류가 2개 이상인 경우임 
CREATE VIEW v_publisher_loyal_customer AS
SELECT c.name AS 고객이름, b.publisher AS 출판사, COUNT(DISTINCT b.bookid) AS 구매종류수
FROM Customer c, Book b, Orders o
WHERE c.custid = o.custid AND b.bookid = o.bookid
GROUP BY c.name, b.publisher
HAVING COUNT(DISTINCT b.bookid) >= 2;

-- 문제 10
-- 도서별 다양한 가격 지표 산출함 
CREATE VIEW v_book_price_stats AS
SELECT b.bookname AS 도서명, b.publisher AS 출판사, MAX(o.saleprice) AS 최고판매가, MIN(o.saleprice) AS 최저판매가, AVG(o.saleprice) AS 평균판매가, MAX(b.price - o.saleprice) AS 최대할인금액
FROM Book b, Orders o
WHERE b.bookid = o.bookid
GROUP BY b.bookname, b.publisher;

-- 문제 1
-- 사원과 부서 정보 결합함 
CREATE VIEW v_emp_basic AS
SELECT e.empid AS 사원번호, e.name AS 이름, d.deptname AS 부서명, e.position AS 직급, e.salary AS 급여
FROM Emp e, Dept d
WHERE e.deptid = d.deptid;

-- 문제 2
-- 수정 불가하도록 읽기 전용으로 생성함 
CREATE VIEW v_high_salary_emp AS
SELECT e.name, e.position, e.salary, d.deptname
FROM Emp e, Dept d
WHERE e.deptid = d.deptid AND e.salary >= 5000000
WITH READ ONLY;

-- 문제 3
-- 현재 날짜 기준으로 진행 중인 프로젝트 필터링함 
CREATE VIEW v_active_projects AS
SELECT projid, projname, startdate, enddate
FROM Project
WHERE SYSDATE BETWEEN startdate AND enddate;

-- 문제 4
-- 입사일 기준 근속연수 계산함 
CREATE VIEW v_veteran_employee AS
SELECT e.empid, e.name, d.deptname, e.hiredate, (TO_CHAR(SYSDATE, 'YYYY') - TO_CHAR(e.hiredate, 'YYYY')) AS 근속연수
FROM Emp e, Dept d
WHERE e.deptid = d.deptid AND e.hiredate < '2019-01-01';

-- 문제 5
-- 특정 지역 부서 정보 추출함 
CREATE VIEW v_seoul_department AS
SELECT deptid, deptname, budget
FROM Dept
WHERE location = '서울';

-- 문제 6
-- 특정 직급 대상 읽기 전용 뷰임 
CREATE VIEW v_senior_position AS
SELECT empid, name, position, salary
FROM Emp
WHERE position IN ('부장', '이사')
WITH READ ONLY;

-- 문제 7
-- PM 역할 수행자 추출함 
CREATE VIEW v_pm_role AS
SELECT empid, projid, role, hours
FROM Works
WHERE role = 'PM';

-- 문제 8
-- 급여와 입사일 동시 조건 처리함 
CREATE VIEW v_junior_emp AS
SELECT name, position, salary, hiredate
FROM Emp
WHERE salary < 3000000 AND hiredate >= '2022-01-01';

-- 문제 9
-- 대규모 예산 프로젝트 읽기 전용 뷰임 
CREATE VIEW v_large_budget_project AS
SELECT projname, startdate, enddate, budget
FROM Project
WHERE budget >= 100000000
WITH READ ONLY;

-- 문제 10
-- 상위 관리자가 없는 조건 처리함 
CREATE VIEW v_top_executive AS
SELECT e.empid, e.name, d.deptname, e.position, e.salary
FROM Emp e, Dept d
WHERE e.deptid = d.deptid AND e.managerid IS NULL AND e.salary >= 7000000
WITH READ ONLY;


-- 문제 1
-- 부서별 급여 통계임 
CREATE VIEW v_dept_salary_stats AS
SELECT d.deptname, AVG(e.salary) AS 평균급여, MAX(e.salary) AS 최고급여, MIN(e.salary) AS 최저급여
FROM Emp e, Dept d
WHERE e.deptid = d.deptid
GROUP BY d.deptname;

-- 문제 2
-- 사원별 참여도 집계함 
CREATE VIEW v_emp_project_summary AS
SELECT e.name AS 사원이름, COUNT(w.projid) AS 참여프로젝트수, SUM(w.hours) AS 총투입시간
FROM Emp e, Works w
WHERE e.empid = w.empid
GROUP BY e.name;

-- 문제 3
-- 소수점 2자리까지 비율 계산함 
CREATE VIEW v_dept_budget_ratio AS
SELECT d.deptname, d.budget AS 부서예산, AVG(e.salary) AS 평균급여, ROUND(AVG(e.salary) / d.budget * 100, 2) AS 급여예산비율
FROM Emp e, Dept d
WHERE e.deptid = d.deptid
GROUP BY d.deptname, d.budget;

-- 문제 4
-- 현재 진행 중인 프로젝트 참여 사원 상세 정보임 
CREATE VIEW v_active_project_emp AS
SELECT e.name, d.deptname, p.projname, w.role
FROM Emp e, Dept d, Project p, Works w
WHERE e.empid = w.empid AND p.projid = w.projid AND e.deptid = d.deptid
AND SYSDATE BETWEEN p.startdate AND p.enddate;

-- 문제 5
-- 프로젝트 참여 이력이 없는 사원 필터링함 
CREATE VIEW v_no_project_emp AS
SELECT e.empid, e.name, d.deptname, e.position
FROM Emp e JOIN Dept d ON e.deptid = d.deptid
WHERE e.empid NOT IN (SELECT empid FROM Works);

-- 문제 6
-- 프로젝트 중심 통계 정보임 
CREATE VIEW v_project_stats AS
SELECT p.projname, COUNT(w.empid) AS 참여사원수, SUM(w.hours) AS 총투입시간, AVG(w.hours) AS 평균투입시간
FROM Project p, Works w
WHERE p.projid = w.projid
GROUP BY p.projname;

-- 문제 7
-- 상관 서브쿼리로 부서 평균과 개별 급여 비교함 
CREATE VIEW v_above_dept_avg AS
SELECT e.name, d.deptname, e.salary,
(SELECT AVG(salary) FROM Emp e2 WHERE e2.deptid = e.deptid) AS 부서평균급여
FROM Emp e, Dept d
WHERE e.deptid = d.deptid
AND e.salary > (SELECT AVG(salary) FROM Emp e2 WHERE e2.deptid = e.deptid);

-- 문제 8
-- 부서 내 가장 이른 입사일자 찾음 
CREATE VIEW v_longest_serving AS
SELECT e.name, d.deptname, e.hiredate, (TO_CHAR(SYSDATE, 'YYYY') - TO_CHAR(e.hiredate, 'YYYY')) AS 근속연수
FROM Emp e, Dept d
WHERE e.deptid = d.deptid
AND e.hiredate = (SELECT MIN(hiredate) FROM Emp e2 WHERE e2.deptid = e.deptid);

-- 문제 9
-- 복합 그룹화 조건(HAVING) 적용함 
CREATE VIEW v_active_emp AS
SELECT e.name, COUNT(w.projid) AS 참여프로젝트수, SUM(w.hours) AS 총투입시간
FROM Emp e, Works w
WHERE e.empid = w.empid
GROUP BY e.name
HAVING COUNT(w.projid) >= 2 AND SUM(w.hours) >= 100;

-- 문제 10
-- 부서별 PM 역할 수와 평균 급여 산출함 
CREATE VIEW v_dept_pm_stats AS
SELECT d.deptname, COUNT(w.empid) AS PM수, AVG(e.salary) AS 부서평균급여
FROM Dept d, Emp e, Works w
WHERE d.deptid = e.deptid AND e.empid = w.empid AND w.role = 'PM'
GROUP BY d.deptname;