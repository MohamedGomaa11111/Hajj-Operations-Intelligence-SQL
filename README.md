# 🕋 Hajj Operations Intelligence & Bottleneck Discovery
### Advanced Operational Analytics & SLA Optimization Using SQL Server

![SQL Server](https://img.shields.io/badge/SQL%20Server-2022%2B-CC292B?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)
![SSMS](https://img.shields.io/badge/SSMS-v17%2B-0078D4?style=for-the-badge&logo=visualstudio&logoColor=white)
![Analytics](https://img.shields.io/badge/Operations-Bottleneck%20Analysis-success?style=for-the-badge)

---

## 📌 Project Overview
Managing crowd movement, transit logistics, and emergency services during the Hajj pilgrimage is one of the world's most intricate logistical challenges. This project provides an advanced relational SQL analysis using **Microsoft SQL Server (SSMS)** across thousands of operational records.

The primary goal is to isolate systemic bottlenecks across transit corridors, service stations, camp housing zones, and emergency SLA compliance—transforming relational database records into actionable operational intelligence.

---

## 🗄️ Database Architecture
The analysis connects operational records across the following entities:
* **Journeys & Routes:** Transit schedule adherence, journey durations, and delay metrics.
* **Services:** Timestamped request records and wait-time distributions across multiple holy sites.
* **Camps & Pilgrims:** Housing capacity utilization and pilgrim density distribution.
* **Incidents:** Event severity tracking, response latencies, and resolution outcomes.

---

## 🔍 Key Analytical Findings & SQL Queries

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