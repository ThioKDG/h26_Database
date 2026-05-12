
-- 1. [AFTER INSERT] 수강 테이블에 새 수강 신청이 INSERT될 때, 
-- 수강 학번이 학생 테이블에 존재하지 않으면 삽입을 차단하는 트리거를 작성하시오.
-- (참고: 보통 외래키 제약조건이 처리하지만, 트리거로 구현할 경우)
CREATE OR REPLACE TRIGGER trg_check_student_exists
BEFORE INSERT ON 수강
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM 학생
    WHERE 학번 = :NEW.학번;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, '오류: 학생 테이블에 존재하지 않는 학번입니다.');
    END IF;
END;
/ [cite: 80, 81]

-- 2. [BEFORE INSERT] 수강 테이블에 INSERT될 때, 
-- 동일한 학번과 과목코드 조합이 이미 존재하면 중복 수강 신청을 차단하는 트리거를 작성하시오.
CREATE OR REPLACE TRIGGER trg_prevent_duplicate_enroll
BEFORE INSERT ON 수강
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM 수강
    WHERE 학번 = :NEW.학번 AND 과목코드 = :NEW.과목코드;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20002, '오류: 이미 해당 과목을 수강 신청한 학생입니다.');
    END IF;
END;
/ 

-- 3. [AFTER INSERT] 수강 테이블에 새 행이 INSERT될 때, 삽입된 학번·과목코드·수강학기를 
-- 수강신청이력(학번, 과목코드, 수강학기, 신청일시) 테이블에 자동으로 기록하는 트리거를 작성하시오.
-- (전제: 수강신청이력 테이블이 미리 생성되어 있어야 함)
CREATE OR REPLACE TRIGGER trg_log_enrollment
AFTER INSERT ON 수강
FOR EACH ROW
BEGIN
    INSERT INTO 수강신청이력(학번, 과목코드, 수강학기, 신청일시)
    VALUES(:NEW.학번, :NEW.과목코드, :NEW.수강학기, SYSDATE);
END;
/ 

-- 4. [BEFORE INSERT] 학생 테이블에 새 학생이 INSERT될 때 
-- 학년이 1~4 범위를 벗어나면 삽입을 차단하는 트리거를 작성하시오.
CREATE OR REPLACE TRIGGER trg_check_grade_range
BEFORE INSERT ON 학생
FOR EACH ROW
BEGIN
    IF :NEW.학년 < 1 OR :NEW.학년 > 4 THEN
        RAISE_APPLICATION_ERROR(-20003, '오류: 학년은 1에서 4 사이여야 합니다.');
    END IF;
END;
/ 

-- 5. [AFTER UPDATE] 수강 테이블에서 성적이 UPDATE될 때, 
-- 변경 전 성적·변경 후 성적·변경 일시를 성적변경이력(학번, 과목코드, 이전성적, 변경성적, 변경일시) 
-- 테이블에 기록하는 트리거를 작성하시오.
CREATE OR REPLACE TRIGGER trg_log_grade_change
AFTER UPDATE OF 성적 ON 수강
FOR EACH ROW
BEGIN
    INSERT INTO 성적변경이력(학번, 과목코드, 이전성적, 변경성적, 변경일시)
    VALUES(:OLD.학번, :OLD.과목코드, :OLD.성적, :NEW.성적, SYSDATE);
END;
/ 

-- 6. [BEFORE UPDATE] 수강 테이블에서 성적이 UPDATE될 때, 
-- 새 성적이 0 미만이거나 100 초과이면 변경을 차단하는 트리거를 작성하시오. [cite: 90, 91]
CREATE OR REPLACE TRIGGER trg_check_grade_range
BEFORE UPDATE OF 성적 ON 수강
FOR EACH ROW
BEGIN
    -- :NEW는 수정하려는 새로운 성적 값을 의미함 
    IF :NEW.성적 < 0 OR :NEW.성적 > 100 THEN
        RAISE_APPLICATION_ERROR(-20004, '오류: 성적은 0점에서 100점 사이여야 합니다.'); [cite: 91]
    END IF;
