-- (1)
-- 학생 수강 전체 현황 뷰를 작성하시오. (학생정보+수강 과목+성적을 한 분에 확인가능하도록 작성) 
CREATE VIEW v_student_enroll_status AS
SELECT s.학번, s.이름, s.전공, s.학년, c.과목이름, e.성적
FROM 학생 s, 수강 e, 과목 c
WHERE s.학번 = e.학번 AND e.과목코드 = c.과목코드;

-- (2)
-- 각 학생별 평균 성적 뷰를 작성하시오. (각 학생의 전체 수강 과목 평균 성적 계산 뷰) 
CREATE VIEW v_student_avg_grade AS
SELECT 학번, AVG(성적) AS 평균성적
FROM 수강
GROUP BY 학번;

-- (3)
-- 과목별 수강 인원 및 평균 성적 뷰를 작성하시오. (각 과목의 수강 인원과 평균, 최고, 최저 성적 통계 뷰) 
CREATE VIEW v_course_stats AS
SELECT 과목코드, COUNT(학번) AS 수강인원, AVG(성적) AS 평균성적, MAX(성적) AS 최고성적, MIN(성적) AS 최저성적
FROM 수강
GROUP BY 과목코드;

-- (4)
-- 성적 우수 학생 뷰를 작성하시오. (평균 90점 이상) 
CREATE VIEW v_excellent_students AS
SELECT 학번, AVG(성적) AS 평균성적
FROM 수강
GROUP BY 학번
HAVING AVG(성적) >= 90;

-- (5)
-- 전공 별 수강 통계 뷰를 작성하시오. (전공별 총 수강 건수와 전공 평균 성적 비교 뷰) 
CREATE VIEW v_major_stats AS
SELECT s.전공, COUNT(e.학번) AS 총수강건수, AVG(e.성적) AS 전공평균성적
FROM 학생 s, 수강 e
WHERE s.학번 = e.학번
GROUP BY s.전공;

-- (6)
-- 학기별 수강 현황 뷰를 작성하시오. 
CREATE VIEW v_semester_status AS
SELECT 수강학기, COUNT(학번) AS 수강학생수
FROM 수강
GROUP BY 수강학기;

-- (7)
-- 미수강 학생 뷰를 작성하시오. 
CREATE VIEW v_unregistered_students AS
SELECT 학번, 이름
FROM 학생
WHERE 학번 NOT IN (SELECT 학번 FROM 수강);

-- (8)
-- 담당 교수별 강의 및 수강 현황 뷰를 작성하시오. (과목별 담당 과목 수와 총 수강 학생수를 집계하는 뷰) 
CREATE VIEW v_professor_status AS
SELECT c.담당교수, COUNT(DISTINCT c.과목코드) AS 담당과목수, COUNT(e.학번) AS 총수강학생수
FROM 과목 c, 수강 e
WHERE c.과목코드 = e.과목코드
GROUP BY c.담당교수;

-- (9)
-- 학년별 수강 과목 수 및 평균 성적 뷰를 작성하시오. 
CREATE VIEW v_grade_year_stats AS
SELECT s.학년, COUNT(e.과목코드) AS 수강과목수, AVG(e.성적) AS 평균성적
FROM 학생 s, 수강 e
WHERE s.학번 = e.학번
GROUP BY s.학년;

-- (10)
-- 성적 미입력(NULL) 수강 내역 뷰를 작성하시오. 
CREATE VIEW v_null_grade_list AS
SELECT *
FROM 수강
WHERE 성적 IS NULL;

--2. 극장 데이터베이스 

-- 1.
-- 전체 상영 정보 통합 뷰를 작성하시오. (극장 + 상영관 + 영화 정보를 한눈에 확인 가능하도록 작성) 
CREATE VIEW v_total_cinema_info AS
SELECT t.극장이름, t.위치, s.상영관번호, s.영화제목, s.가격
FROM 극장 t, 상영관 s
WHERE t.극장번호 = s.극장번호;

