select *
from PortfolioProject.dbo.[Covid deaths]
where continent is not null
order by 3,4

--select *
--from PortfolioProject.dbo.[Covid vaccinations]
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.[Covid deaths]
order by 1,2

--Look at Total cases vs total deaths
--shows liklihood of dying if you contract covid in your country

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS death_percentage
from PortfolioProject.dbo.[Covid deaths]
where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population 

Select location, date, total_cases,population, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population), 0)) * 100 AS death_percentage
from PortfolioProject.dbo.[Covid deaths]
--where location like '%states%'
order by 1,2


--Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount,  
(CONVERT(float, MAX(total_cases)) / NULLIF(CONVERT(float, MAX(population)), 0)) * 100 AS PercentPopulationInfected
from PortfolioProject.dbo.[Covid deaths]
--where location like '%states%'
Group by population, location 
order by PercentPopulationInfected desc

--Showing countries with highest death count per population 

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount,  
(CONVERT(float, MAX(total_cases)) / NULLIF(CONVERT(float, MAX(population)), 0)) * 100 AS PercentPopulationInfected
from PortfolioProject.dbo.[Covid deaths]
--where location like '%states%'
where continent is not null
Group by location 
order by TotalDeathCount desc

---breakdown by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount,  
(CONVERT(float, MAX(total_cases)) / NULLIF(CONVERT(float, MAX(population)), 0)) * 100 AS PercentPopulationInfected
from PortfolioProject.dbo.[Covid deaths]
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--updated continent values 

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount,  
(CONVERT(float, MAX(total_cases)) / NULLIF(CONVERT(float, MAX(population)), 0)) * 100 AS PercentPopulationInfected
from PortfolioProject.dbo.[Covid deaths]
--where location like '%states%'
where continent is null
Group by location
order by TotalDeathCount desc


--showing continents with highest death count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount,  
(CONVERT(float, MAX(total_cases)) / NULLIF(CONVERT(float, MAX(population)), 0)) * 100 AS PercentPopulationInfected
from PortfolioProject.dbo.[Covid deaths]
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--global numbers

Select date, SUM(new_cases), sum(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS death_percentage
from PortfolioProject.dbo.[Covid deaths]
--where location like '%states%'
where continent is not null
group by date 
order by 1,2

--looking at total population vs total vaccinations 
select dea.continent, dea.continent, dea.date, dea.population, dea.new_vaccinations
from PortfolioProject.dbo.[Covid deaths] dea
join PortfolioProject.dbo.[Covid vaccinations] vac
   On dea.location = vac.location
   and dea.date = vac.date


select dea.continent, dea.continent, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject.dbo.[Covid deaths] dea
join PortfolioProject.dbo.[Covid vaccinations] vac
   On dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
   order by 1,2,3

   --partitions

   select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location)
from PortfolioProject.dbo.[Covid deaths] dea
join PortfolioProject.dbo.[Covid vaccinations] vac
   On dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
   order by 2,3 desc

--total people vs vaccinations (using CTE)

with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.[Covid deaths] dea
join PortfolioProject.dbo.[Covid vaccinations] vac
   On dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
   --order by 2,3 desc 
   )
   select*, (RollingPeopleVaccinated/population) *100 as percentage
   from PopvsVac


--temp table

Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated
--with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
--as
--(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.[Covid deaths] dea
join PortfolioProject.dbo.[Covid vaccinations] vac
   On dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
   --order by 2,3 desc 
   
   select*, (RollingPeopleVaccinated/population) *100 as percentage
   from #PercentPopulationVaccinated

--creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.[Covid deaths] dea
join PortfolioProject.dbo.[Covid vaccinations] vac
   On dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
   --order by 2,3 desc 


Select *
From PercentPopulationVaccinated

