USE Diablo

--T06 Trigger

--6.1
GO

CREATE OR ALTER TRIGGER tr_AddItemsWithLowerLevel
	ON UserGameItems INSTEAD OF INSERT
	AS
	DECLARE @ItemId INT = (SELECT ItemId FROM inserted)
	DECLARE @UserGameId INT = (SELECT UserGameId FROM inserted)

	DECLARE @ItemLevel INT = (SELECT MinLevel FROM Items WHERE Id = @ItemId)
	DECLARE @UserLevel INT = (SELECT [Level] FROM UsersGames WHERE Id = @UserGameId)

	BEGIN TRANSACTION
	
	IF @ItemLevel > @UserLevel
	BEGIN
		ROLLBACK
		RETURN		
	END
	INSERT INTO UserGameItems VALUES
	(@ItemId, @UserGameId)
	COMMIT
	

	SELECT * FROM UsersGames
	WHERE Id = 2 --Level 30 user level

	SELECT * FROM Items
	WHERE Id = 2 --MinLevel 46

	
INSERT INTO UserGameItems VALUES
(2, 2)

SELECT * FROM UserGameItems
WHERE ItemId = 2

--6.2 

SELECT * FROM UsersGames
WHERE UserId IN (SELECT Id FROM Users
				WHERE Username IN ('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid','monoxidecos')) 
				AND GameId = (SELECT Id FROM Games
								WHERE [Name] = 'Bali')

UPDATE UsersGames
SET Cash += 50000
WHERE UserId IN (SELECT Id FROM Users
				WHERE Username IN ('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid','monoxidecos')) 
				AND GameId = (SELECT Id FROM Games
								WHERE [Name] = 'Bali')

--6.3

GO

CREATE OR ALTER PROC usp_BuyItems (@ItemIdToBuy INT, @UserIdWhoBuyes INT, @GameId INT)
AS
BEGIN TRANSACTION
DECLARE @CurrentUserCash MONEY = (SELECT Cash FROM UsersGames WHERE UserId = @UserIdWhoBuyes AND GameId = @GameId)
DECLARE @CurrentItemPrice MONEY = (SELECT Price FROM Items WHERE Id = @ItemIdToBuy)
IF @CurrentUserCash < @CurrentItemPrice
BEGIN
	ROLLBACK;
	RAISERROR('Insufficient funds', 16,2)
	RETURN
END
	UPDATE UsersGames
	SET Cash -= @CurrentItemPrice
	WHERE UserId = @UserIdWhoBuyes
		AND GameId = @GameId


	INSERT INTO UserGameItems VALUES
	(@ItemIdToBuy, (SELECT Id FROM UsersGames WHERE UserId = @UserIdWhoBuyes AND GameId = @GameId))

COMMIT


SELECT Id FROM Users WHERE Username IN ('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos') --12, 22, 37, 52, 61 (Cash: 57560.00, 56465.00, 56184.00, 57314.00, 58022.00)

SELECT Id FROM Games WHERE [Name] = 'Bali' --212

SELECT * FROM UsersGames WHERE UserId IN (12,22,37,52,61) AND GameId = 212

DECLARE @ItemIdGroup1 INT = 251;

WHILE @ItemIdGroup1 <= 299
BEGIN
	EXEC usp_BuyItems @ItemIdGroup1, 12, 212
	EXEC usp_BuyItems @ItemIdGroup1, 22, 212
	EXEC usp_BuyItems @ItemIdGroup1, 37, 212
	EXEC usp_BuyItems @ItemIdGroup1, 52, 212
	EXEC usp_BuyItems @ItemIdGroup1, 61, 212
SET @ItemIdGroup1 += 1
END


DECLARE @ItemIdGroup2 INT = 501

WHILE @ItemIdGroup2 <= 539
BEGIN
	EXEC usp_BuyItems @ItemIdGroup2, 12, 212
	EXEC usp_BuyItems @ItemIdGroup2, 22, 212
	EXEC usp_BuyItems @ItemIdGroup2, 37, 212
	EXEC usp_BuyItems @ItemIdGroup2, 52, 212
	EXEC usp_BuyItems @ItemIdGroup2, 61, 212
SET @ItemIdGroup2 += 1
END

--6.4

SELECT u.Username, g.[Name], ug.Cash, i.[Name] AS [Item Name] FROM Games AS g
JOIN UsersGames AS ug ON g.Id = ug.GameId
JOIN Users AS u ON u.Id = ug.UserId
JOIN UserGameItems AS ugi ON ugi.UserGameId = ug.Id
JOIN Items AS i ON i.Id = ugi.ItemId
WHERE g.[Name] = 'Bali'
ORDER BY u.Username, i.[Name]


--T07 *Massive Shopping

SELECT Id FROM Users
WHERE Username = 'Stamat' --Id = 9

SELECT Id FROM Games
WHERE [Name] = 'Safflower' --Id = 87


SELECT Cash FROM UsersGames
WHERE UserId = (SELECT Id FROM Users WHERE Username = 'Stamat') 
			AND GameId = (SELECT Id FROM Games WHERE [Name] = 'Safflower') --Cash = 6266.00, Id = 110

SELECT Id, Price FROM Items
WHERE MinLevel >= 11 AND MinLevel <=12

SELECT Id, Price FROM Items
WHERE MinLevel >=19 AND MinLevel <=21
-------------------------------------------------------------------------------------


