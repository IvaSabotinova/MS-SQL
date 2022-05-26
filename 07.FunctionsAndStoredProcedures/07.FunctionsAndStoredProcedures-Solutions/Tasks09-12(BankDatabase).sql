USE Bank

--T09 Find Full Name

GO

CREATE OR ALTER PROC usp_GetHoldersFullName 
AS
BEGIN
SELECT CONCAT(FirstName, ' ', LastName) AS [Full Name]
FROM AccountHolders
END

EXEC dbo.usp_GetHoldersFullName

--T10 People with Balance Higher Than

GO
CREATE OR ALTER PROC usp_GetHoldersWithBalanceHigherThan(@amount MONEY)
AS
BEGIN
SELECT ah.FirstName, ah.LastName FROM AccountHolders AS ah
JOIN Accounts AS a ON ah.Id = a.AccountHolderId
GROUP BY ah.FirstName, ah.LastName
HAVING SUM(a.Balance) > @amount
ORDER BY ah.FirstName, ah.LastName
END

EXEC dbo.usp_GetHoldersWithBalanceHigherThan 25000

--T11 Future Value Function

GO
CREATE OR ALTER FUNCTION ufn_CalculateFutureValue (@sum DECIMAL(11,4), @interestRate FLOAT, @numberOfYears INT)
RETURNS DECIMAL (16,4)
AS
BEGIN
DECLARE @Result DECIMAL(16,4)
SET @Result = @sum * POWER((1+@interestRate), @numberOfYears)
RETURN @Result
END
GO

SELECT dbo.ufn_CalculateFutureValue (1000, 0.1, 5) AS Result

--T12 Calculating Interest

GO
CREATE OR ALTER PROC usp_CalculateFutureValueForAccount (@AccountID INT, @interestRate FLOAT)
AS
BEGIN
SELECT a.Id AS [Account Id]
, FirstName
, LastName
, a.Balance AS [Current Balance]
, dbo.ufn_CalculateFutureValue(a.Balance, @interestRate, 5) AS [Balance in 5 years]
FROM Accounts AS a
JOIN AccountHolders AS ah ON a.AccountHolderId = ah.Id
WHERE a.Id = @AccountID
END

EXEC usp_CalculateFutureValueForAccount 1, 0.1
