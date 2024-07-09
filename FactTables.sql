
CREATE DATABASE DimensionalDB;
GO

USE DimensionalDB;



-- Crear la tabla de hechos
CREATE TABLE FactAlzheimerData (
    RowId VARCHAR(255),
    YearStart VARCHAR(255),
    YearEnd VARCHAR(255),
    Data_Value DECIMAL(10, 2),
    Data_Value_Alt DECIMAL(10, 2),
    Low_Confidence_Limit DECIMAL(10, 2),
    High_Confidence_Limit DECIMAL(10, 2),
    DimLocationID INT,
    DimQuestionID INT,
    DimStratificationID INT,
    DimGeolocationID INT
);

-- Crear la tabla de dimensiones de ubicaci�n
CREATE TABLE DimLocation (
    DimLocationID INT IDENTITY(1,1),
    LocationAbbr VARCHAR(255),
    LocationDesc VARCHAR(255)
);

-- Crear la tabla de dimensiones de preguntas
CREATE TABLE DimQuestion (
    DimQuestionID INT IDENTITY(1,1),
    Question VARCHAR(255),
    Data_Value_Unit VARCHAR(50),
    DataValueTypeID VARCHAR(50),
    Data_Value_Type VARCHAR(50)
);

-- Crear la tabla de dimensiones de estratificacion
CREATE TABLE DimStratification (
    DimStratificationID INT IDENTITY(1,1),
    StratificationCategory1 VARCHAR(255),
    Stratification1 VARCHAR(255),
    StratificationCategory2 VARCHAR(255),
    Stratification2 VARCHAR(255)
);

-- Crear la tabla de dimensiones de geolocalizacion
CREATE TABLE DimGeolocation (
    DimGeolocationID INT IDENTITY(1,1),
    Geolocation VARCHAR(255)
);
