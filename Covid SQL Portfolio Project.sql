select*
from PortfolioProject.dbo.CovidDeaths
where continent is not null

--select Data that we are going to be using
Select Location, Date, Total_Cases, New_Cases, Total_Deaths, Population
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1, 2

-- looking at total cases vs total death
--show likelihood of dying if you contract covid in a country
Select Location, Date, Total_Cases,  Total_Deaths, (Total_Deaths/Total_Cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
--order by 1, 2

--looking at Total_Case vs Population
--show what percentage of population got covid
Select Location, Date, Total_Cases,  Population, (Total_Cases/Population)*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
where location like '%iran%'
order by 1, 2

--looking at Countries with Highest Infection Rate compared to Population
Select Location, Population, max(Total_Cases) as HighestInfectionCount,  max((Total_Cases/Population))*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by Location, Population
order by 4 desc

--showing Countries with Highest Death Count
Select Location, max(cast(Total_Deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by Location
order by TotalDeathCount desc

--showing Continent with Highest Death Count 
Select continent, max(cast(Total_Deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--showing Daily Global Number
select Date, sum(new_Cases) as TotalCase, sum(cast(new_Deaths as int)) as TotalDeath,
(sum(cast(new_Deaths as int))/sum(new_Cases))*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by Date
order by 1

--showing Global Number
select sum(new_Cases) as TotalCase, sum(cast(new_Deaths as int)) as TotalDeath,
(sum(cast(new_Deaths as int))/sum(new_Cases))*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null

--looking at Population vs Vaccination
--Use CTE
with POPVSVAC as 
(
select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths as Dea
join PortfolioProject.dbo.CovidVaccinations as Vac
on Dea.location=Vac.location
and Dea.date=Vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100 as RollingPopulactionvsVaccination, 
(max(RollingPeopleVaccinated) over (partition by location)/population)*100 as TotalPoulationvsVaccination
from POPVSVAC 
order by 2,3

--looking at Population vs Vaccination
--Use Temp Table
Drop Table if exists  #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths as Dea
join PortfolioProject.dbo.CovidVaccinations as Vac
on Dea.location=Vac.location
and Dea.date=Vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100 as RollingPopulactionvsVaccination, 
(max(RollingPeopleVaccinated) over (partition by location)/population)*100 as TotalPoulationvsVaccination
from #PercentPopulationVaccinated 
order by 2,3

--Creating View to store Data for later visualizations
create view PercentPopulationVaccinated as
select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths as Dea
join PortfolioProject.dbo.CovidVaccinations as Vac
on Dea.location=Vac.location
and Dea.date=Vac.date
where dea.continent is not null

 