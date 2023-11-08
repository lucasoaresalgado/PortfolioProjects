Select *
From [Covid Project].[dbo].['Covid Deaths$']
order by 3,4

--Select *
--From [Covid Project].[dbo].['Covid Vaccinations$']
--order by 3,4

--Select the data which will be used

Select Location, date, total_cases, new_cases, total_deaths, population
From [Covid Project].[dbo].['Covid Deaths$']
order by 1,2

-- Total cases X Total deaths
-- Likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From [Covid Project].[dbo].['Covid Deaths$']
Where location like '%Brazil%'
order by 1,2

--Total Cases vs Population
-- What percentage of the population got Covid
Select Location, date, Population, total_cases, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as PercentPopulationInfected
From [Covid Project].[dbo].['Covid Deaths$']
Where location like '%Brazil%'
order by 1,2

--Countries with the Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From [Covid Project].[dbo].['Covid Deaths$']
--Where location like '%Brazil%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Covid Project].[dbo].['Covid Deaths$']
Where continent is not null
Group by continent
Order by TotalDeathCount

-- GLOBAL NUMBERS
Select date, continent, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From [Covid Project].[dbo].['Covid Deaths$']
Where continent != '' and continent is not null and new_deaths > 0 and new_cases > 0
Group by date, continent
Order by 1,2

-- Total Population X Vaccinations
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
From [Covid Project].[dbo].['Covid Deaths$'] dea
Join [Covid Project].[dbo].['Covid Vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and dea.continent != ''
--Order by 1,2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as 'Total%'
From PopvsVac

--Temp Table

DROP Table if exists #PercentPopulationVaccinated;
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations nvarchar(255),
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
From [Covid Project].[dbo].['Covid Deaths$'] dea
Join [Covid Project].[dbo].['Covid Vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and dea.continent != ''
--Order by 1,2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
From [Covid Project].[dbo].['Covid Deaths$'] dea
Join [Covid Project].[dbo].['Covid Vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and dea.continent != ''

Select *
From PercentPopulationVaccinated