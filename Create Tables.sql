-- ============================================================
-- Project:  Telecom VAS Revenue Analytics
-- File:     01_create_tables.sql
-- Purpose:  DDL scripts to create all four database tables
-- ============================================================

CREATE DATABASE IF NOT EXISTS telecom_data;
USE telecom_data;

-- Table 1: subscribers
CREATE TABLE subscribers (
    subscriber_id     VARCHAR(10)    PRIMARY KEY,
    full_name         VARCHAR(100)   NOT NULL,
    phone_number      VARCHAR(15)    NOT NULL UNIQUE,
    region            VARCHAR(50)    NOT NULL,
    state             VARCHAR(50)    NOT NULL,
    subscriber_type   VARCHAR(20)    NOT NULL,
    account_status    VARCHAR(20)    NOT NULL,
    registration_date DATE           NOT NULL,
    arpu_band         VARCHAR(20)    NOT NULL
);

-- Table 2: vas_services
CREATE TABLE vas_services (
    service_id        VARCHAR(10)    PRIMARY KEY,
    service_name      VARCHAR(100)   NOT NULL,
    service_category  VARCHAR(50)    NOT NULL,
    subscription_type VARCHAR(20)    NOT NULL,
    price             DECIMAL(10,2)  NOT NULL,
    is_active         TINYINT(1)     NOT NULL DEFAULT 1
);

-- Table 3: subscriptions
CREATE TABLE subscriptions (
    subscription_id   VARCHAR(15)    PRIMARY KEY,
    subscriber_id     VARCHAR(10)    NOT NULL,
    service_id        VARCHAR(10)    NOT NULL,
    subscription_date DATE           NOT NULL,
    expiry_date       DATE           NOT NULL,
    status            VARCHAR(20)    NOT NULL,
    channel           VARCHAR(20)    NOT NULL,
    renewal_count     INT            DEFAULT 0,
    FOREIGN KEY (subscriber_id) REFERENCES subscribers(subscriber_id),
    FOREIGN KEY (service_id)    REFERENCES vas_services(service_id)
);

-- Table 4: revenue_transactions
CREATE TABLE revenue_transactions (
    transaction_id     VARCHAR(15)    PRIMARY KEY,
    subscription_id    VARCHAR(15)    NOT NULL,
    subscriber_id      VARCHAR(10)    NOT NULL,
    service_id         VARCHAR(10)    NOT NULL,
    transaction_date   DATE           NOT NULL,
    transaction_month  VARCHAR(7)     NOT NULL,
    amount             DECIMAL(10,2)  NOT NULL,
    transaction_status VARCHAR(20)    NOT NULL,
    failure_reason     VARCHAR(100),
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(subscription_id),
    FOREIGN KEY (subscriber_id)   REFERENCES subscribers(subscriber_id),
    FOREIGN KEY (service_id)      REFERENCES vas_services(service_id)
);