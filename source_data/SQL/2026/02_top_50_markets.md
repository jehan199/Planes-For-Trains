This query was designed to determine the top 50 markets for short haul flights by `Passenger` volume. This was then used to determine which `CityMarketIDs` should be included in the translation table that links the BTS data with the US Census Gazetteer Place File geographic data.
```sql
Select OriginCityMarketID, Origin_City_Market, Sum(Passengers) as Sum_of_Passengers
FROM `cycling-case-study-362219.us_air_passenger.BTS_Destination_Survey_DB1B_Coupon_unioned`
WHERE Distance BETWEEN 75 AND 500 AND OriginState != 'HI'
GROUP BY OriginCityMarketID, Origin_City_Market
ORDER BY Sum_of_Passengers DESC
LIMIT 50
```
