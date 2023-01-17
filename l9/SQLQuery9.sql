use Univer;

--������ � ��� ������ ���� ������, ����������� �������� ����� � ������������ �������,���
--��� ��� ���� ������ ������������ � ���� ����������������� ��������� ������ ������. 
--1---------------------------------------
EXEC sp_helpindex 'AUDITORIUM'
EXEC sp_helpindex 'AUDITORIUM_TYPE'
EXEC sp_helpindex 'FACULTY'
EXEC sp_helpindex 'GROUPS'
EXEC sp_helpindex 'PROFESSION'
EXEC sp_helpindex 'PROGRESS'
EXEC sp_helpindex 'PULPIT'
EXEC sp_helpindex 'STUDENT'
EXEC sp_helpindex 'SUBJECT'
EXEC sp_helpindex 'TEACHER'

--������� ��������� ��������� �������. ��������� �� ������� (�� ����� 1000 �����)
CREATE table #TEMP
(
	SOMEVAR INT,
	SOMESTR NVARCHAR(MAX)
)

set nocount on; -- �� �������� ��������� � ������ �����
declare @i int = 0;
while @i < 1000
	begin
		INSERT #TEMP values(@i, 'string');
			set @i += 1;
	end

--����������� SELECT-������. �������� ���� ������� � ���������� ��� ���������. 
select * from #TEMP where SOMEVAR between 500 and 800 order by SOMEVAR 

-- ������� ����� ��� ���� ������
checkpoint;--�������� ��
dbcc DROPCLEANBUFFERS;--������� ��������� ����

--�������� ����������������� �������
create clustered index #EXPLRE_CL on #TEMP(SOMEVAR asc)--����� ����� ��������� ����������
select * from #TEMP where SOMEVAR between 500 and 800 order by SOMEVAR 
drop index #EXPLRE_CL on #TEMP;
--2---------------------------------------
--������������������ ������� �� ������ �� ���������� ������� ����� � �������. 
CREATE table #EXAMPLE
(    TKEY int, 
      CC int identity(1, 1),
      TF varchar(100)
);

  set nocount on;           
  declare @i1 int = 0;
  while   @i1 < 20000     
  begin
       INSERT #EXAMPLE(TKEY, TF) values(floor(30000*RAND()), replicate('������ ', 10));
        set @i1 = @i1 + 1; 
  end

SELECT count(*)[���������� �����] from #EXAMPLE;
SELECT * from #EXAMPLE

--����, ������, ���������
create index #EX_NONCLU on #EXAMPLE(TKEY, CC)

select * from  #EXAMPLE where  TKEY > 1500 and  CC < 4500;  
select * from  #EXAMPLE order by  TKEY, CC

select * from  #EXAMPLE where  TKEY = 560 and  CC > 3

--3--������������������ ������ ��������-------------------------------------
--��� � ������ ��� ������ ���� ����� �������
CREATE  index #EX_TKEY_X on #EXAMPLE(TKEY) INCLUDE (CC)
DROP INDEX #EX_TKEY_X ON #EX

SELECT CC from #EXAMPLE where TKEY>15000

--4---------------------------------------
--���� ������� �������� �� WHERE-���������� �����, �� ����� ���� ����������� 
--���������� ����������� ������������������ ��������
CREATE table #EXAMPLE2
(    TKEY2 int, 
      CC2 int identity(1, 1),
      TF2 varchar(100)
);
drop table #EXAMPLE2;

  set nocount on;           
  declare @i2 int = 0;
  while   @i2 < 10001     
  begin
       INSERT #EXAMPLE2(TKEY2, TF2) values(floor(30000*RAND()), replicate('������ ', 10));
        set @i2 = @i2 + 1; 
  end

select TKEY2 from  #EXAMPLE2 where TKEY2 between 2000 and 10000; 
select TKEY2 from  #EXAMPLE2 where TKEY2 > 5000 and  TKEY2 < 10001  
select TKEY2 from  #EXAMPLE2 where TKEY2 = 7000

--������� ������ ���� ������, ����������� ���������
create  index #EX_WHERE on #EXAMPLE2(TKEY2) where (TKEY2 >= 5000 and TKEY2 < 10001); 

--5---------------------------------------
create index #EX_TKEY ON #EXAMPLE2(TKEY2); --���������

--������� ������� ������������ �������. 
SELECT name [������], avg_fragmentation_in_percent [������������ (%)]
        FROM sys.dm_db_index_physical_stats(DB_ID(N'TEMPBD'), 
        OBJECT_ID(N'#EXAMPLE2'), NULL, NULL, NULL) ss
        JOIN sys.indexes ii on ss.object_id = ii.object_id and ss.index_id = ii.index_id  
        WHERE name is not null;

--����������� �������� �� T-SQL, ���������� �������� �������� � ������ ������������ ������� ���� 90%. 
--������� ������� ������������ �������. 

INSERT top(10000) #EXAMPLE2(TKEY2, TF2) select TKEY2, TF2 from #EXAMPLE2;

ALTER index #EX_TKEY on #EXAMPLE2 reorganize;--����� ��� ������������ ����� ������ ������ �� ����� ������ ������.
ALTER index #EX_TKEY on #EXAMPLE2 rebuild with (online = off);--����������� ��� ���� ������, ������� ����� �� ���������� ������� ������������ ����� ����.

--6---------------------------------------
--����������� ������, ������������-��� ���������� ��������� FILLFACTOR ��� �������� ����������-��������� �������.
--�������� FILLFACTOR ��������� ������� ���������� ��������� ������� ������� ������.

CREATE index #EX_TKEY2 on #EXAMPLE2(TKEY2) with (fillfactor = 65);
INSERT top(1000) #EXAMPLE2(TKEY2, TF2) select TKEY2, TF2 from #EXAMPLE2;

SELECT name [������], avg_fragmentation_in_percent [������������ (%)]
        FROM sys.dm_db_index_physical_stats(DB_ID(N'TEMPBD'), 
        OBJECT_ID(N'#EXAMPLE2'), NULL, NULL, NULL) ss
        JOIN sys.indexes ii on ss.object_id = ii.object_id and ss.index_id = ii.index_id  
        WHERE name is not null;
