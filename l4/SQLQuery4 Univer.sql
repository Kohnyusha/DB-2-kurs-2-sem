use Univer

SELECT AUDITORIUM.AUDITORIUM, AUDITORIUM_TYPE.AUDITORIUM_TYPENAME---1
	   From AUDITORIUM Inner Join AUDITORIUM_TYPE
	   On AUDITORIUM.AUDITORIUM_TYPE = AUDITORIUM_TYPE.AUDITORIUM_TYPE

SELECT AUDITORIUM.AUDITORIUM, AUDITORIUM_TYPE.AUDITORIUM_TYPENAME---2
       From AUDITORIUM Inner Join AUDITORIUM_TYPE
	   On AUDITORIUM.AUDITORIUM_TYPE = AUDITORIUM_TYPE.AUDITORIUM_TYPE And
				AUDITORIUM.AUDITORIUM_TYPE Like '%���������%'

SELECT T1.AUDITORIUM, T2.AUDITORIUM_TYPENAME---3
       From AUDITORIUM As T1, AUDITORIUM_TYPE As T2
	        Where T1.AUDITORIUM_TYPE = T2.AUDITORIUM_TYPE

SELECT FACULTY.FACULTY, PULPIT.PULPIT, PROFESSION.PROFESSION_NAME, SUBJECT.SUBJECT_NAME, STUDENT.NAME, PROGRESS.NOTE,---4
       Case
			When (PROGRESS.NOTE = 6) then '�����'
			When (PROGRESS.NOTE = 7) then '����'
			When (PROGRESS.NOTE = 8) then '������'
	   END
	   FROM FACULTY, PULPIT, PROFESSION, SUBJECT,
			STUDENT Inner Join PROGRESS
			On PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT 
				ORDER BY FACULTY.FACULTY, PULPIT.PULPIT, PROFESSION.PROFESSION_NAME, STUDENT.NAME asc,
				         PROGRESS.NOTE desc

SELECT FACULTY.FACULTY, PULPIT.PULPIT, PROFESSION.PROFESSION_NAME, SUBJECT.SUBJECT_NAME, STUDENT.NAME, PROGRESS.NOTE,---5
	   Case
	   		When (PROGRESS.NOTE = 6) then '�����' 
	   		When (PROGRESS.NOTE = 7) then '����'
	   		When (PROGRESS.NOTE = 8) then '������'
	   END
	   FROM FACULTY, PULPIT, PROFESSION, SUBJECT,
			STUDENT Inner Join PROGRESS
			On PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT 
				ORDER BY 
				(CASE
						 When (PROGRESS.NOTE = 6) then 3 
						 When (PROGRESS.NOTE = 7) then 1
						 When (PROGRESS.NOTE = 8) then 2
				 END)
			
SELECT isnull (TEACHER.TEACHER_NAME, '***') [�������������], PULPIT.PULPIT_NAME [�������]---6
       FROM PULPIT Left Outer JOIN TEACHER
			ON PULPIT.PULPIT = TEACHER.PULPIT 

SELECT isnull (TEACHER.TEACHER_NAME, '***') [�������������], PULPIT.PULPIT_NAME [�������]---7
       FROM TEACHER Left Outer JOIN PULPIT
			ON PULPIT.PULPIT = TEACHER.PULPIT 	 
			
SELECT isnull (TEACHER.TEACHER_NAME, '***') [�������������], PULPIT.PULPIT_NAME [�������]
       FROM PULPIT Right Outer JOIN TEACHER
			ON PULPIT.PULPIT = TEACHER.PULPIT 
			
SELECT * FROM TEACHER FULL OUTER jOIN PULPIT--8
	   ON PULPIT.PULPIT = TEACHER.PULPIT

SELECT * FROM AUDITORIUM_TYPE FULL OUTER JOIN AUDITORIUM--8.1
	ON AUDITORIUM.AUDITORIUM_TYPE = AUDITORIUM_TYPE.AUDITORIUM_TYPE
	where AUDITORIUM_TYPE.AUDITORIUM_TYPE is NOT NULL

SELECT * FROM AUDITORIUM_TYPE FULL OUTER JOIN AUDITORIUM--8.2
	ON AUDITORIUM.AUDITORIUM_TYPE = AUDITORIUM_TYPE.AUDITORIUM_TYPE
	where AUDITORIUM.AUDITORIUM_TYPE is NOT NULL

SELECT * FROM AUDITORIUM_TYPE FULL OUTER JOIN AUDITORIUM--8.3
	ON AUDITORIUM.AUDITORIUM_TYPE = AUDITORIUM_TYPE.AUDITORIUM_TYPE
	where AUDITORIUM.AUDITORIUM_TYPE is NOT NULL and AUDITORIUM_TYPE.AUDITORIUM_TYPE is NOT NULL

SELECT * FROM AUDITORIUM CROSS JOIN AUDITORIUM_TYPE--9
