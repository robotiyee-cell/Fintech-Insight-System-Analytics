
--------------------------------------------------------------
--  View: Monthly Aggregations for trend charts in Power BI
--------------------------------------------------------------
CREATE VIEW dbo.DW_IFRS_FCA_Monthly AS
SELECT
    s.Reporting_Date,
    p.Product_Type,
    c.Risk_Exposure_Category,
    cu.Country,
    COUNT(DISTINCT c.Policy_ID) AS Policies,
    SUM(s.Claim_Amount)         AS Total_Claims,
    SUM(s.Commission_Amount)    AS Total_Commissions,
    SUM(r.Unearned_Premium_Reserve)     AS Total_UPR,
    SUM(r.Liability_Remaining_Coverage) AS Total_LRC,
    SUM(r.Liability_Incurred_Claims)    AS Total_LIC,
    SUM(r.Revenue_Recognised)           AS Total_Revenue,
    -- A simple claims ratio using available data (Premium approximation via Revenue+UPR)
    CASE 
      WHEN (SUM(r.Revenue_Recognised) + NULLIF(SUM(r.Unearned_Premium_Reserve),0)) = 0 THEN 0
      ELSE SUM(s.Claim_Amount) / (SUM(r.Revenue_Recognised) + NULLIF(SUM(r.Unearned_Premium_Reserve),0))
    END AS Claims_Ratio
FROM dbo.CRM_Policies c
JOIN dbo.Products p   ON p.Product_ID  = c.Product_ID
JOIN dbo.Customers cu ON cu.Customer_ID = c.Customer_ID
JOIN dbo.SAP_Postings s ON s.Policy_ID  = c.Policy_ID
JOIN dbo.DW_IFRS_FCA_Report r ON r.Policy_ID = c.Policy_ID AND r.Reporting_Date = s.Reporting_Date
GROUP BY s.Reporting_Date, p.Product_Type, c.Risk_Exposure_Category, cu.Country;
