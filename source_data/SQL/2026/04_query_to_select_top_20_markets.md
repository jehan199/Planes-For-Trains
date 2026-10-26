This query pivots the same consolidated 2019 BTS data and orders the sum of passengers on short haul flights between 75 and 500 miles (excluding Hawaii) by the largest sum to the smallest. 

It also pulls in the same geographic data from the `BTS_US_Census_Place_City_Market_Translation_Table`. The output of this query is labelled as `Cities_with_most_short_flights_geo_data.csv` and this is the basis for one of the data visualizations in R.

```sql
SELECT  
  b.Origin_City_Market,b.US_Census_Bureau_USPS as US_Census_Bureau_State ,a.Sum_of_Passengers,b.US_Census_Bureau_LAT,b.US_Census_Bureau_LON
FROM 
  (WITH temp_table AS
    (SELECT 
      Origin_City_Market, Passengers, Distance, OriginState,Dest_City_Market, OriginCityMarketID, DestCityMarketID
    FROM `rail-as-alt-travel-362219.us_air_passenger.BTS_Destination_Survey_DB1B_Coupon_unioned`
    WHERE  Distance BETWEEN 75 and 500 and OriginState != 'HI')
      SELECT
        OriginCityMarketID,Sum(Passengers) as Sum_of_Passengers
      FROM temp_table
      GROUP BY OriginCityMarketID) as a
LEFT JOIN `rail-as-alt-travel-362219.us_air_passenger.BTS_US_Census_Place_City_Market_Translation_Table` as b
ON a.OriginCityMarketID = b.OriginCityMarketID
Order BY Sum_of_Passengers DESC
LIMIT 20

```
