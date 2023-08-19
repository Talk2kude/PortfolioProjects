--Let's create a View

Create View Dbo.Analytics as 
	Select s.set_num, s.name as Set_Name, s.year, s.theme_id, 
		Cast(S.num_parts as numeric) as Num_Parts, 
		T.name as Theme_Name, T.parent_id, 
		P.name as Parent_Theme_Name
	from Sets S
		Left Join themes T on
		S.theme_id = T.id
		Left join themes P on
		T.parent_id = P.id;

Select * from dbo.Analytics


--1-What is the total number of parts per theme

Select Theme_Name, Sum(Num_Parts) as Total_Num_Parts from dbo.Analytics
--where parent_theme_name is not null
	Group by theme_name
	Order by 2 desc

	
--2 -What is the total number of parts per year

Select year, Sum(Num_Parts) as Total_Num_Parts from dbo.Analytics
--where parent_theme_name is not null
	Group by year
	Order by 2 desc


--3- How many sets where created in each Century in the dataset
--Let's first Alter our View and add Century column via Case

Alter View Dbo.Analytics as 

Select s.set_num, s.name as Set_Name, s.year, s.theme_id, Cast(S.num_parts as numeric) as Num_Parts, T.name as Theme_Name, T.parent_id, P.name as Parent_Theme_Name,
	(Case 
	When S.year between 1900 and 2000 Then '20th Century'
	When S.year between 2001 and 2100 Then '21st Century'
	End) as Century
from Sets S
	Left Join themes T on
		S.theme_id = T.id
	Left join themes P on
		T.parent_id = P.id;

--Now we continue..

Select Century, Count(Num_Parts) as Total_Sets_Num
	from dbo.Analytics
--where parent_theme_name is not null
	Group by Century
	Order by 2 desc

--4- What percentage of sets ever released in the 21st Century were Star Wars Themed 
--let's first find out the the num of Sets for SW released in 21stC.

Select Century, Theme_name, count(Num_Parts) as Total_Sets_Num
	from dbo.Analytics
	where parent_theme_name like '%star%'
	And Century = '21st Century'
	Group by Century, Theme_Name
	Order by 2 desc

--Now we add a CTE to divide the number against the total set released in 21stC.

; With CTE_PCent As
	(
	Select Century, Theme_name, Count(Num_Parts) as Total_Sets_Num from dbo.Analytics
		Where Century = '21st Century'
		Group by Century, Theme_Name
		)
	Select SUM(Total_Sets_Num), SUM(Percentage)
		from (
			select Century, theme_name, Total_Sets_Num, sum(Total_Sets_Num) OVER() as total,
			cast(1.00 * Total_Sets_Num / sum(Total_Sets_Num) OVER() as decimal(5,4))*100 Percentage
				from CTE_PCent) M
		where theme_name like '%Star wars%'

--5-- What was the popular theme by year in terms of sets released in the 21st Century


Select Year, Theme_name, Count(Num_Parts) as Total_Sets_Num
	from dbo.Analytics
		Where Century = '21st Century'
		Group by Year, Theme_Name
		Order by year desc, Count(Num_Parts)  desc

--Now let's Partition it and rank the rows	

Select Year, Theme_name, Count(Num_Parts) as Total_Sets_Num,
	ROW_NUMBER() Over (Partition by Year order by Count(Num_Parts) desc) as Row_Number
	from dbo.Analytics
		Where Century = '21st Century'
		Group by Year, Theme_Name
		Order by year desc

--Now let's find out the Row with the highest TSN for each year (ie where the Row Number = 1) using  two options, Subquery and CTE

Select Year, Theme_name, Total_Sets_Num 
	From (
			Select Year, Theme_name, Count(Num_Parts) as Total_Sets_Num,
			ROW_NUMBER() Over (Partition by Year order by Count(Num_Parts) desc) as Row_Number
			from dbo.Analytics
			Where Century = '21st Century'
			Group by Year, Theme_Name) As M
	Where Row_Number = 1
	Order by year desc

--OR
;With CTE_HTSN as 
	(
	Select Year, Theme_name, Count(Num_Parts) as Total_Sets_Num,
			ROW_NUMBER() Over (Partition by Year order by Count(Num_Parts) desc) as Row_Number
			from dbo.Analytics
			Where Century = '21st Century'
			Group by Year, Theme_Name)
	Select Year, Theme_name, Total_Sets_Num from CTE_HTSN
	Where Row_Number = 1
	Order by year desc


--6-What is the most produced color of lego ever in terms of quantity of parts?
--Let's join applicable tables first and see what they look like

Select inv.color_id, inv.inventory_id, inv.part_num, cast(inv.quantity as numeric) quantity,  inv.is_spare, 
		c.name as color_name, c.rgb, 
		p.name as part_name, p.part_material, pc.name as category_name
	from inventory_parts Inv
		Inner Join colors C
			on inv.color_id = c.id
		Inner Join parts P
			on inv.part_num = p.part_num
		Inner Join part_categories PC
			on part_cat_id = pc.id

--Now we select the columns we want to see as per our query using a subquery first and then CTE
--Another option is to create a View of the above and then query the view

Select Color_name, sum(quantity) as Quantity_of_parts
	from 
	(
	Select
			inv.color_id, inv.inventory_id, inv.part_num, cast(inv.quantity as numeric) quantity, inv.is_spare, c.name as color_name, c.rgb, p.name as part_name, p.part_material, pc.name as category_name
		from inventory_parts Inv
		Inner Join colors C
			on inv.color_id = c.id
		Inner Join parts P
			on inv.part_num = p.part_num
		Inner Join part_categories PC
			on part_cat_id = pc.id
	) as Main
Group by Color_name
Order by 2 desc

--OR 

; With CTE_MPC As
	(
	Select
		inv.color_id, inv.inventory_id, inv.part_num, cast(inv.quantity as numeric) quantity, inv.is_spare, c.name as color_name, c.rgb, p.name as part_name, p.part_material, pc.name as category_name
		from inventory_parts Inv
		Inner Join colors C
			on inv.color_id = c.id
		Inner Join parts P
			on inv.part_num = p.part_num
		Inner Join part_categories PC
			on part_cat_id = pc.id)
Select Color_name, sum(quantity) as Quantity_of_parts
	from CTE_MPC
Group by Color_name
Order by 2 desc	