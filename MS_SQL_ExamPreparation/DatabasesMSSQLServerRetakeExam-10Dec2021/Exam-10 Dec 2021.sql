

--Section 1. DDL 

CREATE DATABASE Airport

--T01 Database design

CREATE TABLE Passengers
(
Id INT PRIMARY KEY IDENTITY,
FullName VARCHAR(100) UNIQUE NOT NULL,
Email VARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Pilots
(
Id INT PRIMARY KEY IDENTITY,
FirstName VARCHAR(30) UNIQUE NOT NULL,
LastName VARCHAR(30) UNIQUE NOT NULL,
Age TINYINT NOT NULL CHECK (Age >= 21 AND Age <=62),
Rating FLOAT(53) CHECK (Rating >= 0.0 AND Rating <= 10.0)
)

CREATE TABLE AircraftTypes
(
Id INT PRIMARY KEY IDENTITY,
TypeName VARCHAR(30) UNIQUE NOT NULL
)

CREATE TABLE Aircraft 
(
Id INT PRIMARY KEY IDENTITY,
Manufacturer VARCHAR(25) NOT NULL,
Model VARCHAR(30) NOT NULL,
[Year] INT NOT NULL,
FlightHours INT,
Condition CHAR(1) NOT NULL,
TypeId INT FOREIGN KEY REFERENCES AircraftTypes(Id) NOT NULL
)

CREATE TABLE PilotsAircraft
(
AircraftId INT FOREIGN KEY REFERENCES Aircraft(Id) NOT NULL,
PilotId INT FOREIGN KEY REFERENCES Pilots(Id) NOT NULL,
PRIMARY KEY (AircraftId,PilotId) 
)

CREATE TABLE Airports
(
Id INT PRIMARY KEY IDENTITY,
AirportName VARCHAR(70) UNIQUE NOT NULL,
Country VARCHAR(100) UNIQUE NOT NULL
)

CREATE TABLE FlightDestinations
(
Id INT PRIMARY KEY IDENTITY,
AirportId INT FOREIGN KEY REFERENCES Airports(Id) NOT NULL,
[Start] DATETIME NOT NULL,
AircraftId INT FOREIGN KEY REFERENCES Aircraft(Id) NOT NULL,
PassengerId INT FOREIGN KEY REFERENCES Passengers(Id) NOT NULL,
TicketPrice DECIMAL(18,2) DEFAULT 15 NOT NULL
)

--Section 2. DML

--T02 Insert

DECLARE @PilotId INT = 5

WHILE @PilotId <=15
BEGIN
INSERT INTO Passengers VALUES
((SELECT CONCAT(FirstName, ' ', LastName) FROM Pilots WHERE Id = @PilotId), (SELECT CONCAT(FirstName,LastName,'@gmail.com') FROM Pilots WHERE Id=@PilotId))
SET @PilotId += 1
END

--T03 Update

UPDATE Aircraft
SET Condition = 'A' 
WHERE (Condition = 'C' OR Condition = 'B') AND (FlightHours IS NULL OR FlightHours <=100) AND ([Year] >= 2013)

--T04 Delete

DELETE Passengers
WHERE LEN(FullName) <=10

--Section 3. Querying

--T05 Aircraft

SELECT Manufacturer, Model, FlightHours, Condition FROM Aircraft
ORDER BY FlightHours DESC

--T06 Pilots and Aircraft

SELECT p.FirstName
, p.LastName
, a.Manufacturer
, a.Model
, a.FlightHours
FROM Pilots AS p
JOIN PilotsAircraft AS pa ON p.Id = pa.PilotId
JOIN Aircraft as a ON pa.AircraftId = a.Id
WHERE a.FlightHours IS NOT NULL AND a.FlightHours <= 304
ORDER BY a.FlightHours DESC, p.FirstName

--T07 Top 20 Flight Destinations

SELECT TOP 20 fd.Id AS [DestinationId]
, fd.[Start]
, p.FullName
, a.AirportName
, fd.TicketPrice
FROM FlightDestinations AS fd
JOIN Passengers AS p ON fd.PassengerId = p.Id
JOIN Airports AS a ON fd.AirportId = a.Id
WHERE DATEPART(DAY, fd.Start) % 2 = 0
ORDER BY fd.TicketPrice DESC, a.AirportName

--T08 Number of Flights for Each Aircraft

SELECT a.Id AS [AircraftId]
, a.Manufacturer
, a.FlightHours
, COUNT(fd.Id) AS [FlightDestinationsCount]
, ROUND(AVG(fd.TicketPrice),2) AS [AvgPrice]
FROM Aircraft AS a
JOIN FlightDestinations AS fd ON a.Id = fd.AircraftId
GROUP BY a.Id, a.Manufacturer, a.FlightHours
HAVING COUNT(fd.Id) >=2
ORDER BY FlightDestinationsCount DESC, a.Id

--T09 Regular Passengers

SELECT p.FullName
, COUNT(a.Id) AS [CountOfAircraft]
, SUM(fd.TicketPrice) AS [TotalPayed]
FROM Passengers AS p
JOIN FlightDestinations AS fd ON p.Id = fd.PassengerId
JOIN Aircraft AS a ON fd.AircraftId = a.Id
WHERE p.FullName LIKE '_a%'
GROUP BY p.FullName
HAVING COUNT(a.Id) > 1
ORDER BY p.FullName

--T10 Full Info for Flight Destinations

SELECT a.AirportName
, fd.[Start] AS [DayTime]
, fd.TicketPrice
, p.FullName
, ac.Manufacturer
, ac.Model
FROM FlightDestinations AS fd
JOIN Passengers AS p ON fd.PassengerId = p.Id
JOIN Airports AS a ON fd.AirportId = a.Id
JOIN Aircraft AS ac ON fd.AircraftId = ac.Id
WHERE DATEPART(HOUR, fd.[Start]) BETWEEN 6 AND 20 AND fd.TicketPrice > 2500
ORDER BY ac.Model


--Section 4. Programmability

--T11 Find all Destinations by Email Address

GO
CREATE OR ALTER FUNCTION udf_FlightDestinationsByEmail(@email VARCHAR(50))
RETURNS INT
AS
BEGIN
RETURN (SELECT COUNT(fd.Id) FROM Passengers AS p
JOIN FlightDestinations AS fd ON p.Id = fd.PassengerId
WHERE p.Email = @email)
END
go

SELECT dbo.udf_FlightDestinationsByEmail('PierretteDunmuir@gmail.com') --1
SELECT dbo.udf_FlightDestinationsByEmail('Montacute@gmail.com') --3
SELECT dbo.udf_FlightDestinationsByEmail('MerisShale@gmail.com') --0

--T12 Full Info for Airports

GO

CREATE OR ALTER PROC usp_SearchByAirportName(@airportName VARCHAR(70))
AS
BEGIN
SELECT ap.AirportName
, p.FullName
, CASE
WHEN fd.TicketPrice <= 400 THEN 'Low'
WHEN fd.TicketPrice BETWEEN 401 AND 1500 THEN 'Medium'
WHEN fd.TicketPrice >=1501 THEN 'High'
END AS [LevelOfTickerPrice]
, ac.Manufacturer
, ac.Condition
, act.TypeName
FROM Airports AS ap
JOIN FlightDestinations AS fd ON ap.Id = fd.AirportId
JOIN Passengers AS p ON fd.PassengerId = p.Id
JOIN Aircraft AS ac ON fd.AircraftId = ac.Id
JOIN AircraftTypes AS act ON ac.TypeId = act.Id
WHERE ap.AirportName = @airportName
ORDER BY ac.Manufacturer, p.FullName
END

EXEC usp_SearchByAirportName 'Sir Seretse Khama International Airport'