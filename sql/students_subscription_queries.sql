-- Query 1: Monthly MAU and revenue trend
-- Business use: CFO level overview dashboard
-- Key insight: When did decline start?
SELECT
    Month_Label,
    MAU,
    Search_Traffic_Index,
    New_Subscribers,
    Churned_Count,
    Revenue_USD,
    Avg_CSAT,
    Churn_Rate_Pct
FROM mau_monthly
ORDER BY Year, Month;


-- Query 2: Subscription funnel analysis
-- Business use: Where are students dropping off?
-- Funnel: Registered → Subscribed → Renewed → Retained
SELECT
    'Step 1: Registered'           AS Funnel_Stage,
    COUNT(DISTINCT Student_ID)      AS Count,
    100.0                           AS Pct_Of_Top
FROM students

UNION ALL

SELECT
    'Step 2: Subscribed',
    COUNT(DISTINCT Student_ID),
    ROUND(COUNT(DISTINCT Student_ID) * 100.0 /
        (SELECT COUNT(*) FROM students), 1)
FROM subscriptions

UNION ALL

SELECT
    'Step 3: Renewed (2+ times)',
    COUNT(DISTINCT Student_ID),
    ROUND(COUNT(DISTINCT Student_ID) * 100.0 /
        (SELECT COUNT(*) FROM students), 1)
FROM subscriptions
WHERE Renewal_Number >= 2

UNION ALL

SELECT
    'Step 4: Retained (Not Churned)',
    COUNT(DISTINCT Student_ID),
    ROUND(COUNT(DISTINCT Student_ID) * 100.0 /
        (SELECT COUNT(*) FROM students), 1)
FROM subscriptions
WHERE Churned = 'No';

-- Query 3: Churn analysis by subscription plan
-- Business use: Which plan retains students best?
SELECT
    Plan_Type,
    COUNT(*)                           AS Total_Subscriptions,
    SUM(CASE WHEN Churned = 'Yes'
             THEN 1 ELSE 0 END)        AS Churned_Count,
    SUM(CASE WHEN Churned = 'No'
             THEN 1 ELSE 0 END)        AS Retained_Count,
    ROUND(
        SUM(CASE WHEN Churned = 'Yes'
                 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*)
    , 1)                               AS Churn_Rate_Pct,
    ROUND(AVG(Days_Active), 1)         AS Avg_Days_Active,
    ROUND(AVG(Plan_Price_USD), 2)      AS Avg_Price,
    ROUND(SUM(Revenue_USD), 2)         AS Total_Revenue
FROM subscriptions
GROUP BY Plan_Type
ORDER BY Churn_Rate_Pct ASC;


-- Query 4: Why are students churning?
-- Business use: Product team needs to fix root cause
-- Pareto: Top reasons causing 80% of churn
SELECT
    Churn_Reason,
    COUNT(*)                           AS Churn_Count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER ()
    , 1)                               AS Pct_Of_Total,

    -- Cumulative percentage (Pareto)
    ROUND(
        SUM(COUNT(*)) OVER (
            ORDER BY COUNT(*) DESC
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) * 100.0 /
        SUM(COUNT(*)) OVER ()
    , 1)                               AS Cumulative_Pct,

    ROUND(AVG(Days_Active), 1)         AS Avg_Days_Before_Churn,
    ROUND(AVG(Plan_Price_USD), 2)      AS Avg_Plan_Price
FROM subscriptions
WHERE Churned     = 'Yes'
  AND Churn_Reason IS NOT NULL
GROUP BY Churn_Reason
ORDER BY Churn_Count DESC;


-- Query 5: Cohort churn analysis
-- Business use: Which batch of students churns fastest?
-- Cohort = group of students who subscribed same quarter
WITH cohorts AS (
    SELECT
        Student_ID,
        Plan_Type,
        Churned,
        Days_Active,
        Revenue_USD,
        CASE
            WHEN Sub_Start_Month < '2023-05'
                THEN 'Pre-AI (Before May 23)'
            WHEN Sub_Start_Month < '2023-11'
                THEN 'ChatGPT Impact (May-Oct 23)'
            WHEN Sub_Start_Month < '2024-01'
                THEN 'Steep Decline (Nov-Dec 23)'
            ELSE
                'Crisis Phase (2024)'
        END                            AS Cohort
    FROM subscriptions
)
SELECT
    Cohort,
    COUNT(*)                           AS Total_Students,
    SUM(CASE WHEN Churned = 'Yes'
             THEN 1 ELSE 0 END)        AS Churned,
    ROUND(
        SUM(CASE WHEN Churned = 'Yes'
                 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*)
    , 1)                               AS Churn_Rate_Pct,
    ROUND(100 -
        SUM(CASE WHEN Churned = 'Yes'
                 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*)
    , 1)                               AS Retention_Rate_Pct,
    ROUND(AVG(Days_Active), 1)         AS Avg_Days_Active,
    ROUND(SUM(Revenue_USD), 2)         AS Total_Revenue
FROM cohorts
GROUP BY Cohort
ORDER BY Churn_Rate_Pct ASC;


