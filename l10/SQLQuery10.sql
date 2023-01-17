use Univer;
--Курсор является программной конструкцией, которая дает возможность 
--пользователю обрабатывать строки результирующего набора запись за записью

--1---------------------------
--Разработать сценарий, формирующий список дисциплин на кафедре ИСиТ. В отчет должны быть выведены краткие названия 
--(поле SUBJECT) из таблицы SUBJECT в одну строку через запятую. 
--Использовать встроенную функцию RTRIM.

declare cursor1 cursor 
        for select SUBJECT.SUBJECT from SUBJECT
		           where SUBJECT.PULPIT = 'ИСиТ';

declare @subjname varchar(10), @allsubj varchar(300) = ' ';

--Оператор FETCH считывает одну строку из результирующего набора и продвигает указатель на следующую строку
--и проверяет функцию @fetch_status
--(0)успешно
--(-1) достиг конец рез набора и стр не счит
--(-2)строка отсутств
open cursor1
fetch cursor1 into @subjname
     while @@fetch_status = 0 --значит успешно
	 begin
		set @allsubj = rtrim(@subjname) + ', ' + @allsubj--rtrim удаляет пробелы
		fetch cursor1 into @subjname
	 end
close cursor1
print @allsubj

--2---------------------------
--Разработать сценарий, демонстрирующий отличие глобального курсора от локальногo

declare local_cursor cursor local
        for select top(1) TEACHER.TEACHER_NAME from TEACHER
go
declare @var nvarchar = ''
open local_cursor
fetch local_cursor into @var
      print 'LOCAL cursor first package'
go
declare @var nvarchar = ''
fetch local_cursor into @var
      print 'LOCAL cursor second package'


declare global_cursor cursor global 
        for select top(1) TEACHER.TEACHER_NAME from TEACHER

declare @var1 nvarchar = ''
open global_cursor
fetch global_cursor into @var1
      print 'GLOBAL cursor first package'
go
declare @var1 nvarchar = ''
fetch global_cursor into @var1
      print 'GLOBAL cursor second package'
deallocate global_cursor

--3---------------------------
--Разработать сценарий, демонстрирующий отличие статических курсоров от динамических

create table #TEMP (variable nvarchar(max))
insert #TEMP values ('default')
--drop table #TEMP

declare static_cursor cursor local static 
        for select #TEMP.variable from #TEMP
declare dynam_cursor cursor local static 
        for select #TEMP.variable from #TEMP

declare @str nvarchar(max) = ''
open static_cursor
open dynam_cursor
update #TEMP set variable = 'CHANGED'
fetch static_cursor into @str
      print 'STATIC: ' + @str
fetch dynam_cursor into @str
      print 'DYNAMIC: ' + @str


--4---------------------------
--Разработать сценарий, демонстрирующий свойства навигации в результирующем наборе курсора с атрибутом SCROLL
--Использовать все известные ключе-вые слова в операторе FETCH.

declare @str1 varchar(MAX)
declare curs cursor scroll for select TEACHER.TEACHER_NAME from TEACHER
open curs
fetch next from curs into @str1
fetch next from curs into @str1
fetch next from curs into @str1
fetch next from curs into @str1
print 'NEXT: '+@str1
fetch prior from curs into @str1--предыд
print 'PRIOR: '+@str1
fetch first from curs into @str1
print 'FIRST: '+@str1
fetch last from curs into @str1
print 'LAST: '+@str1
fetch absolute 2 from curs into @str1
print 'ABSOLUTE 2: '+@str1
fetch relative -1 from curs into @str1
print 'RELATIVE -1: '+@str1--от текущей
close curs
deallocate curs

--5---------------------------
--Создать курсор, демонстрирующий применение конструкции CURRENT OF в секции WHERE с 
--использованием операторов UPDATE и DELETE.

create table #TEMP ( variable nvarchar(MAX))
insert #TEMP values('DEFAULT')
insert #TEMP values('delete')
declare @str2 nvarchar(MAX) = ''

declare CURS cursor dynamic for select #TEMP.VARIABLE from #TEMP for update
open CURS
fetch CURS into @str2
update #TEMP set #TEMP.VARIABLE = 'UPDATED' where current of CURS
fetch CURS into @str2
delete #TEMP where current of CURS
close CURS

deallocate CURS
select * from #TEMP
drop table #TEMP

--6---------------------------
--Разработать SELECT-запрос, с помощью которого из таблицы PROGRESS удаляются строки, содержащие информацию 
--о студентах, получивших оценки ниже 4 (использовать объединение таблиц PROGRESS, STUDENT, GROUPS). 
drop table #TEMP

select PROGRESS.NOTE into #TEMP from PROGRESS
	inner join STUDENT on STUDENT.IDSTUDENT = PROGRESS.IDSTUDENT
	inner join GROUPS on GROUPS.IDGROUP = STUDENT.IDGROUP
select * from #TEMP


declare @subj char(10), @id int, @dt date, @note int
declare CURS cursor dynamic for select * from PROGRESS for update--для обновления записи
open CURS

fetch CURS into @subj, @id, @dt, @note
while @@fetch_status = 0
	begin
	fetch CURS into @subj, @id, @dt, @note
	if @note < 5
		delete PROGRESS where current of CURS
end
close CURS
deallocate CURS

select * from PROGRESS

--Разработать SELECT-запрос, с по-мощью которого в таблице PROGRESS для студента с конкретным номером IDSTUDENT 
--корректируется оценка (увеличивается на единицу).

declare @idd int = 0, @specId int = 1003
declare CURS cursor dynamic for select PROGRESS.IDSTUDENT from PROGRESS for update
OPEN CURS
fetch CURS into @idd

while @@fetch_status = 0
	begin
	fetch CURS into @idd
	if @idd = @specId
	    update PROGRESS set PROGRESS.NOTE = PROGRESS.NOTE + 1 where current of CURS
	end
close CURS
deallocate CURS

select * from PROGRESS
