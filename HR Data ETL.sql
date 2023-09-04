Select * from hr_employee;

--  Let's update the column ID since it has foreign characters
--  Alter Table hr_employee
	Rename Column ï»¿id To Emp_id Varchar (20) NULL;
    
Alter Table hr_employee
	CHANGE Column ID Emp_id Varchar (20) NULL;
    
--  Let's format the date from text to standard date form
--  Turn off Security mode first
Set sql_safe_updates= 0;
--  Turn off Strict Mode
SET SQL_MODE = ' ';

Update hr_employee
SET Birthdate = Case
When birthdate like '%/%' Then date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
When birthdate like '%-%' Then date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
Else null
End;

--  Let's change the data type of the Birthdate column itself since it was imported as a text while it is now holding date values

Alter Table hr_employee
	Modify Column Birthdate Date;
    
--  Let's update Hiredate using the birthdate update process

Update hr_employee
SET hire_date = Case
When hire_date like '%/%' Then date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
When hire_date like '%-%' Then date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
Else null
End;

Alter Table hr_employee
	Modify Column Hire_date Date;
    
--  Let's format the Termdate from text to standard date

Update hr_employee
	Set termdate = date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'))
    Where termdate is not null
    And termdate != '';

Alter Table hr_employee
	Modify column termdate Date;
 
--  Let's add Age Column facilitate our queries

Alter Table hr_employee
	Add column Age int After birthdate;

-- Let's calculate Employees' age & populate Age col with it using TimeStampDiff (cal the diff btw present and the specified col date)

Update hr_employee
	Set Age = timestampdiff(Year,birthdate,curdate());

--  Let's see the Minimum and Maximum age of employees

Select Min(age) as Youngest,
	Max(Age) as Oldest
    from hr_employee;
 
 -- Let's see the total number of age below 18
 
 Select count(age) from hr_employee
	Where age < 18;
    

