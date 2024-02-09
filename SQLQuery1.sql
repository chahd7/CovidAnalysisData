select * from PortfolioProject..CovidDeaths 

select location, date, total_cases, new_cases, total_deaths, population from PortfolioProject..CovidDeaths order by 1, 2

-- looking at total cases vs total deaths, shows likelihood of dying if you contract covid in country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE (total_deaths/total_cases)*100 IS NOT NULL AND location like 'morocco' and continent is not null
ORDER BY 1, 2;


-- looking total cases vs population , what percentage of population has gotten covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentofPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like 'morocco'
where continent is not null
ORDER BY 1, 2;

--looking at countries with highest infection rate compared to population 
SELECT location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentofPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like 'morocco'
where continent is not null
group by location, population
ORDER BY PercentofPopulationInfected desc



--showing the countries with most deaths per population
--looking at countries with highest infection rate compared to population 
SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like 'morocco'
where continent is not null
group by continent
ORDER BY TotalDeathCount desc

--showing continents with highest death count per population (create a view)
SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null and location != 'World'
group by continent
ORDER BY TotalDeathCount desc

-- global numbers
select sum(new_cases) as TotalNewCasesPerDay, sum(cast(new_deaths as int)) as TotalDeathsPerDay, sum(cast(new_deaths as int)) / sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null 
--group by date 
order by 1,2

-- use cte 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
--Joining the two tables 
-- looking at total population vs vaccinations 
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated--adds up
from PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac 
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/Population)*100 from PopvsVac 

-- temp table 
Drop table if exists #PercentPopulationVaccinated --delete table in case of changes

create table #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated--adds up
from PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac 
on dea.location = vac.location and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 from #PercentPopulationVaccinated

-- creating view to store data for later visualization 

drop view if exists PercentPopulationVaccinated

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated--adds up
from PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac 
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

