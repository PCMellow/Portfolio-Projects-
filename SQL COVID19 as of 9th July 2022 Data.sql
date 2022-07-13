CREATE DATABASE COVID19

SELECT * 
FROM COVID19..Covid_Deaths
ORDER BY 2,1

--CLEANING
DELETE COVID19..Covid_Deaths
WHERE continent is null

SELECT*
FROM COVID19..Covid_Vaccinations

DELETE COVID19..Covid_Vaccinations
WHERE continent is null
--

SELECT location'Location',population 'Population',date'Date',total_cases'Total Cases'
,(total_cases/population)*100 'AFFECTED POPULATION TILL DATE PERCENTILE'
FROM COVID19..Covid_Deaths
ORDER BY [AFFECTED POPULATION TILL DATE PERCENTILE] desc


SELECT location 'Location', MAX(total_cases) 'HIGHEST NUMBER OF CASES'
FROM COVID19..Covid_Deaths
GROUP BY location
ORDER BY [HIGHEST NUMBER OF CASES] desc


SELECT location 'Location', MAX(CAST(total_deaths as int)) 'HIGHEST NUMBER OF DEATHS'
FROM COVID19..Covid_Deaths
--WHERE location ='Latvia'
GROUP BY location
ORDER BY [HIGHEST NUMBER OF DEATHS] desc 


SELECT location 'Location', date 'Date', total_cases 'Total Cases',total_deaths 'Total Deaths', (CAST(total_deaths as int)/total_cases)*100 'DEATH PERCENTILE'
FROM COVID19..Covid_Deaths
WHERE total_deaths >=1
GROUP BY location, date,total_cases,total_deaths
ORDER BY location,date asc


--TO FIND THE DEATH PERCENTILE OF A PARTICULAR LOCATION TILL DATE 
SELECT location 'Location', date 'Date',total_cases ,new_cases 'New Cases',total_deaths 'Total Deaths' 
,((CAST(total_deaths as int)/total_cases)*100) 'DEATH PERCENTILE'
FROM COVID19..Covid_Deaths
WHERE location = 'Latvia'
GROUP BY location, date,new_cases, total_deaths, total_cases
HAVING new_cases >= 1
ORDER BY 2



SELECT continent 'Continent', MAX(CAST(total_deaths as int)) 'HIGHEST NUMBER OF DEATHS BY CONTINENT'
FROM COVID19..Covid_Deaths
GROUP BY continent
ORDER BY [HIGHEST NUMBER OF DEATHS BY CONTINENT] desc 


SELECT location 'Location',date 'Date',population 'Population', total_cases 'Total Cases'
,(total_cases/population)*100 'Population Affected by Covid-19 Till Date'
FROM COVID19..Covid_Deaths
--WHERE location In ('Latvia','France')
ORDER BY [Population Affected by Covid-19 Till Date] desc


--COUNTRIES HAVING HIGHEST INFECTED POPULATION TILL DATE

SELECT location 'Location',population 'Population',MAX(total_cases) 'Highest Infection Count',(MAX(total_cases/population))*100 'INFECTED POPULATION PERCENTAGE TILL DATE'  
FROM COVID19..Covid_Deaths
GROUP BY location,population
ORDER BY [INFECTED POPULATION PERCENTAGE TILL DATE] desc

--SHOWING COUNTRIES WITH HIGHEST DEATHS PERCENTAGE W.R.T the POPULATION

SELECT location 'Location',population 'Population', MAX(CONVERT(int,total_deaths)) 'Total Deaths'
FROM COVID19..Covid_Deaths
GROUP BY location,population
ORDER BY [Total Deaths] desc 


--GLOBAL NUMBERS 
SELECT SUM(new_cases) 'Global Total Cases',SUM(CONVERT(int,new_deaths)) 'Global Total Deaths'
,SUM(CONVERT(int,new_deaths))/SUM(new_cases)*100 'GLOBAL DEATH PERCENTAGE'
FROM COVID19..Covid_Deaths
ORDER BY [Global Total Deaths] desc

--JOIN
SELECT *
FROM COVID19..Covid_Deaths cd
JOIN COVID19..Covid_Vaccinations cv
ON cd.location=cv.location AND cd.date=cv.date
--

--PEOPLE VACCINATED W.R.T Location

SELECT cv.location 'Location',cv.date'DATE', cv.population 'POPULATION',cv.new_vaccinations ' NEW VACCINATIONS'
,SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (PARTITION BY cv.location ORDER BY cv.location,cv.date) 'TOTAL VACCINATIONS'

FROM COVID19..Covid_Deaths cd
JOIN COVID19..Covid_Vaccinations cv
ON cd.location=cv.location AND cd.date=cv.date
--WHERE cv.location IN ('Latvia','France')
ORDER BY 1



--PERCENTAGE OF PEOPLE VACCINATED W.R.T Location BY THE USE OF C.T.E