END;
/

-- 7. [AFTER UPDATE] 학생 테이블에서 전공이 UPDATE될 때, 
-- 이전 전공과 새 전공, 변경 일시를 전공변경이력(학번, 이름, 이전전공, 변경전공, 변경일시) 
-- 테이블에 기록하는 트리거를 작성하시오. [cite: 92, 93]
CREATE OR REPLACE TRIGGER trg_log_major_change
AFTER UPDATE OF 전공 ON 학생
FOR EACH ROW
BEGIN
    -- 변경 전(:OLD)과 변경 후(:NEW) 데이터를 로그 테이블에 삽입 [cite: 93]
    INSERT INTO 전공변경이력(학번, 이름, 이전전공, 변경전공, 변경일시)
    VALUES(:OLD.학번, :OLD.이름, :OLD.전공, :NEW.전공, SYSDATE); [cite: 93]
END;
/

-- 8. [AFTER UPDATE] 수강 테이블에서 성적이 UPDATE될 때, 변경된 성적이 60점 미만이면 
-- "미이수 경고: 학번=XXX, 과목코드=XXX" 형식으로 DBMS_OUTPUT에 출력하는 트리거를 작성하시오. [cite: 94, 95]
CREATE OR REPLACE TRIGGER trg_fail_notice
AFTER UPDATE OF 성적 ON 수강
FOR EACH ROW
BEGIN
    -- 수정된 성적(:NEW.성적)이 60점 미만인지 확인 [cite: 95]
    IF :NEW.성적 < 60 THEN
        DBMS_OUTPUT.PUT_LINE('미이수 경고: 학번=' || :NEW.학번 || ', 과목코드=' || :NEW.과목코드); [cite: 95]
    END IF;
END;
/

-- 9. [BEFORE DELETE] 학생 테이블에서 학생이 DELETE될 때, 
-- 해당 학번을 가진 수강 테이블의 모든 행을 먼저 삭제하는 트리거를 작성하시오. [cite: 96, 97]
CREATE OR REPLACE TRIGGER trg_cascade_delete_student
BEFORE DELETE ON 학생
FOR EACH ROW
BEGIN
    -- 삭제될 학생(:OLD.학번)을 참조하는 수강 내역을 먼저 삭제하여 제약 조건 위반 방지 [cite: 97]
    DELETE FROM 수강
    WHERE 학번 = :OLD.학번; [cite: 97]
END;
/

-- 10. [BEFORE DELETE] 과목 테이블에서 과목이 DELETE될 때, 
-- 삭제되는 과목의 정보(과목코드, 과목이름, 담당교수, 삭제일시)를 삭제과목이력 테이블에 백업한 뒤, 
-- 해당 과목코드를 참조하는 수강 행도 함께 삭제하는 트리거를 작성하시오. [cite: 98, 99]
CREATE OR REPLACE TRIGGER trg_backup_and_delete_course
BEFORE DELETE ON 과목
FOR EACH ROW
BEGIN
    -- 1. 삭제될 과목 정보를 백업 테이블에 저장 [cite: 99]
    INSERT INTO 삭제과목이력(과목코드, 과목이름, 담당교수, 삭제일시)
    VALUES(:OLD.과목코드, :OLD.과목이름, :OLD.담당교수, SYSDATE); [cite: 99]

    -- 2. 해당 과목을 참조하는 수강 데이터 삭제 [cite: 99]
    DELETE FROM 수강
    WHERE 과목코드 = :OLD.과목코드; [cite: 99]
END;
/

-- 1. [BEFORE INSERT] Orders 테이블에 새 주문이 INSERT될 때, 
-- custid가 Customer 테이블에 존재하지 않으면 삽입을 차단하는 트리거를 작성하시오. [cite: 106]
CREATE OR REPLACE TRIGGER trg_check_customer_exists
BEFORE INSERT ON Orders
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    -- 삽입하려는 고객번호(:NEW.custid)가 Customer 테이블에 있는지 확인 [cite: 106]
    SELECT COUNT(*) INTO v_count
    FROM Customer
    WHERE custid = :NEW.custid;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20011, '오류: 등록되지 않은 고객번호입니다.');
    END IF;
