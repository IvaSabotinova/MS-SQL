
CREATE DATABASE WMS
USE WMS

--Section 1. DDL 

--T01 Database design

CREATE TABLE Clients
(
ClientId INT PRIMARY KEY IDENTITY,
FirstName VARCHAR(50) NOT NULL,
LastName VARCHAR (50) NOT NULL,
Phone CHAR (12) NOT NULL 
)

CREATE TABLE Mechanics
(
MechanicId INT PRIMARY KEY IDENTITY,
FirstName VARCHAR(50) NOT NULL,
LastName VARCHAR (50) NOT NULL,
[Address] VARCHAR(255) NOT NULL
)
CREATE TABLE Models
(
ModelId INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) UNIQUE NOT NULL,
)

CREATE TABLE Jobs
(
JobId INT PRIMARY KEY IDENTITY,
ModelId INT FOREIGN KEY REFERENCES Models(ModelId) NOT NULL,
[Status] VARCHAR (11) DEFAULT 'Pending' CHECK ([Status] IN('Pending', 'In Progress' ,'Finished')) NOT NULL,
ClientId INT FOREIGN KEY REFERENCES Clients(ClientId) NOT NULL, 
MechanicId INT FOREIGN KEY REFERENCES Mechanics(MechanicId),
IssueDate DATE NOT NULL,
FinishDate DATE
)

CREATE TABLE Orders
(
OrderId INT PRIMARY KEY IDENTITY,
JobId INT FOREIGN KEY REFERENCES Jobs(JobId) NOT NULL,
IssueDate DATE,
Delivered BIT DEFAULT 0  NOT NULL
)

