-- Truncar y crear las tablas si no existen
IF OBJECT_ID('FactAlzheimer', 'U') IS NOT NULL
BEGIN
    TRUNCATE TABLE FactAlzheimer;
END

IF OBJECT_ID('DimTime', 'U') IS NOT NULL
BEGIN
    TRUNCATE TABLE DimTime;
END

IF OBJECT_ID('DimLocation', 'U') IS NOT NULL
BEGIN
    TRUNCATE TABLE DimLocation;
END

IF OBJECT_ID('DimDataSource', 'U') IS NOT NULL
BEGIN
    TRUNCATE TABLE DimDataSource;
END

IF OBJECT_ID('DimClass', 'U') IS NOT NULL
BEGIN
    TRUNCATE TABLE DimClass;
END

IF OBJECT_ID('DimTopic', 'U') IS NOT NULL
BEGIN
    TRUNCATE TABLE DimTopic;
END

IF OBJECT_ID('DimQuestion', 'U') IS NOT NULL
BEGIN
    TRUNCATE TABLE DimQuestion;
END

IF OBJECT_ID('DimStratification1', 'U') IS NOT NULL
BEGIN
    TRUNCATE TABLE DimStratification1;
END

IF OBJECT_ID('DimStratification2', 'U') IS NOT NULL
BEGIN
    TRUNCATE TABLE DimStratification2;
END

-- Crear las tablas si no existen
IF OBJECT_ID('FactAlzheimer', 'U') IS NULL
BEGIN
    CREATE TABLE FactAlzheimer (
        FactId INT PRIMARY KEY IDENTITY(1,1),
        Data_Value DECIMAL(10, 2),
        Data_Value_Alt DECIMAL(10, 2),
        Low_Confidence_Limit DECIMAL(10, 2),
        High_Confidence_Limit DECIMAL(10, 2),
        TimeKey INT,
        LocationKey INT,
        DataSourceKey INT,
        ClassKey INT,
        TopicKey INT,
        QuestionKey INT,
        Stratification1Key INT,
        Stratification2Key INT
    );
END

IF OBJECT_ID('DimTime', 'U') IS NULL
BEGIN
    CREATE TABLE DimTime (
        TimeKey INT PRIMARY KEY IDENTITY(1,1),
        YearStart VARCHAR(255),
        YearEnd VARCHAR(255)
    );
END

IF OBJECT_ID('DimLocation', 'U') IS NULL
BEGIN
    CREATE TABLE DimLocation (
        LocationKey INT PRIMARY KEY IDENTITY(1,1),
        LocationAbbr VARCHAR(255),
        LocationDesc VARCHAR(255),
        Geolocation VARCHAR(255),
        LocationID VARCHAR(255)
    );
END

IF OBJECT_ID('DimDataSource', 'U') IS NULL
BEGIN
    CREATE TABLE DimDataSource (
        DataSourceKey INT PRIMARY KEY IDENTITY(1,1),
        Datasource VARCHAR(255)
    );
END

IF OBJECT_ID('DimClass', 'U') IS NULL
BEGIN
    CREATE TABLE DimClass (
        ClassKey INT PRIMARY KEY IDENTITY(1,1),
        Class VARCHAR(255),
        ClassID VARCHAR(255)
    );
END

IF OBJECT_ID('DimTopic', 'U') IS NULL
BEGIN
    CREATE TABLE DimTopic (
        TopicKey INT PRIMARY KEY IDENTITY(1,1),
        Topic VARCHAR(255),
        TopicID VARCHAR(255)
    );
END

IF OBJECT_ID('DimQuestion', 'U') IS NULL
BEGIN
    CREATE TABLE DimQuestion (
        QuestionKey INT PRIMARY KEY IDENTITY(1,1),
        Question VARCHAR(255),
        QuestionID VARCHAR(255)
    );
END

IF OBJECT_ID('DimStratification1', 'U') IS NULL
BEGIN
    CREATE TABLE DimStratification1 (
        Stratification1Key INT PRIMARY KEY IDENTITY(1,1),
        StratificationCategory1 VARCHAR(255),
        Stratification1 VARCHAR(255),
        StratificationCategoryID1 VARCHAR(255),
        StratificationID1 VARCHAR(255)
    );
