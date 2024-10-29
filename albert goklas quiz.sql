WITH TotalSales AS (
    -- Step 1: Calculate total sales and transaction frequency by item
    SELECT 
        item_description,
        SUM(sale_dollars) AS TotalSales,
        SUM(bottles_sold) AS TransactionFrequency
    FROM iowa_drink_sales
    GROUP BY item_description
),
TotalSalesWithShares AS (
    -- Step 2: Calculate share of sales and share of frequency
    SELECT 
        item_description,
        TotalSales,
        TransactionFrequency,
        TotalSales / (SELECT SUM(TotalSales) FROM TotalSales) * 100 AS ShareSales,
        TransactionFrequency / (SELECT SUM(TransactionFrequency) FROM TotalSales) * 100 AS ShareFrequency
    FROM TotalSales
),
CumulativeSales AS (
    -- Step 3: Calculate cumulative sales and cumulative frequency
    SELECT 
        item_description,
        TotalSales,
        ShareSales,
        TransactionFrequency,
        ShareFrequency,
        SUM(ShareSales) OVER (ORDER BY ShareSales DESC) AS CumulativeSales,
        SUM(ShareFrequency) OVER (ORDER BY ShareFrequency DESC) AS CumulativeFrequency
    FROM TotalSalesWithShares
)
-- Step 4: Assign ABC and XYZ categories and calculate final columns
SELECT 
    item_description AS Product,
    TotalSales AS Sales,
    ShareSales,
    CumulativeSales,
    ShareFrequency,
    CumulativeFrequency,
    -- Assign ABC categories based on cumulative sales
    CASE 
        WHEN CumulativeSales <= 80 THEN 'A'
        WHEN CumulativeSales > 80 AND CumulativeSales <= 95 THEN 'B'
        ELSE 'C'
    END AS SalesCategory,
    -- Assign XYZ categories based on transaction frequency
    CASE
        WHEN TransactionFrequency <= 50 THEN 'X'
        WHEN TransactionFrequency > 50 AND TransactionFrequency <= 200 THEN 'Y'
        ELSE 'Z'
    END AS ProductCategory,
    -- Calculate CumSalesShare * CumTransactionShare
    CumulativeSales * CumulativeFrequency AS CumSalesShareCumTransactionShare,
    -- Combine SalesCategory and ProductCategory for 'Procutfreqqu'
    CASE
        WHEN CumulativeSales <= 80 AND TransactionFrequency <= 50 THEN 'AX'
        WHEN CumulativeSales > 80 AND CumulativeSales <= 95 AND TransactionFrequency > 50 AND TransactionFrequency <= 200 THEN 'BY'
        ELSE 'BZ'
    END AS Procutfreqqu
FROM CumulativeSales
ORDER BY CumulativeSales;
