-- 1 교재 질의
-- 1 사원의 이름과 업무를 출력하시오. 단 사원의 이름은‘사원이름’, ‘업무는 ’사원업무‘, 머리글'이 나오도록 출력하시오.
select ename as "사원이름", job as "사원업무"
from emp;

-- 2 30번 부서에 근무하는 모든 사원의 이름과 급여를 출력하시오
select ename, sal
from emp
where deptno = 30;

-- 3 사원번호와 이름, 현재급여, 증가된 급여분(열 이름은 증가액), 10% 인상된 급여(열 이름은 ’인상된 급여‘)를 사원 번호 순으로 출력하시오. 
select empno as "사원번호", 
       ename as "이름",
         sal as "사원번호", 
         sal * 0.1 as "증가액",
         sal * 1.1 as "인상된 급여"
  from emp
 order by empno;
 
-- 4 'S'로 시작하는 모든 사원의 부서번호를 출력하시오
select DISTINCT deptno
  from emp
 where ename like 'S%';
 
-- 5 모든 사원의 최대 및 최소 급여, 합계 및 평균 급여를 출력하시오. 열이름은 각각 MAX, MIN, SUM, AVG로 한다. 단 소수점 이하는 반올림하여 정수로 출력한다.
select round(max(sal)) as "MAX", 
       round(min(sal)) as "MIN", 
       round(sum(sal)) as "SUM", 
       round(avg(sal)) as "AVG"
from emp;

-- 6 업무별로 동일한 업무를 하는 사원의 수를 출력하시오 열이름은 각각 업무와 업무별 사원수로 한다
select job as "업무", count(*) as "업무별 사원 수"
from emp
group by job;

-- 7 사원의 최대 급여와 최소 급여의 차액을 출력하시오
select max(sal)-min(sal)
from emp;

-- 8 30번 부서의 사원 수와 사원들 급여의 합계와 평균을 출력하시오.
select count(*), sum(sal), round(avg(sal))
from emp
where deptno = 30;

-- 9 평균 급여가 가장 높은 부서의 번호를 출력하시오.
select deptno
from emp
 group by deptno
 having avg(sal)=(
    select max(avg(sal))
    from emp
    group by deptno
 );

-- 10 세일즈맨을 제외하고, 각 업무별 사원의 총 급여가 3000이상인 가가 업무에 대해서 업무명과 각 업무별 평균 급여를 출력하시오
select job, round(avg(sal))
from emp
where job != 'SALESMAN'
group by job
having sum(sal) >= 3000;

-- 11 전체 사원 가운데 직속 상관이 있는 사원의 수를 출력하시오
select count(*)
from emp
where mgr is not null;

-- 12 emp 테이블에서 급여, 커미션 금액, 총액(sal*12+comm)을 구하여 총액이 많은 순서대로 출력하시오
SELECT (sal * 12) + NVL(comm, 0) AS "총액"
FROM emp
ORDER BY "총액" DESC;

-- 13 부서별로 같은 업무를 하는 사람의 인원수를 구하여 부서번호 업무 이름 인원수를 출력하시오
select deptno, job, count(*) as "인원수"
from emp
group by deptno, job
order by deptno;

-- 14 사원이 한명도 없는 부서의 번호를 출력하시오
select deptno
  from emp
 where deptno not in (select DISTINCT deptno from emp);

-- 15 같은 업무를 하는 사람의 수가 4명 이상인 업무와 인원수를 출력하시오
select job, count(*) as "인원수"
  from emp
  group by job
 having count(job) >= 4;
 
-- 16 사원번호가 7400 7600 이하인 사원의 이름을 출력하시오
select ename
  from emp
 where empno BETWEEN 7400 and 7600;

-- 17 사원의 이름과 사원의 부서이름을 출력하시오.
select e.ename, d.dname
from emp e
join dept d on d.deptno = e.deptno;

-- 18 사원의 이름과 팀장의 이름을 출력하시오
select e.ename as "사원명", m.ename as "팀장"
from emp e
join emp m on e.mgr = m.empno;

-- 19 사원 scott보다 급여를 많이 받는 사람의 이름을 출력하시오
select ename
  from emp 
 where sal > (select sal from emp where ename ='SCOTT');
 
