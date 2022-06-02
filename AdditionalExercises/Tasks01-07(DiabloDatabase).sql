USE Diablo

--T01 Number of Users for Email Provider

SELECT ep.[Email Provider], COUNT(ep.[Email Provider]) AS [Number Of Users] FROM
(SELECT SUBSTRING(Email, CHARINDEX('@', Email, 1) +1, LEN(Email)-CHARINDEX('@', Email, 1)) AS [Email Provider] 
FROM Users) AS ep
GROUP BY ep.[Email Provider]
ORDER BY [Number Of Users] DESC, ep.[Email Provider]

--T02 All Users in Games

SELECT g.[Name] AS [Game]
, gt.[Name] AS [Game Type]
, u.Username
, ug.[Level]
, ug.Cash
, c.[Name] AS [Character]
FROM Users AS u
JOIN UsersGames AS ug ON u.Id = ug.UserId
JOIN Characters AS c ON ug.CharacterId = c.Id
JOIN Games AS g ON ug.GameId = g.Id
JOIN GameTypes AS gt ON g.GameTypeId = gt.Id
ORDER BY ug.[Level] DESC, u.Username, g.[Name]

--T03 Users in Games with Their Items

SELECT u.Username
, g.[Name] AS [Game]
, COUNT(i.Id) AS [Items Count]
, SUM(i.Price) AS [Items Price]
FROM Users AS u
JOIN UsersGames AS ug ON u.Id=ug.UserId
JOIN Games AS g ON ug.GameId = g.Id
JOIN UserGameItems AS ugi ON ug.Id = ugi.UserGameId
JOIN Items AS i ON ugi.ItemId = i.Id
GROUP BY u.Username, G.[Name]
HAVING COUNT(i.Id) >=10
ORDER BY [Items Count] DESC, [Items Price] DESC, Username

--T04 *User in Games with Their Statistics

SELECT u.Username, 
g.[Name] AS [Game]
, MAX(c.[Name]) AS [Character]
, SUM(sta.Strength)+MAX(st.Strength)+MAX(s.Strength) AS [Strength]
, SUM(sta.Defence)+MAX(st.Defence)+MAX(s.Defence) AS [Defence]
, SUM(sta.Speed)+MAX(st.Speed)+MAX(s.Speed) AS [Speed]
, SUM(sta.Mind)+MAX(st.Mind)+MAX(s.Mind) AS [Mind]
, SUM(sta.Luck)+MAX(st.Luck)+MAX(s.Luck) AS [Luck]
FROM Users AS u
JOIN UsersGames AS ug ON u.Id = ug.UserId
JOIN Characters AS c ON ug.CharacterId = c.Id
JOIN [Statistics] AS s ON c.StatisticId = s.Id
JOIN Games AS g ON ug.GameId = g.Id
JOIN GameTypes AS gt ON g.GameTypeId = gt.Id
JOIN [Statistics]  AS st ON gt.BonusStatsId = st.Id
JOIN UserGameItems AS ugi ON ug.Id = ugi.UserGameId
JOIN Items AS i ON i.Id = ugi.ItemId
JOIN [Statistics] AS sta ON i.StatisticId = sta.Id
GROUP BY u.Username, g.[Name]
ORDER BY Strength DESC, Defence DESC, Speed DESC, Mind DESC, Luck DESC

--T05 All Items with Greater than Average Statistics

SELECT i.[Name], i.[Price], i.[MinLevel], s.[Strength], s.[Defence], s.[Speed], s.[Luck], s.[Mind]
FROM [Items] AS i
JOIN [Statistics] AS s ON i.StatisticId = s.Id
WHERE s.[Mind] > (SELECT AVG([Mind]) FROM [Statistics]) AND s.[Luck] > (SELECT AVG([Luck]) FROM [Statistics]) AND s.[Speed] > (SELECT AVG([Speed]) FROM [Statistics])
ORDER BY i.[Name]

--T06 Display All Items with Information about Forbidden Game Type

SELECT i.[Name], i.Price, i.MinLevel, gt.[Name] FROM Items AS i
LEFT JOIN GameTypeForbiddenItems AS gtfi ON i.Id = gtfi.ItemId
LEFT JOIN GameTypes AS gt ON gtfi.GameTypeId = gt.Id
ORDER BY gt.[Name] DESC,i.[Name]

--T07 Buy Items for User in Game

--NOT WORKING IN JUDGE, WORKING LOCALLY

SELECT Id FROM Items WHERE [Name] IN ('Blackguard', 'Bottomless Potion of Amplification', 'Eye of Etlich (Diablo III)', 'Gem of Efficacious Toxin', 'Golden Gorget of Leoric', 'Hellfire Amulet') --51, 71, 157, 184, 197, 223

SELECT ug.Id FROM Users AS u 
JOIN UsersGames AS ug ON u.Id = ug.UserId 
JOIN Games AS g ON ug.GameId = g.Id 
WHERE Username = 'Alex' AND g.[Name] = 'Edinburgh'

GO

