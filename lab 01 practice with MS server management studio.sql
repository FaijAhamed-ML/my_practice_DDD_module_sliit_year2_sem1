create table emp
(
	eid integer primary key,
	ename varchar(25),
	age int,
	salary float
)

insert into emp values(1000,'Lakmal',33,90000)
insert into emp values(1001,'Nadeeka',24,28000)
insert into emp values(1002,'Amila',26,35000)
insert into emp values(1003,'Nishani',28,60000)
insert into emp values(1004,'Krishan',36,95000)
insert into emp values(1005,'Surangi',37,22000)
insert into emp values(1006,'Shanika',24,18000)
insert into emp values(1007,'Amali',21,20000)
insert into emp values(1008,'Charith',28,35000)
insert into emp values(1009,'Prasad',40,95000)

create table dept
(
did char(12) primary key,
budget float,
managerId int foreign key references emp
)

insert into dept values('Academic',900000,1002)
insert into dept values('Admin',120000,1000)
insert into dept values('Finance',3000000,1008)
insert into dept values('ITSD',4500000,1000)
insert into dept values('Maintenance',40000,1004)
insert into dept values('SESD',20000,1004)
insert into dept values('Marketing',90000,1008)

create table works
(
eid int foreign key references emp,
did Char(12) foreign key references dept,
pct_time int,
primary key(eid,did)
)

insert into works values(1000,'Admin',40)
insert into works values(1000,'ITSD',50)
insert into works values(1001,'Admin',100)
insert into works values(1002,'Academic',100)
insert into works values(1003,'Admin',20)
insert into works values(1003,'Academic',30)
insert into works values(1003,'ITSD',45)
insert into works values(1004,'Admin',60)
insert into works values(1004,'Finance',30)
insert into works values(1006,'Finance',45)
insert into works values(1006,'Maintenance',52)
insert into works values(1008,'Maintenance',30)
insert into works values(1008,'ITSD',30)
insert into works values(1008,'Finance',35)
insert into works values(1009,'Admin',100)

--a
SELECT * FROM emp;
--b
SELECT ename, salary FROM emp WHERE salary > 50000;
--c
SELECT * FROM emp WHERE ename LIKE 'A%';
--d
SELECT ename, age FROM emp WHERE age < 30;
--e
SELECT * FROM emp WHERE salary BETWEEN 20000 AND 60000;
--f
SELECT ename FROM emp WHERE ename LIKE '%a%';
--g
SELECT eid, ename FROM emp WHERE age IN (24, 28);
--h
SELECT * FROM emp WHERE age NOT BETWEEN 25 AND 35;
--i
SELECT * FROM emp WHERE salary IS NOT NULL;

--j
SELECT * FROM emp ORDER BY ename;
--a
SELECT * FROM emp ORDER BY salary DESC;
--b
SELECT * FROM emp ORDER BY age ASC, salary DESC;
--c
SELECT * FROM dept ORDER BY budget DESC;
--d
SELECT * FROM works ORDER BY pct_time;


--a
SELECT COUNT(eid) FROM emp;
--b
SELECT SUM(salary) FROM emp;
--c
SELECT MAX(salary) AS HighestSalary, MIN(salary) AS LowestSalary FROM emp;
--d
SELECT AVG(salary) FROM emp;
--e
SELECT COUNT(eid) FROM emp WHERE age < 30;
--f
SELECT COUNT(did) FROM dept;
--g
SELECT MAX(budget) AS MaxBudget, MIN(budget) AS MinBudget FROM dept;
--h
SELECT SUM(pct_time) FROM works;
--i
SELECT eid, AVG(pct_time) AS AvgWorkTime FROM works GROUP BY eid;


--a
SELECT age, SUM(salary) AS TotalSalary FROM emp GROUP BY age;
--b
SELECT did, COUNT(eid) AS [Number of Employees] FROM works GROUP BY did;
--c
SELECT COUNT(eid) FROM emp WHERE salary > 50000;
--d
SELECT * FROM emp WHERE salary > 50000 ORDER BY salary ASC;

--a
SELECT did FROM works GROUP BY did HAVING COUNT(eid) < 3;
--b
SELECT managerId, COUNT(did) AS NumOfDepartments FROM dept GROUP BY managerId HAVING COUNT(did) > 1 ORDER BY NumOfDepartments ASC;
--c
SELECT age, AVG(salary) AS AvgSalary FROM emp GROUP BY age HAVING AVG(salary) > 40000;
--d
SELECT eid, COUNT(did) AS NumOfAssignments FROM works GROUP BY eid HAVING COUNT(did) > 2;
--e
SELECT did FROM dept WHERE budget > 1000000;