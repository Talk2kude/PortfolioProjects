Select * from Pizza_sales;

--1--Let's find the Total Revenue

Select Round(SUM(total_price),3) as Total_Reveue from Pizza_sales

--2-- Find the Average Order Value

Select Round(SUM(total_Price) / (COUNT(distinct order_id)),3) as Avg_Order_Value from Pizza_sales

--3--- Find the Total Number of Pizza Sold

Select SUM(quantity) as Total_Pizza_Sold from Pizza_sales;

--4--Find the Total Number of Orders placed

Select Count(Distinct order_id) as Total_Orders from Pizza_sales;


--5-- Let's find the Average Pizza per Order

Select Cast(Cast(SUM(quantity) AS decimal(10,2)) / 
		Cast(Count(Distinct order_id) AS decimal(10,2)) AS decimal(10,2)) as Avg_Pizza_Per_Order 
		from Pizza_sales;

----Chart Requirement

--1--Daily Trend for total Order

Select DATENAME(WEEKDAY,order_date) as Week_Day, 
	Count(Distinct order_id) as Total_Daily_Orders from Pizza_sales
	Group by DATENAME(WEEKDAY,order_date)
	Order by Total_Daily_Orders desc

--2--Daily Trend for total Order

Select DATENAME(MONTH,order_date) as Month_Name, 
	Count(Distinct order_id) as Total_Monthly_Orders from Pizza_sales
	Group by DATENAME(MONTH,order_date)
	Order by Total_Monthly_Orders desc

--3--Let's find out the Percentage Sales by Pizza Category
--First find out the total sales for each PC, then multiply by 100 to make it a ratio

Select pizza_category, SUM(Total_price)*100 from Pizza_sales
	Group by pizza_category

--Then find out the Total price for all sold Pizza

Select SUM(total_price) as Total_Sales from Pizza_sales

--Now use Subquery to divide 1/2


Select pizza_category, SUM(total_price) as Total_Revenue,
	SUM(Total_price) * 100 /
	(Select SUM(Total_price) from Pizza_sales) As PCentage_Total_Sales
	 from Pizza_sales
	Group by pizza_category


--3--Let's find out the Percentage Sales by Pizza Size
--This is similiar to the above query hence same steps will apply, just change Category to Size

Select pizza_Size, SUM(total_price) as Total_Revenue,
	Cast(SUM(Total_price) * 100 /
	(Select SUM(Total_price) from Pizza_sales) as Decimal (10,2)) As PCentage_Total_Sales
	 from Pizza_sales
	Group by pizza_Size
	Order by PCentage_Total_Sales desc

--4-Let's find the Top 5 Best Sellers by Revenue, Total Quantity and Total Orders

Select Top 5 Pizza_name, SUM(Total_Price) As Total_Revenue from Pizza_sales
	Group by pizza_name
	Order by Total_Revenue desc

Select Top 5 Pizza_name, SUM(Total_Price) As Total_Revenue from Pizza_sales
	Group by pizza_name
	Order by Total_Revenue asc

--Top 5 by Total Quantity

Select Top 5 Pizza_name, SUM(quantity) As Total_Quantity from Pizza_sales
	Group by pizza_name
	Order by Total_Quantity desc

Select Top 5 Pizza_name, SUM(quantity) As Total_Quantity from Pizza_sales
	Group by pizza_name
	Order by Total_Quantity asc

--Top by by Total Order

Select Top 5 Pizza_name, Count(distinct order_id) As Total_Order from Pizza_sales
	Group by pizza_name
	Order by Total_Order desc

Select Top 5 Pizza_name, Count(distinct order_id) As Total_Order from Pizza_sales
	Group by pizza_name
	Order by Total_Order asc



