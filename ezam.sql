use EXAM;

--1
--Подсчитать среднюю цену товара для каждого покупателя и отсортировать по среднему значению цены заказа.
select CUST [Покупатель], avg(AMOUNT) [Средняя цена]
from ORDERS
group by CUST
order by avg(AMOUNT)


--2
--Найти офисы, у которых есть заказ стоимостью выше 15000, и отсортировать по стоимости заказа.
select OFFICE [Офис], AMOUNT [Стоимость]
from OFFICES inner join SALESREPS
     on OFFICES.OFFICE = SALESREPS.REP_OFFICE
	 inner join ORDERS
	 on SALESREPS.EMPL_NUM = ORDERS.REP
	 where AMOUNT > 15000
order by AMOUNT

--или----
select REP_OFFICE [Офис], AMOUNT [Стоимость]
from ORDERS inner join SALESREPS
     on ORDERS.REP = SALESREPS.EMPL_NUM
	 where AMOUNT > 15000
order by AMOUNT


--3
--Найти среднюю цену заказа для каждого производителя.
select MFR [Производитель], avg(AMOUNT) [Средняя цена заказа]
 from ORDERS
 group by MFR


 --4
 --Найти производителей, у которых нет заказов.
select MFR, CUST
from PRODUCTS left outer join ORDERS
on PRODUCTS.PRODUCT_ID = ORDERS.PRODUCT
where CUST is null
group by MFR, CUST--5--Найти производителей товаров, которые заказывали сотрудники из офисов Западного региона.select MFR [Производитель], PRODUCT [Товар], NAME [Сотрудник], REGION [Регион]  from ORDERS inner join SALESREPS on ORDERS.REP = SALESREPS.EMPL_NUM            inner join OFFICES on SALESREPS.REP_OFFICE = OFFICES.OFFICEwhere REGION like ('west%')group by MFR, PRODUCT, NAME, REGION--7--Подсчитать среднее число товаров в заказе для каждого сотрудника и отсортировать по по этому значению по убыванию.select EMPL_NUM [Код сотрудника], NAME [Имя сотрудника], avg(QTY) [Среднее число товаров]from SALESREPS inner join ORDERSon SALESREPS.EMPL_NUM = ORDERS.REPgroup by EMPL_NUM, NAMEorder by avg(QTY)--8--Подсчитать среднюю цену товара для каждого сотрудника и отсортировать по среднему значению цены заказа.select REP [Сотрудник], avg(AMOUNT) [Средняя цена]from ORDERSgroup by REPorder by avg(AMOUNT)--9--Найти сотрудников, у которых есть заказ стоимостью выше 2000, и отсортировать по убыванию стоимости заказа.select REP [Код], NAME [Имя сотрудника], AMOUNT [Стоимость]from ORDERS inner join SALESREPS     on ORDERS.REP = SALESREPS.EMPL_NUM	 where AMOUNT > 2000order by AMOUNT desc--10--Найти среднюю цену заказа для каждого сотрудника.select REP [Код], NAME [Имя сотрудника], avg(AMOUNT) [Стоимость]from ORDERS inner join SALESREPS     on ORDERS.REP = SALESREPS.EMPL_NUMgroup by REP,NAME	 --------------------------- LEVEL 1 --------------------------
------------------------ TASK 1 ------------------------
--Подсчитать количество заказов, среднюю цену заказа для каждого покупателя и отсортировать по среднему значению цены заказа.
use EXAM;
select COUNT(ORDER_NUM) [Количество заказов], AVG(AMOUNT)
[Средняя цена заказов:]
from ORDERS
SELECT CUST [Покупатель],
 COUNT(ORDER_NUM) [Количество заказов],
 AVG(AMOUNT) [Средняя цена заказов:]
