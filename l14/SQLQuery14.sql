use Univer;


--ddl и dml(after, instead off)
--1---------------------------------------------
go
create table TR_AUDIT 
(
	ID int identity,
	STMT varchar(20) check (STMT in ('INS', 'DEL', 'UPD')),
	TRNAME varchar(50),
	CC varchar(300)
)
drop table TR_AUDIT;

--Триггер должен записывать строки вводимых данных в таблицу TR_AUDIT. 
--В столбец СС помещаются значения столбцов вводимой строки. 
go
create trigger TR_TEACHER_INS on TEACHER after INSERT
	as 
	declare @teach varchar(15), @teachname varchar(50), @gen char(1), @pul varchar(15), @in varchar(300);
	print 'Операция вставки';
	set @teach = (select TEACHER from inserted);
	set @teachname = (select TEACHER_NAME from inserted);
	set @gen = (select GENDER from inserted);
	set @pul = (select PULPIT from inserted);
	set @in = rtrim(@teach) + ' ' + rtrim(@teachname) + ' ' + @gen + ' ' + rtrim(@pul);
	insert into TR_AUDIT(STMT, TRNAME, CC) values ('INS', 'TR_TEACHER_INS', @in);
	return;
go

insert into teacher values ('лмлм', 'Ааа Ааа Ааа', 'м', 'ИСиТ')
select * from TR_AUDIT



--2---------------------------------------------
--Триггер должен записывать строку данных в таблицу TR_AUDIT для каждой удаляемой строки. 
--В столбец СС помещаются значения столбца TEACHER удаляемой строки. 
go
create trigger TR_TEACHER_DEL on TEACHER after DELETE
	as 
	declare @teach varchar(15), @teachname varchar(50), @gen char(1), @pul varchar(15), @in varchar(300);
	print 'Операция удаления';
	set @teach = (select TEACHER from deleted)
	set @teachname = (select TEACHER_NAME from deleted)
	set @gen = (select GENDER from deleted)
	set @pul = (select PULPIT from deleted)
	set @in = rtrim(@teach) + ' ' + rtrim(@teachname) + ' ' + @gen + ' ' + rtrim(@pul)
	insert into TR_AUDIT(STMT, TRNAME, CC) values ('DEL', 'TR_TEACHER_DEL', @in)
	return

go
delete teacher where TEACHER = 'ЖЛК';
select * from TR_AUDIT;


--3---------------------------------------------
--Триггер должен записывать строку данных в таблицу TR_AUDIT для каждой изменяемой строки. 
--В столбец СС помещаются значения столбцов изменяемой строки до и после изменения.
go
create trigger TR_TEACHER_UPD on TEACHER after UPDATE
	as 
	declare @teach varchar(15), @teachname varchar(50), @gen char(1), @pul varchar(15), @in varchar(300);
	print 'Операция изменения'
	set @teach = (select TEACHER from inserted)
	set @teachname = (select TEACHER_NAME from inserted)
	set @gen = (select GENDER from inserted)
	set @pul = (select PULPIT from inserted)
	set @in =  rtrim(@teach) + ' ' + rtrim(@teachname) + ' ' + @gen + ' ' + rtrim(@pul)

	set @teach = (select TEACHER from deleted)
	set @teachname = (select TEACHER_NAME from deleted)
	set @gen = (select GENDER from deleted)
	set @pul = (select PULPIT from deleted)
	set @in = '||БЫЛО: ' + rtrim(@teach) + ' ' + rtrim(@teachname) + ' ' + @gen + ' ' + rtrim(@pul) + ' ||СТАЛО: ' + @in
	insert into TR_AUDIT(STMT, TRNAME, CC) values ('UPD', 'TR_TEACHER_UPD', @in)
	return

go
update TEACHER set TEACHER_NAME = 'Р р р р р' where TEACHER = 'АКНВЧ';
select * from TR_AUDIT;



--4---------------------------------------------
 
go
create trigger TR_TEACHER on TEACHER after INSERT, DELETE, UPDATE
	as
	declare @teach varchar(15), @teachname varchar(50), @gen char(1), @pul varchar(15), @in varchar(300);
	declare @ins int = (select count(*) from inserted), 
			@del int = (select count(*) from deleted);
	if @ins > 0 and @del = 0--опред событие, активир действие
		begin
			print 'Операция добавления';
			set @teach = (select TEACHER from inserted);
			set @teachname = (select TEACHER_NAME from inserted);
			set @gen = (select GENDER from inserted);
			set @pul = (select PULPIT from inserted);
			set @in = rtrim(@teach) + ' ' + rtrim(@teachname) + ' ' + @gen + ' ' + rtrim(@pul);
			insert into TR_AUDIT(STMT, TRNAME, CC) values ('INS', 'TR_TEACHER', @in);
			return;
		end;
	else
	if @ins = 0 and @del > 0
		begin
			print 'Операция удаления';
			set @teach = (select TEACHER from deleted);
			set @teachname = (select TEACHER_NAME from deleted);
			set @gen = (select GENDER from deleted);
			set @pul = (select PULPIT from deleted);
			set @in = rtrim(@teach) + ' ' + rtrim(@teachname) + ' ' + @gen + ' ' + rtrim(@pul);
			insert into TR_AUDIT(STMT, TRNAME, CC) values ('DEL', 'TR_TEACHER', @in);
			return;
		end;
	else 
	if @ins > 0 and  @del > 0 
	begin
		print 'Операция изменения';
		set @teach = (select TEACHER from inserted);
		set @teachname = (select TEACHER_NAME from inserted);
		set @gen = (select GENDER from inserted);
		set @pul = (select PULPIT from inserted);
		set @in = rtrim(@teach) + ' ' + rtrim(@teachname) + ' ' + @gen + ' ' + rtrim(@pul);

		set @teach = (select TEACHER from deleted);
		set @teachname = (select TEACHER_NAME from deleted);
		set @gen = (select GENDER from deleted);
		set @pul = (select PULPIT from deleted);
		set @in = rtrim(@teach) + ' ' + rtrim(@teachname) + ' ' + @gen + ' ' + rtrim(@pul) + ' -> ' + @in;
		insert into TR_AUDIT(STMT, TRNAME, CC) values ('UPD', 'TR_TEACHER', @in);
	end
	return

