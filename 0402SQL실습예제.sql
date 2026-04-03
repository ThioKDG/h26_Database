-- 문제 7 릴레이션 R(A,B,C) S(C,D,E)가 주어졌을 때 관계대수를 같은 의미를 갖는 SQL문으로 변환
-- 1
select A from R;

-- 2
select A, B from R;

-- 3
select * 
from R 
natural join S;

-- 문제 8. 다음 릴레이션 R(A,B,C)와 S(C,D,E)가 주어졌을 때 다음 결과가 도출되도록 sql문을 작성하시오
create table R(
    A varchar(20) not null,
    B varchar(20) not null,
    C varchar(20) not null
);
create table S(
    C varchar(20) not null,
    D varchar(20) not null,
    E varchar(20) not null
);
insert into R (A, B, C)
     VALUES ('a1', 'b1', 'c1'); -- 1 3
insert into R (A, B, C)
     VALUES ('a2', 'b1', 'c1'); -- 2 4 
insert into R (A, B, C)
     VALUES ('a3', 'b1', 'c2'); -- 5
insert into R (A, B, C)
     VALUES ('a4', 'b2', 'c4');

insert into S (C, D, E)
     VALUES ('c1', 'd2', 'e1'); -- 1   2 
insert into S (C, D, E)
     VALUES ('c1', 'd1', 'e2') ; -- 3   4
insert into S (C, D, E)
     VALUES ('c2', 'd3', 'e3');  -- 5
insert into S (C, D, E)
     VALUES ('c5', 'd3', 'e3');
-- 8번 실행문
-- 내부 조인
select * from R inner join S on (R.c = S.c);
-- 왼쪽 테이블 기준 조인
select * from R Left outer join S On (R.c = S.c);
-- 오른쪽 테이블 기준 조인
SELECT * FROM R RIGHT OUTER JOIN S ON (R.c=S.c);
-- 전체 외부 조인 (공통되지 않은 행도 유지)
SELECT * FROM R FULL OUTER JOIN S ON (R.c=S.c);
-- 곱집합(두 테이블 데이터의 모든 조합)
SELECT * FROM R CROSS JOIN S ;

-- 9번 UNION 설명
create table R1(
    A varchar(20) not null,
    B varchar(20) not null
);
create table R2(
    A varchar(20) not null,
    B varchar(20) not null
);
create table R3(
    A varchar(20) not null,
    B varchar(20) not null
);
insert into R1 (A, B)
     VALUES ('1', 'a');
insert into R1 (A, B)
     VALUES ('2', 'b');     
insert into R1 (A, B)
     VALUES ('3', 'c');
insert into R2 (A, B)
     VALUES ('2', 'b');
insert into R2 (A, B)
     VALUES ('4', 'd');
insert into R3 (A, B)
     VALUES ('3', 'c');     
insert into R3 (A, B)
     VALUES ('5', 'e');
insert into R3 (A, B)
     VALUES ('1', 'a');
     
-- UNION : 중복 자동 제거
select A,B from R1
UNION
select A,B from R2
UNION
select A,B from R3;

-- union all : 중복포함 (더 빠름)
SELECT A, B FROM R1
UNION ALL
SELECT A, B FROM R2
UNION ALL
SELECT A, B FROM R3;


-- 문제 10 - 1) 주문한 적 있는 고객 조회
select c.name 
from customer c
where EXISTS(
select 1
from orders o
where o.custid = c.custid
);

-- 문제 17)
create table Cust_addr(
	custid int,
	addrid int,
	address varchar2(30),
	phone varchar2(30),
	changedate date,
CONSTRAINT fk FOREIGN KEY (custid) REFERENCES Customer(custid)
);

DELETE FROM book where bookid= 11;

INSERT INTO Book VALUES(11, '데이터베이스 개론', '한빛미디어', 20000);
INSERT INTO Book VALUES(12, '자바의 정석', '길벗', 32000);
INSERT INTO Book VALUES(13, '파이썬 머신러닝', '위키북스', 25000);
INSERT INTO Book VALUES(14, '운영체제 관리', '한빛미디어', 30000);
INSERT INTO Book VALUES(15, '알고리즘 문제 풀기', '길벗', 22000);
INSERT INTO Book VALUES(16, '클린 코드', '인사이트', 33000);
INSERT INTO Book VALUES(17, 'SQL 첫걸음', '한빛미디어', 24000);

