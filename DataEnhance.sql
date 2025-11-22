
/* ===============================
   0. PARAMETRELER
   =============================== */

DECLARE @StartYear INT = 2026;
DECLARE @EndYear   INT = 2028;
DECLARE @PolicyCount INT = 1000;    -- üretilecek policy sayýsý
DECLARE @MonthsPerPolicy INT = 12;  -- her policy için kaç raporlama ayý

/* ===============================
   1. DIM CUSTOMER SEED (60 müþteri)
   Tablo: dbo.Customers
   Kolonlar: Customer_ID, Customer_Name, Country, Location
   =============================== */
DELETE FROM dbo.SAP_Postings;
DELETE FROM dbo.IFRS17_Engine;



;WITH N AS (
    SELECT TOP (60) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects
)
INSERT INTO dbo.Customers (Customer_ID, Customer_Name, Country, Location)
SELECT
    CONCAT('C-', RIGHT('000', 3 - LEN(n)) + CAST(n AS VARCHAR(3))) AS Customer_ID,
    CONCAT('Customer ', RIGHT('000', 3 - LEN(n)) + CAST(n AS VARCHAR(3))) AS Customer_Name,
    CASE (n % 4)
        WHEN 1 THEN 'UK'
        WHEN 2 THEN 'Germany'
        WHEN 3 THEN 'Turkey'
        ELSE 'Spain'
    END AS Country,
    CASE (n % 4)
        WHEN 1 THEN 'London'
        WHEN 2 THEN 'Berlin'
        WHEN 3 THEN 'Istanbul'
        ELSE 'Madrid'
    END AS Location
FROM N
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Customers c
    WHERE c.Customer_ID = CONCAT('C-', RIGHT('000', 3 - LEN(N.n)) + CAST(N.n AS VARCHAR(3)))
);

/* ===============================
   2. DIM PRODUCT SEED (6 ürün)
   Tablo: dbo.Products
   Kolonlar: Product_ID, Product_Name, Product_Type, Regulatory_Framework
   =============================== */

INSERT INTO dbo.Products (Product_ID, Product_Name, Product_Type, Regulatory_Framework)
SELECT * FROM (
    VALUES
    ('PR-01', 'Travel Basic',     'Travel',  'IFRS17'),
    ('PR-02', 'Travel Plus',      'Travel',  'IFRS17'),
    ('PR-03', 'Health Standard',  'Health',  'IFRS17'),
    ('PR-04', 'Motor Full',       'Motor',   'IFRS17'),
    ('PR-05', 'Home Secure',      'Home',    'IFRS17'),
    ('PR-06', 'Gadget Protect',   'Gadget',  'IFRS17')
) AS P(Product_ID, Product_Name, Product_Type, Regulatory_Framework)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Products p2 WHERE p2.Product_ID = P.Product_ID
);

/* ===============================
   3. 1000 POLICY ÜRET
   Tablo: dbo.CRM_Policies
   Varsayýlan kolonlar:
      Policy_ID, Customer_ID, Product_ID,
      Policy_Start_Date, Policy_End_Date,
      Premium_Amount, Risk_Exposure_Category
   =============================== */

;WITH Tally AS (
    SELECT TOP (@PolicyCount)
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects
),
Years AS (
    SELECT DISTINCT year_val
    FROM (
        SELECT @StartYear AS year_val
        UNION ALL SELECT @StartYear+1
        UNION ALL SELECT @StartYear+2
        UNION ALL SELECT @StartYear+3
        UNION ALL SELECT @StartYear+4
        UNION ALL SELECT @StartYear+5
    ) y
)
INSERT INTO dbo.CRM_Policies (
      Policy_ID,
      Customer_ID,
      Product_ID,
      Policy_Start_Date,
      Policy_End_Date,
      Premium_Amount,
      Risk_Exposure_Category
)
SELECT
    CONCAT('P-', RIGHT('0000', 4 - LEN(t.n)) + CAST(t.n AS VARCHAR(4))) AS Policy_ID,
    c.Customer_ID,
    p.Product_ID,
    -- random start date between 1 Jan 2023 and 31 Dec 2028
    DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 365,
            DATEFROMPARTS(@StartYear + (ABS(CHECKSUM(NEWID())) % (@EndYear - @StartYear + 1)), 1, 1)
    ) AS Policy_Start_Date,
    -- end date: start + 12 months - 1 day
    DATEADD(DAY, -1,
        DATEADD(MONTH, 12,
            DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 365,
                DATEFROMPARTS(@StartYear + (ABS(CHECKSUM(NEWID())) % (@EndYear - @StartYear + 1)), 1, 1)
            )
        )
    ) AS Policy_End_Date,
    -- premium between 5k and 50k
    5000 + (ABS(CHECKSUM(NEWID())) % 45000) AS Premium_Amount,
    CASE ABS(CHECKSUM(NEWID())) % 3
        WHEN 0 THEN 'Low'
        WHEN 1 THEN 'Medium'
        ELSE 'High'
    END AS Risk_Exposure_Category
