-- 문제 1
create view v_salesperson_info
as select name, age, salary
from salesperson;
select * from v_salesperson_info;
-- 문제 2
create view v_high_salary_sp
as select name, salary
from salesperson
where salary >= 10000;

select * from v_high_salary_sp;
--INSERT INTO Salesperson (name, age, salary) 
--VALUES ('Chad', 24, 25000);
-- 문제 3
create view v_young_salesperson
as select name, age, salary
from salesperson
where age < 30;
select * from v_young_salesperson;

-- 문제 4
create or replace view v_la_customer
as select name, city, industrytype
from customers
where city = 'LA';
select * from v_la_customer;

-- 문제 5
create view v_developer_customer
as select name, city, industrytype
from customers
where industrytype = 'IT'
WITH CHECK OPTION;

select * from v_developer_customer;

--문제6
create or replace view v_high_amount_order
as select num, custname, salesperson, amount
from "order"
with read only;

select * from v_high_amount_order;

--문제7
create view v_mid_salary_sp
as select name, age, salary
from salesperson
where salary >= 8000 and salary <= 12000;

select * from v_mid_salary_sp;

-- 문제 8
create or replace view v_tom_order
as select num, custname, salesperson, amount
from "order"
where salesperson = 'TOM';

select * from v_tom_order;


-- 문제 9
-- 이름이 'S'로 시작하는 판매원의 이름, 나이, 급여를 보여주는 읽기 전용 뷰 v_s_salesperson을 작성하시오.
create or replace view v_s_salesperson
as select name, age, salary
from salesperson
where name like 'S%'
with read only;

select * from v_s_salesperson;

-- 문제 10
-- 주문금액 5000 이상 10000이하 주문번호, 고객이름, 담당판매원, 주문금액을 보여주는 뷰 작성 
CREATE VIEW v_mid_amount_order
as select num, custname, salesperson, amount
from "order"
where amount >= 5000 and amount <= 10000;

select * from v_mid_amount_order;


-- 복합 뷰
-- 문제 1
-- 판매원 별 총 주문금액과 주문 횟수를 보여주는 뷰 작성 출력: 판매원이름, 총주문금액, 주문횟수
CREATE OR REPLACE VIEW v_sp_order_summary AS
SELECT s.name AS 판매원이름,
 SUM(o.amount) AS 총주문금액,
 COUNT(o.num) AS 주문횟수
FROM Salesperson s
JOIN "order" o ON s.name = o.salesperson
GROUP BY s.name;

select * from v_sp_order_summary;

-- 문제 2
-- 고객별 총 주문금액과 주문 횟수를 보여주는 뷰 작성 출력 : 고객이름, 도시, 총 주문금액, 주문횟수
CREATE OR REPLACE VIEW v_cust_order_summary AS
SELECT c.name AS 고객이름,
 c.city AS 도시,
 SUM(o.amount) AS 총주문금액,
 COUNT(o.num) AS 주문횟수
FROM Customers c
JOIN "order" o ON c.name = o.custname
GROUP BY c.name, c.city;

select * from v_cust_order_summary;

-- 문제 3
-- 판매원의 평균 급여보다 높은 급여를 받는 판매원의 이름, 나이, 급여를 보여주는 뷰 작성
create or replace view v_above_avg_salary
as select name, age, salary
from salesperson
where salary > (select avg(salary) from salesperson);

select * from v_above_avg_salary;

-- 문제 4
-- 한 번도 주문을 받지 못한 판매원의 이름 나이 급여를 보여주는 뷰 작성
create or replace view v_no_order_sp
as select s.name, s.age, s.salary
from salesperson s
where not EXISTS (
    select 1
    from "order" o
    where o.salesperson = s.name
);

select * from v_no_order_sp;

-- 문제 5
-- 'LA'에 거주하는 고객으로부터 주문을 받은 판매원의 이름, 나이, 급여를 보여주는 뷰 작성
create or replace view v_la_order_sp1
as select DISTINCT s.name, s.age, s.salary
from salesperson s
join "order" o on s.name = o.salesperson
join customers c on o.custname = c.name
where c.city = 'LA';