INSERT INTO Customer VALUES (6, '박지수', '서울 마포구 합정동', '010-1234-5678');
INSERT INTO Customer VALUES (7, '김도윤', '경기 성남시 분당구', '010-2345-6789');
INSERT INTO Customer VALUES (8, '이서연', '서울 강남구 역삼동', '010-3456-7890');
INSERT INTO Customer VALUES (9, '최민준', '인천 부평구 부평동', '010-4567-8901');
INSERT INTO Customer VALUES (10, '정하은', '서울 송파구 잠실동', '010-5678-9012');

INSERT INTO Cust_addr VALUES (6, 1, '서울 은평구 불광동','010-1234-5678' ,TO_DATE('2024-03-10','yyyy-mm-dd'));
INSERT INTO Cust_addr VALUES (6, 2, '서울 마포구 합정동','010-1234-5678' ,TO_DATE('2025-07-20','yyyy-mm-dd'));
INSERT INTO Cust_addr VALUES (7, 1, '경기 수원시 팔달구','010-2345-6789' ,TO_DATE('2023-11-05','yyyy-mm-dd'));
INSERT INTO Cust_addr VALUES (7, 2, '경기 성남시 분당구','010-9999-0000' ,TO_DATE('2025-02-14','yyyy-mm-dd'));
INSERT INTO Cust_addr VALUES (8, 1, '서울 강남구 역삼동','010-3456-7890' ,TO_DATE('2025-05-01','yyyy-mm-dd'));
INSERT INTO Cust_addr VALUES (9, 1, '부산 해운대구 우동','010-4567-8901' ,TO_DATE('2024-08-22','yyyy-mm-dd'));

insert into orders values (11, 6, 11, 28000, to_date('2026-01-05', 'yyyy-mm-dd'));
insert into orders values (12, 6, 13, 23000, to_date('2026-01-08', 'yyyy-mm-dd'));
insert into orders values (13, 7, 12, 32000, to_date('2026-01-10', 'yyyy-mm-dd'));
insert into orders values (14, 7, 15, 20000, to_date('2026-01-12', 'yyyy-mm-dd'));
insert into orders values (15, 8, 14, 30000, to_date('2026-01-15', 'yyyy-mm-dd'));
insert into orders values (16, 8, 16, 31000, to_date('2026-01-15', 'yyyy-mm-dd'));
insert into orders values (17, 9, 17, 22000, to_date('2026-01-18', 'yyyy-mm-dd'));
insert into orders values (18, 10, 11, 26000, to_date('2026-01-20', 'yyyy-mm-dd'));
insert into orders values (19, 10, 12, 32000, to_date('2026-01-22', 'yyyy-mm-dd'));
insert into orders values (20, 6, 16, 33000, to_date('2026-01-25', 'yyyy-mm-dd'));


-- 1) 고객번호 1번의 주소 변경 내역을 모두 조회하시오
select cd.address 
from cust_addr cd 
join customer c
  on cd.custid = c.custid
where cd.custid = 6;

commit;

-- 2) 고객번호 1번의 전화번호 변경 내역을 모두 조회하시오
select cd.phone
 from cust_addr cd
 join customer c
   on cd.custid = c.custid
where cd.custid = 6;

-- 3) 고객번호 1번의 가입 당시 전화번호를 조회하시오
select phone
  from cust_addr
 where custid=6
   and changedate = (
   select min(changedate) 
   from cust_addr 
   where custid=6
);
-- 4) 고객번호 1번의 '2025 01 01' 당시 전화번호를 보이시오 주소 이력 중 changeday 속성값이 '2025 01' 보다 오래된 첫 번째 값을 찾는다.
select phone
  from cust_addr
 where custid=6
   and changedate < to_date('2025-01-01', 'yyyy-mm-dd');
   

-- 문제 18   
create table Cart(  
    cartid number PRIMARY KEY,
    custid number,
    bookid number,
    cartdate date,
    CONSTRAINT fk_custid FOREIGN KEY (custid) REFERENCES Customer(custid),
    CONSTRAINT fk_bookid FOREIGN KEY (bookid) REFERENCES Book(bookid)
);

