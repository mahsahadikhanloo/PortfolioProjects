select * from CovidDatabase..CovidDeaths$
where continent is not null
order by 3,4


select Location, date, total_cases, new_cases, total_deaths, population from CovidDatabase..CovidDeaths$ order by 1,2

---Looking at the Total Cases vs Total Deaths
---Shows the likelihood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercantage
from CovidDatabase..CovidDeaths$ 
where location like '%states%'
order by 1,2


---Looking at the Total Cases vs Population
---Shows what percenage of population got Covid
select Location, date, population, total_cases, (total_cases / population)*100 as InfectedPercantage
from CovidDatabase..CovidDeaths$ 
---where location like '%states%'
order by 1,2


---Looking at countries with Highest Infection Rate compared to Population
select Location, Population, MAX(total_cases) as HighestInfection_Count, MAX((total_cases / population))*100 as InfectedPercantage
from CovidDatabase..CovidDeaths$ 
---where location like '%states%'
Group by Location, Population
order by InfectedPercantage desc


---Showing the Countries with Highest Death Count per Population
select Location, MAX(cast(total_deaths as int)) as TotalDeath_Count
from CovidDatabase..CovidDeaths$ 
---where location like '%states%'
where continent is not null
Group by Location
order by TotalDeath_Count desc



---Let's break this down by continent
select location, MAX(cast(total_deaths as int)) as TotalDeath_Count
from CovidDatabase..CovidDeaths$ 
---where location like '%states%'
where continent is null
Group by location
order by TotalDeath_Count desc


---Showing the continent with the Highest Death Count
select continent, MAX(cast(total_deaths as int)) as TotalDeath_Count
from CovidDatabase..CovidDeaths$ 
---where location like '%states%'
where continent is not null
Group by continent
order by TotalDeath_Count desc


---Global Numbers
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100
as DeathPercantage
from CovidDatabase..CovidDeaths$ 
where continent is not null
Group by date
order by 1,2


---Total Cases across the World
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100
as DeathPercantage
from CovidDatabase..CovidDeaths$ 
where continent is not null
order by 1,2


---Let's load the second table
select * from CovidDatabase..CovidVaccination$ 


---Join the two tables
select *
from CovidDatabase..CovidDeaths$ dea
Join CovidDatabase..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date


---Looking at Total Population vs Vaccination
--- Usinf CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeople_Vaccinated )
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeople_Vaccinated 
from CovidDatabase..CovidDeaths$ dea
inner Join CovidDatabase..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
---order by 2, 3
)
select * , (RollingPeople_Vaccinated / population)*100
from PopvsVac



----TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeople_Vaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeople_Vaccinated 
from CovidDatabase..CovidDeaths$ dea
inner Join CovidDatabase..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
---order by 2, 3

select * , (RollingPeople_Vaccinated / population)*100
from #PercentPopulationVaccinated


--- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeople_Vaccinated 
from CovidDatabase..CovidDeaths$ dea
inner Join CovidDatabase..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
---order by 2, 3

select * from PercentPopulationVaccinated