-- 20 사원 scott이 일하는 부서번호 혹은 dallas에 있는 부서번호를 출력하시오
select deptno
from dept
where deptno = (select deptno from emp where ename='SCOTT')
   or loc = 'DALLAS';
   
-- 2 단순질의
-- 1 comm 커미션이 null이 아닌 사원의 이름과 커미션을 출력하시오
select ename, comm
from emp
where comm is not null and comm > 0;    

-- 2 급여가 1500 이상 300 이하인 사원의 이름과 급여를 급여 오름차순으로 출력하시오
select ename, sal
from emp
where sal BETWEEN 1500 and 3000
order by sal asc;

-- 3 1981년 입사한 사원의 이름과 입사일을 출력하시오
select ename, hiredate
from emp
where hiredate BETWEEN '1981-01-01' and '1981-12-31';

-- 4 'S'로 시작하는 모든 사원과 부서번호를 출력하시오
select ename, deptno
from emp
where ename like 'S%';

-- 5 사원의 이름을 소문자로 출력하시오.
select lower(ename)
from emp;

-- 6 사원 이름, 입사일, 오늘까지의 근무 개월 수 내림차순으로 출력하시오.
SELECT ename AS "이름", 
       hiredate AS "입사일", 
       TRUNC(MONTHS_BETWEEN(SYSDATE, hiredate)) AS "근무개월수"
FROM emp
ORDER BY "근무개월수" DESC;

-- 7 사원 이름과 이름의 글자 수를 글자 수 내림차순으로 출력하시오
select ename, LENGTH(ename) as "글자 수"
from emp
order by Length(ename) desc;

-- 8 comm이 null 이면 0으로 대체
select sal + nvl(comm, 0) as "총소득"
from emp;


-- 9 ANALYST 또는 PRESIDENT인 사원의 이름, 업무, 급여를 출력하시오
select ename, job, sal
from emp
where job = 'ANALYST' OR job = 'PRESIDENT';

-- 10 이름 길이가 긴 순, 같으면 알파벳 순으로 사원 이름을 출력하시오
select ename
from emp
order by Length(ename) DESC, ename asc;

-- 3 부속질의
-- 1 jones와 같은 부서에 근무하는 사원의 이름을 출력하시오(JONES 본인 제외)
select ename
from emp
where deptno = (select deptno from emp where ename='JONES')
  and ename != 'JONES';

-- 2 각 부서에서 가장 높은 급여를 받는 사원의 이름, 급여, 부서번호를 출력하시오
select e.ename, e.sal, e.deptno
from emp e
where (deptno,sal) in (select deptno, max(sal)
                         from emp e2
                        group by deptno);
                        
-- 3 30번 부서 평균 급여보다 급여가 높은 사원의 이름과 급여를 출력하시오
select ename, sal
from emp
where sal > (select avg(sal)
               from emp
             where deptno = 30);

-- ④ MANAGER 직급 평균 급여보다 적은 CLERK 사원의 이름과 급여 출력
SELECT ename, sal 
FROM emp 
WHERE job = 'CLERK' 
  AND sal < (SELECT AVG(sal) FROM emp WHERE job = 'MANAGER');

-- ⑤ 업무별 최고 급여를 받는 사원의 이름, 업무, 급여 출력
SELECT ename, job, sal 
FROM emp 
WHERE (job, sal) IN (SELECT job, MAX(sal) FROM emp GROUP BY job);

-- ⑥ KING에게 직접 보고하는 사원의 이름과 업무 출력
SELECT ename, job 
FROM emp 
WHERE mgr = (SELECT empno FROM emp WHERE ename = 'KING'); 

-- ⑦ 입사일이 가장 최근인 사원과 가장 오래된 사원을 함께 출력
SELECT ename, hiredate 
FROM emp 
WHERE hiredate = (SELECT MAX(hiredate) FROM emp) 
   OR hiredate = (SELECT MIN(hiredate) FROM emp); 

-- ⑧ 전체 평균 급여보다 급여가 높고 직위가 MANAGER인 사원 출력
SELECT * FROM emp 
WHERE sal > (SELECT AVG(sal) FROM emp) AND job = 'MANAGER'; 

