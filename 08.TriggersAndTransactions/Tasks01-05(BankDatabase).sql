USE Bank

--T01 Create Table Logs

CREATE TABLE Logs
(
LogId INT PRIMARY KEY IDENTITY,
AccountId INT FOREIGN KEY REFERENCES Accounts(Id),
OldSum MONEY,
NewSum MONEY
)

GO

CREATE OR ALTER TRIGGER tr_ChangedAccount
ON Accounts FOR UPDATE
AS
INSERT INTO Logs(AccountId, OldSum, NewSum)
SELECT i.Id, d.Balance, i.Balance FROM inserted AS i
JOIN deleted as d ON i.AccountHolderId = d.AccountHolderId
WHERE i.Balance != d.Balance

UPDATE Accounts
SET Balance = Balance - 10
WHERE Id = 1

SELECT * FROM Logs

--T02 Create Table Emails

CREATE TABLE NotificationEmails
(
Id INT PRIMARY KEY IDENTITY,
Recipient INT FOREIGN KEY REFERENCES Accounts(Id),
[Subject] VARCHAR (70),
Body VARCHAR(100)
)

CREATE OR ALTER TRIGGER tr_SendNotificationEmail
ON Logs FOR INSERT
AS
INSERT INTO NotificationEmails(Recipient, [Subject], Body)
SELECT i.AccountId, CONCAT('Balance change for account: ', i.AccountId),CONCAT('On ', GETDATE(),' your balance was changed from ', i.OldSum, ' to ', i.NewSum, '.')
FROM inserted AS i

UPDATE Accounts
SET Balance = Balance - 10
WHERE Id = 1

SELECT * FROM NotificationEmails

--T03 Deposit Money

GO

CREATE OR ALTER PROC usp_DepositMoney(@AccountId INT, @MoneyAmount DECIMAL(18,4)) 
AS
BEGIN TRANSACTION
IF @AccountId NOT IN (SELECT Id FROM Accounts) OR @MoneyAmount <0
BEGIN
	ROLLBACK
	RETURN
END
UPDATE Accounts SET Balance += @MoneyAmount
WHERE Id = @AccountId
COMMIT

EXEC usp_DepositMoney 1, 30

SELECT Id AS [AccountId], AccountHolderId,  FORMAT(Balance,'F4') AS [Balance] FROM Accounts
WHERE Id = 1

--T04 Withdraw Money

GO

CREATE OR ALTER PROC usp_WithdrawMoney (@AccountId INT, @MoneyAmount DECIMAL (18,4))
AS
BEGIN TRANSACTION
IF @AccountId NOT IN (SELECT Id FROM Accounts) 
			OR @MoneyAmount < 0 
			OR (SELECT Balance FROM Accounts WHERE Id = @AccountId) - @MoneyAmount < 0
BEGIN
	ROLLBACK;
	THROW 50001, 'Invalid Operation', 1
	RETURN
END
UPDATE Accounts SET Balance = Balance - @MoneyAmount
WHERE Id = @AccountId
COMMIT

EXEC usp_WithdrawMoney 5, 25

SELECT Id AS [AccoundId], AccountHolderId, FORMAT(Balance,'F4') AS [Balance] FROM Accounts
WHERE Id = 5

--T05 Money Transfer

GO

CREATE OR ALTER PROC usp_TransferMoney(@SenderId INT, @ReceiverId INT, @Amount DECIMAL(18,4)) 
AS
BEGIN 
 EXEC usp_WithdrawMoney @SenderId, @Amount
 EXEC usp_DepositMoney @ReceiverId, @Amount
END

EXEC usp_TransferMoney 5, 1, 5000

SELECT Id AS [AccountId], AccountHolderId, 
CASE
WHEN Id = 5 THEN FORMAT(Balance, 'F4')
ELSE FORMAT(Balance, 'F2')
END AS Balance FROM Accounts
WHERE Id IN (1,5)