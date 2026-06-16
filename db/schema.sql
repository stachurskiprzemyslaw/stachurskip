/* =====================================================================
   baseFunds — struktura bazy funduszy (kanon domeny)
   Cel: warsztat "Podgląd NAV i pozycji funduszu".
   Dane wczytywane przez seed.sql są w 100% SYNTETYCZNE.

   Uruchomienie (przykład):
     sqlcmd -S localhost,1433 -U sa -P "$SA_PASSWORD" -i db/schema.sql
   ===================================================================== */

IF DB_ID('baseFunds') IS NULL
BEGIN
    CREATE DATABASE baseFunds;
END;
GO

USE baseFunds;
GO

/* ---- Czyszczenie (idempotentne ponowne uruchomienie) ---------------- */
IF OBJECT_ID('dbo.FeeAccrual',  'U') IS NOT NULL DROP TABLE dbo.FeeAccrual;
IF OBJECT_ID('dbo.Valuation',   'U') IS NOT NULL DROP TABLE dbo.Valuation;
IF OBJECT_ID('dbo.Redemption',  'U') IS NOT NULL DROP TABLE dbo.Redemption;
IF OBJECT_ID('dbo.Subscription','U') IS NOT NULL DROP TABLE dbo.Subscription;
IF OBJECT_ID('dbo.Holding',     'U') IS NOT NULL DROP TABLE dbo.Holding;
IF OBJECT_ID('dbo.PriceEOD',    'U') IS NOT NULL DROP TABLE dbo.PriceEOD;
IF OBJECT_ID('dbo.Instrument',  'U') IS NOT NULL DROP TABLE dbo.Instrument;
IF OBJECT_ID('dbo.Investor',    'U') IS NOT NULL DROP TABLE dbo.Investor;
IF OBJECT_ID('dbo.ShareClass',  'U') IS NOT NULL DROP TABLE dbo.ShareClass;
IF OBJECT_ID('dbo.Fund',        'U') IS NOT NULL DROP TABLE dbo.Fund;
GO

/* ---- Fund ------------------------------------------------------------ */
CREATE TABLE dbo.Fund (
    FundId        VARCHAR(20)   NOT NULL CONSTRAINT PK_Fund PRIMARY KEY,  -- np. FUND-A
    Name          NVARCHAR(120) NOT NULL,
    BaseCurrency  CHAR(3)       NOT NULL,                                 -- ISO 4217, np. EUR
    InceptionDate DATE          NOT NULL
);
GO

/* ---- ShareClass ------------------------------------------------------ */
CREATE TABLE dbo.ShareClass (
    ShareClassId      VARCHAR(20)   NOT NULL CONSTRAINT PK_ShareClass PRIMARY KEY, -- np. FUND-A-ACC
    FundId            VARCHAR(20)   NOT NULL,
    Name              NVARCHAR(80)  NOT NULL,
    Currency          CHAR(3)       NOT NULL,
    ManagementFeeBps  INT           NOT NULL,   -- opłata za zarządzanie w punktach bazowych
    PerformanceFeeBps INT           NOT NULL,   -- opłata za wyniki w punktach bazowych
    HurdleRateBps     INT           NOT NULL,   -- stopa progowa w punktach bazowych
    CONSTRAINT FK_ShareClass_Fund FOREIGN KEY (FundId) REFERENCES dbo.Fund(FundId)
);
GO

/* ---- Investor -------------------------------------------------------- */
CREATE TABLE dbo.Investor (
    InvestorId  VARCHAR(20)   NOT NULL CONSTRAINT PK_Investor PRIMARY KEY,  -- np. INV-001
    Name        NVARCHAR(120) NOT NULL,
    Country     CHAR(2)       NOT NULL                                      -- ISO 3166-1 alpha-2
);
GO

/* ---- Instrument ------------------------------------------------------ */
CREATE TABLE dbo.Instrument (
    InstrumentId VARCHAR(20)   NOT NULL CONSTRAINT PK_Instrument PRIMARY KEY, -- np. INSTR-001
    Name         NVARCHAR(120) NOT NULL,
    AssetClass   VARCHAR(20)   NOT NULL,   -- EQUITY | BOND | CASH
    Currency     CHAR(3)       NOT NULL
);
GO

/* ---- PriceEOD (cena na koniec dnia) ---------------------------------- */
CREATE TABLE dbo.PriceEOD (
    InstrumentId VARCHAR(20)    NOT NULL,
    PriceDate    DATE           NOT NULL,
    ClosePrice   DECIMAL(18,6)  NOT NULL,
    CONSTRAINT PK_PriceEOD PRIMARY KEY (InstrumentId, PriceDate),
    CONSTRAINT FK_PriceEOD_Instrument FOREIGN KEY (InstrumentId) REFERENCES dbo.Instrument(InstrumentId)
);
GO

