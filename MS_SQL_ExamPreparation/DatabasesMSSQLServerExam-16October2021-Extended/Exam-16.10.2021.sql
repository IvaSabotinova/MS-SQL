
CREATE DATABASE CigarShop

--Section 1. DDL

--T01 Database design

CREATE TABLE Sizes
(
Id INT PRIMARY KEY IDENTITY,
[Length] INT CHECK ([LENGTH] BETWEEN 10 AND 25) NOT NULL,
RingRange DECIMAL(18,2) CHECK (RingRange BETWEEN 1.5 AND 7.5) NOT NULL,
)

CREATE TABLE Tastes
(
Id INT PRIMARY KEY IDENTITY,
TasteType VARCHAR(20) NOT NULL,
TasteStrength VARCHAR(15) NOT NULL,
ImageURL NVARCHAR(100) NOT NULL
)

CREATE TABLE Brands
(
Id INT PRIMARY KEY IDENTITY,
BrandName VARCHAR(30) UNIQUE NOT NULL,
BrandDescription VARCHAR(MAX)
)

CREATE TABLE Cigars
(
Id INT PRIMARY KEY IDENTITY,
CigarName VARCHAR(80) NOT NULL,
BrandId INT FOREIGN KEY REFERENCES Brands(Id) NOT NULL,
TastId INT FOREIGN KEY REFERENCES Tastes(Id) NOT NULL,
SizeId INT FOREIGN KEY REFERENCES Sizes(Id) NOT NULL,
PriceForSingleCigar MONEY NOT NULL,
ImageURL NVARCHAR(100) NOT NULL
)

CREATE TABLE Addresses 
(
Id INT PRIMARY KEY IDENTITY,
Town VARCHAR(30) NOT NULL,
Country NVARCHAR(30) NOT NULL,
Streat NVARCHAR(100) NOT NULL,
ZIP VARCHAR(20) NOT NULL
)

CREATE TABLE Clients
(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(30) NOT NULL,
LastName NVARCHAR(30) NOT NULL,
Email NVARCHAR(50) NOT NULL, 
AddressId INT FOREIGN KEY REFERENCES Addresses(Id) NOT NULL
)

CREATE TABLE ClientsCigars
(
ClientId INT FOREIGN KEY REFERENCES Clients(Id) NOT NULL,
CigarId INT FOREIGN KEY REFERENCES Cigars(Id) NOT NULL,
PRIMARY KEY (ClientId, CigarId)
)

--Section 2. DML

--T02 Insert

INSERT INTO Cigars VALUES 
('COHIBA ROBUSTO',	9,	1,	5,	15.50,	'cohiba-robusto-stick_18.jpg'),
('COHIBA SIGLO I',	9,	1,	10,	410.00,	'cohiba-siglo-i-stick_12.jpg'),
('HOYO DE MONTERREY LE HOYO DU MAIRE',	14,	5,	11,	7.50,	'hoyo-du-maire-stick_17.jpg'),
('HOYO DE MONTERREY LE HOYO DE SAN JUAN',	14,	4,	15, 32.00,	'hoyo-de-san-juan-stick_20.jpg'),
('TRINIDAD COLONIALES',	2,	3,	8,	85.21,	'trinidad-coloniales-stick_30.jpg')

INSERT INTO Addresses VALUES
('Sofia',	'Bulgaria',	'18 Bul. Vasil levski',	'1000'),
('Athens',	'Greece',	'4342 McDonald Avenue',	'10435'),
('Zagreb',	'Croatia',	'4333 Lauren Drive', '10000')

--T03 Update

UPDATE Cigars
SET PriceForSingleCigar *= 1.20
WHERE Id IN (SELECT c.Id
FROM Cigars AS c 
JOIN Tastes AS t ON c.TastId = t.Id
WHERE t.TasteType = 'Spicy')

UPDATE Brands
SET BrandDescription = 'New description'
WHERE BrandDescription IS NULL

--T04 Delete

DELETE FROM ClientsCigars
WHERE ClientId IN (SELECT Id FROM Clients
WHERE AddressId IN (SELECT Id FROM Addresses
WHERE Country LIKE 'C%'))

