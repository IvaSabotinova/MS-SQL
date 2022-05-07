--T01
CREATE DATABASE Minions

--T02
USE Minions
CREATE TABLE Minions
(
Id INT PRIMARY KEY,
[Name] VARCHAR(30),
Age INT
)

CREATE TABLE Towns
(
Id INT PRIMARY KEY,
[Name] VARCHAR(30)
)

--T03
ALTER TABLE Minions
ADD TownId INT

ALTER TABLE Minions
ADD FOREIGN KEY (TownId) REFERENCES Towns(Id) 

--T04
INSERT INTO Towns (Id, [Name]) VALUES
(1, 'Sofia'),
(2, 'Plovdiv'),
(3, 'Varna')

INSERT INTO Minions (Id, [Name], Age, TownId) VALUES
(1, 'Kevin', 22, 1),
(2, 'Bob', 15, 3),
(3, 'Steward', NULL, 2)

--T05
DELETE FROM Minions

--T06
DROP TABLE Minions
DROP TABLE Towns

--T07
CREATE TABLE People
(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR (200) NOT NULL, 
Picture VARBINARY (MAX),
Height FLOAT(2),
[Weight] FLOAT (2),
Gender CHAR(1) NOT NULL,
Birthdate DATETIME NOT NULL,
Biography NVARCHAR(MAX)
)

INSERT INTO People ([Name], Height, [Weight], Gender, Birthdate, Biography) VALUES
('Pesho', 1.80, 70.00, 'm', 01/01/2001, 'Peshos Biography'),
('Gosho', 1.81, 71.00, 'm', 05/06/1989, 'Goshos Biography'),
('Sako', 1.82, 72.00, 'f', 03/03/1999, 'Sakos Biography'),
('Maimun', 1.83, 73.00, 'm', 08/08/1996, 'Maimuns Biography'),
('Paco', 1.85, 75.00, 'f', 08/09/1997, 'Pacos Biography')
















