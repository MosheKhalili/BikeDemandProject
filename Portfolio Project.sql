Select *
from PortfolioProject..covidDeaths$
WHERE continent is NOT NULL
order by 3, 4

---Select *
---from PortfolioProject..covidVaccinations$
---order by 3, 4

--- Select data that we are going to be using

SELECT LOCATION, DATE, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..covidDeaths$
order by 1,2

--Looking at total cases vs total deaths
--Shows the likelyhood of death from COVID in your country
SELECT LOCATION, DATE, total_cases, total_deaths, (Total_deaths/total_cases) * 100 as DeathPercentage
FROM PortfolioProject..covidDeaths$
WHERE location like '%states%'
order by 1,2

--Looking at Total cases vs Population
--Shows what percentage of population that got COVID
SELECT LOCATION, DATE, Population, total_cases, (total_cases/Population) * 100 as COVIDPositivePercent
FROM PortfolioProject..covidDeaths$
WHERE location like '%states%'
order by 1,2


--What countries have the highest infection rate compared to population

SELECT LOCATION, Population, MAX(total_cases) as HIghestInfectionCount, (MAX(total_cases)/Population) * 100 as PercentPopulationInfected
FROM PortfolioProject..covidDeaths$
GROUP BY Location, Population
order by PercentPopulationInfected desc


-- show countries with highest deth count per population

SELECT LOCATION, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..covidDeaths$
WHERE continent is not NULL
GROUP BY Location
order by TotalDeathCount desc



--Break it down by continent

--This is showing the continents with the highest death counts

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..covidDeaths$
WHERE continent is not NULL
GROUP BY continent
order by TotalDeathCount desc

-- Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..covidDeaths$
--Where location like '%states%'
where continent is not null 
Group By date
order by 1,2

--Total death percentage 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..covidDeaths$
--Where location like '%states%'
where continent is not null 
order by 1,2


--total population vs vaccination
--Shows the percentage of population that has received  at least one covid vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..covidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select *
from PercentPopulationVaccinated

