CREATE DATABASE Bitbucket
USE Bitbucket

--Section 1. DDL

--T01 Database Design

CREATE TABLE Users
(
Id INT PRIMARY KEY IDENTITY,
Username VARCHAR(30) NOT NULL,
[Password] VARCHAR(30) NOT NULL,
Email VARCHAR(50) NOT NULL
)

CREATE TABLE Repositories
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL,
)

CREATE TABLE RepositoriesContributors
(
RepositoryId INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL,
ContributorId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL,
PRIMARY KEY (RepositoryId, ContributorId)
)

CREATE TABLE Issues
(
Id INT PRIMARY KEY IDENTITY,
Title VARCHAR(255) NOT NULL,
IssueStatus VARCHAR(6) NOT NULL,
RepositoryId INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL,
AssigneeId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL
)

CREATE TABLE Commits
(
Id INT PRIMARY KEY IDENTITY,
[Message] VARCHAR(255) NOT NULL,
IssueId INT FOREIGN KEY REFERENCES Issues(Id),
RepositoryId INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL,
ContributorId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL
)

CREATE TABLE Files
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(100) NOT NULL,
Size DECIMAL (18,2) NOT NULL,
ParentId INT FOREIGN KEY REFERENCES Files(Id),
CommitId INT FOREIGN KEY REFERENCES Commits(Id) NOT NULL
)

--Section 2. DML

--T02 Insert

INSERT INTO Files VALUES
('Trade.idk',	2598.0,	1,	1),
('menu.net',	9238.31,	2,	2),
('Administrate.soshy',	1246.93,	3,	3),
('Controller.php',	7353.15,	4,	4),
('Find.java',	9957.86,	5,	5),
('Controller.json',	14034.87,	3,	6),
('Operate.xix',	7662.92,	7,	7)

INSERT INTO Issues VALUES
('Critical Problem with HomeController.cs file',	'open',	1,	4),
('Typo fix in Judge.html',	'open',	4,	3),
('Implement documentation for UsersService.cs',	'closed', 8	,2),
('Unreachable code in Index.cs','open',	9,	8)

--T03 Update

UPDATE Issues
SET IssueStatus  ='closed'
WHERE AssigneeId = 6

--T04 Delete

DELETE FROM RepositoriesContributors
WHERE RepositoryId = (SELECT Id FROM Repositories
WHERE [Name] = 'Softuni-Teamwork')

DELETE FROM Issues
WHERE RepositoryId = (SELECT Id FROM Repositories
WHERE [Name] = 'Softuni-Teamwork')

--Section 3. Querying

--T05 Commits

SELECT Id, Message, RepositoryId, ContributorId FROM Commits
ORDER BY Id, [Message], RepositoryId, ContributorId

--T06 Front-end

SELECT Id, [Name], Size FROM Files
WHERE Size > 1000 AND [Name] LIKE '%html%'
ORDER BY Size DESC, Id, [Name]

--T07 Issue Assignment

SELECT i.Id
, CONCAT(u.Username, ' : ', i.Title) AS [IssueAssignee] 
FROM Issues AS i
JOIN Users AS u ON i.AssigneeId = u.Id
ORDER BY i.Id DESC, i.AssigneeId

--T08 Single Files

SELECT Id
, [Name]
, CONCAT(CONVERT(VARCHAR, Size), 'KB') AS [Size] 
FROM Files
WHERE Id NOT IN (SELECT ParentId FROM Files
WHERE ParentId IS NOT NULL)
ORDER BY Id, [Name], Size DESC

--ANOTHER SOLUTION

SELECT f2.Id
, f2.[Name]
, CONCAT(CONVERT(VARCHAR, f2.Size), 'KB') AS [Size]
FROM Files  AS f1
RIGHT JOIN Files AS f2 ON f1.ParentId  = f2.Id
WHERE f1.ParentId IS NULL
ORDER BY f2.Id,  f2.[Name], f2.Size DESC

--T09 Commits in Repositories

SELECT TOP 5 r.Id
, r.[Name]
, COUNT(c.Id) AS [Commits] 
FROM Commits AS c
JOIN Repositories AS r ON c.RepositoryId = r.Id
JOIN RepositoriesContributors AS rc ON r.Id = rc.RepositoryId
GROUP BY r.Id, r.[Name]
ORDER BY Commits DESC, r.Id, r.[Name]

--T10 Average Size

SELECT u.Username
, AVG(f.Size) AS [Size]
FROM Users AS u
JOIN Commits AS c ON u.Id = c.ContributorId
JOIN Files AS f ON c.Id = f.CommitId
GROUP BY u.Username
ORDER BY Size DESC, u.Username

--Section 4. Programmability (20 pts)

--T11 All User Commits

GO

CREATE OR ALTER FUNCTION udf_AllUserCommits(@username VARCHAR(30)) 
RETURNS INT
AS
BEGIN
RETURN (SELECT COUNT(*) 
FROM Users AS u
JOIN Commits AS c ON u.Id = c.ContributorId
WHERE u.Username =@username
)
END

GO

SELECT dbo.udf_AllUserCommits('BlaImmagiIana')

--T12 Search for Files

GO

CREATE OR ALTER PROC usp_SearchForFiles(@fileExtension VARCHAR(70))
AS
BEGIN
SELECT Id, [Name], CONCAT(Size, 'KB') AS [Size] FROM Files
WHERE CHARINDEX(CONCAT('.', @fileExtension), [Name]) <> 0
ORDER BY Id, [Name], Size DESC
END

GO

EXEC usp_SearchForFiles 'txt'