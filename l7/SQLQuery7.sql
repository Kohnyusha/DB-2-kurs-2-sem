use Univer;

--1)
CREATE VIEW [�������������]
       as select T.TEACHER [���],
                 T.TEACHER_NAME [��� �������������],
	             T.GENDER [���],
	             T.PULPIT [�������]
	             FROM TEACHER T;

SELECT * from [�������������]

ALTER VIEW [�������������]
       as select T.TEACHER [���],
                 T.TEACHER_NAME [��� �������������],
	             T.PULPIT [�������]
	             FROM TEACHER T;

DROP VIEW [�������������];

--2)�� ����� ��������
CREATE VIEW [���������� ������]
       as select F.FACULTY_NAME [���������],
	             COUNT (*) [���������� ������]
	             FROM FACULTY F INNER JOIN PULPIT P
	             ON F.FACULTY = P.FACULTY
				 GROUP BY F.FACULTY_NAME

SELECT * from [���������� ������]

--3)
CREATE VIEW [���������]
       as select A.AUDITORIUM [���],
	             A.AUDITORIUM_NAME [������������_���������],
				 A.AUDITORIUM_TYPE [���]
	             FROM AUDITORIUM A
				      where A.AUDITORIUM_TYPE like '��%'

SELECT * FROM [���������];
DROP VIEW [���������];

INSERT ��������� 
       values ('345-1', '345-1', '��-�')

--4)
CREATE VIEW [���������� ���������]
            as select A.AUDITORIUM [���],
	                  A.AUDITORIUM_NAME [������������_���������],
				      A.AUDITORIUM_TYPE [���]
			          FROM AUDITORIUM A
					  where A.AUDITORIUM_TYPE like '��%' WITH CHECK OPTION;

INSERT ��������� 
       values ('355-1', '355-1', '��-�')

SELECT * FROM [���������� ���������];

--5)
CREATE VIEW [����������]
            as select TOP 10 S.SUBJECT [���],
			                 S.SUBJECT_NAME [������������ ����������],
					         S.PULPIT [��� �������]
			                 FROM SUBJECT S
							 ORDER BY S.SUBJECT

SELECT * FROM [����������];

--6)
ALTER VIEW [���������� ������] WITH SCHEMABINDING
       as select DBO.FACULTY.FACULTY_NAME [���������],
	             COUNT (*) [���������� ������]
	             FROM DBO.FACULTY  INNER JOIN DBO.PULPIT P
	             ON FACULTY.FACULTY = P.FACULTY
				 GROUP BY FACULTY.FACULTY_NAME

SELECT * from [���������� ������]

