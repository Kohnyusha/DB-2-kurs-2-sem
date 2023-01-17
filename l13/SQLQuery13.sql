use Univer;

--отлич от храинм процедур тем, что на код функций накладываются ограничения (на результат работы и способ вызова)

--нельзя операторы ddl, dml, try catch и транзакции
--1---------------------------------------------
go --скалярная, вычисляет кол-во студентов на факультете
create function COUNT_STUDENTS(@faculty varchar(20)) returns int
as 
begin
    declare @rc int = 0;
	    set @rc = (select count(IDSTUDENT)
		           from FACULTY 
			       join GROUPS on  GROUPS.FACULTY = FACULTY.FACULTY 
			       join STUDENT on STUDENT.IDGROUP = GROUPS.IDGROUP
			       where FACULTY.FACULTY = @faculty);
	return @rc;
end

go
declare @faculty int = dbo.COUNT_STUDENTS('ИТ');
print 'Количество студентов: ' + cast(@faculty as varchar(4));

go
select FACULTY.FACULTY, dbo.COUNT_STUDENTS(FACULTY.FACULTY) [Количество студентов] from FACULTY;

go --@prof--спциальность студентов
alter function COUNT_STUDENTS(@faculty varchar(20) = null, @prof varchar(20) = null) returns int
as 
begin
    declare @rc int = 0;
	    set @rc = (select count(IDSTUDENT)
		           from FACULTY 
			       join GROUPS on  GROUPS.FACULTY = FACULTY.FACULTY 
			       join STUDENT on STUDENT.IDGROUP = GROUPS.IDGROUP
			       where FACULTY.FACULTY = @faculty and GROUPS.PROFESSION = isnull(@prof, GROUPS.PROFESSION));
	return @rc;
end

go
select FACULTY.FACULTY, dbo.COUNT_STUDENTS(FACULTY.FACULTY, default) [Количество студентов] from FACULTY;


--2---------------------------------------------
--скалярная, возвращает строку с перечнем дисциплин в отчете
--р-код кафедры
go
create function FSUBJECTS(@p varchar(20)) returns varchar(300)
as
begin
    declare @subject varchar(10), @result varchar(100) = 'Дисциплины';
	declare cSubjects cursor local static 
	   for select SUBJECT.SUBJECT from SUBJECT 
	      where PULPIT like @p;
	open cSubjects;
	  fetch cSubjects into @subject;

		while @@FETCH_STATUS = 0 
		begin
			set @result = @result + '.' + rtrim(@subject);
			fetch cSubjects into @subject;
		end;
	close cSubjects;
	return @result
end

go
select PULPIT, dbo.FSUBJECTS(PULPIT) [Перечень дисциплин] from PULPIT;



--3---------------------------------------------
--табличная функция
--f - факультет
--р - кафедра
go
create function FFACPUL(@f varchar(20), @p varchar(20)) returns table
as return
  select FACULTY.FACULTY, PULPIT.PULPIT from FACULTY 
         left join PULPIT on FACULTY.FACULTY = PULPIT.FACULTY
	     where FACULTY.FACULTY = ISNULL(@f, FACULTY.FACULTY) and PULPIT.PULPIT = ISNULL(@p, PULPIT.PULPIT);

go
select * from dbo.FFACPUL(null, null);--возвращает список всех кафедр на всех факультетах
select * from dbo.FFACPUL('ЛХФ', null);--возвращает список всех кафедр заданного факультета
select * from dbo.FFACPUL(null, 'ЛМиЛЗ');--возвращает результирующий набор, содержащий строку, соответствующую заданной кафедре
select * from dbo.FFACPUL('ТТЛП', 'ЛМиЛЗ');--возвращает результирующий набор, содержащий строку, со-ответствующую заданной кафедре на заданном факультете. 
select * from dbo.FFACPUL('ИТ', 'ЛМиЛЗ'); --невозможно, поэтому пустой набор



--4---------------------------------------------
--скалярная, возвращает количество преподавателей на заданной параметром кафедре. Если параметр равен NULL, 
--то возвращается общее количество преподавателей. 
go
create function FCTEACHER(@p varchar(20)) returns int
as begin
	declare @rc int = (select count(*) from TEACHER where PULPIT = ISNULL(@p, PULPIT))
	return @rc
end

go
select distinct PULPIT, dbo.FCTEACHER(PULPIT)[Количество преподавателей] from TEACHER
select dbo.FCTEACHER(null)[Общее количество преподавателей]


--6---------------------------------------------
--многооператорная табличная функция
go
create function FACULTY_REPORT(@c int) returns @fr table
	          ([Факультет] varchar(50), [Количество кафедр] int, [Количество групп] int,  [Количество студентов] int, [Количество специальностей] int )
as begin 
        declare cc CURSOR static for 
		select FACULTY from FACULTY where dbo.COUNT_STUDENTS(FACULTY, default) > @c; 

	    declare @f varchar(30)
	    open cc
        fetch cc into @f
	    while @@fetch_status = 0
	    begin
		  insert @fr values( @f,  (select count(PULPIT) from PULPIT where FACULTY = @f),
	            (select count(IDGROUP) from GROUPS where FACULTY = @f),   dbo.COUNT_STUDENTS(@f, default),
	            (select count(PROFESSION) from PROFESSION where FACULTY = @f)   ); 
	            fetch cc into @f;  

	    end
        return
end
--drop function FACULTY_REPORT

--Изменить эту функцию так, чтобы количество кафедр, количество групп, количество 
--студентов и количество специальностей вычислялось отдельными скалярными функциями.
go
create function COUNT_PULPIT(@f varchar(20)) returns int as
begin
	declare @rc int = 0
	set @rc = (select count(PULPIT) from PULPIT where FACULTY = @f)
	return @rc
end

go
create function COUNT_GROUP(@f varchar(20)) returns int as 
begin
	declare @rc int = 0
	set @rc = (select count(IDGROUP) from GROUPS where FACULTY like @f)
	return @rc
end

go
create function COUNT_PROFESSION(@f varchar(20)) returns int as 
begin
	declare @rc int = 0
	set @rc = (select count(PROFESSION) from PROFESSION where FACULTY like @f)
	return @rc
end

go
select * from dbo.FACULTY_REPORT(10)
go
select * from dbo.FACULTY_REPORT(15)
