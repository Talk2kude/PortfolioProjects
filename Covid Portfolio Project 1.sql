Select * from Covid_Deaths
Where continent is not null
	Order by 3,4;


Select location, date, total_cases, new_cases, total_deaths, population
from Covid_Deaths
Where continent is not null
	Order by 1,2;

--Looking at Total Cases VS Total Deaths
--This shows the likelihood of dying if you contract Covid in your country

Select location, date,total_deaths,Total_cases, Round((total_deaths/total_cases *100),5) as Death_Percentage 
 from Covid_Deaths
--Where location like '%States%'
 Where continent is not null
 Order by 1,2;

 --Looking at Total Cases vs Population (You may include Continent in all your queries to enable drill-down effect in Tableau)
 --Shows what percentage of population got Covid

 Select location, date, Population, Total_cases, (total_cases/population *100) as Percent_Population_Infected
 from Covid_Deaths
--Where location like '%States%'
 Where continent is not null
 Order by 1,2;

 --Looking at Countries with Highest Infection Rate compared to Population

 Select location, Population, Max(Total_cases) As HighestInfectionCount, Max(total_cases/population *100) as Percent_Population_Infected
 from Covid_Deaths
 Where continent is not null
 Group by location, Population
 Order by Percent_Population_Infected desc;

 -- Showing Countries with Highest DeathCount per Population

 Select location, Max(cast(Total_deaths As int)) As Total_Death_Count
 from Covid_deaths
 Where continent is not null
 Group by location
 Order by Total_Death_Count desc;

 -- Showing Total DeathCount By Continent
 --Showing Continent with Highest DeathCount per Population

 Select continent, Max(cast(Total_deaths As int)) As Total_Death_Count
 from Covid_deaths
 Where continent is not null
 Group by continent
 Order by Total_Death_Count desc;

 --Global Numbers


Select date, SUM(new_cases) as Total_Cases, SUM(New_deaths) as Total_Deaths, 
	SUM(new_deaths) / nullif(SUM(new_cases),0) * 100 As Death_Percentage
	from Covid_Deaths
	Where continent is not null
	Group by date
	Order by 1,2;

-- Global Number currently without date delineation

Select SUM(new_cases) as Total_Cases, SUM(New_deaths) as Total_Deaths, 
	SUM(new_deaths) / nullif(SUM(new_cases),0) * 100 As Death_Percentage
	from Covid_Deaths
	Where continent is not null
	-- Group by date
	Order by 1,2;

-- Looking at Total Population Vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(vac.new_vaccinations) Over (Partition by dea.location Order by dea.Location, dea.date) As Rolling_People_Vaccinated,
	(Rolling_People_Vaccinated/dea.population)*100
	from Covid_Deaths dea
Join Covid_Vaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
	Where dea.continent is not null
	Order by 2,3

-- Use CTE

With PopVsVac (Continent, Location, Date, Population, new_vaccinations, Rolling_People_Vaccinated)
As (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(vac.new_vaccinations) Over (Partition by dea.location Order by dea.Location, dea.date) As Rolling_People_Vaccinated
--(Rolling_People_Vaccinated/population)*100
	from Covid_Deaths dea
Join Covid_Vaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
	Where dea.continent is not null
--Order by 2,3
)
Select *, (Rolling_People_Vaccinated/population)*100
from PopVsVac

-- TEMP TABLE

DROP Table if exists #Percent_Population_Vaccinated
Create Table #Percent_Population_Vaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date Datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric
)

Insert into #Percent_Population_Vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(vac.new_vaccinations) Over (Partition by dea.location Order by dea.Location, dea.date) As Rolling_People_Vaccinated
--(Rolling_People_Vaccinated/population)*100
	from Covid_Deaths dea
Join Covid_Vaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (Rolling_People_Vaccinated/population)*100
from #Percent_Population_Vaccinated


-- Creating View to store data for later visualisation

Create View Percent_Population_Vaccinated As
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(vac.new_vaccinations) Over (Partition by dea.location Order by dea.Location, dea.date) As Rolling_People_Vaccinated
--(Rolling_People_Vaccinated/population)*100
	from Covid_Deaths dea
Join Covid_Vaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


Create View Total_Population_Vs_Vaccinations As
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(vac.new_vaccinations) Over (Partition by dea.location Order by dea.Location, dea.date) As Rolling_People_Vaccinated
--(Rolling_People_Vaccinated/dea.population)*100
	from Covid_Deaths dea
Join Covid_Vaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
	Where dea.continent is not null
--Order by 2,3

Create View Global_Death_Count_Dated As
Select date, SUM(new_cases) as Total_Cases, SUM(New_deaths) as Total_Deaths, 
	SUM(new_deaths) / nullif(SUM(new_cases),0) * 100 As Death_Percentage
	from Covid_Deaths
	Where continent is not null
	Group by date
--Order by 1,2;

-- Global Number currently without date delineation

Create View Global_Death_Count_Undated As
Select SUM(new_cases) as Total_Cases, SUM(New_deaths) as Total_Deaths, 
	SUM(new_deaths) / nullif(SUM(new_cases),0) * 100 As Death_Percentage
	from Covid_Deaths
	Where continent is not null
-- Group by date
--Order by 1,2;

Create View Total_Death_Count_by_Continent As
Select continent, Max(cast(Total_deaths As int)) As Total_Death_Count
 from Covid_deaths
 Where continent is not null
 Group by continent
--Order by Total_Death_Count desc;

Create View Total_Death_Count As
Select location, Max(cast(Total_deaths As int)) As Total_Death_Count
 from Covid_deaths
 Where continent is not null
 Group by location
--Order by Total_Death_Count desc;

Create View Highest_Infection_Count As
Select location, Population, Max(Total_cases) As HighestInfectionCount, Max(total_cases/population *100) as Percent_Population_Infected
 from Covid_Deaths
 --Where location like '%States%'
 Where continent is not null
 Group by location, Population
--Order by Percent_Population_Infected desc;

Create View TotalCase_Vs_TotalDeath As
Select location, date,total_deaths,Total_cases, Round((total_deaths/total_cases *100),5) as Death_Percentage 
 from Covid_Deaths
 --Where location like '%States%'
 Where continent is not null
--Order by 1,2;

Create View TotalCases_Vs_Population As
Select location, date, Population, Total_cases, (total_cases/population *100) as Percent_Population_Infected
 from Covid_Deaths
--Where location like '%States%'
 Where continent is not null
--Order by 1,2;