-- 2.
-- 예약 전체 현황 뷰를 작성하시오 (고객이 어떤 극장·상영관·영화를 예약했는지 통합 조회하도록 작성) 
CREATE VIEW v_total_reservation_status AS
SELECT c.이름, t.극장이름, s.상영관번호, s.영화제목, r.날짜
FROM 고객 c, 예약 r, 극장 t, 상영관 s
WHERE c.고객번호 = r.고객번호 AND r.극장번호 = t.극장번호 AND r.상영관번호 = s.상영관번호 AND t.극장번호 = s.극장번호;

-- 3.
-- 극장별 상영 영화 목록 뷰를 작성하시오 (각 극장에서 상영 중인 영화와 가격, 좌석수 조회) 
CREATE VIEW v_theater_movies AS
SELECT t.극장이름, s.영화제목, s.가격, s.좌석수
FROM 극장 t, 상영관 s
WHERE t.극장번호 = s.극장번호;

-- 4.
-- 고객별 예약 내역 뷰를 작성하시오 (고객별 예약한 영화 목록과 날짜, 금액 조회가능한 뷰) 
CREATE VIEW v_customer_reservations AS
SELECT c.이름, s.영화제목, r.날짜, s.가격
FROM 고객 c, 예약 r, 상영관 s
WHERE c.고객번호 = r.고객번호 AND r.극장번호 = s.극장번호 AND r.상영관번호 = s.상영관번호;

-- 5.
-- 상영관별 예약 인원 및 잔여 좌석 뷰를 작성하시오 (상영관의 총 좌석 대비 예약 현황과 잔여 좌석 계산) 
CREATE VIEW v_seat_status AS
SELECT s.극장번호, s.상영관번호, s.좌석수, COUNT(r.고객번호) AS 예약인원, (s.좌석수 - COUNT(r.고객번호)) AS 잔여좌석
FROM 상영관 s LEFT JOIN 예약 r ON s.극장번호 = r.극장번호 AND s.상영관번호 = r.상영관번호
GROUP BY s.극장번호, s.상영관번호, s.좌석수;

-- 6.
-- 극장별 총 예약 수 및 매출 뷰를 작성하시오 (극장별 총 예약 건수와 누적 매출 집계를 볼 수 있는 뷰) 
CREATE VIEW v_theater_sales AS
SELECT t.극장이름, COUNT(r.고객번호) AS 총예약수, SUM(s.가격) AS 총매출
FROM 극장 t, 예약 r, 상영관 s
WHERE t.극장번호 = r.극장번호 AND r.극장번호 = s.극장번호 AND r.상영관번호 = s.상영관번호
GROUP BY t.극장이름;

-- 7.
-- 영화별 예약 현황 뷰를 작성하시오 (영화 제목별 총 예약 인원과 총 매출 집계 뷰) 
CREATE VIEW v_movie_sales AS
SELECT s.영화제목, COUNT(r.고객번호) AS 총예약인원, SUM(s.가격) AS 총매출
FROM 상영관 s, 예약 r
WHERE s.극장번호 = r.극장번호 AND s.상영관번호 = r.상영관번호
GROUP BY s.영화제목;

-- 8.
-- 날짜별 예약 현황 뷰를 작성하시오 (날짜별 예약 건수와 해당 날짜 매출 조회 가능한 뷰 작성) 
CREATE VIEW v_daily_sales AS
SELECT r.날짜, COUNT(r.고객번호) AS 예약건수, SUM(s.가격) AS 일매출
FROM 예약 r, 상영관 s
WHERE r.극장번호 = s.극장번호 AND r.상영관번호 = s.상영관번호
GROUP BY r.날짜;

-- 9.
-- 예약 이력이 없는 고객 뷰 (한 번도 예약한 적 없는 고객 조회하는 뷰 작성) 
CREATE VIEW v_no_reservation_customers AS
SELECT * FROM 고객 WHERE 고객번호 NOT IN (SELECT 고객번호 FROM 예약);

