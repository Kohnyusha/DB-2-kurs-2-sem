use Univer;

--1-----------------------------------------
--��� ������������� ������ PATH ������ ������� ��������������� ���������� � ������� ���������� ����� �������
go
select * from TEACHER where TEACHER.PULPIT = '����'
for xml path('TEACHER'), root('TEACHER_LIST');


--2-----------------------------------------

go
select AUDITORIUM.AUDITORIUM, AUDITORIUM_TYPE.AUDITORIUM_TYPE, AUDITORIUM.AUDITORIUM_CAPACITY
from AUDITORIUM inner join AUDITORIUM_TYPE
	on AUDITORIUM.AUDITORIUM_TYPE = AUDITORIUM_TYPE.AUDITORIUM_TYPE
	where AUDITORIUM.AUDITORIUM_TYPE like '%��%'
for xml AUTO, root('LECTURE_AUDITORIUMS');


--3-----------------------------------------
--����������� XML-��������, ���������� ������ � ���� ����� ������� �����������, ������� ������� �������� � ������� SUBJECT. 
--����������� ��������, ����������� ������ � ����������� �� XML-��������� � ����������� �� � ������� SUBJECT. 

go
declare @h int = 0, @text varchar(1000) =
	'<?xml version="1.0" encoding="windows-1251"?>
	<��������>
		<������������� Id="�����1" Full="�����1" Pulpit="����"/>
		<������������� Id="�����2" Full="�����2" Pulpit="����"/>
		<������������� Id="�����3" Full="�����3" Pulpit="����"/>
	</��������>';
exec sp_xml_preparedocument @h output, @text; --�������������� ���
select * from openxml(@h, '/��������/�������������',0)--����������, ����� � ����� ���� ����� ������ �������
	with([Id] nvarchar(10), [Full] nvarchar(70), [Pulpit] nvarchar(10))--��������������������� �����������


insert SUBJECT select [Id], [Full], [Pulpit]
	from openxml(@h, '/��������/�������������',0)
		with([Id] nvarchar(10), [Full] nvarchar(70), [Pulpit] nvarchar(10))

select * from SUBJECT
delete SUBJECT where SUBJECT in('�����1', '�����2', '�����3')

exec sp_xml_removedocument @h;--�������� ���������
go


--4-----------------------------------------
go
delete STUDENT where NAME = '������ ���������� ���������';
select * from STUDENT where NAME = '�';

insert STUDENT(IDGROUP, NAME, BDAY, INFO) values
	(5, '������ ���������� ���������', '2002-06-01',
		'<�������>
		<������� series="MP" id="7327482" date="14.02.2017" />
		<�������>5634337</�������>
			<�����>
				<������>��������</������>
				<�����>�����</�����>
				<�����>���������</�����>
				<���>13</���>
				<��������>204</��������>
			</�����>
		</�������>');					 												    

update STUDENT set INFO = 
	'<�������>
	<������� series="MP" id="7327482" date="01.09.2017" />
	<�������>5634337</�������>
		<�����>
			<������>��������</������>
			<�����>�����</�����>
			<�����>���������</�����>
			<���>223</���>
			<��������>204</��������>
		</�����>
	</�������>'
where STUDENT.INFO.value('(/�������/�����/���)[1]','int') = 13;

select NAME, 
	INFO.value('(/�������/�������/@series)[1]', 'char(2)') '������� series',--���������� �������
	INFO.value('(/�������/�������/@id)[1]', 'varchar(10)') '������� id',
	INFO.query('/�������/�����') '�����' --������� ���� ��������
from  STUDENT where NAME =  '������ ���������� ���������';
go


--5---------------------------------
--�������� (ALTER TABLE) ������� STUDENT � ���� ������ UNIVER ����� �������, 4
--����� �������� ��������������� ������� � ������ INFO ���������������� ���������� XML-���� (XML SCHEMACOLLECTION),
drop xml schema collection Student
go
create xml schema collection Student as 
'<?xml version="1.0" encoding="windows-1251" ?>
<xs:schema attributeFormDefault="unqualified" elementFormDefault="qualified" xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<xs:element name="�������">  
		<xs:complexType>
			<xs:sequence>
				<xs:element name="�������" maxOccurs="1" minOccurs="1">
					<xs:complexType>
						<xs:attribute name="series" type="xs:string" use="required" />
						<xs:attribute name="id" type="xs:unsignedInt" use="required"/>
						<xs:attribute name="date"  use="required" >  
							<xs:simpleType> 
								<xs:restriction base ="xs:string">
									<xs:pattern value="[0-9]{2}.[0-9]{2}.[0-9]{4}"/>
								</xs:restriction>
							</xs:simpleType>
						</xs:attribute>
					</xs:complexType> 
				</xs:element>
				<xs:element maxOccurs="3" name="�������" type="xs:unsignedInt"/>
				<xs:element name="�����">
					<xs:complexType>
						<xs:sequence>
							<xs:element name="������" type="xs:string" />
							<xs:element name="�����" type="xs:string" />
							<xs:element name="�����" type="xs:string" />
							<xs:element name="���" type="xs:string" />
							<xs:element name="��������" type="xs:string" />
						</xs:sequence>
					</xs:complexType>
				</xs:element>
			</xs:sequence>
		</xs:complexType>
	</xs:element>
</xs:schema>';

alter table STUDENT alter column INFO xml(Student);

insert STUDENT(IDGROUP, NAME, BDAY, INFO) values
	(18,'������','01.01.2000',
		'<�������>
			<������� series="PM" id="6799765" date="25.10.2011"/>
			<�������>0000000</�������>
			<�����>
				<������>��������</������>
				<�����>�����</�����>
				<�����>�����</�����>
				<���>19</���>
				<��������>416</��������>
			</�����>
		</�������>');

insert STUDENT(IDGROUP, NAME, BDAY, INFO) values
	(18,'������','01.01.2000',
		'<�������>
			<������� series="�B" id="6799765" date="25.10.2011"/>
			<�������>2434353</�������>
			<�����>
				<������>��������</������>
				<�����>�����</�����>
				<�����>����������</�����>
				<���>19</���>
				<��������>416</��������>
			</�����>
		</�������>');

delete STUDENT where NAME = '������'
delete STUDENT where NAME = '������'
select * from STUDENT
