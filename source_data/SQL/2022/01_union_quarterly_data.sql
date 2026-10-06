### This is the query I originally used to create a consolidated table containing the U.S. DoT data for 2019

CREATE TABLE us_air_passenger.unioned_and_filtered_table3 AS
(WITH temp_table AS
(SELECT
  Origin, OriginStateName, Dest, DestStateName, Passengers, Distance, OriginState, DestState, OriginCityMarketID, DestCityMarketID
FROM `cycling-case-study-362219.us_air_passenger.2019_Q1`
UNION ALL
SELECT
  Origin, OriginStateName, Dest, DestStateName, Passengers, Distance, OriginState, DestState, OriginCityMarketID, DestCityMarketID
FROM `cycling-case-study-362219.us_air_passenger.2019_Q2`
UNION ALL
SELECT 
  Origin, OriginStateName, Dest, DestStateName, Passengers, Distance, OriginState , DestState, OriginCityMarketID, DestCityMarketID
FROM `cycling-case-study-362219.us_air_passenger.2019_Q3`
UNION ALL
SELECT
  Origin, OriginStateName, Dest, DestStateName, Passengers, Distance, OriginState, DestState, OriginCityMarketID, DestCityMarketID
FROM `cycling-case-study-362219.us_air_passenger.2019_Q4`)
SELECT 
a1.string_field_1 AS origin_name,OriginStateName, OriginState,
a2.string_field_1 AS destination_name, DestStateName, DestState,
Origin AS Origin_Airport_Code, Dest AS Dest_Airport_Code, 
OriginCityMarketID, DestCityMarketID, 
Passengers, Distance
FROM temp_table AS full_data
LEFT JOIN `cycling-case-study-362219.us_air_passenger.Airport_Codes` AS a1 ON full_data.Origin = a1.string_field_0
LEFT JOIN `cycling-case-study-362219.us_air_passenger.Airport_Codes` AS a2 ON full_data.Dest = a2.string_field_0)
