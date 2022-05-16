USE SoftUniDatabase

--T01 Find Names of All Employees by First Name

SELECT FirstName, LastName FROM Employees
WHERE FirstName LIKE 'Sa%'

--T02 Find Names of All employees by Last Name 

SELECT FirstName, LastName FROM Employees
WHERE LastName LIKE '%ei%'

--T03 Find First Names of All Employess

SELECT FirstName FROM Employees
WHERE DepartmentID IN (3,10) AND YEAR(HireDate) BETWEEN 1995 AND 2005

--T04 Find All Employees Except Engineers

SELECT FirstName, LastName FROM Employees
WHERE JobTitle NOT LIKE '%engineer%'

--ANOTHER SOLUTION
SELECT FirstName, LastName FROM Employees
WHERE CHARINDEX('engineer', JobTitle, 1) = 0

--T05 Find Towns with Name Length

SELECT [Name] FROM Towns
WHERE LEN([Name]) = 5 OR LEN([Name]) = 6
ORDER BY [Name]

--T06 Find Towns Starting With

SELECT TownID, [Name] FROM Towns
WHERE LEFT([Name], 1) = 'M' OR LEFT([Name], 1) = 'K' OR LEFT([Name], 1) = 'B' OR LEFT([Name], 1) = 'E'
ORDER BY [Name]

--ANOTHER SOLUTION

SELECT TownID, [Name] FROM Towns
WHERE LEFT([Name], 1) IN ('M', 'K', 'B', 'E')
ORDER BY [Name]

--ANOTHER SOLUTION

SELECT TownID, [Name] FROM Towns
WHERE [Name] LIKE '[MKBE]%'
ORDER BY [Name]

--T07 Find Towns Not Starting With

SELECT TownID, [Name] FROM Towns
WHERE [Name] LIKE '[^RBD]%'
ORDER BY [Name]

--ANOTHER SOLUTION

SELECT TownID, [Name] FROM Towns
WHERE [Name] NOT LIKE '[RBD]%'
ORDER BY [Name]

--T08 Create View Employees Hired After 2000 Year

CREATE VIEW V_EmployeesHiredAfter2000 AS
SELECT FirstName, LastName  FROM Employees
WHERE YEAR(HireDate) > 2000

--ANOTHER SOLUTION

CREATE VIEW V_EmployeesHiredAfter2000 AS
SELECT FirstName, LastName  FROM Employees
WHERE DATEPART(Year, HireDate) > 2000

--T09 Length of Last Name

SELECT FirstName, LastName FROM Employees
WHERE LEN(LastName) = 5

--T10 Rank Employees by Salary

SELECT EmployeeID, FirstName, LastName, Salary,
DENSE_RANK() OVER (PARTITION BY Salary ORDER BY EmployeeID) AS Rank FROM Employees
WHERE Salary BETWEEN 10000 AND 50000
ORDER BY Salary DESC

--T11 Find All Employees with Rank 2 *

SELECT * FROM (SELECT EmployeeID, FirstName, LastName, Salary,
DENSE_RANK() OVER (PARTITION BY Salary ORDER BY EmployeeID) AS [Rank] FROM Employees
WHERE Salary BETWEEN 10000 AND 50000
) AS FinalTable
WHERE [Rank] = 2
ORDER BY Salary DESC