END;
/

-- 2. [BEFORE INSERT] Orders 테이블에 INSERT될 때, 
-- bookid가 Book 테이블에 존재하지 않으면 삽입을 차단하는 트리거를 작성하시오. [cite: 108]
CREATE OR REPLACE TRIGGER trg_check_book_exists
BEFORE INSERT ON Orders
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    -- 삽입하려는 도서번호(:NEW.bookid)가 Book 테이블에 있는지 확인 [cite: 108]
    SELECT COUNT(*) INTO v_count
    FROM Book
    WHERE bookid = :NEW.bookid;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20012, '오류: 존재하지 않는 도서번호입니다.');
    END IF;
END;
/

-- 3. [BEFORE INSERT] Orders 테이블에 INSERT될 때, 
-- saleprice가 0보다 작으면 삽입을 차단하는 트리거를 작성하시오. [cite: 110]
CREATE OR REPLACE TRIGGER trg_check_saleprice_positive
BEFORE INSERT ON Orders
FOR EACH ROW
BEGIN
    -- 판매가(:NEW.saleprice)가 0보다 작은지 검사 [cite: 110]
    IF :NEW.saleprice < 0 THEN
        RAISE_APPLICATION_ERROR(-20013, '오류: 판매 가격은 0보다 작을 수 없습니다.');
    END IF;
END;
/

-- 4. [AFTER INSERT] Orders 테이블에 새 주문이 INSERT될 때, 
-- orderid, custid, bookid, saleprice, orderdate를 주문이력 테이블에 자동으로 백업하는 트리거를 작성하시오. 
-- (전제: 주문이력 테이블(orderid, custid, bookid, saleprice, orderdate, 기록일시)이 존재해야 함)
CREATE OR REPLACE TRIGGER trg_log_order_insert
AFTER INSERT ON Orders
FOR EACH ROW
BEGIN
    -- 새 주문 정보를 주문이력 테이블에 기록 
    INSERT INTO 주문이력(orderid, custid, bookid, saleprice, orderdate, 기록일시)
    VALUES(:NEW.orderid, :NEW.custid, :NEW.bookid, :NEW.saleprice, :NEW.orderdate, SYSDATE);
END;
/

-- 5. [BEFORE UPDATE] Book 테이블에서 price가 UPDATE될 때, 
-- 새 가격이 기존 가격보다 50% 이상 높으면 변경을 차단하는 트리거를 작성하시오. 
CREATE OR REPLACE TRIGGER trg_limit_price_increase
BEFORE UPDATE OF price ON Book
FOR EACH ROW
BEGIN
    -- 새 가격(:NEW.price)이 기존 가격(:OLD.price)의 1.5배를 초과하는지 확인 
    IF :NEW.price > :OLD.price * 1.5 THEN
        RAISE_APPLICATION_ERROR(-20014, '오류: 가격 인상폭이 너무 큽니다 (기존 가격의 50% 초과 금지).');
    END IF;
END;
/

-- 6. [AFTER UPDATE] Orders 테이블에서 saleprice가 UPDATE될 때, 
-- 변경 전후 금액과 차액을 saleprice_log(orderid, before_price, after_price, diff, chg_date) 
-- 테이블에 기록하는 트리거를 작성하시오. [cite: 115, 116, 117]
CREATE OR REPLACE TRIGGER trg_log_saleprice_update
AFTER UPDATE OF saleprice ON Orders
FOR EACH ROW
BEGIN
    -- 변경 전후 금액과 그 차액(새 금액 - 이전 금액)을 로그 테이블에 삽입 [cite: 117]
    INSERT INTO saleprice_log(orderid, before_price, after_price, diff, chg_date)
    VALUES(:OLD.orderid, :OLD.saleprice, :NEW.saleprice, (:NEW.saleprice - :OLD.saleprice), SYSDATE);
END;
/