-- 10.
-- 고객별 총 예약 횟수 및 결제 금액 뷰 (고객의 예약 활동 통계) 
CREATE VIEW v_customer_stats AS
SELECT c.이름, COUNT(r.고객번호) AS 예약횟수, SUM(s.가격) AS 총결제금액
FROM 고객 c, 예약 r, 상영관 s
WHERE c.고객번호 = r.고객번호 AND r.극장번호 = s.극장번호 AND r.상영관번호 = s.상영관번호
GROUP BY c.이름;

-- 11.
-- 가격이 가장 비싼 상영관 뷰를 작성하시오 (티켓 가격 기준 상위 상영관 목록 조회하는 뷰 작성) 
CREATE VIEW v_expensive_screens AS
SELECT * FROM 상영관 WHERE 가격 = (SELECT MAX(가격) FROM 상영관);

-- 12.
-- 위치별 극장 및 상영 현황 뷰 (지역(위치)별로 운영 중인 극장과 상영 영화 수 집계하는 뷰 작성) 
CREATE VIEW v_location_status AS
SELECT t.위치, COUNT(DISTINCT t.극장번호) AS 극장수, COUNT(s.영화제목) AS 상영영화수
FROM 극장 t, 상영관 s
WHERE t.극장번호 = s.극장번호
GROUP BY t.위치;

-- 13.
-- 만석 상영관 뷰를 작성하시오 (예약 좌석 수가 전체 좌석 수와 동일한 매진 상영관 조회) 
CREATE VIEW v_full_screens AS
SELECT s.극장번호, s.상영관번호, s.영화제목
FROM 상영관 s, 예약 r
WHERE s.극장번호 = r.극장번호 AND s.상영관번호 = r.상영관번호
GROUP BY s.극장번호, s.상영관번호, s.영화제목, s.좌석수
HAVING COUNT(r.고객번호) = s.좌석수;

-- 14.
-- 특정 날짜 예약 고객 상세 뷰를 작성하시오 (날짜별 예약 고객 정보와 관람 영화 상세 조회) 
CREATE VIEW v_daily_reservation_detail AS
SELECT r.날짜, c.이름, s.영화제목, t.극장이름
FROM 예약 r, 고객 c, 상영관 s, 극장 t
WHERE r.고객번호 = c.고객번호 AND r.극장번호 = s.극장번호 AND r.상영관번호 = s.상영관번호 AND s.극장번호 = t.극장번호;

-- 15.
-- 예약 없는 상영관 뷰 (개설되었지만 예약이 한 건도 없는 상영관 조회) 
CREATE VIEW v_empty_screens AS
SELECT * FROM 상영관 s
WHERE NOT EXISTS (SELECT 1 FROM 예약 r WHERE s.극장번호 = r.극장번호 AND s.상영관번호 = r.상영관번호);

--3. 판매원 데이터베이스 

-- 1.
-- 전체 주문 통합 현황 뷰를 작성하시오 (주문 + 고객 + 영업사원 정보를 한눈에 통합 조회 뷰) 
CREATE VIEW v_order_total_info AS
SELECT o.number, o.amount, c.name AS cust_name, s.name AS sales_name
FROM "Order" o, Customer c, Salesperson s
WHERE o.custname = c.name AND o.salesperson = s.name;

-- 2.
-- 영업사원별 총 주문 금액 및 건수 뷰를 작성하시오 (영업사원별 실적 집계) 
CREATE VIEW v_salesperson_perf AS
SELECT salesperson, COUNT(number) AS order_count, SUM(amount) AS total_sales
FROM "Order"
GROUP BY salesperson;

-- 3.
-- 고객별 총 주문 금액 뷰를 작성하시오 (고객별 누적 주문 횟수와 총 구매 금액 집계 포함된 뷰) 
CREATE VIEW v_customer_order_summary AS
SELECT custname, COUNT(number) AS order_count, SUM(amount) AS total_amount
FROM "Order"
GROUP BY custname;

-- 4.
-- 도시별 주문 현황 뷰를 작성하시오 (도시(city)별 총 주문 건수와 매출 집계 포함된 뷰) 
CREATE VIEW v_city_order_stats AS
SELECT c.city, COUNT(o.number) AS order_count, SUM(o.amount) AS total_sales
FROM Customer c, "Order" o
WHERE c.name = o.custname
GROUP BY c.city;

