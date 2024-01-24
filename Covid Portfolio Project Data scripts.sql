select *
from EDWINODOYOPortfolioProject..CovidDeaths
order by 1,2

--select *
--from EDWINODOYOPortfolioProject..CovidVaccinations
--order by 1, 2 

--First Data we are Querying 

select location,date, total_cases, new_cases, total_deaths, population
from EDWINODOYOPortfolioProject..CovidDeaths
order by 1, 2 

--Consider Total Cases vs Total Death

select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from EDWINODOYOPortfolioProject..CovidDeaths
order by 1, 2  

--lets consider a defined location, United States

select location,date, total_cases, total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage 
from EDWINODOYOPortfolioProject..CovidDeaths
where location like '%States%'
order by 1,2  
 
 --Likelihood of dying if one contacts covid in United Kingdom

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from EDWINODOYOPortfolioProject..CovidDeaths
where location like '%Kingdom%'
order by 1,2  

--total cases vs Population 

select location, date, total_cases, population, (total_cases/population)*100 As CovidContractionPercentage
from EDWINODOYOPortfolioProject..CovidDeaths
WHERE location like '%Kingdom%'
ORDER BY 1, 2
 
 --Countries with Highest Infection Rate compared to Population

select location,population,  MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 As CovidContractionPercentage
from EDWINODOYOPortfolioProject..CovidDeaths
--WHERE location like '%Kingdom%'
group by location, population
ORDER BY CovidContractionPercentage desc

--showing the countries with Highest death counts per population 

select location, Max(total_deaths) as TotalDeathCount 
from EDWINODOYOPortfolioProject..CovidDeaths
--WHERE location like '%Kingdom%'
where continent is not null 
group by  location
order by TotalDeathCount desc

--also for nvarchar case consider

select location, Max(cast(total_deaths)as int) as TotalDeathCount
from EDWINODOYOPortfolioProject..CovidDeaths
--WHERE location like '%Kingdom%'
where continent is not null 
group by  location
order by TotalDeathCount desc

--lets consider data per continent 

select continent, max(total_deaths) as TotalDeathCount
from EDWINODOYOPortfolioProject..CovidDeaths
--WHERE location like '%Kingdom%'
where continent is not null 
group by  continent
order by TotalDeathCount desc

-- Global Considerations

--Global Death Percentage. 

select 
SUM(new_cases) as TotalCases,
SUM(cast(new_deaths as int))as TotalDeaths, 
sum(cast(new_deaths as int ))/sum(new_cases)* 100 AS DeathPercentage
from EDWINODOYOPortfolioProject..CovidDeaths
--WHERE location like '%Kingdom%'
where continent is not null 
order by 1, 2

--TABLE TWO 

Select *
From EDWINODOYOPortfolioProject..CovidDeaths Dea
Join EDWINODOYOPortfolioProject..CovidVaccinations Vac
on dea.location = vac.location
and dea.date = vac.date 

--Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From EDWINODOYOPortfolioProject..CovidDeaths Dea
Join EDWINODOYOPortfolioProject..CovidVaccinations Vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
order by 1, 2, 3 

---Rolling People Vaccinated 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations))OVER
(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
From EDWINODOYOPortfolioProject..CovidDeaths Dea
Join EDWINODOYOPortfolioProject..CovidVaccinations Vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null 
Order by 1, 2, 3

---CTE with Population vs Vaccination

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int, vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date
) as RollingPeopleVaccinated 
From EDWINODOYOPortfolioProject..CovidDeaths Dea
Join EDWINODOYOPortfolioProject..CovidVaccinations Vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is NOT NULL 
--order by 1, 2, 3
)
select *, (RollingPeopleVaccinated/Population *100)
from PopvsVac

--ALTERNATIVE  TABLE (TEMP)

DROP IF EXIST #PercentPopulationvaccinated 
Create Table #PercentPopulationvaccinated 
(
Continet nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric
new_vaccinations numeric, 
RollingPeopleVaccinated numeric)

insert into
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int, vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date
) as RollingPeopleVaccinated 
From EDWINODOYOPortfolioProject..CovidDeaths Dea
Join EDWINODOYOPortfolioProject..CovidVaccinations Vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is NOT NULL 

select *,(RollingPeopleVaccinated/Population *100)
from #PercentPopulationvaccinated 

--View to store data for later calculations 
create view PercentPopulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int, vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date
) as RollingPeopleVaccinated 
From EDWINODOYOPortfolioProject..CovidDeaths Dea
Join EDWINODOYOPortfolioProject..CovidVaccinations Vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is NOT NULL 


Select *
from PercentPopulationvaccinated 
