Select * from PortfollioProject..['covid deaths$']
Where continent is not null
order by 3,4

--Select * from PortfollioProject..['covid deaths$']
--order by 3,4

--Select Data taht we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from PortfollioProject..['covid deaths$']
Where continent is not null
order by 1,2

--Looking at total cases vs total deaths
-- Shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfollioProject..['covid deaths$']
Where location like '%states%'
order by 1,2

--Looking at total cases vs population
--Shows what percentage of population with Covid
Select location, date, population,total_cases, (total_cases/population)*100 as CovidPositivePercentage
from PortfollioProject..['covid deaths$']
--Where location like '%states%'
order by 1,2

--Looking at countries with highest infection rate compared to population
Select location,Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PerecentPopulationInfected
from PortfollioProject..['covid deaths$']
--Where location like '%states%'
Group by Location, population
order by PerecentPopulationInfected desc
--Showing countries with highest death count per population
Select location, Max(cast(Total_Deaths as int)) as totaldeathcount
from PortfollioProject..['covid deaths$']
Where continent is not null
--Where location like '%states%'
Group by Location 
order by totaldeathcount desc

--Lets breakdown by continent

Select continent, Max(cast(Total_Deaths as int)) as totaldeathcount
from PortfollioProject..['covid deaths$']
Where continent is not null
Group by continent 
order by totaldeathcount desc

--Showing contintent with highest death count per population
Select continent, Max(cast(Total_Deaths as int)) as totaldeathcount
from PortfollioProject..['covid deaths$']
Where continent is not null
Group by continent 
order by totaldeathcount desc

--Global Numbers

Select Sum(new_cases)as totalcases,Sum(cast(new_deaths as int)) as totaldeaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from PortfollioProject..['covid deaths$']
Where continent is not null
--Group by date
order by 1,2

--Looking at total population vs vaccinations
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(Cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacccinated,
--(RollingPeopleVacinated/population)* 100
From PortfollioProject..['covid deaths$'] dea
Join PortfollioProject..['covid vacinations$'] vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--Use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(Cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacccinated
--(RollingPeopleVacinated/population)* 100
From PortfollioProject..['covid deaths$'] dea
Join PortfollioProject..['covid vacinations$'] vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/ Population)*100
from PopvsVac

--Temp table
Drop table if exists  #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(Convert(bigint,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacccinated
--(RollingPeopleVacinated/population)* 100
From PortfollioProject..['covid deaths$'] dea
Join PortfollioProject..['covid vacinations$'] vac
on dea.location = vac.location
and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/ Population)*100
from #PercentPopulationVaccinated

--Create view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(Convert(bigint,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacccinated
--(RollingPeopleVacinated/population)* 100
From PortfollioProject..['covid deaths$'] dea
Join PortfollioProject..['covid vacinations$'] vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated