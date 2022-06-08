CREATE DATABASE ColonialJourney

--Section 1. DDL 

--T01 Database Design

CREATE TABLE Planets
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(30) NOT NULL,
)

CREATE TABLE Spaceports
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL,
PlanetId INT FOREIGN KEY REFERENCES Planets(Id) NOT NULL
)

CREATE TABLE Spaceships
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL,
Manufacturer VARCHAR(30) NOT NULL,
LightSpeedRate INT DEFAULT 0
)

CREATE TABLE Colonists
(
Id INT PRIMARY KEY IDENTITY,
FirstName VARCHAR(20) NOT NULL,
LastName VARCHAR(20) NOT NULL,
Ucn VARCHAR (10) NOT NULL UNIQUE,
BirthDate DATE NOT NULL
)

CREATE TABLE Journeys
(
Id INT PRIMARY KEY IDENTITY,
JourneyStart DATETIME NOT NULL,
JourneyEnd DATETIME NOT NULL,
Purpose VARCHAR(11) CHECK (Purpose in ('Medical', 'Technical', 'Educational', 'Military')),
DestinationSpaceportId INT FOREIGN KEY REFERENCES Spaceports(Id) NOT NULL,
SpaceshipId INT FOREIGN KEY REFERENCES Spaceships(Id) NOT NULL
)

CREATE TABLE TravelCards
(
Id INT PRIMARY KEY IDENTITY,
CardNumber VARCHAR(10)  UNIQUE NOT NULL,
JobDuringJourney VARCHAR(8) CHECK (JobDuringJourney IN ('Pilot', 'Engineer', 'Trooper', 'Cleaner', 'Cook')),
ColonistId INT FOREIGN KEY REFERENCES Colonists (Id) NOT NULL,
JourneyId INT FOREIGN KEY REFERENCES Journeys(Id) NOT NULL
)

--Section 2. DML

--T02 Insert

INSERT INTO Planets VALUES
('Mars'),
('Earth'),
('Jupiter'),
('Saturn')

INSERT INTO Spaceships VALUES
('Golf', 'VW', 3),
('WakaWaka', 'Wakanda', 4),
('Falcon9', 'SpaceX', 1),
('Bed', 'Vidolov', 6)

--T03 Update

UPDATE Spaceships
SET LightSpeedRate +=1
WHERE Id BETWEEN 8 AND 12

--T04 Delete

DELETE FROM TravelCards
WHERE JourneyId BETWEEN 1 AND 3

DELETE FROM Journeys
WHERE Id BETWEEN 1 AND 3

--Section 3. Querying 

--T05 Select all military journeys

SELECT Id
, FORMAT(JourneyStart, 'dd/MM/yyyy') AS [JourneyStart]
, FORMAT(JourneyEnd, 'dd/MM/yyyy') AS [JourneyEnd]
FROM Journeys
WHERE Purpose = 'Military'
ORDER BY JourneyStart

--T06 Select all pilots

SELECT c.Id AS [id]
, CONCAT(c.FirstName, ' ', c.LastName) AS [full_name]
FROM Colonists AS c
JOIN TravelCards AS tc ON c.Id = tc.ColonistId
WHERE JobDuringJourney = 'Pilot'
ORDER BY c.Id

--T07 Count colonists

SELECT COUNT(*) AS [count]
FROM Colonists AS c
JOIN TravelCards AS tc ON c.Id = tc.ColonistId
JOIN Journeys AS j ON tc.JourneyId = j.Id
WHERE j.Purpose = 'Technical'

--T08 Select spaceships with pilots younger than 30 years

SELECT s.[Name]
, s.Manufacturer 
FROM Colonists AS c
JOIN TravelCards AS tc ON c.Id = tc.ColonistId
JOIN Journeys AS j ON tc.JourneyId = j.Id
JOIN Spaceships AS s ON j.SpaceshipId = s.Id
WHERE c.BirthDate > '1989/01/01' AND c.BirthDate < '2019/01/01' AND tc.JobDuringJourney = 'Pilot' 
ORDER BY s.[Name]

--T09 Select all planets and their journey count

SELECT p.[Name] AS [PlanetName]
, COUNT(j.Id) AS [JourneysCount]
FROM Planets AS p
JOIN Spaceports AS sp ON p.Id =sp.PlanetId
JOIN Journeys AS j ON sp.Id = j.DestinationSpaceportId
GROUP BY p.[Name]
ORDER BY JourneysCount DESC, p.[Name]

--T10 Select Second Oldest Important Colonist

SELECT * FROM
(SELECT tc.JobDuringJourney
, CONCAT(FirstName, ' ', LastName) AS [FullName] 
, DENSE_RANK() OVER(PARTITION BY tc.JobDuringJourney ORDER BY c.BirthDate) AS [JobRank]
FROM Colonists AS c
JOIN TravelCards AS tc ON c.Id = tc.ColonistId) AS temp
WHERE temp.JobRank = 2

--Section 4. Programmability

--T11 Get Colonists Count

GO

CREATE OR ALTER FUNCTION udf_GetColonistsCount(@PlanetName VARCHAR (30)) 
RETURNS INT
AS
BEGIN
RETURN (SELECT COUNT(c.Id) 
FROM Planets AS p
JOIN Spaceports AS sp ON p.Id = sp.PlanetId
JOIN Journeys AS j ON sp.Id = j.DestinationSpaceportId
JOIN TravelCards AS tc ON j.Id = tc.JourneyId
JOIN Colonists AS c ON tc.ColonistId = c.Id
WHERE p.[Name] = @PlanetName)
END

GO

SELECT dbo.udf_GetColonistsCount('Otroyphus')

--T12 Change Journey Purpose

GO

CREATE OR ALTER PROC usp_ChangeJourneyPurpose(@JourneyId INT, @NewPurpose VARCHAR(11))
AS
BEGIN
DECLARE @PurposeToChange VARCHAR(MAX)= (SELECT Purpose FROM Journeys
WHERE Id = @JourneyId)
IF @JourneyId NOT IN (SELECT Id FROM Journeys)
BEGIN
RAISERROR('The journey does not exist!', 16,1)
END
IF @NewPurpose = (SELECT Purpose FROM Journeys
WHERE Id = @JourneyId)
BEGIN
RAISERROR('You cannot change the purpose!', 16,2)
END
UPDATE Journeys
SET Purpose = @NewPurpose
WHERE Id = @JourneyId
END

EXEC usp_ChangeJourneyPurpose 4, 'Technical'
EXEC usp_ChangeJourneyPurpose 2, 'Educational' --You cannot change the purpose!
EXEC usp_ChangeJourneyPurpose 196, 'Technical' --The journey does not exist!

