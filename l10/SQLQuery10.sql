use Univer;
--������ �������� ����������� ������������, ������� ���� ����������� 
--������������ ������������ ������ ��������������� ������ ������ �� �������

--1---------------------------
--����������� ��������, ����������� ������ ��������� �� ������� ����. � ����� ������ ���� �������� ������� �������� 
--(���� SUBJECT) �� ������� SUBJECT � ���� ������ ����� �������. 
--������������ ���������� ������� RTRIM.

declare cursor1 cursor 
        for select SUBJECT.SUBJECT from SUBJECT
		           where SUBJECT.PULPIT = '����';

declare @subjname varchar(10), @allsubj varchar(300) = ' ';

--�������� FETCH ��������� ���� ������ �� ��������������� ������ � ���������� ��������� �� ��������� ������
--� ��������� ������� @fetch_status
--(0)�������
--(-1) ������ ����� ��� ������ � ��� �� ����
--(-2)������ ��������
open cursor1
fetch cursor1 into @subjname
     while @@fetch_status = 0 --������ �������
	 begin
		set @allsubj = rtrim(@subjname) + ', ' + @allsubj--rtrim ������� �������
		fetch cursor1 into @subjname
	 end
close cursor1
print @allsubj

--2---------------------------
--����������� ��������, ��������������� ������� ����������� ������� �� ���������o

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
--����������� ��������, ��������������� ������� ����������� �������� �� ������������

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
--����������� ��������, ��������������� �������� ��������� � �������������� ������ ������� � ��������� SCROLL
--������������ ��� ��������� �����-��� ����� � ��������� FETCH.

declare @str1 varchar(MAX)
declare curs cursor scroll for select TEACHER.TEACHER_NAME from TEACHER
open curs
fetch next from curs into @str1
fetch next from curs into @str1
fetch next from curs into @str1
fetch next from curs into @str1
print 'NEXT: '+@str1
fetch prior from curs into @str1--������
print 'PRIOR: '+@str1
fetch first from curs into @str1
print 'FIRST: '+@str1
fetch last from curs into @str1
print 'LAST: '+@str1
fetch absolute 2 from curs into @str1
print 'ABSOLUTE 2: '+@str1
fetch relative -1 from curs into @str1
print 'RELATIVE -1: '+@str1--�� �������
close curs
deallocate curs

--5---------------------------
--������� ������, ��������������� ���������� ����������� CURRENT OF � ������ WHERE � 
--�������������� ���������� UPDATE � DELETE.

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
--����������� SELECT-������, � ������� �������� �� ������� PROGRESS ��������� ������, ���������� ���������� 
--� ���������, ���������� ������ ���� 4 (������������ ����������� ������ PROGRESS, STUDENT, GROUPS). 
drop table #TEMP

select PROGRESS.NOTE into #TEMP from PROGRESS
	inner join STUDENT on STUDENT.IDSTUDENT = PROGRESS.IDSTUDENT
	inner join GROUPS on GROUPS.IDGROUP = STUDENT.IDGROUP
select * from #TEMP


declare @subj char(10), @id int, @dt date, @note int
declare CURS cursor dynamic for select * from PROGRESS for update--��� ���������� ������
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

--����������� SELECT-������, � ��-����� �������� � ������� PROGRESS ��� �������� � ���������� ������� IDSTUDENT 
--�������������� ������ (������������� �� �������).

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
