# FPL 2025 Value Efficiency Analysis

This project analyses Fantasy Premier League (FPL) player and team data to measure **value efficiency** across the first 10 weeks of the 2025 season.  
It combines raw data extraction from the official FPL API, data cleaning in Excel, structured transformation in SQL, and interactive visualisation in Tableau Public.

![FPL 2025 Dashboard Preview] <img width="2118" height="1374" alt="FPL_Value_Effieciency_Dashboard" src="https://github.com/user-attachments/assets/1b3e11cd-c463-4ab9-872c-5acc56ea59f1" />



---

## Overview

The goal of this project was to determine which players, teams, and positions provided the best value for money, measured through points per million and other efficiency metrics.  
The workflow involved building a complete data pipeline — from sourcing raw JSON data to publishing a live, browser-based Tableau dashboard.

---

## Data Process

### 1. Data Extraction and Preparation
- Retrieved raw data from the official **FPL API**, containing thousands of nested records in JSON format.  
- Converted the JSON output into an **Excel dataset** for easier manipulation.  
- Cleaned and standardised the dataset by:
  - Removing players no longer active in the Premier League.
  - Fixing invalid characters and name formatting issues.
  - Validating data types and column structures for SQL import.

### 2. SQL Cleaning and Transformation
- Imported the cleaned dataset into a **SQL environment** for further processing.  
- Wrote multiple queries to prepare analytical tables, including:
  - Calculations for *per-90 metrics* (Goals per 90, Assists per 90, Points per 90).  
  - Efficiency ratios (Points per £M, Expected Goal Involvement per £M).  
  - Team and position aggregates using `JOIN`, `GROUP BY`, `ORDER BY`, and `UNION` statements.  
- Created reusable CTEs to simplify logic and maintain a clear data model.

### 3. Data Export and Visualisation
- Exported the transformed SQL results back into Excel and hosted the file via **OneDrive**, allowing Tableau Public to connect live without extracts.  
- Designed a comprehensive dashboard in **Tableau Public**, featuring:
  - Team performance leaderboard.
  - Top 10 players by total points.
  - Value vs. cost scatter plot.
  - KPI summary bar showing top team, best player, average efficiency, and best valued position.
- Applied consistent colour schemes, legends, and filters for interactivity and readability.

---

## Tools and Technologies

| Stage | Tool / Technology | Purpose |
|-------|-------------------|----------|
| Data Source | FPL API | Raw JSON player & team statistics |
| Data Cleaning | Excel | Structure validation and name/format cleaning |
| Data Transformation | SQL | Aggregation, joins, efficiency calculations |
| Visualisation | Tableau Public | Dashboard design and sharing |
| Cloud Hosting | OneDrive | Live connection for Tableau data updates |

---

## Key Outcomes

- Delivered a **fully interactive dashboard** accessible online through Tableau Public.  
- Created a **reproducible data pipeline** from raw API output to finished visualisation.  
- Demonstrated capability in data wrangling, SQL analysis, and analytical storytelling.  
- Identified statistically which positions and players offer the highest return on cost.

---

## Tableau Dashboard

View the live dashboard here:  
**[FPL 2025 – Value Efficiency Dashboard (Tableau Public)][(https://public.tableau.com/views/FPL2025ValueEfficiencyDashboard-First10WeeksSQLTableau/Dashboard1?:language=en-GB&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)]**

---

<pre> ## Repository Structure ``` fpl-value-efficiency-dashboard/ │ ├── data/ │ └── fpl_data.xlsx │ ├── sql/ │ └── fpl_analysis_queries.sql │ ├── screenshots/ │ └── dashboard_preview.png │ └── README.md ``` </pre>

---

## How to Reproduce

1. Download the data from the `/data` directory or retrieve fresh data from the FPL API.  
2. Run the SQL queries in `/sql` to generate the cleaned and aggregated tables.  
3. Connect the resulting dataset to Tableau Public using OneDrive or a local Excel file.  
4. Open the published dashboard to explore the findings interactively.

---

## Author

**Finn Carman**  
Data Analyst | Tableau, SQL, Excel  
[LinkedIn][(www.linkedin.com/in/finncarmankuh)] • [Tableau Public][(https://public.tableau.com/app/profile/finn.carman/vizzes)]

---