-- custid 1~5, bookid 1~7과 연계
INSERT INTO Cart VALUES (1,  6, 11, TO_DATE('2025/01/05', 'YYYY/MM/DD'));
INSERT INTO Cart VALUES (2,  6, 13, TO_DATE('2025/01/10', 'YYYY/MM/DD'));
INSERT INTO Cart VALUES (3,  2, 2, TO_DATE('2025/02/03', 'YYYY/MM/DD'));
INSERT INTO Cart VALUES (4,  2, 5, TO_DATE('2025/02/15', 'YYYY/MM/DD'));
INSERT INTO Cart VALUES (5,  3, 4, TO_DATE('2025/03/07', 'YYYY/MM/DD'));
INSERT INTO Cart VALUES (6,  3, 7, TO_DATE('2025/03/20', 'YYYY/MM/DD'));
INSERT INTO Cart VALUES (7,  4, 6, TO_DATE('2025/04/01', 'YYYY/MM/DD'));
INSERT INTO Cart VALUES (8,  4, 1, TO_DATE('2025/04/18', 'YYYY/MM/DD'));
INSERT INTO Cart VALUES (9,  5, 3, TO_DATE('2025/05/09', 'YYYY/MM/DD'));
INSERT INTO Cart VALUES (10, 5, 7, TO_DATE('2025/05/22', 'YYYY/MM/DD'));

drop table Cart;

-- 고객 6~10번, 도서 11~17번 연동 완료
INSERT INTO Cart VALUES (1,  6, 11, TO_DATE('2025/01/05', 'YYYY/MM/DD'));
INSERT INTO Cart VALUES (2,  6, 13, TO_DATE('2025/01/10', 'YYYY/MM/DD'));
INSERT INTO Cart VALUES (3,  7, 12, TO_DATE('2025/02/03', 'YYYY/MM/DD'));
INSERT INTO Cart VALUES (4,  7, 15, TO_DATE('2025/02/15', 'YYYY/MM/DD'));
INSERT INTO Cart VALUES (5,  8, 14, TO_DATE('2025/03/07', 'YYYY/MM/DD'));
INSERT INTO Cart VALUES (6,  8, 17, TO_DATE('2025/03/20', 'YYYY/MM/DD'));
INSERT INTO Cart VALUES (7,  9, 16, TO_DATE('2025/04/01', 'YYYY/MM/DD'));
INSERT INTO Cart VALUES (8,  9, 11, TO_DATE('2025/04/18', 'YYYY/MM/DD'));
INSERT INTO Cart VALUES (9,  10, 13, TO_DATE('2025/05/09', 'YYYY/MM/DD'));
INSERT INTO Cart VALUES (10, 10, 17, TO_DATE('2025/05/22', 'YYYY/MM/DD'));

commit;
-- 1) 고객번호 1번(6)의 cart에 저장된 도서 중 이미 주문한 도서를 구하시오
SELECT bookname
  FROM Book
 WHERE bookid IN (SELECT bookid FROM Cart WHERE custid = 6)  
   AND bookid IN (SELECT bookid FROM Orders WHERE custid = 6);

-- 2) 고객번호 1번의 cart에 저장된 도서 중 아직 주문하지 않은 도서를 구하시오
select b.bookname
  from book b
  join cart c on b.bookid  = c.bookid
 where not EXISTS(
 select 1
 from orders o
 where o.bookid = c.bookid
   and c.custid = 6
 );
 
-- 3) 고객번호 1번의 cart에 저장된 도서들의 정가 합계를 구하시오.
select sum(b.price) as "정가 합계"
from book b
join cart c on c.bookid = b.bookid
where c.custid = 6;

Drop table emp;
drop table dept;

-- 문제 19) Emp, Dept 테이블 구성된 회사사원 데이터베이스를 만들고자 한다. 테이블을 생성하고 데이터를 입력하는 SQL 질의를 작성하시오
-- 부서(department)에 관한 dept 테이블 
CREATE table Dept(
    deptno number(2) not null PRIMARY KEY,
    dname varchar2(14),
    loc varchar2(13)
);
commit;
-- 직원(emp)에 관한 emp 테이블
create table Emp(
    empno number(4) not null PRIMARY KEY,
    ename varchar2(10),
    job varchar2(9),
    mgr number(4),
    hiredate DATE,
    sal number(7,2),
    comm number(7,2),
    deptno number(2),
    CONSTRAINT fk_deptno FOREIGN KEY (deptno) REFERENCES Dept(deptno)
);

