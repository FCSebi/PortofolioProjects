Select *
From CovidDB..CovidDeaths
Where continent is not null
Order by 1,2


Select Location, date, total_cases, total_deaths
From CovidDB..CovidDeaths
Where continent is not null
Order by 1,2

--Select *
--From CovidDB..CovidVaccinations
--order by 3,4

--Looking at Total cases vs total deaths

--Select Location, date, total_cases, total_deaths, new_cases, (total_deaths/total_cases)*100 as DeathPercentage
--From CovidDB..CovidDeaths
--order by 1,2

--Select data to be used

Select Location, date, total_cases, new_cases, total_deaths,population
From CovidDB..CovidDeaths
Order by 1,2,3


Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
From CovidDB..CovidDeaths
Order by 1,2

-- Total cases vs total deaths and death%

Select location, date, total_cases, population, total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
From CovidDB..CovidDeaths
Where location like 'Romania'
Order by 6 DESC

--Change date format

--SELECT 
--FORMAT(date,'MM-dd-yyyy') AS formatted_date --YEAR-MONTH-DAY
--FROM CovidDB..CovidDeaths


-- Check if dates are in 'MM/dd/yyyy' format

Select DATE
FROM CovidDB..CovidDeaths
WHERE 
date LIKE '[0-1][0-9]/[0-3][0-9]/[0-9][0-9][0-9][0-9]';


---Tableau 1

Select SUM(CONVERT(float, new_cases)) as Total_cases, SUM(cast(new_deaths as int )) as total_deaths--(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
From CovidDB..CovidDeaths
Where continent is not null
--Group by 1
Order by 1,2

--Countries with highest Infection rate compared with population -- Tableau 3

Select Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS PercentPopulationInfected
From CovidDB..CovidDeaths
---Max((total_cases/population))* 100 as PercentPopulationInfected
---Where location like 'Romania' 
Group By Location, Population
Order by 4 Desc

----Tableau 4

Select Location, Population, MAX(total_cases) AS HighestInfectionCount
From CovidDB..CovidDeaths
Group By Location, Population
Order by 1 asc

Select Location, Population, date, MAX(total_cases) AS HighestInfectionCount, MAX(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS PercentPopulationInfected
From CovidDB..CovidDeaths
---Max((total_cases/population))* 100 as PercentPopulationInfected
---Where location like 'Romania' 
Group By Location, Population, date
Order by 5 Desc



Select Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDB..CovidDeaths
 ---WHERE location like '%states%'
Where continent is not null
Group By location
Order by TotalDeathCount DESC

-- Data by continent

Select Continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDB..CovidDeaths
 ---WHERE location like '%states%'
Where continent is not null
Group By continent
Order by TotalDeathCount DESC

--Data by location 2

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDB..CovidDeaths
Where continent is not null
and location not in('world', 'European Union', 'International')
Group by location
Order by TotalDeathCount desc


--Percent population infected







-- Continent with the highest death rate

Select Continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDB..CovidDeaths
Where continent is not null
Group By continent
Order by TotalDeathCount DESC


Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
FROM CovidDB..CovidDeaths
Where total_cases is not null
--Group By date
Order by date DESC

--Global data by date

Select date, SUM(cast(new_cases as int))as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/NULLIF(SUM(New_cases, 0) * 100 as DeathPercentage
FROM CovidDB..CovidDeaths
Where new_cases is not null
Group by date
Order by 2 desc

--Select Distinct location...

Select DISTINCT location
FROM CovidDB..CovidDeaths
Order by 1


---Convert Varchart to float


Select SUM(cast(new_cases as float))as total_cases, SUM(cast(new_deaths as float)) as total_deaths,
SUM(cast(new_deaths as float))/(SUM(new_cases)* 100 as DeathPercentage

FROM CovidDB..CovidDeaths
Where continent is not null
--Group by date
Order by 1,2 desc




-- Join tables

 Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
FROM CovidDB..CovidDeaths dea
Join CovidDB..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2

 --- 


 Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
FROM CovidDB..CovidDeaths dea
Join CovidDB..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3 

--USE CTE

With PopvsVac (Continent, Location, Date, Population, Mew_Vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
FROM CovidDB..CovidDeaths dea
Join CovidDB..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


---TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinatedn numeric)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
FROM CovidDB..CovidDeaths dea
Join CovidDB..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



Select *
From #PercentPopulationVaccinated


---View to store data for later Visualizations

Create View #PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
FROM CovidDB..CovidDeaths dea
Join CovidDB..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3 


---2
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDB..CovidDeaths
Where continent is null
and location not in ('World', 'European Union', 'International')

Group by location
Order by TotalDeathCount desc