-- 5.
-- 업종별 주문 통계 뷰를 작성하시오 (산업 유형(industrytype)별 주문 건수 및 총 매출 비교 뷰) 
CREATE VIEW v_industry_stats AS
SELECT c.industrytype, COUNT(o.number) AS order_count, SUM(o.amount) AS total_sales
FROM Customer c, "Order" o
WHERE c.name = o.custname
GROUP BY c.industrytype;

-- 6.
-- 고액 주문 뷰 (amount 상위)를 작성하시오 (주문 금액이 평균 이상인 고액 주문만 조회하는 뷰) 
CREATE VIEW v_high_amount_orders AS
SELECT * FROM "Order" WHERE amount > (SELECT AVG(amount) FROM "Order");

-- 7.
-- 주문 실적 없는 영업사원 뷰를 작성하시오 (한 건도 주문을 처리하지 않은 영업사원 조회 뷰) 
CREATE VIEW v_no_order_salesperson AS
SELECT * FROM Salesperson WHERE name NOT IN (SELECT salesperson FROM "Order");

-- 8.
-- 주문 이력 없는 고객 뷰를 작성하시오 (등록은 되어 있지만 한 번도 주문하지 않은 고객 조회 뷰) 
CREATE VIEW v_no_order_customer AS
SELECT * FROM Customer WHERE name NOT IN (SELECT custname FROM "Order");

-- 9.
-- 영업사원 급여 등급 뷰를 작성하시오 (급여 구간별로 영업사원을 분류하는 뷰) 
CREATE VIEW v_salary_grade AS
SELECT name, salary,
CASE WHEN salary >= 5000 THEN 'A'
WHEN salary >= 3000 THEN 'B'
ELSE 'C' END AS grade
FROM Salesperson;

-- 10.
-- 영업사원별 담당 고객 목록 뷰를 작성하시오 (각 영업사원이 주문을 처리한 고객 목록(중복 제거) 생성 뷰) 
CREATE VIEW v_sales_assigned_customers AS
SELECT DISTINCT salesperson, custname
FROM "Order";

-- 11.
-- 최고 실적 영업사원 뷰를 작성하시오 (총 주문 금액이 가장 높은 영업사원 조회하는 뷰) 
CREATE VIEW v_top_salesperson AS
SELECT salesperson, SUM(amount) AS total_sales
FROM "Order"
GROUP BY salesperson
HAVING SUM(amount) = (SELECT MAX(SUM(amount)) FROM "Order" GROUP BY salesperson);

-- 12.
-- 도시별 영업사원 활동 현황 뷰를 작성하시오 (어느 도시의 고객에게 얼마나 판매했는지 영업사원 기준 집계 뷰) 
CREATE VIEW v_sales_city_activity AS
SELECT o.salesperson, c.city, SUM(o.amount) AS sales_amount
FROM "Order" o, Customer c
WHERE o.custname = c.name
GROUP BY o.salesperson, c.city;

-- 13.
-- 영업사원 급여 대비 매출 효율 뷰를 작성하시오 (영업사원 급여 대비 총 매출 비율로 효율성 측정 뷰) 
CREATE VIEW v_sales_efficiency AS
SELECT s.name, (SUM(o.amount) / s.salary) AS efficiency_ratio
FROM Salesperson s, "Order" o
WHERE s.name = o.salesperson
GROUP BY s.name, s.salary;

-- 14.
-- 업종별 담당 영업사원 현황 뷰를 작성하시오 (산업 유형별로 어떤 영업사원이 활동하는지 파악) 
CREATE VIEW v_industry_salesperson AS
SELECT DISTINCT c.industrytype, o.salesperson
FROM Customer c, "Order" o
WHERE c.name = o.custname;

-- 15.
-- 주문 금액 구간별 분류 뷰를 작성하시오 (주문을 금액 구간으로 나누어 분류 및 통계 제공 뷰) 
CREATE VIEW v_order_amount_range AS
SELECT number, amount,
CASE WHEN amount >= 1000 THEN 'High'
WHEN amount >= 500 THEN 'Mid'
ELSE 'Low' END AS range_type
FROM "Order";