select * from v_la_order_sp1;

-- 문제 6
-- 판매원별 평균 주문금액을 계산하여 전체 평균 주문금액보다 높은 판매원의 이름과 평균주문금액을 보여주는 뷰 작성
create or replace view v_above_avg_order_sp
as select name, Round(avg(amount)) as "평균주문금액"
from "order"
group by salesperson
having avg(amount) > (select AVG(AMOUNT) from "order");
select * from v_above_avg_order_sp;

-- 문제7
-- 한 번도 주문하지않은 곡개의 이름, 도시, 직업을 보여주는 뷰 작성
CREATE OR REPLACE VIEW v_no_order_cust AS
SELECT c.name, c.city, c.industrytype
FROM customers c
LEFT JOIN "order" o ON c.name = o.custname
WHERE o.custname IS NULL;

select * from v_no_order_cust;

-- 문제 8
-- 2건 이상 주문을 받은 판매원의 이름과 주문 횟수, 총 주문금액을 보여주는 뷰 작성
create or replace view v_frequent_sp
as select salesperson, count(*) as "주문 횟수", sum(amount) as "총 주문금액"
from "order"
group by salesperson
having count(*) >=2;

select * from v_frequent_sp;

-- 문제 9
-- 고객의 도시별 총 주문 금액과 주문 건수를 보여주는 뷰 작성
create or replace view v_city_order_stats
as select c.city, sum(o.amount) as "총 주문금액", count(*) as "주문건수"
from customers c
join "order" o on c.name = o.custname
group by c.city;

select * from v_city_order_stats;

-- 문제 10
-- 판매원별 최고 주문금액, 최저 주문금액, 평균 주문금액과 자신의 급여 대비 총 주문금액 비율을 보여주는 뷰 작성
create or replace view v_sp_order_stats
as select s.name as "판매원이름", 
          s.salary as "급여", 
          max(o.amount) as "최고주문금액",
          min(o.amount) as "최소주문금액",
          round(avg(o.amount)) as "평균주문금액",
          ROUND((SUM(o.amount) / s.salary) * 100, 2) || '%' AS "급여대비주문비율"
from salesperson s
join "order" o on s.name = o.salesperson
group by s.name, s.salary;

select * from v_sp_order_stats;

-- 문제 11
-- 직업별 총 주문금액과 평균 주문금액을 보여주는 뷰 작성
create or replace view v_industry_order_stats
as select c.industrytype,
          sum(o.amount) as "총주문금액",
          round(avg(o.amount)) as "평균주문금액"
from customers c
join "order" o on c.name = o.custname
group by c.industrytype;

select * from v_industry_order_stats;

-- 문제 12
-- 판매원 중 자신의 급여보다 총 주문금액이 더 높은 판매원의 이름, 급여, 총주문금액을 보여주는 뷰 작성
create or replace view v_sp_order_over_salary
as select s.name, s.salary, sum(o.amount) as "총주문금액"
from salesperson s
join "order" o on s.name = o.salesperson
group by s.name, s.salary
having sum(o.amount) > s.salary;

select * from v_sp_order_over_salary;


-- 문제 13
-- 각 판매원이 주문을 받은 고객의 수(서로 다른 고객만)와 총 주문금액을 보여주는 뷰 작성
create or replace view v_sp_cust_count
as select s.name, count(DISTINCT o.custname) as "담당고객수", sum(o.amount) as "총주문금액"
from salesperson s
join "order" o on s.name = o.salesperson
group by s.name;

select * from v_sp_cust_count;

-- 문제 14
-- 주문 금액이 가장 높은 주문을 한 고객의 이름, 도시, 직업, 주문금액을 보여주는 뷰 작성
create or replace view v_max_order_cust
as select c.name, c.city, c.industrytype, o.amount
from customers c
join "order" o on c.name = o.custname
where o.amount = (select max(amount) from "order");

select * from v_max_order_cust;

