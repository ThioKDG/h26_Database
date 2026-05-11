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
CREATE OR REPLACE PROCEDURE searchOrder(
    o_custid in ORDERS.custid%TYPE
)
IS

CURSOR order_cursor IS
    SELECT bookid, bookname, price
    FROM Book
    WHERE publisher = b_publisher;
    
    v_bookname  book.BOOKNAME%TYPE;
    v_saleprice orders.SALEPRICE%TYPE;
    v_orderdate orders.ORDERDATE%TYPE;
BEGIN
    -- 코드를 입력하세요
END;