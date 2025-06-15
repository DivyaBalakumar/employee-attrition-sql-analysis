
**Employee Attrition Analysis using SQL**

A complete SQL-based analysis of HR attrition data using CTEs, window functions, and subqueries to uncover hidden patterns in employee behavior.


**Dataset**

Source: Kaggle - https://www.kaggle.com/datasets/patelprashant/employee-attrition

Attributes: Age, Attrition, JobRole, MonthlyIncome, YearsAtCompany, PerformanceRating, and more.

Rows: 1,470

Format: CSV

**Tools Used**

SQL (tested on MySQL / PostgreSQL / BigQuery) - Dbeaver

Kaggle Dataset

GitHub (for version control)

**Key Areas of Analysis**
**1**. Data Preparation
Table creation and structure setup

Alteration of fields where needed

Data loading and verification

**2**. Attrition Trends
Attrition analysis by age group — identifying which age groups have higher attrition rates

Experience-based attrition — identifying trends among less experienced employees

Department-wise analysis of employees who travel longer distances from home

Evaluating whether training time impacts attrition

Investigating if high overtime combined with low job satisfaction increases attrition risk

**3**. Income & Role Insights
Do factors like low income and low satisfaction lead to higher attrition?

Attrition comparison between employees of the same Education Field and Job Role (stayed vs. left)

Average tenure comparison for leavers vs. stayers across Job Roles and Departments

**4**. Performance Analysis
Top 10 high-income earners per department

Analyzing employees with high performance ratings — how do they relate to attrition?


**Sample Query(CTE+Window functions)**

with top_incomers as (
select e.employeeNumber, e.MonthlyIncome, e.department, dense_rank() over (partition by e.department order by e.MonthlyIncome desc) as rank_top from my_project.employees e 
)
select * from top_incomers r where r.rank_top<=10;


**Advanced Queries**

Use of CTEs, window functions (RANK, DENSE_RANK, PERCENT_RANK)

Filtering using subqueries and joins

Total: 27 analysis queries using CTEs, joins, filters, and window functions.


**Project Structure:**

employee-attrition-sql-analysis/
│
├── dataset/
│ └── HR_data.csv # Kaggle dataset
│
├── scripts/
│ └── attrition_analysis.sql # SQL queries: setup + 27 analysis queries
│
├── README.md # Project documentation



**How to Use**

1. Open the SQL file in any SQL editor (e.g., DBeaver, BigQuery, PostgreSQL).
2. Load the dataset (`.csv`) into your SQL engine.
3. Run each query step-by-step to explore the analysis.























