USE SoftUniDatabase

--T08 Employees with Three Projects

GO
CREATE OR ALTER PROC usp_AssignProject(@emloyeeId INT, @projectID INT) 
AS
BEGIN TRANSACTION
IF (SELECT COUNT(ProjectID) FROM EmployeesProjects WHERE EmployeeID = @emloyeeId) >= 3 
BEGIN
	ROLLBACK
	RAISERROR('The employee has too many projects!',16,1) 
	RETURN
END
	INSERT INTO EmployeesProjects VALUES
	(@emloyeeId, @projectID)
COMMIT

--T09 Delete Employees

CREATE TABLE Deleted_Employees
(
EmployeeId INT PRIMARY KEY,
FirstName VARCHAR(50) NOT NULL,
LastName VARCHAR (50) NOT NULL,
MiddleName VARCHAR(50),
JobTitle VARCHAR(50) NOT NULL,
DepartmentId INT NOT NULL,
Salary MONEY NOT NULL
)

GO
CREATE OR ALTER TRIGGER tr_Deleted_Employees
ON Employees FOR DELETE
AS
INSERT INTO Deleted_Employees(FirstName, LastName, MiddleName, JobTitle, DepartmentId, Salary)
SELECT FirstName, LastName, MiddleName, JobTitle, DepartmentID, Salary FROM deleted





