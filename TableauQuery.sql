-- case6 :GLOBAL NUMBERS * tableau table 1
Select SUM(new_cases) as GLOBAL_CASES, SUM(cast(new_deaths as int)) as GLOBAL_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM MyPortfolioProject1.dbo.CovideDeaths$
--Where location like '%states%'
WHERE continent is not null 
--Group By date
ORDER BY 1,2

-- case5 : Let's breakdown things by continent * tableau table 2

SELECT location ,   MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM MyPortfolioProject1.dbo.CovideDeaths$
--WHERE Location LIKE '%India%'
WHERE continent is null
and location  not in ('World' , 'European Union' , 'International')
GROUP BY location
ORDER BY TotalDeathCount desc 

-- case3 : Looking for countries with highest infectious rates vs popullation * tableau table 3
SELECT Location ,  population , MAX(total_cases) as TotalInfectionCount ,MAX((total_cases/population))*100 as PercentagePoppulationInfected
FROM MyPortfolioProject1.dbo.CovideDeaths$
--WHERE Location LIKE '%India%'
GROUP BY location , population
ORDER BY PercentagePoppulationInfected desc

-- CASE 3A tableau table 4
SELECT Location ,  population , date , MAX(total_cases) as TotalInfectionCount ,MAX((total_cases/population))*100 as PercentagePoppulationInfected
FROM MyPortfolioProject1.dbo.CovideDeaths$
--WHERE Location LIKE '%India%'
GROUP BY location , population , date
ORDER BY PercentagePoppulationInfected desc

