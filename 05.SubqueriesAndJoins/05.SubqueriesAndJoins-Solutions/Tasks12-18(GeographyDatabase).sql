USE Geography

--T12 Highest Peaks in Bulgaria

SELECT c.CountryCode
, m.MountainRange
, p.PeakName
, p.Elevation FROM Countries AS c
JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
JOIN Mountains AS m ON m.Id = mc.MountainId
JOIN Peaks AS P ON p.MountainId = m.Id
WHERE C.CountryName = 'Bulgaria' AND p.Elevation> 2835
ORDER BY p.Elevation DESC

--T13 Count Mountain Ranges

SELECT CountryCode, Count(*) AS MountainRanges FROM MountainsCountries
WHERE CountryCode IN ('US', 'RU', 'BG')
GROUP BY CountryCode

--T14 Countries with Rivers

SELECT TOP(5) c.CountryName, r.RiverName FROM  Countries AS c
LEFT JOIN CountriesRivers AS cr ON c.CountryCode = cr.CountryCode
LEFT JOIN Rivers AS r ON cr.RiverId = r.Id
WHERE c.ContinentCode = 'AF'
ORDER BY c.CountryName

--T15 *Continents and Currencies

SELECT curr.ContinentCode, curr.CurrencyCode, curr.CurrencyUsage FROM
(
SELECT ContinentCode, CurrencyCode, COUNT(CurrencyCode) AS CurrencyUsage,
DENSE_RANK() OVER (PARTITION BY ContinentCode ORDER BY COUNT(CurrencyCode) DESC) AS DenseRanked
FROM Countries
GROUP BY  ContinentCode, CurrencyCode

) AS curr 
WHERE  curr.DenseRanked = 1 AND curr.CurrencyUsage >1
ORDER BY ContinentCode

--T16 Countries Without Any Mountains

SELECT COUNT(*) AS [Count] FROM Countries AS c
LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
WHERE mc.CountryCode IS NULL

--T17 Highest Peak and Longest River by Country

SELECT TOP(5) ss.CountryName, ss.HighestPeakElevation, ss.LongestRiverLength FROM
(SELECT c.CountryName
, MAX(p.Elevation) AS [HighestPeakElevation]
, MAX(r.Length) AS [LongestRiverLength]
FROM Countries AS c
LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
LEFT JOIN Peaks AS p ON m.Id = p.MountainId
LEFT JOIN CountriesRivers AS cp ON c.CountryCode = cp.CountryCode
LEFT JOIN Rivers AS r ON cp.RiverId = r.Id
GROUP BY c.CountryName) AS ss
ORDER BY ss.HighestPeakElevation DESC, ss.LongestRiverLength DESC, ss.CountryName

--SHORTER VERSION

SELECT TOP(5) c.CountryName
, MAX(p.Elevation) AS [HighestPeakElevation]
, MAX(r.Length) AS [LongestRiverLength]
FROM Countries AS c
LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
LEFT JOIN Peaks AS p ON m.Id = p.MountainId
LEFT JOIN CountriesRivers AS cr ON c.CountryCode = cr.CountryCode
LEFT JOIN Rivers AS r ON cr.RiverId = r.Id
GROUP BY CountryName
ORDER BY HighestPeakElevation DESC, LongestRiverLength DESC, CountryName

--T18 Highest Peak Name and Elevation by Country

SELECT new.CountryName, new.[Highest Peak Name], new.[Highest Peak Elevation], new.Mountain FROM
(SELECT TOP (5) c.CountryName, 
CASE 
WHEN p.PeakName IS NULL THEN '(no highest peak)'
ELSE p.PeakName
END AS [Highest Peak Name],
CASE 
WHEN MAX(p.Elevation) IS NULL THEN '0'
ELSE MAX(p.Elevation)
END AS [Highest Peak Elevation],
CASE 
WHEN m.MountainRange IS NULL THEN '(no mountain)'
ELSE m.MountainRange
END AS [Mountain],
DENSE_RANK() OVER(PARTITION BY c.CountryName ORDER BY MAX(p.Elevation)) AS Ranked
FROM Countries AS c
LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
LEFT JOIN Peaks AS p ON m.Id = p.MountainId
GROUP BY CountryName, p.PeakName, m.MountainRange) AS new
WHERE new.Ranked = 1
ORDER BY CountryName, [Highest Peak Name] 

--ANOTHER SOLUTION

SELECT TOP (5) new.CountryName, new.[Highest Peak Name], new.[Highest Peak Elevation], new.Mountain FROM
(SELECT CountryName
, ISNULL(p.PeakName,'(no highest peak)') AS [Highest Peak Name]
, ISNULL(p.Elevation, 0) AS [Highest Peak Elevation]
, ISNULL(m.MountainRange,'(no mountain)') AS [Mountain],
DENSE_RANK() OVER(PARTITION BY c.CountryName ORDER BY p.Elevation DESC) AS Ranked
FROM Countries AS c
LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
LEFT JOIN Peaks AS p ON m.Id = p.MountainId
GROUP BY c.CountryName, PeakName, MountainRange, Elevation) AS new
WHERE new.Ranked = 1
ORDER BY new.CountryName, new.[Highest Peak Name]



