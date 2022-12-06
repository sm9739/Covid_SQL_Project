Select *
From DataAnalyst_SQL..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From DataAnalyst_SQL..CovidVaccinations
--Order by 3,4

-- Select Data that we are going to be using.

Select location, date, total_cases, new_cases, total_deaths, population
From DataAnalyst_SQL..CovidDeaths
Where continent is not null
Order by 1,2

-- Looking at the Total Cases vs Total Deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From DataAnalyst_SQL..CovidDeaths
Where continent is not null
Order by 1,2

-- Looking at Total Cases vs Population
Select location, date, total_cases, population, (total_cases/population)*100 as covid_population_percentage
From DataAnalyst_SQL..CovidDeaths
Where continent is not null
Order by 1,2

-- Countries with Highest infected rate compared to population
Select location, max(total_cases) as highest_infection_count, population, max((total_cases/population)*100) as percentage_population_infected
From DataAnalyst_SQL..CovidDeaths
Where continent is not null
Group by location, population
Order by percentage_population_infected desc

-- Countries with Highest death count per population
Select location, max(cast(total_deaths as int)) as death_count
From DataAnalyst_SQL..CovidDeaths
Where continent is not null
Group by location
Order by death_count desc


Select location, max(cast(total_deaths as int)) as death_count
From DataAnalyst_SQL..CovidDeaths
Where continent is null
Group by location
Order by death_count desc

-- Continent wise Highest death count per population
Select continent, max(cast(total_deaths as int)) as death_count
From DataAnalyst_SQL..CovidDeaths
Where continent is not null
Group by continent
Order by death_count desc

-- Global numbers
Select sum(new_cases) as total_new_cases, sum(cast(new_deaths as int)) as total_new_deaths, (sum(new_cases)/sum(cast(new_deaths as int)))*100 as death_percentage
From DataAnalyst_SQL..CovidDeaths
Where continent is not null
Order by 1,2

Select date, sum(new_cases) as total_new_cases, sum(cast(new_deaths as int)) as total_new_deaths, (sum(new_cases)/sum(cast(new_deaths as int)))*100 as death_percentage
From DataAnalyst_SQL..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

-- Total population vs vaccination
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, sum(convert(int,CV.new_vaccinations)) over (partition by CD.location, CD.date) as rooling_vaccination
From DataAnalyst_SQL..CovidDeaths CD
Join DataAnalyst_SQL..CovidVaccinations CV
	On CD.location = CV.location
	and CD.date = CV.date
Where CD.continent is not null
Order by 2,3

-- Use CTE
With PopvsVac (continent, location, date, population, new_vaccination, rolling_vaccination)
as 
(
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, sum(convert(int,CV.new_vaccinations)) over (partition by CD.location, CD.date) as rolling_vaccination
From DataAnalyst_SQL..CovidDeaths CD
Join DataAnalyst_SQL..CovidVaccinations CV
	On CD.location = CV.location
	and CD.date = CV.date
Where CD.continent is not null
) 
Select*, (rolling_vaccination/population)*100
From PopvsVac

-- Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rolling_vaccination numeric
)

Insert into #PercentPopulationVaccinated
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, sum(convert(int,CV.new_vaccinations)) over (partition by CD.location, CD.date) as rolling_vaccination
From DataAnalyst_SQL..CovidDeaths CD
Join DataAnalyst_SQL..CovidVaccinations CV
	On CD.location = CV.location
	and CD.date = CV.date
Where CD.continent is not null
Select*, (rolling_vaccination/population)*100 as rolling_vaccination_per_population
From #PercentPopulationVaccinated

-- Creating view to store data for visualizations
Create View PercentPopulationVaccinated as
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, sum(convert(int,CV.new_vaccinations)) over (partition by CD.location, CD.date) as rolling_vaccination
From DataAnalyst_SQL..CovidDeaths CD
Join DataAnalyst_SQL..CovidVaccinations CV
	On CD.location = CV.location
	and CD.date = CV.date
Where CD.continent is not null

Select*
From PercentPopulationVaccinated