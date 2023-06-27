/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4 

-- Select data that we are going to use
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you get covid in your country(INDIA)
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location = 'INDIA' and
continent is not null
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid (INDIA)

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location = 'India'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select 
Location, 
population, 
Max(total_cases) as HighestInfectionCount,
Round(Max((total_cases/population))*100, 2) as PercentagePopulationInfected 
From PortfolioProject..CovidDeaths
group by 
location,
population
order by 
PercentagePopulationInfected 
desc


-- Countries with Highest Death Count per Population
-- Use PortfolioProject
Select 
location, 
population,
Max(cast(total_deaths as int)) as TotalDeathCount,
round(Max((cast(total_deaths as int))/population)*100,2) as PercetagePopulationDeath
From PortfolioProject..CovidDeaths
where continent is not null
group by location,
population
--order by PercetagePopulationDeath desc
order by TotalDeathCount desc

-- Let's Break things down by continent

-- Showing the continent with highest death count per popution

select
continent,
max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global Numbers

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location = 'INDIA' and
where continent is not null
order by 1,2

 -- Duplicates in the Date column
 select DATE, COUNT(date) --, new_cases
 from PortfolioProject..CovidDeaths
 where continent is not null
 group by date
 having COUNT(date) > 1
 
select 
--date,
sum(new_cases) as New_Cases, 
sum(cast(new_deaths as int)) as New_Deaths,
round(sum(cast(new_deaths as int))/sum(new_cases)*100,2) as New_Death_Percentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1, 2

-- Looking total population vs vaccinations
--use PortfolioProject
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date)
as Rolling_Vaccinatios
--(Rolling_Vaccinations/population)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
order by 2, 3

--use CTE

with PopVsVac
as
(select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date)
as Rolling_Vaccinatios
--(Rolling_Vaccinations/population)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 2, 3
)
select * , 
round((Rolling_Vaccinatios/population)*100,2) as percentage_pop_Rolling_Vacc 
from PopVsVac
order by 2, 3


-- TEMP TABLE	
Drop Table if exists #PercentagePopulationVaccinated
create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccitionations numeric,
RollingPeopleVaccinated numeric,
)
--select * from #PercentagePopulationVaccinated
Insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date)
as Rolling_Vaccinatios
--(Rolling_Vaccinations/population)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null 
--order by 2, 3

select *, round((RollingPeopleVaccinated/population)*100,2)
from #PercentagePopulationVaccinated


-- CREATE VIEWS
Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--(Rolling_Vaccinations/population)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 2, 3

select * from PercentPopulationVaccinated