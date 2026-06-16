/* =====================================================================
   baseFunds — dane SYNTETYCZNE (zmyślone) na potrzeby warsztatu.
   Wszystko deterministyczne, aby wynik dało się zweryfikować ręcznie.

   Skala: 3 fundusze, 2-3 klasy/fundusz, 20 inwestorów,
          8 instrumentów, 90 dni cen i wycen (2025-01-02 .. 2025-04-01).

   Niezmiennik utrzymywany przez ten skrypt:
     NetAssetValue = NavPerUnit * (Σ Subscription.Units − Σ Redemption.Units do daty)
     => NavPerUnit = NetAssetValue / jednostki w obrocie  (DOKŁADNIE)

   Uruchomienie:
     sqlcmd -S localhost,1433 -U sa -P "$SA_PASSWORD" -d baseFunds -i db/seed.sql
   ===================================================================== */

USE baseFunds;
GO

SET NOCOUNT ON;

/* ---- Czyszczenie danych (idempotentnie) ----------------------------- */
DELETE FROM dbo.FeeAccrual;
DELETE FROM dbo.Valuation;
DELETE FROM dbo.Redemption;
DELETE FROM dbo.Subscription;
DELETE FROM dbo.Holding;
DELETE FROM dbo.PriceEOD;
DELETE FROM dbo.Instrument;
DELETE FROM dbo.Investor;
DELETE FROM dbo.ShareClass;
DELETE FROM dbo.Fund;
GO

/* ---- Fund ------------------------------------------------------------ */
INSERT INTO dbo.Fund (FundId, Name, BaseCurrency, InceptionDate) VALUES
 ('FUND-A', N'Global Equity Fund',   'EUR', '2024-12-31'),
 ('FUND-B', N'US Opportunities Fund','USD', '2024-12-31'),
 ('FUND-C', N'UK Income Fund',       'GBP', '2024-12-31');

/* ---- ShareClass ------------------------------------------------------ */
INSERT INTO dbo.ShareClass
 (ShareClassId, FundId, Name, Currency, ManagementFeeBps, PerformanceFeeBps, HurdleRateBps) VALUES
 ('FUND-A-ACC',  'FUND-A', N'Klasa A (akumulacyjna)',   'EUR', 150, 2000, 500),
 ('FUND-A-DIS',  'FUND-A', N'Klasa A (dystrybucyjna)',  'EUR', 150, 2000, 500),
 ('FUND-B-ACC',  'FUND-B', N'Klasa A (akumulacyjna)',   'USD', 175, 2000, 600),
 ('FUND-B-INST', 'FUND-B', N'Klasa I (instytucjonalna)','USD',  90, 1500, 600),
 ('FUND-B-DIS',  'FUND-B', N'Klasa A (dystrybucyjna)',  'USD', 175, 2000, 600),
 ('FUND-C-ACC',  'FUND-C', N'Klasa A (akumulacyjna)',   'GBP', 125, 1000, 400),
 ('FUND-C-INST', 'FUND-C', N'Klasa I (instytucjonalna)','GBP',  70,  800, 400);

/* ---- Investor (20) --------------------------------------------------- */
INSERT INTO dbo.Investor (InvestorId, Name, Country) VALUES
 ('INV-001', N'Northwind Pension Trust',   'SE'),
 ('INV-002', N'Birch Capital Partners',    'GB'),
 ('INV-003', N'Lindgren Family Office',    'SE'),
 ('INV-004', N'Helvetia Insurance Group',  'CH'),
 ('INV-005', N'Aurora Wealth Mgmt',        'NO'),
 ('INV-006', N'Meridian Endowment',        'US'),
 ('INV-007', N'Cascade Holdings',          'US'),
 ('INV-008', N'Granite State Foundation',  'US'),
 ('INV-009', N'Polaris Institutional',     'FI'),
 ('INV-010', N'Delta Sovereign Fund',      'AE'),
 ('INV-011', N'Maple Asset Mgmt',          'CA'),
 ('INV-012', N'Solis Private Bank',        'ES'),
 ('INV-013', N'Thistle Pension Scheme',    'GB'),
 ('INV-014', N'Camden Mutual',             'GB'),
 ('INV-015', N'Severn Trust',              'GB'),
 ('INV-016', N'Orchard Capital',           'IE'),
 ('INV-017', N'Bluefin Advisors',          'GB'),
 ('INV-018', N'Kestrel Holdings',          'GB'),
 ('INV-019', N'Vanguard Heights LLC',      'US'),
 ('INV-020', N'Tamesis Investments',       'GB');