-- 문제 15
-- 판매원별로 주문금액의 합계를 구하고, 전체 주문금액 대비 각 판매원의 주문 비중을 보여주는 뷰 작성
CREATE OR REPLACE VIEW v_sp_super_ratio AS 
SELECT 
    o.salesperson AS "판매원이름", 
    SUM(o.amount) AS "총주문금액", 
    (SELECT SUM(amount) FROM "order") AS "전체주문금액", -- 서브쿼리로 전체 합계 산출
    ROUND((SUM(o.amount) / (SELECT SUM(amount) FROM "order")) * 100, 2) || '%' AS "주문비중"
FROM "order" o
GROUP BY o.salesperson; -- 판매원별로 그룹화
          
select * from v_sp_super_ratio;

-- 문제 11 직업별 총 주문금액과 평균 주문금액을 보여주는 뷰 작성
CREATE OR REPLACE VIEW v_industry_order_stats AS 
select c.industrytype, sum(o.amount) as "총주문금액", round(avg(o.amount)) as "평균주문금액"
from customers c
join "order" o on c.name = o.custname
group by c.industrytype;

select * from v_industry_order_stats;

-- 문제 12 판매원 중 자신의 급여보다 총 주문금액이 더 높은 판매원의 뷰 작성
CREATE OR REPLACE VIEW v_industry_order_stats AS 
select s.name, s.salary, sum(o.amount) as "총주문금액"
from salesperson s
join "order" o on s.name = o.salesperson
group by s.name, s.salary;

-- 문제 13 각 판매원이 주문을 받은 고객의 수 (서로 다른 고객만)와 총 주문금액을 보여주는 뷰 작성
CREATE OR REPLACE VIEW v_sp_cust_count AS 
select o.salesperson, count(distinct o.custname) as "담당고객수", sum(o.amount) as "총주문금액"
from "order" o
group by o.salesperson;

select * from v_sp_cust_count;

-- 문제 14 주문금액이 가장 높은 주문을 한 곡개의 이름, 도시, 직업, 주문금액을 보여주는 뷰 작성
CREATE OR REPLACE VIEW v_max_order_cust as
select c.name, c.city, c.industrytype, o.amount as "주문금액"
from customers c
join "order" o on c.name = o.custname
where o.amount = (select max(amount) from "order");

select * from v_max_order_cust;


-- 문제 15 판매원별로 주문금액의 합계를 구하고, 전체 주문금액 대비 각 판매원의 주문 비중을 보여주는 뷰 작성
CREATE OR REPLACE VIEW v_sp_order_ratio AS
SELECT 
    salesperson AS "판매원이름", 
    SUM(amount) AS "총주문금액", 
    (SELECT SUM(amount) FROM "order") AS "전체주문금액",
    ROUND((SUM(amount) / (SELECT SUM(amount) FROM "order")) * 100, 2) || '%' AS "주문비중"
FROM "order"
GROUP BY salesperson;

select * from v_sp_order_ratio;

-- 극장 데이터베이스 3장 연습문제
-- 문제 1 모든 극장의 극장번호, 극장이름, 위치를 보여주는 뷰 작성
CREATE OR REPLACE VIEW v_theater_info AS
select 극장번호, 극장이름, 위치
from 극장;
select * from v_theater_info;

-- 문제2 위치가 강남인 극장의 극장번호 극장이름을 보여주는 읽기전용 뷰 생성
CREATE OR REPLACE VIEW v_gangnam_theater AS
select 극장번호, 극장이름
from 극장
where 위치 = '강남'
with read only;

select * from v_gangnam_theater;

-- 문제 3 가격이 10000원 이상인 상영관의 극장번호 상영관 번호 영화제목 가격을 보여주는 읽기 전용 뷰 생성
CREATE OR REPLACE VIEW v_high_price_screen AS
select 극장번호, 상영관번호, 영화제목, 가격
from 상영관
where 가격 >= 10000
with read only;
select * from v_high_price_screen;

