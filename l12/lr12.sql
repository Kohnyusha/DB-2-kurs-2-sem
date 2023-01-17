--хранимые процедуры

use Univer;

--task 1

go
create procedure PSUBJECT
	as
begin
	declare @count int = (select count(*) from SUBJECT);
	select SUBJECT [Код], SUBJECT_NAME [Дисциплина], PULPIT [Кафедра] from SUBJECT;
	return @count;
end;

declare @k int = 0;
exec @k = PSUBJECT;
print 'Количество дисциплин: ' + cast(@k as varchar(5));


--task 2

go
ALTER procedure [dbo].[PSUBJECT] @p varchar(20) = NULL, @c int output
	as
begin
	declare @count int = (select count(*) from SUBJECT);
	select SUBJECT [Код], SUBJECT_NAME [Дисциплина], PULPIT [Кафедра] from SUBJECT where PULPIT = @p;
	set @c = @@rowcount;
	return @count;
end;

go
declare @k int = 0, @p varchar(20)  = 'ИСиТ', @rows int = 0;
exec @k = PSUBJECT @p, @rows output;
print 'Количество дисциплин: ' + cast(@k as varchar(5));
print 'Количество дисциплин на кафедре ' + @p + ': ' +  cast(@rows as varchar(5));


--task 3

create table #Sb
(
	Код char(10) primary key not null,
	Дисциплина varchar(100),
	Кафедра char(20)
)

--хранимая процедура может служить источником строк
go
ALTER procedure PSUBJECT @p varchar(20)
	as
begin
	declare @count int = (select count(*) from SUBJECT);
	select SUBJECT [Код], SUBJECT_NAME [Дисциплина], PULPIT [Кафедра] from SUBJECT where PULPIT = @p;
	return @count;
end;

insert #Sb exec PSUBJECT 'ИСиТ';
insert #Sb exec PSUBJECT 'ПОиСОИ';

select * from #Sb order by Кафедра;

--task 4
select * from AUDITORIUM;

go
create procedure PAUDITORIUM_INSERT 
	@a char(20),  @t char(10), @c int = 0, @n varchar(50)
as
	declare @rc int = 1;
begin try
   insert into AUDITORIUM (AUDITORIUM, AUDITORIUM_TYPE, AUDITORIUM_CAPACITY, AUDITORIUM_NAME) 
			   values (@a, @t, @c, @n)
	return @rc;
end try

begin catch
	print 'номер ошибки: ' + cast(error_number() as varchar(6));
	print 'сообщение: ' + error_message();
	print 'уровень: ' + cast(error_severity() as varchar(10));
	print 'метка: ' + cast(error_state() as varchar(10));
	print 'строка: ' + cast(error_line() as varchar(10));
	if error_procedure() is not null print 'имя процедуры: ' + error_procedure();
	return -1;
end catch;


go
declare @rc int = 0;
exec @rc = PAUDITORIUM_INSERT '599-1', 'ЛК', '100', '599-1' --добавлено новое значение
exec @rc = PAUDITORIUM_INSERT '206-1', 'ЛК-К', '255', '206-1' --тут ошибка PK преднамеренно
print 'код возврата: ' + cast (@rc as varchar(3));

--task 5

select * from SUBJECT;

go
create procedure SUBJECT_REPORT @pulpit char(20)
	as 
declare @rc int = 0;
begin try
	declare @subjects char(10), @resultstr varchar(350) = '';
	declare CUR_SUBJECT cursor local for (select SUBJECT from SUBJECT where PULPIT = @pulpit);
	if not exists (select SUBJECT from SUBJECT where PULPIT = @pulpit) raiserror('ошибка', 11, 1)

	else 
		open CUR_SUBJECT
		fetch CUR_SUBJECT into @subjects

		print 'Дисциплины';   
		while @@fetch_status = 0                                     
			   begin 
				   set @resultstr = rtrim(@subjects) + ', ' + @resultstr;  
				   set @rc = @rc + 1;       
				   fetch  CUR_SUBJECT into @subjects; 
				end;   
		print @resultstr;        
		close  CUR_SUBJECT;
		return @rc;
end try

begin catch
	print 'ошибка в параметрах'
	print error_message();
	if error_procedure() is not null print 'имя процедуры : ' + error_procedure();
	return @rc;
end catch;

go
declare @rc int = 0;
exec @rc = SUBJECT_REPORT 'ИСиТ';
print 'Количество дисциплин = ' + cast(@rc as varchar(3)); 

--drop procedure SUBJECT_REPORT

--task 6
select * from AUDITORIUM_TYPE;
select * from AUDITORIUM;

go
create procedure PAUDITORIUM_INSERTX
		@a char(20),  @t char(10), @c int = 0, @n varchar(50), @tn varchar(50)
as  declare @rc int=1;                            

begin try
	set transaction isolation level SERIALIZABLE
		begin tran
			insert into AUDITORIUM_TYPE (AUDITORIUM_TYPE, AUDITORIUM_TYPENAME) values (@t, @tn)
			exec @rc = PAUDITORIUM_INSERT @a, @t, @c, @n;  --см task4 PAUDITORIUM_INSERT вызываем из прошлого задания
			commit tran; 
	return @rc;           
end try

begin catch

    print 'номер ошибки: ' + cast(error_number() as varchar(6));
    print 'сообщение: ' + error_message();
    print 'уровень: ' + cast(error_severity()  as varchar(6));
    print 'метка: ' + cast(error_state()   as varchar(8));
    print 'номер строки: ' + cast(error_line()  as varchar(8));
    if error_procedure() is not  null print 'имя процедуры: ' + error_procedure();
    if @@trancount > 0 rollback tran ; 
    return -1;	