WITH PopVsVacc (location,date,population,[NEW VACCINATIONS],[TOTAL VACCINATIONS])
AS
(
SELECT cv.location 'Location',cv.date'DATE', cv.population 'POPULATION',cv.new_vaccinations ' NEW VACCINATIONS'
,SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (PARTITION BY cv.location ORDER BY cv.location,cv.date) 'TOTAL VACCINATIONS'

FROM COVID19..Covid_Deaths cd
JOIN COVID19..Covid_Vaccinations cv
ON cd.location=cv.location AND cd.date=cv.date
--WHERE cv.location IN ('Latvia','France')
--ORDER BY 1
)
SELECT *, ([TOTAL VACCINATIONS]/population)*100 'PERCENTAGE OF PEOPLE VACCINATED'
FROM PopVsVacc
ORDER BY 1
--

--BY THE USE OF TEMP TABLE INSTEAD

DROP TABLE IF EXISTS #Percentageofpeoplevaccinated 
CREATE TABLE #Percentageofpeoplevaccinated
(
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
total_vaccinations numeric
)
INSERT INTO #Percentageofpeoplevaccinated
SELECT cv.location 'Location',cv.date'DATE', cv.population 'POPULATION',cv.new_vaccinations ' NEW VACCINATIONS'
,SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (PARTITION BY cv.location ORDER BY cv.location,cv.date) 'TOTAL VACCINATIONS'

FROM COVID19..Covid_Deaths cd
JOIN COVID19..Covid_Vaccinations cv
ON cd.location=cv.location AND cd.date=cv.date
--WHERE cv.location IN ('Latvia','France')
--ORDER BY 1
SELECT *,(total_vaccinations/population)*100 'PERCENTAGE OF PEOPLE VACCINATED'
FROM #Percentageofpeoplevaccinated
--WHERE location In ('France','Latvia')
ORDER BY 1


--CREATING VIEW for VISUALIZATIONS

CREATE VIEW Percentageofpeoplevaccinated
as SELECT cv.location 'Location',cv.date'DATE', cv.population 'POPULATION',cv.new_vaccinations ' NEW VACCINATIONS'
,SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (PARTITION BY cv.location ORDER BY cv.location,cv.date) 'TOTAL VACCINATIONS'

FROM COVID19..Covid_Deaths cd
JOIN COVID19..Covid_Vaccinations cv
ON cd.location=cv.location AND cd.date=cv.date


--
CREATE VIEW Globaldeathpercentage
as SELECT SUM(new_cases) 'Global Total Cases',SUM(CONVERT(int,new_deaths)) 'Global Total Deaths'
,SUM(CONVERT(int,new_deaths))/SUM(new_cases)*100 'GLOBAL DEATH PERCENTAGE'
FROM COVID19..Covid_Deaths
--ORDER BY [Global Total Deaths] desc


--
CREATE VIEW Infectedpopulationpercentagetilldate
as SELECT location 'Location',population 'Population',MAX(total_cases) 'Highest Infection Count'
,(MAX(total_cases/population))*100 'INFECTED POPULATION PERCENTAGE TILL DATE'  

FROM COVID19..Covid_Deaths
GROUP BY location,population
--ORDER BY [INFECTED POPULATION PERCENTAGE TILL DATE] desc



--
CREATE VIEW Affectedpopulationtilldatepercentile
as SELECT location'Location',population 'Population',date'Date',total_cases'Total Cases'
,(total_cases/population)*100 'AFFECTED POPULATION TILL DATE PERCENTILE'
FROM COVID19..Covid_Deaths
--ORDER BY [AFFECTED POPULATION TILL DATE PERCENTILE] desc




--
CREATE VIEW Highestnumberofcases
as SELECT location 'Location', MAX(total_cases) 'HIGHEST NUMBER OF CASES'
FROM COVID19..Covid_Deaths
GROUP BY location
--ORDER BY [HIGHEST NUMBER OF CASES] desc


CREATE VIEW Highestnumberofdeaths
as SELECT location 'Location', MAX(CAST(total_deaths as int)) 'HIGHEST NUMBER OF DEATHS'
FROM COVID19..Covid_Deaths
--WHERE location ='Latvia'
GROUP BY location
--ORDER BY [HIGHEST NUMBER OF DEATHS] desc 



--
CREATE VIEW Deathpercentiletilldate
as SELECT location 'Location', date 'Date',total_cases ,new_cases 'New Cases',total_deaths 'Total Deaths' 
,((CAST(total_deaths as int)/total_cases)*100) 'DEATH PERCENTILE'
FROM COVID19..Covid_Deaths
WHERE location = 'Latvia'
GROUP BY location, date,new_cases, total_deaths, total_cases
HAVING new_cases >= 1
--ORDER BY 2


--
CREATE VIEW Totaldeaths
as SELECT location 'Location',population 'Population', MAX(CONVERT(int,total_deaths)) 'Total Deaths'
FROM COVID19..Covid_Deaths
GROUP BY location,population
--ORDER BY [Total Deaths] desc 


--
CREATE VIEW Totalpeoplevaccinated
as SELECT cv.location 'Location',cv.date'DATE', cv.population 'POPULATION',cv.new_vaccinations ' NEW VACCINATIONS'
,SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (PARTITION BY cv.location ORDER BY cv.location,cv.date) 'TOTAL VACCINATIONS'

FROM COVID19..Covid_Deaths cd
JOIN COVID19..Covid_Vaccinations cv
ON cd.location=cv.location AND cd.date=cv.date
--WHERE cv.location IN ('Latvia','France')
--ORDER BY 1