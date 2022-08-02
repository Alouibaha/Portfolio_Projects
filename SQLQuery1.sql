
Select * 
From PortfolioProject..CovidDeaths
Where continent is not null -- To eliminate results for contients
order by 3,4

--Select * 
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Select the data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Show likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths
Where location like '%France%'
order by 2 

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid


Select location, date, population, total_cases, (total_cases/population)*100 as ContaminationPercentage
From PortfolioProject..CovidDeaths
--Where location like '%France%'
Where continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Highest_Contamination_Percentage
From PortfolioProject..CovidDeaths
--Where location like '%France%'
Where continent is not null
Group by location, population
order by Highest_Contamination_Percentage desc


--Showing Countries with Highest Death count per Population

Select location, MAX(cast(total_deaths as int)) as Total_Deaths_Count
From PortfolioProject..CovidDeaths
--Where location like '%France%'
Where continent is not null
Group by location
order by Total_Deaths_Count desc


-- Lets break things down by continent

-- Showing continents with the highest death count

Select continent, MAX(cast(total_deaths as int)) as Total_Deaths_Count
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by Total_Deaths_Count desc


-- Global numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths
--Where location like '%France%'
Where continent is not null
Group by date
order by 1


-- Total numbers around the word

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths
--Where location like '%France%'
Where continent is not null
--Group by date
order by 1,2


-- Looking at Total population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


-- Use CTE (Common Table Expression)

With PopvsVac (Continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (Rolling_People_Vaccinated/population)*100
From PopvsVac




-- TEMP TABLE

DROP Table if exists #Percent_Population_Vaccinated
Create Table #Percent_Population_Vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

Insert into #Percent_Population_Vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (Rolling_People_Vaccinated/population)*100
From #Percent_Population_Vaccinated



-- Creating View to store data for visualizations

CREATE VIEW Percent_Population_Vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select * 
From Percent_Population_Vaccinated