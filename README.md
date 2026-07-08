# Telecom-VAS-Revenue-Analytics
# SQL + Power BI Portfolio Project 

Project Overview

This project delivers an end-to-end revenue analytics solution for a telecom Value Added Services (VAS) platform operating across six Nigerian regions. Starting from a relational MySQL database designed and populated from scratch, the project covers full database architecture, data insertion, KPI query development, SQL view creation, and an interactive Power BI dashboard built directly on top of the SQL views.
The analysis spans a 12-month observation window (January 2024 – December 2024) and examines VAS revenue performance across subscription services, subscriber segments, acquisition channels, and geographic regions.Tools & Technologies

# TOOLS AND TECHNOLOGIES

MySQL 8.0 - database design, DDL scripts, data insertion, KPI queries, view creation

MySQL Workbench - query execution and schema management

Power BI Desktop - data connection via MySQL connector, DAX measures, dashboard design

Power Query (M) - data type enforcement and column validation on loaded views

# SQL DELIVERABLES

DDL Scripts

Full CREATE TABLE scripts with primary keys, foreign keys, and appropriate data types for all four tables.

Data Insertion Scripts

Complete INSERT statements for all 285 records across four tables, inserted in foreign key dependency order to maintain referential integrity.

# KEY FINDINGS
-Revenue Performance: Total successful revenue across the 12-month observation window is ₦13,620. The Lifestyle category led by LifeStyle Plus (Monthly, ₦300) and TrendZone Weekly (₦120) generates the highest revenue share, reflecting strong subscriber appetite for lifestyle content. Music services follow closely, driven by RingTone Premium at ₦250 per month.

-ARPU: Overall ARPU across all 30 subscribers stands at ₦454. Postpaid subscribers significantly outperform Prepaid on ARPU reflecting higher tier engagement and monthly billing commitment. Premium and High ARPU band subscribers contribute disproportionately to total revenue despite representing a smaller share of the subscriber base.

-Service Penetration: Monthly subscription services (LifeStyle Plus, RingTone Premium) show the highest penetration and renewal counts — confirming that monthly billing cycles drive stronger subscriber stickiness than daily or weekly services. Daily services show high transaction volume but lower revenue per subscriber due to low unit pricing.

-Transaction Failure Rate: Three failure reasons are present in the dataset ( Insufficient Balance, Network Error, and Subscriber Inactive). Insufficient Balance is the most frequent, concentrated among Prepaid subscribers on daily services. Suspended and Closed account subscribers appear in transaction records,a data quality signal flagged during profiling and documented in the issues log.

-Regional Performance: South West (Lagos, Ogun, Oyo) dominates transaction volume and revenue given its concentration of Postpaid and High ARPU subscribers. North West and North East regions show lower revenue contribution, driven by higher Prepaid penetration and lower average spend per subscriber.

-Subscription Channels: App is the dominant subscription channel, followed by USSD and SMS. App subscribers also show higher renewal counts suggesting the in-app experience drives better retention than USSD or SMS subscription flows.


