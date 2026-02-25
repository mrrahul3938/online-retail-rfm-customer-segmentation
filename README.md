# online-retail-rfm-customer-segmentation

An end-to-end Business Intelligence project analyzing E-Commerce retail data to uncover revenue patterns, product intelligence, and customer segmentation insights using RFM modeling.

---

# 📌 Project Objective

The goal of this project is to:

- Analyze overall sales performance
- Identify revenue-driving products
- Perform RFM-based customer segmentation
- Detect customer churn risk
- Provide business-level strategic recommendations

This project simulates a real-world Data Analyst workflow from raw data to executive dashboard reporting.

---

# 🛠 Tools & Technologies Used

- Python (Data Cleaning, EDA, Feature Engg)
- MS SQL Server
- Power BI
- DAX

---

# 📊 Dashboard Overview

The Power BI report is divided into three intelligence layers:

1. Executive Overview
2. Product Intelligence
3. Customer Intelligence

---

# 🎯 Executive Overview

This dashboard provides high-level business KPIs and revenue trends.

### Key Metrics:
- Latest Month Revenue
- Average Order Value
- Total Orders
- Total Customers
- Revenue Trend Over Time
- Revenue by Country
- Top 5 Revenue Generating Products

<img src="images/Executive Overview.png" width="750">

### Insights:
- Revenue peaked at 1.43M in Nov 2010.
- UK contributes majority of total revenue (8.4M).
- Revenue growth trend visible in last quarter.
- Sales highly concentrated among top products.

---

# 📦 Product Intelligence

This dashboard analyzes product performance and revenue contribution patterns.

<img src="images/Product Intelligence.png" width="750">

### Key Visuals:
- Top 10 Products by Quantity
- Top 10 Products by Revenue
- Revenue Contribution by Product
- Unit Price Distribution

### Insights:
- Few products dominate revenue generation.
- Quantity leaders differ from revenue leaders.
- Revenue concentration risk exists.
- Majority sales occur within lower price bands.

---

# 👥 Customer Intelligence

This dashboard focuses on RFM-based customer segmentation.

<img src="images/Customer Intelligence.png" width="750">

### Visuals Included:
- Customer Segment Distribution
- Revenue Contribution by Segment
- Final_RFM Table (Customer-level scoring)

### Segments Identified:
- Champions
- Loyal Customers
- Potential Loyalists
- At Risk
- Lost Customers
- New Customers

### Key Findings:
- 896 Champions contribute 64.4% of revenue.
- 1021 customers classified as Lost.
- Potential Loyalists represent growth opportunity.
- Revenue highly dependent on repeat buyers.

---

# 🧠 Technical Implementation

## 🐍 Python (Data Cleaning & EDA)

- Removed return transactions (negative quantity)
- Removed duplicates
- Removed negative Quantity
- Created Revenue and YearMonth columns
- Performed exploratory data analysis

---
## Data Cleaning Impact Analysis

Initial total revenue including null Customer IDs: 9.79M  
Revenue after removing null customers: 8.62M  

~1.17M revenue originated from unidentified customers.

After cleaning, Champions contributed 64.4% of revenue (vs 56.5% when including null customers), improving segmentation clarity and customer-level accuracy.
--- 
## 🛢 SQL (RFM Modeling)

- Aggregated customer-level metrics
- Calculated Recency, Frequency, Monetary
- Assigned RFM scores
- Created `RFM_Final` view
- Segmented customers based on score thresholds

---

## 📈 Power BI

- Created interactive dashboards
- Implemented DAX measures:
  - SUM()
  - CALCULATE()
  - DISTINCTCOUNT()
  - RANKX()
- Built executive-friendly layout

---

# 💼 Business Insights

- High churn observed in Lost Customers segment
- Revenue concentration risk identified
- Converting Potential Loyalists can significantly increase revenue
- Customer retention more impactful than new acquisition

---


# 📦 Dataset

Due to GitHub file size limitations (~50MB), the dataset is not included in this repository.

You can download it from:
- online_retail = [https://docs.google.com/spreadsheets/d/1yyJN6ffBv5qUDdtcdkb7jxyYBmYoA4Il/edit?usp=drive_link&ouid=117517964316414550336&rtpof=true&sd=true]
- Clean_retail = [https://drive.google.com/file/d/1vtcnhG0vIoY1vSXmTUHaODITlP1AI69e/view?usp=drive_link]

---

# 🚀 Skills Demonstrated

- Data Cleaning & Feature Engineering
- SQL Aggregation & Window Functions
- RFM Customer Segmentation
- Business Intelligence Reporting
- Dashboard Storytelling
- Data-to-Decision Translation

---