-- 7. [AFTER UPDATE] Customer 테이블에서 phone이 UPDATE될 때, 
-- 변경 전후 번호와 변경 일시를 phone_change_log(custid, name, old_phone, new_phone, chg_date) 
-- 테이블에 기록하는 트리거를 작성하시오. [cite: 118, 119]
CREATE OR REPLACE TRIGGER trg_log_phone_update
AFTER UPDATE OF phone ON Customer
FOR EACH ROW
BEGIN
    -- 전화번호가 변경될 때 고객 정보와 이전/이후 번호를 기록 [cite: 119]
    INSERT INTO phone_change_log(custid, name, old_phone, new_phone, chg_date)
    VALUES(:OLD.custid, :OLD.name, :OLD.phone, :NEW.phone, SYSDATE);
END;
/

-- 8. [BEFORE DELETE] Customer 테이블에서 고객이 DELETE될 때, 
-- 해당 custid를 참조하는 Orders 행을 모두 먼저 삭제하는 트리거를 작성하시오. [cite: 120, 121]
CREATE OR REPLACE TRIGGER trg_cascade_delete_orders
BEFORE DELETE ON Customer
FOR EACH ROW
BEGIN
    -- 외래키 제약 조건 오류를 방지하기 위해 자식 레코드(주문 내역)를 먼저 삭제 [cite: 121]
    DELETE FROM Orders
    WHERE custid = :OLD.custid;
END;
/

-- 9. [BEFORE DELETE] Book 테이블에서 책이 DELETE될 때, 삭제되는 책 정보(bookid, bookname, publisher, price, 삭제일시)를 
-- deleted_book_log 테이블에 백업한 후 해당 bookid를 참조하는 Orders 행도 함께 삭제하는 트리거를 작성하시오. [cite: 122, 123, 124]
CREATE OR REPLACE TRIGGER trg_backup_and_delete_book
BEFORE DELETE ON Book
FOR EACH ROW
BEGIN
    -- 1. 삭제되는 도서 정보를 백업 테이블에 저장 [cite: 123, 124]
    INSERT INTO deleted_book_log(bookid, bookname, publisher, price, 삭제일시)
    VALUES(:OLD.bookid, :OLD.bookname, :OLD.publisher, :OLD.price, SYSDATE);

    -- 2. 해당 도서를 참조하는 주문 내역 삭제 [cite: 124]
    DELETE FROM Orders
    WHERE bookid = :OLD.bookid;
END;
/

-- 10. [BEFORE INSERT] Orders 테이블에 INSERT될 때, 동일한 custid와 bookid 조합이 
-- 같은 orderdate에 이미 존재하면 중복 주문을 차단하는 트리거를 작성하시오. [cite: 125, 126]
CREATE OR REPLACE TRIGGER trg_prevent_duplicate_order
BEFORE INSERT ON Orders
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    -- 동일한 날짜에 같은 고객이 같은 책을 주문했는지 확인 
    SELECT COUNT(*) INTO v_count
    FROM Orders
    WHERE custid = :NEW.custid 
      AND bookid = :NEW.bookid 
      AND orderdate = :NEW.orderdate;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20015, '오류: 동일한 고객이 같은 날에 이미 해당 도서를 주문하였습니다.');
    END IF;
END;
/

-- 1. [BEFORE INSERT] 예약 테이블에 새 예약이 INSERT될 때, 
-- 고객번호가 고객 테이블에 존재하지 않으면 삽입을 차단하는 트리거를 작성하시오.
CREATE OR REPLACE TRIGGER trg_check_theater_customer
BEFORE INSERT ON 예약
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    -- 입력하려는 고객번호(:NEW.고객번호)가 고객 테이블에 있는지 확인 
    SELECT COUNT(*) INTO v_count
    FROM 고객
    WHERE 고객번호 = :NEW.고객번호;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20021, '오류: 등록되지 않은 고객번호입니다.');
    END IF;
END;
/

