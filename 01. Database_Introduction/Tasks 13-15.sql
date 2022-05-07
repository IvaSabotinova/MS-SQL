--T13 Movies Database

--CREATE DATABASE Movies

CREATE TABLE Directors
(
Id INT PRIMARY KEY NOT NULL,
DirectorName VARCHAR (30) NOT NULL,
Notes VARCHAR (MAX)
)

INSERT INTO Directors VALUES
(1, 'Pesho Peshev' , 'Aaaaaaaa'),
(2, 'Gosho Peshev' , 'Aaaaaaaa'),
(3, 'Vasa Peshev' , 'Aaaaaaaa'),
(4, 'Dimo Peshev' , 'Aaaaaaaa'),
(5, 'Geca Peshev' , 'Aaaaaaaa')


CREATE TABLE Genres
(
Id INT PRIMARY KEY NOT NULL,
GenreName VARCHAR(30),
Notes VARCHAR (MAX)
)
INSERT INTO Genres VALUES
(1, 'Drama', NULL),
(2, 'Comedy', NULL),
(3, 'Romance', NULL),
(4, 'Fiction', NULL),
(5, 'Action', NULL)

CREATE TABLE Categories
(
Id INT PRIMARY KEY NOT NULL,
CategoryName VARCHAR (30) NOT NULL,
Notes VARCHAR (MAX)
)

INSERT INTO Categories VALUES
(1, 'A', NULL),
(2, 'B', NULL),
(3, 'C', NULL),
(4, 'D', NULL),
(5, 'E', NULL)

CREATE TABLE Movies
(
Id INT PRIMARY KEY NOT NULL,
Title VARCHAR(30) NOT NULL,
DirectorId INT NOT NULL,
CopyrightYear DATE NOT NULL,
[Length] TIME NOT NULL,
GenreId INT NOT NULL,
CategoryId INT NOT NULL,
Rating INT,
Notes VARCHAR(MAX)
)

INSERT INTO Movies VALUES
(1, 'Movie1', 1, '05/05/2002', '01:35:25', 1, 1, 25, NULL),
(2, 'Movie2', 2, '06/05/2001', '01:30:03', 2, 2, 21, NULL),
(3, 'Movie3', 3, '02/02/2000', '00:35:45', 3, 3, 20, NULL),
(4, 'Movie4', 4, '06/08/1999', '02:25:05', 4, 4, 26, NULL),
(5, 'Movie5', 5, '07/08/1998', '01:25:08', 5, 5, 27, NULL)


--T14 Car Rental Database

CREATE DATABASE CarRental

USE CarRental
CREATE TABLE Categories
(
Id INT PRIMARY KEY IDENTITY NOT NULL,
CategoryName VARCHAR (30),
DailyRate INT,
WeeklyRate INT,
MonthlyRate INT NOT NULL,
WeekendRate INT
)
INSERT INTO Categories VALUES
('A', 1, 7, 30, 2),
('B', 5, 35, 150, 10),
('C', 10, 70, 300, 20)

CREATE TABLE Cars
(Id INT PRIMARY KEY IDENTITY NOT NULL,
PlateNumber VARCHAR (20),
Manufacturer VARCHAR (50),
Model VARCHAR (50),
CarYear DATE,
CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
Doors INT,
Picture VARBINARY (MAX),
Condition VARCHAR(30),
Available BIT
)

INSERT INTO Cars(PlateNumber, Manufacturer, Model, CarYear, CategoryId, Doors, Available) VALUES
('A2222A', 'BMW', 'aaa', '08/22/1999', 1, 2,0),
('A3333A', 'Audi', 'bbb', '08/17/2000', 2, 5,1),
('A7777A', 'Tesla', 'ccc', '07/13/2001', 3, 5,1)


CREATE TABLE Employees
(
Id INT PRIMARY KEY IDENTITY NOT NULL, 
FirstName VARCHAR (20) NOT NULL,
LastName VARCHAR (30) NOT NULL,
Title VARCHAR (30),
Notes VARCHAR (MAX)
)

INSERT INTO Employees VALUES
('Pesho','Peshev','Seller',NULL),
('Gosho','Goshev','Seller',NULL),
('Geca','Gecev','Seller',NULL)


CREATE TABLE Customers
(
Id INT PRIMARY KEY IDENTITY NOT NULL,
DriverLicenceNumber VARCHAR(30),
FullName VARCHAR (70) NOT NULL, 
Address VARCHAR (120),
City VARCHAR(20),
ZIPCode INT,
Notes VARCHAR (MAX)
)

INSERT INTO Customers VALUES
('AAAAA', 'Gecata Gecev', 'ul. Gecata', 'Sofia', 1000, NULL),
('BBBBB', 'Pecata Pecev', 'ul. Pecata', 'Varna', 2000, NULL),
('CCCCC', 'Dimata Dimev', 'ul. Dimata', 'Bourgas', 8000, NULL)

CREATE TABLE RentalOrders
(
Id INT PRIMARY KEY IDENTITY NOT NULL,
EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL,
CustomerId INT FOREIGN KEY REFERENCES Customers(Id) NOT NULL,
CarId INT FOREIGN KEY REFERENCES Cars(Id) NOT NULL,
TankLevel INT,
KilometrageStart INT,
KilometrageEnd INT,
TotalKilometrage INT,
StartDate DATE,
EndDate DATE,
TotalDays INT,
RateApplied DECIMAL,
TaxRate DECIMAL,
OrderStatus BIT,
Notes VARCHAR(MAX)
)

