Select * 
From PortfolioProject.dbo.CovidDeaths 
--Where continent is not null
Order By 3, 4

--Select * 
--From PortfolioProject.dbo.CovidVaccinations 
--Order By 3, 4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 1,2


-- Data Exploration
-- Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in India
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'India' 
and continent is not null
Order By 1,2

-- Shows what percentage of the population got covid in India
Select location, date, population, total_cases, (total_cases/population)*100 as InfectedPopulationPercent
From PortfolioProject..CovidDeaths
Where location = 'India'
and continent is not null
Order By 1,2

-- Showing countries with the highest infection rate compared to their population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPopulationPercent
From PortfolioProject..CovidDeaths
Where continent is not null
Group By location, population
Order By InfectedPopulationPercent desc

-- Showing Countries with the highest percentage

Select location, population, MAX(total_deaths) as HighestDeathCount, MAX((total_deaths/population))*100 as PopulationDeathPercent
From PortfolioProject..CovidDeaths
Where continent is not null
Group By location, population
Order By PopulationDeathPercent desc

-- Showing Countries with the highest death count per population

Select location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths 
Where continent is not null
Group By location, population
Order By TotalDeathCount desc

-- Showing Continents with the highest death count per population
-- what happens when we group by continent, population

--Select location, MAX(population) as TotalPopulation, MAX(cast(total_deaths as int)) as TotalDeathCount
--From PortfolioProject..CovidDeaths 
--Where continent is null
--Group By location
--Order By TotalDeathCount desc

Select continent, MAX(population) as TotalPopulation, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths 
Where continent is not null
Group By continent
Order By TotalDeathCount desc


--select count(distinct(location))
--from PortfolioProject..CovidDeaths
--where continent is null


 -- Global Numbers

-- Death % on different days
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
From PortfolioProject..CovidDeaths 
Where continent is not null
Group By date
Order By 1,2

-- Death % of the entire population
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
From PortfolioProject..CovidDeaths 
Where continent is not null
Order By 1,2


-- Looking at total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location 
and dea.date = vac.date
Where dea.continent is not null
Order by 2,3 

-- Over tells the sql engine that its an analytical function and not an aggregate function
--The PARTITION BY clause divides the result set into partitions and changes how the window function is calculated. 
--The PARTITION BY clause does not reduce the number of rows returned.
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as 'VaccinatedPopulationBDate'
--, (VaccinatedPopulationByDate/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location 
and dea.date = vac.date
Where dea.continent is not null
Order by 2,3 

-- USE CTE
-- Note that we need to mention the same no of columns
With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, VaccinatedPopulatedByDate)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as 'VaccinatedPopulationBDate'
--, (VaccinatedPopulationByDate/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location 
and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3 
)

Select *, (VaccinatedPopulatedByDate/Population) * 100 as VaccinatedPercentage 
From PopVsVac


-- TEMP Table

Drop Table if exists #PercentpopulationVaccinated
Create Table #PercentpopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
VaccinatedPopulationByDate numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as 'VaccinatedPopulationBDate'
--, (VaccinatedPopulationByDate/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location 
and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3 

Select *, (VaccinatedPopulationByDate/Population) * 100 as PercentPopulationVaccinated
From  #PercentpopulationVaccinated


-- Create Views

Drop View if exists PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as 'VaccinatedPopulationBDate'
--, (VaccinatedPopulationByDate/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location 
and dea.date = vac.date
Where dea.continent is not null

Select * From PercentPopulationVaccinated

--Drop View if exists DeathPercentByDay
--Create View DeathPercentByDay as
--Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
--From PortfolioProject..CovidDeaths 
--Where continent is not null
--Group By date
----Order By 1,2