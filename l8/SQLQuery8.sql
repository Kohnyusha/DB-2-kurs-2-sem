use Univer;

--1---------------------------------------
declare @a char(2) = 'БД',
		@b varchar(4) = 'БГТУ',
		@c datetime,
		@d time,
		@e int,--не объявл
		@f smallint,
		@g tinyint,--неотриц цел
		@h numeric(12,5);

set @c = (select top(1) BDAY from STUDENT);
set @d = getdate();
select @f = -1, @g = 1, @h = 14.55;

select @a a, @b b, @c c, @d d;
print 'f = ' + convert(char, @f) + 'g = ' + convert(char, @g) + 'h = ' + convert(char, @h);
go
--2---------------------------------------
--Разработать скрипт, в котором определяется общая вместимость аудиторий. 
--Когда общая вместимость превышает 200, то вывести количество аудиторий, среднюю вместимость аудиторий, количество аудиторий, вместимость которых меньше средней, и процент таких аудиторий. 
--Когда общая вместимость аудиторий меньше 200, то вывести сообщение о размере общей вместимости.
--audavg - количество аудиторий, вместимость которых меньше ср
go
declare @cap int = convert(int, (select sum(AUDITORIUM_CAPACITY) from AUDITORIUM)), @countaud int, @avgcap int, @audavg int, @procent float;
	    if @cap >= 200
		   begin
		         select @countaud = (select count(*) from AUDITORIUM);
				 select @avgcap = (select avg(AUDITORIUM_CAPACITY) from AUDITORIUM);
				 select @audavg = (select count(AUDITORIUM) from AUDITORIUM 
				                                            where AUDITORIUM_CAPACITY < @avgcap);
                 select @procent = (@audavg * 100 / @countaud);
				 select @countaud [Количество аудиторий], @avgcap [Средняя вместимость аудиторий], @audavg [Количество аудиторий, вместимость которых меньше средней], @procent [Процент таких аудиторий]
		   end
		   else if @cap < 200
		         print 'Размер общей вместимости = ' + convert(char, @cap);

--3---------------------------------------
--вывести глобальные переменные
go
select * from AUDITORIUM;
print 'Число обработанных строк: ' + cast(@@ROWCOUNT as varchar(10));

print @@VERSION;
print @@SPID;--системный идентификатор процесса

--insert into AUDITORIUM values ('299-1', 'Кафедра', 20, '299-1');
print @@ERROR;

print @@SERVERNAME;

begin tran
	begin tran
		print @@TRANCOUNT --уровень вложенности транзакции
	commit
commit 

select * from AUDITORIUM;
print 'Проверка результата считывания строк результирующего набора: ' + cast(@@FETCH_STATUS as varchar(300));--0 это успешно

--
GO  
IF OBJECT_ID (N'usp_OuterProc', N'P')IS NOT NULL  
    DROP PROCEDURE usp_OuterProc;  
GO  
IF OBJECT_ID (N'usp_InnerProc', N'P')IS NOT NULL  
    DROP PROCEDURE usp_InnerProc;  
GO  
CREATE PROCEDURE usp_InnerProc AS   
    SELECT @@NESTLEVEL AS 'Inner Level';  
GO  
CREATE PROCEDURE usp_OuterProc AS   
    SELECT @@NESTLEVEL AS 'Outer Level';  
    EXEC usp_InnerProc;  
GO  
EXECUTE usp_OuterProc;  
GO 

--4.1---------------------------------------
declare @z float, @t float = 4.5, @x float = 0.2;
        if @t > @x 
		   set @z = power(sin(@t),2)
		else if @t < @x
		   set @z = 4 * (@t + @x)
        else if @t = @x
		   set @z = 1 - exp(@x - 2)
		print 'z = ' + cast(@z as varchar(10))

--4.2 преобразование полного ФИО студента в сокращенное ---------------------------------------
declare @fio varchar(50) = 'Кохнюк Александра Сергеевна', @shotrfio varchar(20), @spacepos1 int, @spacepos2 int;
  set @spacepos1 = charindex(' ', @fio, 1);
  set @spacepos2 = charindex(' ', @fio, @spacepos1 + 1);
  set @shotrfio = substring(@fio, 1, @spacepos1) + substring(@fio, @spacepos1 + 1, 1) + '.' + substring(@fio, @spacepos2 + 1, 1) + '.';
print 'Сокращенное ФИО: ' + @shotrfio;

--4.3---------------------------------------
--поиск студентов, у которых день рождения в следующем месяце, и определение их возраста
declare @currentmonth int, @nextmonth int, @age int;
  set @currentmonth = month(getdate());
  set @nextmonth = @currentmonth + 1;
  select NAME, BDAY, year(getdate()) - year(BDAY) [Возраст] from STUDENT
               where month(BDAY) = @nextmonth
			   order by [Возраст];

