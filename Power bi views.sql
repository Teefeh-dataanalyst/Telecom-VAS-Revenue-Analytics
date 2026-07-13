- POWER BI DASHBOARD
DROP VIEW IF EXISTS vw_monthly_revenue;
DROP VIEW IF EXISTS vw_regional_performance;
DROP VIEW IF EXISTS vw_service_performance;
DROP VIEW IF EXISTS vw_subscriber_profile;

CREATE VIEW vw_monthly_revenue AS
SELECT t.transaction_month,COUNT(t.transaction_id)                             AS total_transactions,
    SUM(CASE WHEN t.transaction_status = 'Success'  THEN 1 ELSE 0 END)                         AS successful_count,
    SUM(CASE WHEN t.transaction_status = 'Failed'   THEN 1 ELSE 0 END)                         AS failed_count,
    SUM(CASE WHEN t.transaction_status = 'Expired'  THEN 1 ELSE 0 END)                         AS expired_count,
    ROUND(SUM(CASE WHEN t.transaction_status = 'Success' THEN t.amount ELSE 0 END), 2)        AS total_revenue,
    COUNT(DISTINCT t.subscriber_id)                     AS active_subscribers,
    ROUND(M(CASE WHEN t.transaction_status = 'Success' THEN t.amount ELSE 0 END) / NULLIF(COUNT(DISTINCT t.subscriber_id), 0), 2)                                                AS monthly_arpu
FROM revenue_transactions t
GROUP BY t.transaction_month;

CREATE VIEW vw_regional_performance AS
SELECT s.region,s.state,COUNT(DISTINCT s.subscriber_id)                     AS total_subscribers,
    SUM(CASE WHEN s.account_status = 'Active'    THEN 1 ELSE 0 END)                         AS active_subscribers,
    SUM(CASE WHEN s.account_status = 'Churned'   THEN 1 ELSE 0 END)                         AS churned_subscribers,
    SUM(CASE WHEN s.account_status = 'Suspended' THEN 1 ELSE 0 END)                         AS suspended_subscribers,
    ROUND(SUM(CASE WHEN t.transaction_status = 'Success' THEN t.amount ELSE 0 END), 2)        AS total_revenue,
    ROUND(CASE WHEN t.transaction_status = 'Success' THEN t.amount ELSE 0 END) / NULLIF(COUNT(DISTINCT s.subscriber_id), 0), 2                                             AS arpu
FROM subscribers s
LEFT JOIN revenue_transactions t 
    ON s.subscriber_id = t.subscriber_id
GROUP BY s.region, s.state;

CREATE VIEW vw_service_performance AS
SELECT v.service_id,v.service_name,v.service_category,v.subscription_type,v.price   AS unit_price,s_active,COUNT(DISTINCT t.subscriber_id)                     AS unique_subscribers,
    ROUND(AVG(sub.renewal_count), 2)                    AS avg_renewals,
    COUNT(t.transaction_id)                             AS total_transactions,
    SUM(CASE WHEN t.transaction_status = 'Success' THEN 1 ELSE 0 END)                         AS successful_txns,
    SUM(CASE WHEN t.transaction_status = 'Failed'  THEN 1 ELSE 0 END)                         AS failed_txns,
    ROUND(SUM(CASE WHEN t.transaction_status = 'Success' THEN t.amount ELSE 0 END), 2)        AS total_revenue,
    ROUND(SUM(CASE WHEN t.transaction_status = 'Failed' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(t.transaction_id), 0), 2)                                                AS failure_rate_pct
FROM vas_services v
LEFT JOIN revenue_transactions t 
    ON v.service_id = t.service_id
LEFT JOIN (
    SELECT service_id, AVG(renewal_count) AS renewal_count
    FROM subscriptions
    GROUP BY service_id
) sub ON v.service_id = sub.service_id
GROUP BY v.service_id, v.service_name, v.service_category,
         v.subscription_type, v.price, v.is_active;
         
         
    DROP VIEW IF EXISTS vw_subscriber_profile;
DROP VIEW IF EXISTS vw_subscriber_profile;

CREATE VIEW vw_subscriber_profile AS
SELECT s.subscriber_id,s.full_name,s.region,s.state,s.subscriber_type,s.account_status,s.arpu_band,s.registration_date,

    -- Services subscribed pulled separately to avoid row multiplication
    COALESCE(sub.services_subscribed, 0)            AS services_subscribed,

    COUNT(t.transaction_id)                         AS total_transactions,
    SUM(CASE WHEN t.transaction_status = 'Success' THEN 1 ELSE 0 END)                     AS successful_txns,
    ROUND(SUM(CASE WHEN t.transaction_status = 'Success' THEN t.amount ELSE 0 END), 2)    AS total_revenue_generated,
    ROUND(AVG(CASE WHEN t.transaction_status = 'Success' THEN t.amount END), 2)           AS avg_transaction_value

FROM subscribers s

-- Subquery counts distinct services per subscriber independently
LEFT JOIN (
    SELECT subscriber_id,COUNT(DISTINCT service_id)                  AS services_subscribed
    FROM subscriptions
    GROUP BY subscriber_id) sub ON s.subscriber_id = sub.subscriber_id

-- Transactions joined separately with no interference from subscriptions
LEFT JOIN revenue_transactions t 
    ON s.subscriber_id = t.subscriber_id

GROUP BY s.subscriber_id, s.full_name, s.region, s.state,
         s.subscriber_type, s.account_status, s.arpu_band,
         s.registration_date, sub.services_subscribed;
         
         SELECT 'raw_transactions'       AS source,
    ROUND(SUM(amount), 2)       AS total_revenue
FROM revenue_transactions
WHERE transaction_status = 'Success'

UNION ALL

SELECT 'vw_monthly_revenue',
    SUM(total_revenue)
FROM vw_monthly_revenue

UNION ALL

SELECT 'vw_regional_performance',
    SUM(total_revenue)
FROM vw_regional_performance

UNION ALL

SELECT 'vw_service_performance',
    SUM(total_revenue)
FROM vw_service_performance

UNION ALL

SELECT 'vw_subscriber_profile',
    SUM(total_revenue_generated)
FROM vw_subscriber_profile;
 