use UNIVER;

--��������� - ��� ������������� ��� �� ����� Transact-SQL.

--1---------------------------------------
--����������� �������� ��������� ��� ���������� � ������ PSUBJECT.
--� ����� ������ ��������� ������ ���������� ����-������ �����, ���������� � �������������� �����.
go
create procedure PSUBJECT
as
begin
	declare @count int = (select count(*) from SUBJECT)
	select SUBJECT.SUBJECT[���], SUBJECT.SUBJECT_NAME[����������], SUBJECT.PULPIT[�������] FROM SUBJECT
	return @count
end

--drop procedure PSUBJECT;
go
declare @count int = 0
EXEC @count = PSUBJECT
print '���������� ��������� = ' + cast(@count as varchar(3))



--2---------------------------------------
--����� ��, �� ��� ���� ��������� ������, ��������������� ���� �������, ��������� ���������� @p. ����� ����, ��������� ������ 
--����������� �������� ��������� ��������� @�, ������ ���������� ����� � �������������� ������, � ����� ���������� 
--�������� � ����� ������, ������ ������ ����-������ ��������� (���������� ����� � ������� SUBJECT). 
go
ALTER procedure [dbo].[PSUBJECT] @p varchar(20) = NULL, @c int output
as
begin
	declare @count int = (select count(*) from SUBJECT)
	print 'Parameters: @p = ' + @p + ', @c = ' + CAST(@c AS VARCHAR(3))
	select SUBJECT.SUBJECT[���], SUBJECT.SUBJECT_NAME[����������], SUBJECT.PULPIT[�������] FROM SUBJECT
	WHERE SUBJECT.PULPIT = @p
	SET @c = @@ROWCOUNT
	return @count
end

go
declare @count int = 0, @r int = 0, @p varchar(20); 
EXEC @count = PSUBJECT @p = '����', @c = @r output
print '���������� ���� ���������: ' + cast(@count as varchar(20));
print '���������� ��������� � ������� ' + @p + ': ' + cast(@r as varchar(20));



--3---------------------------------------
--������� ��������� ��������� ������� � ������ #SUBJECT. ������������ � ��� �������� ������� ������ ��������������� �������� ��������������� ������ ��������� PSUBJECT, ������������� � ������� 2. 
--�������� ��������� PSUBJECT ����� �������, ����� ��� �� ��������� ��������� ���������.
--�������� ����������� INSERT� EXECUTE � ���������������� ���������� PSUBJECT, �������� ������ � ������� #SUBJECT. 
create table #Subj
(
	��� char(10) primary key not null,
	���������� varchar(100),
	������� char(20)
)
--��������� ��� ��� ��������� ����� ���� ���������� ����� ��� ��� � ����
go
ALTER procedure PSUBJECT @p varchar(20)--��� �������
	as
begin
	declare @count int = (select count(*) from SUBJECT);
	select SUBJECT [���], SUBJECT_NAME [����������], PULPIT [�������] from SUBJECT where PULPIT = @p;
	return @count;
end;

insert #Subj exec PSUBJECT '���';
insert #Subj exec PSUBJECT '����';

select * from #Subj order by �������;



--4---------------------------------------
--��������� ������ ���������� � ����� ������ �������� -1 
--� ��� ������, ���� ��������� ������ � 1, ���� ���������� �������. 
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
    print '����� ������: ' + cast(error_number() as varchar(6));
	print '���������: ' + error_message();
	print '�������: ' + cast(error_severity() as varchar(10));
	print '�����: ' + cast(error_state() as varchar(10));
	print '� ������: ' + cast(error_line() as varchar(10));
	if error_procedure() is not null print '��� ���������: ' + error_procedure();
	return -1;
end catch;

go
declare @rc int;
exec @rc = PAUDITORIUM_INSERT '776-2', '��', 200, '776-2'
select @rc



--5---------------------------------------
--������ ��������� �� ���������� �������
--� ��� ������, ���� �� ��������� �������� @p ��-�������� ���������� ��� �������, ��������� ������ ������������ ������ � ���������� ������ � ����-������. 
--��������� SUBJECT_REPORT ������ ���������� � ����� ������ ���������� ���������, ������������ � ������. 

go
create procedure SUBJECT_REPORT
   @p char(10)--��� �������
as declare @r� int = 0;
begin try
   declare @sb char(10), @resstr varchar(350) = ''
   declare SUBJECTS cursor for
       select SUBJECT.SUBJECT from SUBJECT
	          where SUBJECT.PULPIT = rtrim(@p)
   if not exists (select SUBJECT.SUBJECT from SUBJECT where PULPIT = @p) 
       raiserror('������', 11, 1)
   else 
       open SUBJECTS
	   fetch SUBJECTS into @sb
	   print '����������: '
	   while @@FETCH_STATUS = 0
	     begin
		    set @resstr = rtrim(@sb) + ', ' + rtrim(@resstr)
			set @r� = @r� + 1
			fetch SUBJECTS into @sb;
		 end
		 print @resstr
		close SUBJECTS
		return @r�
end try
begin catch
    print '������!'
	print error_message();
	if error_procedure() is not null print '��� ��������� : ' + error_procedure();
	return @resstr
end catch;

go
declare @rc int;
exec @rc = SUBJECT_REPORT '���' 
print '���������� ��������� = ' + cast(@rc as varchar(3)); 




--6---------------------------------------
select * from AUDITORIUM_TYPE;
select * from AUDITORIUM;
go
create procedure PAUDITORIUM_INSERTX
   @a char(20), @n varchar(50), @c int = 0, @t char(10), @tn varchar(50)--��� ����� ���� � �������
as declare @rc int = 1;
begin try
   set transaction isolation level SERIALIZABLE;--�� ��������������� ����� (�� ����� ���� �� ����� ������ � ����� �������)
      begin tran
	     insert into AUDITORIUM_TYPE (AUDITORIUM_TYPE, AUDITORIUM_TYPENAME)
		        values (@t, @tn);
		 --������ ������ ����� ������ ��������� �� �������4
		 exec @rc = PAUDITORIUM_INSERT @a, @n, @c, @t;
      commit tran
   return @rc;
end try
--��������� PAUDITORIUM_INSERTX ������ ���������� � ����� ������ �������� -1 � ��� ������, ���� ��������� 
--������ � 1, ���� ���������� ��������� ����������� �������
begin catch
    print '����� ������: ' + cast(error_number() as varchar(6));
    print '���������: ' + error_message();
    print '�������: ' + cast(error_severity()  as varchar(6));
    print '�����: ' + cast(error_state()   as varchar(8));
    print '����� ������: ' + cast(error_line()  as varchar(8));
    if error_procedure() is not  null print '��� ���������: ' + error_procedure();
    if @@trancount > 0 rollback tran ; 
    return -1;	
end catch

go
declare @rc int;
exec @rc = PAUDITORIUM_INSERTX '781-1', '��_3.0', 100, '781-1', '���������';
print '��� ������ = ' + cast((@rc as varchar(3));

