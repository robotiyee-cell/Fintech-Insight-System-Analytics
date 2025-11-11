--------------------------------------------------------------
--  View: Detailed IFRS/FCA Report (policy-month)
--  Calculates UPR, LRC, LIC, Revenue_Recognised dynamically
--------------------------------------------------------------
CREATE VIEW dbo.DW_IFRS_FCA_Report AS
SELECT
    c.Policy_ID,
    c.Customer_ID,
    cu.Customer_Name,
    cu.Country,
    cu.Location,
    p.Product_ID,
    p.Product_Name,
    p.Product_Type,
    p.Regulatory_Framework,
    c.Risk_Exposure_Category,
    c.Policy_Start_Date,
    c.Policy_End_Date,
    c.Premium_Amount,
    s.Reporting_Date,
    s.Claim_Amount,
    s.Commission_Amount,
    s.Outstanding_Claim_Ratio,
    i.Discount_Rate,
    i.Fulfilment_Cash_Flows,
    i.Contractual_Service_Margin,
    i.Insurance_Contract_Liability_Gross,
    i.Reinsurance_Asset,

    -- Coverage 
    CASE 
        WHEN DATEDIFF(DAY, c.Policy_Start_Date, c.Policy_End_Date) = 0 THEN 0
        ELSE
            -- Remaining coverage at the reporting date
            CASE 
              WHEN DATEDIFF(DAY, s.Reporting_Date, c.Policy_End_Date) <= 0 THEN 0.0
              WHEN DATEDIFF(DAY, s.Reporting_Date, c.Policy_Start_Date) >= 0 THEN 1.0
              ELSE 
                 CAST(DATEDIFF(DAY, s.Reporting_Date, c.Policy_End_Date) AS FLOAT) /
                 NULLIF(CAST(DATEDIFF(DAY, c.Policy_Start_Date, c.Policy_End_Date) AS FLOAT),0)
            END
    END AS Remaining_Coverage_Fraction,

    -- UPR: Premium * remaining coverage
    CAST(
        c.Premium_Amount * 
        (
            CASE 
              WHEN DATEDIFF(DAY, c.Policy_Start_Date, c.Policy_End_Date) = 0 THEN 0.0
              WHEN DATEDIFF(DAY, s.Reporting_Date, c.Policy_End_Date) <= 0 THEN 0.0
              WHEN DATEDIFF(DAY, s.Reporting_Date, c.Policy_Start_Date) >= 0 THEN 1.0
              ELSE 
                 CAST(DATEDIFF(DAY, s.Reporting_Date, c.Policy_End_Date) AS FLOAT) /
                 NULLIF(CAST(DATEDIFF(DAY, c.Policy_Start_Date, c.Policy_End_Date) AS FLOAT),0)
            END
        ) AS DECIMAL(14,2)
    ) AS Unearned_Premium_Reserve,

    -- LRC = UPR + CSM
    CAST(
        (c.Premium_Amount *
            (CASE 
              WHEN DATEDIFF(DAY, c.Policy_Start_Date, c.Policy_End_Date) = 0 THEN 0.0
              WHEN DATEDIFF(DAY, s.Reporting_Date, c.Policy_End_Date) <= 0 THEN 0.0
              WHEN DATEDIFF(DAY, s.Reporting_Date, c.Policy_Start_Date) >= 0 THEN 1.0
              ELSE 
                 CAST(DATEDIFF(DAY, s.Reporting_Date, c.Policy_End_Date) AS FLOAT) /
                 NULLIF(CAST(DATEDIFF(DAY, c.Policy_Start_Date, c.Policy_End_Date) AS FLOAT),0)
            END)
         ) + i.Contractual_Service_Margin AS DECIMAL(14,2)
    ) AS Liability_Remaining_Coverage,

    -- LIC = Claim * Outstanding Ratio
    CAST(s.Claim_Amount * s.Outstanding_Claim_Ratio AS DECIMAL(14,2)) AS Liability_Incurred_Claims,

    -- Revenue Recognised = Premium – UPR
    CAST(
        c.Premium_Amount - 
        (c.Premium_Amount *
            (CASE 
              WHEN DATEDIFF(DAY, c.Policy_Start_Date, c.Policy_End_Date) = 0 THEN 0.0
              WHEN DATEDIFF(DAY, s.Reporting_Date, c.Policy_End_Date) <= 0 THEN 0.0
              WHEN DATEDIFF(DAY, s.Reporting_Date, c.Policy_Start_Date) >= 0 THEN 1.0
              ELSE 
                 CAST(DATEDIFF(DAY, s.Reporting_Date, c.Policy_End_Date) AS FLOAT) /
                 NULLIF(CAST(DATEDIFF(DAY, c.Policy_Start_Date, c.Policy_End_Date) AS FLOAT),0)
            END)
        ) AS DECIMAL(14,2)
    ) AS Revenue_Recognised
FROM dbo.CRM_Policies c
JOIN dbo.Products p  ON p.Product_ID  = c.Product_ID
JOIN dbo.Customers cu ON cu.Customer_ID = c.Customer_ID
JOIN dbo.SAP_Postings s ON s.Policy_ID = c.Policy_ID
JOIN dbo.IFRS17_Engine i ON i.Policy_ID = c.Policy_ID AND i.Reporting_Date = s.Reporting_Date;
