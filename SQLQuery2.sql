select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Total cases vs Total death

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%pakistan%'
order by 1,2

--Total cases vs population

Select Location, date,population, total_cases,  (total_cases/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%pakistan%'
order by 1,2

--Looking at countries with highest infection rate with respect to population

Select Location, population,  MAX(total_cases) as HighestInfectionCount,MAX(total_cases/population)*100 as populationinfected
from PortfolioProject..CovidDeaths
where continent is not null
group by location,population
order by populationinfected desc

--Showing Countries With Highest Death Count per Population

--Lets Break things down by Continent

Select location,   MAX(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is  null
group by location
order by HighestDeathCount desc

--#2
Select continent,   MAX(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is  not null
group by continent
order by HighestDeathCount desc

--Global Numbers
Select  date, SUM(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths,
Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--#2
Select   SUM(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths,
Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
   on dea.location=vac.location
   and dea.date=vac.date
   where dea.continent is not null
   order by 2,3

   --use CTE

With PopvsVac (Continent,Location, Date, Population,New_Vaccinations, rollingPeopleVaccinated)
   as(
   Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
   on dea.location=vac.location
   and dea.date=vac.date
   where dea.continent is not null
  -- order by 2,3
)
Select * ,(rollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
   on dea.location=vac.location
   and dea.date=vac.date
   --where dea.continent is not null
 --  order by 2,3

Select * ,(rollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating view to store DATA for later Visualization

create view PercentPopulationVaccinated as
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
   on dea.location=vac.location
   and dea.date=vac.date
   where dea.continent is not null


   Select *
   From PercentPopulationVaccinated