-- ⑨ 급여가 전체 사원 급여 합계의 10%를 초과하는 사원의 이름과 급여 출력
SELECT ename, sal 
FROM emp 
WHERE sal > (SELECT SUM(sal) * 0.1 FROM emp);

-- ⑩ BLAKE와 같은 직위(job)를 가진 사원의 이름, 급여 출력 (본인 제외)
SELECT ename, sal 
FROM emp 
WHERE job = (SELECT job FROM emp WHERE ename = 'BLAKE') 
  AND ename != 'BLAKE'; 

-- ⑪ 30번 부서에 속한 사원과 같은 직위(job)를 가진 모든 사원 출력
SELECT * FROM emp 
WHERE job IN (SELECT DISTINCT job FROM emp WHERE deptno = 30); 

-- ⑫ 급여가 모든 CLERK보다 많은 사원의 이름과 급여 출력 (ALL 사용)
SELECT ename, sal 
FROM emp 
WHERE sal > ALL (SELECT sal FROM emp WHERE job = 'CLERK');

-- ⑬ SALESMAN 중 누구보다도 급여가 많은 사원의 이름과 급여 출력 (ANY 사용)
SELECT ename, sal 
FROM emp 
WHERE sal > ANY (SELECT sal FROM emp WHERE job = 'SALESMAN');

-- ⑭ 부하 직원이 존재하는 (관리자인) 사원의 이름과 직위 출력 (EXISTS 사용)
SELECT ename, job 
FROM emp e1 
WHERE EXISTS (SELECT 1 FROM emp e2 WHERE e2.mgr = e1.empno); 

-- ⑮ 급여 상위 3위 안에 드는 사원의 이름과 급여 출력
SELECT ename, sal 
FROM (SELECT ename, sal FROM emp ORDER BY sal DESC) 
WHERE ROWNUM <= 3; 

-- 4 조인질의
-- ① 사원의 이름과 소속 부서 이름 출력
SELECT e.ename, d.dname 
FROM emp e JOIN dept d ON e.deptno = d.deptno; 

-- ② 사원의 이름과 팀장의 이름 출력 (셀프 조인)
SELECT e.ename AS "사원명", m.ename AS "팀장명" 
FROM emp e JOIN emp m ON e.mgr = m.empno; 

-- ③ 사원이 한 명도 없는 부서의 이름 출력
SELECT d.dname 
FROM dept d LEFT JOIN emp e ON d.deptno = e.deptno 
WHERE e.empno IS NULL; 

-- ④ NEW YORK에 근무하는 사원의 이름과 업무 출력
SELECT e.ename, e.job 
FROM emp e JOIN dept d ON e.deptno = d.deptno 
WHERE d.loc = 'NEW YORK'; 

-- ⑤ 사원이름, 급여, 급여 등급 출력 (SALGRADE 활용)
SELECT e.ename, e.sal, s.grade 
FROM emp e JOIN salgrade s ON e.sal BETWEEN s.losal AND s.hisal;

-- ⑥ 사원이름, 급여, 급여 등급, 부서 이름을 한 번에 출력
SELECT e.ename, e.sal, s.grade, d.dname 
FROM emp e 
JOIN dept d ON e.deptno = d.deptno 
JOIN salgrade s ON e.sal BETWEEN s.losal AND s.hisal;

-- ⑦ 자신의 상관보다 급여가 높은 사원의 이름과 두 사람의 급여 출력
SELECT e.ename AS "사원", e.sal AS "사원급여", m.ename AS "상관", m.sal AS "상관급여" 
FROM emp e JOIN emp m ON e.mgr = m.empno 
WHERE e.sal > m.sal; 

-- ⑧ 사원 이름, 부서이름, 근무 도시 출력
SELECT e.ename, d.dname, d.loc 
FROM emp e JOIN dept d ON e.deptno = d.deptno;

-- ⑨ CHICAGO에 근무하는 사원 수 출력
SELECT COUNT(*) 
FROM emp e JOIN dept d ON e.deptno = d.deptno 
WHERE d.loc = 'CHICAGO';

