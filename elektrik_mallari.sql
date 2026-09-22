-- ========================================================
-- Layihə: "Elektrik_mallari" Verilənlər Bazasının Yaradılması
-- Mühit: MS SQL Server (T-SQL)
-- Təsvir: Elektrik malları zavodunun fəaliyyət uçotu
-- ========================================================

-- 1. Verilənlər bazasının yaradılması və aktivləşdirilməsi
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Elektrik_mallari')
BEGIN
CREATE DATABASE Elektrik_mallari;
END
GO

USE Elektrik_mallari;
GO

-- ========================================================
-- 2. CƏDVƏLLƏRİN YARADILMASI (TABLE CREATION)
-- ========================================================

-- 2.1. Tədarükçülər cədvəli
IF OBJECT_ID('dbo.Tedarukculer', 'U') IS NOT NULL DROP TABLE dbo.Tedarukculer;
CREATE TABLE Tedarukculer (
TedarukcuID INT IDENTITY(1,1) PRIMARY KEY,
TedarukcuKodu VARCHAR(20) UNIQUE NOT NULL,
Soyad NVARCHAR(50) NOT NULL,
Ad NVARCHAR(50) NOT NULL,
AtaAdi NVARCHAR(50),
HesabNomresi VARCHAR(30) NOT NULL,
Unvan NVARCHAR(150),
Telefon VARCHAR(20)
);

-- 2.2. Xammal cədvəli
IF OBJECT_ID('dbo.Xammal', 'U') IS NOT NULL DROP TABLE dbo.Xammal;
CREATE TABLE Xammal (
XammalID INT IDENTITY(1,1) PRIMARY KEY,
XammalAdi NVARCHAR(100) NOT NULL,
OlcuVahidi NVARCHAR(20) NOT NULL,
Deyeri DECIMAL(10,2) NOT NULL,
SaxlanmaSeraiti NVARCHAR(100),
SaxlanmaMuddetiAy INT
);

-- 2.3. Xammal Alışı cədvəli
IF OBJECT_ID('dbo.XammalAlisi', 'U') IS NOT NULL DROP TABLE dbo.XammalAlisi;
CREATE TABLE XammalAlisi (
AlisID INT IDENTITY(1,1) PRIMARY KEY,
TedarukcuID INT NOT NULL,
XammalID INT NOT NULL,
AlinmaTarixi DATE NOT NULL,
Miqdar DECIMAL(10,2) NOT NULL,
AlisQiymeti DECIMAL(10,2) NOT NULL,
CONSTRAINT FK_XammalAlisi_Tedarukculer FOREIGN KEY (TedarukcuID) REFERENCES Tedarukculer(TedarukcuID),
CONSTRAINT FK_XammalAlisi_Xammal FOREIGN KEY (XammalID) REFERENCES Xammal(XammalID)
);

-- 2.4. Hazır Məhsul cədvəli
IF OBJECT_ID('dbo.HazirMehsul', 'U') IS NOT NULL DROP TABLE dbo.HazirMehsul;
CREATE TABLE HazirMehsul (
MehsulID INT IDENTITY(1,1) PRIMARY KEY,
MehsulAdi NVARCHAR(100) NOT NULL,
Nomenklatura VARCHAR(50) UNIQUE NOT NULL,
Deyeri DECIMAL(10,2) NOT NULL,
IstifadeMeqsedi NVARCHAR(150),
SaxlanmaSeraiti NVARCHAR(100)
);

-- 2.5. İstehlakçılar cədvəli
IF OBJECT_ID('dbo.Istehlakcilar', 'U') IS NOT NULL DROP TABLE dbo.Istehlakcilar;
CREATE TABLE Istehlakcilar (
IstehlakciID INT IDENTITY(1,1) PRIMARY KEY,
IstehlakciKodu VARCHAR(20) UNIQUE NOT NULL,
Soyad NVARCHAR(50) NOT NULL,
Ad NVARCHAR(50) NOT NULL,
AtaAdi NVARCHAR(50),
HesabNomresi VARCHAR(30) NOT NULL,
Unvan NVARCHAR(150),
Telefon VARCHAR(20)
);