--4.4---------------------------------------
--поиск дня недели, в который студенты некоторой группы сдавали экзамен по СУБД
declare @subj varchar(10) = 'СУБД', @idgroup int = 5;
  select NAME, STUDENT.IDGROUP, PROGRESS.SUBJECT, PROGRESS.PDATE, datename(DW, PDATE) [День недели]
         from STUDENT 
		   inner join PROGRESS on STUDENT.IDSTUDENT = PROGRESS.IDSTUDENT
		   inner join GROUPS on STUDENT.IDGROUP = GROUPS.IDGROUP
		   where PROGRESS.SUBJECT = @subj and STUDENT.IDGROUP = @idgroup

--5 Продемонстрировать конструкцию IF… ELSE ---------------------------------------
declare @st_kg int, @st_oaip int;
  set @st_kg = (select count(*) from PROGRESS where PROGRESS.SUBJECT = 'КГ');
  set @st_oaip = (select count(*) from PROGRESS where PROGRESS.SUBJECT = 'ОАиП');
     if (@st_kg > @st_oaip) 
	    begin
		   print 'Количество студентов, сдавших КГ: ' + cast(@st_kg as varchar(15))
		   print 'Количество студентов, сдавших ОАиП: ' + cast(@st_oaip as varchar(15))
		   print 'КГ сдали больше студентов, чем ОАиП'
	    end;
     if (@st_kg < @st_oaip) 
	    begin
		   print 'Количество студентов, сдавших КГ: ' + cast(@st_kg as varchar(15))
		   print 'Количество студентов, сдавших ОАиП: ' + cast(@st_oaip as varchar(15))
		   print 'КГ сдали меньше студентов, чем ОАиП'
	    end;
	 else 
	    begin 
		   print 'Количество студентов, сдавших СУБД: ' + cast(@st_kg as varchar(15))
		   print 'Количество студентов, сдавших КГ: ' + cast(@st_oaip as varchar(15))
		   print 'На экзаменах СУБД и КГ было одинаковое количество студентов'
	    end;

--6---------------------------------------
--анализ оценок, полученные студентами некоторого факультета при сдаче экзаменов
--case - для формирования одного из нескольких возможных значений
declare @super int = 10, @normal int = 8, @poidet int = 5, @ploho int = 3, @yzhasno int = 1, @fac varchar(20) = 'ИТ';
  select
    case
	    when NOTE between @normal and @super then 'отлично'
		when NOTE between @poidet and @normal then 'хорошо'
		when NOTE between @ploho and @poidet then 'удовлетворительно'
		when NOTE between @yzhasno and @ploho then 'удовлитворительно'
	end [Результат сдачи], count(*) [Количество]
	from PROGRESS 
	    inner join STUDENT on PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
		inner join GROUPS on STUDENT.IDGROUP = GROUPS.IDGROUP
		   where GROUPS.FACULTY = @fac
  group by 
    case 
	    when NOTE between @normal and @super then 'отлично'
		when NOTE between @poidet and @normal then 'хорошо'
		when NOTE between @ploho and @poidet then 'удовлетворительно'
		when NOTE between @yzhasno and @ploho then 'удовлитворительно'
    end

--7 Создать временную локальную таблицу из трех столбцов и 10 строк, заполнить ее и вывести содержимое. ---------------------------------------
--глобальные нач с ##
CREATE table #TEMP
(   
   ID int,
   TEMPTEXT varchar(150),
   TEMPDESCRIPTION varchar(150)
);
drop table #TEMP

set nocount on;
declare @i int = 0;
while @i<10
	begin
		insert #TEMP values (floor(3000 * rand()), replicate('little', 2), replicate('dark age', 2))--ранд генерирует случ число
		if (@i % 100 = 0) print @i;
set @i = @i+1;
end;

select * from  #TEMP order by ID;

--8 Разработать скрипт, демонстрирующий использование оператора RETURN. ---------------------------------------
--return для немедленного завершения работы пакета
go
declare @x int = 2
	print @x+1
	print @x+10
	return
	print @x+300
go

--9 Разработать сценарий с ошибками, в ко-тором используются для обработки ошибок блоки TRY и CATCH....---------------------------------------
begin try
	insert into AUDITORIUM values ('299-1', 'Кафедра', 20, '299-1');
end try
begin catch
	print 'Код последней ошибки: ' + cast(ERROR_NUMBER() as varchar(10));
	print 'Сообщение об ошибке: ' + cast(ERROR_MESSAGE() as varchar(250));
	print 'Строка с ошибкой (код): ' + cast(ERROR_LINE() as varchar(25));
	print 'Имя процедуры: ' + isnull(cast(ERROR_PROCEDURE() as varchar(50)), 'NULL');
	print 'Уровень серьезности ошибки: ' + cast(ERROR_SEVERITY() as varchar(25));
	print 'Метка ошибки: ' + cast(ERROR_STATE() as varchar(25));
end catch