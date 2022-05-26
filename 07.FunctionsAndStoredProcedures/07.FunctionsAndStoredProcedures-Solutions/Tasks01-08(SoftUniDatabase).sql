USE SoftUniDatabase

--T01 Employees with Salary Above 35000

GO
CREATE PROC usp_GetEmployeesSalaryAbove35000 
AS
SELECT FirstName, LastName FROM Employees
WHERE Salary > 35000
GO
--EXEC usp_GetEmployeesSalaryAbove35000

--T02 Employees with Salary Above Number

--GO
CREATE PROC usp_GetEmployeesSalaryAboveNumber(@MinSalary DECIMAL(18,4))
AS
BEGIN
SELECT FirstName, LastName FROM Employees
WHERE Salary >= @MinSalary
END
--GO
--EXEC usp_GetEmployeesSalaryAboveNumber 48100

--T03 Town Names Starting With

GO
CREATE OR ALTER PROC usp_GetTownsStartingWith(@InputTown NVARCHAR(50))
AS
BEGIN
SELECT [Name] FROM Towns
WHERE [Name] LIKE @InputTown + '%'
END

--EXEC usp_GetTownsStartingWith b

--T04 Employees from Town

GO
CREATE OR ALTER PROC usp_GetEmployeesFromTown(@TownName VARCHAR(50))
AS
BEGIN
SELECT FirstName, LastName FROM Employees e
JOIN Addresses AS a ON e.AddressID = a.AddressID
JOIN Towns AS t ON a.TownID = t.TownID
WHERE t.[Name] = @TownName
END

EXEC usp_GetEmployeesFromTown 'sofia'

--T05 Salary Level Function

GO
CREATE OR ALTER FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4)) 
RETURNS VARCHAR(10)
AS
BEGIN
DECLARE @Result VARCHAR(10)
IF @salary <30000
SET @Result = 'Low'
ELSE IF @salary <=50000
SET @Result = 'Average'
ELSE
SET @Result = 'High'
RETURN @Result;
END
GO

SELECT *, dbo.ufn_GetSalaryLevel(Salary) AS SalaryLevel FROM Employees

--T06 Employees by Salary Level

GO

CREATE PROC usp_EmployeesBySalaryLevel(@SalaryLevel VARCHAR(10))
AS
BEGIN
SELECT FirstName, LastName FROM Employees
WHERE dbo.ufn_GetSalaryLevel(Salary) = @SalaryLevel
END

EXEC usp_EmployeesBySalaryLevel 'high'

--T07 Define Function

GO
CREATE OR ALTER FUNCTION ufn_IsWordComprised(@setOfLetters NVARCHAR(MAX), @word NVARCHAR(100))
RETURNS BIT
AS
BEGIN
DECLARE @countOfLetters INT = 1;
WHILE @countOfLetters <= LEN(@word)
BEGIN
IF (CHARINDEX(SUBSTRING(@word, @countOfLetters, 1), @setOfLetters) = 0)
RETURN 0
SET @countOfLetters += 1;
END
RETURN 1
END
GO

SELECT dbo.ufn_IsWordComprised('oistmiahf', 'Sofia') AS Result

DECLARE @setOfLetters NVARCHAR(MAX) = 'oistmiahf'
DECLARE @word NVARCHAR(100) = 'Sofia'
SELECT @setOfLetters AS [SetOfLetters], @word AS [Word], dbo.ufn_IsWordComprised(@setOfLetters, @word) AS Result

CREATE TABLE #DefineFunction
(
SetOfLetters NVARCHAR(MAX),
Word NVARCHAR(100)
)

INSERT INTO #DefineFunction VALUES
('oistmiahf', 'Sofia'),
('oistmiahf', 'halves'),
('bobr', 'Rob'),
('pppp', 'Guy')

SELECT *, dbo.ufn_IsWordComprised(SetOfLetters, Word) AS Result FROM #DefineFunction

--T08 *Delete Employees and Departments

USE SoftUniDatabase

GO

CREATE OR ALTER PROC usp_DeleteEmployeesFromDepartment(@departmentId INT) 
AS

DELETE  FROM EmployeesProjects
WHERE EmployeeID IN (SELECT EmployeeID FROM Employees WHERE DepartmentID = @departmentId)

UPDATE Employees
SET ManagerID = NULL
WHERE ManagerID IN (SELECT EmployeeID FROM Employees WHERE DepartmentID = @departmentId)

ALTER TABLE Departments
ALTER COLUMN ManagerID INT NULL

UPDATE Departments
SET ManagerID = NULL
WHERE ManagerID IN (SELECT EmployeeID FROM Employees WHERE DepartmentID = @departmentId)

DELETE FROM Employees
WHERE DepartmentID = @departmentId

DELETE FROM Departments
WHERE DepartmentID = @departmentId

SELECT COUNT(*) FROM Employees
WHERE DepartmentID = @departmentId

GO

EXEC usp_DeleteEmployeesFromDepartment 5


