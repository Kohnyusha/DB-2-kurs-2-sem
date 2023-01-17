use Univer;

--1---------------------------------------
declare @a char(2) = '��',
		@b varchar(4) = '����',
		@c datetime,
		@d time,
		@e int,--�� ������
		@f smallint,
		@g tinyint,--������� ���
		@h numeric(12,5);

set @c = (select top(1) BDAY from STUDENT);
set @d = getdate();
select @f = -1, @g = 1, @h = 14.55;

select @a a, @b b, @c c, @d d;
print 'f = ' + convert(char, @f) + 'g = ' + convert(char, @g) + 'h = ' + convert(char, @h);
go
--2---------------------------------------
--����������� ������, � ������� ������������ ����� ����������� ���������. 
--����� ����� ����������� ��������� 200, �� ������� ���������� ���������, ������� ����������� ���������, ���������� ���������, ����������� ������� ������ �������, � ������� ����� ���������. 
--����� ����� ����������� ��������� ������ 200, �� ������� ��������� � ������� ����� �����������.
--audavg - ���������� ���������, ����������� ������� ������ ��
go
declare @cap int = convert(int, (select sum(AUDITORIUM_CAPACITY) from AUDITORIUM)), @countaud int, @avgcap int, @audavg int, @procent float;
	    if @cap >= 200
		   begin
		         select @countaud = (select count(*) from AUDITORIUM);
				 select @avgcap = (select avg(AUDITORIUM_CAPACITY) from AUDITORIUM);
				 select @audavg = (select count(AUDITORIUM) from AUDITORIUM 
				                                            where AUDITORIUM_CAPACITY < @avgcap);
                 select @procent = (@audavg * 100 / @countaud);
				 select @countaud [���������� ���������], @avgcap [������� ����������� ���������], @audavg [���������� ���������, ����������� ������� ������ �������], @procent [������� ����� ���������]
		   end
		   else if @cap < 200
		         print '������ ����� ����������� = ' + convert(char, @cap);

--3---------------------------------------
--������� ���������� ����������
go
select * from AUDITORIUM;
print '����� ������������ �����: ' + cast(@@ROWCOUNT as varchar(10));

print @@VERSION;
print @@SPID;--��������� ������������� ��������

--insert into AUDITORIUM values ('299-1', '�������', 20, '299-1');
print @@ERROR;

print @@SERVERNAME;

begin tran
	begin tran
		print @@TRANCOUNT --������� ����������� ����������
	commit
commit 

select * from AUDITORIUM;
print '�������� ���������� ���������� ����� ��������������� ������: ' + cast(@@FETCH_STATUS as varchar(300));--0 ��� �������

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

--4.2 �������������� ������� ��� �������� � ����������� ---------------------------------------
declare @fio varchar(50) = '������ ���������� ���������', @shotrfio varchar(20), @spacepos1 int, @spacepos2 int;
  set @spacepos1 = charindex(' ', @fio, 1);
  set @spacepos2 = charindex(' ', @fio, @spacepos1 + 1);
  set @shotrfio = substring(@fio, 1, @spacepos1) + substring(@fio, @spacepos1 + 1, 1) + '.' + substring(@fio, @spacepos2 + 1, 1) + '.';
print '����������� ���: ' + @shotrfio;

--4.3---------------------------------------
--����� ���������, � ������� ���� �������� � ��������� ������, � ����������� �� ��������
declare @currentmonth int, @nextmonth int, @age int;
  set @currentmonth = month(getdate());
  set @nextmonth = @currentmonth + 1;
  select NAME, BDAY, year(getdate()) - year(BDAY) [�������] from STUDENT
               where month(BDAY) = @nextmonth
			   order by [�������];

--4.4---------------------------------------
--����� ��� ������, � ������� �������� ��������� ������ ������� ������� �� ����
declare @subj varchar(10) = '����', @idgroup int = 5;
  select NAME, STUDENT.IDGROUP, PROGRESS.SUBJECT, PROGRESS.PDATE, datename(DW, PDATE) [���� ������]
         from STUDENT 
		   inner join PROGRESS on STUDENT.IDSTUDENT = PROGRESS.IDSTUDENT
		   inner join GROUPS on STUDENT.IDGROUP = GROUPS.IDGROUP
		   where PROGRESS.SUBJECT = @subj and STUDENT.IDGROUP = @idgroup

