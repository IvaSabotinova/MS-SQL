--Section 1. DDL

CREATE DATABASE Zoo

USE Zoo

--T01 Database design

CREATE TABLE Owners
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL,
PhoneNumber VARCHAR(15) NOT NULL,
[Address] VARCHAR(50)
)

CREATE TABLE AnimalTypes
(
Id INT PRIMARY KEY IDENTITY,
AnimalType VARCHAR(30) NOT NULL
)

CREATE TABLE Cages
(
Id INT PRIMARY KEY IDENTITY,
AnimalTypeId INT FOREIGN KEY REFERENCES AnimalTypes(Id) NOT NULL
)

CREATE TABLE Animals
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(30) NOT NULL,
BirthDate DATE NOT NULL,
OwnerId INT FOREIGN KEY REFERENCES Owners(Id),
AnimalTypeId INT FOREIGN KEY REFERENCES AnimalTypes(Id) NOT NULL
)

CREATE TABLE AnimalsCages
(
CageId INT FOREIGN KEY REFERENCES Cages(Id) NOT NULL,
AnimalId INT FOREIGN KEY REFERENCES Animals(Id) NOT NULL,
PRIMARY KEY (CageId, AnimalId)
)

CREATE TABLE VolunteersDepartments
(
Id INT PRIMARY KEY IDENTITY,
DepartmentName VARCHAR(30) NOT NULL,
)

CREATE TABLE Volunteers
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL,
PhoneNumber VARCHAR(15) NOT NULL,
[Address] VARCHAR(50),
AnimalId INT FOREIGN KEY REFERENCES Animals(Id),
DepartmentId INT FOREIGN KEY REFERENCES VolunteersDepartments(Id) NOT NULL
)

--Section 2. DML

--T02 Insert

INSERT INTO Volunteers VALUES
('Anita Kostova','0896365412','Sofia, 5 Rosa str.',15,1),
('Dimitur Stoev','0877564223',null,42,4),
('Kalina Evtimova','0896321112','Silistra, 21 Breza str.',9,7),
('Stoyan Tomov','0898564100','Montana, 1 Bor str.',18,8),
('Boryana Mileva','0888112233',null,31,5)

INSERT INTO Animals VALUES
('Giraffe','2018-09-21',21,1),
('Harpy Eagle','2015-04-17',15,3),
('Hamadryas Baboon','2017-11-02',null,1),
('Tuatara','2021-06-30',2,4)

--T03 Update

UPDATE Animals
SET OwnerId = 4
WHERE OwnerId IS NULL

--T04 Delete

DELETE FROM Volunteers
WHERE DepartmentId = 2

DELETE FROM VolunteersDepartments
WHERE DepartmentName  ='Education program assistant'

--Section 3. Querying

--T05 Volunteers

SELECT [Name], PhoneNumber, [Address], AnimalId, DepartmentId
FROM Volunteers
ORDER BY [Name], AnimalId, DepartmentId

--T06 Animals data

SELECT a.[Name]
, [at].AnimalType
, FORMAT(BirthDate,'dd.MM.yyyy') AS [BirthDate]
FROM Animals AS a
JOIN AnimalTypes AS [at] ON a.AnimalTypeId = at.Id
ORDER BY a.[Name]

--T07 Owners and Their Animals

SELECT TOP 5 o.[Name], 
COUNT(a.Id) AS [CountOfAnimals] 
FROM Owners AS o
LEFT JOIN Animals AS a ON o.Id = a.OwnerId
GROUP BY o.[Name]
ORDER BY CountOfAnimals DESC, O.[Name]

--T08 Owners, Animals and Cages

SELECT CONCAT(o.[Name], '-', a.[Name]) AS [OwnersAnimals]
, o.PhoneNumber
, ac.CageId AS [CageId]
FROM Owners AS o
JOIN Animals AS a ON o.Id = a.OwnerId
JOIN AnimalsCages AS ac ON a.Id = ac.AnimalId
WHERE a.AnimalTypeId = 1
ORDER BY o.[Name], a.[Name] DESC

--T09 Volunteers in Sofia

SELECT [Name]
,PhoneNumber
--, SUBSTRING([Address], PATINDEX('%[0-9]%', [Address]), LEN([Address])) AS [Address]
, SUBSTRING([Address], CHARINDEX(',', [Address], 1 )+1, LEN([Address])) AS [Address]
--, SUBSTRING([Address], CHARINDEX(',', [Address], 1 )+1, LEN([Address]) - CHARINDEX(',', [Address], 1 )) AS [Address]
FROM Volunteers
WHERE DepartmentId = 2 AND CHARINDEX('Sofia', [Address],1) <>0
ORDER BY [Name]

--ANOTHER SOLUTION

SELECT [Name] 
, PhoneNumber
, TRIM(', Sofia' FROM [Address]) AS [Address]
FROM Volunteers
WHERE DepartmentId = 2 AND CHARINDEX ('Sofia', [Address], 1) <>0
ORDER BY [Name]

--ANOTHER SOLUTION

SELECT [Name] 
, PhoneNumber
, CASE WHEN CHARINDEX ('Sofia,', [Address], 1) <> 0 THEN REPLACE([Address], 'Sofia, ', '')
ELSE LTRIM(REPLACE([Address], 'Sofia ,',''))
END AS [Address]
FROM Volunteers
WHERE DepartmentId = 2 AND CHARINDEX ('Sofia', [Address], 1) <>0
ORDER BY [Name]

--T10 Animals for Adoption

SELECT a.[Name]
, YEAR(a.BirthDate) AS [BirthYear]
, [at].AnimalType 
FROM Animals AS a
LEFT JOIN AnimalTypes AS [at] ON a.AnimalTypeId = [at].Id
WHERE OwnerId IS NULL AND DATEDIFF(YEAR, BirthDate, '01/01/2022') < 5 AND [at].AnimalType != 'Birds'
ORDER BY a.[Name]

--Section 4. Programmability

--T11 All Volunteers in a Department

GO

CREATE OR ALTER FUNCTION udf_GetVolunteersCountFromADepartment (@VolunteersDepartment VARCHAR(30))
RETURNS INT
AS
BEGIN
RETURN(
SELECT COUNT(v.Id) FROM VolunteersDepartments AS vd
LEFT JOIN Volunteers AS v ON vd.Id = v.DepartmentId
WHERE vd.DepartmentName = @VolunteersDepartment)
END

GO
SELECT dbo.udf_GetVolunteersCountFromADepartment ('Education program assistant')
SELECT dbo.udf_GetVolunteersCountFromADepartment ('Guest engagement')
SELECT dbo.udf_GetVolunteersCountFromADepartment ('Zoo events')

--T12 Animals with Owner or Not

GO

CREATE OR ALTER PROCEDURE usp_AnimalsWithOwnersOrNot(@AnimalName VARCHAR(30))
AS
BEGIN
SELECT a.[Name],
CASE WHEN o.[Name] IS NULL THEN 'For adoption'
ELSE o.[Name] 
END AS [OwnersName]
FROM Animals AS a
LEFT JOIN Owners AS o ON a.OwnerId = o.Id
WHERE a.[Name] = @AnimalName
END

GO

EXEC usp_AnimalsWithOwnersOrNot 'Pumpkinseed Sunfish'
EXEC usp_AnimalsWithOwnersOrNot 'Hippo'
EXEC usp_AnimalsWithOwnersOrNot 'Brown bear'