CREATE OR ALTER PROC usp_BuyItemsForGameAndUser(@UserName NVARCHAR(50), @GameName NVARCHAR(50), @ItemName NVARCHAR(50))
AS
BEGIN TRANSACTION
DECLARE @AvailableCash MONEY = (SELECT Cash FROM Users AS u JOIN UsersGames AS ug ON u.Id = ug.UserId JOIN Games AS g ON ug.GameId = g.Id WHERE Username = @UserName AND g.[Name] = @GameName)
DECLARE @ItemPrice MONEY = (SELECT Price FROM Items WHERE [Name] = @ItemName)
DECLARE @UserGameId INT = (SELECT ug.Id FROM Users AS u JOIN UsersGames AS ug ON u.Id = ug.UserId JOIN Games AS g ON ug.GameId = g.Id WHERE u.Username = @UserName AND g.[Name] = @GameName)
DECLARE @ItemId INT = (SELECT Id FROM Items WHERE [Name] = @ItemName)

IF @AvailableCash < @ItemPrice
BEGIN
	ROLLBACK
	RETURN
END

BEGIN
UPDATE UsersGames
SET Cash -= @ItemPrice
WHERE Id = @UserGameId

INSERT INTO UserGameItems VALUES
(@ItemId, @UserGameId)
END
COMMIT

SELECT * FROM UserGameItems AS ugi
JOIN Items AS i ON ugi.ItemId = i.Id
WHERE ugi.UserGameId= 235


EXEC usp_BuyItemsForGameAndUser 'Alex', 'Edinburgh', 'Blackguard'
EXEC usp_BuyItemsForGameAndUser 'Alex', 'Edinburgh', 'Bottomless Potion of Amplification'
EXEC usp_BuyItemsForGameAndUser 'Alex', 'Edinburgh', 'Eye of Etlich (Diablo III)'
EXEC usp_BuyItemsForGameAndUser 'Alex', 'Edinburgh', 'Gem of Efficacious Toxin'
EXEC usp_BuyItemsForGameAndUser 'Alex', 'Edinburgh', 'Golden Gorget of Leoric'
EXEC usp_BuyItemsForGameAndUser 'Alex', 'Edinburgh', 'Hellfire Amulet'

SELECT u.Username, g.[Name],ug.Cash, i.[Name] FROM Users AS u
JOIN UsersGames AS ug ON u.Id = ug.UserId
JOIN Games AS g ON ug.GameId = g.Id
JOIN UserGameItems AS ugi ON ug.Id = ugi.UserGameId
JOIN Items AS i ON ugi.ItemId = i.Id
WHERE g.Name = 'Edinburgh'
ORDER BY i.[Name]

--ANOTHER SOLUTION WORKING IN JUDGE SYSTEM

SELECT Id FROM Items
WHERE [Name] IN ('Blackguard', 'Bottomless Potion of Amplification', 'Eye of Etlich (Diablo III)', 'Gem of Efficacious Toxin', 'Golden Gorget of Leoric', 'Hellfire Amulet') --51, 71, 157, 184, 197, 223

SELECT ug.Id FROM Users AS u
JOIN UsersGames AS ug ON u.Id = ug.UserId
JOIN Games AS g ON ug.GameId = g.Id
WHERE Username = 'Alex' AND g.[Name] = 'Edinburgh' --235

DECLARE @AvailableCash1 MONEY = (Select Cash FROM Users AS u JOIN UsersGames AS ug ON u.Id = ug.UserId JOIN Games AS g ON ug.GameId = g.Id WHERE Username = 'Alex' AND g.[Name] = 'Edinburgh')
DECLARE @ItemsPrice MONEY = (SELECT SUM(Price) FROM Items WHERE [Name] IN ('Blackguard', 'Bottomless Potion of Amplification', 'Eye of Etlich (Diablo III)', 'Gem of Efficacious Toxin', 'Golden Gorget of Leoric', 'Hellfire Amulet'))
DECLARE @UserGameId1 INT = (SELECT ug.Id FROM Users AS u JOIN UsersGames AS ug ON u.Id = ug.UserId JOIN Games AS g ON ug.GameId = g.Id WHERE Username = 'Alex' AND g.[Name] = 'Edinburgh')

BEGIN TRANSACTION

IF @AvailableCash1 >= @ItemsPrice

BEGIN

UPDATE UsersGames
SET Cash -= @ItemsPrice
WHERE Id = @UserGameId1

INSERT INTO UserGameItems VALUES
((SELECT Id FROM Items WHERE [Name] = 'Blackguard'), @UserGameId1),
((SELECT Id FROM Items WHERE [Name] = 'Bottomless Potion of Amplification'), @UserGameId1),
((SELECT Id FROM Items WHERE [Name] = 'Eye of Etlich (Diablo III)'), @UserGameId1),
((SELECT Id FROM Items WHERE [Name] = 'Gem of Efficacious Toxin'), @UserGameId1),
((SELECT Id FROM Items WHERE [Name] = 'Golden Gorget of Leoric'), @UserGameId1),
((SELECT Id FROM Items WHERE [Name] = 'Hellfire Amulet'), @UserGameId1)
END
COMMIT

SELECT u.Username
, g.[Name]
, ug.Cash
, i.[Name] AS [Item Name]
FROM Users AS u
JOIN UsersGames AS ug ON u.Id = ug.UserId
JOIN Games AS g ON ug.GameId = g.Id
JOIN UserGameItems AS ugi ON ug.Id = ugi.UserGameId
JOIN Items AS i ON ugi.ItemId = i.Id
WHERE g.[Name] = 'Edinburgh'
ORDER BY i.[Name]