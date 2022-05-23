USE Gringotts

--T01 Records’ Count

SELECT COUNT(*) AS Count
FROM WizzardDeposits 

--T02 Longest Magic Wand

SELECT MAX(MagicWandSize) AS LongestMagicWand
FROM WizzardDeposits

--T03 Longest Magic Wand Per Deposit Groups

SELECT DepositGroup, MAX(MagicWandSize) AS LongestMagicWand
FROM WizzardDeposits
GROUP BY DepositGroup

--T04 *Smallest Deposit Group Per Magic Wand Size

SELECT TOP(2) DepositGroup
FROM WizzardDeposits
GROUP BY DepositGroup
ORDER BY AVG(MagicWandSize) 

--T05 Deposits Sum

SELECT DepositGroup, Sum(DepositAmount) AS TotalSum
FROM WizzardDeposits
GROUP BY DepositGroup

--T06 Deposits Sum for Ollivander Family

SELECT DepositGroup, Sum(DepositAmount) AS TotalSum
FROM WizzardDeposits
WHERE MagicWandCreator IN ('Ollivander family')
--WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup

--T07 Deposits Filter

SELECT DepositGroup, Sum(DepositAmount) AS TotalSum
FROM WizzardDeposits
WHERE MagicWandCreator IN ('Ollivander family')
GROUP BY DepositGroup
HAVING Sum(DepositAmount) < 150000
ORDER BY TotalSum DESC

--T08 Deposit Charge

SELECT DepositGroup, MagicWandCreator, MIN(DepositCharge) AS MinDepositCharge 
FROM WizzardDeposits
GROUP BY DepositGroup, MagicWandCreator
ORDER BY MagicWandCreator, DepositGroup

--T09 Age Groups

SELECT new.AgeGroup, COUNT(new.AgeGroup) AS WizardCount FROM
(SELECT
CASE
WHEN Age BETWEEN 0 AND 10 THEN '[0-10]'
WHEN Age BETWEEN 11 AND 20 THEN '[11-20]' 
WHEN Age BETWEEN 21 AND 30 THEN '[21-30]' 
WHEN Age BETWEEN 31 AND 40 THEN '[31-40]' 
WHEN Age BETWEEN 41 AND 50 THEN '[41-50]' 
WHEN Age BETWEEN 51 AND 60 THEN '[51-60]' 
ELSE '[61+]' 
END AS AgeGroup
FROM WizzardDeposits) AS new 
GROUP BY new.AgeGroup

--T10 First Letter

SELECT LEFT(FirstName, 1) AS [FirstLetter]
FROM WizzardDeposits
WHERE DepositGroup = 'Troll Chest'
GROUP BY LEFT(FirstName, 1)

--T11 Average Interest 

SELECT DepositGroup, IsDepositExpired, AVG(DepositInterest) AS AverageInterest
FROM WizzardDeposits
WHERE DepositStartDate > '1985-01-01'
GROUP BY DepositGroup, IsDepositExpired
ORDER BY DepositGroup DESC, IsDepositExpired

--T12 *Rich Wizard, Poor Wizard

SELECT SUM(wz1.DepositAmount - wz2.DepositAmount) AS SumDifference
FROM WizzardDeposits AS wz1
JOIN WizzardDeposits AS wz2 ON wz1.Id + 1 = wz2.Id
