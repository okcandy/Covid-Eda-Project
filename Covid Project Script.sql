
Select *
From CovidProject..CovidDeaths$
Where continent IS NOT NULL
Order by 3,4

-- Global Covid Deaths
Select continent, Location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths$
Where continent IS NOT NULL
Order by 2,3

-- Global Total Cases vs Total Deaths
Select continent, Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From CovidProject..CovidDeaths$
Where continent IS NOT NULL
Order by 2,3

-- Total Cases vs Total Deaths in Africa
-- Likelihood of dying if you contract covid-19 in Africa
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From CovidProject..CovidDeaths$
Where continent = 'Africa' and continent is NOT NULL
Order by 1,2

--% of Global Population that have Contracted Covid
Select continent, Location, date, Population, total_cases, (total_cases/Population)*100 as Population_Infected
From CovidProject..CovidDeaths$
--Where continent = 'Africa'
Where continent IS NOT NULL
Order by 2,3

--% of population in Africa that have contracted Covid
Select Location, date, Population, total_cases, (total_cases/Population)*100 as Population_Infected
From CovidProject..CovidDeaths$
Where continent = 'Africa' and continent IS NOT NULL
Order by 1,2

--Countries with Highest Infection Rates
Select continent, Location, Population, MAX(total_cases) as Highest_Infection_Rate, MAX((total_cases/Population))*100 as Population_Infected
From CovidProject..CovidDeaths$
--Where continent = 'Africa'
Where continent IS NOT NULL
Group by Location, continent, Population
Order by 5 DESC

--Countries with the Highest Death Counts
Select continent, Location, MAX(cast(total_deaths as int)) as Death_Count
From CovidProject..CovidDeaths$
Where continent IS NOT NULL
Group by continent, Location
Order by 3 DESC

--Countries with the Highest Death Counts in Africa
Select Location, MAX(cast(total_deaths as int)) as Death_Count
From CovidProject..CovidDeaths$
Where continent = 'Africa' and continent IS NOT NULL
Group by Location
Order by 2 DESC


--Continents with the Highest Death Counts
Select Location, MAX(cast(total_deaths as int)) as Death_Count
From CovidProject..CovidDeaths$
Where continent IS NULL
Group by Location
Order by 2 DESC

--Continents with the Highest Death Counts w/o world
Select continent, MAX(cast(total_deaths as int)) as Death_Count
From CovidProject..CovidDeaths$
Where continent is NOT NULL
Group by continent
Order by 2 DESC

--Global Breakdown
Select SUM(new_cases) AS Global_Total_Cases, SUM(cast(new_deaths as int)) AS Global_Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS Death_Percentage
From CovidProject..CovidDeaths$
Where continent is NOT NULL
Order by 1

--Global Daily New Cases and Deaths 
Select date, SUM(new_cases) AS Daily_Total_Cases, SUM(cast(new_deaths as int)) AS Daily_Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS Death_Percentage
From CovidProject..CovidDeaths$
Where continent is NOT NULL
Group by date
Order by 1, 2



---VACCINATION ANALYSIS

Select *
From CovidProject..CovidVaccinations$
Order by location, date

--Total Cases and Vaccinations
Select *
From CovidProject..CovidDeaths$ death
Join CovidProject..CovidVaccinations$ vacc
	On death.location = vacc.location and
	death.date = vacc.date

--Total Population vs Vaccinations
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS bigint)) OVER (Partition by death.location Order by death.location, death.date) AS Aggregate_Vaccinated
From CovidProject..CovidDeaths$ death
Join CovidProject..CovidVaccinations$ vacc
	On death.location = vacc.location and
	death.date = vacc.date
Where death.continent is not null
Order by 2, 3

--Total Population vs Daily New Vaccinations in Africa
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations as int)) OVER (Partition by death.location Order by death.location, death.date) AS Aggregate_Vaccinated
From CovidProject..CovidDeaths$ death
Join CovidProject..CovidVaccinations$ vacc
	On death.location = vacc.location and
	death.date = vacc.date
Where death.continent = 'Africa' and death.continent is not null
Order by 2, 3



DROP TABLE IF EXISTS #PopVaccinatedPercentage
CREATE TABLE #PopVaccinatedPercentage
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Aggregate_Vaccinated numeric
)


Insert into #PopVaccinatedPercentage
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations as bigint)) OVER (Partition by death.location Order by death.location, death.date) AS Aggregate_Vaccinated
From CovidProject..CovidDeaths$ death
Join CovidProject..CovidVaccinations$ vacc
	On death.location = vacc.location and
	death.date = vacc.date
Where death.continent is not null

Select *, (Aggregate_Vaccinated/Population)*100
From #PopVaccinatedPercentage



-- Views

USE CovidProject
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

Create View PopVaccinatedPercentage AS (
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations as bigint)) OVER (Partition by death.location Order by death.location, death.date) AS Aggregate_Vaccinated
From CovidProject..CovidDeaths$ death
Join CovidProject..CovidVaccinations$ vacc
	On death.location = vacc.location and
	death.date = vacc.date
Where death.continent is not null
)

GO