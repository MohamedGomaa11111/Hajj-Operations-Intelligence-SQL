-- Hajj Operations Intelligence — SYNTHETIC educational dataset
-- Not official Hajj operational data.
CREATE DATABASE HajjOperationsIntelligence;
GO
USE HajjOperationsIntelligence;
GO
CREATE TABLE Camps(camp_id VARCHAR(10) PRIMARY KEY,camp_name VARCHAR(100),zone VARCHAR(30),capacity INT);
CREATE TABLE Routes(route_id VARCHAR(10) PRIMARY KEY,route_name VARCHAR(100),from_zone VARCHAR(50),to_zone VARCHAR(50),planned_minutes INT);
CREATE TABLE Pilgrims(pilgrim_id VARCHAR(10) PRIMARY KEY,region VARCHAR(50),group_type VARCHAR(30),age_group VARCHAR(20),group_id VARCHAR(10),camp_id VARCHAR(10),satisfaction_score DECIMAL(3,1),FOREIGN KEY(camp_id) REFERENCES Camps(camp_id));
CREATE TABLE Journeys(journey_id VARCHAR(12) PRIMARY KEY,pilgrim_id VARCHAR(10),route_id VARCHAR(10),day VARCHAR(20),time_period VARCHAR(30),channel VARCHAR(30),crowd_level VARCHAR(20),planned_minutes INT,actual_minutes INT,delay_minutes INT,completed VARCHAR(5),FOREIGN KEY(pilgrim_id) REFERENCES Pilgrims(pilgrim_id),FOREIGN KEY(route_id) REFERENCES Routes(route_id));
CREATE TABLE Services(service_event_id VARCHAR(12) PRIMARY KEY,pilgrim_id VARCHAR(10),service_type VARCHAR(30),day VARCHAR(20),location VARCHAR(100),wait_minutes INT,rating DECIMAL(3,1),resolved VARCHAR(5),FOREIGN KEY(pilgrim_id) REFERENCES Pilgrims(pilgrim_id));
CREATE TABLE Incidents(incident_id VARCHAR(10) PRIMARY KEY,pilgrim_id VARCHAR(10),incident_type VARCHAR(50),severity VARCHAR(20),day VARCHAR(20),location VARCHAR(150),response_minutes INT,resolved VARCHAR(5),FOREIGN KEY(pilgrim_id) REFERENCES Pilgrims(pilgrim_id));
GO
-- Import the CSV files into SQL Server using your local folder path.