-- 3 부서에 관한 다음 네 개의 데이터를 삽입하시오.
INSERT INTO Dept VALUES (10, 'ACCOUNTING', 'NEW YORK');
INSERT INTO Dept VALUES (20, 'RESEARCH', 'DALLAS');
INSERT INTO Dept VALUES (30, 'SALES', 'NEW YORK');
INSERT INTO Dept VALUES (40, 'OPERATION', 'BOSTON');

-- 4 사원에 관한 네 개의 데이터를 삽입하시오
INSERT INTO emp VALUES (7369, 'SMITH', 'CLERK', 7902, TO_DATE('1980-12-17', 'YYYY-MM-DD'), 800, NULL, 20);
INSERT INTO emp VALUES (7499, 'ALLEN', 'SALEMEN', 7698, TO_DATE('1981-02-20', 'YYYY-MM-DD'), 1600, 300, 30);
INSERT INTO emp VALUES (7521, 'WARD', 'SALEMEN', 7698, TO_DATE('1981-02-22', 'YYYY-MM-DD'), 1250, 500, 30);
INSERT INTO emp VALUES (7566, 'JONES', 'MANAGER', 7839, TO_DATE('1981-04-02', 'YYYY-MM-DD'), 2975, NULL, 20);

-- 5 사원 테이블에 다음 데이터를 삽입하려고 하니 오류가 발생하였다. 오류 메시지를 확인해 보고 원인을 찾아보시오
--INSERT INTO Emp (empno,ename, job,mgr, hiredate,sal,comm,deptno ) values 
--(7654,'MARTIN', 'SALESMAN', 7698, to_date('1981-09-28', 'yyyy-mm-dd'), 1250,1400,50);
-- dept 테이블내에는 50이라는 데이터가 없음

-- 서브 질의
-- 6 각 사원의 사원이름(ename) 과 소속 부서이름(dname), 부서워치(loc)를 함께 조회하시오

select e.ename, d.dname, d.loc
from emp e
join dept d on d.deptno = e.deptno;


-- 7 부서가 배정된 사원의 사원번호(empno), 사원이름(ename), 부서이름(dname)을 조회하시오. 부서가 없는 사원은 제외한다.
select e.empno, e.ename, d.dname
from emp e
join dept d on d.deptno = e.deptno;

-- 8 부서위치가 DALLAS인 부서에 소속된 모든 사원의 이름, 업무, 월급여를 조회하시오
select e.ename, e.job, e.sal
from emp e
join dept d on d.deptno = e.deptno
where d.loc = 'DALLAS';

-- 9)부서 위치(loc)가 'DALLAS'인 부서에 소속된 사원의 이름(ename), 업무(job)를 조회하시오. 서브쿼리를 사용할 것.
select e.ename, e.job
  from emp e
 where e.deptno = (
  select d.deptno
    from dept d
   where d.loc = 'DALLAS'
);

-- 10) 전체 사원의 평균 급여보다 급여가 높은 사원의 이름과 급여를 조회하시오.
select ename, sal 
from emp
where sal > (select avg(sal) from emp);

-- 11) 각 사원의 이름과 그 사원의 직속상사 이름을 함께 조회하시오 상사가 없는 사원도 포함
select a.ename as "사원명" , b.ename as "상사명"
from emp a
left outer join emp b on a.mgr = b.empno;

-- 12) 각 부서에서 급여가 가장 높은 사원의 이름, 급여, 부서이름을 조회하시오. 조인, 서브쿼리를 함께 사용할 것
select e.ename, e.sal, d.dname
from emp e
join dept d on d.deptno = e.deptno
where (e.deptno, e.sal) In (
    select deptno, max(sal)
    from emp
    group by deptno
);

-- 13) 부서 테이블의 구조를 변경하여 부서장의 이름을 저장하는 manager속성을 추가하고자 한다. ALTER 문을 사용하여 작성해 보시오. managername 속성이 만들어졌으면 UPDATE문을 이용하여 MANAGER의 이름을 입력하시오.
ALTER TABLE Dept ADD (managername VARCHAR2(10));

UPDATE Dept 
SET managername = 'JONES' 
WHERE deptno = 20;


-- 문제 20 극장DB
DROP TABLE 극장 CASCADE CONSTRAINTS;
drop table 상영관 CASCADE CONSTRAINTS;
TRUNCATE table 극장;
TRUNCATE table 상영관;
TRUNCATE table 예약;
TRUNCATE table 고객;

