
--1-Data Inspection
Select * from sales_data_sample

--2- Let's check for unique values

Select distinct STATUS from sales_data_sample --tag for plotting
Select distinct year_id from sales_data_sample
Select distinct PRODUCTLINE from sales_data_sample ---tag for plotting
Select distinct COUNTRY from sales_data_sample ---tag for plotting
Select distinct DEALSIZE from sales_data_sample ---tag for plotting
Select distinct TERRITORY from sales_data_sample ---tag for plotting

--3-- Let's analyze the product line

Select productline, Round(sum(SALES),2) as Revenue from sales_data_sample
	Group by PRODUCTLINE
	Order by 2 desc

--4-Let's see how the sales were over the years

Select YEAR_ID, Round(sum(sales),2) Revenue from sales_data_sample
	Group by YEAR_ID
	Order by 2 desc

--5-Let's see what happened in year 2005 which resulted in low sales

Select distinct MONTH_ID from sales_data_sample
	Where YEAR_ID = 2005

--6-Let's see the Revenue per Dealsize

Select DEALSIZE, Round(sum(sales),2) Revenue from sales_data_sample
	Group by DEALSIZE
	Order by 2 desc

--7-Let's see highest single sales made per year

Select YEAR_ID, Round(MAX(sales),2) as Max_Revenue from sales_data_sample
	Group by YEAR_ID
	Order by 2 desc

--8--What was the best month for sales in a specific year? How much was earned that month? 

Select  Month_id, Round(Sum(sales),2) as Revenue, Count(ORDERNUMBER) as Frequency from sales_data_sample
	Where YEAR_ID = 2004 --change year to see the rest
	Group by  MONTH_ID
	Order by 2 desc



--9-Since November appears to be their best sales month, what product do they sell in November, Classic I believe

Select  MONTH_ID, PRODUCTLINE, Round(sum(sales),2) as Revenue, count(ORDERNUMBER) as Frequency from sales_data_sample
	Where YEAR_ID = 2004 and MONTH_ID = 11 --change year to see the rest
	Group by  MONTH_ID, PRODUCTLINE
	Order by 3 desc


--10--Let's look into our customer status over the years (RFM is ideal for this analysis)

Select 
		CUSTOMERNAME, 
		Round(Sum(sales),3) as MonetaryValue,
		Round(Avg(sales),3) as AvgMonetaryValue,
		Count(ORDERNUMBER) as Frequency,
		Max(ORDERDATE) last_order_date, 
		(Select Max(ORDERDATE) from sales_data_sample) Max_Order_Date,
		DATEDIff(DD,Max(ORDERDATE),(Select Max(ORDERDATE) from sales_data_sample)) as Recency
		From sales_data_sample
		Group by CUSTOMERNAME

--Now that we have got the RFM, let’s group them into equal buckets using the Ntile function. We will begin by putting above query into CTE

DROP TABLE IF EXISTS #rfm
;With RFM as
	(
Select 
		CUSTOMERNAME, 
		Round(Sum(sales),3) as MonetaryValue,
		Round(Avg(sales),3) as AvgMonetaryValue,
		Count(ORDERNUMBER) as Frequency,
		Max(ORDERDATE) last_order_date, 
		(Select Max(ORDERDATE) from sales_data_sample) Max_Order_Date,
		DATEDIff(DD,Max(ORDERDATE),(Select Max(ORDERDATE) from sales_data_sample)) as Recency
		From sales_data_sample
		Group by CUSTOMERNAME
),

RFM_calc as
(
	Select r.*,
		NTILE(4) OVER (order by Recency desc) rfm_recency,
		NTILE(4) OVER (order by Frequency) rfm_frequency,
		NTILE(4) OVER (order by MonetaryValue) rfm_monetary
	from RFM R

--Now lets concatenate the rfm values together, first as integar and then as string. Insert this into our TEMP table
)
select 
	c.*, rfm_recency+ rfm_frequency+ rfm_monetary as rfm_cell,
	cast(rfm_recency as varchar) + cast(rfm_frequency as varchar) + cast(rfm_monetary  as varchar) rfm_cell_string
	into #rfm