/* ---- Instrument (8) -------------------------------------------------- */
INSERT INTO dbo.Instrument (InstrumentId, Name, AssetClass, Currency) VALUES
 ('INSTR-001', N'Helios Industries',  'EQUITY', 'EUR'),
 ('INSTR-002', N'Aurora Tech',        'EQUITY', 'USD'),
 ('INSTR-003', N'Nordwind Energy',    'EQUITY', 'EUR'),
 ('INSTR-004', N'Govt Bond 2030',     'BOND',   'EUR'),
 ('INSTR-005', N'Corp Bond Helios',   'BOND',   'USD'),
 ('INSTR-006', N'Meridian Pharma',    'EQUITY', 'GBP'),
 ('INSTR-007', N'Cascade Retail',     'EQUITY', 'GBP'),
 ('INSTR-008', N'EUR Cash',           'CASH',   'EUR');

/* ---- Kalendarz 90 dni (Idx 0..89) ----------------------------------- */
IF OBJECT_ID('tempdb..#cal') IS NOT NULL DROP TABLE #cal;
CREATE TABLE #cal (ValuationDate DATE NOT NULL, Idx INT NOT NULL);

;WITH days AS (
    SELECT 0 AS Idx, CAST('2025-01-02' AS DATE) AS d
    UNION ALL
    SELECT Idx + 1, DATEADD(DAY, 1, d) FROM days WHERE Idx < 89
)
INSERT INTO #cal (ValuationDate, Idx)
SELECT d, Idx FROM days OPTION (MAXRECURSION 100);

/* ---- PriceEOD: ClosePrice = BasePrice * (1 + 0.001 * Idx) ------------ */
DECLARE @instr TABLE (InstrumentId VARCHAR(20), BasePrice DECIMAL(18,6));
INSERT INTO @instr VALUES
 ('INSTR-001', 120),
 ('INSTR-002', 85),
 ('INSTR-003', 64),
 ('INSTR-004', 98),
 ('INSTR-005', 101),
 ('INSTR-006', 47),
 ('INSTR-007', 33),
 ('INSTR-008', 1);

INSERT INTO dbo.PriceEOD (InstrumentId, PriceDate, ClosePrice)
SELECT i.InstrumentId, c.ValuationDate,
       CAST(i.BasePrice * (1 + 0.001 * c.Idx) AS DECIMAL(18,6))
FROM @instr i CROSS JOIN #cal c;

/* ---- Holding: stałe pozycje per fundusz, replikowane na każdy dzień -- */
DECLARE @hold TABLE (FundId VARCHAR(20), InstrumentId VARCHAR(20), Quantity DECIMAL(18,4));
INSERT INTO @hold VALUES
 -- FUND-A
 ('FUND-A','INSTR-001', 5000),
 ('FUND-A','INSTR-002', 8000),
 ('FUND-A','INSTR-003', 12000),
 ('FUND-A','INSTR-004', 3000),
 ('FUND-A','INSTR-005', 2000),
 ('FUND-A','INSTR-008', 50000),
 -- FUND-B
 ('FUND-B','INSTR-002', 15000),
 ('FUND-B','INSTR-005', 9000),
 ('FUND-B','INSTR-001', 4000),
 ('FUND-B','INSTR-004', 6000),
 ('FUND-B','INSTR-007', 10000),
 ('FUND-B','INSTR-008', 30000),
 -- FUND-C
 ('FUND-C','INSTR-006', 20000),
 ('FUND-C','INSTR-007', 25000),
 ('FUND-C','INSTR-003', 5000),
 ('FUND-C','INSTR-001', 2000),
 ('FUND-C','INSTR-004', 4000),
 ('FUND-C','INSTR-008', 20000);

INSERT INTO dbo.Holding (FundId, InstrumentId, AsOfDate, Quantity)
SELECT h.FundId, h.InstrumentId, c.ValuationDate, h.Quantity
FROM @hold h CROSS JOIN #cal c;