-- 문제 4 좌석수가 100석 이상인 상영관 뷰생성
CREATE OR REPLACE VIEW v_large_screen AS
select 극장번호, 상영관번호, 영화제목, 좌석수
from 상영관 
where 좌석수 >= 100;
select * from v_large_screen;

-- 문제 5 주소가 강남인 고객의 고객번호 이름 주소를 보여주는 뷰 생성
CREATE OR REPLACE VIEW v_gangnam_customer AS
select 고객번호, 이름, 주소
from 고객
where 주소 = '강남';
select * from v_gangnam_customer;

-- 문제 6 2025년 9월 1일에 예약된 내역의 극장번호, 상영관번호, 고객번호, 좌석번호, 날짜를 보여주는 뷰 v_reservation_20250901을 작성하시오. 
create or replace view v_reservation_20250901 as
select 극장번호, 상영관번호, 고객번호, 좌석번호, 날짜
from 예약
WHERE 날짜 = TO_DATE('2025/09/01', 'YYYY/MM/DD');
select * from v_reservation_20250901;

-- 문제 7 가격이 7,500원 이상 10,000원 이하인 상영관의 극장번호, 상영관번호, 영화제목, 가격을 보여
--주는 뷰 v_mid_price_screen을 작성하시오. 단, 조건을 벗어나는 데이터는 입력할 수 없도록 설정하시오. 
create or replace view v_mid_price_screen as
select 극장번호, 상영관번호, 영화제목, 가격
from 상영관
where 가격 between 7500 and 10000
WITH CHECK OPTION;
select * from v_mid_price_screen;

--문제 8.
--좌석번호가 20번 이하인 예약 내역의 극장번호, 상영관번호, 고객번호, 좌석번호를 보여주는
--뷰 v_front_seat_reservation을 작성하시오. 
create or replace view v_front_seat_reservation as
select 극장번호, 상영관번호, 고객번호, 좌석번호
from 예약
where 좌석번호 <= 20;

select * from v_front_seat_reservation;

--문제 9.
--영화제목에 '영화'가 포함된 상영관의 극장번호, 상영관번호, 영화제목, 가격, 좌석수를 보여주
--는 읽기 전용 뷰 v_movie_screen을 작성하시오.
create or replace view v_movie_screen as 
select 극장번호, 상영관번호, 영화제목, 가격, 좌석수
from 상영관
where 영화제목 like '%영화%'
with read only;

select * from v_movie_screen;

--문제 10.
--주소가 '잠실'인 고객의 고객번호, 이름, 주소를 보여주는 뷰 v_jamsil_customer를 작성하시
--오. 단, 조건을 벗어나는 데이터는 입력할 수 없도록 설정하시오.
create or replace view v_jamsil_customer as 
select 고객번호, 이름, 주소
from 고객
where 주소 = '잠실'
WITH CHECK OPTION;

select * from v_jamsil_customer;

--(극장 데이터베이스 복합 뷰 문제)
--문제 1.
--극장별 상영관 수와 평균 가격을 보여주는 뷰 v_theater_screen_stats를 작성하시오.
--(출력 컬럼 : 극장이름, 위치, 상영관수, 평균가격)
CREATE OR REPLACE VIEW v_theater_screen_stats AS
SELECT 
    t.극장이름, 
    t.위치, 
    COUNT(s.상영관번호) AS "상영관수", 
    ROUND(AVG(s.가격)) AS "평균가격"
FROM 극장 t
JOIN 상영관 s ON t.극장번호 = s.극장번호
GROUP BY t.극장이름, t.위치;

-- 결과 확인
SELECT * FROM v_theater_screen_stats;


--문제 2.
--각 극장의 상영관 중 가격이 가장 비싼 영화제목과 가격을 보여주는
--뷰 v_theater_max_price를 작성하시오.
--(출력 컬럼 : 극장이름, 영화제목, 가격)
CREATE OR REPLACE VIEW v_theater_max_price AS
SELECT 
    t.극장이름, 
    s.영화제목, 
    s.가격