from rfm_calc C

--Let's classify our Customers using the Case Statement. 

select CUSTOMERNAME , rfm_recency, rfm_frequency, rfm_monetary, rfm_cell,
	case 
		when rfm_cell = 1 then 'lost_customers'  --lost customers
		when rfm_cell In (2,3) then 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
		when rfm_cell In (4,5) then 'new customers'
		when rfm_cell In (6,7) then 'potential churners'
		when rfm_cell  = 8 then 'active' --(Customers who buy often & recently, but at low price points)
		when rfm_cell = 9 then 'loyal'
	end rfm_segment

from #rfm

--OR

select CUSTOMERNAME , rfm_recency, rfm_frequency, rfm_monetary,
	case 
		when rfm_cell_string in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) then 'lost_customers'  --lost customers
		when rfm_cell_string in (133, 134, 143, 244, 334, 343, 344, 144) then 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
		when rfm_cell_string in (311, 411, 331) then 'new customers'
		when rfm_cell_string in (222, 223, 233, 322) then 'potential churners'
		when rfm_cell_string in (323, 333,321, 422, 332, 432) then 'active' --(Customers who buy often & recently, but at low price points)
		when rfm_cell_string in (433, 434, 443, 444) then 'loyal'
	end rfm_segment
from #rfm


--11--What products are most often sold together?
--Select * from sales_data_sample where ORDERNUMBER = 10411

--From Distinct Status we know that Shipped orders are the completed transaction so we would work with that
Select distinct(status) from sales_data_sample

Select ORDERNUMBER, COUNT(*) RM from sales_data_sample
	Where STATUS = 'shipped'
	Group by ORDERNUMBER
--Now that we have the Shipped orders, let's see where Row Numbers are equal to two (means two items shipped)

Select ORDERNUMBER from
	(Select ORDERNUMBER, COUNT(*) RN from sales_data_sample
	Where STATUS = 'shipped'
	Group by ORDERNUMBER) RM
Where RN = 2

--Now let's see the ProductCode for these orders (We will add the above query into another subquery)

Select ProductCode from sales_data_sample
		Where ORDERNUMBER in 
		(
	Select ORDERNUMBER from
		(Select ORDERNUMBER, COUNT(*) RN from sales_data_sample
		Where STATUS = 'shipped'
		Group by ORDERNUMBER) m
		Where RN = 2
		)

--Let's convert the above result into a single row using XML Path and then use STUFF to convert it to a string 
--(Will add a comma before the ProductCode to seperate orders with more than 1 products)

Select STUFF(
	(Select ',' + ProductCode from sales_data_sample
		Where ORDERNUMBER in 
		(
	Select ORDERNUMBER from
		(Select ORDERNUMBER, COUNT(*) RN from sales_data_sample
		Where STATUS = 'shipped'
		Group by ORDERNUMBER) m
		Where RN = 2
		)
	FOR XML Path ('')),
		1,1,'')

-- To see the entire dataset instead of just for orders with two productcodes, let's add Distinct OrderNumber and join them together

Select DISTINCT ORDERNUMBER, STUFF(
	(Select ',' + ProductCode from sales_data_sample as P
		Where ORDERNUMBER in 
		(
	Select ORDERNUMBER from
		(Select ORDERNUMBER, COUNT(*) RN from sales_data_sample
		Where STATUS = 'shipped'
		Group by ORDERNUMBER) m
		Where RN = 2
		)
	And P.ORDERNUMBER = S.ORDERNUMBER
	FOR XML Path ('')),
		1,1,'') as ProductCodes

From sales_data_sample as S
Order by 2 desc

---EXTRAs----
--Cities has the highest number of sales in a specific country

Select City, Round(Sum(sales),2) as Revenue from sales_data_sample
	Where country = 'UK'
	Group by city
	Order by 2 desc


---What is the best product in United States?

select Country, YEAR_ID, PRODUCTLINE, Round(Sum(sales),2) as Revenue from sales_data_sample
	Where Country = 'USA'
	Group by  Country, YEAR_ID, PRODUCTLINE
	Order by 4 desc