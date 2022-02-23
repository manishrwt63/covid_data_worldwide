select * from covid_deaths
where continent <> "";

select location, date, total_cases, new_cases, total_deaths, population
from covid_deaths
where continent <> ""
order by 1,2;



-- total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covid_deaths
where location = "india"
order by 2;

-- total cases vs population of whole countries

select location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentage
from covid_deaths
order by 1,2;

-- countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfected, population, (max(total_cases/population))*100 as InfectedPopulationPercentage
from covid_deaths
group by location, population
order by 5 desc;

-- countries with highest death per count

select location, max(total_deaths) as total_deaths
from covid_deaths
where continent <>""
group by location
order by 2 desc;



-- continent with highest death per count

select continent, max(total_deaths) as total_deaths
from covid_deaths
where continent <>""
group by continent
order by 2 desc;

-- global numbers by date

select date, sum(new_cases) as new_cases_per_day, sum(new_deaths) as NewDeathsPerDay, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentagePerDay
from covid_deaths
where continent <> ""
group by date
order by 1 desc;




-- total population vs vaccinations
with PopvsVac 
	(
	continent, location, date, population, new_vaccinations, PeopleVaccinatedTillDate
	)  
as 
(  
	select t1.continent, t1.location, t1.date, t1.population, t2.new_vaccinations,   
		sum(t2.new_vaccinations) over(partition by t1.location order by t1.location,t1.date) as PeopleVaccinatedTillDate 
	from covid_deaths t1  
	join cov_vac t2   
		on t1.location = t2.location   and t1.date = t2.date  
	where t1.continent <>"" 
)
select *, (PeopleVaccinatedTillDate/population)*100 as percent from PopvsVac;


-- Temp table

drop table if exists population_vacc;
create temporary table population_vacc
(
continent varchar(255),
location varchar(55),
date date,
population double,
new_vaccinations text,
PeopleVaccinatedTillDate double
);
insert into population_vacc
select t1.continent, t1.location, t1.date, t1.population, t2.new_vaccinations,
	sum(t2.new_vaccinations) over(partition by t1.location order by t1.location,t1.date) as PeopleVaccinatedTillDate
from covid_deaths t1
join cov_vac t2
	on t1.location = t2.location
	and t1.date = t2.date;
-- where t1.continent <>""

select *, (PeopleVaccinatedTillDate/Population)*100 from population_vacc;



-- creating view to score data for later visualizations

create view population_vacc as 
select t1.continent, t1.location, t1.date, t1.population, t2.new_vaccinations,
	sum(t2.new_vaccinations) over(partition by t1.location order by t1.location,t1.date) as PeopleVaccinatedTillDate
from covid_deaths t1
join cov_vac t2
	on t1.location = t2.location
	and t1.date = t2.date
where t1.continent <>""