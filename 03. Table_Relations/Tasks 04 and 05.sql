--T04 Self-Referencing 

CREATE TABLE Teachers
(
TeacherID INT PRIMARY KEY IDENTITY (101,1) NOT NULL,
[Name] VARCHAR (30) NOT NULL,

ManagerID INT FOREIGN KEY REFERENCES Teachers (TeacherID)
)

INSERT INTO Teachers VALUES
('John', NULL),
('Maya', 106),
('Silvia', 106),
('Ted', 105),
('Mark', 101),
('Greta', 101)

--T05 Online Store Database

CREATE DATABASE [Online Store]


CREATE TABLE Cities
(
CityID INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50)
)

CREATE TABLE Customers
(
CustomerID INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50),
Birthday DATE,
CityID INT FOREIGN KEY REFERENCES Cities(CityID)
)

CREATE TABLE Orders
(
OrderID INT PRIMARY KEY IDENTITY,
CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID)
)

CREATE TABLE ItemTypes
(
ItemTypeID INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50)
)

CREATE TABLE Items
(
ItemID INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50),
ItemTypeID INT FOREIGN KEY REFERENCES ItemTypes(ItemTypeID)
)

CREATE TABLE OrderItems
(
OrderID INT FOREIGN KEY  REFERENCES Orders(OrderID),
ItemID INT FOREIGN KEY REFERENCES Items(ItemID)

CONSTRAINT PK_Orders_Items PRIMARY KEY (OrderID, ItemID)
)