--4. 여행사 데이터베이스 

-- 1.
-- 전체 예약 통합 현황 뷰를 작성하시오 (승객 + 여행사 + 항공편 정보를 한눈에 통합 조회 뷰) 
CREATE VIEW v_booking_total_info AS
SELECT p.pname, a.aname, f.fid, f.src, f.dest, b.fdate
FROM Passenger p, Agency a, Flight f, Booking b
WHERE p.pid = b.pid AND a.aid = b.aid AND f.fid = b.fid;

-- 2.
-- 승객별 예약 내역 뷰를 작성하시오 (각 승객이 예약한 항공편과 여행사 정보 조회 뷰) 
CREATE VIEW v_passenger_bookings AS
SELECT p.pname, f.fid, a.aname, b.fdate
FROM Passenger p, Booking b, Flight f, Agency a
WHERE p.pid = b.pid AND b.fid = f.fid AND b.aid = a.aid;

-- 3.
-- 여행사별 예약 건수 및 실적 뷰를 작성하시오 (각 여행사의 총 예약 건수와 취급 항공편 수 집계 뷰) 
CREATE VIEW v_agency_performance AS
SELECT a.aname, COUNT(b.pid) AS booking_count, COUNT(DISTINCT b.fid) AS flight_count
FROM Agency a, Booking b
WHERE a.aid = b.aid
GROUP BY a.aname;

-- 4.
-- 항공편별 예약 승객 수 뷰를 작성하시오 (각 항공편의 예약된 승객 수와 출발·도착지 조회 뷰) 
CREATE VIEW v_flight_passenger_count AS
SELECT f.fid, f.src, f.dest, COUNT(b.pid) AS passenger_count
FROM Flight f, Booking b
WHERE f.fid = b.fid
GROUP BY f.fid, f.src, f.dest;

-- 5.
-- 출발지 도착지별 노선 통계 뷰를 작성하시오 (노선별 운항 횟수와 총 예약 건수 집계 뷰) 
CREATE VIEW v_route_stats AS
SELECT f.src, f.dest, COUNT(DISTINCT f.fid) AS flight_freq, COUNT(b.pid) AS total_bookings
FROM Flight f LEFT JOIN Booking b ON f.fid = b.fid
GROUP BY f.src, f.dest;

-- 6.
-- 도시별 승객 예약 현황 뷰를 작성하시오 (승객 거주 도시별 총 예약 건수 및 이용 현황 집계 뷰) 
CREATE VIEW v_city_passenger_stats AS
SELECT p.pcity, COUNT(b.pid) AS total_bookings
FROM Passenger p, Booking b
WHERE p.pid = b.pid
GROUP BY p.pcity;

-- 7.
-- 성별 이용 통계 뷰를 작성하시오 (성별(pgender)에 따른 예약 건수와 이용 노선 수 비교 뷰) 
CREATE VIEW v_gender_usage_stats AS
SELECT p.pgender, COUNT(b.pid) AS booking_count, COUNT(DISTINCT f.src || f.dest) AS route_count
FROM Passenger p, Booking b, Flight f
WHERE p.pid = b.pid AND b.fid = f.fid
GROUP BY p.pgender;

-- 8.
-- 예약 이력 없는 승객 뷰를 작성하시오 (한 번도 예약하지 않은 승객 조회 뷰) 
CREATE VIEW v_inactive_passengers AS
SELECT * FROM Passenger WHERE pid NOT IN (SELECT pid FROM Booking);

-- 9.
-- 예약 실적 없는 여행사 뷰를 작성하시오 (한 건도 예약을 처리하지 않은 여행사 조회 뷰) 
CREATE VIEW v_inactive_agencies AS
SELECT * FROM Agency WHERE aid NOT IN (SELECT aid FROM Booking);

