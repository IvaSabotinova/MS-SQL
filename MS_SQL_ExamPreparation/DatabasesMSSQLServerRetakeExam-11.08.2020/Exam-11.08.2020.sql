
--Section 1. DDL 

--T01 Database design

CREATE DATABASE Bakery
USE Bakery

CREATE TABLE Countries
(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50) UNIQUE
)

CREATE TABLE Customers
(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(25),
LastName NVARCHAR(25),
Gender CHAR(1) CHECK (Gender = 'M' OR Gender = 'F'),
Age INT,
PhoneNumber CHAR(10),
CountryId INT FOREIGN KEY REFERENCES Countries(Id)
)

CREATE TABLE Products
(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(25) UNIQUE,
[Description] NVARCHAR(250),
Recipe NVARCHAR(MAX),
Price MONEY CHECK(Price >=0)
)

CREATE TABLE Feedbacks
(
Id INT PRIMARY KEY IDENTITY,
[Description] NVARCHAR(255),
Rate DECIMAL(18,2) CHECK(Rate BETWEEN 0 AND 10),
ProductId INT FOREIGN KEY REFERENCES Products(Id),
CustomerId INT FOREIGN KEY REFERENCES Customers(Id)
)

CREATE TABLE Distributors
(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(25) UNIQUE,
AddressText NVARCHAR(30),
Summary NVARCHAR(200),
CountryId INT FOREIGN KEY REFERENCES Countries(Id)
)

CREATE TABLE Ingredients
(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(30),
[Description] NVARCHAR(200),
OriginCountryId INT FOREIGN KEY REFERENCES Countries(Id),
DistributorId INT FOREIGN KEY REFERENCES Distributors(Id)
)

CREATE TABLE ProductsIngredients
(
ProductId INT FOREIGN KEY REFERENCES Products(Id) NOT NULL,
IngredientId INT FOREIGN KEY REFERENCES Ingredients(Id) NOT NULL,
PRIMARY KEY (ProductId, IngredientId)
)

--Section 2. DML

--T02 Insert

INSERT INTO Distributors ([Name], CountryId, AddressText, Summary) VALUES
('Deloitte & Touche', 2, '6 Arch St #9757', 'Customizable neutral traveling'),
('Congress Title', 13, '58 Hancock St', 'Customer loyalty'),
('Kitchen People', 1, '3 E 31st St #77', 'Triple-buffered stable delivery'),
('General Color Co Inc', 21, '6185 Bohn St #72', 'Focus group'),
('Beck Corporation', 23, '21 E 64th Ave', 'Quality-focused 4th generation hardware')

INSERT INTO Customers (FirstName, LastName, Age, Gender, PhoneNumber, CountryId) VALUES
('Francoise', 'Rautenstrauch', 15, 'M', '0195698399', 5),
('Kendra', 'Loud', 22, 'F', '0063631526', 11),
('Lourdes', 'Bauswell', 50, 'M', '0139037043', 8),
('Hannah', 'Edmison', 18, 'F', '0043343686', 1),
('Tom', 'Loeza', 31, 'M', '0144876096', 23),
('Queenie', 'Kramarczyk', 30, 'F', '0064215793', 29),
('Hiu', 'Portaro', 25, 'M', '0068277755', 16),
('Josefa', 'Opitz', 43, 'F', '0197887645', 17)

--T03 Update

UPDATE Ingredients
SET DistributorId = 35
WHERE [Name] IN ('Bay Leaf', 'Paprika', 'Poppy')

UPDATE Ingredients
SET OriginCountryId = 14
WHERE OriginCountryId = 8

--T04 Delete

DELETE FROM Feedbacks
WHERE CustomerId = 14 OR ProductId = 5

--Section 3. Querying

--T05 Products by Price

SELECT [Name], Price, [Description] FROM Products
ORDER BY Price DESC, [Name]

--T06 Negative Feedback

SELECT f.ProductId
, f.Rate
, f.[Description]
, f.CustomerId
, c.Age
, c.Gender 
FROM Feedbacks AS f
JOIN Customers AS c ON f.CustomerId = c.Id
WHERE Rate < 5.0
ORDER BY f.ProductId DESC, f.Rate

--T07 Customers without Feedback

SELECT CONCAT(c.FirstName, ' ', c.LastName) AS [CustomerName]
, c.PhoneNumber
, c.Gender 
FROM Customers AS c
LEFT JOIN Feedbacks AS f ON c.Id = f.CustomerId
WHERE f.Id IS NULL
ORDER BY c.Id

--T08 Customers by Criteria

SELECT c.FirstName
, c.Age
, c.PhoneNumber 
FROM Customers AS c
JOIN Countries AS ctr ON c.CountryId = ctr.Id
WHERE (c.Age >=21 AND c.FirstName LIKE '%an%') OR (c.PhoneNumber LIKE '%38' AND ctr.Name <> 'Greece')
ORDER BY c.FirstName, c.Age

--T09 Middle Range Distributors

SELECT d.[Name] AS [DistributorName]
, i.[Name] AS [IngredientName]
, p.[Name] AS [ProductName]
, AVG(f.Rate) AS AverageRate
FROM Distributors AS d
JOIN Ingredients AS i ON d.Id = i.DistributorId
JOIN ProductsIngredients AS pri ON i.Id = pri.IngredientId
JOIN Products AS p ON pri.ProductId = p.Id
JOIN Feedbacks AS f ON p.Id = f.ProductId
GROUP BY  p.[Name], d.[Name], i.[Name]
HAVING AVG(f.Rate) BETWEEN 5 AND 8
ORDER BY d.[Name], i.[Name], p.[Name]

--T10 Country Representative

SELECT temp.CountryName, temp.DisributorName FROM
(
SELECT c.[Name] AS [CountryName]
, d.[Name] AS [DisributorName]
, DENSE_RANK() OVER (PARTITION BY c.[Name] ORDER BY COUNT(i.Id) DESC) AS [Ranked]
FROM Countries AS c
JOIN Distributors AS d ON c.Id = d.CountryId
LEFT JOIN Ingredients AS i ON d.Id = i.DistributorId
GROUP BY d.[Name], c.[Name]) AS temp
WHERE temp.Ranked = 1
ORDER BY temp.CountryName, temp.DisributorName

--Section 4. Programmability

--T11 Customers with Countries

GO
CREATE VIEW v_UserWithCountries AS
SELECT CONCAT(FirstName, ' ', LastName) AS [CustomerName]
, c.Age
, c.Gender
, ctr.[Name] AS [CountryName] 
FROM Customers AS c
LEFT JOIN Countries AS ctr ON c.CountryId = ctr.Id
GO

SELECT TOP 5 * FROM v_UserWithCountries
ORDER BY Age

--T12 Delete Products

GO
CREATE OR ALTER TRIGGER tr_DeleteProducts
ON Products INSTEAD OF DELETE
AS
BEGIN
DELETE FROM Feedbacks
WHERE ProductId = (SELECT Id FROM deleted)

DELETE FROM ProductsIngredients
WHERE ProductId = (SELECT Id FROM deleted)

DELETE FROM Products
WHERE Id = (SELECT Id FROM deleted)
END
GO

DELETE FROM Products WHERE Id = 7