END

IF OBJECT_ID('DimStratification2', 'U') IS NULL
BEGIN
    CREATE TABLE DimStratification2 (
        Stratification2Key INT PRIMARY KEY IDENTITY(1,1),
        StratificationCategory2 VARCHAR(255),
        Stratification2 VARCHAR(255),
        StratificationCategoryID2 VARCHAR(255),
        StratificationID2 VARCHAR(255)
    );
END

-- Insertar datos en tablas dimensionales
INSERT INTO DimTime (YearStart, YearEnd)
SELECT DISTINCT YearStart, YearEnd FROM Alzheimer.dbo.Alzheimer;

INSERT INTO DimLocation (LocationAbbr, LocationDesc, Geolocation, LocationID)
SELECT DISTINCT LocationAbbr, LocationDesc, Geolocation, LocationID FROM Alzheimer.dbo.Alzheimer;

INSERT INTO DimDataSource (Datasource)
SELECT DISTINCT Datasource FROM Alzheimer.dbo.Alzheimer;

INSERT INTO DimClass (Class, ClassID)
SELECT DISTINCT Class, ClassID FROM Alzheimer.dbo.Alzheimer;

INSERT INTO DimTopic (Topic, TopicID)
SELECT DISTINCT Topic, TopicID FROM Alzheimer.dbo.Alzheimer;

INSERT INTO DimQuestion (Question, QuestionID)
SELECT DISTINCT Question, QuestionID FROM Alzheimer.dbo.Alzheimer;

INSERT INTO DimStratification1 (StratificationCategory1, Stratification1, StratificationCategoryID1, StratificationID1)
SELECT DISTINCT StratificationCategory1, Stratification1, StratificationCategoryID1, StratificationID1 FROM Alzheimer.dbo.Alzheimer;

INSERT INTO DimStratification2 (StratificationCategory2, Stratification2, StratificationCategoryID2, StratificationID2)
SELECT DISTINCT StratificationCategory2, Stratification2, StratificationCategoryID2, StratificationID2 FROM Alzheimer.dbo.Alzheimer;

-- Insertar datos en la fact table
INSERT INTO FactAlzheimer (Data_Value, Data_Value_Alt, Low_Confidence_Limit, High_Confidence_Limit, TimeKey, LocationKey, DataSourceKey, ClassKey, TopicKey, QuestionKey, Stratification1Key, Stratification2Key)
SELECT 
    A.Data_Value,
    A.Data_Value_Alt,
    A.Low_Confidence_Limit,
    A.High_Confidence_Limit,
    T.TimeKey,
    L.LocationKey,
    D.DataSourceKey,
    C.ClassKey,
    TP.TopicKey,
    Q.QuestionKey,
    S1.Stratification1Key,
    S2.Stratification2Key
FROM Alzheimer.dbo.Alzheimer AS A
JOIN DimTime AS T ON A.YearStart = T.YearStart AND A.YearEnd = T.YearEnd
JOIN DimLocation AS L ON A.LocationAbbr = L.LocationAbbr AND A.LocationDesc = L.LocationDesc AND A.Geolocation = L.Geolocation AND A.LocationID = L.LocationID
JOIN DimDataSource AS D ON A.Datasource = D.Datasource
JOIN DimClass AS C ON A.Class = C.Class AND A.ClassID = C.ClassID
JOIN DimTopic AS TP ON A.Topic = TP.Topic AND A.TopicID = TP.TopicID
JOIN DimQuestion AS Q ON A.Question = Q.Question AND A.QuestionID = Q.QuestionID
JOIN DimStratification1 AS S1 ON A.StratificationCategory1 = S1.StratificationCategory1 AND A.Stratification1 = S1.Stratification1 AND A.StratificationCategoryID1 = S1.StratificationCategoryID1 AND A.StratificationID1 = S1.StratificationID1
JOIN DimStratification2 AS S2 ON A.StratificationCategory2 = S2.StratificationCategory2 AND A.Stratification2 = S2.Stratification2 AND A.StratificationCategoryID2 = S2.StratificationCategoryID2 AND A.StratificationID2 = S2.StratificationID2;