-- 10.
-- 승객별 이용 여행사 목록 뷰를 작성하시오 (각 승객이 이용한 여행사 목록 (중복 제거) 뷰) 
CREATE VIEW v_passenger_agency_list AS
SELECT DISTINCT p.pname, a.aname
FROM Passenger p, Booking b, Agency a
WHERE p.pid = b.pid AND b.aid = a.aid;

-- 11.
-- 동일 출발·도착지 왕복 노선 뷰를 작성하시오 (왕복 운항이 가능한 노선 쌍 조회 뷰) 
CREATE VIEW v_round_trip_routes AS
SELECT f1.src, f1.dest
FROM Flight f1, Flight f2
WHERE f1.src = f2.dest AND f1.dest = f2.src;

-- 12.
-- 여행사별 담당 승객 상세 뷰를 작성하시오 (여행사별로 담당한 승객 정보와 이용 항공편 상세 조회 뷰) 
CREATE VIEW v_agency_customer_detail AS
SELECT a.aname, p.pname, f.fid, b.fdate
FROM Agency a, Booking b, Passenger p, Flight f
WHERE a.aid = b.aid AND b.pid = p.pid AND b.fid = f.fid;

-- 13.
-- 날짜별 예약 및 항공편 현황 뷰를 작성하시오 (날짜별 총 예약 건수와 운항 항공편 수 집계 뷰) 
CREATE VIEW v_daily_flight_stats AS
SELECT fdate, COUNT(*) AS booking_count, COUNT(DISTINCT fid) AS flight_count
FROM Booking
GROUP BY fdate;

-- 14.
-- 다중 항공편 이용 승객 뷰를 작성하시오 (2개 이상의 항공편을 예약한 승객 조회 뷰) 
CREATE VIEW v_frequent_flyers AS
SELECT p.pname, COUNT(b.fid) AS flight_count
FROM Passenger p, Booking b
WHERE p.pid = b.pid
GROUP BY p.pname
HAVING COUNT(b.fid) >= 2;

-- 15.
-- 승객-여행사 동일 도시 예약 뷰를 작성하시오 (승객의 거주 도시와 여행사 위치가 같은 예약 조회 뷰) 
CREATE VIEW v_same_city_booking AS
SELECT p.pname, a.aname, p.pcity
FROM Passenger p, Booking b, Agency a
WHERE p.pid = b.pid AND b.aid = a.aid AND p.pcity = a.acity;

-- 5. 기업프로젝트 데이터베이스 

-- 1.
-- 직원 전체 정보 통합 뷰를 작성하시오 (직원 정보와 소속 부서명을 함께 조회하는 뷰) 
CREATE VIEW v_emp_dept_info AS
SELECT e.*, d.deptname
FROM Employee e, Department d
WHERE e.deptno = d.deptno;

-- 2.
-- 직원별 프로젝트 참여 현황 뷰를 작성하시오 (직원이 참여 중인 프로젝트명과 투입 시간 조회하는 뷰) 
CREATE VIEW v_emp_project_status AS
SELECT e.name, p.proname, w.hours_worked
FROM Employee e, Works w, Project p
WHERE e.empno = w.empno AND w.projno = p.projno;

-- 3.
-- 부서별 직원 수 및 현황 뷰를 작성하시오 (부서별 소속 직원 수와 관리자 정보 집계 뷰) 
CREATE VIEW v_dept_emp_count AS
SELECT d.deptname, COUNT(e.empno) AS emp_count, d.manager
FROM Department d LEFT JOIN Employee e ON d.deptno = e.deptno
GROUP BY d.deptname, d.manager;

-- 4.
-- 프로젝트별 참여 직원 및 총 투입 시간 뷰를 작성하시오 (각 프로젝트에 참여한 직원 수와 총 근무 시간 집계 뷰) 
CREATE VIEW v_project_work_stats AS
SELECT p.proname, COUNT(w.empno) AS emp_count, SUM(w.hours_worked) AS total_hours
FROM Project p, Works w
WHERE p.projno = w.projno
GROUP BY p.proname;

-- 5.
-- 직원별 총 근무 시간 뷰를 작성하시오 (직원이 전체 프로젝트에 투입한 총 시간 집계 뷰) 
CREATE VIEW v_emp_total_hours AS
SELECT e.name, SUM(w.hours_worked) AS total_hours
FROM Employee e, Works w
WHERE e.empno = w.empno
GROUP BY e.name;