DECLARE @StamatId INT = (SELECT Id FROM Users WHERE Username = 'Stamat') 
DECLARE @GameSafflowerId INT = (SELECT Id FROM Games WHERE [Name] = 'Safflower')
DECLARE @AvailableCash MONEY = (SELECT Cash FROM UsersGames WHERE UserId = (SELECT Id FROM Users WHERE Username = 'Stamat') AND GameId = (SELECT Id FROM Games WHERE [Name] = 'Safflower'))
DECLARE @TotalPriceItemsWithLevel11_12 MONEY = (SELECT Sum(Price) FROM Items WHERE MinLevel BETWEEN 11 AND 12)
DECLARE @StamatSafflowerUserGameId INT = (SELECT Id FROM UsersGames WHERE UserId = (SELECT Id FROM Users WHERE Username = 'Stamat')  AND GameId = (SELECT Id FROM Games WHERE [Name] = 'Safflower'))


BEGIN TRANSACTION
--IF @AvailableCash < @TotalPriceItemsWithLevel11_12
--BEGIN
--	ROLLBACK
--	RETURN
--END
IF @AvailableCash >= @TotalPriceItemsWithLevel11_12
BEGIN
	UPDATE UsersGames
	SET Cash -= @TotalPriceItemsWithLevel11_12
	WHERE UserId = @StamatId AND GameId = @GameSafflowerId

	INSERT INTO UserGameItems (ItemId, UserGameId)
	SELECT Id, @StamatSafflowerUserGameId FROM Items WHERE MinLevel BETWEEN 11 AND 12
END
COMMIT


--USING TRY CATCH BLOCK - NOT WORKING IN JUDGE SYSTEM, BUT WORKING LOCALLY

--BEGIN TRY
--BEGIN TRANSACTION
--IF @AvailableCash < @TotalPriceItemsWithLevel11_12
--BEGIN
--	ROLLBACK;
--	THROW 50001,'Not enough money', 2
--END
--IF @AvailableCash >= @TotalPriceItemsWithLevel11_12
--BEGIN
--	UPDATE UsersGames
--	SET Cash -= @TotalPriceItemsWithLevel11_12
--	WHERE UserId = @StamatId AND GameId = @GameSafflowerId

--	INSERT INTO UserGameItems (ItemId, UserGameId)
--	SELECT Id, @StamatSafflowerUserGameId FROM Items WHERE MinLevel BETWEEN 11 AND 12
--END
--COMMIT
--END TRY
--BEGIN CATCH
--	SELECT ERROR_MESSAGE()
--END CATCH



DECLARE @StamatId1 INT = (SELECT Id FROM Users WHERE Username = 'Stamat')
DECLARE @GameSafflowerId1 INT = (SELECT Id FROM Games WHERE [Name] = 'Safflower')
DECLARE @AvailableCash1 MONEY = (SELECT Cash FROM UsersGames WHERE UserId = (SELECT Id FROM Users WHERE Username = 'Stamat') AND GameId = (SELECT Id FROM Games WHERE [Name] = 'Safflower'))
DECLARE @TotalPriceItemsWithLevel19To21 MONEY= (SELECT Sum(Price) FROM Items WHERE MinLevel BETWEEN 19 AND 21)
DECLARE @StamatSafflowerUserGameId1 INT = (SELECT Id FROM UsersGames WHERE UserId = @StamatId1 AND GameId = @GameSafflowerId1)


BEGIN TRANSACTION
--IF @AvailableCash1 < @TotalPriceItemsWithLevel19To21
--BEGIN
--	ROLLBACK
--	RETURN
--END
IF @AvailableCash1 >= @TotalPriceItemsWithLevel19To21
BEGIN
	UPDATE UsersGames
	SET Cash -= @TotalPriceItemsWithLevel19To21
	WHERE UserId = @StamatId1 AND GameId = @GameSafflowerId1

	INSERT INTO UserGameItems (ItemId, UserGameId)
	SELECT Id, @StamatSafflowerUserGameId1 FROM Items WHERE MinLevel BETWEEN 19 AND 21
END
COMMIT

--USING TRY CATCH BLOCK - NOT WORKING IN JUDGE SYSTEM, BUT WORKING LOCALLY

--BEGIN TRY
--BEGIN TRANSACTION
--IF @AvailableCash1 < @TotalPriceItemsWithLevel19To21
--BEGIN
--	ROLLBACK;
--	THROW 50001,'Not enough money', 2
--END
--IF @AvailableCash1 >= @TotalPriceItemsWithLevel19To21
--BEGIN
--	UPDATE UsersGames
--	SET Cash -= @TotalPriceItemsWithLevel19To21
--	WHERE UserId = @StamatId1 AND GameId = @GameSafflowerId1

--	INSERT INTO UserGameItems (ItemId, UserGameId)
--	SELECT Id, @StamatSafflowerUserGameId1 FROM Items WHERE MinLevel BETWEEN 19 AND 21
--END
--COMMIT
--END TRY
--BEGIN CATCH
--	SELECT ERROR_MESSAGE()
--END CATCH


DECLARE @StamatSafflowerUserGameIdNew INT = (SELECT Id FROM UsersGames WHERE UserId = (SELECT Id FROM Users WHERE Username = 'Stamat') 
									AND GameId = (SELECT Id FROM Games WHERE [Name] = 'Safflower'))
							
SELECT i.[Name] AS [Item Name] FROM UserGameItems AS ugi
JOIN Items AS i ON ugi.ItemId = i.Id
WHERE UserGameId = @StamatSafflowerUserGameIdNew
ORDER BY i.[Name]





