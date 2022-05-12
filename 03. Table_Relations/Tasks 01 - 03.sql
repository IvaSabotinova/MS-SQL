CREATE DATABASE TableRelations
USE TableRelations


--T01 One-To-One Relationship

CREATE TABLE Passports
(
PassportID INT PRIMARY KEY IDENTITY (101,1),
PassportNumber CHAR (8) NOT NULL
)

CREATE TABLE Persons
(
PersonID INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR (30),
Salary DECIMAL (10, 2),
PassportID INT FOREIGN KEY REFERENCES Passports(PassportID) UNIQUE NOT NULL
)

INSERT INTO Passports VALUES
('N34FG21B'),
('K65LO4R7'),
('ZE657QP2')

INSERT INTO Persons VALUES
('Roberto', 43300.00, 102),
('Tom', 56100.00, 103),
('Yana', 60200.00, 101)

--T02 One-To-Many Relationship

CREATE TABLE Manufacturers
(
ManufacturerID INT PRIMARY KEY IDENTITY NOT NULL,
[Name] VARCHAR(20),
EstablishedOn DATE
)

CREATE TABLE Models
(
ModelID INT PRIMARY KEY IDENTITY (101,1) NOT NULL,
[Name] NVARCHAR (30),
ManufacturerID INT FOREIGN KEY REFERENCES Manufacturers(ManufacturerID)
)

INSERT INTO Manufacturers VALUES
('BMW','07/03/1916'),
('Tesla','01/01/2003'),
('Lada','01/05/1966')

INSERT INTO Models VALUES
('X1', 1),
('i6',1),
('Model S',2),
('Model X', 2),
('Model 3', 2),
('Nova',3)


--T03 Many-To-Many Relationship

CREATE TABLE Students
(
StudentID INT IDENTITY PRIMARY KEY,
[Name] VARCHAR(30)
)

CREATE TABLE Exams
(
ExamID INT PRIMARY KEY IDENTITY (101,1),
[Name] VARCHAR (30)
)

CREATE TABLE StudentsExams
(
StudentID INT,
ExamID INT,

CONSTRAINT PK_Students_Exams PRIMARY KEY (StudentID, ExamID),
CONSTRAINT FK_Students FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
CONSTRAINT FK_Exams FOREIGN KEY (ExamID) REFERENCES Exams(ExamID)
)

INSERT INTO Students VALUES
('Mila'),
('Toni'),
('Ron')

INSERT INTO Exams VALUES
('SpringMVC'),
('Neo4j'),
('Oracle 11g')

INSERT INTO StudentsExams VALUES
(1,101),
(1,102),
(2,101),
(3,103),
(2,102),
(2,103)