-- 6.
-- 부서별 프로젝트 현황 뷰를 작성하시오 (각 부서가 담당하는 프로젝트 수와 총 투입 시간 집계 뷰) 
CREATE VIEW v_dept_project_stats AS
SELECT d.deptname, COUNT(DISTINCT p.projno) AS project_count, SUM(w.hours_worked) AS total_hours
FROM Department d, Project p, Works w
WHERE d.deptno = p.deptno AND p.projno = w.projno
GROUP BY d.deptname;

-- 7.
-- 프로젝트에 참여하지 않는 직원 뷰를 작성하시오 (어떤 프로젝트에도 투입되지 않은 직원 조회 뷰) 
CREATE VIEW v_unassigned_emp AS
SELECT * FROM Employee WHERE empno NOT IN (SELECT empno FROM Works);

-- 8.
-- 성별 프로젝트 참여 통계 뷰를 작성하시오 (성별(sex)에 따른 프로젝트 참여 수와 평균 근무 시간 비교 뷰) 
CREATE VIEW v_gender_project_stats AS
SELECT sex, COUNT(w.projno) AS participation_count, AVG(w.hours_worked) AS avg_hours
FROM Employee e, Works w
WHERE e.empno = w.empno
GROUP BY sex;

-- 9.
-- 관리자(Manager) 직원 상세 뷰를 작성하시오 (부서 관리자로 지정된 직원의 상세 정보 조회 뷰) 
CREATE VIEW v_dept_managers AS
SELECT e.*
FROM Employee e, Department d
WHERE e.name = d.manager;

-- 10.
-- 직책별 프로젝트 참여 현황 뷰를 작성하시오 (직책(position)별 총 프로젝트 참여 건수와 평균 투입 시간 뷰) 
CREATE VIEW v_position_project_stats AS
SELECT position, COUNT(w.projno) AS total_count, AVG(w.hours_worked) AS avg_hours
FROM Employee e, Works w
WHERE e.empno = w.empno
GROUP BY position;

-- 11.
-- 다중 프로젝트 참여 직원 뷰를 작성하시오 (2개 이상의 프로젝트에 참여 중인 직원 조회 뷰) 
CREATE VIEW v_multi_project_emp AS
SELECT e.name, COUNT(w.projno) AS proj_count
FROM Employee e, Works w
WHERE e.empno = w.empno
GROUP BY e.name
HAVING COUNT(w.projno) >= 2;

-- 12.
-- 부서 내 프로젝트 참여 직원 상세 뷰를 작성하시오 
CREATE VIEW v_internal_project_emp AS
SELECT e.name, d.deptname, p.proname
FROM Employee e, Department d, Project p, Works w
WHERE e.deptno = d.deptno AND d.deptno = p.deptno AND p.projno = w.projno AND e.empno = w.empno;

-- 13.
-- 타 부서 프로젝트 참여 직원 뷰를 작성하시오 
CREATE VIEW v_external_project_emp AS
SELECT e.name, e.deptno AS emp_dept, p.deptno AS proj_dept, p.proname
FROM Employee e, Project p, Works w
WHERE e.empno = w.empno AND w.projno = p.projno AND e.deptno <> p.deptno;

-- 14.
-- 고투입 시간 직원 뷰 (평균 이상 근무)를 작성하시오 
CREATE VIEW v_hardworking_emp AS
SELECT e.name, SUM(w.hours_worked) AS total_hours
FROM Employee e, Works w
WHERE e.empno = w.empno
GROUP BY e.name
HAVING SUM(w.hours_worked) > (SELECT AVG(hours_worked) FROM Works);

-- 15.
-- 프로젝트 미배정 부서 뷰를 작성하시오 (담당 프로젝트가 하나도 없는 부서 조회 뷰) 
CREATE VIEW v_no_project_dept AS
SELECT * FROM Department WHERE deptno NOT IN (SELECT deptno FROM Project);