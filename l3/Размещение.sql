use master
go 
create database k_MyBase3
on primary
(name = N'k_MyBase3_mdf', filename = N'D:\2 курс\БД Блинова\l3\k_MyBase_mdf.mdf',
 size = 10240Kb, maxsize = UNLiMITED, filegrowth = 1024Kb),
(name = N'k_MyBase3_log', filename = N'D:\2 курс\БД Блинова\l3\k_MyBase_ndf.ndf',
 size = 10240Kb, maxsize = 2048Gb, filegrowth = 25%),

filegroup FG1
(name = N'k_MyBase3_fg1_1', filename = N'D:\2 курс\БД Блинова\l3\k_MyBase_fgq-1.ndf',
 size = 10240Kb, maxsize = 1Gb, filegrowth = 25%),
(name = N'k_MyBase3_fg1_2', filename = N'D:\2 курс\БД Блинова\l3\k_MyBase_fgq-2.ndf',
 size = 10240Kb, maxsize = 1Gb, filegrowth = 25%)

log on
(name = N'k_MyBase3_log', filename = N'D:\2 курс\БД Блинова\l3\k_MyBase_log.ldf',
 size = 10240Kb, maxsize = 1Gb, filegrowth = 10%)