CREATE TABLE 극장 (
    극장번호 INT PRIMARY KEY,
    극장이름 VARCHAR(20),
    위치 VARCHAR(20)
);
CREATE TABLE 상영관 (
    극장번호 INT,
    상영관번호 INT,
    영화제목 VARCHAR(50),
    가격 INT,
    좌석수 INT,
    -- 제약조건 1: 영화가격은 20,000원을 넘지 않아야 한다.
    CONSTRAINT chk_price CHECK (가격 <= 20000),
    -- 제약조건 2: 상영관번호는 1~10사이다.
    CONSTRAINT chk_room_no CHECK (상영관번호 BETWEEN 1 AND 10),
    PRIMARY KEY (극장번호, 상영관번호, 영화제목),
    FOREIGN KEY (극장번호) REFERENCES 극장(극장번호)
);

drop table 예약;
CREATE TABLE 예약 (
    극장번호 INT,
    상영관번호 INT,
    고객번호 INT,
    좌석번호 INT,
    날짜 DATE,
    -- 제약조건 3: 같은 사람이 같은 좌석번호를 두 번 예약하지 않아야 한다.
    -- (동일 날짜에 동일 좌석 중복 예약 방지)
    UNIQUE (고객번호, 극장번호, 상영관번호, 좌석번호, 날짜),
    FOREIGN KEY (고객번호) REFERENCES 고객(고객번호),
    FOREIGN KEY (극장번호) REFERENCES 극장(극장번호)
);




-- 극장 데이터
INSERT INTO 극장 VALUES (1, '롯데', '잠실');
INSERT INTO 극장 VALUES (2, '메가', '강남');
INSERT INTO 극장 VALUES (3, '대한', '잠실');

-- 상영관 데이터
INSERT INTO 상영관 VALUES (1, 1, '어려운 영화', 15000, 48);
INSERT INTO 상영관 VALUES (1, 1, '멋진 영화', 7500, 120);
INSERT INTO 상영관 VALUES (3, 2, '재밌는 영화', 8000, 110);

-- 고객 데이터
INSERT INTO 고객 VALUES (3, '홍길동', '강남');
INSERT INTO 고객 VALUES (4, '김철수', '잠실');
INSERT INTO 고객 VALUES (9, '박영희', '강남');

-- 예약 데이터 (날짜 형식은 YYYY-MM-DD 기준)
INSERT INTO 예약 VALUES (3, 2, 3, 15, '2025-09-01');
INSERT INTO 예약 VALUES (3, 1, 4, 16, '2025-09-01');
INSERT INTO 예약 VALUES (1, 1, 9, 48, '2025-09-01');


--단순질의
-- 1 모든 극장의 이름과 위치를 보이시오
select 극장이름, 위치
from 극장;

-- 2 '잠실'에 있는 극장을 보이시오
select *
from 극장
where 위치 = '잠실';

-- 3 '잠실'에 사는 고객의 이름을 오름차순으로 보이시오
SELECT * FROM 고객 
WHERE 주소 = '잠실' 
ORDER BY 고객번호 ASC;

-- 4 가격이 8000원 이하인 영화의 극장번호, 영화제목을 보이시오
select 극장번호, 영화제목
from 상영관
where 가격 <= 8000;

-- 5 극장 위치와 고객의 주소가 같은 고객을 보이시오
select * from 고객 
join 극장 on 극장.위치 = 고객.주소;

-- 집계질의
-- 1 극장의 수는 몇개인가?
select count(*) as "총극장 수"
from 극장;
-- 2 상영되는 영화의 평균 가격은 얼마인가?
select round(avg(가격)) as "평균가격"
from 상영관;
-- 3 2025년 9월 1일 에 영화를 관람한 고객의 수는 얼마인가?
select count(*) as "총 관람수"
from 예약
where 날짜 = '2025-09-01';

--부속질의, 조인
-- 1 대한 극장에서 상영된 영화 제목을 보이시오\
select 상영관.영화제목
from 상영관
join 극장 on 극장.극장번호 = 상영관.극장번호
where 극장.극장이름 = '대한';

-- 2 대한극장에서 영화를 본 고객의 이름을 보이시오
select 고객.이름
from 고객
join 예약 on 예약.고객번호 = 고객.고객번호
join 극장 on 극장.극장번호 = 예약.극장번호
where 극장.극장이름 = '대한';

-- 3 대한극장의 전체 수입을 보이시오
select sum(가격) as "전체수입"
from 상영관
join 극장 on 극장.극장번호 = 상영관.극장번호
where 극장.극장이름 = '대한';