CREATE TABLE Vendors
(
VendorId INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Parts
(
PartId INT PRIMARY KEY IDENTITY,
SerialNumber VARCHAR(50) UNIQUE NOT NULL,
[Description] VARCHAR(255),
Price MONEY CHECK (Price >0 AND Price < 9999.999) NOT NULL,
VendorId INT FOREIGN KEY REFERENCES Vendors(VendorId) NOT NULL,
StockQty INT CHECK(StockQty >=0) DEFAULT 0 NOT NULL
)

CREATE TABLE OrderParts
(
OrderId INT FOREIGN KEY REFERENCES Orders(OrderId)NOT NULL,
PartId INT FOREIGN KEY REFERENCES Parts(PartId) NOT NULL,
PRIMARY KEY(OrderId, PartId),
Quantity INT CHECK(Quantity > 0) DEFAULT 1 NOT NULL
)

CREATE TABLE PartsNeeded
(
JobId INT FOREIGN KEY REFERENCES Jobs(JobId) NOT NULL,
PartId INT FOREIGN KEY REFERENCES Parts(PartId) NOT NULL,
PRIMARY KEY (JobId, PartId),
Quantity INT CHECK(Quantity > 0) DEFAULT 1 NOT NULL
)

--Section 2. DML

--T02 Insert

INSERT INTO Clients VALUES
('Teri',	'Ennaco',	'570-889-5187'),
('Merlyn',	'Lawler',	'201-588-7810'),
('Georgene', 'Montezuma', '925-615-5185'),
('Jettie',	'Mconnell',	'908-802-3564'),
('Lemuel',	'Latzke',	'631-748-6479'),
('Melodie',	'Knipp',	'805-690-1682'),
('Candida',	'Corbley',	'908-275-8357')

INSERT INTO Parts (SerialNumber, [Description], Price, VendorId) VALUES
('WP8182119', 'Door Boot Seal',	117.86,	2),
('W10780048', 'Suspension Rod',	42.81,	1),
('W10841140', 'Silicone Adhesive',  6.77,	4),
('WPY055980', 'High Temperature Adhesive', 13.94,	3)

--T03 Update

--SELECT * FROM Mechanics 
--WHERE FirstName  ='Ryan' AND LastName = 'Harnos' --3

UPDATE Jobs
SET MechanicId = 3, [Status] = 'In Progress'
WHERE [Status] = 'Pending'

--T04 Delete

DELETE FROM OrderParts
WHERE OrderId = 19

DELETE FROM Orders
WHERE OrderId = 19

--Section 3. Querying 

--T05. Mechanic Assignments

SELECT CONCAT(m.FirstName, ' ', m.LastName) AS [Mechanic]
, j.[Status]
, j.IssueDate
FROM Mechanics AS m
JOIN Jobs AS j ON m.MechanicId = j.MechanicId
ORDER BY m.MechanicId, j.IssueDate, j.JobId

--T06 Current Clients

SELECT CONCAT(c.FirstName, ' ', c.LastName) AS [Client]
, DATEDIFF(DAY, j.IssueDate, '24 April 2017') AS [Days going]
, j.[Status]
FROM Clients AS c
JOIN Jobs AS j ON c.ClientId = j.ClientId
WHERE J.Status <> 'Finished'
ORDER BY [Days going] DESC, c.ClientId

--T07 Mechanic Performance

SELECT CONCAT(m.FirstName, ' ', m.LastName) AS [Mechanic]
, AVG(DATEDIFF(DAY, j.IssueDate, j.FinishDate)) as [Average Days] FROM Mechanics AS m
JOIN Jobs AS j ON m.MechanicId = j.MechanicId
GROUP BY CONCAT(m.FirstName, ' ', m.LastName), m.MechanicId
ORDER BY m.MechanicId

--T08 Available Mechanics

SELECT MechanicId FROM Jobs
WHERE [Status] = 'In Progress' -- Busy Mechanics

SELECT CONCAT(m.FirstName, ' ', m.LastName) AS [Available]
FROM Mechanics AS m
LEFT JOIN Jobs AS j ON m.MechanicId = j.MechanicId
WHERE m.MechanicId NOT IN (SELECT MechanicId FROM Jobs
							WHERE [Status] = 'In Progress')
GROUP BY CONCAT(m.FirstName, ' ', m.LastName), m.MechanicId
ORDER BY m.MechanicId

--T09  Past Expenses

SELECT j.JobId
, ISNULL(SUM(p.Price * op.Quantity),0) AS [Total] 
FROM Jobs AS j
LEFT JOIN Orders AS o ON j.JobId = o.JobId
LEFT JOIN OrderParts AS op ON o.OrderId = op.OrderId
LEFT JOIN Parts AS p ON op.PartId = p.PartId
WHERE j.[Status] = 'Finished'
GROUP BY j.JobId
ORDER BY Total DESC, j.JobId

--T10 Missing Parts

SELECT * FROM 
(SELECT p.PartId
, p.[Description]
, pn.Quantity AS [Required]
, p.StockQty AS [In Stock]
, ISNULL(op.Quantity,0) AS [Ordered]
FROM Jobs AS j
LEFT JOIN PartsNeeded AS pn ON j.JobId = pn.JobId
LEFT JOIN Parts AS p ON pn.PartId = p.PartId
LEFT JOIN Orders AS o ON j.JobId = o.JobId
LEFT JOIN OrderParts AS op ON o.OrderId = op.OrderId
WHERE j.[Status] <> 'Finished' AND (o.Delivered = 0 OR o.Delivered IS NULL)
) AS temp
WHERE temp.[In Stock] + temp.Ordered < temp.[Required]
ORDER BY temp.PartId

--Section 4. Programmability

--T11 Place Order

GO

CREATE OR ALTER PROCEDURE usp_PlaceOrder(@jobId INT, @serialNumber VARCHAR(50), @quantity INT)
AS
BEGIN
IF @quantity <= 0
BEGIN;
	THROW 50012, 'Part quantity must be more than zero!', 1
END
IF @jobId IN (SELECT JobId FROM Jobs
WHERE [Status] = 'Finished')
BEGIN;
	THROW 50011, 'This job is not active!', 1
END
IF @jobId NOT IN (SELECT JobId FROM Jobs)
BEGIN;
	THROW 50013, 'Job not found!', 1
END
IF @serialNumber NOT IN (SELECT SerialNumber FROM Parts)
BEGIN;
	THROW 50014, 'Part not found!',1
END
IF (SELECT COUNT(OrderId) FROM Orders WHERE JobId  = @jobId AND IssueDate IS NULL) = 0
BEGIN
	INSERT INTO Orders VALUES(@jobId, NULL, 0)
END
	DECLARE @orderId INT = (SELECT OrderId FROM Orders WHERE JobId = @jobId AND IssueDate IS NULL AND Delivered = 0)
	DECLARE @partId INT = (SELECT PartId FROM Parts WHERE SerialNumber = @serialNumber)
IF (SELECT COUNT(*) FROM OrderParts
	WHERE OrderId = @orderId AND PartId = @partId) > 0
BEGIN
	UPDATE OrderParts
	SET Quantity += @quantity
	WHERE OrderId = @orderId AND PartId = @partId
END
ELSE
BEGIN
	INSERT INTO OrderParts VALUES (@orderId, @partId, @quantity ) 
END
END

DECLARE @err_msg AS NVARCHAR(MAX);
BEGIN TRY
  EXEC usp_PlaceOrder 1, 'ZeroQuantity', 0
END TRY

BEGIN CATCH
  SET @err_msg = ERROR_MESSAGE();
  SELECT @err_msg
END CATCH

--T12 Cost Of Order
GO

CREATE OR ALTER FUNCTION udf_GetCost (@jobId INT)
RETURNS DECIMAL(18,2)
AS
BEGIN
RETURN ISNULL((SELECT SUM(p.Price * op.Quantity)
FROM Jobs AS j
JOIN Orders AS o ON j.JobId = o.JobId
JOIN OrderParts AS op ON o.OrderId = op.OrderId
JOIN Parts AS p ON op.PartId = p.PartId
WHERE j.JobId = @jobId), 0)
END
GO
SELECT dbo.udf_GetCost(1) --91.86
SELECT dbo.udf_GetCost(3) --40.97
SELECT dbo.udf_GetCost(6) --27.15