-- 2. [BEFORE INSERT] 예약 테이블에 INSERT될 때, 동일한 극장번호·상영관번호·날짜·좌석번호 
-- 조합이 이미 존재하면 중복 예약을 차단하는 트리거를 작성하시오.
CREATE OR REPLACE TRIGGER trg_prevent_double_booking
BEFORE INSERT ON 예약
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    -- 동일한 상영관, 날짜, 좌석에 이미 예약이 있는지 확인 
    SELECT COUNT(*) INTO v_count
    FROM 예약
    WHERE 극장번호 = :NEW.극장번호 
      AND 상영관번호 = :NEW.상영관번호 
      AND 날짜 = :NEW.날짜 
      AND 좌석번호 = :NEW.좌석번호;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20022, '오류: 해당 좌석은 이미 예약되었습니다.');
    END IF;
END;
/

-- 3. [BEFORE INSERT] 예약 테이블에 INSERT될 때 해당 상영관의 좌석수보다 
-- 현재 예약 수가 같거나 많으면 예약을 차단하는 트리거를 작성하시오.
CREATE OR REPLACE TRIGGER trg_check_theater_capacity
BEFORE INSERT ON 예약
FOR EACH ROW
DECLARE
    v_max_seats NUMBER;
    v_current_reserves NUMBER;
BEGIN
    -- 1. 해당 상영관의 총 좌석 수 조회 
    SELECT 좌석수 INTO v_max_seats
    FROM 상영관
    WHERE 극장번호 = :NEW.극장번호 AND 상영관번호 = :NEW.상영관번호;

    -- 2. 해당 날짜, 해당 상영관의 현재 예약 건수 조회 
    SELECT COUNT(*) INTO v_current_reserves
    FROM 예약
    WHERE 극장번호 = :NEW.극장번호 AND 상영관번호 = :NEW.상영관번호 AND 날짜 = :NEW.날짜;

    -- 3. 정원 초과 여부 확인 
    IF v_current_reserves >= v_max_seats THEN
        RAISE_APPLICATION_ERROR(-20023, '오류: 해당 상영관의 모든 좌석이 매진되었습니다.');
    END IF;
END;
/

-- 4. [AFTER INSERT] 예약 테이블에 새 예약이 INSERT될 때, 예약된 정보
-- (극장번호, 상영관번호, 고객번호, 좌석번호, 날짜, 기록일시)를 예약이력 테이블에 자동으로 기록하는 트리거를 작성하시오.
CREATE OR REPLACE TRIGGER trg_log_reservation
AFTER INSERT ON 예약
FOR EACH ROW
BEGIN
    -- 예약 성공 후 이력 테이블에 데이터 백업 
    INSERT INTO 예약이력(극장번호, 상영관번호, 고객번호, 좌석번호, 날짜, 기록일시)
    VALUES(:NEW.극장번호, :NEW.상영관번호, :NEW.고객번호, :NEW.좌석번호, :NEW.날짜, SYSDATE);
END;
/

-- 5. [BEFORE UPDATE] 상영관 테이블에서 가격이 UPDATE될 때, 
-- 새 가격이 0이하이면 변경을 차단하는 트리거를 작성하시오.
CREATE OR REPLACE TRIGGER trg_check_movie_price
BEFORE UPDATE OF 가격 ON 상영관
FOR EACH ROW
BEGIN
    -- 수정하려는 가격(:NEW.가격)이 0 이하인지 확인 
    IF :NEW.가격 <= 0 THEN
        RAISE_APPLICATION_ERROR(-20024, '오류: 영화 가격은 0보다 커야 합니다.');
    END IF;
END;
/

-- 6. [AFTER UPDATE] 상영관 테이블에서 가격이 UPDATE될 때 변경 전후 가격과 변경 일시를 
-- 가격변경이력(극장번호, 상영관번호, 영화제목, 이전가격, 변경가격, 변경일시) 테이블에 기록하는 트리거를 작성하시오. [cite: 142]
CREATE OR REPLACE TRIGGER trg_log_theater_price
AFTER UPDATE OF 가격 ON 상영관
FOR EACH ROW
BEGIN
    -- 변경 전(:OLD) 가격과 변경 후(:NEW) 가격을 이력 테이블에 기록함 [cite: 142]
    INSERT INTO 가격변경이력(극장번호, 상영관번호, 영화제목, 이전가격, 변경가격, 변경일시)
    VALUES(:OLD.극장번호, :OLD.상영관번호, :OLD.영화제목, :OLD.가격, :NEW.가격, SYSDATE);
