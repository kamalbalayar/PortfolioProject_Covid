select*
from Covid..Covid_death
order by 3,4

--select*
--from Covid..Covid_Vaccination
--order by 3,4

-- select Data that we are going to be using

select location, date, total_cases, total_deaths, population
from Covid..Covid_death
order by 1, 2


-- looking at Total cases VS total dealth
SELECT location, date, total_cases, total_deaths, 
       (CAST(total_deaths AS numeric) / CAST(total_cases AS numeric)) * 100 AS DeathPercentage
FROM Covid..Covid_death
ORDER BY 1, 2

--find out in States with poplulation

SELECT location, date, total_cases, population, 
       (CAST(total_cases AS numeric) / population) * 100 AS DeathPercentage
FROM Covid..Covid_death
where location like '%states%'
ORDER BY 1, 2;

-- find out highest number of infection rate base on poplation

SELECT location, max(total_cases) as higestInfectionCount, population, 
       (CAST(max(total_cases) AS numeric) / population) * 100 AS PercentageInfectionCount
FROM Covid..Covid_death
--where location like '%states%'
group by population, location
order by PercentageInfectionCount desc


--showing Countries wiht Highest Dealth Count
SELECT location, max(total_deaths) as TotalDealthCount, population, 
       (CAST(max(total_deaths) AS numeric) / population) * 100 AS TotalDealthsCount
FROM Covid..Covid_death
--where location like '%states%'
group by population, location
order by TotalDealthCount desc


--Global Data

Select date, sum(new_cases) as total_case, sum(new_deaths) as total_death, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM Covid..Covid_death
where continent is not null
group by date
order by 1, 2

--Looking at Total Population and Vaccination


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM Covid..Covid_death dea
join Covid..Covid_Vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--partition by Location

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location)
FROM Covid..Covid_death dea
join Covid..Covid_Vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--partition by location and order by location and date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)
FROM Covid..Covid_death dea
join Covid..Covid_Vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
order by 2,3


--USE CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM Covid..Covid_death dea
join Covid..Covid_Vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
)
select *
from PopvsVac

-- USE CTC

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM Covid..Covid_death dea
join Covid..Covid_Vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
)
--to findout percentage
select *, (RollingPeopleVaccinated/population)*100 
from PopvsVac


---Temp Table
Create Table #PercentPoulationVaccinated
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPoulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM Covid..Covid_death dea
join Covid..Covid_Vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null

select *, (RollingPeopleVaccinated/population)*100
from #PercentPoulationVaccinated

-- DROP TEMP TABLE

DROP table if exists #PercentPoulationVaccinated
Create Table #PercentPoulationVaccinated
(
    continent nvarchar(225),
    location nvarchar(225),
    date datetime,
    population numeric,
    new_vaccinations numeric,
    RollingPeopleVaccinated numeric,
)

Insert into #PercentPoulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM Covid..Covid_death dea
join Covid..Covid_Vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null

select *, (RollingPeopleVaccinated/population)*100 
from #PercentPoulationVaccinated


-- Createing View To store Data for Later Visualization

create View PPV as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM Covid..Covid_death dea
join Covid..Covid_Vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
--order by 2,3


--From Views table
select*
from PPV