-- 그룹질의
-- 1 극장별 상영관 수를 보이시오
SELECT 극장번호, COUNT(*) AS 상영관수
FROM 상영관
GROUP BY 극장번호;

-- 2 잠실에 있는 극장의 상영관을 보이시오
SELECT 상영관.*
FROM 극장 JOIN 상영관 ON 극장.극장번호 = 상영관.극장번호
WHERE 극장.위치 = '잠실';


-- 25년 9월 1일의 극장별 평균 관람 고객 수 를 보이시오
SELECT 극장번호, AVG(고객수) AS 평균고객수
FROM (
    -- 상영관별로 관람객 수를 먼저 계산
    SELECT 극장번호, 상영관번호, COUNT(*) AS 고객수
    FROM 예약
    WHERE 날짜 = '2025-09-01'
    GROUP BY 극장번호, 상영관번호
)
GROUP BY 극장번호;

-- 25년 9월 1일에 가장 많은 고객이 관람한 영화를 보이시오
SELECT * FROM (
    SELECT S.영화제목, COUNT(*) AS 관람객수
    FROM 예약 R
    JOIN 상영관 S ON R.극장번호 = S.극장번호 AND R.상영관번호 = S.상영관번호
    WHERE R.날짜 = '2025-09-01'
    GROUP BY S.영화제목
    ORDER BY 관람객수 DESC
)
WHERE ROWNUM = 1;


-- 1. 극장: 새로운 극장 'CGV' 추가
INSERT INTO 극장 (극장번호, 극장이름, 위치) 
VALUES (4, 'CGV', '판교');

-- 2. 상영관: 4번 극장에 새로운 영화 등록
INSERT INTO 상영관 (극장번호, 상영관번호, 영화제목, 가격, 좌석수) 
VALUES (4, 1, '파묘', 12000, 150);

-- 3. 고객: 새로운 고객 '이순신' 추가
INSERT INTO 고객 (고객번호, 이름, 주소) 
VALUES (10, '이순신', '서울');

-- 4. 예약: 이순신 고객이 CGV에서 영화 예약 (날짜 형식 주의)
INSERT INTO 예약 (극장번호, 상영관번호, 고객번호, 좌석번호, 날짜) 
VALUES (4, 1, 10, 55, TO_DATE('2026-04-02', 'YYYY-MM-DD'));

-- 가격 10% 인상
UPDATE 상영관
SET 가격 = 가격 * 1.1;


drop table Salesperson;
drop table Cust;
-- 문제 21 
-- 1. Salesperson 테이블 생성 (기본키 설정 확인)
CREATE TABLE Salesperson (
    name   VARCHAR2(50) PRIMARY KEY, -- 이 name이 PK여야 Order에서 참조 가능
    age    NUMBER,
    salary NUMBER
);

-- 2. Customer 테이블 생성 (기본키 설정 확인)
CREATE TABLE Customers (
    name         VARCHAR2(50) PRIMARY KEY, -- 이 name이 PK여야 Order에서 참조 가능
    city         VARCHAR2(50),
    industrytype VARCHAR2(50)
);

-- 3. Order 테이블 생성 (REFERENCES 대상 확인)
CREATE TABLE "Order" (
    num          NUMBER PRIMARY KEY,
    custname     VARCHAR2(50),
    salesperson  VARCHAR2(50),
    amount       NUMBER,
    -- REFERENCES 대상을 Customers로 수정했습니다.
    CONSTRAINT fk_cust FOREIGN KEY (custname) REFERENCES Customers(name),
    CONSTRAINT fk_sales FOREIGN KEY (salesperson) REFERENCES Salesperson(name)
);


INSERT INTO Salesperson VALUES ('TOM', 28, 40000), ('ALICE', 35, 50000);
INSERT INTO Customers VALUES ('KIM', 'LA', 'IT'), ('LEE', 'PARIS', 'BANK');
INSERT INTO "Order" VALUES (1, 'KIM', 'TOM', 1000), (2, 'KIM', 'ALICE', 2000);

-- 2번
SELECT DISTINCT name, salary FROM Salesperson;

-- 3번
SELECT name FROM Salesperson WHERE age < 30;

-- 4번
SELECT name FROM Customer WHERE city LIKE '%S';

-- 5번
SELECT COUNT(DISTINCT custname) FROM "Order";

