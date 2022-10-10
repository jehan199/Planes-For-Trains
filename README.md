# Planes-For-Trains
This project seeks to use demand for flights between 75 and 550 miles to determine which cities in the United States are best positioned to become major high speed rail hubs. 

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