FROM 극장 t
JOIN 상영관 s ON t.극장번호 = s.극장번호
WHERE (s.극장번호, s.가격) IN (
    -- 각 극장별로 가장 높은 가격이 얼마인지 찾는 서브쿼리
    SELECT 극장번호, MAX(가격)
    FROM 상영관
    GROUP BY 극장번호
);

-- 결과 확인
SELECT * FROM v_theater_max_price;

-- 문제 3. 가격이 10,000원 이상인 상영관의 극장번호, 상영관번호, 영화제목, 가격을 보여주는 읽기 전용 뷰 v_high_price_screen을 작성하시오.
CREATE OR REPLACE VIEW v_high_price_screen AS
SELECT 극장번호, 상영관번호, 영화제목, 가격
FROM 상영관
WHERE 가격 >= 10000
WITH READ ONLY;

-- 문제 4. 좌석수가 100석 이상인 상영관의 극장번호, 상영관번호, 영화제목, 좌석수를 보여주는 뷰 v_large_screen을 작성하시오.
CREATE OR REPLACE VIEW v_large_screen AS
SELECT 극장번호, 상영관번호, 영화제목, 좌석수
FROM 상영관
WHERE 좌석수 >= 100;

-- 문제 5. 주소가 '강남'인 고객의 고객번호, 이름, 주소를 보여주는 읽기 전용 뷰 v_gangnam_customer를 작성하시오.
CREATE OR REPLACE VIEW v_gangnam_customer AS
SELECT 고객번호, 이름, 주소
FROM 고객
WHERE 주소 = '강남'
WITH READ ONLY;

-- 문제 6. 2025년 9월 1일에 예약된 내역의 극장번호, 상영관번호, 고객번호, 좌석번호, 날짜를 보여주는 뷰 v_reservation_20250901을 작성하시오.
CREATE OR REPLACE VIEW v_reservation_20250901 AS
SELECT 극장번호, 상영관번호, 고객번호, 좌석번호, 날짜
FROM 예약
WHERE 날짜 = TO_DATE('2025-09-01', 'YYYY-MM-DD');

-- 문제 7. 가격이 7,500원 이상 10,000원 이하인 상영관의 극장번호, 상영관번호, 영화제목, 가격을 보여주는 뷰 v_mid_price_screen을 작성하시오. 단, 조건을 벗어나는 데이터는 입력할 수 없도록 설정하시오.
CREATE OR REPLACE VIEW v_mid_price_screen AS
SELECT 극장번호, 상영관번호, 영화제목, 가격
FROM 상영관
WHERE 가격 BETWEEN 7500 AND 10000
WITH CHECK OPTION;

-- 문제 8. 좌석번호가 20번 이하인 예약 내역의 극장번호, 상영관번호, 고객번호, 좌석번호를 보여주는 뷰 v_front_seat_reservation을 작성하시오.
CREATE OR REPLACE VIEW v_front_seat_reservation AS
SELECT 극장번호, 상영관번호, 고객번호, 좌석번호
FROM 예약
WHERE 좌석번호 <= 20;

-- 문제 9. 영화제목에 '영화'가 포함된 상영관의 극장번호, 상영관번호, 영화제목, 가격, 좌석수를 보여주는 읽기 전용 뷰 v_movie_screen을 작성하시오.
CREATE OR REPLACE VIEW v_movie_screen AS
SELECT 극장번호, 상영관번호, 영화제목, 가격, 좌석수
FROM 상영관
WHERE 영화제목 LIKE '%영화%'
WITH READ ONLY;

-- 문제 10. 주소가 '잠실'인 고객의 고객번호, 이름, 주소를 보여주는 뷰 v_jamsil_customer를 작성하시오. 단, 조건을 벗어나는 데이터는 입력할 수 없도록 설정하시오.
CREATE OR REPLACE VIEW v_jamsil_customer AS
SELECT 고객번호, 이름, 주소
FROM 고객
WHERE 주소 = '잠실'
WITH CHECK OPTION;

