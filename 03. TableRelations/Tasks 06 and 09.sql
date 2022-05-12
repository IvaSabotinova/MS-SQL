
CREATE DATABASE University

USE University

--T06 University Database

CREATE TABLE Majors
(
MajorID INT PRIMARY KEY IDENTITY NOT NULL,
[Name] VARCHAR (50)
)

CREATE TABLE Students
(
StudentID INT PRIMARY KEY IDENTITY NOT NULL,
StudentNumber INT NOT NULL,
StudentName VARCHAR (50) NOT NULL,
MajorID INT FOREIGN KEY REFERENCES Majors(MajorID)
)

CREATE TABLE Payments
(
PaymentID INT PRIMARY KEY IDENTITY,
PaymentDate DATE,
PaymentAmount DECIMAL (20,2),
StudentID INT FOREIGN KEY REFERENCES Students(StudentID)
)

CREATE TABLE Subjects
(
SubjectID INT PRIMARY KEY IDENTITY NOT NULL,
SubjectName VARCHAR(50)
)

CREATE TABLE Agenda
(
StudentID INT FOREIGN KEY REFERENCES Students (StudentID),
SubjectID INT FOREIGN KEY REFERENCES Subjects (SubjectID)

CONSTRAINT PK_Students_Subjects PRIMARY KEY (StudentID, SubjectID)
)

USE Geography

--T09 *Peaks in Rila

SELECT m.MountainRange, p.PeakName, p.Elevation FROM Mountains AS m
JOIN Peaks AS p ON p.MountainId = m.Id
WHERE m.MountainRange = 'Rila'
ORDER BY p.Elevation DESC