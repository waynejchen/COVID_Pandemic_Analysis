select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as death_rate
from covid.coviddeaths ccd
where location like '%states%'
order by 1, 2;

select location, population, max(total_cases) as peak_infection, max(total_cases/population)*100 as infection_rate
from covid.coviddeaths ccd
#where location like '%states%'
group by location, population
order by 4 desc
limit 10;

select location, max(total_deaths) as death_count
from covid.coviddeaths ccd
where continent is null
group by location
order by 2 desc
limit 10;

select continent, max(total_deaths) as death_count
from covid.coviddeaths ccd
where continent is not null
group by continent
order by 2 desc;

with pop_vs_vac as
(
select ccd.continent, ccd.location, ccd.date, ccd.population, ccv.new_vaccinations, 
       sum(new_vaccinations) over (partition by ccd.location order by ccd.date) as rolling_vac 
from covid.coviddeaths ccd
join covid.CovidVaccinations ccv
using (date, location)
where ccd.continent is not null
order by 2,3
)

select *, (rolling_vac / population)*100 as vac_rate
from pop_vs_vac;

drop table if exists vac_condition;
create table vac_condition
(
  continent varchar(50),
  location varchar(100),
  date datetime,
  population int,
  new_vaccinations int,
  rolling_vac int
);

insert into vac_condition
select ccd.continent, ccd.location, ccd.date, ccd.population, ccv.new_vaccinations, 
       sum(new_vaccinations) over (partition by ccd.location order by ccd.date) as rolling_vac 
from covid.coviddeaths ccd
join covid.CovidVaccinations ccv
using (date, location)
where ccd.continent is not null
order by 2,3;

select *, (rolling_vac / population)*100 as vac_rate
from vac_condition;

drop view if exists vac_condition1;
create view vac_condition1 as
select ccd.continent, ccd.location, ccd.date, ccd.population, ccv.new_vaccinations, 
       sum(new_vaccinations) over (partition by ccd.location order by ccd.date) as rolling_vac 
from covid.coviddeaths ccd
join covid.CovidVaccinations ccv
using (date, location)
where ccd.continent is not null
order by 2,3;

select * from vac_condition1
  





