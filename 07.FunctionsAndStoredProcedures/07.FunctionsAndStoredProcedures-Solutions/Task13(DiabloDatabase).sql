USE Diablo

--T13 *Scalar Function: Cash in User Games Odd Rows

GO

CREATE OR ALTER FUNCTION ufn_CashInUsersGames(@gameName VARCHAR(100))
RETURNS TABLE AS
RETURN
(SELECT SUM(fr.SingleCash) AS SumCash FROM
(SELECT Cash AS SingleCash,
ROW_NUMBER() OVER(ORDER BY ug.Cash DESC) AS RowNumbers FROM Games AS g
JOIN UsersGames AS ug ON g.Id = ug.GameId
WHERE g.[Name] = @gameName) AS fr
WHERE fr.RowNumbers % 2 != 0)

GO

SELECT * FROM dbo.ufn_CashInUsersGames('Love in a mist')