-- ⑩ 부서별 인원 수가 많은 순으로 부서번호, 부서이름, 인원수 출력
SELECT d.deptno, d.dname, COUNT(e.empno) AS CNT 
FROM dept d LEFT JOIN emp e ON d.deptno = e.deptno 
GROUP BY d.deptno, d.dname 
ORDER BY CNT DESC; 

-- ⑪ 부서별 평균 급여를 부서이름과 함께 출력
SELECT d.dname, AVG(e.sal) 
FROM dept d LEFT JOIN emp e ON d.deptno = e.deptno 
GROUP BY d.dname;

-- ⑫ 급여 등급이 3등급인 사원의 이름, 급여, 부서이름 출력
SELECT e.ename, e.sal, d.dname 
FROM emp e 
JOIN dept d ON e.deptno = d.deptno 
JOIN salgrade s ON e.sal BETWEEN s.losal AND s.hisal 
WHERE s.grade = 3;

-- ⑬ 사원의 이름, 입사일, 입사 요일을 부서이름과 함께 출력
SELECT e.ename, e.hiredate, TO_CHAR(e.hiredate, 'DAY'), d.dname 
FROM emp e JOIN dept d ON e.deptno = d.deptno;

-- ⑭ 같은 부서에서 근무하는 사원끼리 이름을 나란히 출력 (중복제거)
SELECT DISTINCT e1.ename, e2.ename 
FROM emp e1 JOIN emp e2 ON e1.deptno = e2.deptno 
WHERE e1.ename < e2.ename; 

-- ⑮ 사원이름, 상관이름, 상관의 부서이름 출력 (셀프+DEPT 조인)
SELECT e.ename, m.ename, d.dname 
FROM emp e 
JOIN emp m ON e.mgr = m.empno 
JOIN dept d ON m.deptno = d.deptno; 


-- 5 집계 질의

-- ① 업무별 최고, 최소, 평균 급여와 사원 수 출력
SELECT job, MAX(sal), MIN(sal), AVG(sal), COUNT(*) 
FROM emp 
GROUP BY job; 

-- ② 부서별, 업무별 인원수 출력
SELECT deptno, job, COUNT(*) 
FROM emp 
GROUP BY deptno, job; 

-- ③ 직원별 총 급여(sal*12+comm)를 내림차순으로 출력
SELECT ename, (sal * 12 + NVL(comm, 0)) AS TOTAL 
FROM emp 
ORDER BY TOTAL DESC;

-- ④ 평균 급여보다 높은 급여를 받는 부서번호와 해당 부서의 평균 급여 출력
SELECT deptno, AVG(sal) 
FROM emp 
GROUP BY deptno 
HAVING AVG(sal) > (SELECT AVG(sal) FROM emp);

-- ⑤ 입사년도별 사원 수 출력
SELECT TO_CHAR(hiredate, 'YYYY'), COUNT(*) 
FROM emp 
GROUP BY TO_CHAR(hiredate, 'YYYY'); 

-- ⑥ 급여 등급별 사원 수와 평균 급여 출력
SELECT s.grade, COUNT(*), AVG(e.sal) 
FROM emp e JOIN salgrade s ON e.sal BETWEEN s.losal AND s.hisal 
GROUP BY s.grade; 

-- ⑦ 총급여(합계)가 5000 이상인 부서의 번호와 합계 출력
SELECT deptno, SUM(sal) 
FROM emp 
GROUP BY deptno 
HAVING SUM(sal) >= 5000;

-- ⑧ 각 사원의 급여가 전체 급여 합계에서 차지하는 비율(%) 출력
SELECT ename, (sal / (SELECT SUM(sal) FROM emp) * 100) || '%' 
FROM emp; 

-- ⑨ 근속 연수 10년 이상인 사원의 이름, 입사일, 근속 연수 출력
SELECT ename, hiredate, TRUNC(MONTHS_BETWEEN(SYSDATE, hiredate)/12) AS YEARS 
FROM emp 
WHERE MONTHS_BETWEEN(SYSDATE, hiredate)/12 >= 10; 

-- ⑩ 급여 상위 5명의 사원 이름과 급여 출력
SELECT ename, sal 
FROM (SELECT ename, sal FROM emp ORDER BY sal DESC) 
WHERE ROWNUM <= 5; 

-- 24 인사부서