END;
/

-- 7. [BEFORE UPDATE] 상영관 테이블에서 좌석수가 UPDATE될 때, 
-- 변경하려는 좌석수가 현재 해당 상영관의 예약 수보다 작으면 변경을 차단하는 트리거를 작성하시오. 
CREATE OR REPLACE TRIGGER trg_check_seat_update
BEFORE UPDATE OF 좌석수 ON 상영관
FOR EACH ROW
DECLARE
    v_reserve_count NUMBER;
BEGIN
    -- 현재 해당 상영관에 예약된 인원수를 조회함 
    SELECT COUNT(*) INTO v_reserve_count
    FROM 예약
    WHERE 극장번호 = :OLD.극장번호 AND 상영관번호 = :OLD.상영관번호;

    -- 변경하려는 새 좌석수(:NEW.좌석수)가 현재 예약자 수보다 적은지 검사함 
    IF :NEW.좌석수 < v_reserve_count THEN
        RAISE_APPLICATION_ERROR(-20025, '오류: 변경하려는 좌석수가 현재 예약 인원(' || v_reserve_count || ')보다 적을 수 없습니다.');
    END IF;
END;
/

-- 8. [BEFORE DELETE] 고객 테이블에서 고객이 DELETE될 때, 
-- 해당 고객번호를 참조하는 예약 행을 모두 먼저 삭제하는 트리거를 작성하시오. [cite: 146]
CREATE OR REPLACE TRIGGER trg_cascade_delete_reserve
BEFORE DELETE ON 고객
FOR EACH ROW
BEGIN
    -- 고객이 삭제되기 전(:OLD.고객번호), 해당 고객의 모든 예약 내역을 먼저 삭제하여 외래키 오류를 방지함 [cite: 146]
    DELETE FROM 예약
    WHERE 고객번호 = :OLD.고객번호;
END;
/

-- 9. [BEFORE DELETE] 상영관 테이블에서 행이 DELETE될 때, 삭제되는 상영관 정보(극장번호, 상영관번호, 영화제목, 가격, 삭제일시)를 
-- 삭제상영관이력 테이블에 백업하고, 해당 상영관의 예약 행도 모두 삭제하는 트리거를 작성하시오. [cite: 148]
CREATE OR REPLACE TRIGGER trg_backup_and_delete_room
BEFORE DELETE ON 상영관
FOR EACH ROW
BEGIN
    -- 1. 삭제되는 상영관 정보를 이력 테이블에 먼저 백업함 [cite: 148]
    INSERT INTO 삭제상영관이력(극장번호, 상영관번호, 영화제목, 가격, 삭제일시)
    VALUES(:OLD.극장번호, :OLD.상영관번호, :OLD.영화제목, :OLD.가격, SYSDATE);

    -- 2. 해당 상영관과 관련된 모든 예약 내역을 삭제함 [cite: 148]
    DELETE FROM 예약
    WHERE 극장번호 = :OLD.극장번호 AND 상영관번호 = :OLD.상영관번호;
END;
/

-- 10. [BEFORE DELETE] 극장 테이블에서 극장이 DELETE될 때, 
-- 해당 극장번호를 참조하는 예약 행과 상영관 행을 모두 삭제하는 트리거를 작성하시오. [cite: 150]
CREATE OR REPLACE TRIGGER trg_cascade_delete_theater
BEFORE DELETE ON 극장
FOR EACH ROW
BEGIN
    -- 1. 해당 극장에서 발생한 모든 예약 정보를 먼저 삭제함 [cite: 150]
    DELETE FROM 예약 WHERE 극장번호 = :OLD.극장번호;
    
    -- 2. 해당 극장에 소속된 모든 상영관 정보를 삭제함 [cite: 150]
    DELETE FROM 상영관 WHERE 극장번호 = :OLD.극장번호;
END;
/