-- 6번
SELECT salesperson, COUNT(*) FROM "Order" GROUP BY salesperson;

-- 7번
SELECT name, age FROM Salesperson 
WHERE name IN (
    SELECT salesperson FROM "Order" 
    WHERE custname IN (SELECT name FROM Customer WHERE city = 'LA')
);
commit;

-- 8번
SELECT DISTINCT s.name, s.age 
FROM Salesperson s
JOIN "Order" o ON s.name = o.salesperson
JOIN Customer c ON o.custname = c.name
WHERE c.city = 'LA';

-- 9번
SELECT salesperson FROM "Order" 
GROUP BY salesperson 
HAVING COUNT(*) >= 2;

-- 10번
UPDATE Salesperson SET salary = 45000 WHERE name = 'TOM';


-- 문제 22
-- 1. Department 생성
CREATE TABLE Department (
    depno    NUMBER PRIMARY KEY,
    deptname VARCHAR2(50),
    manager  VARCHAR2(50)
);

-- 2. Employee 생성
CREATE TABLE Employee (
    empno    NUMBER PRIMARY KEY,
    name     VARCHAR2(50),
    phoneno  VARCHAR2(20),
    address  VARCHAR2(100),
    sex      CHAR(1),
    position VARCHAR2(50),
    depno    NUMBER,
    CONSTRAINT fk_emp_dept FOREIGN KEY (depno) REFERENCES Department(depno)
);

-- 3. Project 생성
CREATE TABLE Project (
    projno   NUMBER PRIMARY KEY,
    projname VARCHAR2(100),
    deptno   NUMBER,
    CONSTRAINT fk_proj_dept FOREIGN KEY (deptno) REFERENCES Department(depno)
);

-- 4. Works 생성 (복합키 설정)
CREATE TABLE Works (
    empno        NUMBER,
    projno       NUMBER,
    hours_worked NUMBER,
    PRIMARY KEY (empno, projno),
    CONSTRAINT fk_works_emp FOREIGN KEY (empno) REFERENCES Employee(empno),
    CONSTRAINT fk_works_proj FOREIGN KEY (projno) REFERENCES Project(projno)
);

-- 데이터 삽입 (예시)
INSERT INTO Department VALUES (10, 'IT', '홍길동');
INSERT INTO Employee VALUES (101, '김철수', '010-1111', '서울', 'M', '사원', 10);
INSERT INTO Project VALUES (1, 'AI개발', 10);
INSERT INTO Works VALUES (101, 1, 40);
COMMIT;
 
-- 2 모든 사원의 이름을 보이시오.
SELECT name FROM Employee;

-- 3 여자 사원의 이름을 보이시오
SELECT name FROM Employee WHERE sex = 'F'; -- 데이터가 'F' 또는 '여'로 저장된 경우에 맞춰 수정 가능

-- 4 팀장의 이름을 보이시오
SELECT DISTINCT manager FROM Department;

-- 5 'IT' 부서에서 일하는 사원의 이름과 주소를 보이시오
SELECT e.name, e.address 
FROM Employee e 
JOIN Department d ON e.depno = d.depno 
WHERE d.deptname = 'IT';

-- 6 홍길동 팀장 부서에서 일하는 사원의 수를 보이시오
SELECT COUNT(*) 
FROM Employee e 
JOIN Department d ON e.depno = d.depno 
WHERE d.manager = '홍길동';

-- 7 사원들이 일한 시간 수를 부서별 사원 이름별 오름차순으로 보이시오
SELECT d.deptname, e.name, SUM(w.hours_worked) AS total_hours
FROM Employee e
JOIN Department d ON e.depno = d.depno
JOIN Works w ON e.empno = w.empno
GROUP BY d.deptname, e.name
ORDER BY d.deptname ASC, e.name ASC;

-- 8 2명이상의 사원이 참여한 프로젝트의 번호 이름 사원의 수를 보이시오
SELECT p.projno, p.projname, COUNT(w.empno) AS emp_count
FROM Project p
JOIN Works w ON p.projno = w.projno
GROUP BY p.projno, p.projname
HAVING COUNT(w.empno) >= 2;

-- 9 3명이상의 사원이 있는 부서의 사원 이름을 보이시오
SELECT name 
FROM Employee 
WHERE depno IN (
    SELECT depno 
    FROM Employee 
    GROUP BY depno 
    HAVING COUNT(*) >= 3
);