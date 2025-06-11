CREATE TABLE Item (
    UniqueID INT PRIMARY KEY,
    Title TEXT NOT NULL,
    Translation TEXT NOT NULL,
    Archived INT
);

CREATE TABLE Screen (
    UniqueID INT PRIMARY KEY,
    Title TEXT NOT NULL,
    Translation TEXT NOT NULL,
    Archived INT
);

CREATE TABLE Menu (
    UniqueID INT PRIMARY KEY,
    Title TEXT NOT NULL,
    Translation TEXT NOT NULL,
    Archived INT
);

CREATE TABLE Misc (
    UniqueID INT PRIMARY KEY,
    Title TEXT NOT NULL,
    Translation TEXT NOT NULL,
    Archived INT
);