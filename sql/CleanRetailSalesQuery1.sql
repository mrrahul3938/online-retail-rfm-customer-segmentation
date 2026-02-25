--renaming clean_retail_1 to 'CleanRetailSales

USE RetailAnalytics;
EXEC sp_rename 'clean_retail_1', 'CleanRetailSales';
DROP TABLE IF EXISTS clean_retail_1;

SELECT TOP 10 * FROM CleanRetailSales;

ALTER TABLE CleanRetailSales
ALTER COLUMN YearMonth VARCHAR(7);

UPDATE CleanRetailSales
SET YearMonth = CONVERT(VARCHAR(7),InvoiceDate,120);

SELECT COUNT(*) FROM CleanRetailSales;

SELECT ROUND(SUM(Revenue),2) [Total Revenue] FROM CleanRetailSales WHERE Customer_ID IS NOT NULL ;

--which country contribute more in revenue 

SELECT Country, ROUND(SUM(Revenue),2) [Total Revenue] from CleanRetailSales 
GROUP BY Country
ORDER BY [Total Revenue] DESC;

--What is the Top 5 Customers by Revenue?

SELECT Customer_ID,ROUND(SUM(Revenue),2) [Total Revenue] FROM CleanRetailSales
WHERE Customer_ID is not null
GROUP BY Customer_ID
ORDER BY [Total Revenue] DESC 

SELECT Customer_ID, COUNT(DISTINCT Invoice) [Total Invoice] , SUM(Quantity) [Total Quantity]
, ROUND(SUM(Revenue),2) [Total Revenue] FROM CleanRetailSales
WHERE Customer_ID = 18102
GROUP BY Customer_ID 
ORDER BY [Total Revenue] DESC

--“Customer 18102 appears to be a high-volume wholesale buyer,
-- contributing ~3.5% of total revenue alone.”



--(Top 10 customers revenue

--Their combined revenue

--Percentage contribution to total revenue

--This tells us:

--Is business dependent on few customers?
-- Or is revenue diversified?)

SELECT ROUND(SUM(Revenue),2) FROM CleanRetailSales;

SELECT SUM(TotalRevenue)  FROM (
SELECT TOP 10 Customer_ID,ROUND(SUM(Revenue),2) [TotalRevenue] FROM CleanRetailSales
WHERE Customer_ID is not null
GROUP BY Customer_ID
ORDER BY [TotalRevenue] DESC
) AS TopCustomers; 

--total distinct customer_id

SELECT COUNT(DISTINCT Customer_ID) FROM CleanRetailSales

--using window function rank() for asigning rank to top customer

SELECT 
    Customer_ID,
    SUM(Revenue) AS TotalRevenue,
    RANK() OVER (ORDER BY SUM(Revenue) DESC) AS RevenueRank
FROM CleanRetailSales
WHERE Customer_ID IS NOT NULL
GROUP BY Customer_ID
ORDER BY SUM(Revenue) DESC;


--STARTING RFM ANALYSIS--

SELECT MAX(InvoiceDate) FROM CleanRetailSales;
--Latest invoce date in dataset is 2010-12-09 


SELECT Customer_ID, DATEDIFF(DAY,MAX(InvoiceDate),'2010-12-09') [Recency]
FROM CleanRetailSales
WHERE Customer_ID IS NOT NULL 
GROUP BY Customer_ID;

--count distinct invoice
SELECT COUNT(DISTINCT Invoice) FROM CleanRetailSales



--Final Combined RFM Query--


WITH RFM AS (
  SELECT
    Customer_ID,
    
    -- Recency (days since last purchase)
    DATEDIFF(
        DAY,
        MAX(InvoiceDate),
        (SELECT MAX(InvoiceDate) FROM CleanRetailSales)
    ) AS Recency,
    
    -- Frequency (number of invoices)
    COUNT(DISTINCT Invoice) AS Frequency,
    
    -- Monetary (total revenue)
    ROUND(SUM(Revenue),2) AS Monetary

FROM CleanRetailSales
WHERE Customer_ID IS NOT NULL
GROUP BY Customer_ID
)
 
 SELECT 
       MIN(Recency) [MinRecency],
       MAX(Recency) [MaxRecency],
       AVG(Frequency) [AvgFrequency],
       MAX(Monetary) [MaxMonetary]
