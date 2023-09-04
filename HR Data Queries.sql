-- QUESTIONS

-- 	What's the gender breakdown of employees in the company?

Select gender, Count(gender) as Count from hr_employee	
	Where age >= 18
    And termdate = '0000-00-00'
    group by gender;
 
 -- 2. What's the Race/Ethnicity breakdown of employees in the company?
 
 Select Race, Count(Race) as Count from hr_employee	
	Where age >= 18
    And termdate = '0000-00-00'
    Group by Race
    Order by Count desc;

-- 3. What's the age distribution of employees in the company?

Select Min(age) as Youngest, Max(Age) as Oldest from hr_employee
    Where age >= 18
    And termdate = '0000-00-00';

-- With the above info, let's create age bracket/bucket

Select Case
	When Age >= 18 And Age <= 24 Then '18-24'
	When Age >= 25 And Age <= 34 Then '25-34'
	When Age >= 35 And Age <= 44 Then '35-44' 
	When Age >= 45 And Age <= 54 Then '45-54' 
	When Age >= 55 And Age <= 64 Then '55-64'
	Else '65+'
End As Age_Group, 
Count(*) As Count from hr_employee
Where age >= 18
    And termdate = '0000-00-00'
Group by Age_Group
Order by Age_Group;

-- 3A. What's the age distribution of employees by gender in the company?

Select Case
	When Age >= 18 And Age <= 24 Then '18-24'
	When Age >= 25 And Age <= 34 Then '25-34'
	When Age >= 35 And Age <= 44 Then '35-44' 
	When Age >= 45 And Age <= 54 Then '45-54' 
	When Age >= 55 And Age <= 64 Then '55-64'
	Else '65+'
End As Age_Group, Gender,
Count(*) As Count from hr_employee
Where age >= 18
    And termdate = '0000-00-00'
Group by Age_Group, Gender
Order by Age_Group, Gender;



--  4--How many employees work at Headquarters versus 

Select Location, count(location) as Count from hr_employee
Where age >= 18
    And termdate = '0000-00-00'
Group by location
Order by 2 desc;

--  5--What is the average length of employement for employees who have been terminated?

select Round(Avg(datediff(termdate, hire_date))/365,2) as Avg_Length_Employment from hr_employee
	Where age >= 18
    And termdate != '0000-00-00'
	And current_date() >= termdate;
    
-- 5a Let's check the Running Average length of employement for employees who have been terminated
With Employ_T As (
select *, datediff(termdate, hire_date)/365 as Employ_Duration from hr_employee
	Where age >= 18
    And termdate != '0000-00-00'
    And current_date() >= termdate)
    
select concat(first_name, '', Last_Name) as Employee,
	Gender, Age, Race, Jobtitle, department, Hire_date, Termdate, 
    Round(avg(Employ_duration) Over (order by termdate),3) as Running_Avg from Employ_T;
    

--  6-- How does gender distribution vary across department and jobtitle?

Select department, gender, Count(*) as Count from hr_employee
	Where age >= 18
    And termdate != '0000-00-00'
    Group by Department, gender
    Order by department;
    
--  What is the distribution of jobtitles across the company?

Select jobtitle, Count(jobtitle) as Count from hr_employee
	Where age >= 18
    And termdate = '0000-00-00'
    Group by jobtitle
    Order by jobtitle desc;
    
--  8--Which department has the highest turnover (exit) rate?

Select department,
	Total_Count,
    Terminated_Count,
    Terminated_Count/Total_Count As Termination_Rate
From (
	select department,
    Count(*) As Total_Count,
    Sum(	Case
		When termdate != '0000-00-00' And  termdate <= current_date() Then 1 
        Else 0 End) As Terminated_Count
	from hr_employee
    Where age >= 18
    Group by department) as Subquery
Order by Termination_Rate desc;
        
 
--  9--What is the distribution of employees across locations by state?
 
 Select Location_State,
	Count(*) As Count from hr_employee
    Where age >= 18
    And termdate = '0000-00-00'
    Group by location_State
    Order by Count desc;
    
--  10--How has the company's employee count changed over time based on hire and term date?

Select
	Year,
    Hires,
    Terminations,
    Hires - Terminations As Net_Change,
    Round((Hires - Terminations)/Hires * 100,2) As Net_Change_Percent
From (
	Select Year(Hire_date) As Year,
    Count(Hire_date) As Hires,
    Sum(Case When termdate!= '0000-00-00' And  termdate <= current_date() Then 1 
		Else 0 End) As Terminations
	From hr_employee
     Where age >= 18
    Group by Year(Hire_date)
    ) As Subquery
Order by Year asc;
    
    
--  11--What is the tenure distribution (tenure duration) of each department?

Select Department,
	Round(Avg(datediff(Termdate,Hire_date)/365),2) As Avg_Tenure
    From hr_employee
    Where termdate != '0000-00-00' And  termdate <= current_date()
    And Age >= 18
    Group by department;