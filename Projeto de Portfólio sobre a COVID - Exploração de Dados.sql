--Selects para confirmar que importação ocorreu bem.

select * from VacinacaoCovidBrazil

Select * From MortesCovidBrazil


-- Seleção de dados que serão usados

Select Location, date, total_cases, new_cases, total_deaths, population
From MortesCovidBrazil
Where continent is not null 
order by 2

--Mostra a probabilidade de morrer com covid se infectado em diferentes datas.
Select Location, date, total_cases,total_deaths, 
ROUND((cast(total_deaths as float(18,2))/cast(total_cases as float(18,2)))*100.00, 2) as PercentualMorte
From MortesCovidBrazil
Where total_deaths is not null and total_cases is not null
order by 5 desc

--Mostra qual a porcentagem da população infectada com Covid
Select Location, date, Population, total_cases,  
ROUND((cast(total_cases as float(18,2))/cast(population as float(18,2)))*100.00, 2) as PercentualPopulacaoInfectada
From MortesCovidBrazil
Where population is not null and total_cases is not null
order by 5 desc

--Maior Taxa de Infecção em Comparação com a População (Brasil)
Select Location, Population, MAX(cast(total_cases as float(18,2))) as MaiorNúmeroDeInfecções,  
Max((cast(total_cases as float(18,2))/cast(population as float(18,2))))*100 as PercentualPopulacaoInfectada
From  MortesCovidBrazil
Group by Location, Population
order by 4 desc

--Total de Mortes
Select Location, MAX(cast(Total_deaths as int)) as TotalMortes
From MortesCovidBrazil
Group by Location
order by 2 desc


-- Mostra a Porcentagem da População que Recebeu Pelo Menos uma Vacina contra a Covid
Select m.continent, m.location, convert(datetime,m.date, 103), m.population, v.new_vaccinations
, SUM(cast(v.new_vaccinations as int)) OVER 
(Partition by m.Location Order by m.location,
 convert(datetime,m.date, 103) ) as TotalPessoasVacinadas
From MortesCovidBrazil m
INNER Join VacinacaoCovidBrazil v
	On m.location = v.location and
	m.date=v.date 
where v.new_vaccinations is not null 
order by 6


With PopvsVac ( Date, Population, New_Vaccinations,
               PopulacaoVacinada)
as
(
Select mor.date, mor.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by mor.Location Order by mor.location, mor.Date) as PopulacaoVacinada
From MortesCovidBrazil mor
Join VacinacaoCovidBrazil vac
	On mor.location = vac.location
	and mor.date = vac.date
where mor.continent is not null 
)
Select *, (PopulacaoVacinada/Population)*100
From PopvsVac


DROP Table if exists #PercentualPopulacaoVacinada
Create Table #PercentualPopulacaoVacinada
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PopulacaoVacinada numeric
)

Insert into #PercentualPopulacaoVacinada
Select mor.continent, mor.location, mor.date, mor.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by mor.Location Order by mor.location, mor.Date) as PopulacaoVacinada
From MortesCovidBrazil mor
Join VacinacaoCovidBrazil vac
	On mor.location = vac.location
	and mor.date = vac.date
Select *, (PopulacaoVacinada/Population)*100
From #PercentualPopulacaoVacinada



Create View PercentualPopulacaoVacinada as
Select mor.continent, mor.location, mor.date, mor.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by mor.Location Order by mor.location, mor.Date) as PopulacaoVacinada
From MortesCovidBrazil mor
Join VacinacaoCovidBrazil vac
	On mor.location = vac.location
	and mor.date = vac.date
    
select * from PercentualPopulacaoVacinada 