-- 2.6. Satış Qaimələri cədvəli
IF OBJECT_ID('dbo.SatisQaimeleri', 'U') IS NOT NULL DROP TABLE dbo.SatisQaimeleri;
CREATE TABLE SatisQaimeleri (
QaimeID INT IDENTITY(1,1) PRIMARY KEY,
QaimeNomresi VARCHAR(30) UNIQUE NOT NULL,
IstehlakciID INT NOT NULL,
MehsulID INT NOT NULL,
SatilmaTarixi DATE NOT NULL,
SatisQiymeti DECIMAL(10,2) NOT NULL,
OlcuVahidi NVARCHAR(20) NOT NULL,
Miqdar DECIMAL(10,2) NOT NULL,
UmumiDeyer AS (SatisQiymeti * Miqdar) PERSISTED,
OdenilenPul DECIMAL(10,2) DEFAULT 0.00,
QaliqPul AS ((SatisQiymeti * Miqdar) - OdenilenPul) PERSISTED,
SonOdenisTarixi DATE,
CONSTRAINT FK_SatisQaimeleri_Istehlakcilar FOREIGN KEY (IstehlakciID) REFERENCES Istehlakcilar(IstehlakciID),
CONSTRAINT FK_SatisQaimeleri_HazirMehsul FOREIGN KEY (MehsulID) REFERENCES HazirMehsul(MehsulID)
);
GO

-- ========================================================
-- 3. TEST MƏLUMATLARININ DAXİL EDİLMƏSİ (INSERT DATA)
-- ========================================================

-- Tədarükçülər
INSERT INTO Tedarukculer (TedarukcuKodu, Soyad, Ad, AtaAdi, HesabNomresi, Unvan, Telefon) VALUES
('TED001', N'Əliyev', N'Məmməd', N'Həsən', 'AZ12NABZ0000000001', N'Bakı şəh., Nərimanov r.', '+994501234567'),
('TED002', N'Həsənov', N'Elçin', N'Rauf', 'AZ34ABBZ0000000002', N'Sumqayıt şəh., 5-ci mkr', '+994557654321');

-- Xammal
INSERT INTO Xammal (XammalAdi, OlcuVahidi, Deyeri, SaxlanmaSeraiti, SaxlanmaMuddetiAy) VALUES
(N'Mis məftil 2.5mm', N'metr', 5.50, N'Quru anbar, Max 30°C', 36),
(N'Plastik korpus xammalı', N'kq', 12.00, N'Quru anbar, Opt. 20°C', 24);

-- Xammal Alışları
INSERT INTO XammalAlisi (TedarukcuID, XammalID, AlinmaTarixi, Miqdar, AlisQiymeti) VALUES
(1, 1, '2026-01-10', 500.00, 5.50),
(2, 2, '2026-01-15', 200.00, 12.00);

-- Hazır Məhsul
INSERT INTO HazirMehsul (MehsulAdi, Nomenklatura, Deyeri, IstifadeMeqsedi, SaxlanmaSeraiti) VALUES
(N'Avtomat Birləşdirici 16A', 'NOM-ELK-001', 15.00, N'Məişət elektrik şəbəkəsi mühafizəsi', N'Nəmsiz mühit'),
(N'Elektrik Qutusu 4-lü', 'NOM-ELK-002', 8.50, N'Daxili kabel paylanması', N'Otaq temperaturu');

-- İstehlakçılar
INSERT INTO Istehlakcilar (IstehlakciKodu, Soyad, Ad, AtaAdi, HesabNomresi, Unvan, Telefon) VALUES
('IST001', N'Vəliyev', N'Kamil', N'İslam', 'AZ98IBAZ0000000002', N'Sumqayıt şəh., 3-cü mkr', '+994559876543'),
('IST002', N'Qasımov', N'Orxan', N'Fuad', 'AZ56PASZ0000000004', N'Bakı şəh., Yasamal r.', '+994703332211');

-- Satış Qaimələri
INSERT INTO SatisQaimeleri (QaimeNomresi, IstehlakciID, MehsulID, SatilmaTarixi, SatisQiymeti, OlcuVahidi, Miqdar, OdenilenPul, SonOdenisTarixi) VALUES
('QMN-2026-001', 1, 1, '2026-02-01', 15.00, N'ədəd', 100, 1000.00, '2026-02-20'),
('QMN-2026-002', 2, 2, '2026-02-05', 8.50, N'ədəd', 50, 425.00, '2026-02-05');
GO

-- ========================================================
-- 4. ANALİTİK SORĞULAR (SAMPLE QUERIES)
-- ========================================================

-- Borcu olan müştərilərin siyahısı
SELECT
sq.QaimeNomresi,
i.Soyad + ' ' + i.Ad AS Istehlakci,
hm.MehsulAdi,
sq.UmumiDeyer,
sq.OdenilenPul,
sq.QaliqPul,
sq.SonOdenisTarixi
FROM SatisQaimeleri sq
JOIN Istehlakcilar i ON sq.IstehlakciID = i.IstehlakciID
JOIN HazirMehsul hm ON sq.MehsulID = hm.MehsulID
WHERE sq.QaliqPul > 0;
GO