-- Query 6: Revenue impact of churn
-- Business use: CFO needs to see dollar impact
WITH monthly_revenue AS (
    SELECT
        Sub_Start_Month        AS Month_Label,
        Plan_Type,
        COUNT(*)               AS Total_Subs,
        SUM(Revenue_USD)       AS Actual_Revenue,
        -- What revenue would be if no churn
        SUM(Plan_Price_USD)    AS Expected_Revenue,
        SUM(CASE WHEN Churned = 'Yes'
                 THEN Plan_Price_USD - Revenue_USD
                 ELSE 0 END)   AS Revenue_Lost_To_Churn
    FROM subscriptions
    GROUP BY Sub_Start_Month, Plan_Type
)
SELECT
    Month_Label,
    Plan_Type,
    Total_Subs,
    ROUND(Actual_Revenue, 2)        AS Actual_Revenue,
    ROUND(Expected_Revenue, 2)      AS Expected_Revenue,
    ROUND(Revenue_Lost_To_Churn,2)  AS Revenue_Lost,
    ROUND(
        Revenue_Lost_To_Churn
        * 100.0 / Expected_Revenue
    , 1)                            AS Revenue_Loss_Pct
FROM monthly_revenue
ORDER BY Month_Label, Plan_Type;


-- Query 7: Does low activity predict churn?
-- Business use: Early warning system for at-risk students
SELECT
    sa.Churn_Risk,
    COUNT(DISTINCT sa.Student_ID)      AS Students,
    ROUND(AVG(sa.Login_Count), 1)      AS Avg_Logins,
    ROUND(AVG(sa.Questions_Viewed), 1) AS Avg_Q_Viewed,
    ROUND(AVG(sa.Expert_Sessions), 1)  AS Avg_Sessions,
    ROUND(AVG(sa.Activity_Score), 1)   AS Avg_Score,

    -- What % of these students actually churned?
    ROUND(
        COUNT(DISTINCT
            CASE WHEN s.Churned = 'Yes'
                 THEN sa.Student_ID END
        ) * 100.0 /
        COUNT(DISTINCT sa.Student_ID)
    , 1)                               AS Actual_Churn_Pct
FROM student_activity sa
LEFT JOIN subscriptions s
       ON sa.Student_ID = s.Student_ID
GROUP BY sa.Churn_Risk
ORDER BY Avg_Score DESC;


-- Query 8: Which country retains best?
-- Business use: Marketing team targets high-retention regions
SELECT
    Country,
    COUNT(*)                           AS Total_Subs,
    ROUND(
        SUM(CASE WHEN Churned = 'No'
                 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*)
    , 1)                               AS Retention_Rate_Pct,
    ROUND(AVG(Days_Active), 1)         AS Avg_Days_Active,
    ROUND(SUM(Revenue_USD), 2)         AS Total_Revenue,
    RANK() OVER (
        ORDER BY
        SUM(CASE WHEN Churned = 'No'
                 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*) DESC
    )                                  AS Retention_Rank
FROM subscriptions
GROUP BY Country
ORDER BY Retention_Rate_Pct DESC;


-- Query 9: Month by month retention per cohort
-- Business use: Cohort heatmap data for Power BI

WITH first_sub AS (
    SELECT
        Student_ID,
        MIN(Sub_Start_Month) AS First_Month
    FROM subscriptions
    GROUP BY Student_ID
),

cohort_data AS (
    SELECT
        f.First_Month AS Cohort_Month,
        s.Sub_Start_Month AS Activity_Month,
        COUNT(DISTINCT s.Student_ID) AS Active_Students
    FROM subscriptions s
    JOIN first_sub f
        ON s.Student_ID = f.Student_ID
    WHERE s.Churned = 'No'
    GROUP BY
        f.First_Month,
        s.Sub_Start_Month
),

cohort_size AS (
    SELECT
        First_Month,
        COUNT(*) AS Total_Students
    FROM first_sub
    GROUP BY First_Month
)

SELECT
    cd.Cohort_Month,
    cd.Activity_Month,
    cd.Active_Students,
    cs.Total_Students,
    ROUND(
        cd.Active_Students * 100.0 / cs.Total_Students,
        1
    ) AS Retention_Pct
FROM cohort_data cd
JOIN cohort_size cs
    ON cd.Cohort_Month = cs.First_Month
ORDER BY
    cd.Cohort_Month,
    cd.Activity_Month;


-- Query 10: Students at high churn risk
-- Business use: CRM team sends retention offers
SELECT
    s.Student_ID,
    s.Country,
    s.Plan_Type,
    s.Days_Active,
    s.Churn_Reason,
    ROUND(AVG(sa.Activity_Score), 1)   AS Avg_Activity,
    ROUND(AVG(sa.Login_Count), 1)      AS Avg_Logins,
    MAX(sa.Churn_Risk)                 AS Risk_Level,

    CASE
        WHEN AVG(sa.Activity_Score) < 20
          OR s.Days_Active < 10
                    THEN 'Send Discount Offer'
        WHEN AVG(sa.Activity_Score) < 40
                    THEN 'Send Re-engagement Email'
        ELSE            'Monitor Only'
    END                                AS Recommended_Action

FROM subscriptions s
JOIN student_activity sa
  ON s.Student_ID = sa.Student_ID
WHERE s.Churned = 'No'   -- Currently active
GROUP BY s.Student_ID, s.Country,
         s.Plan_Type, s.Days_Active,
         s.Churn_Reason
HAVING AVG(sa.Activity_Score) < 50
ORDER BY Avg_Activity ASC
LIMIT 100;
