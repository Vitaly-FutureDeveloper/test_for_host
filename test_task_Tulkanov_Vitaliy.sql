create schema test;
USE test;

-- люди
create table test.tPerson (
	pid	int, -- идентификатор человека
	name nvarchar(100),
	oid	int, -- ссылка на организацию, в которой трудоустроен данный человек
	primary key(pid)
);

-- организации (и подразделения)
create table test.tOrg (
	oid	int, -- идентификатор организации
	name nvarchar(100), 
	poid int DEFAULT 0, -- ссылка на oid родительской организации. Для «корневых» - NULL
	primary key(oid)
	);

-- счета
create table test.tAccount (
	aid int, -- идентификатор счета
	pid	int, -- ссылка на Person которому принадлежит счет
	accNumber nvarchar(20), -- номер счета
	primary key(aid)
);

-- остатки по счетам на дату
-- для каждого идентификатора счета aid в таблице хранится набор записей с разными датами stDate
-- каждый раз как по счету происходит движение денег, в tAccountRest на соответствующую
-- дату вставляется запись т.е. по каждому из счетов записи есть не на каждый день, 
-- а только на те даты когда состояние счетов менялось.
create table test.tAccountRest (
	aid int, -- идентификатор счета
	stDate	datetime, -- дата  остатка
	balance float, -- остаток на счете на эту дату
	primary key(aid, stDate)
);


insert into test.tOrg (oid, name) values (1,'IBM');
insert into test.tOrg (oid, name) values (2,'M$');
insert into test.tOrg (oid, name) values (3,'Oracle');
insert into test.tOrg (oid, name) values (4,'Google');
insert into test.tOrg (oid, name) values (5,'Lukoil');
insert into test.tOrg (oid, name, poid) values (6,'OOO VolgogradNP',5);
insert into test.tOrg (oid, name, poid) values (7,'OOO Perm NP',5);
insert into test.tOrg (oid, name, poid) values (8,'IT',7);
insert into test.tOrg (oid, name, poid) values (9,'Accounting',7);
insert into test.tOrg (oid, name, poid) values (10,'Sales',7);
insert into test.tOrg (oid, name, poid) values (11,'ITD',6);
insert into test.tOrg (oid, name, poid) values (12,'AccountingD',6);
insert into test.tOrg (oid, name, poid) values (13,'SalesD',6);



insert into test.tPerson (pid, name, oid) values (1, 'Ivan Ivanov', 1);


DROP PROCEDURE IF EXISTS sp_create_write;

DELIMITER //

CREATE PROCEDURE sp_create_write(
    IN var_name nvarchar(100),
    IN var_oid	int) 
BEGIN
  DECLARE count_pid INT DEFAULT 1; 
  select MAX(pid)+1 INTO count_pid from test.tPerson;
  insert into test.tPerson (pid, name, oid) VALUES (count_pid, var_name, var_oid);
END //

DELIMITER ;

-- Прописываем процедуры добавления по максимальному pid

CALL sp_create_write('Ivan Petrov', 1);
CALL sp_create_write('Petr Kalinin', 2);
CALL sp_create_write('Denis Uljano', 2);
CALL sp_create_write('Larisa Tretyakova', 9);
CALL sp_create_write('Tatjana Rybina', 8);
CALL sp_create_write('Semen Tsarkin', null);
CALL sp_create_write('Kirill Ustinov', null);

-- insert into test.tPerson (pid, name, oid) values (1, 'Ivan Ivanov', 1);
-- insert into test.tPerson (pid, name, oid) values ((select MAX(pid)+1 from test.tPerson), 'Ivan Petrov', 1);
-- insert into test.tPerson (pid, name, oid) values ((select MAX(pid)+1 from test.tPerson), 'Petr Kalinin', 2);
-- insert into test.tPerson (pid, name, oid) values ((select MAX(pid)+1 from test.tPerson), 'Denis Uljanov', 2);
-- insert into test.tPerson (pid, name, oid) values ((select MAX(pid)+1 from test.tPerson), 'Larisa Tretyakova', 9);
-- insert into test.tPerson (pid, name, oid) values ((select MAX(pid)+1 from test.tPerson), 'Tatjana Rybina', 8);
-- insert into test.tPerson (pid, name, oid) values ((select MAX(pid)+1 from test.tPerson), 'Semen Tsarkin', null);
-- insert into test.tPerson (pid, name, oid) values ((select MAX(pid)+1 from test.tPerson), 'Kirill Ustinov', null);

insert into test.tAccount (aid,pid,accNumber) values (1,1,'40807810000000000001');
insert into test.tAccount (aid,pid,accNumber) values (2,2,'40807810000000000002');
insert into test.tAccount (aid,pid,accNumber) values (3,3,'40807810000000000003');
insert into test.tAccount (aid,pid,accNumber) values (4,4,'40807810000000000004');
insert into test.tAccount (aid,pid,accNumber) values (5,5,'40807810000000000005');
insert into test.tAccount (aid,pid,accNumber) values (6,4,'40807810000000020004');
insert into test.tAccount (aid,pid,accNumber) values (7,4,'40807810000120020004');


-- 1. написать запрос, который выводит список всех людей с названиями их 
-- организаций или с NULL вместо названия организации если для человека не 
-- указана организация.
SELECT tPerson.name, tOrg.name AS tOrg
  FROM tPerson LEFT OUTER JOIN tOrg  
    ON tPerson.oid = tOrg.oid;

-- 2. Написать запрос, 
-- выводящий список всех  организаций, в которых никто не работает.
SELECT tOrg.name, tOrg.poid
  FROM tOrg
    WHERE tOrg.poid < 1


-- 3.	Написать запрос выводящий список названий всех организаций 
-- с количеством трудоустроенных в них людей: 
-- 3.1. Вар1 – только организации, в которых кто-то есть т.е. 
SELECT tOrg.name, tOrg.poid
  FROM tOrg
    WHERE poid > 0;

-- 3.2. Вар2 – полный список 
SELECT tOrg.name, tOrg.poid
  FROM tOrg;


-- 4. Таблица test.tOrg задает иерархическую структуру организаций т.е. 
-- poid – ссылка на родительский oid. Задача написать функцию, 
-- которая по переданному oid вернет строку, содержащую «путь» 
-- от  корня до переданного oid, например getFullOrgName(9) 
-- вернет /Lukoil/OOO Perm NP/Accounting

-- DROP FUNCTION IF EXISTS getFullOrgName;

-- DELIMITER //
-- CREATE FUNCTION getFullOrgName(id int) 
-- RETURNS nvarchar(80)
-- DETERMINISTIC
-- BEGIN
-- 	DECLARE str_total nvarchar(80) DEFAULT "/"; 
-- 	DECLARE str_name nvarchar(80) DEFAULT "/"; 
-- 	DECLARE str_num nvarchar(80) DEFAULT "/"; 
   
-- 	SELECT poid INTO str_num FROM test.tOrg WHERE oid = id;
-- 	SELECT name INTO str_name FROM test.tOrg WHERE oid = str_num;
--     WHILE str_num > 0
-- 	BEGIN
-- 		SELECT poid INTO str_num FROM test.tOrg WHERE oid = id;
-- 		SELECT name INTO str_name FROM test.tOrg WHERE oid = str_num;
-- 		SET str_total = CONCAT(str_total, str_name);
-- 	END;
--     RETURN str_total;
-- END //
-- DELIMITER ;

-- SELECT getFullOrgName(9);