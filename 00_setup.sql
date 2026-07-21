-- 00_setup.sql
-- Prerequisites: ACCOUNTADMIN or equivalent to create objects and grant roles.
-- Run this script once before executing the notebooks.

USE ROLE ACCOUNTADMIN;

-- =============================================================================
-- Role
-- =============================================================================
CREATE ROLE IF NOT EXISTS SPLINK_ROLE;
GRANT ROLE SPLINK_ROLE TO ROLE SYSADMIN;

-- =============================================================================
-- Warehouse
-- =============================================================================
CREATE WAREHOUSE IF NOT EXISTS SPLINK_WH
  WAREHOUSE_SIZE = 'MEDIUM'
  AUTO_SUSPEND = 300
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE;

GRANT USAGE ON WAREHOUSE SPLINK_WH TO ROLE SPLINK_ROLE;
GRANT OPERATE ON WAREHOUSE SPLINK_WH TO ROLE SPLINK_ROLE;

-- =============================================================================
-- Database and Schema
-- =============================================================================
CREATE DATABASE IF NOT EXISTS SPLINK_DEMO;
GRANT USAGE ON DATABASE SPLINK_DEMO TO ROLE SPLINK_ROLE;

CREATE SCHEMA IF NOT EXISTS SPLINK_DEMO.PUBLIC;
GRANT USAGE ON SCHEMA SPLINK_DEMO.PUBLIC TO ROLE SPLINK_ROLE;
GRANT CREATE TABLE ON SCHEMA SPLINK_DEMO.PUBLIC TO ROLE SPLINK_ROLE;
GRANT CREATE STAGE ON SCHEMA SPLINK_DEMO.PUBLIC TO ROLE SPLINK_ROLE;
GRANT CREATE FUNCTION ON SCHEMA SPLINK_DEMO.PUBLIC TO ROLE SPLINK_ROLE;

-- =============================================================================
-- Compute Pool (for Snowpark Connect / SCOS)
-- =============================================================================
CREATE COMPUTE POOL IF NOT EXISTS SPLINK_COMPUTE_POOL
  MIN_NODES = 1
  MAX_NODES = 1
  INSTANCE_FAMILY = CPU_X64_S
  AUTO_SUSPEND_SECS = 300
  AUTO_RESUME = TRUE;

GRANT USAGE ON COMPUTE POOL SPLINK_COMPUTE_POOL TO ROLE SPLINK_ROLE;
GRANT MONITOR ON COMPUTE POOL SPLINK_COMPUTE_POOL TO ROLE SPLINK_ROLE;

-- =============================================================================
-- External Access Integration (GitHub — Splink downloads data from GitHub)
-- Note: This is only required because splink_datasets.historical_50k fetches
-- sample data from raw.githubusercontent.com at runtime. If you are running
-- Splink against data already in Snowflake, this EAI is not needed.
-- =============================================================================
CREATE NETWORK RULE IF NOT EXISTS SPLINK_DEMO.PUBLIC.GITHUB_NETWORK_RULE
  TYPE = HOST_PORT
  MODE = EGRESS
  VALUE_LIST = ('raw.githubusercontent.com', 'github.com');

CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION SPLINK_GITHUB_EAI
  ALLOWED_NETWORK_RULES = (SPLINK_DEMO.PUBLIC.GITHUB_NETWORK_RULE)
  ENABLED = TRUE;

GRANT USAGE ON INTEGRATION SPLINK_GITHUB_EAI TO ROLE SPLINK_ROLE;
