use Univer;

--Индекс – это объект базы данных, позволяющий ускорить поиск в определенной таблице,так
--как при этом данные организуются в виде сбалансированного бинарного дерева поиска. 
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

--Создать временную локальную таблицу. Заполнить ее данными (не менее 1000 строк)
CREATE table #TEMP
(
	SOMEVAR INT,
	SOMESTR NVARCHAR(MAX)
)

set nocount on; -- не выводить сообщения о выводе строк
declare @i int = 0;
while @i < 1000
	begin
		INSERT #TEMP values(@i, 'string');
			set @i += 1;
	end

--Разработать SELECT-запрос. Получить план запроса и определить его стоимость. 
select * from #TEMP where SOMEVAR between 500 and 800 order by SOMEVAR 

-- очищаем буфер для след оценки
checkpoint;--фиксация бд
dbcc DROPCLEANBUFFERS;--очистка буферного кэша

--создание кластеризованного индекса
create clustered index #EXPLRE_CL on #TEMP(SOMEVAR asc)--после этого стоимость уменьшится
select * from #TEMP where SOMEVAR between 500 and 800 order by SOMEVAR 
drop index #EXPLRE_CL on #TEMP;
--2---------------------------------------
--Некластеризованные индексы не влияют на физический порядок строк в таблице. 
CREATE table #EXAMPLE
(    TKEY int, 
      CC int identity(1, 1),
      TF varchar(100)
);

  set nocount on;           
  declare @i1 int = 0;
  while   @i1 < 20000     
  begin
       INSERT #EXAMPLE(TKEY, TF) values(floor(30000*RAND()), replicate('строка ', 10));
        set @i1 = @i1 + 1; 
  end

SELECT count(*)[количество строк] from #EXAMPLE;
SELECT * from #EXAMPLE

--сост, неуник, некластер
create index #EX_NONCLU on #EXAMPLE(TKEY, CC)

select * from  #EXAMPLE where  TKEY > 1500 and  CC < 4500;  
select * from  #EXAMPLE order by  TKEY, CC

select * from  #EXAMPLE where  TKEY = 560 and  CC > 3

--3--Некластеризованный индекс покрытия-------------------------------------
--вкл в состав инд строки знач неинд столбца
CREATE  index #EX_TKEY_X on #EXAMPLE(TKEY) INCLUDE (CC)
DROP INDEX #EX_TKEY_X ON #EX

SELECT CC from #EXAMPLE where TKEY>15000

--4---------------------------------------
--Если запросы основаны на WHERE-фильтрации строк, то может быть эффективным 
--применение фильтруемых некластеризованных индексов
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
       INSERT #EXAMPLE2(TKEY2, TF2) values(floor(30000*RAND()), replicate('строка ', 10));
        set @i2 = @i2 + 1; 
  end

select TKEY2 from  #EXAMPLE2 where TKEY2 between 2000 and 10000; 
select TKEY2 from  #EXAMPLE2 where TKEY2 > 5000 and  TKEY2 < 10001  
select TKEY2 from  #EXAMPLE2 where TKEY2 = 7000

--создаем фильтр некл индекс, уменьшающий стоимость
create  index #EX_WHERE on #EXAMPLE2(TKEY2) where (TKEY2 >= 5000 and TKEY2 < 10001); 

--5---------------------------------------
create index #EX_TKEY ON #EXAMPLE2(TKEY2); --некластир

--Оценить уровень фрагментации индекса. 
SELECT name [Индекс], avg_fragmentation_in_percent [Фрагментация (%)]
        FROM sys.dm_db_index_physical_stats(DB_ID(N'TEMPBD'), 
        OBJECT_ID(N'#EXAMPLE2'), NULL, NULL, NULL) ss
        JOIN sys.indexes ii on ss.object_id = ii.object_id and ss.index_id = ii.index_id  
        WHERE name is not null;

--Разработать сценарий на T-SQL, выполнение которого приводит к уровню фрагментации индекса выше 90%. 
--Оценить уровень фрагментации индекса. 

INSERT top(10000) #EXAMPLE2(TKEY2, TF2) select TKEY2, TF2 from #EXAMPLE2;

ALTER index #EX_TKEY on #EXAMPLE2 reorganize;--после нее фрагментация будет убрана только на самом нижнем уровне.
ALTER index #EX_TKEY on #EXAMPLE2 rebuild with (online = off);--затрагивает все узлы дерева, поэтому после ее выполнения степень фрагментации равна нулю.

--6---------------------------------------
--Разработать пример, демонстрирую-щий применение параметра FILLFACTOR при создании некластери-зованного индекса.
--Параметр FILLFACTOR указывает процент заполнения индексных страниц нижнего уровня.

CREATE index #EX_TKEY2 on #EXAMPLE2(TKEY2) with (fillfactor = 65);
INSERT top(1000) #EXAMPLE2(TKEY2, TF2) select TKEY2, TF2 from #EXAMPLE2;

SELECT name [Индекс], avg_fragmentation_in_percent [Фрагментация (%)]
        FROM sys.dm_db_index_physical_stats(DB_ID(N'TEMPBD'), 
        OBJECT_ID(N'#EXAMPLE2'), NULL, NULL, NULL) ss
        JOIN sys.indexes ii on ss.object_id = ii.object_id and ss.index_id = ii.index_id  
        WHERE name is not null;