end catch;

--вставка двух новых записей, тип аудитории и соответствующая ему конкретная аудитория
go
declare @rc int;  
exec @rc = PAUDITORIUM_INSERTX '355-1', 'Кафедра', 155, '355-1', 'Кафедра факультета';  
print 'Код возврата =' + cast(@rc as varchar(3));  


--task 8

select * from FACULTY;
select * from PULPIT;
select * from TEACHER;
select * from SUBJECT;


go
create procedure PRINT_REPORT @flt char(10) = NULL, @pulp char(20) = NULL
as 
	declare @rc int=0; 
	declare @faculty varchar(15), @pulpit char(20), @teachercount int = 0, @subject varchar(20), @ressubj varchar(900) = '';
	declare @currentfaculty varchar(15) = 'xxx';
	declare @currentpulpit varchar(15) = 'xxx';
begin try
	
--определим требуемый факультет и кафедру на основании входных параметров flt и pulp
declare @rqfaculty char(10), @rqpulpit char(20);
if (@flt is not null AND @pulp is null) 
	begin
		set @rqfaculty = @flt;
		set @rqpulpit = '*'; -- обозначим * требование вывода всех кафедр факультета
	end
else if (@flt is not null AND @pulp is not null) 
	begin
		set @rqfaculty = @flt;
		set @rqpulpit = @pulp;
	end
else if (@flt is null AND @pulp is not null) 
	begin
	if not exists (select FACULTY from PULPIT where PULPIT = @pulp) raiserror ('ошибка в параметрах', 11, 1);
		else 
		begin
		set @rqfaculty = (select FACULTY from PULPIT where PULPIT = @pulp)
		set @rqpulpit =@pulp 
		end
	end

declare cur_report cursor local static scroll
for select FACULTY.FACULTY, PULPIT.PULPIT, SUBJECT.SUBJECT
	from FACULTY full outer join PULPIT on FACULTY.FACULTY = PULPIT.FACULTY	
	full outer join SUBJECT on SUBJECT.PULPIT = PULPIT.PULPIT
	where FACULTY.FACULTY = @rqfaculty --!!!!!!!!!!!
	order by FACULTY.FACULTY, PULPIT.PULPIT, SUBJECT.SUBJECT;

open cur_report;

fetch cur_report into @faculty, @pulpit, @subject;

while @@FETCH_STATUS = 0
	begin		

		if (@faculty != @currentfaculty) 
		begin
		
			print 'Факультет: ' + @faculty;
			
		end
			
			if (@pulpit != @currentpulpit and (@rqpulpit = '*' or @rqpulpit = @pulpit)) -- !!!!!!!
			begin
			
			print '  Кафедра: ' + @pulpit;
			set @rc = @rc + 1; --считаем количество кафедр
			--количество преподавателей
			--курсор с параметром
			declare @pulpkey char(20);
			set @pulpkey = @pulpit;

			declare cur_qteacher cursor local static scroll 
			for select Count(*) from TEACHER where TEACHER.PULPIT = @pulpkey;

			open cur_qteacher;
			fetch cur_qteacher into @teachercount;				
			print '    Количество преподавателей: ' + cast(@teachercount as varchar(10));
			
			close cur_qteacher;
			deallocate cur_qteacher;

			-- дисциплины
			set @currentpulpit = @pulpit;

				if (@subject is NULL) print '    Дисциплины: нет'
				else
				begin

					while @currentpulpit = @pulpit and @@FETCH_STATUS = 0
					begin

					SET @ressubj = @ressubj + trim(@subject) + ', ';
					set @currentpulpit = @pulpit;
					fetch cur_report into @faculty, @pulpit, @subject;					

					end;

					print '    Дисциплины: ' + substring(@ressubj,1,len(@ressubj)-1);

					set @ressubj = '';

					fetch PRIOR from cur_report into @faculty, @pulpit, @subject;

				end;

			end;
	
		set @currentfaculty = @faculty;
		set @currentpulpit = @pulpit;
		fetch cur_report into @faculty, @pulpit, @subject;
	end;

close cur_report;

	return @rc;
end try

begin catch
    print 'номер ошибки: ' + cast(error_number() as varchar(6));
    print 'сообщение: ' + error_message();
    print 'уровень: ' + cast(error_severity()  as varchar(6));
    print 'метка: ' + cast(error_state()   as varchar(8));
    print 'номер строки: ' + cast(error_line()  as varchar(8));
    if error_procedure() is not  null print 'имя процедуры: ' + error_procedure();
    if @@trancount > 0 rollback tran ; 
    return -1; --в случае ошибки процедура вернет -1, а если успех - количество кафедр отчета	
end catch;


go
declare @k int = 0;
exec @k = PRINT_REPORT 'ИТ', null;
print 'Количество кафедр в отчете: ' + cast(@k as varchar(6));

go
declare @k int = 0;
exec @k = PRINT_REPORT null, 'ЛКиП';
print 'Количество кафедр в отчете: ' + cast(@k as varchar(6));

go
declare @k int = 0;
exec @k = PRINT_REPORT null, null;
print 'Количество кафедр в отчете: ' + cast(@k as varchar(6));

go
declare @k int = 0;
exec @k = PRINT_REPORT 'ИТ', 'ИСиТ';
print 'Количество кафедр в отчете: ' + cast(@k as varchar(6));

--drop procedure PRINT_REPORT