use Univer;

--1-----------------------------------------
--При использовании режима PATH каждый столбец конфигурируется независимо с помощью псевдонима этого столбца
go
select * from TEACHER where TEACHER.PULPIT = 'ИСиТ'
for xml path('TEACHER'), root('TEACHER_LIST');


--2-----------------------------------------

go
select AUDITORIUM.AUDITORIUM, AUDITORIUM_TYPE.AUDITORIUM_TYPE, AUDITORIUM.AUDITORIUM_CAPACITY
from AUDITORIUM inner join AUDITORIUM_TYPE
	on AUDITORIUM.AUDITORIUM_TYPE = AUDITORIUM_TYPE.AUDITORIUM_TYPE
	where AUDITORIUM.AUDITORIUM_TYPE like '%ЛК%'
for xml AUTO, root('LECTURE_AUDITORIUMS');


--3-----------------------------------------
--Разработать XML-документ, содержащий данные о трех новых учебных дисциплинах, которые следует добавить в таблицу SUBJECT. 
--Разработать сценарий, извлекающий данные о дисциплинах из XML-документа и добавляющий их в таблицу SUBJECT. 

go
declare @h int = 0, @text varchar(1000) =
	'<?xml version="1.0" encoding="windows-1251"?>
	<Предметы>
		<НовыеПредметы Id="Новый1" Full="Новый1" Pulpit="ИСиТ"/>
		<НовыеПредметы Id="Новый2" Full="Новый2" Pulpit="ИСиТ"/>
		<НовыеПредметы Id="Новый3" Full="Новый3" Pulpit="ИСиТ"/>
	</Предметы>';
exec sp_xml_preparedocument @h output, @text; --подготавливаем док
select * from openxml(@h, '/Предметы/НовыеПредметы',0)--дескриптор, выраж и число указ режим работы функции
	with([Id] nvarchar(10), [Full] nvarchar(70), [Pulpit] nvarchar(10))--структураформируемого резулльтата


insert SUBJECT select [Id], [Full], [Pulpit]
	from openxml(@h, '/Предметы/НовыеПредметы',0)
		with([Id] nvarchar(10), [Full] nvarchar(70), [Pulpit] nvarchar(10))

select * from SUBJECT
delete SUBJECT where SUBJECT in('Новый1', 'Новый2', 'Новый3')

exec sp_xml_removedocument @h;--удаление документа
go


--4-----------------------------------------
go
delete STUDENT where NAME = 'Кохнюк Александра Сергеевна';
select * from STUDENT where NAME = 'с';

insert STUDENT(IDGROUP, NAME, BDAY, INFO) values
	(5, 'Кохнюк Александра Сергеевна', '2002-06-01',
		'<студент>
		<паспорт series="MP" id="7327482" date="14.02.2017" />
		<телефон>5634337</телефон>
			<адрес>
				<страна>Беларусь</страна>
				<город>Минск</город>
				<улица>Свердлова</улица>
				<дом>13</дом>
				<квартира>204</квартира>
			</адрес>
		</студент>');					 												    

update STUDENT set INFO = 
	'<студент>
	<паспорт series="MP" id="7327482" date="01.09.2017" />
	<телефон>5634337</телефон>
		<адрес>
			<страна>Беларусь</страна>
			<город>Минск</город>
			<улица>Свердлова</улица>
			<дом>223</дом>
			<квартира>204</квартира>
		</адрес>
	</студент>'
where STUDENT.INFO.value('(/студент/адрес/дом)[1]','int') = 13;

select NAME, 
	INFO.value('(/студент/паспорт/@series)[1]', 'char(2)') 'паспорт series',--выполнение запроса
	INFO.value('(/студент/паспорт/@id)[1]', 'varchar(10)') 'паспорт id',
	INFO.query('/студент/адрес') 'адрес' --возвращ знач атрибута
from  STUDENT where NAME =  'Кохнюк Александра Сергеевна';
go


--5---------------------------------
--Изменить (ALTER TABLE) таблицу STUDENT в базе данных UNIVER таким образом, 4
--чтобы значения типизированного столбца с именем INFO контролировались коллекцией XML-схем (XML SCHEMACOLLECTION),
drop xml schema collection Student
go
create xml schema collection Student as 
'<?xml version="1.0" encoding="windows-1251" ?>
<xs:schema attributeFormDefault="unqualified" elementFormDefault="qualified" xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<xs:element name="студент">  
		<xs:complexType>
			<xs:sequence>
				<xs:element name="паспорт" maxOccurs="1" minOccurs="1">
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
				<xs:element maxOccurs="3" name="телефон" type="xs:unsignedInt"/>
				<xs:element name="адрес">
					<xs:complexType>
						<xs:sequence>
							<xs:element name="страна" type="xs:string" />
							<xs:element name="город" type="xs:string" />
							<xs:element name="улица" type="xs:string" />
							<xs:element name="дом" type="xs:string" />
							<xs:element name="квартира" type="xs:string" />
						</xs:sequence>
					</xs:complexType>
				</xs:element>
			</xs:sequence>
		</xs:complexType>
	</xs:element>
</xs:schema>';

alter table STUDENT alter column INFO xml(Student);

insert STUDENT(IDGROUP, NAME, BDAY, INFO) values
	(18,'Первый','01.01.2000',
		'<студент>
			<паспорт series="PM" id="6799765" date="25.10.2011"/>
			<телефон>0000000</телефон>
			<адрес>
				<страна>Беларусь</страна>
				<город>Минск</город>
				<улица>Улица</улица>
				<дом>19</дом>
				<квартира>416</квартира>
			</адрес>
		</студент>');

insert STUDENT(IDGROUP, NAME, BDAY, INFO) values
	(18,'Второй','01.01.2000',
		'<студент>
			<паспорт series="НB" id="6799765" date="25.10.2011"/>
			<телефон>2434353</телефон>
			<адрес>
				<страна>Беларусь</страна>
				<город>Минск</город>
				<улица>Улицаулица</улица>
				<дом>19</дом>
				<квартира>416</квартира>
			</адрес>
		</студент>');

delete STUDENT where NAME = 'Первый'
delete STUDENT where NAME = 'Второй'
select * from STUDENT