--5 ������������������ ����������� IF� ELSE ---------------------------------------
declare @st_kg int, @st_oaip int;
  set @st_kg = (select count(*) from PROGRESS where PROGRESS.SUBJECT = '��');
  set @st_oaip = (select count(*) from PROGRESS where PROGRESS.SUBJECT = '����');
     if (@st_kg > @st_oaip) 
	    begin
		   print '���������� ���������, ������� ��: ' + cast(@st_kg as varchar(15))
		   print '���������� ���������, ������� ����: ' + cast(@st_oaip as varchar(15))
		   print '�� ����� ������ ���������, ��� ����'
	    end;
     if (@st_kg < @st_oaip) 
	    begin
		   print '���������� ���������, ������� ��: ' + cast(@st_kg as varchar(15))
		   print '���������� ���������, ������� ����: ' + cast(@st_oaip as varchar(15))
		   print '�� ����� ������ ���������, ��� ����'
	    end;
	 else 
	    begin 
		   print '���������� ���������, ������� ����: ' + cast(@st_kg as varchar(15))
		   print '���������� ���������, ������� ��: ' + cast(@st_oaip as varchar(15))
		   print '�� ��������� ���� � �� ���� ���������� ���������� ���������'
	    end;

--6---------------------------------------
--������ ������, ���������� ���������� ���������� ���������� ��� ����� ���������
--case - ��� ������������ ������ �� ���������� ��������� ��������
declare @super int = 10, @normal int = 8, @poidet int = 5, @ploho int = 3, @yzhasno int = 1, @fac varchar(20) = '��';
  select
    case
	    when NOTE between @normal and @super then '�������'
		when NOTE between @poidet and @normal then '������'
		when NOTE between @ploho and @poidet then '�����������������'
		when NOTE between @yzhasno and @ploho then '�����������������'
	end [��������� �����], count(*) [����������]
	from PROGRESS 
	    inner join STUDENT on PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
		inner join GROUPS on STUDENT.IDGROUP = GROUPS.IDGROUP
		   where GROUPS.FACULTY = @fac
  group by 
    case 
	    when NOTE between @normal and @super then '�������'
		when NOTE between @poidet and @normal then '������'
		when NOTE between @ploho and @poidet then '�����������������'
		when NOTE between @yzhasno and @ploho then '�����������������'
    end

--7 ������� ��������� ��������� ������� �� ���� �������� � 10 �����, ��������� �� � ������� ����������. ---------------------------------------
--���������� ��� � ##
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
		insert #TEMP values (floor(3000 * rand()), replicate('little', 2), replicate('dark age', 2))--���� ���������� ���� �����
		if (@i % 100 = 0) print @i;
set @i = @i+1;
end;

select * from  #TEMP order by ID;

--8 ����������� ������, ��������������� ������������� ��������� RETURN. ---------------------------------------
--return ��� ������������ ���������� ������ ������
go
declare @x int = 2
	print @x+1
	print @x+10
	return
	print @x+300
go

--9 ����������� �������� � ��������, � ��-����� ������������ ��� ��������� ������ ����� TRY � CATCH....---------------------------------------
begin try
	insert into AUDITORIUM values ('299-1', '�������', 20, '299-1');
end try
begin catch
	print '��� ��������� ������: ' + cast(ERROR_NUMBER() as varchar(10));
	print '��������� �� ������: ' + cast(ERROR_MESSAGE() as varchar(250));
	print '������ � ������� (���): ' + cast(ERROR_LINE() as varchar(25));
	print '��� ���������: ' + isnull(cast(ERROR_PROCEDURE() as varchar(50)), 'NULL');
	print '������� ����������� ������: ' + cast(ERROR_SEVERITY() as varchar(25));
	print '����� ������: ' + cast(ERROR_STATE() as varchar(25));
end catch