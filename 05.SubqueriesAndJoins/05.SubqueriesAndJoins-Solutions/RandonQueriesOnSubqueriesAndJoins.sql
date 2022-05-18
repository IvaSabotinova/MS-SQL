USE SoftUni

--INNER JOIN

SELECT * FROM Employees e
JOIN Employees m ON e.ManagerID = m.EmployeeID

--LEFT OUTER JOIN

SELECT * FROM Employees AS e
LEFT OUTER JOIN Departments AS d ON e.DepartmentID = d.DepartmentID

--RIGHT OUTER JOIN

SELECT * FROM Employees AS e
RIGHT JOIN Employees AS m ON e.ManagerID = m.EmployeeID

SELECT * FROM Employees AS e
RIGHT JOIN Departments AS d ON e.DepartmentID = d.DepartmentID

--FULL JOIN

SELECT * FROM Employees AS e
FULL JOIN Departments AS d ON e.DepartmentID = d.DepartmentID

--CARTESIAN PRODUCT

SELECT LastName, [Name] AS DepartmentName
FROM Employees, Departments

--CROSS JOIN

SELECT * FROM Employees AS e
CROSS JOIN Departments AS d




