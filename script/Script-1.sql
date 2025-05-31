
/*
 Project: Employee Attrition Analysis
 Author: Divya
 Description: 27 query-based insights using SQL over a Kaggle HR dataset.
 */



#Table Creation
CREATE TABLE employees (
  Age INT,
  Attrition BOOLEAN,
  BusinessTravel VARCHAR(50),
  DailyRate INT,
  Department VARCHAR(50),
  DistanceFromHome INT,
  Education INT,
  EducationField VARCHAR(50),
  EmployeeCount INT,
  EmployeeNumber INT,
  EnvironmentSatisfaction INT,
  Gender VARCHAR(10),
  HourlyRate INT,
  JobInvolvement INT,
  JobLevel INT,
  JobRole VARCHAR(50),
  JobSatisfaction INT,
  MaritalStatus VARCHAR(20),
  MonthlyIncome INT,
  MonthlyRate INT,
  NumCompaniesWorked INT,
  Over18 BOOLEAN,
  OverTime BOOLEAN,
  PercentSalaryHike INT,
  PerformanceRating INT,
  RelationshipSatisfaction INT,
  StandardHours INT,
  StockOptionLevel INT,
  TotalWorkingYears INT,
  TrainingTimesLastYear INT,
  WorkLifeBalance INT,
  YearsAtCompany INT,
  YearsInCurrentRole INT,
  YearsSinceLastPromotion INT,
  YearsWithCurrManager INT
);


#Altering table with compatible datatype
alter table my_project.employees
modify column attrition enum('Yes','No');

alter table my_project.employees
modify column over18 enum('Y', 'N');

alter table my_project.employees
modify column overTime enum('Yes','No');


#Loading the file
LOAD DATA LOCAL INFILE 'C:/Users/Divya/Downloads/attrition/WA_Fn-UseC_-HR-Employee-Attrition.csv'
INTO TABLE employees
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


select * from my_project.employees;
DESC EMPLOYEES;


#Section 1: Basic and Advanced Selects/Aggregate functions

#1.What is the overall attrition rate in the company?

select round(sum(case when attrition='Yes' then 1 else 0 end)*100.00/count(*), 2) as attrition_Rate from my_project.employees;


#2.Which departments have the highest employee attrition rates?

select department, round(sum(case when attrition='Yes' then 1 else 0 end)*100/count(*),2) as att_Rate from my_project.employees group by department order by att_Rate desc limit 1;

#3.What is the attrition rate by gender?
select gender, round(sum(case when attrition='Yes' then 1 else 0 end)*100/count(*),2) as att_rate from my_project.employees group by gender;

#4.Does age influence attrition? What age groups are leaving more?
select age, round(sum(case when attrition='Yes' then 1 else 0 end)*100/count(*),2) as attrition_rate from my_project.employees group by age order by attrition_rate desc limit 1;


#5.What is the age group that contributes to higher attrition rate?

select 
case 
when age<30 then 'Under 30'
when age between 30 and 39 then 'Between 30 and 40'
when age between 40 and 49 then 'Group 40-49'
else '50+'
end as age_group, 
round(sum(case when attrition='Yes' then 1 else 0 end)*100/count(*),2) as attrition_rate from my_project.employees group by age order by attrition_rate desc limit 1;

#6.How does job satisfaction relate to attrition?

select * from my_project.employees limit 10;

select JobSatisfaction, round(sum(case when attrition='Yes' then 1 else 0 end)*100/count(*),2) as attrition_rate from my_project.employees group by JobSatisfaction;

#7.Does the distance from home affect an employee’s decision to leave?

select 
case
when DistanceFromHome < 20 then 'Below 20km'
when DistanceFromHome between 20 and 30 then 'Between 20 to 30'
when DistanceFromHome > 30 then 'Greater than 30'
end as DistanceFromHome_km, round(sum(case when attrition='Yes' then 1 else 0 end)*100/count(*),2) as attrition_rate from my_project.employees group by DistanceFromHome_km;


#8.Are employees with less experience (e.g., < 2 years at company) more likely to leave?

