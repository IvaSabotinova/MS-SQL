USE SoftUniDatabase

--T01 Employee Address

SELECT TOP(5) e.EmployeeID, e.JobTitle, e.AddressID, a.AddressText FROM Employees AS e
JOIN Addresses AS a ON e.AddressID = a.AddressID
ORDER BY AddressID 

--T02 Addresses with Towns

SELECT TOP(50) e.FirstName,e.LastName, t.[Name] AS [Town], a.AddressText FROM Employees AS e
JOIN Addresses AS a ON e.AddressID = a.AddressID
JOIN Towns AS t ON a.TownID = t.TownID
ORDER BY e.FirstName, e.LastName

--T03 Sales Employee

SELECT e.EmployeeID
, e.FirstName
, e.LastName
, d.[Name] AS DepartmentName
FROM Employees AS e
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
WHERE D.[Name] = 'Sales'
ORDER BY e.EmployeeID

--T04 Employee Departments

SELECT TOP(5) e.EmployeeID
, e.FirstName
, e.Salary
, d.Name AS DepartmentName FROM Employees AS e
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
WHERE e.Salary > 15000
ORDER BY e.DepartmentID

--T05 Employees Without Project

SELECT TOP (3) e.EmployeeID, e.FirstName FROM Employees AS e
LEFT JOIN EmployeesProjects as ep ON e.EmployeeID = ep.EmployeeID
WHERE ep.EmployeeID IS NULL
ORDER BY e.EmployeeID 

--T06 Employees Hired After

SELECT e.FirstName
, e.LastName
, e.HireDate
, d.[Name] AS DeptName 
FROM Employees AS e
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
WHERE e.HireDate > '1999-01-01' AND (d.[Name] = 'Sales' OR d.[Name] = 'Finance')
ORDER BY E.HireDate

--T07 Employees with Project

SELECT TOP(5) e.EmployeeID
, e.FirstName
, p.[Name] AS ProjectName
FROM Employees AS e
JOIN EmployeesProjects AS ep ON ep.EmployeeID = e.EmployeeID
JOIN Projects AS p ON ep.ProjectID = p.ProjectID AND (p.StartDate > '2002-08-13' AND p.EndDate IS NULL)
ORDER BY E.EmployeeID

--T08 Employee 24

SELECT e.EmployeeID, e.FirstName, 
CASE
WHEN p.StartDate >= '2005-01-01' THEN NULL
ELSE p.[Name]
END AS [ProjectName] FROM Employees AS e
JOIN EmployeesProjects AS ep ON ep.EmployeeID = e.EmployeeID
JOIN Projects AS p ON ep.ProjectID = p.ProjectID
WHERE e.EmployeeID = 24


--T09 Employee Manager

SELECT e.EmployeeID
, e.FirstName
, e.ManagerID 
, m.FirstName AS ManagerName FROM Employees e
JOIN Employees m ON e.ManagerID = m.EmployeeID
WHERE  e.ManagerID IN (3, 7)
ORDER BY e.EmployeeID

--T10 Employee Summary

SELECT TOP (50) e.EmployeeID
, CONCAT(e.FirstName, ' ', e.LastName) AS [EmployeeName]
, CONCAT(m.FirstName, ' ', m.LastName) AS [ManagerName]
, d.[Name] AS [DepartmentName]
FROM Employees AS e
LEFT JOIN Employees AS m ON e.ManagerID = m.EmployeeID
LEFT JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
ORDER BY e.EmployeeID

--T11 Min Average Salary

SELECT TOP(1) AVG(e.Salary) AS MinAverageSalary
FROM Employees AS e
GROUP BY e.DepartmentID
ORDER BY MinAverageSalary

--ANOTHER SOLUTION

SELECT MIN(a.AvgSalary) AS MinAverageSalary
FROM 
(
SELECT AVG(Salary) AS AvgSalary FROM Employees 
GROUP BY DepartmentID
) 
AS a


