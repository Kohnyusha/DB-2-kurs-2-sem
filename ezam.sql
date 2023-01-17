use EXAM;

--1
--���������� ������� ���� ������ ��� ������� ���������� � ������������� �� �������� �������� ���� ������.
select CUST [����������], avg(AMOUNT) [������� ����]
from ORDERS
group by CUST
order by avg(AMOUNT)


--2
--����� �����, � ������� ���� ����� ���������� ���� 15000, � ������������� �� ��������� ������.
select OFFICE [����], AMOUNT [���������]
from OFFICES inner join SALESREPS
     on OFFICES.OFFICE = SALESREPS.REP_OFFICE
	 inner join ORDERS
	 on SALESREPS.EMPL_NUM = ORDERS.REP
	 where AMOUNT > 15000
order by AMOUNT

--���----
select REP_OFFICE [����], AMOUNT [���������]
from ORDERS inner join SALESREPS
     on ORDERS.REP = SALESREPS.EMPL_NUM
	 where AMOUNT > 15000
order by AMOUNT


--3
--����� ������� ���� ������ ��� ������� �������������.
select MFR [�������������], avg(AMOUNT) [������� ���� ������]
 from ORDERS
 group by MFR


 --4
 --����� ��������������, � ������� ��� �������.
select MFR, CUST
from PRODUCTS left outer join ORDERS
on PRODUCTS.PRODUCT_ID = ORDERS.PRODUCT
where CUST is null
group by MFR, CUST--5--����� �������������� �������, ������� ���������� ���������� �� ������ ��������� �������.select MFR [�������������], PRODUCT [�����], NAME [���������], REGION [������]  from ORDERS inner join SALESREPS on ORDERS.REP = SALESREPS.EMPL_NUM            inner join OFFICES on SALESREPS.REP_OFFICE = OFFICES.OFFICEwhere REGION like ('west%')group by MFR, PRODUCT, NAME, REGION--7--���������� ������� ����� ������� � ������ ��� ������� ���������� � ������������� �� �� ����� �������� �� ��������.select EMPL_NUM [��� ����������], NAME [��� ����������], avg(QTY) [������� ����� �������]from SALESREPS inner join ORDERSon SALESREPS.EMPL_NUM = ORDERS.REPgroup by EMPL_NUM, NAMEorder by avg(QTY)--8--���������� ������� ���� ������ ��� ������� ���������� � ������������� �� �������� �������� ���� ������.select REP [���������], avg(AMOUNT) [������� ����]from ORDERSgroup by REPorder by avg(AMOUNT)--9--����� �����������, � ������� ���� ����� ���������� ���� 2000, � ������������� �� �������� ��������� ������.select REP [���], NAME [��� ����������], AMOUNT [���������]from ORDERS inner join SALESREPS     on ORDERS.REP = SALESREPS.EMPL_NUM	 where AMOUNT > 2000order by AMOUNT desc--10--����� ������� ���� ������ ��� ������� ����������.select REP [���], NAME [��� ����������], avg(AMOUNT) [���������]from ORDERS inner join SALESREPS     on ORDERS.REP = SALESREPS.EMPL_NUMgroup by REP,NAME	 --------------------------- LEVEL 1 --------------------------
------------------------ TASK 1 ------------------------
--���������� ���������� �������, ������� ���� ������ ��� ������� ���������� � ������������� �� �������� �������� ���� ������.
use EXAM;
select COUNT(ORDER_NUM) [���������� �������], AVG(AMOUNT)
[������� ���� �������:]
from ORDERS
SELECT CUST [����������],
 COUNT(ORDER_NUM) [���������� �������],
 AVG(AMOUNT) [������� ���� �������:]
from ORDERS
group by CUST
ORDER BY AVG(AMOUNT)
------------------------ TASK 2 ------------------------
--����� �����������, � ������� ���� ����� ���������� ���� 15000, � ������������� �� ��������� ������.
use EXAM;
select REP [���������], NAME [��� ����������], AMOUNT
[����������]
from ORDERS join SALESREPS
on ORDERS.REP = SALESREPS.EMPL_NUM
where AMOUNT >= 15000
ORDER BY AMOUNT
------------------------ TASK 3 ------------------------
--����� ���������� � ������� ���� ��������� ��� ������� �������������.
use EXAM;
select MFR_ID [�������������], SUM(QTY_ON_HAND) [����������
�������], AVG(PRICE) [������� ����]
from PRODUCTS
group by MFR_ID
------------------------ TASK 4 ------------------------
--����� �����������, � ������� ��� �������.
use EXAM;
select COMPANY, CUST
from CUSTOMERS left outer join ORDERS
on CUSTOMERS.CUST_NUM = ORDERS.CUST
where CUST is null
group by COMPANY, CUST
------------------------ TASK 5 ------------------------
--����� ������, ������� ��������� ��������� �� ������� EAST.
use EXAM;
select ORDER_NUM [����� ������], NAME [��� ���������,
����������� �����], REGION [������ ���������]
from ORDERS inner join SALESREPS
on ORDERS.REP = SALESREPS.EMPL_NUM
inner join OFFICES
on SALESREPS.REP_OFFICE = OFFICES.OFFICE
where REGION like ('east%')
group by ORDER_NUM, NAME, REGION
--------------------------- LEVEL 2 --------------------------
------------------------ TASK 1 ------------------------
--1.	������� ���������, ������� ��������� ���������� ������ � ������� OFFICES. ������������� ������ ��������� ��� �������.
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
print ('������! ������ �� ����������.');
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
--2.	������� �������, ������� ���������� ���������� ������� �� ������������ ����������. ���� ������ ���������� ���, ������������ -1
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
print ('���������� ������� = ') + cast(@res as varchar(3));
------------------------ TASK 3 ------------------------
--3.	������� �������, ������� ���������� ���������� �����������, � ������� ���� ����� ���������� ���� N. N � �������� ��������.
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
print ('���������� �����������, � ������� ���� �����
���������� ���� ���������� ���������:') + cast(@res as
varchar);
------------------------ TASK 4 ------------------------
--4.	������� ���������, ������� ��������� ��� ������������� � �������� ��������� � ���������� ���������� ��������� ��� ����� �������������. ���� ������ ���� ���, �� ������������ -1.
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
--5.	������� ���������, ������� ������� ������ �� ���� ����������: ������������ ����������, ������ ���������� ������ (��������, � 01.02.2007 �� 01.02.2008). � ����� ������ ������������ ���������� �������. ���� ������ ���������� ���, �� ������������ -1.
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