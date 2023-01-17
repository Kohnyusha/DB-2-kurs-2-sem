use UNIVER;

--Процедура - это поименованный код на языке Transact-SQL.

--1---------------------------------------
--Разработать хранимую процедуру без параметров с именем PSUBJECT.
--К точке вызова процедура должна возвращать коли-чество строк, выведенных в результирующий набор.
go
create procedure PSUBJECT
as
begin
	declare @count int = (select count(*) from SUBJECT)
	select SUBJECT.SUBJECT[Код], SUBJECT.SUBJECT_NAME[Дисциплина], SUBJECT.PULPIT[Кафедра] FROM SUBJECT
	return @count
end

--drop procedure PSUBJECT;
go
declare @count int = 0
EXEC @count = PSUBJECT
print 'количество дисциплин = ' + cast(@count as varchar(3))



--2---------------------------------------
--такая же, но при этом содержать строки, соответствующие коду кафедры, заданному параметром @p. Кроме того, процедура должна 
--формировать значение выходного параметра @с, равное количеству строк в результирующем наборе, а также возвращать 
--значение к точке вызова, равное общему коли-честву дисциплин (количеству строк в таблице SUBJECT). 
go
ALTER procedure [dbo].[PSUBJECT] @p varchar(20) = NULL, @c int output
as
begin
	declare @count int = (select count(*) from SUBJECT)
	print 'Parameters: @p = ' + @p + ', @c = ' + CAST(@c AS VARCHAR(3))
	select SUBJECT.SUBJECT[Код], SUBJECT.SUBJECT_NAME[Дисциплина], SUBJECT.PULPIT[Кафедра] FROM SUBJECT
	WHERE SUBJECT.PULPIT = @p
	SET @c = @@ROWCOUNT
	return @count
end

go
declare @count int = 0, @r int = 0, @p varchar(20); 
EXEC @count = PSUBJECT @p = 'ИСиТ', @c = @r output
print 'Количество всех дисциплин: ' + cast(@count as varchar(20));
print 'Количество дисциплин с кафедры ' + @p + ': ' + cast(@r as varchar(20));



--3---------------------------------------
--Создать временную локальную таблицу с именем #SUBJECT. Наименование и тип столбцов таблицы должны соответствовать столбцам результирующего набора процедуры PSUBJECT, разработанной в задании 2. 
--Изменить процедуру PSUBJECT таким образом, чтобы она не содержала выходного параметра.
--Применив конструкцию INSERT… EXECUTE с модифицированной процедурой PSUBJECT, добавить строки в таблицу #SUBJECT. 
create table #Subj
(
	Код char(10) primary key not null,
	Дисциплина varchar(100),
	Кафедра char(20)
)
--процедуры без вых параметра могут быть источником строк для доб в табл
go
ALTER procedure PSUBJECT @p varchar(20)--код кафедры
	as
begin
	declare @count int = (select count(*) from SUBJECT);
	select SUBJECT [Код], SUBJECT_NAME [Дисциплина], PULPIT [Кафедра] from SUBJECT where PULPIT = @p;
	return @count;
end;

insert #Subj exec PSUBJECT 'ТОВ';
insert #Subj exec PSUBJECT 'ИСиТ';

select * from #Subj order by Кафедра;



--4---------------------------------------
--Процедура должна возвращать к точке вызова значение -1 
--в том случае, если произошла ошибка и 1, если выполнение успешно. 
go
create procedure PAUDITORIUM_INSERT 
   @a char(20), @n varchar(50), @c int = 0, @t char(10)
as declare @rc int = 1;
begin try
    insert into AUDITORIUM (AUDITORIUM, AUDITORIUM_NAME, AUDITORIUM_CAPACITY, AUDITORIUM_TYPE) 
			   values (@a, @n, @c, @t)
	return @rc;
