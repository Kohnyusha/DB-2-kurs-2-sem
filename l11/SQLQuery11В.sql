use Univer;

--4-----------------------------------
begin transaction
select @@SPID
insert SUBJECT values ('NewSubject', 'NS', '����');
update PROGRESS set SUBJECT = 'NewSubject'
       where PROGRESS.SUBJECT = '����'
-------------------------- t1
-------------------------- t2
rollback;

--5-----------------------------------
--- B ---
set transaction isolation level READ COMMITTED
begin transaction
-------------------------- t1
update SUBJECT set SUBJECT.PULPIT = '����'
   where SUBJECT.PULPIT = '����'
   commit;
-------------------------- t2


--6-----------------------------------
--- B ---
begin transaction
-------------------------- t1 --------------------
insert SUBJECT values ('�sdf', 'hsbs', '����');
commit;



--7-----------------------------------
--- B ---
set transaction isolation level READ COMMITTED
begin transaction
     delete SUBJECT where SUBJECT.SUBJECT = '��';
     insert SUBJECT values ('OOO', 'ooo', '����');
     update SUBJECT set SUBJECT.SUBJECT = '��' 
         where SUBJECT.PULPIT = '����';
	 select * from SUBJECT where PULPIT = '����';
-------------------------- t1 --------------------
commit;
select * from SUBJECT where PULPIT = '����';
-------------------------- t2 --------------------