-- 문제 1. 극장별 상영관 수와 평균 가격을 보여주는 뷰 v_theater_screen_stats를 작성하시오.
CREATE OR REPLACE VIEW v_theater_screen_stats AS
SELECT t.극장이름, t.위치, COUNT(s.상영관번호) AS 상영관수, ROUND(AVG(s.가격)) AS 평균가격
FROM 극장 t
JOIN 상영관 s ON t.극장번호 = s.극장번호
GROUP BY t.극장이름, t.위치;

-- 문제 2. 각 극장의 상영관 중 가격이 가장 비싼 영화제목과 가격을 보여주는 뷰 v_theater_max_price를 작성하시오.
CREATE OR REPLACE VIEW v_theater_max_price AS
SELECT t.극장이름, s.영화제목, s.가격
FROM 극장 t
JOIN 상영관 s ON t.극장번호 = s.극장번호
WHERE (s.극장번호, s.가격) IN (SELECT 극장번호, MAX(가격) FROM 상영관 GROUP BY 극장번호);

-- 문제 3. 고객별 총 예약 횟수를 보여주는 뷰 v_customer_reservation_count를 작성하시오.
CREATE OR REPLACE VIEW v_customer_reservation_count AS
SELECT c.이름 AS 고객이름, c.주소, COUNT(r.고객번호) AS 총예약횟수
FROM 고객 c
LEFT JOIN 예약 r ON c.고객번호 = r.고객번호
GROUP BY c.이름, c.주소;

-- 문제 4. 한 번도 예약하지 않은 고객의 고객번호, 이름, 주소를 보여주는 뷰 v_no_reservation_customer를 작성하시오.
CREATE OR REPLACE VIEW v_no_reservation_customer AS
SELECT 고객번호, 이름, 주소
FROM 고객
WHERE 고객번호 NOT IN (SELECT DISTINCT 고객번호 FROM 예약);

-- 문제 5. 예약이 한 번도 없는 상영관의 극장번호, 상영관번호, 영화제목, 가격을 보여주는 뷰 v_no_reservation_screen을 작성하시오.
CREATE OR REPLACE VIEW v_no_reservation_screen AS
SELECT 극장번호, 상영관번호, 영화제목, 가격
FROM 상영관
WHERE (극장번호, 상영관번호) NOT IN (SELECT DISTINCT 극장번호, 상영관번호 FROM 예약);

-- 문제 6. 극장별 총 예약 건수와 총 예약 좌석수를 보여주는 뷰 v_theater_reservation_stats를 작성하시오.
CREATE OR REPLACE VIEW v_theater_reservation_stats AS
SELECT t.극장이름, COUNT(r.고객번호) AS 총예약건수, COUNT(r.좌석번호) AS 총예약좌석수
FROM 극장 t
JOIN 예약 r ON t.극장번호 = r.극장번호
GROUP BY t.극장이름;

-- 문제 7. '강남'에 사는 고객이 예약한 내역의 고객이름, 극장번호, 상영관번호, 좌석번호, 날짜를 보여주는 뷰 v_gangnam_customer_reservation을 작성하시오.
CREATE OR REPLACE VIEW v_gangnam_customer_reservation AS
SELECT c.이름 AS 고객이름, r.극장번호, r.상영관번호, r.좌석번호, r.날짜
FROM 고객 c
JOIN 예약 r ON c.고객번호 = r.고객번호
WHERE c.주소 = '강남';

-- 문제 8. 상영관별 예약 건수와 전체 좌석수 대비 예약된 좌석의 비율을 보여주는 뷰 v_screen_reservation_rate를 작성하시오.
CREATE OR REPLACE VIEW v_screen_reservation_rate AS
SELECT s.극장번호, s.상영관번호, s.영화제목, s.좌석수, COUNT(r.좌석번호) AS 예약건수,
       ROUND((COUNT(r.좌석번호) / s.좌석수) * 100, 2) || '%' AS 예약률
FROM 상영관 s
LEFT JOIN 예약 r ON s.극장번호 = r.극장번호 AND s.상영관번호 = r.상영관번호
GROUP BY s.극장번호, s.상영관번호, s.영화제목, s.좌석수;

