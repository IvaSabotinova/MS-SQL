--T02 Find All Information About Departments

SELECT * FROM Departments

--T03 Find all Department Names

SELECT Name FROM Departments

--T04 Find Salary of Each Employee

SELECT FirstName, LastName, Salary FROM Employees

--T05 Find Full Name of Each Employee

SELECT FirstName, MiddleName, LastName  FROM Employees

--T06 Find Email Address of Each Employee

SELECT CONCAT (FirstName, '.', LastName, '@softuni.bg')  AS [Full Email Address] FROM Employees

--T07 Find All Different Employee’s Salaries

SELECT DISTINCT Salary FROM Employees

--T08 Find all Information About Employees

SELECT * FROM Employees
WHERE JobTitle = 'Sales Representative'

--T09 Find Names of All Employees by Salary in Range

SELECT FirstName, LastName, JobTitle FROM Employees
WHERE Salary BETWEEN 20000 AND 30000

--T10 Find Names of All Employees

SELECT FirstName +' '+ MiddleName+' '+LastName AS [Full Name] FROM Employees
	WHERE Salary IN (25000, 14000, 12500, 23600)

--T11 Find All Employees Without Manager

SELECT FirstName, LastName FROM Employees
WHERE ManagerID IS NULL

--T12 Find All Employees with Salary More Than 50000

SELECT FirstName, LastName, Salary FROM Employees
WHERE Salary > 50000
ORDER BY Salary Desc

--T13 Find 5 Best Paid Employees

SELECT TOP(5) FirstName, LastName FROM Employees
ORDER BY Salary DESC

--T14 Find All Employees Except Marketing

SELECT FirstName, LastName FROM Employees
WHERE DepartmentID !=4

--T15 Sort Employees Table

SELECT * FROM Employees
ORDER BY Salary DESC, FirstName ASC, LastName DESC, MiddleName ASC

--T16 Create View Employees with Salaries

CREATE VIEW V_EmployeesSalaries AS 
SELECT FirstName, LastName, Salary FROM Employees

--T17 Create View Employees with Job Titles

CREATE VIEW V_EmployeeNameJobTitle AS
SELECT FirstName+' '+ ISNULL(MiddleName, '')+' '+ LastName AS [Full Name], JobTitle  FROM Employees

--T18 Distinct Job Titles

SELECT DISTINCT JobTitle FROM Employees

--T19 Find First 10 Started Projects

SELECT TOP(10) * FROM Projects
ORDER BY StartDate, Name

--T20 Last 7 Hired Employees

SELECT TOP(7) FirstName, LastName, HireDate FROM Employees
ORDER BY HireDate DESC

--T21 Increase Salaries

--USE SoftUni
UPDATE Employees
SET Salary = Salary *1.12
WHERE DepartmentID IN (1,2,4,11)

SELECT Salary FROM Employees


