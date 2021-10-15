---Data exploration of Covid 19 data---
---Skills used Aggregate functions, CTE's, Data types, Joins, Temp tables, Views, Window functions---

Select *
from PortfolioCovidproject..CovidDeaths$
-----------------------------------------------------------------------------------------------------
--Exploring global cases, deaths, Death_percenatge, Percentage population infected--

--Total cases, Total deaths and Death_Percentage
select sum(new_cases) as Totalcases, sum(cast(new_deaths as int)) as Totaldeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as Death_Percentage
from PortfolioCovidproject..CovidDeaths$
where continent is not null

--World Total cases by population
select location, population, MAX(cast(total_deaths as int)) as coronadeaths, MAX(total_deaths/population)*100 as DeathPopulationpercentage
from PortfolioCovidproject..CovidDeaths$
where location = 'world' 
group by location, population
order by DeathPopulationpercentage desc

--Continents by Total deaths 
Select continent, SUM(cast(new_deaths as int)) as totaldeath_count
from PortfolioCovidproject..CovidDeaths$
where continent is not null
group by continent
order by totaldeath_count desc

--Continents by Total cases 
Select continent, SUM(cast(new_cases as int)) as totalcases_count
from PortfolioCovidproject..CovidDeaths$
where continent is not null
group by continent
order by totalcases_count desc

-----------------------------------------------------------------------------------------------------
--Analysing Africa and Kenya cases,deaths, Death_percenatge, Percentage population infected---
--Analysing total deaths vs total cases for Africa
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioCovidproject..CovidDeaths$
where location = 'africa'
order by 1,2

--Analysing total cases vs Population for Africa
select location, date, total_cases, (total_cases/population)*100 as InfectedPopulationpercentage
from PortfolioCovidproject..CovidDeaths$
where location = 'africa'
order by location,date

--Analysing total deaths vs total cases for Kenya
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioCovidproject..CovidDeaths$
where location like '%kenya%'
order by location,date

--Analysing total cases vs Population for Kenya
select location, date, total_cases, (total_cases/population)*100 as InfectedPopulationpercentage
from PortfolioCovidproject..CovidDeaths$
where location like '%kenya%'
order by 1,2
------------------------------------------------------------------------------------------------------
---Analysing countries with highest cases,deaths, Death_percenatge, Percentage population infected----
--Countries with Highest Cases per population
select location, population, MAX(total_cases), MAX((total_cases/population))*100 as InfectedPopulationpercentage
from PortfolioCovidproject..CovidDeaths$
where continent is not null
group by population, location
order by InfectedPopulationpercentage DESC

--Countries with Highest Death per population
select location, population, MAX(cast(total_deaths as int)) as coronadeaths, MAX(total_deaths/population)*100 as DeathPopulationpercentage
from PortfolioCovidproject..CovidDeaths$
where continent is not null 
group by location, population
order by DeathPopulationpercentage desc

--Countries with Highest Cases per population against time
select date, location, population, MAX(total_cases) as total_cases, MAX((total_cases/population))*100 as InfectedPopulationpercentage
from PortfolioCovidproject..CovidDeaths$
where continent is not null
group by population, location, date
order by location
------------------------------------------------------------------------------------------------------
---Using CTE to Comparing vaccinations and population by country------------
With VaccinationvsPopulation (continent, location, date, population,new_vaccinations, cumulative_vaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as cumulative_vaccination
from PortfolioCovidproject..CovidDeaths$ dea
join PortfolioCovidproject..CovidVaccinations$ vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)
select *, (cumulative_vaccination/population)*100 as vaccinatedpopulationpercentage
from VaccinationvsPopulation

------------------------------------------------------------------------------------------------------
---Using Temp table for calculation on query---
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, New_vaccinations numeric, Cumulativepeoplevaccianted numeric)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Cumulativepeoplevaccinated
From PortfolioCovidproject..CovidDeaths$ dea
Join PortfolioCovidproject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Select *, (Cumulativepeoplevaccianted/Population)*100
From #PercentPopulationVaccinated

------------------------------------------------------------------------------------------------------
----Creating views for viewing peopel vaccianted------------------------------------------------------
Create view Peoplevaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Peoplevaccinated
From PortfolioCovidproject..CovidDeaths$ dea
Join PortfolioCovidproject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *
From Peoplevaccinated
------------------------------------------------------------------------------------------------------
