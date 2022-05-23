USE SoftUniDatabase

--T13 Departments Total Salaries

SELECT DepartmentID, SUM(Salary) AS TotalSalary
FROM Employees
GROUP BY DepartmentID
ORDER BY DepartmentID

--T14 Employees Minimum Salaries

SELECT DepartmentID, MIN(Salary) AS MinimumSalary
FROM Employees
WHERE DepartmentID IN (2,5,7) AND HireDate > '2000/01/01'
GROUP BY DepartmentID

--T15 Employees Average Salaries

SELECT * INTO EmployeesNew
FROM Employees 
WHERE Salary > 30000

DELETE FROM EmployeesNew
WHERE ManagerID = 42

UPDATE EmployeesNew
SET Salary = Salary + 5000
WHERE DepartmentID = 1

SELECT DepartmentID, AVG(Salary) AS AverageSalary
FROM EmployeesNew
GROUP BY DepartmentID

--T16 Employees Maximum Salaries

SELECT DepartmentID, MAX(Salary) AS MaxSalary
FROM Employees
GROUP BY DepartmentID
HAVING MAX(Salary) NOT BETWEEN 30000 AND 70000

--T17 Employees Count Salaries

SELECT COUNT(Salary) AS [Count] FROM Employees
WHERE ManagerID IS NULL

--T18 *3rd Highest Salary

SELECT DISTINCT DepartmentID, Salary AS ThirdHighestSalary FROM
(SELECT DepartmentID, Salary,
DENSE_RANK() OVER(PARTITION BY DepartmentID ORDER BY Salary DESC) AS Ranked FROM Employees) AS sr
WHERE sr.Ranked = 3

--T19 **Salary Challenge

SELECT TOP(10) e.FirstName, e.LastName, e.DepartmentID FROM Employees AS e
WHERE e.Salary > (SELECT AVG(Salary) FROM Employees
WHERE DepartmentID = e.DepartmentID
GROUP BY DepartmentID)
ORDER BY DepartmentID