/* ---- Holding (pozycja funduszu w instrumencie na datę) --------------- */
CREATE TABLE dbo.Holding (
    HoldingId    INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Holding PRIMARY KEY,
    FundId       VARCHAR(20)   NOT NULL,
    InstrumentId VARCHAR(20)   NOT NULL,
    AsOfDate     DATE          NOT NULL,
    Quantity     DECIMAL(18,4) NOT NULL,   -- liczba jednostek / nominał
    CONSTRAINT FK_Holding_Fund       FOREIGN KEY (FundId)       REFERENCES dbo.Fund(FundId),
    CONSTRAINT FK_Holding_Instrument FOREIGN KEY (InstrumentId) REFERENCES dbo.Instrument(InstrumentId),
    CONSTRAINT UQ_Holding UNIQUE (FundId, InstrumentId, AsOfDate)
);
GO

/* ---- Subscription (nabycie jednostek przez inwestora) ---------------- */
CREATE TABLE dbo.Subscription (
    SubscriptionId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Subscription PRIMARY KEY,
    ShareClassId   VARCHAR(20)   NOT NULL,
    InvestorId     VARCHAR(20)   NOT NULL,
    TradeDate      DATE          NOT NULL,
    Units          DECIMAL(18,4) NOT NULL,   -- nabyte jednostki
    CONSTRAINT FK_Subscription_ShareClass FOREIGN KEY (ShareClassId) REFERENCES dbo.ShareClass(ShareClassId),
    CONSTRAINT FK_Subscription_Investor   FOREIGN KEY (InvestorId)   REFERENCES dbo.Investor(InvestorId)
);
GO

/* ---- Redemption (umorzenie jednostek przez inwestora) ---------------- */
CREATE TABLE dbo.Redemption (
    RedemptionId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Redemption PRIMARY KEY,
    ShareClassId VARCHAR(20)   NOT NULL,
    InvestorId   VARCHAR(20)   NOT NULL,
    TradeDate    DATE          NOT NULL,
    Units        DECIMAL(18,4) NOT NULL,   -- umorzone jednostki
    CONSTRAINT FK_Redemption_ShareClass FOREIGN KEY (ShareClassId) REFERENCES dbo.ShareClass(ShareClassId),
    CONSTRAINT FK_Redemption_Investor   FOREIGN KEY (InvestorId)   REFERENCES dbo.Investor(InvestorId)
);
GO

/* ---- Valuation (wycena / NAV klasy jednostek na datę) ---------------- */
CREATE TABLE dbo.Valuation (
    ValuationId   INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Valuation PRIMARY KEY,
    ShareClassId  VARCHAR(20)    NOT NULL,
    ValuationDate DATE           NOT NULL,
    NetAssetValue DECIMAL(20,4)  NOT NULL,  -- NAV całej klasy jednostek
    NavPerUnit    DECIMAL(18,6)  NOT NULL,  -- NAV na jednostkę (wyliczone i zapisane)
    CONSTRAINT FK_Valuation_ShareClass FOREIGN KEY (ShareClassId) REFERENCES dbo.ShareClass(ShareClassId),
    CONSTRAINT UQ_Valuation UNIQUE (ShareClassId, ValuationDate)
);
GO

/* ---- FeeAccrual (naliczenie opłat — poza zakresem MVP) --------------- */
CREATE TABLE dbo.FeeAccrual (
    FeeAccrualId  INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_FeeAccrual PRIMARY KEY,
    ShareClassId  VARCHAR(20)    NOT NULL,
    AccrualDate   DATE           NOT NULL,
    FeeType       VARCHAR(20)    NOT NULL,   -- MANAGEMENT | PERFORMANCE
    Amount        DECIMAL(20,4)  NOT NULL,
    CONSTRAINT FK_FeeAccrual_ShareClass FOREIGN KEY (ShareClassId) REFERENCES dbo.ShareClass(ShareClassId)
);
GO

/* ---- Indeksy pomocnicze pod typowe odczyty --------------------------- */
CREATE INDEX IX_Holding_FundDate    ON dbo.Holding(FundId, AsOfDate);
CREATE INDEX IX_Valuation_ClassDate ON dbo.Valuation(ShareClassId, ValuationDate);
CREATE INDEX IX_Sub_ClassDate       ON dbo.Subscription(ShareClassId, TradeDate);
CREATE INDEX IX_Red_ClassDate       ON dbo.Redemption(ShareClassId, TradeDate);
GO

/* ---- Konto odczytowe o najmniejszych uprawnieniach ------------------- */
/* Uwaga: hasło ustawiane jest poza repo (zmienna środowiskowa po stronie
   prowadzącego). Poniżej tylko schemat nadania praw — bez wpisanego hasła. */
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'workshop_reader')
BEGIN
    PRINT 'Utwórz login workshop_reader z hasłem ze zmiennej środowiskowej, np.:';
    PRINT '  CREATE LOGIN workshop_reader WITH PASSWORD = ''<z env>'';';
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'workshop_reader')
BEGIN
    -- CREATE USER workshop_reader FOR LOGIN workshop_reader;
    -- ALTER ROLE db_datareader ADD MEMBER workshop_reader;  -- tylko SELECT
    PRINT 'Po utworzeniu loginu: dodaj usera do roli db_datareader (tylko odczyt).';
END;
GO

PRINT 'Struktura bazy baseFunds utworzona.';
GO