end try
begin catch
    print 'номер ошибки: ' + cast(error_number() as varchar(6));
	print 'сообщение: ' + error_message();
	print 'уровень: ' + cast(error_severity() as varchar(10));
	print 'метка: ' + cast(error_state() as varchar(10));
	print '№ строки: ' + cast(error_line() as varchar(10));
	if error_procedure() is not null print 'имя процедуры: ' + error_procedure();
	return -1;
end catch;

go
declare @rc int;
exec @rc = PAUDITORIUM_INSERT '776-2', 'ЛК', 200, '776-2'
select @rc



--5---------------------------------------
--список дисциплин на конкретной кафедре
--В том случае, если по заданному значению @p не-возможно определить код кафедры, процедура должна генерировать ошибку с сообщением ошибка в пара-метрах. 
--Процедура SUBJECT_REPORT должна возвращать к точке вызова количество дисциплин, отображенных в отчете. 

go
create procedure SUBJECT_REPORT
   @p char(10)--код кафедры
as declare @rс int = 0;
begin try
   declare @sb char(10), @resstr varchar(350) = ''
   declare SUBJECTS cursor for
       select SUBJECT.SUBJECT from SUBJECT
	          where SUBJECT.PULPIT = rtrim(@p)
   if not exists (select SUBJECT.SUBJECT from SUBJECT where PULPIT = @p) 
       raiserror('Ошибка', 11, 1)
   else 
       open SUBJECTS
	   fetch SUBJECTS into @sb
	   print 'Дисциплины: '
	   while @@FETCH_STATUS = 0
	     begin
		    set @resstr = rtrim(@sb) + ', ' + rtrim(@resstr)
			set @rс = @rс + 1
			fetch SUBJECTS into @sb;
		 end
		 print @resstr
		close SUBJECTS
		return @rс
end try
begin catch
    print 'Ошибка!'
	print error_message();
	if error_procedure() is not null print 'имя процедуры : ' + error_procedure();
	return @resstr
end catch;

go
declare @rc int;
exec @rc = SUBJECT_REPORT 'ТОВ' 
print 'Количество дисциплин = ' + cast(@rc as varchar(3)); 




--6---------------------------------------
select * from AUDITORIUM_TYPE;
select * from AUDITORIUM;
go
create procedure PAUDITORIUM_INSERTX
   @a char(20), @n varchar(50), @c int = 0, @t char(10), @tn varchar(50)--для ввода знач в столбец
as declare @rc int = 1;
begin try
   set transaction isolation level SERIALIZABLE;--ур изолированности транз (ДР ТРАНЗ НИЧЕ НЕ МОГУТ ДЕЛАТЬ С ЭТИМИ ДАННЫМИ)
      begin tran
	     insert into AUDITORIUM_TYPE (AUDITORIUM_TYPE, AUDITORIUM_TYPENAME)
		        values (@t, @tn);
		 --вторая строка путем вызова процедуры из задания4
		 exec @rc = PAUDITORIUM_INSERT @a, @n, @c, @t;
      commit tran
   return @rc;
end try
--Процедура PAUDITORIUM_INSERTX должна возвращать к точке вызова значение -1 в том случае, если произошла 
--ошибка и 1, если выполнения процедуры завершилось успешно
begin catch
    print 'номер ошибки: ' + cast(error_number() as varchar(6));
    print 'сообщение: ' + error_message();
    print 'уровень: ' + cast(error_severity()  as varchar(6));
    print 'метка: ' + cast(error_state()   as varchar(8));
    print 'номер строки: ' + cast(error_line()  as varchar(8));
    if error_procedure() is not  null print 'имя процедуры: ' + error_procedure();
    if @@trancount > 0 rollback tran ; 
    return -1;	
end catch

go
declare @rc int;
exec @rc = PAUDITORIUM_INSERTX '781-1', 'ЛК_3.0', 100, '781-1', 'Аудитория';
print 'Код ошибки = ' + cast((@rc as varchar(3));

