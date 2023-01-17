use Univer;

--1)
SELECT max(A.AUDITORIUM_CAPACITY) [������������ �����������],
	   avg(A.AUDITORIUM_CAPACITY) [������� �����������],
	   min(A.AUDITORIUM_CAPACITY) [����������� �����������],
	   sum(A.AUDITORIUM_CAPACITY) [��������� �����������],
	   count(*)                   [����� ���������� ���������]
       FROM AUDITORIUM A

--2)��� ������� ����
SELECT AT.AUDITORIUM_TYPENAME,
	   max(A.AUDITORIUM_CAPACITY) [������������ �����������],
	   min(A.AUDITORIUM_CAPACITY) [����������� �����������],
	   avg(A.AUDITORIUM_CAPACITY) [������� �����������],
	   sum(A.AUDITORIUM_CAPACITY) [��������� �����������],
	   count(*)                   [����� ���������� ���������]
       FROM AUDITORIUM A INNER JOIN AUDITORIUM_TYPE AT
            ON A.AUDITORIUM_TYPE = AT.AUDITORIUM_TYPE
	        GROUP BY AUDITORIUM_TYPENAME

--3)
SELECT * FROM 
(
	   SELECT 
	   CASE 
	         WHEN NOTE between 4 and 5 then '4-5'
			 WHEN NOTE between 6 and 7 then '6-7'
			 WHEN NOTE between 8 and 9 then '8-9'
			 else '10'
	   END [������� �������], count(*) [����������]
	   FROM PROGRESS 
	   GROUP BY
	   CASE
			WHEN NOTE between 4 and 5 then '4-5'
			WHEN NOTE between 6 and 7 then '6-7'
			WHEN NOTE between 8 and 9 then '8-9'
			else '10'
       END
) AS TAB
	   ORDER BY 
	   CASE [������� �������]
	        WHEN '4-5' then 3
			WHEN '6-7' then 2
			WHEN '8-9' then 1
			else 0
       END

--4.1)�� �� ��� ���� ����� ���� ����
SElECT F.FACULTY [���������], G.PROFESSION [�������������],
	   CASE 
	        when G.YEAR_FIRST = 2010 then '4'
			when G.YEAR_FIRST = 2011 then '3'
			when G.YEAR_FIRST = 2012 then '2'
			when G.YEAR_FIRST = 2013 then '1'
	   END [����],
	        round(avg(cast(P.NOTE as float(4))), 2) [������� ������]
       FROM PROGRESS P
	   INNER JOIN STUDENT S ON P.IDSTUDENT = S.IDSTUDENT
       INNER JOIN GROUPS G ON S.IDGROUP = G.IDGROUP
       INNER JOIN FACULTY F ON G.FACULTY = F.FACULTY
       GROUP BY F.FACULTY, G.PROFESSION, G.YEAR_FIRST, P.NOTE 

--4.2)
SElECT F.FACULTY [���������], G.PROFESSION [�������������],
	   CASE 
	        when G.YEAR_FIRST = 2010 then '4'
			when G.YEAR_FIRST = 2011 then '3'
			when G.YEAR_FIRST = 2012 then '2'
			when G.YEAR_FIRST = 2013 then '1'
	   END [����],
	        round(avg(cast(P.NOTE as float(4))), 2) [������� ������]
       FROM PROGRESS P
	   INNER JOIN STUDENT S ON P.IDSTUDENT = S.IDSTUDENT
       INNER JOIN GROUPS G ON S.IDGROUP = G.IDGROUP
       INNER JOIN FACULTY F ON G.FACULTY = F.FACULTY
	   WHERE P.SUBJECT in ('��', '����')
       GROUP BY F.FACULTY, G.PROFESSION, G.YEAR_FIRST, P.NOTE

--5.1)
SELECT F.FACULTY, G.PROFESSION, P.SUBJECT, ROUND(AVG(CAST(P.NOTE as float(4))), 2) [������� ������]
       FROM PROGRESS P
       INNER JOIN STUDENT S ON P.IDSTUDENT = S.IDSTUDENT
       INNER JOIN GROUPS G ON S.IDGROUP = G.IDGROUP
       INNER JOIN FACULTY F ON G.FACULTY = F.FACULTY
	   WHERE G.FACULTY = '���' 
GROUP BY F.FACULTY, G.PROFESSION, P.SUBJECT

--5.2)ROLLUP ���������� ���������� ����� � �������� �����, 
--������� ���������� � �������, � ������� ������ ������������ �������
SELECT F.FACULTY, G.PROFESSION, P.SUBJECT, ROUND(AVG(CAST(P.NOTE as float(4))), 2) [������� ������]
       FROM PROGRESS P
       INNER JOIN STUDENT S ON P.IDSTUDENT = S.IDSTUDENT
       INNER JOIN GROUPS G ON S.IDGROUP = G.IDGROUP
       INNER JOIN FACULTY F ON G.FACULTY = F.FACULTY
	   WHERE G.FACULTY = '���'
GROUP BY ROLLUP (F.FACULTY, G.PROFESSION, P.SUBJECT)