/* ---- Subscription / Redemption -------------------------------------- */
INSERT INTO dbo.Subscription (ShareClassId, InvestorId, TradeDate, Units) VALUES
 -- FUND-A-ACC
 ('FUND-A-ACC',  'INV-001', '2025-01-02', 100000),
 ('FUND-A-ACC',  'INV-002', '2025-01-02', 50000),
 ('FUND-A-ACC',  'INV-003', '2025-02-01', 25000),
 -- FUND-A-DIS
 ('FUND-A-DIS',  'INV-004', '2025-01-02', 40000),
 ('FUND-A-DIS',  'INV-005', '2025-01-15', 20000),
 -- FUND-B-ACC
 ('FUND-B-ACC',  'INV-006', '2025-01-02', 80000),
 ('FUND-B-ACC',  'INV-007', '2025-01-02', 30000),
 ('FUND-B-ACC',  'INV-019', '2025-02-15', 15000),
 -- FUND-B-INST
 ('FUND-B-INST', 'INV-009', '2025-01-02', 200000),
 ('FUND-B-INST', 'INV-010', '2025-01-02', 150000),
 -- FUND-B-DIS
 ('FUND-B-DIS',  'INV-011', '2025-01-02', 60000),
 ('FUND-B-DIS',  'INV-012', '2025-01-02', 25000),
 -- FUND-C-ACC
 ('FUND-C-ACC',  'INV-013', '2025-01-02', 70000),
 ('FUND-C-ACC',  'INV-014', '2025-01-02', 30000),
 ('FUND-C-ACC',  'INV-020', '2025-03-01', 10000),
 -- FUND-C-INST
 ('FUND-C-INST', 'INV-016', '2025-01-02', 120000),
 ('FUND-C-INST', 'INV-017', '2025-01-02', 90000),
 ('FUND-C-INST', 'INV-018', '2025-01-02', 40000);

INSERT INTO dbo.Redemption (ShareClassId, InvestorId, TradeDate, Units) VALUES
 ('FUND-A-ACC', 'INV-002', '2025-03-01', 10000),
 ('FUND-B-DIS', 'INV-011', '2025-02-20', 5000),
 ('FUND-C-INST','INV-018', '2025-03-15', 15000);

/* ---- Valuation: NAV per klasy/dzień, niezmiennik utrzymany ----------- */
DECLARE @cls TABLE (ShareClassId VARCHAR(20), BaseNav DECIMAL(18,6), DriftPerDay DECIMAL(18,6));
INSERT INTO @cls VALUES
 ('FUND-A-ACC',  100.000000,  0.080000),
 ('FUND-A-DIS',  100.000000,  0.050000),
 ('FUND-B-ACC',  150.000000,  0.120000),
 ('FUND-B-INST', 150.000000,  0.130000),
 ('FUND-B-DIS',  100.000000,  0.060000),
 ('FUND-C-ACC',  200.000000, -0.040000),
 ('FUND-C-INST', 200.000000, -0.030000);

INSERT INTO dbo.Valuation (ShareClassId, ValuationDate, NetAssetValue, NavPerUnit)
SELECT p.ShareClassId,
       c.ValuationDate,
       CAST(ROUND((p.BaseNav + p.DriftPerDay * c.Idx) * u.Units, 4) AS DECIMAL(20,4)) AS NetAssetValue,
       CAST(p.BaseNav + p.DriftPerDay * c.Idx AS DECIMAL(18,6))                       AS NavPerUnit
FROM @cls p
CROSS JOIN #cal c
CROSS APPLY (
    SELECT Units =
        ISNULL((SELECT SUM(s.Units) FROM dbo.Subscription s
                 WHERE s.ShareClassId = p.ShareClassId AND s.TradeDate <= c.ValuationDate), 0)
      - ISNULL((SELECT SUM(r.Units) FROM dbo.Redemption r
                 WHERE r.ShareClassId = p.ShareClassId AND r.TradeDate <= c.ValuationDate), 0)
) u
WHERE u.Units > 0;

/* ---- FeeAccrual: kilka wierszy (poza zakresem MVP, dla kompletności) - */
INSERT INTO dbo.FeeAccrual (ShareClassId, AccrualDate, FeeType, Amount)
SELECT v.ShareClassId, v.ValuationDate, 'MANAGEMENT',
       CAST(v.NetAssetValue * 150.0 / 10000.0 / 365.0 AS DECIMAL(20,4))
FROM dbo.Valuation v
WHERE v.ValuationDate IN ('2025-01-31','2025-02-28','2025-03-31');

DROP TABLE #cal;

PRINT 'Dane syntetyczne wczytane.';
GO

/* ---- Szybka weryfikacja niezmiennika (opcjonalnie) ------------------- */
SELECT TOP 5
       v.ShareClassId, v.ValuationDate, v.NetAssetValue, v.NavPerUnit,
       CAST(v.NetAssetValue / NULLIF(
            (SELECT ISNULL(SUM(s.Units),0) FROM dbo.Subscription s
              WHERE s.ShareClassId = v.ShareClassId AND s.TradeDate <= v.ValuationDate)
          - (SELECT ISNULL(SUM(r.Units),0) FROM dbo.Redemption r
              WHERE r.ShareClassId = v.ShareClassId AND r.TradeDate <= v.ValuationDate), 0)
        AS DECIMAL(18,6)) AS NavPerUnit_Recomputed
FROM dbo.Valuation v
WHERE v.ShareClassId = 'FUND-A-ACC'
ORDER BY v.ValuationDate;
GO