select 
case when YearsATCompany < 2 then 'with less than 2 years of experience'
else 'Greater then 2 years'
end as Employee_group, count(EmployeeNumber) as Employees_count, round(sum(case when attrition='Yes' then 1 else 0 end)*100/count(*),2) as attrition_rate from my_project.employees group by Employee_group order by Employees_count desc, attrition_rate desc;

#9.Which employees have an attrition risk higher than the overall attrition rate? Or Find group of employees by department/jobsatisfaction/roles/distancefromhome who have attrition rate higher than overall attrition rate.

select department, round(sum(case when attrition='Yes' then 1 else 0 end)*100/count(*),2) as department_attrition_Rate from my_project.employees group by department having department_attrition_Rate > (select round(sum(case when attrition='Yes' then 1 else 0 end)*100.00/count(*), 2) as attrition_Rate from my_project.employees);

#10.List job roles where the average monthly income is less than the overall average income.

select jobRole, avg(monthlyIncome) as avg_month, (SELECT AVG(e.monthlyIncome) FROM my_project.employees e) AS total_avg from my_project.employees group by jobRole having avg_month < (select avg(e.monthlyIncome) from my_project.employees e);

#11. find the average distance of employees by department
select avg(e.distanceFromHome) from my_project.employees e group by department;

#12. Show employees whose distance from home is greater than the average for their department.

select d.employeeNumber, d.distanceFromHome, d.department, (  
select avg(e.distanceFromHome) from my_project.employees e where e.department= d.department) as department_avg from my_project.employees d where d.distanceFromHome > (  
select avg(e.distanceFromHome) from my_project.employees e where e.department= d.department);



#Section 2: Subqueirs/Joins/CTEs

#13. Find employees who have the same JobRole as someone who left the company.


select e.employeeNumber, e.jobRole from my_project.employees e where e.attrition='No' and e.jobRole in (select distinct d.jobRole from my_project.employees d where d.attrition='Yes');

#More efficient way for large datasets - Using Joins

select e.employeeNumber, e.jobRole from my_project.employees e 
JOIN (select distinct d.jobRole from my_project.employees d where d.attrition='Yes') leavers on 
leavers.jobRole = e.jobRole and e.attrition='No';

#14. Find the count of employees who have the same Jobrole as someone who left the company
select count(e.employeeNumber), e.jobRole from my_project.employees e where e.attrition='No' and e.jobRole in (select distinct d.jobRole from my_project.employees d where d.attrition='Yes') group by e.jobRole;


#15. Compare attrition rates of employees with the same EducationField and JobRole. - Fetch attirtion rates of employees of same educationField and jobrole

select count(e.employeeNumber) as count_em, e.educationField, e.jobRole, round(sum(case when e.attrition='Yes' then 1 else 0 end)*100/count(*),2) as attrition_Rate from my_project.employees e group by e.educationField, e.jobRole order by count_em desc, attrition_Rate desc;

#16. Find pairs of employees in the same department and same job level but with different attrition outcomes.

select e.employeeNumber as EmployeeCurrent, d.employeeNumber as Employeeleft, e.department, e.jobLevel from my_project.employees e
join my_project.employees d on 
d.department = e.department and
d.jobLevel = e.jobLevel and 
d.attrition = 'No' and 
e.attrition = 'Yes' and
e.employeeNumber <> d.employeeNumber;

#17. List departments where the average performance rating of those who left is higher than those who stayed.

select e.department, avg(e.performanceRating) as leave_performance, curr_em.per_Rat as stay_performance from my_project.employees e
join (select d.department, avg(d.performanceRating) as per_Rat from my_project.employees d where d.attrition ='No' group by department) curr_em
on e.department = curr_em.department where e.attrition = 'Yes' group by e.department, curr_em.per_Rat having avg(e.performanceRating) > curr_em.per_Rat;


#18. Show the difference in average training time between attrited and non-attrited employees per job role.  in ow, show avg training time of attrited/retained employees group by job role

