use k_MyBase2

CREATE table ��������2
(
	�����_�������������� int primary key,
	������� nchar(30) NOT NULL,
	��� nchar(30) NOT NULL,
	�������� nchar(30) NOT NULL,
	����� nchar(30) NOT NULL,
	������� nchar(20) NOT NULL,
)
CREATE table ������������2
(
	��������_������������ nchar(50) primary key,
	�����_������ int NOT NULL,
	�����_������������ int,
	�����_������������ int,
)
CREATE table ������2 
(
	�����_������_�_������� int primary key,
	��������_������������ nchar(50) foreign key references ������������2(��������_������������),
	�����_�������������� int foreign key references ��������2(�����_��������������),
	������� int NOT NULL,
)

ALTER Table ������2 ADD ����_����� date;

ALTER Table ������2 DROP Column ����_�����;

INSERT into ��������2(�����_��������������, �������, ���, ��������, �����, �������)
	Values (1002121, '��������', '������', '������������', '�.�����', +375294568799),
		   (1012324, '���������', '�����', '��������', '�.������', +375447898821),
		   (1022365, '����������', '����', '��������', '�.�����', +375336455585),
		   (1034332, '�����', '�������', '����������', '�.����������', +375256599637);

INSERT into ������������2(��������_������������, �����_������, �����_������������, �����_������������)
	Values ('������', 36, 20, 17),
		   ('����������', 24, 20, 0),
		   ('������������� ������', 36, 10, 0);

INSERT into ������2(�����_������_�_�������, ��������_������������, �����_��������������, �������)
	Values (1, '������', 1002121, 7),
		   (2, '������������� ������', 1022365, 9),
		   (3, '����������', 1034332, 8),
		   (4, '������', 1034332, 8),
		   (5, '������', 1002121, 5),
		   (6, '����������', 1002121, 5),
		   (7, '����������', 1022365, 10);


SELECT * From ��������2;


SELECT ��������_������������, �����_������ From ������������2;


SELECT count(*) [���������� �����] From ������2;


SELECT �����_�������������� ������� FROM ������2
	   Where ������� > 8


SELECT Distinct Top(3) �������, ��� 
	   FROM ��������2;


UPDATE ��������2 set ����� = '�.�����';
SELECT �������, ����� From ��������2;


UPDATE ������2  set ������� = ������� - 2 Where ��������_������������ = '����������';
SELECT ��������_������������, ������� From ������2;


DELETE from ��������2 where ������� = '�����';
SELECT * from ��������2;


SELECT Distinct ��������_������������, �����_�������������� 
		From ������2 Where ������� 
				Between '4' And '6'


SELECT ������� From ��������2
	Where ������� Like '�%';



SELECT Distinct ��������_������������, ������� From ������2
	Where ������� In (6,8);