--6)����������� CUBE ���������� ����� ��������� ���������� ����� � �������� �����.
SELECT F.FACULTY, G.PROFESSION, P.SUBJECT, ROUND(AVG(CAST(P.NOTE as float(4))), 2) [������� ������]
       FROM PROGRESS P
       INNER JOIN STUDENT S ON P.IDSTUDENT = S.IDSTUDENT
       INNER JOIN GROUPS G ON S.IDGROUP = G.IDGROUP
       INNER JOIN FACULTY F ON G.FACULTY = F.FACULTY
	   WHERE G.FACULTY = '���'
GROUP BY CUBE (F.FACULTY, G.PROFESSION, P.SUBJECT)

--7.1)���������� ����� ���������
SELECT G.PROFESSION, P.SUBJECT, ROUND(AVG(CAST(P.NOTE as float(4))), 2) [������� ������]
       FROM PROGRESS P
	   INNER JOIN STUDENT S ON S.IDSTUDENT = P.IDSTUDENT
       INNER JOIN GROUPS G ON G.IDGROUP = S.IDGROUP
	   WHERE G.FACULTY = '���'
	   GROUP BY G.PROFESSION, P.SUBJECT
	   UNION
SELECT G.PROFESSION, P.SUBJECT, ROUND(AVG(CAST(P.NOTE as float(4))), 2) [������� ������]
       FROM PROGRESS P
	   INNER JOIN STUDENT S ON S.IDSTUDENT = P.IDSTUDENT
       INNER JOIN GROUPS G ON G.IDGROUP = S.IDGROUP
	   WHERE G.FACULTY = '����'
	   GROUP BY G.PROFESSION, P.SUBJECT

--7.2)
SELECT G.PROFESSION, P.SUBJECT, ROUND(AVG(CAST(P.NOTE as float(4))), 2) [������� ������]
       FROM PROGRESS P
	   INNER JOIN STUDENT S ON S.IDSTUDENT = P.IDSTUDENT
       INNER JOIN GROUPS G ON G.IDGROUP = S.IDGROUP
	   WHERE G.FACULTY = '���'
	   GROUP BY G.PROFESSION, P.SUBJECT
	   UNION ALL
SELECT G.PROFESSION, P.SUBJECT, ROUND(AVG(CAST(P.NOTE as float(4))), 2) [������� ������]
       FROM PROGRESS P
	   INNER JOIN STUDENT S ON S.IDSTUDENT = P.IDSTUDENT
       INNER JOIN GROUPS G ON G.IDGROUP = S.IDGROUP
	   WHERE G.FACULTY = '����'
	   GROUP BY G.PROFESSION, P.SUBJECT

--8)
SELECT G.PROFESSION, P.SUBJECT, ROUND(AVG(CAST(P.NOTE as float(4))), 2) [������� ������]
       FROM PROGRESS P
	   INNER JOIN STUDENT S ON S.IDSTUDENT = P.IDSTUDENT
       INNER JOIN GROUPS G ON G.IDGROUP = S.IDGROUP
	   WHERE G.FACULTY = '���'
	   GROUP BY G.PROFESSION, P.SUBJECT
	   INTERSECT
SELECT G.PROFESSION, P.SUBJECT, ROUND(AVG(CAST(P.NOTE as float(4))), 2) [������� ������]
       FROM PROGRESS P
	   INNER JOIN STUDENT S ON S.IDSTUDENT = P.IDSTUDENT
       INNER JOIN GROUPS G ON G.IDGROUP = S.IDGROUP
	   WHERE G.FACULTY = '����'
	   GROUP BY G.PROFESSION, P.SUBJECT

--9)
SELECT G.PROFESSION, P.SUBJECT, ROUND(AVG(CAST(P.NOTE as float(4))), 2) [������� ������]
       FROM PROGRESS P
	   INNER JOIN STUDENT S ON S.IDSTUDENT = P.IDSTUDENT
       INNER JOIN GROUPS G ON G.IDGROUP = S.IDGROUP
	   WHERE G.FACULTY = '���'
	   GROUP BY G.PROFESSION, P.SUBJECT
	   EXCEPT
SELECT G.PROFESSION, P.SUBJECT, ROUND(AVG(CAST(P.NOTE as float(4))), 2) [������� ������]
       FROM PROGRESS P
	   INNER JOIN STUDENT S ON S.IDSTUDENT = P.IDSTUDENT
       INNER JOIN GROUPS G ON G.IDGROUP = S.IDGROUP
	   WHERE G.FACULTY = '����'
	   GROUP BY G.PROFESSION, P.SUBJECT

--10)��� ������ ���������� ���������� ������-���, ���������� ������ 8 � 9
SELECT P1.SUBJECT, P1.NOTE, 
(
	SELECT COUNT(*)
	FROM PROGRESS P2
	WHERE P2.SUBJECT = P1.SUBJECT AND P2.NOTE = P1.NOTE
) [����������]
FROM PROGRESS P1
GROUP BY P1.SUBJECT, P1.NOTE
HAVING	P1.NOTE = 8 OR P1.NOTE = 9