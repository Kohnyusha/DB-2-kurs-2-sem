use K_MyBase;
--вариант 1

--1-----------------------
--создать процедуру для добавления сотрудника, обработать ошибки
go 
create procedure AddSalesreps
    @add_num int, @add_name varchar(20), @add_age int,@add_date date,@add_sales float 
as declare @rc int = 1;
begin try
    insert into SALESREPS (EMPL_NUM, NAME, AGE, HIRE_DATE, SALES)
	      values (@add_num, @add_name, @add_age, @add_date, @add_sales)
	return @rc;
end try
begin catch
 print 'номер ошибки: ' + cast(error_number() as varchar(6));
	print 'сообщение: ' + error_message();
	print 'уровень: ' + cast(error_severity() as varchar(10));
	print 'метка: ' + cast(error_state() as varchar(10));
	print '№ строки: ' + cast(error_line() as varchar(10));
	if error_procedure() is not null print 'имя процедуры: ' + error_procedure();
	return -1;
end catch


go
declare @rc int;
exec @rc = AddSalesreps 199, 'Kohnyuk Aleksandra', 18, '2022-05-31', 99999.00
select @rc







--4------------------------
go
create function COUNT_ZAKAZ (@r varchar(20)) returns int
as begin
declare @rc int = 0;
 set @rc = (select count(ORDER_NUM)
       from ORDERS join OFFICES
	   on  ORDERS.REP = OFFICES.MGR);
return @rc
end

go
declare @r varchar(20) = dbo.COUNT_ZAKAZ('Eastern');
print @r