go
insert into TEACHER values ('БББ', 'Ббб Ббб Ббб', 'м', 'ИСиТ');
update TEACHER set TEACHER_NAME = 'АКНВЧ' where TEACHER = 'БББ';
delete TEACHER where TEACHER = 'БББ';
select * from TR_AUDIT;



--5---------------------------------------------
--проверка ограничения целостности выполняется до срабатывания AFTER-триггера

go
update TEACHER set GENDER = 'а' where TEACHER = 'АКНВЧ';
select * from TR_AUDIT;



--6---------------------------------------------
go
create trigger TR_TEACHER_DEL1 on TEACHER after DELETE  
       as 
	   insert into TR_AUDIT(STMT, TRNAME) values ('DEL', ' TR_TEACHER_DEL1');
	return;  
go 
create trigger TR_TEACHER_DEL2 on TEACHER after DELETE  
       as 
	   insert into TR_AUDIT(STMT, TRNAME) values ('DEL', ' TR_TEACHER_DEL2');
	return;  
go 
create trigger TR_TEACHER_DEL3 on TEACHER after DELETE  
       as 
	   insert into TR_AUDIT(STMT, TRNAME) values ('DEL', ' TR_TEACHER_DEL3');
	return;  

--представление каталога
	select t.name, e.type_desc 
from sys.triggers t join sys.trigger_events e  
	on t.object_id = e.object_id  
		where OBJECT_NAME(t.parent_id) = 'TEACHER';
go


 --Изменение порядка выполнения триггеров выполняется с помощью системных процедур

exec sp_settriggerorder @triggername = 'TR_TEACHER_DEL3',
	@order = 'First', @stmttype = 'DELETE';

exec sp_settriggerorder @triggername = 'TR_TEACHER_DEL2',
	@order = 'Last', @stmttype = 'DELETE';

insert into TEACHER values ('БББ', 'Ббб Ббб Ббб', 'м', 'ИСиТ');
delete TEACHER where TEACHER = 'БББ';
select * from TR_AUDIT;
go

--7---------------------------------------------
--AFTER триггер является частью транзакции, в рамках которого выполняется оператор, активизировавший триггер
go
create trigger TR_AUDITORIUM on AUDITORIUM after INSERT, UPDATE
	as 
	declare @c int = (select sum(AUDITORIUM_CAPACITY) from AUDITORIUM);
	if (@c > 500)
		begin
			raiserror('Общая вместимость аудиторий не может быть больше 500', 10, 1);
			rollback;
		end;
	return;

go
insert AUDITORIUM values ('500-1', 'ЛБ-К', 500, '500-1');
select * from AUDITORIUM;
go
select * from TR_AUDIT;



--8---------------------------------------------
--OF выполняется вместо оператора, вызвавшего соответствующее событие. 
--Выполнение INSTEAD OF триггера предшествует проверке установленных для таблицы ограничений целостности.
go
create trigger TR_FACULTY_INSTEAD_OF on FACULTY instead of DELETE
	as raiserror('Удаление запрещено', 10, 1);
	return;
go

delete FACULTY where FACULTY = 'ИТ';
select * from FACULTY
go



drop trigger TR_TEACHER_INS
drop trigger TR_TEACHER_DEL
drop trigger TR_TEACHER_UPD
drop trigger TR_TEACHER
drop trigger TR_TEACHER_DEL1
drop trigger TR_TEACHER_DEL2
drop trigger TR_TEACHER_DEL3
drop trigger TR_AUDITORIUM
drop trigger TR_FACULTY_INSTEAD_OF
drop table TR_AUDIT
go


--9---------------------------------------------
--DDl - триггер-транз
--реагирует на все события в бд, запрещает созд таблицы и удалять существующие
create trigger TR_DDL_UNIVER on database for DDL_DATABASE_LEVEL_EVENTS
	as 
	--представление xml с инфой о событии вызв триггер
	declare @ev_type varchar(50) = eventdata().value('(/EVENT_INSTANCE/EventType)[1]', 'varchar(50)');
	declare @obj_name varchar(50) = eventdata().value('(/EVENT_INSTANCE/ObjectName)[1]', 'varchar(50)');
	declare @obj_type varchar(50) = eventdata().value('(/EVENT_INSTANCE/ObjectType)[1]', 'varchar(50)');
	if (@ev_type = 'CREATE_TABLE') 
		begin
			raiserror('Создание таблиц запрещено', 16, 1);
			rollback;
		end;
	if (@ev_type = 'DROP_TABLE') 
		begin
			raiserror('Удаление таблиц запрещено', 16, 1);
			rollback;
		end;
go

create table TESTING (value int);
go
drop table TR_AUDIT;
go

ALTER TRIGGER TR_DDL_UNIVER on database for DDL_DATABASE_LEVEL_EVENTS
AS
	PRINT('СОБЫТИЕ');
GO