### 1. Transit Route Bottlenecks & Major Delay Impact
* **Business Objective:** Identify routes generating the majority of transit disruptions.
* **Finding:** Two routes (`Muzdalifah-Mina` and `Mina-Arafat`) account for **81.5% of all major transit delays (>15 mins)** and over 16,100 cumulative delay minutes.

```sql
-- Route Delay Analysis & Major Transit Bottlenecks
SELECT 
    r.route_name,
    COUNT(j.journey_id) AS total_journeys,
    AVG(j.delay_minutes) AS avg_delay_minutes,
    MAX(j.delay_minutes) AS max_delay_minutes,
    SUM(CASE WHEN j.delay_minutes > 15 THEN 1 ELSE 0 END) AS major_delay_count,
    SUM(j.delay_minutes) AS total_delay_minutes
FROM Journeys j
INNER JOIN Routes r ON j.route_id = r.route_id
GROUP BY r.route_name
ORDER BY avg_delay_minutes DESC;