-- 문제 9. 2건 이상 예약한 고객의 이름, 주소, 예약횟수를 보여주는 뷰 v_frequent_customer를 작성하시오.
CREATE OR REPLACE VIEW v_frequent_customer AS
SELECT c.이름, c.주소, COUNT(r.고객번호) AS 예약횟수
FROM 고객 c
JOIN 예약 r ON c.고객번호 = r.고객번호
GROUP BY c.이름, c.주소
HAVING COUNT(r.고객번호) >= 2;

-- 문제 10. 영화제목별 총 예약 건수와 총 예약 금액을 보여주는 뷰 v_movie_reservation_stats를 작성하시오.
CREATE OR REPLACE VIEW v_movie_reservation_stats AS
SELECT s.영화제목, COUNT(r.고객번호) AS 총예약건수, SUM(s.가격) AS 총예약금액
FROM 상영관 s
JOIN 예약 r ON s.극장번호 = r.극장번호 AND s.상영관번호 = r.상영관번호
GROUP BY s.영화제목;

-- 문제 11. 극장 위치별 평균 영화 가격과 총 상영관 수를 보여주는 뷰 v_location_screen_stats를 작성하시오.
CREATE OR REPLACE VIEW v_location_screen_stats AS
SELECT t.위치, ROUND(AVG(s.가격)) AS 평균가격, COUNT(s.상영관번호) AS 총상영관수
FROM 극장 t
JOIN 상영관 s ON t.극장번호 = s.극장번호
GROUP BY t.위치;

-- 문제 12. 각 고객이 가장 최근에 예약한 날짜와 예약한 극장번호, 상영관번호를 보여주는 뷰 v_customer_last_reservation을 작성하시오.
CREATE OR REPLACE VIEW v_customer_last_reservation AS
SELECT c.이름 AS 고객이름, r.극장번호, r.상영관번호, r.날짜 AS 최근예약날짜
FROM 고객 c
JOIN 예약 r ON c.고객번호 = r.고객번호
WHERE (r.고객번호, r.날짜) IN (SELECT 고객번호, MAX(날짜) FROM 예약 GROUP BY 고객번호);

-- 문제 13. 전체 평균 가격보다 비싼 상영관의 극장이름, 상영관번호, 영화제목, 가격을 보여주는 뷰 v_above_avg_price_screen을 작성하시오.
CREATE OR REPLACE VIEW v_above_avg_price_screen AS
SELECT t.극장이름, s.상영관번호, s.영화제목, s.가격
FROM 극장 t
JOIN 상영관 s ON t.극장번호 = s.극장번호
WHERE s.가격 > (SELECT AVG(가격) FROM 상영관);

-- 문제 14. 극장별로 예약 건수가 가장 많은 상영관의 극장이름, 상영관번호, 영화제목, 예약건수를 보여주는 뷰 v_most_reserved_screen을 작성하시오.
CREATE OR REPLACE VIEW v_most_reserved_screen AS
SELECT t.극장이름, s.상영관번호, s.영화제목, res.cnt AS 예약건수
FROM 극장 t
JOIN 상영관 s ON t.극장번호 = s.극장번호
JOIN (SELECT 극장번호, 상영관번호, COUNT(*) AS cnt FROM 예약 GROUP BY 극장번호, 상영관번호) res 
  ON s.극장번호 = res.극장번호 AND s.상영관번호 = res.상영관번호
WHERE (s.극장번호, res.cnt) IN (
    SELECT 극장번호, MAX(COUNT(*)) 
    FROM 예약 
    GROUP BY 극장번호, 상영관번호
);

-- 문제 15. 고객별 총 예약금액을 계산하고 전체 예약금액 대비 각 고객의 예약 비중을 보여주는 뷰 v_customer_payment_ratio를 작성하시오.
CREATE OR REPLACE VIEW v_customer_payment_ratio AS
SELECT c.이름 AS 고객이름, 
       SUM(s.가격) AS 총예약금액, 
       (SELECT SUM(s2.가격) FROM 예약 r2 JOIN 상영관 s2 ON r2.극장번호 = s2.극장번호 AND r2.상영관번호 = s2.상영관번호) AS 전체예약금액,
       ROUND((SUM(s.가격) / (SELECT SUM(s2.가격) FROM 예약 r2 JOIN 상영관 s2 ON r2.극장번호 = s2.극장번호 AND r2.상영관번호 = s2.상영관번호)) * 100, 2) || '%' AS 예약비중
