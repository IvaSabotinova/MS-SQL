--T16 Create SoftUni Database

CREATE DATABASE SoftUni
USE SoftUni

CREATE TABLE Towns
(
Id INT PRIMARY KEY IDENTITY NOT NULL,
[Name] VARCHAR(30) NOT NULL
)

CREATE TABLE Departments
(
Id INT PRIMARY KEY IDENTITY NOT NULL,
[Name] VARCHAR (30) NOT NULL
)

CREATE TABLE Employees
(
Id INT PRIMARY KEY NOT NULL,
FirstName VARCHAR (30),
MiddleName VARCHAR (30),
LastName VARCHAR (30),
JobTitle VARCHAR (30),
DepartmentId INT FOREIGN KEY REFERENCES Departments (Id),
HireDate DATE,
Salary DECIMAL (10,2),
AddressId INT FOREIGN KEY REFERENCES Towns (Id)
)

--T18 Basic Insert

INSERT INTO Towns VALUES
('Sofia'),
('Plovdiv'),
('Varna'),
('Burgas')

INSERT INTO Departments VALUES
('Engineering'),
('Sales'),
('Marketing'),
('Software Development'),
('Quality Assurance')

INSERT INTO Employees VALUES
(1,'Ivan', 'Ivanov', 'Ivanov', '.NET Developer', 4, '02/01/2013', 3500.00, 1),
(2,'Petar', 'Petrov', 'Petrov', 'Senior Engineer', 1, '03/02/2004', 4000.00, 2),
(3,'Maria', 'Petrova', 'Ivanova', 'Intern', 5, '08/28/2016', 525.25, 3),
(4,'Georgi', 'Teziev', 'Ivanov', 'CEO', 2, '12/09/2007', 3000.00, 4),
(5,'Peter', 'Pan', 'Pan', 'Intern', 3, '08/28/2016', 599.88, 3)

--T19  Select All Fields

SELECT * FROM Towns
SELECT * FROM Departments
SELECT * FROM Employees

--T20 Basic Select All Fields and Order Them

SELECT * FROM Towns
ORDER BY [Name] ASC

SELECT * FROM Departments
ORDER BY [Name] ASC

SELECT * FROM Employees
ORDER BY Salary DESC

--T21 Basic Select Some Fields

SELECT [Name] FROM Towns 
ORDER BY [Name]ASC

SELECT [Name] FROM Departments 
ORDER BY [Name]ASC

SELECT FirstName, LastName, JobTitle, Salary FROM Employees 
ORDER BY Salary DESC

--T22 Increase Employees Salary

UPDATE Employees
SET Salary *=1.1
SELECT Salary FROM Employees

--T23 Decrease Tax Rate

 USE Hotel

 UPDATE Payments
 SET TaxRate *=0.97
 SELECT TaxRate FROM Payments

 --T24 Delete All Records

 USE Hotel
 DELETE FROM Occupancies








