--T01 Create Database

CREATE DATABASE Minions

--T02 Create Tables

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

--T03 Alter Minions Table

ALTER TABLE Minions
ADD TownId INT

ALTER TABLE Minions
ADD FOREIGN KEY (TownId) REFERENCES Towns(Id) 

--T04 Insert Records in Both Tables

INSERT INTO Towns (Id, [Name]) VALUES
(1, 'Sofia'),
(2, 'Plovdiv'),
(3, 'Varna')

INSERT INTO Minions (Id, [Name], Age, TownId) VALUES
(1, 'Kevin', 22, 1),
(2, 'Bob', 15, 3),
(3, 'Steward', NULL, 2)

--T05 Truncate Table Minions

DELETE FROM Minions

--T06 Drop All Tables
DROP TABLE Minions
DROP TABLE Towns

--T07 Create Table People

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

--T08 Create Table Users

CREATE TABLE Users
(
Id BIGINT PRIMARY KEY IDENTITY,
Username VARCHAR (30) UNIQUE NOT NULL,
[Password] VARCHAR(26) NOT NULL,
ProfilePicture VARBINARY(MAX),
LastLoginTime DATETIME,
IsDeleted BIT
)

INSERT INTO Users (Username, [Password], LastLoginTime, IsDeleted) VALUES
('Pesho', 'peshoto', 07/05/1999, 0),
('Gosho', 'goshoto', 08/05/2002, 0),
('Mina', 'minata', 03/03/1999, 1),
('Kina', 'kinata', 07/05/1997, 0),
('Vasha', 'vashata', 06/08/1998, 1)


--T09 Change Primary Key

ALTER TABLE Users
DROP CONSTRAINT PK__Users__3214EC077A117E85

ALTER TABLE Users
ADD CONSTRAINT PK_IdUsername PRIMARY KEY (Id, Username)

--T10 Add Check Constraint

ALTER TABLE Users
ADD  CONSTRAINT CH_PasswordLen CHECK (LEN([Password]) >= 5) 

--T11 Set Default Value of a Field

ALTER TABLE Users
ADD CONSTRAINT df_LastLoginTime DEFAULT GETDATE() FOR LastLoginTime;

--T12 Set Unique Field

ALTER TABLE Users
DROP CONSTRAINT PK_IdUsername

ALTER TABLE Users
ADD CONSTRAINT PK_Id PRIMARY KEY (Id)

ALTER TABLE Users
ADD CONSTRAINT CH_Username CHECK (LEN(Username)>=3)