from ORDERS
group by CUST
ORDER BY AVG(AMOUNT)
------------------------ TASK 2 ------------------------
--Найти сотрудников, у которых есть заказ стоимостью выше 15000, и отсортировать по стоимости заказа.
use EXAM;
select REP [Сотрудник], NAME [Имя сотрудника], AMOUNT
[Количество]
from ORDERS join SALESREPS
on ORDERS.REP = SALESREPS.EMPL_NUM
where AMOUNT >= 15000
ORDER BY AMOUNT
------------------------ TASK 3 ------------------------
--Найти количество и среднюю цену продуктов для каждого производителя.
use EXAM;
select MFR_ID [Производитель], SUM(QTY_ON_HAND) [Количество
товаров], AVG(PRICE) [Средняя цена]
from PRODUCTS
group by MFR_ID
------------------------ TASK 4 ------------------------
--Найти покупателей, у которых нет заказов.
use EXAM;
select COMPANY, CUST
from CUSTOMERS left outer join ORDERS
on CUSTOMERS.CUST_NUM = ORDERS.CUST
where CUST is null
group by COMPANY, CUST
------------------------ TASK 5 ------------------------
--Найти заказы, которые оформляли менеджеры из региона EAST.
use EXAM;
select ORDER_NUM [Номер заказа], NAME [Имя менеджера,
оформившего заказ], REGION [Регион менеджера]
from ORDERS inner join SALESREPS
on ORDERS.REP = SALESREPS.EMPL_NUM
inner join OFFICES
on SALESREPS.REP_OFFICE = OFFICES.OFFICE
where REGION like ('east%')
group by ORDER_NUM, NAME, REGION
--------------------------- LEVEL 2 --------------------------
------------------------ TASK 1 ------------------------
--1.	Создать процедуру, которая выполняет добавление строки в таблицу OFFICES. Предусмотреть выдачу сообщений при ошибках.
use EXAM;
drop procedure Task1
go
create procedure Task1 @o int,
 @c varchar(15),
 @r varchar(10),
 @m int,
 @t decimal(9,2),
 @s decimal(9,2)
as declare @rs int = 1
begin
begin try
insert into OFFICES(OFFICE, CITY, REGION, MGR,
TARGET, SALES)
values (@o, @c, @r, @m, @t,
@s);
return @rs;
end try
begin catch
if ERROR_PROCEDURE() is not null
print error_message();
print ('Ошибка! Строка не вставилась.');
return -1;
end catch
end
go
declare @rss int
exec @rss = Task1 @o = '24', @c = 'Gomel', @r = 'Eastern', @m
= 106, @t = 64531, @s=123456
print cast(@rss as varchar(3));
select * from OFFICES;
------------------------ TASK 2 ------------------------
--2.	Создать функцию, которая возвращает количество заказов по наименованию покупателя. Если такого покупателя нет, возвращается -1
use EXAM;
go
create function Task2 (@number varchar(35)) returns int
as
begin declare @result int = 1
set @result = (select COUNT(*)
from ORDERS
where CUST = @number)
if @result = 0
set @result = -1
return @result
end
go
select CUST, dbo.Task2(CUST) from ORDERS
declare @res int = dbo.Task2(2114);
print ('Количество заказов = ') + cast(@res as varchar(3));
------------------------ TASK 3 ------------------------
--3.	Создать функцию, которая возвращает количество сотрудников, у которых есть заказ стоимостью выше N. N – числовой параметр.
use EXAM;
go
create function Task3(@cost decimal(9,2)) returns int
as
begin
declare @result int = 1
set @result = (select count(*)
from SALESREPS inner join
ORDERS
on EMPL_NUM = REP
where AMOUNT > @cost);
return @result;
end
go
declare @res int = dbo.Task3(31000);
print ('Количество сотрудников, у которых есть заказ
стоимостью выше указанного параметра:') + cast(@res as
varchar);
------------------------ TASK 4 ------------------------
--4.	Создать процедуру, которая принимает код производителя в качестве параметра и возвращает количество продуктов для этого производителя. Если такого кода нет, то возвращается -1.
use EXAM;
drop procedure Task4;
go
create procedure Task4 @code varchar(5)
as declare @result int = 1
begin
set @result = (select COUNT(*) from PRODUCTS where
MFR_ID = @code)
if @result = 0
set @result = -1
print @result
return @result
end
go
declare @res int
exec @res = Task4 @code = 2435;
------------------------ TASK 5 ------------------------
--5.	Создать процедуру, которая находит заказы по трем параметрам: наименование покупателя, период выполнения заказа (например, с 01.02.2007 по 01.02.2008). К точке вызова возвращается количество заказов. Если такого покупателя нет, то возвращается -1.
use EXAM;
drop procedure Task5
go
create procedure Task5 @name varchar(35), @period1 date,
@period2 date
as declare @result int = 1
begin
set @result = (
select count(*)
from ORDERS inner join
CUSTOMERS
on ORDERS.CUST =
CUSTOMERS.CUST_NUM
where ORDER_DATE between
@period1 and @period2
AND
COMPANY like (@name)
 )
select COMPANY, ORDER_DATE
from ORDERS inner join CUSTOMERS
on ORDERS.CUST = CUSTOMERS.CUST_NUM
where ORDER_DATE between @period1 and @period2
AND
COMPANY like (@name)
if @result = 0
set @result = -1
print @result
return @result
end
go
declare @res int
exec @res = Task5 @name = 'Jones Mfg.', @period1 =
'01.02.2007', @period2 = '01.02.2008';