--- Incident Resolution Rate & Operational Response by Severity
SELECT 
    severity,
    COUNT(*) AS total_incidents,
    SUM(CASE WHEN resolved = 0 THEN 1 ELSE 0 END) AS unresolved_count,
    ROUND(CAST(SUM(CASE WHEN resolved = 0 THEN 1 ELSE 0 END) AS FLOAT) * 100 / COUNT(*), 2) AS unresolved_pct,
    AVG(response_minutes) AS avg_response_time,
    MAX(response_minutes) AS max_response_time
FROM Incidents
GROUP BY severity
ORDER BY unresolved_count DESC;  

--Route Delay Analysis & Major Transit Bottlenecks
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
------ Critical Service Bottlenecks

WITH RankedServices AS (
    SELECT 
        service_type,
        location,
        COUNT(*) AS total_requests,
        ROUND(AVG(CAST(wait_minutes AS FLOAT)), 2) AS avg_wait_minutes,
        MAX(wait_minutes) AS max_wait_minutes,
        DENSE_RANK() OVER (
            PARTITION BY service_type 
            ORDER BY AVG(CAST(wait_minutes AS FLOAT)) DESC
        ) AS service_rank
    FROM Services
    WHERE service_type IN ('Water', 'Meals', 'Medical')
    GROUP BY service_type, location
)
SELECT 
    service_type,
    location,
    total_requests,
    avg_wait_minutes,
    max_wait_minutes,
    service_rank
FROM RankedServices
WHERE service_rank <= 2
ORDER BY service_type, avg_wait_minutes DESC;

------Day-over-Day Delay Trend Analysis Using LAG Window Function 
WITH DailyRoutePerformance AS (
    SELECT 
        j.day,
        r.route_name,
        ROUND(AVG(CAST(j.delay_minutes AS FLOAT)), 2) AS avg_delay_minutes
    FROM Journeys j
    INNER JOIN Routes r ON j.route_id = r.route_id
    WHERE r.route_name IN ('Muzdalifah-Mina', 'Mina-Arafat')
    GROUP BY j.day, r.route_name
) 
SELECT 
    day,
    route_name,
    avg_delay_minutes,
    LAG(avg_delay_minutes) OVER (
        PARTITION BY route_name 
        ORDER BY day
    ) AS prev_day_avg_delay,
    ROUND(
        avg_delay_minutes - LAG(avg_delay_minutes) OVER (
            PARTITION BY route_name 
            ORDER BY day
        ), 2
    ) AS delay_change_from_yesterday
FROM DailyRoutePerformance
ORDER BY route_name, day;
---- 
--  (Camp Performance)
WITH CampCapacity AS (
    SELECT 
        zone,
        COUNT(camp_id) AS total_camps,
        SUM(capacity) AS total_capacity
    FROM Camps
    GROUP BY zone
),
PilgrimCounts AS (
    SELECT 
        c.zone,
        COUNT(p.pilgrim_id) AS actual_pilgrims
    FROM Camps c
    INNER JOIN Pilgrims p ON c.camp_id = p.camp_id
    GROUP BY c.zone
)
SELECT 
    cc.zone,
    cc.total_camps,
    cc.total_capacity,
    pc.actual_pilgrims,
    ROUND(
        (CAST(pc.actual_pilgrims AS FLOAT) / cc.total_capacity) * 100, 
        2
    ) AS occupancy_rate_pct
FROM CampCapacity cc
LEFT JOIN PilgrimCounts pc ON cc.zone = pc.zone
ORDER BY occupancy_rate_pct DESC; 


---Critical Incidents

SELECT TOP 5
    incident_type,
    severity,
    COUNT(incident_id) AS total_incidents,
    ROUND(AVG(CAST(response_minutes AS FLOAT)), 2) AS avg_response_minutes,
    SUM(CASE WHEN resolved = 0 THEN 1 ELSE 0 END) AS unresolved_count,
    ROUND(
        SUM(CASE WHEN resolved = 0 THEN 1.0 ELSE 0.0 END) / COUNT(incident_id) * 100, 
        2
    ) AS unresolved_pct
FROM Incidents
WHERE severity IN ('Critical', 'High')
GROUP BY incident_type, severity
ORDER BY unresolved_pct DESC, avg_response_minutes DESC;
```[cite: 38]