FROM 고객 c
JOIN 예약 r ON c.고객번호 = r.고객번호
JOIN 상영관 s ON r.극장번호 = s.극장번호 AND r.상영관번호 = s.상영관번호
GROUP BY c.이름;




-- 테이블 내용 너무 적어 추가로 작성한 것 by gemini
-- 주문 번호(NUM)는 기존 1, 2번에 이어 3번부터 부여
-- 금액 조건을 다양하게 설정 (고액 주문, 중등 금액 주문 등)
--INSERT INTO "order" (NUM, CUSTNAME, SALESPERSON, AMOUNT) VALUES (3, 'PARK', 'SAM', 20000);  -- 15,000 이상 고액 주문
--INSERT INTO "order" (NUM, CUSTNAME, SALESPERSON, AMOUNT) VALUES (4, 'CHOI', 'SAM', 18000);  -- SAM의 추가 실적
--INSERT INTO "order" (NUM, CUSTNAME, SALESPERSON, AMOUNT) VALUES (5, 'KIM', 'TOM', 7500);    -- 5,000~10,000 사이 주문
--INSERT INTO "order" (NUM, CUSTNAME, SALESPERSON, AMOUNT) VALUES (6, 'SMITH', 'SARA', 12000); -- 일반 주문
--INSERT INTO "order" (NUM, CUSTNAME, SALESPERSON, AMOUNT) VALUES (7, 'LEE', 'BOB', 6000);    -- 5,000~10,000 사이 주문
--INSERT INTO "order" (NUM, CUSTNAME, SALESPERSON, AMOUNT) VALUES (8, 'BROWN', 'TOM', 3000);   -- TOM의 추가 실적
---- 'LA' 거주자 및 '개발자' 직업군 추가
--INSERT INTO CUSTOMERS (NAME, CITY, INDUSTRYTYPE) VALUES ('PARK', 'LA', 'IT'); -- LA 거주 & 개발자
--INSERT INTO CUSTOMERS (NAME, CITY, INDUSTRYTYPE) VALUES ('CHOI', 'SEOUL', 'IT'); -- 개발자 (타지역)
--INSERT INTO CUSTOMERS (NAME, CITY, INDUSTRYTYPE) VALUES ('SMITH', 'LA', 'ARTIST');    -- LA 거주 (타직업)
--INSERT INTO CUSTOMERS (NAME, CITY, INDUSTRYTYPE) VALUES ('BROWN', 'NY', 'TEACHER');    -- 일반 데이터
--INSERT INTO CUSTOMERS (NAME, CITY, INDUSTRYTYPE) VALUES ('WHITE', 'TOKYO', 'IT');     -- 일반 데이터
---- 급여가 높은 판매원, 나이가 어린 판매원, 'S'로 시작하는 이름 등을 추가
--INSERT INTO SALESPERSON (NAME, AGE, SALARY) VALUES ('SAM', 25, 55000);   -- 'S' 시작, 30세 미만, 고액 급여
--INSERT INTO SALESPERSON (NAME, AGE, SALARY) VALUES ('SARA', 32, 9000);   -- 'S' 시작, 8,000~12,000 사이 급여
--INSERT INTO SALESPERSON (NAME, AGE, SALARY) VALUES ('BOB', 29, 30000);   -- 30세 미만
--INSERT INTO SALESPERSON (NAME, AGE, SALARY) VALUES ('STEVEN', 40, 11000); -- 'S' 시작, 8,000~12,000 사이 급여
--INSERT INTO SALESPERSON (NAME, AGE, SALARY) VALUES ('CHRIS', 31, 7000);  -- 저급여 판매원