select jobRole, 
round(avg(case when attrition='Yes' then TrainingTimesLastYear end), 2) as trainingavg_left,
round(avg(case when attrition='No' then TrainingTimesLastYear end), 2) as training_stayed, round(avg(case when attrition='No' then TrainingTimesLastYear end)-avg(case when attrition='Yes' then TrainingTimesLastYear end),2) as differce
from my_project.employees group by jobRole;


#19. List employees whose MonthlyIncome is higher than the average income of their respective Department.

with avg_income_by_depart as(
select department as avg_dep, avg(monthlyIncome) as avg_depincome from employees group by department
)
select e.employeeNumber, e.monthlyIncome, a.avg_dep , a.avg_depincome from employees e join avg_income_by_depart a on e.department = a.avg_dep and e.monthlyIncome>a.avg_depincome;

select * from employees limit 10;

#20.  Average Tenure of Those Who Left vs Stayed per each department.

with leaver_avg as (
select e.department, avg(e.yearsAtCompany) as leavers_avg_yrs from my_project.employees e where e.attrition ='Yes' group by e.Department
),
stayer_avg as (
select a.department, avg(a.yearsAtCompany) as stayers_avg_yrs from my_project.employees a where a.attrition ='No' group by a.Department
)
select e.department, e.leavers_avg_yrs, a.stayers_avg_yrs from leaver_avg e join stayer_avg a on a.department=e.department;


#21 Average Tenure of Those Who Left vs Stayed per each jobroles.


with leavers_avg as(
select e.JobRole , avg(e.yearsAtCompany) as leavers_avg_yrs from my_project.employees e where e.attrition ='Yes' group by e.JobRole
)
select e.Jobrole, e.leavers_avg_yrs, avg(a.yearsAtCompany) as stayers_avg_yrs from my_project.employees a join leavers_avg e on e.JobRole = a.JobRole where a.attrition ='No' group by e.jobrole, e.leavers_avg_yrs; 



#Section 3: Window-Functions.

#22. List top 3 rank employees by MonthlyIncome within each department.

with top_rankers as(
select employeeNumber, department, monthlyIncome, rank() over (partition by department order by monthlyIncome desc) as rank_emps from my_project.employees
)
select * from top_rankers r where r.rank_emps<=3;


#23. Income vs Department Average. For each employee, show their MonthlyIncome, the average income of their department, and the difference between the two.

select e.employeeNumber, e.MonthlyIncome, avg(e.MonthlyIncome) over (partition by e.department) as department_Avg, avg(e.MonthlyIncome) over (partition by e.department) - e.MonthlyIncome as difference_inavg
from my_project.employees e;


#24. For each department, find the employee with the highest attrition-related risk (e.g., lowest satisfaction + high overtime).

select employeeNumber, Department, jobSatisfaction, min(jobSatisfaction) over (partition by department order by jobSatisfaction asc, overtime desc) as min_jobsatisfaction from my_project.employees where attrition='No';

#25. Calculate the rolling average attrition rate by JobLevel.


SELECT 
  JobLevel,
  ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 1.0 / COUNT(*), 4) AS attrition_rate,
  ROUND(AVG(
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 1.0 / COUNT(*)
  ) OVER (ORDER BY JobLevel ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 4) AS rolling_avg_attrition
FROM my_project.employees
GROUP BY JobLevel
ORDER BY JobLevel;


#26. Employees with Above-Average Tenure in Their Role. For each JobRole, find employees whose YearsInCurrentRole is above the average for their job role.

with total_avg as(
select avg(e.YearsInCurrentRole) over (partition by e.JobRole) as total_avg_role from my_project.employees e
)
select e.employeeNumber, e.JobRole, e.YearsInCurrentRole, a.total_avg_role from my_project.employees e join total_avg a on e.YearsInCurrentRole > a.total_avg_role;


#27. Identify Salary Outliers. Flag employees whose MonthlyIncome is in the top 10% of their department.

with top_incomers as (
select e.employeeNumber, e.MonthlyIncome, e.department, dense_rank() over (partition by e.department order by e.MonthlyIncome desc) as rank_top from my_project.employees e 
)
select * from top_incomers r where r.rank_top<=10;



select * from my_project.employees limit 10;



