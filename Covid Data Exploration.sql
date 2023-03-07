Select * 
From CovidReport..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From CovidReport..CovidVaccinations
--order by 3,4

---Select data that we are going to be using

Select Location, date, total_cases, total_deaths, population
From CovidReport..CovidDeaths
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidReport..CovidDeaths
where continent is not null
---where location like '%states%'
order by 1,2

Select Location, date, population, total_cases, (total_cases/population)*100 as 
PercentPopulationInfected
From CovidReport..CovidDeaths
where continent is not null
---where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate Compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount , MAX((total_cases/population))*100 as 
PercentPopulationInfected
From CovidReport..CovidDeaths
--where location like '%states%'
where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population
Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From CovidReport..CovidDeaths
----where location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc


Select location, Max(cast(Total_deaths as int)) as TotalDeathCount
From CovidReport..CovidDeaths
----where location like '%states%'
where continent is null
Group by location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing continents with the highest death count population

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From CovidReport..CovidDeaths
----where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc



---Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidReport..CovidDeaths
where continent is not null
---where location like '%states%'
--Group by date
order by 1,2


---Join CovidDeaths and CovidVaccinations

Select *
From CovidReport..CovidDeaths Dea
Join CovidReport..CovidVaccinations Vac
On Dea.location = Vac.location
and Dea.date = Vac.date

--Looking at Total Population vs Vaccinations
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
From CovidReport..CovidDeaths Dea
Join CovidReport..CovidVaccinations Vac
On Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
order by 2,3

Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CONVERT(int, Vac.new_vaccinations)) OVER (Partition by Dea.location order by Dea.location, 
Dea.date) as RollingPeopleVaccinated
From CovidReport..CovidDeaths Dea
Join CovidReport..CovidVaccinations Vac
On Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
order by 2,3



--USE CTE

with POPvsVAC (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CONVERT(int, Vac.new_vaccinations)) OVER (Partition by Dea.location order by Dea.location, 
Dea.date) as RollingPeopleVaccinated
From CovidReport..CovidDeaths Dea
Join CovidReport..CovidVaccinations Vac
On Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From POPvsVAC



--TEMP TABLE
Drop Table if  exists #PercentagePopulationVaccinated
Create Table #PercentpopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentpopulationVaccinated
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CONVERT(int, Vac.new_vaccinations)) OVER (Partition by Dea.location order by Dea.location, 
Dea.date) as RollingPeopleVaccinated
From CovidReport..CovidDeaths Dea
Join CovidReport..CovidVaccinations Vac
On Dea.location = Vac.location
and Dea.date = Vac.date
--where Dea.continent is not null
--order by 2,3,

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentpopulationVaccinated




---Creating a view to store data for visualisations


Create View #PercentpopulationVaccinated as
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CONVERT(int, Vac.new_vaccinations)) OVER (Partition by Dea.location order by Dea.location, 
Dea.date) as RollingPeopleVaccinated
From CovidReport..CovidDeaths Dea
Join CovidReport..CovidVaccinations Vac
On Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
--order by 2,3,


Select * 
From #PercentpopulationVaccinated