--task1
go
declare @x char = 'd', 
		@y varchar(15) = 'doubt',
		@z datetime,
		@a time,
		@b int,
		@c smallint,
		@d tinyint, --��� ����������
		@e numeric(12,5)

set @z = (select cast(GETDATE() as datetime)); 
set @a = '10:40:00';

select @b = 2000000, @c = 32000, @e = 1111111.652335;

print 'x = ' + @x;
print 'y = ' + @y;
print 'z = ' + cast(@z as varchar(35));
print 'a = ' + cast(@a as varchar(10));

select @b [�������� ���������� b], @c [�������� ���������� c], @d [�������� ���������� d], @e [�������� ���������� e];
go


--task2
--����������� ������, � ������� ������������ ����� ����������� ���������. 
--����� ����� ����������� ��������� 200, �� ������� ���������� ���������, ������� ����������� ���������, ���������� ���������, ����������� ������� ������ �������, � ������� ����� ���������. 
--����� ����� ����������� ��������� ������ 200, �� ������� ��������� � ������� ����� �����������.

use Univer;
--select * from AUDITORIUM;

go
	declare @generalcapacity int = (select sum(AUDITORIUM_CAPACITY) from AUDITORIUM),
	@audcount int = (select Count(*) from AUDITORIUM),
	@avgcapacity int = (select avg(AUDITORIUM_CAPACITY) from AUDITORIUM),
	@audcountlessavg int, @audcountlessavgpercent int
	if @generalcapacity >= 200
		begin
		    select @audcountlessavg = (select count(*) from AUDITORIUM where AUDITORIUM_CAPACITY < @avgcapacity)
			set @audcountlessavgpercent = (@audcountlessavg * 100 / @audcount)

			select @audcount [���������� ���������], @avgcapacity [������� ����������� ���������], @audcountlessavg [���������� ���������, ����������� ������� ������ �������],
			@audcountlessavgpercent [������� ����� ���������]
		end
	else if @generalcapacity < 200
		print '������ ����� �����������: ' + cast(@generalcapacity as varchar(10))
go

--task3
--������� ���������� ����������

go

select * from AUDITORIUM;
print '���������� �����: ' + cast(@@ROWCOUNT as varchar(10));

print @@VERSION;
print @@SPID;

insert into AUDITORIUM values ('299-1', '�������', 20, '299-1');
print @@ERROR; --������ ����������, �� ������ - �������� ����������� � ��

print @@SERVERNAME;

begin tran
	begin tran
		print @@TRANCOUNT --������� ����������� ����������
	commit
commit 

select * from AUDITORIUM;
print '��������� ���������� ����� ��������������� ������: ' + cast(@@FETCH_STATUS as varchar(250)); -- 0 - �������

go
create procedure sp_InnerProc as   
    SELECT @@NESTLEVEL AS 'Inner Level'; 
go

go
create procedure sp_OuterProc as  
    select  @@NESTLEVEL as 'Outer Level';  
    exec sp_InnerProc;
go

execute sp_OuterProc;  

--drop procedure sp_InnerProc;
--drop procedure sp_OuterProc;

go


--task4-1
go
declare @z float, @t float = 3.5, @x float = 0.3;
if (@t > @x) set @z = power(sin(@t),2)
else if (@t < @x) set @z = 4 * (@t + @x)
else set @z = 1 - exp(@x - 2)
print 'z = ' + cast(@z as varchar(10))
go

--task4-2
declare @fullfio varchar(100) = '������ ����� ����������', @shortfio varchar(100), @spacepos1 int, @spacepos2 int;
set @spacepos1 = CHARINDEX (' ', @fullfio, 1);
set @spacepos2 = CHARINDEX (' ', @fullfio, @spacepos1+1);
set @shortfio = SUBSTRING(@fullfio, 1, @spacepos1) + SUBSTRING(@fullfio, @spacepos1+1, 1) + '.' + SUBSTRING(@fullfio, @spacepos2+1, 1) + '.'
print '����������� ���: ' + @shortfio

--��� ���� ������� ���������:
select NAME [������ ���], SUBSTRING(NAME, 1, CHARINDEX (' ', NAME, 1)) + SUBSTRING(NAME, CHARINDEX (' ', NAME, 1)+1, 1) + '.' + SUBSTRING(NAME, CHARINDEX (' ',  NAME, CHARINDEX (' ', NAME, 1)+1)+1, 1) + '.' [����������� ���] from STUDENT


--task4-3
declare @currentmonth int, @nextmonth int, @age int;
set @currentmonth = MONTH(GETDATE());
set @nextmonth = @currentmonth+1;
select NAME, BDAY, YEAR(GETDATE()) - YEAR(BDAY) [�������] from STUDENT where MONTH(BDAY)=@nextmonth
order by [�������];

