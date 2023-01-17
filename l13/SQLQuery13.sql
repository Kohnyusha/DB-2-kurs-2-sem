use Univer;

--����� �� ������ �������� ���, ��� �� ��� ������� ������������� ����������� (�� ��������� ������ � ������ ������)

--������ ��������� ddl, dml, try catch � ����������
--1---------------------------------------------
go --���������, ��������� ���-�� ��������� �� ����������
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
declare @faculty int = dbo.COUNT_STUDENTS('��');
print '���������� ���������: ' + cast(@faculty as varchar(4));

go
select FACULTY.FACULTY, dbo.COUNT_STUDENTS(FACULTY.FACULTY) [���������� ���������] from FACULTY;

go --@prof--������������ ���������
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
select FACULTY.FACULTY, dbo.COUNT_STUDENTS(FACULTY.FACULTY, default) [���������� ���������] from FACULTY;


--2---------------------------------------------
--���������, ���������� ������ � �������� ��������� � ������
--�-��� �������
go
create function FSUBJECTS(@p varchar(20)) returns varchar(300)
as
begin
    declare @subject varchar(10), @result varchar(100) = '����������';
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
select PULPIT, dbo.FSUBJECTS(PULPIT) [�������� ���������] from PULPIT;



--3---------------------------------------------
--��������� �������
--f - ���������
--� - �������
go
create function FFACPUL(@f varchar(20), @p varchar(20)) returns table
as return
  select FACULTY.FACULTY, PULPIT.PULPIT from FACULTY 
         left join PULPIT on FACULTY.FACULTY = PULPIT.FACULTY
	     where FACULTY.FACULTY = ISNULL(@f, FACULTY.FACULTY) and PULPIT.PULPIT = ISNULL(@p, PULPIT.PULPIT);

go
select * from dbo.FFACPUL(null, null);--���������� ������ ���� ������ �� ���� �����������
select * from dbo.FFACPUL('���', null);--���������� ������ ���� ������ ��������� ����������
select * from dbo.FFACPUL(null, '�����');--���������� �������������� �����, ���������� ������, ��������������� �������� �������
select * from dbo.FFACPUL('����', '�����');--���������� �������������� �����, ���������� ������, ��-������������� �������� ������� �� �������� ����������. 
select * from dbo.FFACPUL('��', '�����'); --����������, ������� ������ �����



--4---------------------------------------------
--���������, ���������� ���������� �������������� �� �������� ���������� �������. ���� �������� ����� NULL, 
--�� ������������ ����� ���������� ��������������. 
go
create function FCTEACHER(@p varchar(20)) returns int
as begin
	declare @rc int = (select count(*) from TEACHER where PULPIT = ISNULL(@p, PULPIT))
	return @rc
end

go
select distinct PULPIT, dbo.FCTEACHER(PULPIT)[���������� ��������������] from TEACHER
select dbo.FCTEACHER(null)[����� ���������� ��������������]


--6---------------------------------------------
--���������������� ��������� �������
go
create function FACULTY_REPORT(@c int) returns @fr table
	          ([���������] varchar(50), [���������� ������] int, [���������� �����] int,  [���������� ���������] int, [���������� ��������������] int )
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

--�������� ��� ������� ���, ����� ���������� ������, ���������� �����, ���������� 
--��������� � ���������� �������������� ����������� ���������� ���������� ���������.
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
