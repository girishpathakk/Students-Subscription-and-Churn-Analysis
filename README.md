# 📊 Students Subscription & Churn Analysis

> **Replicating real-world Data Analyst work from an EdTech. — analyzing student subscription trends, churn patterns, and revenue impact using Python, SQL, and Power BI.**

![Python](https://img.shields.io/badge/Python-3.x-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Pandas](https://img.shields.io/badge/Pandas-2.x-150458?style=for-the-badge&logo=python&logoColor=white)
![Jupyter](https://img.shields.io/badge/Juypter-Notebook-F37626?style=for-the-badge&logo=python&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-Desktop-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=for-the-badge)

---

## 🎯 Project Overview

The CFO flagged a significant decline in Monthly Active Users (MAU). I was tasked with identifying:

- **Why** students were cancelling subscriptions
- **When** the decline started and what triggered it
- **Which** student segments were churning fastest
- **What** the revenue impact was

This project replicates that real-world analysis using a synthetic dataset built on actual EdTech data structures, business logic, and KPI definitions.

---

## 📸 Dashboard Preview

### Power BI Dashboard
![Power BI Dashboard](https://github.com/girishpathakk/Students-Subscription-and-Churn-Analysis/blob/main/powerbi/students_subscription%20%26%20churn_dashboard.PNG)


---

## 🔍 Key Business Insights

| # | Insight | Impact |
|---|---|---|
| 1 | MAU dropped **74%** from Jan 2023 to Jun 2024 | Critical revenue loss |
| 2 | **"Found Better Alternative"** = #1 churn reason (1,938 cancellations) | ChatGPT disruption |
| 3 | Pre-AI churn rate: **19.5%** → Crisis 2024: **63.8%** | 3x increase |
| 4 | **Annual plan** retention: 73.5% vs **Monthly**: 57.1% | Plan strategy needed |
| 5 | Search traffic dropped **FIRST** → Subscriptions dropped 2-3 months later | Early warning signal |
| 6 | **United Kingdom** highest retention: 62.7% | Geographic opportunity |
| 7 | Students with low activity score (<20) showed highest churn risk | Predictive signal |

---

## 💼 Business Recommendations

### 🔴 Immediate Actions
```
1. RETENTION CAMPAIGN
   Target: Monthly plan subscribers (57.1% retention)
   Action: Offer upgrade discount to Annual plan
   Expected: Improve retention by 10-15%

2. AI INTEGRATION
   Problem: "Found Better Alternative" = top churn reason
   Action: Integrate AI features within Chegg platform
   Expected: Reduce "Better Alternative" churn by 30%
```

### 🟡 Short Term (1-3 months)
```
3. EARLY WARNING SYSTEM
   Signal: Students with Activity Score < 20
   Action: Trigger re-engagement email campaign
   Tool: student_activity table → Churn_Risk column

4. GEOGRAPHIC FOCUS
   Opportunity: India (largest market, 61% retention)
   Action: Localized pricing & regional content
   Expected: 5% retention improvement
```

### 🟢 Long Term (3-6 months)
```
5. EXAM SEASON STRATEGY
   Pattern: Activity spikes in Jan, Apr, May, Nov, Dec
   Action: Lock-in annual plans before exam season
   Expected: Higher renewal rates

6. COHORT-BASED PRICING
   Insight: Pre-AI cohort churned 3x less
   Action: Grandfather pricing for loyal subscribers
   Expected: Improved lifetime value
```

---

## 🛠️ Tech Stack

| Tool | Usage |
|---|---|
| **Python** | Data generation, EDA, visualization |
| **Pandas & NumPy** | Data manipulation and analysis |
| **MySQL** | Database storage and querying |
| **SQL** | CTEs, Window Functions, JOINs |
| **Power BI** | Interactive business dashboard |
| **DAX** | Custom measures and KPIs |
| **Jupyter Notebook** | Analysis and documentation |

---

## 📁 Project Structure

```
Students-Subscription-and-Churn-Analysis/
│
├── 📁 data/
│   ├── students.csv              # 10,000 student profiles
│   ├── subscriptions.csv         # subscription records
│   ├── mau_monthly.csv           # 18 months MAU data
│   └── student_activity.csv      # Monthly activity per student
│
├── 📁 notebooks/
│   └── students_subscription_analysis.ipynb
│
├── 📁 sql/
│   └── students_subscription_queries.sql
│
├── 📁 powerbi/
│   └── students_subscription & churn_analysis.pbix
│   └── students_subscription & churn_dashboard.PNG 
│
└── README.md
```

---

## 🗄️ Data Schema

### Table 1: `students.csv`
| Column | Type | Description |
|---|---|---|
| Student_ID | String | Unique student identifier |
| Country | String | India, US, UK, Canada, Australia |
| Age_Group | String | 18-22, 23-27, 28+ |
| Education_Level | String | Undergraduate, Postgraduate, PhD |
| Acquisition_Source | String | Organic, Paid Ad, Referral, Social |
| Registration_Date | Date | When student registered |

### Table 2: `subscriptions.csv`
| Column | Type | Description |
|---|---|---|
| Sub_ID | String | Unique subscription ID |
| Student_ID | String | Foreign key → students |
| Plan_Type | String | Monthly, Quarterly, Annual |
| Plan_Price_USD | Float | 9.99, 19.99, 59.99 |
| Sub_Start_Month | Date | Subscription start |
| Churned | String | Yes / No |
| Churn_Reason | String | Why student cancelled |
| Days_Active | Integer | How long student was active |
| Revenue_USD | Float | Actual revenue earned |

### Table 3: `mau_monthly.csv`
| Column | Type | Description |
|---|---|---|
| Month_Label | String | YYYY-MM format |
| MAU | Integer | Monthly Active Users |
| Search_Traffic_Index | Float | 100 = Jan 2023 baseline |
| New_Subscribers | Integer | New subs this month |
| Churned_Count | Integer | Cancellations this month |
| Revenue_USD | Integer | Monthly revenue |
| Avg_CSAT | Float | Customer satisfaction score |

### Table 4: `student_activity.csv`
| Column | Type | Description |
|---|---|---|
| Student_ID | String | Foreign key → students |
| Month_Label | String | Activity month |
| Login_Count | Integer | Monthly logins |
| Questions_Viewed | Integer | Questions accessed |
| Expert_Sessions | Integer | Expert help sessions |
| Activity_Score | Float | 0-100 engagement score |
| Churn_Risk | String | High, Medium, Low |

---

## 🔧 SQL Queries Highlights

### Cohort Analysis (CTE)
```sql
WITH cohorts AS (
    SELECT Student_ID, Plan_Type, Churned,
        CASE
            WHEN Sub_Start_Month < '2023-05' THEN 'Pre-AI'
            WHEN Sub_Start_Month < '2023-11' THEN 'ChatGPT Impact'
            WHEN Sub_Start_Month < '2024-01' THEN 'Steep Decline'
            ELSE 'Crisis 2024'
        END AS Cohort
    FROM subscriptions
)
SELECT Cohort,
    ROUND(SUM(CASE WHEN Churned='Yes' THEN 1 ELSE 0 END)
    * 100.0 / COUNT(*), 1) AS Churn_Rate_Pct
FROM cohorts
GROUP BY Cohort;
```

### Revenue Loss Analysis (Window Function)
```sql
SELECT Sub_Start_Month, Plan_Type,
    ROUND(SUM(Revenue_USD), 2)       AS Actual_Revenue,
    ROUND(SUM(Plan_Price_USD), 2)    AS Expected_Revenue,
    ROUND(SUM(Plan_Price_USD)
        - SUM(Revenue_USD), 2)       AS Revenue_Lost
FROM subscriptions
GROUP BY Sub_Start_Month, Plan_Type
ORDER BY Sub_Start_Month;
```

---

## 📈 Power BI Dashboard Features

| Feature | Description |
|---|---|
| **KPI Cards** | Total Students, Subscriptions, Churn Rate, Revenue |
| **MAU Trend** | 18-month line chart with decline visualization |
| **Churn Reasons** | Horizontal bar chart — filtered by churned only |
| **Cohort Analysis** | Pre-AI vs ChatGPT vs Crisis phase comparison |
| **Plan Retention** | Monthly vs Quarterly vs Annual comparison |
| **Country Analysis** | Retention rate by geography |
| **Dynamic Slicers** | Filter by Year, Plan Type, Country |

---

## 🚀 How to Run This Project

### Step 1: Generate Data
```bash
# Run in Jupyter Notebook
# Cell 2: generates students.csv
# Cell 3: generates subscriptions.csv
# Cell 4: generates mau_monthly.csv
# Cell 5: generates student_activity.csv
```

### Step 2: SQL Analysis
```bash
# Import CSVs to MySQL
# Run: sql/chegg_subscription_queries.sql
# Use DBeaver or MySQL Workbench
```

### Step 3: Python Visualization
```bash
# Open notebooks/Chegg_Subscription_Analysis.ipynb
# Run all cells
```

### Step 4: Power BI Dashboard
```bash
# Open powerbi/Chegg_Subscription_Analysis.pbix
# All visuals load automatically
```

---

## 🎓 About This Project

This project is based on **real analytics work** performed during my role as a **Data Analyst**. The dataset is synthetic but built on:
- Actual table structures used in EdTech's analytics pipeline
- Real business KPIs tracked by the team
- Actual churn patterns observed during the ChatGPT disruption period

---
## 👤 Author

**Girish Pathak**

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=flat&logo=linkedin)](https://linkedin.com/in/girishpathakk)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-181717?style=flat&logo=github)](https://github.com/girishpathakk)
[![Email](https://img.shields.io/badge/Email-Contact-EA4335?style=flat&logo=gmail)](mailto:girish.pathak.ds@gmail.com)

---



<div align="left">
  
*Built with ❤️ as part of my Data Analytics journey*
**⭐ If you found this project useful, please give it a star!**
