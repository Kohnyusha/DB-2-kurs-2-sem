use Univer;
--атом
--согласованность - транзакция должна фиксировать новое согласованное состояние БД
--изол
-- долгов

--1-----------------------------------
--Разработать сценарий, демонстрирующий работу в режиме неявной транзакции.
--Проанализировать пример, приведенный справа, в котором создается таблица Х

set nocount on
if  exists (select * from  SYS.OBJECTS        -- таблица X есть?
			where OBJECT_ID= object_id(N'DBO.X') )	            
	drop table X;           
declare @c int, @flag char = 'c';           -- commit или rollback?
SET IMPLICIT_TRANSACTIONS  ON   -- включ. режим неявной транзакции
CREATE table X(K int );                         -- начало транзакции 
INSERT X values (1),(2),(3);
set @c = (select count(*) from X);
print 'количество строк в таблице X: ' + cast( @c as varchar(2));
if @flag = 'c'  
      commit;                   -- завершение транзакции: фиксация 
else   rollback;                                 -- завершение транзакции: откат  
SET IMPLICIT_TRANSACTIONS  OFF   -- выключ. режим неявной транзакции
	
if  exists (select * from  SYS.OBJECTS       -- таблица X есть?
	        where OBJECT_ID= object_id(N'DBO.X') )
	print 'таблица X есть';  
else print 'таблицы X нет'



--2-----------------------------------
--продемонстрировать свойство атомарности ЯВНОЙ транзакции. 
--В блоке CATCH предусмотреть выдачу соответствующих сообщений об ошибках. 


begin try
      begin tran --начало явной транз
	       delete FACULTY where FACULTY.FACULTY = 'ФГ'
		   insert FACULTY values ('ФКА', 'Факультет Кохнюк Александры')
      commit tran--фиксация
end try
begin catch
      print 'ОШИБКА: ' + case
	  when error_number() = 2627 and patindex('%PK_FACULTY%', error_message()) > 0
	    then 'Дублирование информации'
		  else 'Неизвестная ошибка: ' + cast(error_number() as varchar(5)) + error_message()
	  end;
  if @@TRANCOUNT > 0 rollback tran;
end catch

select * from FACULTY



--3-----------------------------------
--продемонстририровать применение оператора SAVE TRAN 
--В блоке CATCH предусмотреть выдачу соответствующих сообщений об ошибках. 

--если несколько независмых операторов, то SAVE TRAN формирует контр точку транзакции

declare @point varchar(32)
  begin try
    begin tran--начало явной транз
	  delete FACULTY where FACULTY.FACULTY = 'ФKA'
	  set @point = 'p1'; save tran @point;--контрольная точка 1
	  insert FACULTY values ('ФЛЧ', 'Факультет Любого Человека');
	  set @point = 'p2'; save tran @point;--контрольная точка 2
	  insert FACULTY values ('ФЕЧ', 'Факультет Единственного Человека');
	  commit tran;
	end try
begin catch
      print 'ОШИБКА: ' + case
	  when error_number() = 2627 and patindex('%PK_FACULTY%', error_message()) > 0
	    then 'Дублирование информации'
		  else 'Неизвестная ошибка: ' + cast(error_number() as varchar(5)) + error_message()
	  end;
  if @@TRANCOUNT > 0 rollback tran;
  begin
    print 'Контрольная точка: ' + @point;
	rollback tran @point;--откат к контрольной точке
	commit tran;--фиксация изм, выполненных до контрольной точки
	end;
end catch




--4-----------------------------------
--Разработать два сценария A и B 
--Сценарий A - явная транзакция с уровнем изолированности READ UNCOMMITED (Указывает, что инструкции могут считывать строки, которые были изменены другими транзакциями, но еще не были зафиксированы.)
--Сценарий B – явная транзакция с уровнем изолированности READ COMMITED (по умолчанию). Указывает, что инструкции не могут считывать данные, которые были изменены другими транзакциями, но еще не были зафиксированы
--Сценарий A должен демонстрировать, что уровень READ UNCOMMITED допускает неподтвержденное, неповторяющееся и фантомное чтение. 

set transaction isolation level READ UNCOMMITTED
begin transaction
--- А ---
-------------------------- t1 
--SPID системный идентификатор процесса назнач сервером текущему процессу 
select @@SPID, 'insert SUBJECT' 'результат', * from  SUBJECT
  where SUBJECT.PULPIT = 'ИСиТ';
select @@SPID, 'insert PROGRESS' 'результат',  * from PROGRESS 
  where PROGRESS.SUBJECT = 'NewSubject';
commit;
-------------------------- t2 




--5-----------------------------------
--Сценарии A и В - явные транзакции с уровнем изолированности READ COMMITED. 
--Сценарий A должен демонстрировать, что уровень READ COMMITED НЕ допускает неподтвержденного чтения,
--но при этом возможно неповторяющееся и фантомное чтение. 

-- A ---
set transaction isolation level READ COMMITTED
begin transaction
select count(*) from SUBJECT where SUBJECT.PULPIT = 'ИСиТ';
-------------------------- t1 
-------------------------- t2 
select 'update SUBJECT' 'результат', count(*)
    from SUBJECT where SUBJECT.PULPIT = 'ИСиТ';
commit;




--6-----------------------------------
--Сценарий A - явная транзакция с уровнем изолированности REPEATABLE READ. 
--Сценарий B – явная транзакция с уровнем изолированности READ COMMITED. 
--Сценарий A должен демонстрировать, что уровень REAPETABLE READ НЕ допускает неподтвержденного чтения 
--и неповторяющегося чтения, но при этом возможно фантомное чтение. 

-- A ---
set transaction isolation level READ COMMITTED
begin transaction
select count(*) from SUBJECT where SUBJECT.PULPIT = 'ИСиТ';
-------------------------- t1 
-------------------------- t2 
select case 
when SUBJECT.SUBJECT = 'БД'
   then 'insert SUBJECT' else ' ' 
   end 'результат', SUBJECT.SUBJECT from SUBJECT 
     where SUBJECT.PULPIT = 'ИСиТ';
commit;



--7------------------------------------
--Сценарий A - явная транзакция с уровнем изолированности SERIALIZABLE. 
--Сценарий B – явная транзакция с уровнем изолированности READ COMMITED.
--Сценарий A должен демонстрировать ОТСУТсТвиЕ фантомного, неподтвержденного и неповторяющегося чтения.

-- A ---
set transaction isolation level SERIALIZABLE
begin transaction
     delete SUBJECT where SUBJECT.SUBJECT = 'БД';
     insert SUBJECT values ('OOO', 'ooo', 'ИСиТ');
     update SUBJECT set SUBJECT.SUBJECT = 'БД' 
         where SUBJECT.PULPIT = 'ИСиТ';
     select * from SUBJECT where PULPIT = 'ИСиТ';
-------------------------- t1 -----------------
     select * from SUBJECT where PULPIT = 'ИСиТ';
-------------------------- t2 ------------------
commit;




--8------------------------------------
--Разработать сценарий, демон-стрирующий свойства вложен-ных транзакций, на примере базы данных X_UNIVER. 

create table #TEMPDB8
   (A INT, B INT);
insert #TEMPDB8 values(1,2);

begin tran--внешняя транзакция
    insert #TEMPDB8 values(999,2)
	    begin tran --внутренняя транз
	       update #TEMPDB8 set A = 1 
		      where B = 2
	    commit;--внутренняя транз
  if @@TRANCOUNT > 0 
     rollback--внешняя транзакция (отменяет тольеок внутр)
select * from #TEMPDB8
