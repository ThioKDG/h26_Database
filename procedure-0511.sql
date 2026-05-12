-- 1 bookid를 입력받아 해당 도서의 bookname, publisher, price를 출력하는 프로시저를 작성하시오
CREATE OR REPLACE PROCEDURE GetBookInfo (
    v_bookid IN Book.bookid%TYPE
)
AS
    -- 변수 선언: 테이블의 컬럼 타입을 그대로 참조 (%TYPE)
    v_bookname  Book.bookname%TYPE;
    v_publisher Book.publisher%TYPE;
    v_price     Book.price%TYPE;
BEGIN
    -- 데이터 조회
    SELECT bookname, publisher, price
    INTO v_bookname, v_publisher, v_price
    FROM Book
    WHERE bookid = v_bookid;

    -- 결과 출력
    DBMS_OUTPUT.PUT_LINE('도서명: ' || v_bookname);
    DBMS_OUTPUT.PUT_LINE('출판사: ' || v_publisher);
    DBMS_OUTPUT.PUT_LINE('가  격: ' || v_price);

EXCEPTION
    -- 해당 ID의 도서가 없을 경우 예외 처리
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('오류: 해당 도서 ID(' || v_bookid || ')가 존재하지 않습니다.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('기타 오류 발생');
END;
/

exec GetBookInfo(1);


-- 2. 새로운 고객 정보 (custid, name, address, phone)를 입력받아 Customer 테이블에 삽입하는 프로시저 작성
CREATE OR REPLACE PROCEDURE proc_insert_customer(
    p_custid  IN Customer.custid%TYPE,
    p_name    IN Customer.name%TYPE,
    p_address IN Customer.address%TYPE,
    p_phone   IN Customer.phone%TYPE
)
IS
BEGIN
    INSERT INTO Customer(custid, name, address, phone)
    VALUES(p_custid, p_name, p_address, p_phone);
    
    COMMIT;
    -- 수정: DBMS_OUTPUT (U가 아니라 O)
    DBMS_OUTPUT.PUT_LINE('고객이 정상적으로 등록되었습니다.');

EXCEPTION
    -- 수정: 중복 오류 시에도 DBMS_OUTPUT 사용
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('이미 존재하는 고객번호 입니다.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('오류발생 : ' || SQLERRM);
END;
/

exec proc_insert_customer(6, '김강민', '프랑스 파리', '001-202-3303');

-- 3 bookid와 새로운 price를 입력받아 해당 도서의 가격을 수정하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE UpBookprice(
    b_bookid in Book.bookid%TYPE,
    b_price in Book.price%TYPE
)
IS
BEGIN
    -- 코드를 입력하세요
    UPDATE Book 
    SET price = b_price
    WHERE bookid = b_bookid;

    if SQL%NOTFOUND THEN
        DBMS_OUTPUT.PUT_LINE('오류 : 도서번호 ' || b_bookid || '번을 찾을 수 없습니다');
    ELSE
        COMMIT;
        DBMS_OUTPUT.PUT_LINE(b_bookid || ' 번 도서의 가격이 ' || b_price || '원으로 수정되었습니다');
    END if;

EXCEPTION
    when OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('오류발생 : ' || SQLERRM);

END;
/
exec UpBookprice(1, 10000);

-- 4 custid를 입력받아 해당 고객의 주문내역을 orders 테이블에서 모두 삭제한 후, customer 테이블에서도 해당 고객을 삭제하는 프로시저를 작성하시오.

CREATE OR REPLACE PROCEDURE DelCust(
    c_custid in Customer.custid%type
)
IS
BEGIN
    DELETE from ORDERS
    where custid = c_custid;

    DELETE from CUSTOMER
    where custid = c_custid;

    if SQL%NOTFOUND THEN
        DBMS_OUTPUT.PUT_LINE('오류 : 고객번호 : ' || c_custid || '번을 찾을 수 없습니다');
        ROLLBACK;
    ELSE
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('고객번호 : ' || c_custid || '번과 관련 주문 내역이 모두 삭제 되었습니다');
    END if;
EXCEPTION
    when OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('오류 발생 : ' || SQLERRM);
        
END;
/

exec DelCust(6);

-- 5 orderid를 입력받아 해당 주문의 고객 이름, 도서명, 주문금액, 주문날짜를 출력하는 프로시저를 작성하시오
CREATE OR REPLACE PROCEDURE SelectInfo(
    o_orderid IN Orders.orderid%TYPE
)
IS
    -- 정보를 담을 변수 선언
    v_name      Customer.name%TYPE;
    v_bookname  Book.bookname%TYPE;
    v_saleprice Orders.saleprice%TYPE;
    v_orderdate Orders.orderdate%TYPE;
BEGIN
    -- 3개 테이블 조인 및 변수에 대입 (INTO)
    SELECT c.name, b.bookname, o.saleprice, o.orderdate
    INTO v_name, v_bookname, v_saleprice, v_orderdate
    FROM Orders o
    JOIN Customer c ON o.custid = c.custid
    JOIN Book b     ON o.bookid = b.bookid
    WHERE o.orderid = o_orderid;

    -- 결과 출력
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('주문번호: ' || o_orderid);
    DBMS_OUTPUT.PUT_LINE('고객이름: ' || v_name);
    DBMS_OUTPUT.PUT_LINE('도 서 명: ' || v_bookname);
    DBMS_OUTPUT.PUT_LINE('주문금액: ' || v_saleprice);
    DBMS_OUTPUT.PUT_LINE('주문날짜: ' || TO_CHAR(v_orderdate, 'YYYY-MM-DD'));
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('오류: 주문번호 ' || o_orderid || '번에 대한 정보가 없습니다.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('오류 발생 : ' || SQLERRM);
END;
/

exec SelectInfo(1);

-- 6. 출판사 이름을 입력받아 해당 출판사의 도서 목록(bookid, bookname, price)을 모두 출력하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE publisherProc(
    b_publisher in Book.publisher%TYPE
)
IS
    -- 1. 여러 행을 처리하기 위한 커서 선언
    CURSOR book_cursor IS
        SELECT bookid, bookname, price
        FROM Book
        WHERE publisher = b_publisher;

    v_bookid book.BOOKID%TYPE;
    v_bookname book.BOOKNAME%TYPE;
    v_bookprice book.PRICE%TYPE;
    
    -- 데이터 존재 여부 체크용 변수
    v_found     BOOLEAN := FALSE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('출판사 [' || b_publisher || '] 도서 목록');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------');

    -- 2. 커서 열기 및 반복문 처리
    OPEN book_cursor;
    LOOP
        FETCH book_cursor INTO v_bookid, v_bookname, v_bookprice;
        EXIT WHEN book_cursor%NOTFOUND; -- 더 이상 데이터가 없으면 탈출
        
        v_found := TRUE;
        DBMS_OUTPUT.PUT_LINE('도서번호: ' || v_bookid || ' | 도서명: ' || v_bookname || ' | 금액: ' || v_bookprice);
    END LOOP;
    CLOSE book_cursor;

    -- 3. 데이터가 하나도 없었을 경우 처리
    IF NOT v_found THEN
        DBMS_OUTPUT.PUT_LINE('해당 출판사의 도서가 존재하지 않습니다.');
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------');

EXCEPTION
    WHEN OTHERS THEN
        IF book_cursor%ISOPEN THEN CLOSE book_cursor; END IF;
        DBMS_OUTPUT.PUT_LINE('오류 발생 : ' || SQLERRM);
END;
/

exec publisherProc('굿스포츠');

-- 7. custid를 입력받아 해당 고객의 전체 주문 내역(도서명, 주문금액, 주문날짜)을 주문날짜 오름차순으로 출력하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE get_customer_orders(
    p_custid IN Customer.custid%TYPE
) 
IS
    v_found BOOLEAN := FALSE; -- 주문 내역 존재 여부 확인용
BEGIN
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('고객번호 [' || p_custid || '] 님의 전체 주문 내역 (날짜 오름차순)');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------');

    -- FOR LOOP를 사용하여 자동으로 커서 처리
    -- JOIN을 통해 도서명(bookname)을 가져오고, ORDER BY로 정렬
    FOR rec IN (
        SELECT b.bookname, o.saleprice, o.orderdate
        FROM Orders o
        JOIN Book b ON o.bookid = b.bookid
        WHERE o.custid = p_custid
        ORDER BY o.orderdate ASC
    ) LOOP
        v_found := TRUE;
        DBMS_OUTPUT.PUT_LINE('도서명: ' || RPAD(rec.bookname, 20) || 
                             ' | 주문금액: ' || LPAD(rec.saleprice, 7) || 
                             ' | 주문날짜: ' || TO_CHAR(rec.orderdate, 'YYYY-MM-DD'));
    END LOOP;

    -- 주문 내역이 없을 경우 메시지 출력
    IF NOT v_found THEN
        DBMS_OUTPUT.PUT_LINE('해당 고객의 주문 내역이 존재하지 않습니다.');
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------');
END;
/

EXEC get_customer_orders(1); 

-- 8 시작 날짜와 종료 날짜를 입력받아 해당 기간 내 주문된 모든 주문 정보(고객명, 도서명, 주문금액, 주문날짜)를 출력하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE GetOrdersByPeriod(
    p_start_date IN DATE,
    p_end_date   IN DATE
)
IS
    CURSOR order_cursor IS
        SELECT c.name, b.bookname, o.saleprice, o.orderdate
        FROM Orders o
        JOIN Customer c ON o.custid = c.custid
        JOIN Book b     ON o.bookid = b.bookid
        WHERE o.orderdate BETWEEN p_start_date AND p_end_date;
BEGIN
    FOR rec IN order_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('고객: ' || rec.name || ' | 도서: ' || rec.bookname || 
                             ' | 금액: ' || rec.saleprice || ' | 날짜: ' || TO_CHAR(rec.orderdate, 'YYYY-MM-DD'));
    END LOOP;
END;
/

exec GetOrdersByPeriod('2020-07-01', '2020-07-07');


-- 9. 도서 이름을 입력받아 해당 도서를 주문한 고객의 이름과 주문금액을 출력하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE GetCustByBook(
    p_bookname IN Book.bookname%TYPE
)
IS
BEGIN
    FOR rec IN (
        SELECT c.name, o.saleprice
        FROM Orders o
        JOIN Customer c ON o.custid = c.custid
        JOIN Book b     ON o.bookid = b.bookid
        WHERE b.bookname LIKE '%' || p_bookname || '%'
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('고객명: ' || rec.name || ' | 주문금액: ' || rec.saleprice);
    END LOOP;
END;
/

exec GetCustByBook('축구의 역사');

-- 10. 특정 주문금액 이상의 주문을 한 고객의 custid, name, 주문 건수를 출력하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE GetHighValueCust(
    p_min_price IN Orders.saleprice%TYPE
)
IS
BEGIN
    FOR rec IN (
        SELECT c.custid, c.name, COUNT(o.orderid) as cnt
        FROM Orders o
        JOIN Customer c ON o.custid = c.custid
        WHERE o.saleprice >= p_min_price
        GROUP BY c.custid, c.name
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('ID: ' || rec.custid || ' | 이름: ' || rec.name || ' | 주문건수: ' || rec.cnt);
    END LOOP;
END;
/

exec GetHighValueCust(6000);

-- 11. custid를 입력받아 해당 고객의 총 주문금액 합계를 OUT 매개변수로 반환하고 화면에도 출력하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE proc_total_price(
    p_custid IN Orders.custid%TYPE,
    p_total OUT NUMBER
)
IS
    v_name Customer.name%TYPE;
BEGIN
    SELECT name INTO v_name FROM Customer WHERE custid = p_custid;
    
    SELECT SUM(saleprice) INTO p_total 
    FROM Orders 
    WHERE custid = p_custid;

    DBMS_OUTPUT.PUT_LINE(v_name || ' 고객님의 총 주문금액: ' || NVL(p_total, 0) || '원');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('해당 고객을 찾을 수 없습니다.');
END;
/
exec proc_total_price(1);

-- 12. 출판사 이름을 입력받아 해당 출판사 도서들의 평균 주문금액, 최고 주문금액, 최저 주문금액을 출력하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE proc_publisher_stats(
    p_publisher IN Book.publisher%TYPE
)
IS
    v_avg NUMBER;
    v_max NUMBER;
    v_min NUMBER;
BEGIN
    SELECT AVG(o.saleprice), MAX(o.saleprice), MIN(o.saleprice)
    INTO v_avg, v_max, v_min
    FROM Orders o
    JOIN Book b ON o.bookid = b.bookid
    WHERE b.publisher = p_publisher;

    DBMS_OUTPUT.PUT_LINE('출판사: ' || p_publisher);
    DBMS_OUTPUT.PUT_LINE('평균가: ' || ROUND(v_avg, 0) || ' | 최고가: ' || v_max || ' | 최저가: ' || v_min);
END;
/
exec proc_publisher_stats('굿스포츠');

-- 13. 전체 도서 중 주문 횟수가 가장 많은 도서의 이름과 주문 횟수를 OUT 매개변수로 반환하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE proc_best_seller(
    p_bookname OUT Book.bookname%TYPE,
    p_count OUT NUMBER
)
IS
BEGIN
    SELECT bookname, cnt INTO p_bookname, p_count
    FROM (
        SELECT b.bookname, COUNT(*) as cnt
        FROM Orders o
        JOIN Book b ON o.bookid = b.bookid
        GROUP BY b.bookname
        ORDER BY cnt DESC
    ) WHERE ROWNUM = 1;
END;
/

VARIABLE v_name VARCHAR2(100);
VARIABLE v_count NUMBER;
EXEC proc_best_seller(:v_name, :v_count);
PRINT v_name;
PRINT v_count;


-- 14. 주문 삽입 시 입력한 saleprice가 해당 도서의 price보다 크면 오류 메시지를 출력하고 삽입을 중단하며, 정상이면 Orders 테이블에 삽입하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE proc_insert_order_check(
    p_orderid   IN Orders.orderid%TYPE,
    p_custid    IN Orders.custid%TYPE,
    p_bookid    IN Orders.bookid%TYPE,
    p_saleprice IN Orders.saleprice%TYPE,
    p_orderdate IN Orders.orderdate%TYPE
)
IS
    v_original_price Book.price%TYPE;
BEGIN
    -- 해당 도서의 원래 가격 조회
    SELECT price INTO v_original_price 
    FROM Book 
    WHERE bookid = p_bookid;

    -- 가격 비교 로직
    IF p_saleprice > v_original_price THEN
        DBMS_OUTPUT.PUT_LINE('오류: 판매가(' || p_saleprice || ')가 도서 정가(' || v_original_price || ')보다 클 수 없습니다.');
    ELSE
        -- 정상인 경우 삽입
        INSERT INTO Orders(orderid, custid, bookid, saleprice, orderdate)
        VALUES(p_orderid, p_custid, p_bookid, p_saleprice, p_orderdate);
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('주문이 정상적으로 완료되었습니다.');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('오류: 존재하지 않는 도서번호(' || p_bookid || ')입니다.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
END;
/

-- 오류 발생 시나리오 (정가보다 비싸게 입력)
EXEC proc_insert_order_check(11, 1, 1, 8000, SYSDATE);

-- 정상 삽입 시나리오
EXEC proc_insert_order_check(1, 1, 1, 5000, SYSDATE);

-- 15. custid를 입력받아 해당 고객의 총 주문금액이 30,000원 이상이면 'VIP 고객', 10,000원 이상이면 '일반 고객', 그 미만이면 '신규 고객'으로 등급을 분류하여 출력하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE proc_customer_grade(
    p_custid IN Customer.custid%TYPE
)
IS
    v_name  Customer.name%TYPE;
    v_total NUMBER;
    v_grade VARCHAR2(20);
BEGIN
    -- 고객 이름 조회
    SELECT name INTO v_name FROM Customer WHERE custid = p_custid;

    -- 총 주문금액 합산 (주문 내역이 없으면 0)
    SELECT NVL(SUM(saleprice), 0) INTO v_total 
    FROM Orders 
    WHERE custid = p_custid;

    -- 등급 분류 로직
    IF v_total >= 30000 THEN
        v_grade := 'VIP 고객';
    ELSIF v_total >= 10000 THEN
        v_grade := '일반 고객';
    ELSE
        v_grade := '신규 고객';
    END IF;

    -- 결과 출력
    DBMS_OUTPUT.PUT_LINE('고객명: ' || v_name);
    DBMS_OUTPUT.PUT_LINE('총 주문금액: ' || v_total || '원');
    DBMS_OUTPUT.PUT_LINE('현재 등급: ' || v_grade);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('오류: 해당 고객번호를 찾을 수 없습니다.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
END;
/

SET SERVEROUTPUT ON;
EXEC proc_customer_grade(1); -- 박지성 등 누적 금액에 따른 등급 확인


-- 극장 DB
-- 1. 특정 극장번호를 입력받아 해당 극장의 이름과 위치를 출력하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE proc_get_theater_info(
    p_theater_id IN 극장.극장번호%TYPE
)
IS
    v_name  극장.극장이름%TYPE;
    v_loc   극장.위치%TYPE;
BEGIN
    SELECT 극장이름, 위치 INTO v_name, v_loc
    FROM 극장
    WHERE 극장번호 = p_theater_id;

    DBMS_OUTPUT.PUT_LINE('극장명: ' || v_name || ' | 위치: ' || v_loc); [cite: 29, 33]

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('오류: 해당 극장번호(' || p_theater_id || ')가 존재하지 않습니다.');
END;
/

-- 2. 새로운 극장 정보(극장번호, 극장이름, 위치)를 입력받아 극장 테이블에 삽입하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE proc_insert_theater(
    p_theater_id   IN 극장.극장번호%TYPE,
    p_theater_name IN 극장.극장이름%TYPE,
    p_location     IN 극장.위치%TYPE
)
IS
BEGIN
    INSERT INTO 극장(극장번호, 극장이름, 위치)
    VALUES(p_theater_id, p_theater_name, p_location); [cite: 29, 34]
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('새로운 극장이 등록되었습니다.');

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('오류: 이미 존재하는 극장번호입니다.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
END;
/

-- 3. 극장번호와 새로운 위치를 입력받아 해당 극장의 위치를 수정하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE proc_update_theater_loc(
    p_theater_id  IN 극장.극장번호%TYPE,
    p_new_location IN 극장.위치%TYPE
)
IS
BEGIN
    UPDATE 극장
    SET 위치 = p_new_location
    WHERE 극장번호 = p_theater_id; [cite: 29, 35]

    IF SQL%NOTFOUND THEN
        DBMS_OUTPUT.PUT_LINE('오류: 해당 극장을 찾을 수 없습니다.');
    ELSE
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('극장 위치가 수정되었습니다.');
    END IF;
END;
/

-- 4. 극장번호를 입력받아 해당 극장과 그 극장의 모든 상영관 정보를 삭제하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE proc_delete_theater_all(
    p_theater_id IN 극장.극장번호%TYPE
)
IS
BEGIN
    -- 외래키 제약 조건을 고려하여 자식 테이블(상영관)부터 삭제
    DELETE FROM 상영관 WHERE 극장번호 = p_theater_id; [cite: 30, 36]
    -- 부모 테이블(극장) 삭제
    DELETE FROM 극장 WHERE 극장번호 = p_theater_id; [cite: 29, 36]

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('해당 극장과 모든 상영관 정보가 삭제되었습니다.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
END;
/

-- 5. 상영관번호와 극장번호를 입력받아 해당 상영관의 영화제목, 가격, 좌석수를 출력하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE proc_get_room_info(
    p_theater_id IN 상영관.극장번호%TYPE,
    p_room_id    IN 상영관.상영관번호%TYPE
)
IS
    v_title  상영관.영화제목%TYPE;
    v_price  상영관.가격%TYPE;
    v_seats  상영관.좌석수%TYPE;
BEGIN
    SELECT 영화제목, 가격, 좌석수 
    INTO v_title, v_price, v_seats
    FROM 상영관
    WHERE 극장번호 = p_theater_id AND 상영관번호 = p_room_id; [cite: 30, 37]

    DBMS_OUTPUT.PUT_LINE('영화제목: ' || v_title);
    DBMS_OUTPUT.PUT_LINE('가    격: ' || v_price || '원');
    DBMS_OUTPUT.PUT_LINE('좌 석 수: ' || v_seats || '석');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('오류: 해당 상영관 정보를 찾을 수 없습니다.');
END;
/

-- 6. 특정 가격 이하의 상영관 목록을 모두 출력하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE proc_cheap_rooms(
    p_price IN 상영관.가격%TYPE
)
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('가 격 ' || p_price || '원 이하 상영관 목록');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
    
    FOR rec IN (
        SELECT 극장번호, 상영관번호, 영화제목, 가격
        FROM 상영관
        WHERE 가격 <= p_price
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('극장번호: ' || rec.극장번호 || ' | 상영관: ' || rec.상영관번호 || 
                             ' | 영화: ' || rec.영화제목 || ' | 가격: ' || rec.가격);
    END LOOP;
END;
/

-- 7. 특정 날짜를 입력받아 그날 예약된 모든 예약 정보(극장번호, 상영관번호, 고객번호, 좌석번호)를 출력하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE proc_daily_reservations(
    p_date IN 예약.날짜%TYPE
)
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE(p_date || ' 예약 현황');
    
    FOR rec IN (
        SELECT 극장번호, 상영관번호, 고객번호, 좌석번호
        FROM 예약
        WHERE 날짜 = p_date
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('극장: ' || rec.극장번호 || ' | 상영관: ' || rec.상영관번호 || 
                             ' | 고객: ' || rec.고객번호 || ' | 좌석: ' || rec.좌석번호);
    END LOOP;
END;
/

-- 6. 특정 가격 이하의 상영관 목록을 모두 출력하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE proc_cheap_rooms(
    p_price IN 상영관.가격%TYPE
)
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('가 격 ' || p_price || '원 이하 상영관 목록');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
    
    FOR rec IN (
        SELECT 극장번호, 상영관번호, 영화제목, 가격
        FROM 상영관
        WHERE 가격 <= p_price
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('극장번호: ' || rec.극장번호 || ' | 상영관: ' || rec.상영관번호 || 
                             ' | 영화: ' || rec.영화제목 || ' | 가격: ' || rec.가격);
    END LOOP;
END;
/

-- 7. 특정 날짜를 입력받아 그날 예약된 모든 예약 정보(극장번호, 상영관번호, 고객번호, 좌석번호)를 출력하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE proc_daily_reservations(
    p_date IN 예약.날짜%TYPE
)
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE(p_date || ' 예약 현황');
    
    FOR rec IN (
        SELECT 극장번호, 상영관번호, 고객번호, 좌석번호
        FROM 예약
        WHERE 날짜 = p_date
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('극장: ' || rec.극장번호 || ' | 상영관: ' || rec.상영관번호 || 
                             ' | 고객: ' || rec.고객번호 || ' | 좌석: ' || rec.좌석번호);
    END LOOP;
END;
/

-- 8. 고객번호를 입력받아 해당 고객의 전체 예약 내역(극장이름, 영화제목, 날짜, 좌석번호)을 출력하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE proc_cust_reserves(
    p_custid IN 고객.고객번호%TYPE
)
IS
BEGIN
    FOR rec IN (
        SELECT g.극장이름, s.영화제목, r.날짜, r.좌석번호
        FROM 예약 r
        JOIN 극장 g ON r.극장번호 = g.극장번호
        JOIN 상영관 s ON r.극장번호 = s.극장번호 AND r.상영관번호 = s.상영관번호
        WHERE r.고객번호 = p_custid
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('극장: ' || rec.극장이름 || ' | 영화: ' || rec.영화제목 || 
                             ' | 날짜: ' || rec.날짜 || ' | 좌석: ' || rec.좌석번호);
    END LOOP;
END;
/

-- 9. 영화제목을 입력받아 해당 영화를 상영 중인 극장 이름과 위치를 출력하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE proc_theater_by_movie(
    p_movie_title IN 상영관.영화제목%TYPE
)
IS
BEGIN
    -- 중복된 극장 이름을 제거하기 위해 DISTINCT 사용
    FOR rec IN (
        SELECT DISTINCT g.극장이름, g.위치
        FROM 상영관 s
        JOIN 극장 g ON s.극장번호 = g.극장번호
        WHERE s.영화제목 = p_movie_title
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('극장이름: ' || rec.극장이름 || ' | 위치: ' || rec.위치);
    END LOOP;
END;
/

-- 10. 특정 극장번호를 입력받아 해당 극장의 상영관별 총 예약 건수를 출력하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE proc_theater_reserve_stat(
    p_theater_id IN 예약.극장번호%TYPE
)
IS
BEGIN
    FOR rec IN (
        SELECT 상영관번호, COUNT(*) as res_count
        FROM 예약
        WHERE 극장번호 = p_theater_id
        GROUP BY 상영관번호
        ORDER BY 상영관번호 ASC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('상영관 번호: ' || rec.상영관번호 || ' | 총 예약 건수: ' || rec.res_count);
    END LOOP;
END;
/

-- 11. 극장 번호를 입력받아 해당 극장 전체 상영관의 평균 좌석수를 OUT 매개변수로 반환하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE proc_avg_seats(
    p_theater_id IN 극장.극장번호%TYPE,
    p_avg_seats  OUT NUMBER
)
IS
BEGIN
    -- 해당 극장의 모든 상영관 좌석수 평균 계산 
    SELECT AVG(좌석수) 
    INTO p_avg_seats
    FROM 상영관
    WHERE 극장번호 = p_theater_id;

    DBMS_OUTPUT.PUT_LINE('극장번호 ' || p_theater_id || '의 평균 좌석수: ' || ROUND(p_avg_seats, 2));
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_avg_seats := 0;
        DBMS_OUTPUT.PUT_LINE('해당 극장에 등록된 상영관이 없습니다.');
END;
/

-- 12. 상영관 번호와 극장 번호를 입력받아 해당 상영관의 좌석 예약률(예약건수 / 좌석수 × 100)을 계산하여 출력하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE proc_reserve_rate(
    p_theater_id IN 상영관.극장번호%TYPE,
    p_room_id    IN 상영관.상영관번호%TYPE
)
IS
    v_total_seats NUMBER;
    v_res_count   NUMBER;
    v_rate        NUMBER;
BEGIN
    -- 1. 해당 상영관의 총 좌석수 가져오기 
    SELECT 좌석수 INTO v_total_seats
    FROM 상영관
    WHERE 극장번호 = p_theater_id AND 상영관번호 = p_room_id;

    -- 2. 해당 상영관의 예약 건수 세기 
    SELECT COUNT(*) INTO v_res_count
    FROM 예약
    WHERE 극장번호 = p_theater_id AND 상영관번호 = p_room_id;

    -- 3. 예약률 계산 (예약건수 / 좌석수 * 100) 
    IF v_total_seats > 0 THEN
        v_rate := (v_res_count / v_total_seats) * 100;
        DBMS_OUTPUT.PUT_LINE('극장 ' || p_theater_id || ', ' || p_room_id || '관 예약률: ' || ROUND(v_rate, 2) || '%');
    ELSE
        DBMS_OUTPUT.PUT_LINE('좌석 정보가 0이어서 계산할 수 없습니다.');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('해당 상영관 정보를 찾을 수 없습니다.');
END;
/

-- 13. 특정 고객 번호를 입력받아 해당 고객이 지출한 총 예약 금액(예약 건수 * 가격)을 OUT 매개변수로 반환하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE proc_total_spent(
    p_custid IN 고객.고객번호%TYPE,
    p_total_price OUT NUMBER
)
IS
BEGIN
    -- 예약 테이블과 상영관 테이블을 조인하여 고객별 지출 합계 계산 
    SELECT SUM(s.가격) 
    INTO p_total_price
    FROM 예약 r
    JOIN 상영관 s ON r.극장번호 = s.극장번호 AND r.상영관번호 = s.상영관번호
    WHERE r.고객번호 = p_custid;

    DBMS_OUTPUT.PUT_LINE('고객번호 ' || p_custid || '님의 총 지출 금액: ' || NVL(p_total_price, 0) || '원');
EXCEPTION
    WHEN OTHERS THEN
        p_total_price := 0;
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
END;
/

-- 14. 예약 삽입 시 해당 상영관의 좌석 수보다 예약 건수가 많으면 오류 메시지를 출력하고 삽입을 중단하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE proc_insert_reservation_check(
    p_theater_id IN 예약.극장번호%TYPE,
    p_room_id    IN 예약.상영관번호%TYPE,
    p_custid     IN 예약.고객번호%TYPE,
    p_seat_id    IN 예약.좌석번호%TYPE,
    p_date       IN 예약.날짜%TYPE
)
IS
    v_max_seats NUMBER;
    v_current_reserves NUMBER;
BEGIN
    -- 1. 해당 상영관의 전체 좌석 수 조회 [cite: 30]
    SELECT 좌석수 INTO v_max_seats
    FROM 상영관
    WHERE 극장번호 = p_theater_id AND 상영관번호 = p_room_id;

    -- 2. 현재 해당 상영관의 예약 건수 조회 [cite: 31]
    SELECT COUNT(*) INTO v_current_reserves
    FROM 예약
    WHERE 극장번호 = p_theater_id AND 상영관번호 = p_room_id AND 날짜 = p_date;

    -- 3. 좌석 여유 확인 및 삽입 로직 
    IF v_current_reserves >= v_max_seats THEN
        DBMS_OUTPUT.PUT_LINE('오류: 해당 상영관의 모든 좌석이 매진되었습니다.');
    ELSE
        INSERT INTO 예약(극장번호, 상영관번호, 고객번호, 좌석번호, 날짜)
        VALUES(p_theater_id, p_room_id, p_custid, p_seat_id, p_date);
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('예약이 정상적으로 완료되었습니다.');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('오류: 상영관 정보를 찾을 수 없습니다.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
END;
/

-- 15. 특정 극장번호와 날짜를 입력받아, 그날 예약이 없는 상영관 목록을 출력하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE proc_no_reserve_rooms(
    p_theater_id IN 극장.극장번호%TYPE,
    p_date       IN 예약.날짜%TYPE
)
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('극장번호 ' || p_theater_id || ' - ' || p_date || ' 미예약 상영관 목록');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------');

    -- 상영관 테이블에는 있지만, 특정 날짜의 예약 테이블에는 없는 상영관 조회 
    FOR rec IN (
        SELECT 상영관번호, 영화제목
        FROM 상영관
        WHERE 극장번호 = p_theater_id
        AND 상영관번호 NOT IN (
            SELECT DISTINCT 상영관번호
            FROM 예약
            WHERE 극장번호 = p_theater_id AND 날짜 = p_date
        )
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('상영관 번호: ' || rec.상영관번호 || ' | 상영영화: ' || rec.영화제목);
    END LOOP;
END;
/

-- 1. 학번을 입력받아 해당 학생의 이름, 전공, 학년을 출력하는 프로시저를 작성하시오. [cite: 56]
CREATE OR REPLACE PROCEDURE proc_get_student_info(
    p_std_id IN 학생.학번%TYPE
)
IS
    v_name  학생.이름%TYPE;
    v_major 학생.전공%TYPE;
    v_grade 학생.학년%TYPE;
BEGIN
    SELECT 이름, 전공, 학년 INTO v_name, v_major, v_grade
    FROM 학생
    WHERE 학번 = p_std_id;

    DBMS_OUTPUT.PUT_LINE('이름: ' || v_name || ' | 전공: ' || v_major || ' | 학년: ' || v_grade);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('오류: 학번(' || p_std_id || ')에 해당하는 학생이 없습니다.');
END;
/

-- 2. 새로운 학생 정보(학번, 이름, 전공, 학년)를 입력받아 학생 테이블에 삽입하는 프로시저를 작성하시오. [cite: 57]
CREATE OR REPLACE PROCEDURE proc_insert_student(
    p_std_id IN 학생.학번%TYPE,
    p_name   IN 학생.이름%TYPE,
    p_major  IN 학생.전공%TYPE,
    p_grade  IN 학생.학년%TYPE
)
IS
BEGIN
    INSERT INTO 학생(학번, 이름, 전공, 학년)
    VALUES(p_std_id, p_name, p_major, p_grade);
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('학생 정보가 성공적으로 등록되었습니다.');

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('오류: 이미 존재하는 학번입니다.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
END;
/

-- 3. 학번과 새로운 학년을 입력받아 해당 학생의 학년 정보를 수정하는 프로시저를 작성하시오. [cite: 58]
CREATE OR REPLACE PROCEDURE proc_update_student_grade(
    p_std_id    IN 학생.학번%TYPE,
    p_new_grade IN 학생.학년%TYPE
)
IS
BEGIN
    UPDATE 학생
    SET 학년 = p_new_grade
    WHERE 학번 = p_std_id;

    IF SQL%NOTFOUND THEN
        DBMS_OUTPUT.PUT_LINE('오류: 해당 학번의 학생을 찾을 수 없습니다.');
    ELSE
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('학년 정보가 수정되었습니다.');
    END IF;
END;
/

-- 4. 학번을 입력받아 해당 학생의 수강 내역을 모두 삭제한 후 학생 정보도 삭제하는 프로시저를 작성하시오. 
CREATE OR REPLACE PROCEDURE proc_delete_student_all(
    p_std_id IN 학생.학번%TYPE
)
IS
BEGIN
    -- 외래키 제약을 고려하여 자식 테이블(수강)부터 삭제 
    DELETE FROM 수강 WHERE 학번 = p_std_id;
    -- 부모 테이블(학생) 삭제 
    DELETE FROM 학생 WHERE 학번 = p_std_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('학번 ' || p_std_id || ' 학생의 모든 정보가 삭제되었습니다.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
END;
/

-- 5. 과목코드를 입력받아 해당 과목의 과목이름, 강의실, 요일, 담당교수를 출력하는 프로시저를 작성하시오. [cite: 60]
CREATE OR REPLACE PROCEDURE proc_get_course_info(
    p_course_id IN 과목.과목코드%TYPE
)
IS
    v_cname 학생.이름%TYPE; -- 과목이름
    v_room  과목.강의실%TYPE;
    v_day   과목.요일%TYPE;
    v_prof  과목.담당교수%TYPE;
BEGIN
    SELECT 과목이름, 강의실, 요일, 담당교수 
    INTO v_cname, v_room, v_day, v_prof
    FROM 과목
    WHERE 과목코드 = p_course_id;

    DBMS_OUTPUT.PUT_LINE('과목명: ' || v_cname || ' | 강의실: ' || v_room || 
                         ' | 요일: ' || v_day || ' | 담당교수: ' || v_prof);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('오류: 해당 과목코드 정보를 찾을 수 없습니다.');
END;
/

-- 6. 전공을 입력받아 해당 전공 학생들의 학번과 이름 전체를 출력하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE proc_students_by_major(
    p_major IN 학생.전공%TYPE
)
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('전공 [' || p_major || '] 학생 목록');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
    
    -- 전공 조건에 맞는 학생들을 루프로 출력
    FOR rec IN (
        SELECT 학번, 이름
        FROM 학생
        WHERE 전공 = p_major
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('학번: ' || rec.학번 || ' | 이름: ' || rec.이름);
    END LOOP;
END;
/

-- 7. 학번을 입력받아 해당 학생이 수강한 과목명, 수강학기, 성적을 모두 출력하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE proc_student_course_list(
    p_std_id IN 학생.학번%TYPE
)
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('학번 [' || p_std_id || '] 수강 내역');
    
    -- 수강 테이블과 과목 테이블을 조인하여 과목이름 추출
    FOR rec IN (
        SELECT k.과목이름, s.수강학기, s.성적
        FROM 수강 s
        JOIN 과목 k ON s.과목코드 = k.과목코드
        WHERE s.학번 = p_std_id
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('과목: ' || rec.과목이름 || ' | 학기: ' || rec.수강학기 || ' | 성적: ' || NVL(TO_CHAR(rec.성적), '미입력'));
    END LOOP;
END;
/

-- 8. 담당교수 이름을 입력받아 해당 교수가 강의하는 과목을 수강한 학생들의 이름과 성적을 출력하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE proc_students_by_professor(
    p_prof_name IN 과목.담당교수%TYPE
)
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('담당교수 [' || p_prof_name || '] 수강 학생 목록');
    
    -- 학생, 수강, 과목 3개 테이블 조인
    FOR rec IN (
        SELECT h.이름, s.성적
        FROM 학생 h
        JOIN 수강 s ON h.학번 = s.학번
        JOIN 과목 k ON s.과목코드 = k.과목코드
        WHERE k.담당교수 = p_prof_name
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('학생이름: ' || rec.이름 || ' | 성적: ' || rec.성적);
    END LOOP;
END;
/

-- 9. 수강학기를 입력받아 해당 학기에 수강 인원이 가장 많은 과목 이름과 인원수를 출력하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE proc_popular_course_by_semester(
    p_semester IN 수강.수강학기%TYPE
)
IS
BEGIN
    -- 인라인 뷰(서브쿼리)를 사용하여 인원수 내림차순 정렬 후 최상위 1건 추출
    FOR rec IN (
        SELECT * FROM (
            SELECT k.과목이름, COUNT(s.학번) as cnt
            FROM 수강 s
            JOIN 과목 k ON s.과목코드 = k.과목코드
            WHERE s.수강학기 = p_semester
            GROUP BY k.과목이름
            ORDER BY cnt DESC
        ) WHERE ROWNUM = 1
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('학기: ' || p_semester);
        DBMS_OUTPUT.PUT_LINE('가장 많이 수강한 과목: ' || rec.과목이름 || ' | 수강인원: ' || rec.cnt || '명');
    END LOOP;
END;
/

-- 10. 특정 요일을 입력받아 그 요일에 강의가 있는 과목 목록과 강의실을 출력하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE proc_courses_by_day(
    p_day IN 과목.요일%TYPE
)
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE(p_day || '요일 강의 목록');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
    
    FOR rec IN (
        SELECT 과목이름, 강의실
        FROM 과목
        WHERE 요일 = p_day
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('과목명: ' || rec.과목이름 || ' | 강의실: ' || rec.강의실);
    END LOOP;
END;
/

-- 11. 학번을 입력받아 해당 학생의 전체 평균 성적을 OUT 매개변수로 반환하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE proc_student_avg(
    p_std_id IN 학생.학번%TYPE,
    p_avg_score OUT NUMBER
)
IS
BEGIN
    -- 학번에 해당하는 모든 과목의 성적 평균 계산 
    SELECT AVG(성적) 
    INTO p_avg_score
    FROM 수강
    WHERE 학번 = p_std_id;

    DBMS_OUTPUT.PUT_LINE('학번 ' || p_std_id || ' 학생의 평균 성적: ' || ROUND(p_avg_score, 2));
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_avg_score := 0;
        DBMS_OUTPUT.PUT_LINE('해당 학생의 수강 내역이 없습니다.');
END;
/

-- 12. 과목코드를 입력받아 해당 과목의 수강생 평균 성적과 최고 성적, 최저 성적을 출력하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE proc_course_stats(
    p_course_id IN 과목.과목코드%TYPE
)
IS
    v_avg NUMBER;
    v_max NUMBER;
    v_min NUMBER;
BEGIN
    -- 특정 과목의 평균, 최고, 최저 점수 산출 
    SELECT AVG(성적), MAX(성적), MIN(성적)
    INTO v_avg, v_max, v_min
    FROM 수강
    WHERE 과목코드 = p_course_id;

    DBMS_OUTPUT.PUT_LINE('과목코드: ' || p_course_id);
    DBMS_OUTPUT.PUT_LINE('평균 성적: ' || ROUND(v_avg, 2));
    DBMS_OUTPUT.PUT_LINE('최고 성적: ' || v_max);
    DBMS_OUTPUT.PUT_LINE('최저 성적: ' || v_min);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('해당 과목의 수강생이 없습니다.');
END;
/

-- 13. 학년을 입력받아 해당 학년 학생들의 전공별 평균 성적을 출력하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE proc_grade_major_avg(
    p_grade IN 학생.학년%TYPE
)
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE(p_grade || '학년 전공별 평균 성적 목록');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------');

    -- 학생 테이블과 수강 테이블을 조인하여 전공별로 그룹화 
    FOR rec IN (
        SELECT h.전공, AVG(s.성적) as avg_score
        FROM 학생 h
        JOIN 수강 s ON h.학번 = s.학번
        WHERE h.학년 = p_grade
        GROUP BY h.전공
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('전공: ' || rec.전공 || ' | 평균 성적: ' || ROUND(rec.avg_score, 2));
    END LOOP;
END;
/

-- 14. 수강 신청 시 동일 학번과 과목코드로 이미 수강 내역이 존재하면 '이미 수강 중입니다' 메시지를 출력하고 삽입을 중단하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE proc_enroll_check(
    p_std_id     IN 수강.학번%TYPE,
    p_course_id  IN 수강.과목코드%TYPE,
    p_semester   IN 수강.수강학기%TYPE
)
IS
    v_count NUMBER;
BEGIN
    -- 1. 동일 학번과 과목코드의 수강 내역이 있는지 확인 
    SELECT COUNT(*) INTO v_count
    FROM 수강
    WHERE 학번 = p_std_id AND 과목코드 = p_course_id;

    -- 2. 조건에 따른 처리
    IF v_count > 0 THEN
        -- 이미 존재할 경우 메시지 출력 및 중단 
        DBMS_OUTPUT.PUT_LINE('이미 수강 중입니다');
    ELSE
        -- 존재하지 않을 경우 수강 테이블에 삽입 
        INSERT INTO 수강(과목코드, 학번, 수강학기)
        VALUES(p_course_id, p_std_id, p_semester);
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('수강 신청이 정상적으로 완료되었습니다.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
END;
/

-- 15. 특정 수강학기를 입력받아 성적이 NULL인 학생의 학번, 이름, 과목이름을 출력하고 성적 미입력 건수를 OUT 매개변수로 반환하는 프로시저를 작성하시오.
CREATE OR REPLACE PROCEDURE proc_null_grade_list(
    p_semester     IN 수강.수강학기%TYPE,
    p_null_count   OUT NUMBER
)
IS
BEGIN
    -- 1. 성적 미입력 건수 계산 (OUT 매개변수 대입) 
    SELECT COUNT(*) INTO p_null_count
    FROM 수강
    WHERE 수강학기 = p_semester AND 성적 IS NULL;

    DBMS_OUTPUT.PUT_LINE('학기 [' || p_semester || '] 성적 미입력 명단');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------');

    -- 2. 성적이 NULL인 학생 목록 출력 
    FOR rec IN (
        SELECT h.학번, h.이름, k.과목이름
        FROM 수강 s
        JOIN 학생 h ON s.학번 = h.학번
        JOIN 과목 k ON s.과목코드 = k.과목코드
        WHERE s.수강학기 = p_semester AND s.성적 IS NULL
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('학번: ' || rec.학번 || ' | 이름: ' || rec.이름 || ' | 과목: ' || rec.과목이름);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('총 미입력 건수: ' || p_null_count);

EXCEPTION
    WHEN OTHERS THEN
        p_null_count := 0;
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
END;
/