FROM RFM;

-- RFM SCORING QUERY --


WITH RFM_Base AS (
    SELECT
        Customer_ID,
        DATEDIFF(
            DAY,
            MAX(InvoiceDate),
            (SELECT MAX(InvoiceDate) FROM CleanRetailSales)
        ) AS Recency,
        COUNT(DISTINCT Invoice) AS Frequency,
        SUM(Revenue) AS Monetary
    FROM CleanRetailSales
    WHERE Customer_ID IS NOT NULL
    GROUP BY Customer_ID
)

SELECT *,
    
    -- Recency Score (lower recency = higher score)
    NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
    
    -- Frequency Score
    NTILE(5) OVER (ORDER BY Frequency ASC) AS F_Score,
    
    -- Monetary Score
    NTILE(5) OVER (ORDER BY Monetary ASC) AS M_Score

FROM RFM_Base;


--CREATING SEGMENTS--

WITH RFM_Base AS (
    SELECT
        Customer_ID,
        DATEDIFF(
            DAY,
            MAX(InvoiceDate),
            (SELECT MAX(InvoiceDate) FROM CleanRetailSales)
        ) AS Recency,
        COUNT(DISTINCT Invoice) AS Frequency,
        SUM(Revenue) AS Monetary
    FROM CleanRetailSales
    WHERE Customer_ID IS NOT NULL
    GROUP BY Customer_ID
),

RFM_Score AS (
    
    SELECT *,
    
    -- Recency Score (lower recency = higher score)
    NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
    
    -- Frequency Score
    NTILE(5) OVER (ORDER BY Frequency ASC) AS F_Score,
    
    -- Monetary Score
    NTILE(5) OVER (ORDER BY Monetary ASC) AS M_Score

FROM RFM_Base) 

 SELECT *, 
      CASE 
         WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4 THEN 'Champions'
         WHEN R_Score >= 3 AND F_Score >=4 THEN 'Loyal Customers'
         WHEN R_Score = 5 AND F_Score <= 2 THEN 'New Customer'
         WHEN R_Score <=2 AND F_Score <=2 THEN 'Lost Customers'
         WHEN R_Score <=2 AND F_Score >=4 THEN 'At Risk'
         WHEN R_Score >=3 AND F_Score <=3 THEN 'Potential Loyalist'
         ELSE 'Others'
     END [Customer_Segment]
FROM RFM_Score;

--STEP C SEGMENT DISTRIBUTION 

WITH RFM_Base AS (
    SELECT
        Customer_ID,
        DATEDIFF(
            DAY,
            MAX(InvoiceDate),
            (SELECT MAX(InvoiceDate) FROM CleanRetailSales)
        ) AS Recency,
        COUNT(DISTINCT Invoice) AS Frequency,
        SUM(Revenue) AS Monetary
    FROM CleanRetailSales
    WHERE Customer_ID IS NOT NULL
    GROUP BY Customer_ID
),

RFM_Score AS (
    
    SELECT *,
    
    -- Recency Score (lower recency = higher score)
    NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
    
    -- Frequency Score
    NTILE(5) OVER (ORDER BY Frequency ASC) AS F_Score,
    
    -- Monetary Score
    NTILE(5) OVER (ORDER BY Monetary ASC) AS M_Score

FROM RFM_Base
),
RFM_Segment AS (

   SELECT *, 
      CASE 
         WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4 THEN 'Champions'
         WHEN R_Score >= 3 AND F_Score >=4 THEN 'Loyal Customers'
         WHEN R_Score = 5 AND F_Score <= 2 THEN 'New Customer'
         WHEN R_Score <=2 AND F_Score <=2 THEN 'Lost Customers'
         WHEN R_Score <=2 AND F_Score >=4 THEN 'At Risk'
         WHEN R_Score >=3 AND F_Score <=3 THEN 'Potential Loyalist'
         ELSE 'Others'
     END [Customer_Segment]
FROM RFM_Score
)

