CREATE DATABASE TripService

USE TripService
--Section 1. DDL

--T01 Database design

CREATE TABLE Cities
(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(20) NOT NULL,
CountryCode CHAR(2) NOT NULL
)

CREATE TABLE Hotels
(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(30) NOT NULL,
CityId INT FOREIGN KEY REFERENCES Cities(Id) NOT NULL,
EmployeeCount INT NOT NULL,
BaseRate DECIMAL (18,2)
)

CREATE TABLE Rooms
(
Id INT PRIMARY KEY IDENTITY,
Price DECIMAL (18,2) NOT NULL,
[Type] NVARCHAR(20) NOT NULL,
Beds INT NOT NULL,
HotelId INT FOREIGN KEY REFERENCES Hotels(Id) NOT NULL
)

CREATE TABLE Trips
(
Id INT PRIMARY KEY IDENTITY,
RoomId INT FOREIGN KEY REFERENCES Rooms(Id) NOT NULL,
BookDate DATETIME NOT NULL,
ArrivalDate DATETIME NOT NULL,
ReturnDate DATETIME NOT NULL,
CancelDate DATETIME,
CONSTRAINT CHECK_DATE1 CHECK (BookDate < ArrivalDate),
CONSTRAINT CHECK_DATE2 CHECK (ArrivalDate < ReturnDate)
)

CREATE TABLE Accounts
(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(50) NOT NULL,
MiddleName NVARCHAR(20),
LastName NVARCHAR(50) NOT NULL,
CityId INT FOREIGN KEY REFERENCES Cities(Id) NOT NULL,
BirthDate DATETIME NOT NULL,
Email NVARCHAR(100) NOT NULL
)

CREATE TABLE AccountsTrips
(
AccountId INT FOREIGN KEY REFERENCES Accounts(Id) NOT NULL,
TripId INT FOREIGN KEY REFERENCES Trips(Id) NOT NULL,
PRIMARY KEY (AccountId, TripId),
Luggage INT CHECK (Luggage >=0) NOT NULL
)

--Section 2. DML

--T02 Insert

INSERT INTO Accounts VALUES
('John','Smith', 'Smith', 34 ,'1975-07-21','j_smith@gmail.com'),
('Gosho',NULL, 'Petrov', 11 ,'1978-05-16','g_petrov@gmail.com'),
('Ivan','Petrovich', 'Pavlov', 59 ,'1849-09-26','i_pavlov@softuni.bg'),
('Friedrich','Wilhelm', 'Nietzsche', 2 ,'1844-10-15','f_nietzsche@softuni.bg')

INSERT INTO Trips VALUES
(101, '2015-04-12', '2015-04-14', '2015-04-20', '2015-02-02'),
(102, '2015-07-07',	'2015-07-15', '2015-07-22', '2015-04-29'),
(103, '2013-07-17', '2013-07-23', '2013-07-24', NULL),
(104, '2012-03-17',	'2012-03-31', '2012-04-01', '2012-01-10'),
(109, '2017-08-07',	'2017-08-28', '2017-08-29',	NULL)

--T03 Update

UPDATE Rooms
SET Price *= 1.14
WHERE HotelId IN (5,7,9)

--T04 Delete

DELETE FROM AccountsTrips
WHERE AccountId = 47

--Section 3. Querying

--T05 EEE-Mails

SELECT a.FirstName
, a.LastName
, FORMAT(a.BirthDate, 'MM-dd-yyyy') AS [BirthDate]
, c.[Name] AS [Hometown]
, a.Email
FROM Accounts AS a
JOIN Cities AS c ON a.CityId = c.Id
WHERE a.Email LIKE 'e%'
ORDER BY c.[Name]

--T06 City Statistics

SELECT c.[Name] AS [City]
, COUNT(h.Id) AS [Hotels]
FROM Cities AS c
JOIN Hotels AS h ON c.Id = h.CityId
GROUP BY c.[Name]
ORDER BY Hotels DESC, c.[Name]

--T07 Longest and Shortest Trips

SELECT a.Id AS [AccountId]
, CONCAT(a.FirstName, ' ', a.LastName) AS [FullName]
, MAX(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) AS [LongestTrip]
, MIN(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) AS [ShortestTrip] 
FROM Accounts AS a
JOIN AccountsTrips AS act ON a.Id = act.AccountId
JOIN Trips AS t ON act.TripId = t.Id
WHERE a.MiddleName IS NULL AND t.CancelDate IS NULL
GROUP BY a.Id, CONCAT(a.FirstName, ' ', a.LastName)
ORDER BY LongestTrip DESC, ShortestTrip

--T08 Metropolis

SELECT TOP 10 c.Id
, c.[Name] AS [City]
, c.CountryCode AS [Country]
, COUNT(a.Id) AS [Accounts]
FROM Cities AS c
JOIN Accounts AS a ON c.Id = a.CityId
GROUP BY c.Id, c.[Name], c.CountryCode
ORDER BY Accounts DESC

