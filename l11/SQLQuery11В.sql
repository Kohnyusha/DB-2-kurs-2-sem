use Univer;

--4-----------------------------------
begin transaction
select @@SPID
insert SUBJECT values ('NewSubject', 'NS', 'ศั่า');
update PROGRESS set SUBJECT = 'NewSubject'
       where PROGRESS.SUBJECT = 'ัำมฤ'
-------------------------- t1
-------------------------- t2
rollback;

--5-----------------------------------
--- B ---
set transaction isolation level READ COMMITTED
begin transaction
-------------------------- t1
update SUBJECT set SUBJECT.PULPIT = 'ศั่า'
   where SUBJECT.PULPIT = 'ศั่า'
   commit;
-------------------------- t2


--6-----------------------------------
--- B ---
begin transaction
-------------------------- t1 --------------------
insert SUBJECT values ('ýsdf', 'hsbs', 'ศั่า');
commit;



--7-----------------------------------
--- B ---
set transaction isolation level READ COMMITTED
begin transaction
     delete SUBJECT where SUBJECT.SUBJECT = 'มฤ';
     insert SUBJECT values ('OOO', 'ooo', 'ศั่า');
     update SUBJECT set SUBJECT.SUBJECT = 'มฤ' 
         where SUBJECT.PULPIT = 'ศั่า';
	 select * from SUBJECT where PULPIT = 'ศั่า';
-------------------------- t1 --------------------
commit;
select * from SUBJECT where PULPIT = 'ศั่า';
-------------------------- t2 --------------------
