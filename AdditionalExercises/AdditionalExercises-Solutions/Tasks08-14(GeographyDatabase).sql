USE Geography

--T08 Peaks and Mountains

SELECT p.PeakName
, m.MountainRange AS [Mountain]
, p.Elevation
FROM Mountains AS m
JOIN Peaks AS p ON m.Id = p.MountainId
ORDER BY p.Elevation DESC, p.PeakName

--T09 Peaks with Their Mountain, Country and Continent

SELECT p.PeakName
, m.MountainRange AS [Mountain]
, c.CountryName
, cont.ContinentName 
FROM Peaks AS p
JOIN Mountains AS m ON p.MountainId = m.Id
JOIN MountainsCountries AS mc ON m.Id = mc.MountainId
JOIN Countries AS c ON mc.CountryCode = c.CountryCode
JOIN Continents AS cont ON c.ContinentCode = cont.ContinentCode
ORDER BY p.PeakName, c.CountryName

--T10 Rivers by Country

SELECT c.CountryName
, cont.ContinentName
, ISNULL(COUNT(r.Id), 0) AS [RiversCount]
, SUM(ISNULL(r.Length,0)) AS [TotalLength]
FROM Countries AS c
LEFT JOIN Continents AS cont ON c.ContinentCode = cont.ContinentCode
LEFT JOIN CountriesRivers AS cr ON c.CountryCode = cr.CountryCode
LEFT JOIN Rivers AS r ON cr.RiverId = r.Id
GROUP BY c.CountryName, cont.ContinentName
ORDER BY RiversCount DESC, TotalLength DESC, c.CountryName

--T11 Count of Countries by Currency

SELECT curr.CurrencyCode
, curr.[Description] AS [Currency]
, COUNT(c.CountryCode) AS [NumberOfCountries]
FROM Currencies AS curr
LEFT JOIN Countries AS c ON curr.CurrencyCode = c.CurrencyCode
GROUP BY curr.CurrencyCode, curr.[Description] 
ORDER BY NumberOfCountries DESC, curr.[Description]

--T12 Population and Area by Continent

SELECT cont.ContinentName
, SUM(CAST(c.AreaInSqKm AS bigint)) AS [CountriesArea]
, SUM(CAST(c.[Population] AS bigint)) AS [CountriesPopulation]
FROM Continents AS cont
LEFT JOIN Countries AS c ON cont.ContinentCode = c.ContinentCode
GROUP BY cont.ContinentName
ORDER BY CountriesPopulation DESC

--T13 Monasteries by Country

--13.1

CREATE TABLE Monasteries
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50),
CountryCode CHAR(2) FOREIGN KEY REFERENCES Countries(CountryCode)
)

--13.2

INSERT INTO Monasteries(Name, CountryCode) VALUES
('Rila Monastery “St. Ivan of Rila”', 'BG'), 
('Bachkovo Monastery “Virgin Mary”', 'BG'),
('Troyan Monastery “Holy Mother''s Assumption”', 'BG'),
('Kopan Monastery', 'NP'),
('Thrangu Tashi Yangtse Monastery', 'NP'),
('Shechen Tennyi Dargyeling Monastery', 'NP'),
('Benchen Monastery', 'NP'),
('Southern Shaolin Monastery', 'CN'),
('Dabei Monastery', 'CN'),
('Wa Sau Toi', 'CN'),
('Lhunshigyia Monastery', 'CN'),
('Rakya Monastery', 'CN'),
('Monasteries of Meteora', 'GR'),
('The Holy Monastery of Stavronikita', 'GR'),
('Taung Kalat Monastery', 'MM'),
('Pa-Auk Forest Monastery', 'MM'),
('Taktsang Palphug Monastery', 'BT'),
('Sümela Monastery', 'TR')

--13.3 THIS POINT NOT FOR SUBMISSION IN JUDGE SYSTEM

ALTER TABLE Countries
ADD IsDeleted BIT NOT NULL DEFAULT 0

--13.4

UPDATE Countries
SET IsDeleted = 1
WHERE CountryName IN (SELECT c.CountryName FROM Countries AS c
JOIN CountriesRivers AS cr ON c.CountryCode = cr.CountryCode
JOIN Rivers AS r ON cr.RiverId = r.Id
GROUP BY c.CountryName
HAVING COUNT(cr.RiverId) >3)

--13.5

SELECT m.[Name] AS [Monastery]
, c.CountryName AS [Country]
FROM Monasteries AS m
JOIN Countries AS c ON m.CountryCode = c.CountryCode
WHERE IsDeleted = 0
ORDER BY m.[Name]

--T14 Monasteries by Continents and Countries

--14.1

UPDATE Countries
SET CountryName  = 'Burma'
WHERE CountryName = 'Myanmar'

--14.2

INSERT INTO Monasteries VALUES
('Hanga Abbey', (SELECT CountryCode FROM Countries WHERE CountryName = 'Tanzania'))

--14.3

INSERT INTO Monasteries VALUES
('Myin-Tin-Daik', (SELECT CountryCode FROM Countries WHERE CountryName = 'Myanmar'))

--14.4

SELECT cont.ContinentName
, c.CountryName
, COUNT(m.Id) AS [MonasteriesCount]
FROM Countries AS c
LEFT JOIN Continents AS cont ON c.ContinentCode = cont.ContinentCode
LEFT JOIN Monasteries AS m ON c.CountryCode = m.CountryCode
WHERE c.IsDeleted = 0
GROUP BY cont.ContinentName,c.CountryName
ORDER BY MonasteriesCount DESC, c.CountryName


