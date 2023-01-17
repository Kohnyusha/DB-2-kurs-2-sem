use k_MyBase;

CREATE table GROUPP
(
	IDGR int primary key IDENTITY (1,1),
	FACLT int NOT NULL,
	PROF int NOT NULL,
	YEARP date NOT NULL default '2020-09-01',
)

CREATE table STUD 
(
	 IDST int primary key IDENTITY (1,1),
	 IDGROUP int foreign key references GROUPP(IDGR) NOT NULL,
	 NAME nchar(60) NOT NULL,
	 BDAY date,
)

CREATE table PROGR 
(
	   SUBJ nchar(50) NOT NULL,
	   IDST int foreign key references STUD(IDST) NOT NULL, 
	   PDATE date default '2022-04-05',
	   NOTE int check (NOTE > 0 and NOTE < 11) NOT NULL,
)

INSERT into GROUPP(IDGR, FACLT, PROF, YEARP)
	   Values (1122, 1012, 10103, '2022'),
			  (1123, 1012, 10104, '2022'),
			  (1124, 1013, 10105, '2022'),
			  (1125, 1013, 10106, '2022'),
			  (1126, 1014, 10107, '2022');

SELECT * FROM GROUPP;

INSERT into STUD(IDST, IDGROUP, NAME, BDAY) 
       Values (10101, 1122, 'Кохнюк Александра Сергеевна', '2003-07-18'),
	          (10203, 1123, 'Шастовская Марина Сергеевна', '2003-02-14'),
			  (10304, 1123, 'Богдан Анастасия Александровна', '2003-08-10'),
			  (10405, 1125, 'Миринская Каролина Андреевна', '2003-04-12'),
			  (10506, 1124, 'Латышевич Дмитрий Сергеевич', '2002-08-22');

SELECT * FROM STUD;

INSERT into PROGR(SUBJ, IDST, PDATE, NOTE)
	   Values ('Базы данных', 10101, '2022-06-09', 6),
			  ('Математика', 10203, '2022-06-12', 8),
			  ('ООП', 10405, '2022-06-21', 5),
			  ('КМС', 10304, '2022-06-25', 6),
			  ('Базы данных', 10203, '2022-06-12', 7),
			  ('Базы данных', 10405, '2022-06-08', 8),
			  ('Базы данных', 10304, '2022-06-12', 6),
			  ('Математика', 10304, '2022-06-12', 9),
			  ('Математика', 10101, '2022-06-15', 10),
			  ('Математика', 10405, '2022-06-15', 8);

SELECT * FROM PROGR;

--вывести фамилию, спец, дисциплину, оценку студентов от 4 до 6, на факультете с кодом 1012
SELECT t1.NAME [Студент], t2.PROF [Специальность], t3.SUBJ [Дисциплина], t3.NOTE [Оценка]
	   FROM STUD t1 INNER JOIN GROUPP t2
	   ON t1.IDGROUP = t2.IDGR
	   INNER JOIN PROGR t3 
	   ON t1.IDST = t3.IDST
	   Where t3.NOTE between 4 and 6
			and t2.FACLT = 1012

--вывести фамилию, спец, дисциплину, оценку студентов от 4 до 6, на факультете с кодом 1013
SELECT t1.NAME [Студент], t2.PROF [Специальность], t3.SUBJ [Дисциплина], t3.NOTE [Оценка]
	   FROM STUD t1 INNER JOIN GROUPP t2
	   ON t1.IDGROUP = t2.IDGR
	   INNER JOIN PROGR t3 
	   ON t1.IDST = t3.IDST
	   Where t3.NOTE between 4 and 6
			and t2.FACLT = 1013

--Оператор UNION выполняет операцию объединения, результатом является множество строк, 
--в котором строки не могут повторяться. В результате будет выведены результаты 2ух предыдущих запросов.
SELECT t1.NAME [Студент], t2.PROF [Специальность], t3.SUBJ [Дисциплина], t3.NOTE [Оценка]
	   FROM STUD t1 INNER JOIN GROUPP t2
	   ON t1.IDGROUP = t2.IDGR
	   INNER JOIN PROGR t3 
	   ON t1.IDST = t3.IDST
	   Where t3.NOTE between 4 and 6
			and t2.FACLT = 1012
       UNION
SELECT t1.NAME [Студент], t2.PROF [Специальность], t3.SUBJ [Дисциплина], t3.NOTE [Оценка]
	   FROM STUD t1 INNER JOIN GROUPP t2
	   ON t1.IDGROUP = t2.IDGR
	   INNER JOIN PROGR t3 
	   ON t1.IDST = t3.IDST
	   Where t3.NOTE between 4 and 6
			and t2.FACLT = 1013

SELECT t1.NAME [Студент], t2.PROF [Специальность], t3.SUBJ [Дисциплина], t3.NOTE [Оценка]
	   FROM STUD t1 INNER JOIN GROUPP t2
	   ON t1.IDGROUP = t2.IDGR
	   INNER JOIN PROGR t3 
	   ON t1.IDST = t3.IDST
	   Where t3.NOTE between 4 and 6
			and t2.FACLT = 1012
       UNION ALL
SELECT t1.NAME [Студент], t2.PROF [Специальность], t3.SUBJ [Дисциплина], t3.NOTE [Оценка]
	   FROM STUD t1 INNER JOIN GROUPP t2
	   ON t1.IDGROUP = t2.IDGR
	   INNER JOIN PROGR t3 
	   ON t1.IDST = t3.IDST
	   Where t3.NOTE between 4 and 6
			and t2.FACLT = 1013