--T09 Romantic Getaways

SELECT a.Id
, a.Email
, c.[Name] AS [City]
, COUNT(t.Id) AS [Trips]
FROM Accounts AS a
JOIN AccountsTrips AS act ON a.Id = act.AccountId
JOIN Trips AS t ON act.TripId = t.Id
JOIN Rooms AS r ON t.RoomId = r.Id
JOIN Hotels AS h ON r.HotelId = h.Id
JOIN Cities AS c ON h.CityId = c.Id
WHERE a.CityId = h.CityId
GROUP BY a.Id, a.Email, c.[Name]
ORDER BY Trips DESC, a.Id

--T10 GDPR Violation

SELECT t.Id
, CONCAT(a.FirstName,' ', ISNULL(a.MiddleName + ' ', ''), a.LastName) AS [Full Name]
, c1.[Name] AS [From]
, c2.[Name] AS [To]
, CASE
WHEN t.CancelDate IS NOT NULL THEN 'Canceled'
ELSE CONCAT(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate), ' days')
END AS [Duration]
FROM Trips AS t
JOIN AccountsTrips AS act ON t.Id =act.TripId
JOIN Accounts AS a ON act.AccountId = a.Id
JOIN Cities AS c1 ON a.CityId = c1.Id
JOIN Rooms AS r ON r.Id = t.RoomId
JOIN Hotels AS h ON r.HotelId  = h.Id
JOIN Cities AS c2 ON h.CityId = c2.Id
ORDER BY [Full Name], t.Id

--Section 4. Programmability

--T11 Available Room

GO
CREATE OR ALTER FUNCTION udf_GetAvailableRoom(@HotelId INT, @Date DATETIME, @People INT)
RETURNS VARCHAR(MAX)
AS
BEGIN
DECLARE @OccupiedRooms TABLE(Id INT) 
INSERT INTO  @OccupiedRooms 
SELECT r.Id FROM Rooms AS r
JOIN Trips AS t ON r.Id = t.RoomId
WHERE r.HotelId = @HotelId AND @Date> t.ArrivalDate AND @Date < t.ReturnDate AND t.CancelDate IS NULL
RETURN
ISNULL((SELECT TOP 1
CONCAT('Room ', r.Id, ': ', r.[Type], ' (', r.Beds, ' beds) - $', (h.BaseRate + r.Price) * @People)
FROM Rooms AS r
LEFT JOIN Trips AS t ON r.Id= t.RoomId
JOIN Hotels AS h ON r.HotelId = h.Id
WHERE r.HotelId = @HotelId AND r.Beds >=  @People AND r.Id NOT IN (SELECT * FROM @OccupiedRooms)
ORDER BY (h.BaseRate + r.Price) * @People  DESC), 'No rooms available');
END

GO
SELECT dbo.udf_GetAvailableRoom(112, '2011-12-17', 2) --Room 211: First Class (5 beds) - $202.80 
SELECT dbo.udf_GetAvailableRoom(94, '2015-07-26', 3) --No rooms available

--T12 Switch Room

SELECT r.HotelId FROM Trips AS t
JOIN Rooms AS r ON t.RoomId = r.Id
WHERE t.Id=10 --6 (Trip's HotelId)

SELECT Beds FROM Rooms
WHERE Id = 11 --3 (TargetRoom Beds)

SELECT COUNT(*) 
FROM AccountsTrips
WHERE TripId = 10 --2 (Number of Trip's Accounts)

GO
CREATE OR ALTER PROC usp_SwitchRoom(@TripId INT, @TargetRoomId INT)
AS
BEGIN
DECLARE @TripHotelId  INT = (SELECT r.HotelId FROM Trips AS t
JOIN Rooms AS r ON t.RoomId = r.Id WHERE t.Id=@TripId)
DECLARE @TargetRoomHotelId INT = (SELECT HotelId FROM Rooms WHERE Id = @TargetRoomId)
DECLARE @TargetRoomBeds INT = (SELECT Beds FROM Rooms WHERE Id = @TargetRoomId)
DECLARE @NumberOfTripAccounts INT = (SELECT COUNT(*) FROM AccountsTrips 
WHERE TripId = @TripId)
IF @TripHotelId != @TargetRoomHotelId
 BEGIN
 RAISERROR ('Target room is in another hotel!' , 16,1)
 END
 IF @TargetRoomBeds < @NumberOfTripAccounts
  BEGIN
  RAISERROR ('Not enough beds in target room!', 16,2)
  END
 UPDATE Trips
 SET RoomId = @TargetRoomId
 WHERE Id  =@TripId
END

EXEC usp_SwitchRoom 10, 11

SELECT RoomId FROM Trips WHERE Id = 10 --11

EXEC usp_SwitchRoom 10, 7 --Target room is in another hotel!

EXEC usp_SwitchRoom 10, 8 -- Not enough beds in target room!