FROM Tally t
CROSS JOIN (
    SELECT TOP 1 c1.Customer_ID
    FROM dbo.Customers c1
) c_seed
CROSS APPLY (
    SELECT TOP 1 c2.Customer_ID
    FROM dbo.Customers c2
    ORDER BY NEWID()
) c
CROSS APPLY (
    SELECT TOP 1 p2.Product_ID
    FROM dbo.Products p2
    ORDER BY NEWID()
) p
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.CRM_Policies cp
    WHERE cp.Policy_ID = CONCAT('P-', RIGHT('0000', 4 - LEN(t.n)) + CAST(t.n AS VARCHAR(4)))
);

/* ===============================
   4. SAP_POSTINGS (her policy için 12 ay)
   Tablo: dbo.SAP_Postings
   Kolonlar: Policy_ID, Reporting_Date,
             Claim_Amount, Commission_Amount
   =============================== */

;WITH Policies AS (
    SELECT Policy_ID,
           Policy_Start_Date,
           DATEADD(MONTH, 12, Policy_Start_Date) AS Coverage_End
    FROM dbo.CRM_Policies
),
MonthTally AS (
    SELECT TOP (@MonthsPerPolicy)
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS m
    FROM sys.all_objects
)
INSERT INTO dbo.SAP_Postings (
      Policy_ID,
      Reporting_Date,
      Claim_Amount,
      Commission_Amount
)
SELECT
    p.Policy_ID,
    DATEADD(MONTH, mt.m, EOMONTH(p.Policy_Start_Date)) AS Reporting_Date,
    -- claims: 0–20% of premium randomly
    ROUND((ABS(CHECKSUM(NEWID())) % 20) / 100.0
          * (5000 + (ABS(CHECKSUM(NEWID())) % 45000)), 2) AS Claim_Amount,
    -- commission: 5–15% of premium randomly
    ROUND((5 + (ABS(CHECKSUM(NEWID())) % 10)) / 100.0
          * (5000 + (ABS(CHECKSUM(NEWID())) % 45000)), 2) AS Commission_Amount
FROM Policies p
CROSS JOIN MonthTally mt;

/* ===============================
   5. IFRS17_Engine (her policy + ay için UPR, LRC, LIC, Revenue)
   Tablo: dbo.IFRS17_Engine
   Kolonlar (senin view’lerine göre):
       Policy_ID,
       Reporting_Date,
       Unearned_Premium_Reserve,
       Liability_Remaining_Coverage,
       Liability_Incurred_Claims,
       Revenue_Recognised
   =============================== */


;WITH P AS (
    SELECT Policy_ID, Policy_Start_Date, Policy_End_Date, Premium_Amount
    FROM dbo.CRM_Policies
),
M AS (
    SELECT TOP (@MonthsPerPolicy)
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS m
    FROM sys.all_objects
),
Schedule AS (
    SELECT
        p.Policy_ID,
        DATEADD(MONTH, M.m, EOMONTH(p.Policy_Start_Date)) AS Reporting_Date,
        p.Premium_Amount,
        DATEDIFF(DAY, p.Policy_Start_Date, p.Policy_End_Date) + 1 AS TotalDays,
        DATEDIFF(DAY, p.Policy_Start_Date, DATEADD(MONTH, M.m, EOMONTH(p.Policy_Start_Date))) + 1 AS ElapsedDays
    FROM P
    CROSS JOIN M
)
INSERT INTO dbo.IFRS17_Engine (
      Policy_ID,
      Reporting_Date,
      Unearned_Premium_Reserve ,
      Liability_Remaining_Coverage,
      Liability_Incurred_Claims,
      Revenue_Recognised
)
SELECT
    Policy_ID,
    Reporting_Date,
    -- UPR: Remaining fraction of premium
(CASE    WHEN TotalDays <= 0 THEN 0     ELSE CAST(Premium_Amount * (1.0 - (ElapsedDays * 1.0 / TotalDays)) AS DECIMAL(18,2)) END ) AS  UPR,
    -- LRC: assume 60% of remaining premium
(CASE  WHEN TotalDays <= 0 THEN 0 ELSE CAST(Premium_Amount * 0.60 * (1.0 - (ElapsedDays * 1.0 / NULLIF(TotalDays,1))) AS DECIMAL(14,2))END ) AS LRC,
    -- LIC: assume 40% of elapsed premium
 (CASE  WHEN TotalDays <= 0 THEN 0 ELSE   CAST(Premium_Amount * 0.40 * (ElapsedDays * 1.0 / NULLIF(TotalDays,1)) AS DECIMAL(14,2)) END) AS LIC,
    -- Revenue: straight-line recognition
 (CASE  WHEN TotalDays <= 0 THEN 0 ELSE    CAST(Premium_Amount * (ElapsedDays * 1.0 / NULLIF(TotalDays,1)) AS DECIMAL(14,2)) END ) AS Revenue_Recognised
FROM Schedule;


