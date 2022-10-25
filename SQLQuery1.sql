select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that I'll be using

select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths
order by 1,2;

-- Total cases vs Active deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage, population
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2;

-- Total case vs Perentage

select location, date, population, total_cases, total_deaths, (total_cases/population)*100 as case_percentage
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2;

-- Countries with highest infection rate

select location, population, max(total_cases) as HighestInfectionCount , max((total_cases/population))*100 as case_percentage
from PortfolioProject..CovidDeaths
--where location like '%india%'
Group by location, population
order by 4 desc

-- Countries with highest death count

select location, max(cast(total_deaths as int)) as highest_deathcount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by 2 desc

-- Lets break things down by continent

select continent, max(cast(total_deaths as int)) as total_deathCount
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
Group by continent
order by 2 desc

-- Showing continents with the highest death count per population
select continent, max(cast(total_deaths as int)) as highest_death_count 
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by 2

-- Global Numbers

select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date 
order by 1,2


--Looking at Total Population vs Vaccination

select * 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- With CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated