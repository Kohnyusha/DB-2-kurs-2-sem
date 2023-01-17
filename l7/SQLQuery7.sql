use Univer;

--1)
CREATE VIEW [Преподаватели]
       as select T.TEACHER [Код],
                 T.TEACHER_NAME [Имя преподавателя],
	             T.GENDER [Пол],
	             T.PULPIT [Кафедры]
	             FROM TEACHER T;

SELECT * from [Преподаватели]

ALTER VIEW [Преподаватели]
       as select T.TEACHER [Код],
                 T.TEACHER_NAME [Имя преподавателя],
	             T.PULPIT [Кафедры]
	             FROM TEACHER T;

DROP VIEW [Преподаватели];

--2)не соотв правилам
CREATE VIEW [Количество кафедр]
       as select F.FACULTY_NAME [Факультет],
	             COUNT (*) [Количество кафедр]
	             FROM FACULTY F INNER JOIN PULPIT P
	             ON F.FACULTY = P.FACULTY
				 GROUP BY F.FACULTY_NAME

SELECT * from [Количество кафедр]

--3)
CREATE VIEW [Аудитории]
       as select A.AUDITORIUM [Код],
	             A.AUDITORIUM_NAME [Наименование_аудитории],
				 A.AUDITORIUM_TYPE [Тип]
	             FROM AUDITORIUM A
				      where A.AUDITORIUM_TYPE like 'ЛК%'

SELECT * FROM [Аудитории];
DROP VIEW [Аудитории];

INSERT Аудитории 
       values ('345-1', '345-1', 'ЛК-К')

--4)
CREATE VIEW [Лекционные аудитории]
            as select A.AUDITORIUM [Код],
	                  A.AUDITORIUM_NAME [Наименование_аудитории],
				      A.AUDITORIUM_TYPE [Тип]
			          FROM AUDITORIUM A
					  where A.AUDITORIUM_TYPE like 'ЛК%' WITH CHECK OPTION;

INSERT Аудитории 
       values ('355-1', '355-1', 'ЛБ-К')

SELECT * FROM [Лекционные аудитории];

--5)
CREATE VIEW [Дисциплины]
            as select TOP 10 S.SUBJECT [Код],
			                 S.SUBJECT_NAME [Наименование дисциплины],
					         S.PULPIT [Код кафедры]
			                 FROM SUBJECT S
							 ORDER BY S.SUBJECT

SELECT * FROM [Дисциплины];

--6)
ALTER VIEW [Количество кафедр] WITH SCHEMABINDING
       as select DBO.FACULTY.FACULTY_NAME [Факультет],
	             COUNT (*) [Количество кафедр]
	             FROM DBO.FACULTY  INNER JOIN DBO.PULPIT P
	             ON FACULTY.FACULTY = P.FACULTY
				 GROUP BY FACULTY.FACULTY_NAME

SELECT * from [Количество кафедр]

