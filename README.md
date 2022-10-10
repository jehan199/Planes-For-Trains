# Planes-For-Trains
This project seeks to use 2019 demand for short haul flights (between 75 and 550 miles) to determine which cities in the United States are best positioned to become major high speed rail hubs.

# Data Collection and Setup

The dataset I am using for this project comes from the US Bureau of Transportation Statistics Origin and Destination Survey : DB1BCoupon. This is a report that is released quarterly that includes every domestic flight itinerary for a given period. Since the report is issued quarterly, I decided to take the 4 quarterly reports from 2019 and consolidate them into one table for analysis. I also downloaded a list of US domestic airport codes that I then joined with the source data to provide more descriptive infomortion 

```
CREATE TABLE us_air_passenger.unioned_and_filtered_table AS
(WITH temp_table AS
(SELECT
  Origin, OriginStateName, Dest, DestStateName, Passengers, Distance, OriginState, DestState, OriginCityMarketID, DestCityMarketID
FROM `high-speed-rail-1029201.us_air_passenger.2019_Q1`
UNION ALL
SELECT
  Origin, OriginStateName, Dest, DestStateName, Passengers, Distance, OriginState, DestState, OriginCityMarketID, DestCityMarketID
FROM `high-speed-rail-1029201.us_air_passenger.2019_Q2`
UNION ALL
SELECT 
  Origin, OriginStateName, Dest, DestStateName, Passengers, Distance, OriginState , DestState, OriginCityMarketID, DestCityMarketID
FROM `high-speed-rail-1029201.us_air_passenger.2019_Q3`
UNION ALL
SELECT
  Origin, OriginStateName, Dest, DestStateName, Passengers, Distance, OriginState, DestState, OriginCityMarketID, DestCityMarketID
FROM `high-speed-rail-1029201.us_air_passenger.2019_Q4`)
SELECT 
a1.string_field_1 AS origin_name,OriginStateName, OriginState,
a2.string_field_1 AS destination_name, DestStateName, DestState,
Origin AS Origin_Airport_Code, Dest AS Dest_Airport_Code, 
OriginCityMarketID, DestCityMarketID, 
Passengers, Distance
FROM temp_table AS full_data
LEFT JOIN `high-speed-rail-1029201.us_air_passenger.Airport_Codes` AS a1 ON full_data.Origin = a1.string_field_0
LEFT JOIN `high-speed-rail-1029201.us_air_passenger.Airport_Codes` AS a2 ON full_data.Dest = a2.string_field_0)
```

# Query Data to Determine the Top 20 Metros
Next I run a query that takes the consolidated table and groups it by the Sum of Passengers for each origin city and then sorts the values in descending order with the output limited to 20 rows. This gives us a list of the metro areas that have the most passengers departing from their airports on short haul flights. A table with the latitude and longitude of these metro areas is also used to provide the spatial data that is needed for the subisquent visualization in R. 

```
SELECT  
  b.Metro_Area_Name,b.State,a.Sum_of_Passengers,b.Latitude,b.Longitude
FROM 
  (WITH temp_table AS
    (SELECT 
      origin_name,Passengers, Distance, OriginState,destination_name, OriginCityMarketID, DestCityMarketID
    FROM `cycling-case-study-362219.us_air_passenger.unioned_and_filtered_table3`
    WHERE  Distance BETWEEN 75 and 500 and OriginState != 'HI')
      SELECT
        OriginCityMarketID,Sum(Passengers) as Sum_of_Passengers
      FROM temp_table
      GROUP BY OriginCityMarketID) as a
LEFT JOIN `cycling-case-study-362219.us_air_passenger.Metro_Data_Table` as b
ON a.OriginCityMarketID = b.OriginCityMarketID
Order BY Sum_of_Passengers DESC
LIMIT 20
```
# Query Data to Setup City Specific Analysis in R.

While the last query gave us a list of the 20 cities with the most short haul domestic flights, this query is meant to determine where these flights are actually going. This will be key to determining 

```
WITH temp_table as 
  (SELECT
    OriginCityMarketID, DestCityMarketID, Sum(Passengers) as Sum_of_Passengers, AVG(Distance) AS Distance
  FROM `cycling-case-study-362219.us_air_passenger.unioned_and_filtered_table3`
  GROUP BY OriginCityMarketID, DestCityMarketID)
  
SELECT a.*,b.Metro_Area_Name_Origin_,c.Metro_Area_Name_Dest_,d.Latitude as OriginLat,d.Longitude as OriginLon,e.Latitude as DestLat, e.Longitude as DestLon, 
from temp_table as a
LEFT JOIN `cycling-case-study-362219.us_air_passenger.Metro_Area_Data` as b
ON a.OriginCityMarketID = b.OriginCityMarketID
LEFT JOIN `cycling-case-study-362219.us_air_passenger.Metro_Area_Data` as c
ON a.DestCityMarketID = c.DestCityMarketID
LEFT JOIN `cycling-case-study-362219.us_air_passenger.Metro_Area_Data` as d
ON a.OriginCityMarketID= d.OriginCityMarketID
LEFT JOIN `cycling-case-study-362219.us_air_passenger.Metro_Area_Data` as e
ON a.DestCityMarketID = e.DestCityMarketID
WHERE a.Distance BETWEEN 75 AND 550 AND Sum_of_Passengers > 15000
ORDER BY b.Metro_Area_Name_Origin_, a.Sum_of_Passengers DESC
```