INSERT INTO RentalOrders VALUES
(1, 1, 1, 5, 10, 80, 70, '03/03/2022', '03/08/2022', 5, 1.2, 1.2, 0, NULL),
(2, 2, 2, 7, 20, 80, 60, '03/03/2022', '03/08/2022', 5, 1.2, 1.2, 0, NULL),
(3, 3, 3, 9, 70, 80, 10, '03/03/2022', '03/08/2022', 5, 1.2, 1.2, 0, NULL)


--T15 Hotel Database

CREATE DATABASE Hotel

USE Hotel
CREATE TABLE Employees
(
Id INT PRIMARY KEY NOT NULL,
FirstName VARCHAR(20),
LastName VARCHAR(30) NOT NULL,
Title VARCHAR(30),
Notes VARCHAR(MAX)
)

INSERT INTO Employees VALUES
(1, 'Pesho', 'Peshov', 'Seller', NULL),
(2, 'Gosho', 'Goshov', 'Seller', NULL),
(3, 'Geca', 'Gecov', 'Seller', NULL)


CREATE TABLE Customers
(
AccountNumber INT PRIMARY KEY NOT NULL,
FirstName VARCHAR(20),
LastName VARCHAR(30) NOT NULL,
PhoneNumber CHAR (10),
EmergencyName VARCHAR(50),
EmergencyNumber CHAR(10),
Notes VARCHAR(MAX)
)

INSERT INTO Customers VALUES
(111, 'Customer1', 'LastName1', '0888111111', 'AAA', '111111', NULL),
(222, 'Customer2', 'LastName2', '0888222222', 'BBB', '111222', NULL),
(333, 'Customer3', 'LastName3', '0888333333', 'CCC', '111333', NULL)


CREATE TABLE RoomStatus
(
RoomStatus VARCHAR (30) PRIMARY KEY NOT NULL,
Notes VARCHAR (MAX)
)

INSERT INTO RoomStatus VALUES
('Occupied', NULL),
('Under Repair', NULL),
('Reserved', NULL)

CREATE TABLE RoomTypes
(
RoomType VARCHAR (15) PRIMARY KEY NOT NULL,
Notes VARCHAR(MAX)
)

INSERT INTO RoomTypes VALUES
('Apartment', NULL),
('DoubleRoom', NULL),
('SingleRoom', NULL)


CREATE TABLE BedTypes
(
BedType VARCHAR (30) PRIMARY KEY NOT NULL,
Notes VARCHAR (MAX)
)

INSERT INTO BedTypes VALUES
('SingleBed', NULL),
('DoubleBed', NULL),
('BedRoom', NULL)

CREATE TABLE Rooms
(
RoomNumber INT PRIMARY KEY NOT NULL,
RoomType VARCHAR (15) FOREIGN KEY REFERENCES RoomTypes(RoomType) NOT NULL,
BedType VARCHAR (30) FOREIGN KEY REFERENCES BedTypes(BedType) NOT NULL,
Rate INT,
RoomStatus VARCHAR(30) FOREIGN KEY REFERENCES RoomStatus(RoomStatus) NOT NULL,
Notes VARCHAR (MAX)
)

INSERT INTO Rooms VALUES
(111, 'Apartment', 'BedRoom', 1.2, 'Reserved', NULL), 
(222, 'DoubleRoom', 'DoubleBed', 1.2, 'Occupied', NULL),
(333, 'SingleRoom', 'SingleBed', 1.2, 'Under Repair', NULL)

CREATE TABLE Payments
(
Id INT PRIMARY KEY NOT NULL,
EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL,
PaymentDate DATE,
AccountNumber INT FOREIGN KEY REFERENCES Customers(AccountNumber) NOT NULL,
FirstDateOccupied DATE,
LastDateOccupied DATE,
TotalDays INT,
AmountCharged DECIMAL (10,2),
TaxRate DECIMAL(10,2),
TaxAmount DECIMAL(10,2),
PaymentTotal DECIMAL (10,2),
Notes VARCHAR(MAX)
)

INSERT INTO Payments VALUES
(1, 1, '01/05/2002', 111, '05/05/2005', '06/05/2005', 31, 120.00, 1.20, 1.00, 120.00, NULL),
(2, 2, '01/05/2002', 222, '05/05/2005', '06/05/2005', 31, 120.00, 1.20, 1.00, 120.00, NULL),
(3, 3, '01/05/2002', 333, '05/05/2005', '06/05/2005', 31, 120.00, 1.20, 1.00, 120.00, NULL)

CREATE TABLE Occupancies
(
Id INT PRIMARY KEY NOT NULL,
EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL,
DateOccupied DATE, 
AccountNumber INT FOREIGN KEY REFERENCES Customers(AccountNumber) NOT NULL,
RoomNumber INT FOREIGN KEY REFERENCES Rooms(RoomNumber) NOT NULL,
RateApplied DECIMAL (10,2),
PhoneCharge DECIMAL (10,2),
Notes VARCHAR (MAX)
)

INSERT INTO Occupancies VALUES
(1, 1, '06/06/2006', 111, 111, 1.20, 2.20, NULL),
(2, 2, '06/06/2006', 222, 222, 1.20, 2.20, NULL),
(3, 3, '06/06/2006', 333, 333, 1.20, 2.20, NULL)