SELECT 
     Customer_Segment,
     COUNT(*) [Total_Customers]
FROM RFM_Segment
GROUP BY Customer_Segment
ORDER BY Total_Customers DESC;


--Revenue Contribution by Segment

WITH RFM_Base AS (
    SELECT
        Customer_ID,
        DATEDIFF(
            DAY,
            MAX(InvoiceDate),
            (SELECT MAX(InvoiceDate) FROM CleanRetailSales)
        ) AS Recency,
        COUNT(DISTINCT Invoice) AS Frequency,
        ROUND(SUM(Revenue),2) AS Monetary
    FROM CleanRetailSales
    WHERE Customer_ID IS NOT NULL
    GROUP BY Customer_ID
),

RFM_Score AS (
    
    SELECT *,
          NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
          NTILE(5) OVER (ORDER BY Frequency ASC) AS F_Score,
          NTILE(5) OVER (ORDER BY Monetary ASC) AS M_Score
    FROM RFM_Base
),
RFM_Segment AS (

   SELECT *, 
      CASE 
         WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4 THEN 'Champions'
         WHEN R_Score >= 3 AND F_Score >=4 THEN 'Loyal Customers'
         WHEN R_Score = 5 AND F_Score <= 2 THEN 'New Customer'
         WHEN R_Score <=2 AND F_Score <=2 THEN 'Lost Customers'
         WHEN R_Score <=2 AND F_Score >=4 THEN 'At Risk'
         WHEN R_Score >=3 AND F_Score <=3 THEN 'Potential Loyalist'
         ELSE 'Others'
     END [Customer_Segment]
FROM RFM_Score
)
 
 SELECT 
    Customer_Segment,
    COUNT(Customer_ID) AS Total_Customers,
    ROUND(SUM(Monetary),2) AS Total_Revenue,
    ROUND(
         SUM(Monetary) * 100.0 / 
         SUM(SUM(Monetary)) OVER(),2)
         AS Revenue_Percentage
         
FROM RFM_Segment
GROUP BY Customer_Segment
ORDER BY Total_Revenue DESC;


--Creating a RFM view 

CREATE VIEW RFM_Final AS


WITH RFM_Base AS (
    SELECT
        Customer_ID,
        DATEDIFF(
            DAY,
            MAX(InvoiceDate),
            (SELECT MAX(InvoiceDate) FROM CleanRetailSales)
        ) AS Recency,
        COUNT(DISTINCT Invoice) AS Frequency,
        ROUND(SUM(Revenue),2) AS Monetary
    FROM CleanRetailSales
    WHERE Customer_ID IS NOT NULL
    GROUP BY Customer_ID
),

RFM_Score AS (
    
    SELECT *,
    
    NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
    NTILE(5) OVER (ORDER BY Frequency ASC) AS F_Score,
    NTILE(5) OVER (ORDER BY Monetary ASC) AS M_Score

FROM RFM_Base) 

 SELECT *, 
      CASE 
         WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4 THEN 'Champions'
         WHEN R_Score >= 3 AND F_Score >=4 THEN 'Loyal Customers'
         WHEN R_Score = 5 AND F_Score <= 2 THEN 'New Customer'
         WHEN R_Score <=2 AND F_Score <=2 THEN 'Lost Customers'
         WHEN R_Score <=2 AND F_Score >=4 THEN 'At Risk'
         WHEN R_Score >=3 AND F_Score <=3 THEN 'Potential Loyalist'
         ELSE 'Others'
     END [Customer_Segment]
FROM RFM_Score;


SELECT * FROM RFM_Final;