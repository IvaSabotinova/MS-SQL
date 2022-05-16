USE Geography

--T12 Countries Holding ‘A’ 3 or More Times

SELECT CountryName, IsoCode FROM Countries
WHERE UPPER(CountryName) LIKE '%A%A%A%'
ORDER BY IsoCode

--T13 Mix of Peak and River Names

SELECT PeakName, RiverName,
LOWER(LEFT(PeakName, LEN(PeakName)-1)+RIGHT(RiverName, LEN(RiverName))) AS Mix
FROM Peaks, Rivers
WHERE RIGHT(PeakName, 1) = LEFT(RiverName, 1)
ORDER BY Mix