--task4-4

--����� ��� ������, � ������� �������� ��������� ������ ������� ������� �� ����
--select * from student;  -- �������� IDSTUDENT, IDGROUP
--select * from groups;   -- c������� IDGROUP
--select * from progress; -- c������� IDSTUDENT, SUBJECT � PDATE

go
declare @subject varchar(10) = '����', @idgroup int = 5;
select NAME, STUDENT.IDGROUP, SUBJECT, PDATE, DATENAME(DW, PDATE) [���� ������] from
STUDENT inner join PROGRESS on STUDENT.IDSTUDENT = PROGRESS.IDSTUDENT
inner join GROUPS on GROUPS.IDGROUP = STUDENT.IDGROUP 
where SUBJECT = @subject and STUDENT.IDGROUP = @idgroup
go

--task5
go
declare @studentcount_subd int = (select Count(*) from PROGRESS where PROGRESS.SUBJECT like '%����%'), @studentcount_kg int = (select Count(*) from PROGRESS where PROGRESS.SUBJECT like '%��%');
if (@studentcount_subd >  @studentcount_kg) 
	begin 
		print '���������� ���������, ������� ����: ' + cast(@studentcount_subd as varchar(15))
		print '���������� ���������, ������� ��: ' + cast(@studentcount_kg as varchar(15))
		print '���� ����� ������ ���������, ��� ��'
	end;
else if (@studentcount_subd <  @studentcount_kg) 
	begin 
		print '���������� ���������, ������� ����: ' + cast(@studentcount_subd as varchar(15))
		print '���������� ���������, ������� ��: ' + cast(@studentcount_kg as varchar(15))
		print '���� ����� ������ ���������, ��� ��'
	end;
else 
	begin 
		print '���������� ���������, ������� ����: ' + cast(@studentcount_subd as varchar(15))
		print '���������� ���������, ������� ��: ' + cast(@studentcount_kg as varchar(15))
		print '�� ��������� ���� � �� ���� ���������� ���������� ���������'
	end;
go


--task6
--����������� ��������, � ������� � ������� CASE ������������� ������, ���������� ���������� ���������� ���������� ��� ����� ���������.

declare @startsuper int = 7, @endsuper int = 10, @startud int = 4, @endud int = 6, @startneud int = 1,  @endneud int = 3, @faculty varchar(15) = '��'
select
case 
	when NOTE between  @startsuper and @endsuper then '�������'
	when NOTE between  @startud and @endud then '�����������������'
	when NOTE between @startneud and @endneud then '������'
end [��������� ����� ��������],  Count (*) [����������]
from PROGRESS inner join STUDENT on PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
inner join GROUPS on STUDENT.IDGROUP = GROUPS.IDGROUP where GROUPS.FACULTY =  @faculty
group by 
case
	when NOTE between @startsuper and @endsuper then '�������'
	when NOTE between  @startud and @endud then '�����������������'
	when NOTE between  @startneud and  @endneud then '������'
end


--task7
CREATE table #TEMP
(   
ID int,
TEMPTEXT varchar(150),
TEMPDESCRIPTION varchar(150)
);

--drop table #TEMP;

set nocount on; --�� �������� ��������� � ����� �����
declare @i int = 0;
while @i<10
	begin
		insert #TEMP values (floor(3000 * rand()), replicate('little', 2), replicate('dark age', 2))
		if (@i % 100 = 0) print @i;
set @i = @i+1;
end;

select * from  #TEMP order by ID;

--task8
go
declare @x int = 50, @y int = -10, @res float = 0, @excepres varchar(25)
while @y<10
	begin
		if (@y!=0) set @res = @res + (@x / @y);
		else 
			begin
				set @excepres = '������� �� ����';
				print '���������� = ' + cast(@excepres as varchar (25));
				return;
			end;
		set @y = @y + 1;
		print '��������� = ' + cast(@res as varchar(10));
	end;
go


--task9
begin try
	insert into AUDITORIUM values ('299-1', '�������', 20, '299-1');
end try
begin catch
	print '��� ��������� ������: ' + cast(ERROR_NUMBER() as varchar(10));
	print '��������� �� ������: ' + cast(ERROR_MESSAGE() as varchar(250));
	print '������ � �������: ' + cast(ERROR_LINE() as varchar(25));
	print '��� ���������: ' + isnull(cast(ERROR_PROCEDURE() as varchar(50)), 'NULL');
	print '������� ����������� ������: ' + cast(ERROR_SEVERITY() as varchar(25));
	print '����� ������: ' + cast(ERROR_STATE() as varchar(25));
end catch
