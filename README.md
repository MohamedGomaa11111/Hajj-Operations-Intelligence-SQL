🕋 Hajj Operations Intelligence & Bottleneck Discovery

Advanced Operational Analytics & SLA Optimization Using SQL Server

📌 Project Overview

Managing crowd movement, transit logistics, and emergency services during the Hajj pilgrimage is one of the world's most intricate logistical challenges. This project provides an advanced relational SQL analysis using Microsoft SQL Server (SSMS) across thousands of operational records.

The primary goal is to isolate systemic bottlenecks across transit corridors, service stations, camp housing zones, and emergency SLA compliance—transforming relational database records into actionable operational intelligence.

🗄️ Database Architecture

The analysis connects operational records across the following entities:

Journeys & Routes: Transit schedule adherence, journey durations, and delay metrics.

Services: Timestamped request records and wait-time distributions across multiple holy sites.

Camps & Pilgrims: Housing capacity utilization and pilgrim density distribution.

Incidents: Event severity tracking, response latencies, and resolution outcomes.

🔍 Key Analytical Findings & SQL Queries

1. Transit Route Bottlenecks & Major Delay Impact

Business Objective: Identify routes generating the majority of transit disruptions.

Finding: Two routes (Muzdalifah-Mina and Mina-Arafat) account for 81.5% of all major transit delays (>15 mins) and over 16,100 cumulative delay minutes.

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


2. Day-over-Day Delay Trend Analysis (LAG Window Function)

Business Objective: Measure the day-over-day compounding effect of delays on critical routes.

Finding: The Muzdalifah-Mina corridor peaked on Day 3 with an average delay of 12.00 minutes, showing an increase of +1.47 minutes compared to Day 2.

-- Day-over-Day Delay Trend Analysis Using LAG Window Function 
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


3. Critical Service Congestion Points (DENSE_RANK)

Business Objective: Pinpoint locations with the longest waiting times per service category.

Finding: Water stations in Muzdalifah South suffered the longest wait times (10.31 mins average, up to 37 mins), followed by meal distribution in Mina North (10.08 mins).

-- Critical Service Bottlenecks
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


4. Camp Capacity & Occupancy Rate (Multi-CTE)

Business Objective: Evaluate housing load and avoid join-duplication errors across campsite zones.

Finding: Mina camps experienced the highest operational occupancy rate at 19.80%, directly feeding into transit congestion on its incoming corridors.

-- Camp Performance & Capacity Analysis
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


5. Incident Resolution Rate & Response Times by Severity

Business Objective: Assess if field teams prioritize high-severity reports effectively.

Finding: Incidents classified as Critical had the highest unresolved rate at 12.68%, with average response latencies exceeding 11 minutes.

-- Incident Resolution Rate & Operational Response by Severity
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


6. Critical Incidents Deep-Dive & SLA Compliance

Business Objective: Identify specific high-severity issue types with SLA failures.

Finding: Critical Service Complaints showed a 25.0% unresolved rate, while Critical Lost Group cases recorded a 20.0% unresolved rate.

-- Critical Incidents Deep-Dive
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


🎯 Operational Recommendations

Dynamic Transit Dispatching: Introduce staggered departure slots between Muzdalifah and Mina prior to Day 3 to prevent transit peaks.

Targeted Resource Re-allocation: Deploy mobile support teams to Muzdalifah South water distribution and Mina North meal stations to reduce wait times.

Dedicated SLA Units: Create dedicated rapid-response escorts for critical "Lost Group" events to reduce response times to under 10 minutes.

📁 Repository Structure

├── data/                              # Raw and structured project datasets
├── screenshots/                       # Output verification screenshots
├── hajj_operations_intelligence.sql   # Unified SQL script containing all 6 queries
└── README.md                          # Comprehensive project documentation


Author: Mohamed Gomaa Mohamed

Specialization: Software Engineering & Data Analytics