DELETE FROM Clients
WHERE AddressId IN (SELECT Id FROM Addresses
WHERE Country LIKE 'C%')

DELETE FROM Addresses
WHERE Country LIKE 'C%'


--Section 3. Querying

--T05 Cigars by Price

SELECT CigarName, PriceForSingleCigar, ImageURL FROM Cigars
ORDER BY PriceForSingleCigar, CigarName DESC

--T06 Cigars by Taste

SELECT c.Id
, c.CigarName
, c.PriceForSingleCigar
, t.TasteType
, t.TasteStrength 
FROM Cigars AS c
JOIN Tastes AS t ON c.TastId = t.Id
WHERE t.TasteType = 'Earthy' OR t.TasteType = 'Woody'
ORDER BY c.PriceForSingleCigar DESC

--T07 Clients without Cigars

SELECT c.Id
, CONCAT(FirstName, ' ', LastName) AS [ClientName]
, c.Email
FROM Clients AS c
LEFT JOIN ClientsCigars AS cc ON c.Id = cc.ClientId
WHERE CigarId IS NULL
ORDER BY ClientName

--T08 First 5 Cigars

SELECT TOP 5 c.CigarName
, c.PriceForSingleCigar
, c.ImageURL 
FROM Cigars AS c
JOIN Sizes AS s ON c.SizeId = s.Id
WHERE s.[Length] >=12 AND (c.CigarName LIKE '%ci%' OR c.PriceForSingleCigar > 50) AND s.RingRange > 2.55
ORDER BY c.CigarName, c.PriceForSingleCigar DESC

--T09 Clients with ZIP Codes

SELECT temp.FullName
, temp.Country
, temp.ZIP
, CONCAT('$', MAX(temp.CigarPrice)) AS CigarPrice FROM
(SELECT 
CONCAT(c.FirstName, ' ', c.LastName) AS [FullName]
, a.Country
, a.ZIP
, cig.PriceForSingleCigar AS [CigarPrice]
FROM Clients AS c
JOIN Addresses AS a ON c.AddressId = a.Id
JOIN ClientsCigars AS cc ON cc.ClientId = c.Id
JOIN Cigars AS cig ON cc.CigarId = cig.Id
WHERE a.ZIP NOT LIKE '%[A-Z]%') as temp
GROUP BY FullName, Country, ZIP
ORDER BY FullName

--10 Cigars by Size

SELECT c.LastName
, AVG(s.Length) AS [CiagrLength]
, CEILING(AVG(s.RingRange)) AS [CiagrRingRange]
FROM Clients AS c
JOIN ClientsCigars AS cc ON c.Id = cc.ClientId
JOIN Cigars AS cig ON cc.CigarId = cig.Id
JOIN Sizes AS s ON cig.SizeId = s.Id
GROUP BY c.LastName
ORDER BY CiagrLength DESC

--Section 4. Programmability

--T11 Client with Cigars
GO

CREATE OR ALTER FUNCTION udf_ClientWithCigars(@name NVARCHAR(30)) 
RETURNS INT
AS
BEGIN
RETURN (SELECT COUNT(cc.CigarId) 
FROM Clients AS c
JOIN ClientsCigars AS cc ON c.Id = cc.ClientId
WHERE c.FirstName = @name
)
END

GO
SELECT dbo.udf_ClientWithCigars('Betty')

--T12 Search for Cigar with Specific Taste

GO

CREATE OR ALTER PROC usp_SearchByTaste(@taste VARCHAR(20))
AS
BEGIN
SELECT cig.CigarName
, CONCAT('$',cig.PriceForSingleCigar) AS [Price]
, t.TasteType
, b.BrandName
, CONCAT(s.[Length], ' ', 'cm') AS [CigarLength]
, CONCAT(s.RingRange, ' ', 'cm') AS [CigarRingRange]
FROM Tastes AS t
JOIN Cigars AS cig ON t.Id = cig.TastId
JOIN Brands AS b ON cig.BrandId = b.Id
JOIN Sizes AS s ON cig.SizeId = s.Id
WHERE t.TasteType = @taste
ORDER BY CigarLength, CigarRingRange DESC
END

EXEC usp_SearchByTaste 'Woody'

