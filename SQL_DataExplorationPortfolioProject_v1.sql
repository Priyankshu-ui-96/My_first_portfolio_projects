SELECT*
FROM MyPortfolioProject1.dbo.CovideDeaths$
WHERE continent is not null
ORDER BY 3,4


--SELECT*
--FROM MyPortfolioProject1.dbo.CovideVaccinations$
--ORDER BY 3,4

-- select data that we are going to use
SELECT Location , date , total_cases , new_cases , total_deaths , population
FROM MyPortfolioProject1.dbo.CovideDeaths$
ORDER BY 1 ,2

-- case1 : percentage of death i.e, toatl_deaths vs total cases 
-- shows the rough estimates of dying if you get contract by covid-19
SELECT Location , date , total_cases , total_deaths , (total_deaths/total_cases)*100 as DeathPercentage 
FROM MyPortfolioProject1.dbo.CovideDeaths$
WHERE Location LIKE '%India%'
ORDER BY 1 , 2

-- case2 : total cases vs population
-- shows what percentage of popullation got covid-19
SELECT Location , date ,  population , total_cases ,(total_cases/population)*100 as CovidPercentage 
FROM MyPortfolioProject1.dbo.CovideDeaths$
--WHERE Location LIKE '%India%'
ORDER BY 1 , 2

-- case3 : Looking for countries with highest infectious rates vs popullation
SELECT Location ,  population , MAX(total_cases) as TotalInfectionCount ,MAX((total_cases/population))*100 as PercentagePoppulationInfected
FROM MyPortfolioProject1.dbo.CovideDeaths$
--WHERE Location LIKE '%India%'
GROUP BY location , population
ORDER BY PercentagePoppulationInfected desc

-- case4 : Showing countries with highest death count per population 
SELECT Location ,  population , MAX(cast(total_deaths as int)) as TotalDeathCount ,MAX((total_deaths/population))*100 as HighestDeathPercentage
FROM MyPortfolioProject1.dbo.CovideDeaths$
--WHERE Location LIKE '%India%'
WHERE continent is not null
GROUP BY location , population
ORDER BY TotalDeathCount desc 

-- case5 : Let's breakdown things by continent

SELECT location ,   MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM MyPortfolioProject1.dbo.CovideDeaths$
--WHERE Location LIKE '%India%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc 

-- case6 : GLOBAL NUMBERS
Select SUM(new_cases) as GLOBAL_CASES, SUM(cast(new_deaths as int)) as GLOBAL_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM MyPortfolioProject1.dbo.CovideDeaths$
--Where location like '%states%'
WHERE continent is not null 
--Group By date
ORDER BY 1,2

-- case7 : Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT  dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int )) OVER (Partition by dea.location ORDER BY dea.location , dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM MyPortfolioProject1..CovideDeaths$ dea
JOIN MyPortfolioProject1..CovideVaccinations$ vac
ON  dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

-- case 8 : Uing CTE(Common Expression Table) i.e, to perdform calculation on PARTITION BY 

with PopvsVac ( continent , location , date , population , new_vaccinations ,RollingPeopleVaccinated)
as
(
SELECT  dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int )) OVER (Partition by dea.location ORDER BY dea.location , dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM MyPortfolioProject1..CovideDeaths$ dea
JOIN MyPortfolioProject1..CovideVaccinations$ vac
ON  dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY, 3
)
SELECT* , (RollingPeopleVaccinated/population)*100 
FROM PopvsVac

-- case 9 : Temp Table to make calculations on previous queries
DROP Table if exists #PercentPopulationVacinated
CREATE TABLE #PercentagePopulationVacinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric 

)
Insert into #PercentagePopulationVacinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM MyPortfolioProject1..CovideDeaths$ dea
JOIN MyPortfolioProject1..CovideVaccinations$ vac
ON  dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--ORDER BY, 3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentagePopulationVacinated

-- case 10 : creating VIEW to store data for Tableau and PowerBI Visualizations 

CREATE VIEW PercentagePopulationVacinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM MyPortfolioProject1..CovideDeaths$ dea
JOIN MyPortfolioProject1..CovideVaccinations$ vac
ON  dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--ORDER BY, 3

select* 
FROM PercentagePopulationVacinated


-- VIEW 2:
CREATE VIEW GlobalNumbers as
Select SUM(new_cases) as GLOBAL_CASES, SUM(cast(new_deaths as int)) as GLOBAL_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM MyPortfolioProject1.dbo.CovideDeaths$
--Where location like '%states%'
WHERE continent is not null 
--Group By date
-- order by 1, 2

select*
from GlobalNumbers

-- view 3:
CREATE VIEW TotalDeaths as
SELECT location ,   MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM MyPortfolioProject1.dbo.CovideDeaths$
--WHERE Location LIKE '%India%'
WHERE continent is null
GROUP BY location
--DER BY TotalDeathCount desc 

SELECT*
from TotalDeaths
