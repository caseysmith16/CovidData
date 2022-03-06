Select * 
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select * 
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select data that we are going to be using 

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths 
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population 
Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population 
Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as HighInfectiontPopulationPercent
From PortfolioProject..CovidDeaths
Group by Location, Population 
order by HighInfectiontPopulationPercent desc

-- Looking at Countries with Highest Death Count per Population 
Select Location, MAX(Total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Group by Location
order by TotalDeathCount desc

-- The above does not yield the results that I am looking for because of the data type of total_deaths. Therefore, I need to modify.

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- BROKEN DOWN BY CONTINENT

-- Showing continents with highest death count per population 
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
--Number of cases and deaths each day

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by date 
order by 1,2

-- Global total cases, deaths, and percentage 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2


-- JOIN Covid deaths and vaccination tables 
Select * 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

-- Looking at Total Population vs Vaccinations 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
Order by 2,3

-- Add a rolling count (to see the vaccination number increase by day). Partition by location so that every time we get to a new location, the number resets. 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as RollingVaccinationCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
Order by 2,3

-- USE Common Table Expressions 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinationCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as RollingVaccinationCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
--Order by 2,3
)
Select *, (RollingVaccinationCount/Population)*100 as RollingVaccinationPercent
From PopvsVac


-- Creating View to store data for later visualizations 

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as RollingVaccinationCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 

Create View TotalDeathCount as
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location

Create View DailyDeathPercentage as
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by date 