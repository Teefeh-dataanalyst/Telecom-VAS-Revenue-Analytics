-- 1a. Transaction status breakdown
SELECT transaction_status, COUNT(*) AS transaction_count, ROUND(SUM(amount), 2) AS total_amount, ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage_of_total
FROM revenue_transactions
GROUP BY transaction_status;

-- 1b. Check for orphaned transactions (no matching subscriber)
SELECT t.transaction_id
FROM revenue_transactions t
LEFT JOIN subscribers s ON t.subscriber_id = s.subscriber_id
WHERE s.subscriber_id IS NULL;

-- 1c. Check for orphaned subscriptions (no matching service)
SELECT s.subscription_id
FROM subscriptions s
LEFT JOIN vas_services v ON s.service_id = v.service_id
WHERE v.service_id IS NULL;

-- 1d. Confirm active vs inactive services
SELECT is_active,  COUNT(*) AS service_count
FROM vas_services
GROUP BY is_active;


-- KPIS
-- 2a. Total revenue — successful transactions only
SELECT ROUND(SUM(amount), 2) AS total_revenue
FROM revenue_transactions
WHERE transaction_status = 'Success';

-- 2b. Monthly revenue trend
SELECT transaction_month, COUNT(*) AS total_transactions, SUM(CASE WHEN transaction_status = 'Success'  THEN 1 ELSE 0 END) AS successful, SUM(CASE WHEN transaction_status = 'Failed'   THEN 1 ELSE 0 END) AS failed,
SUM(CASE WHEN transaction_status = 'Reversed' THEN 1 ELSE 0 END) AS reversed, ROUND(SUM(CASE WHEN transaction_status = 'Success' 
THEN amount ELSE 0 END), 2)  AS revenue
FROM revenue_transactions
GROUP BY transaction_month
ORDER BY transaction_month;

-- 2c. Revenue by service
SELECT v.service_name, v.service_category, v.subscription_type, v.price AS unit_price, COUNT(t.transaction_id) AS total_transactions, SUM(CASE WHEN t.transaction_status = 'Success' 
THEN 1 ELSE 0 END) AS successful_txns,
ROUND(SUM(CASE WHEN t.transaction_status = 'Success' 
THEN t.amount ELSE 0 END), 2)    AS total_revenue, ROUND(SUM(CASE WHEN t.transaction_status = 'Success' THEN t.amount ELSE 0 END) 
* 100.0 / SUM(SUM(CASE WHEN t.transaction_status = 'Success' 
THEN t.amount ELSE 0 END)) 
OVER (), 2) AS revenue_share_pct
FROM revenue_transactions t
JOIN vas_services v ON t.service_id = v.service_id
GROUP BY v.service_id, v.service_name, v.service_category, v.subscription_type, v.price
ORDER BY total_revenue DESC;

-- 2d. Revenue by service category
SELECT v.service_category, COUNT(DISTINCT t.subscriber_id) AS unique_subscribers, COUNT(t.transaction_id) AS total_transactions,
ROUND(SUM(CASE WHEN t.transaction_status = 'Success' THEN t.amount ELSE 0 END), 2) AS total_revenue
FROM revenue_transactions t
JOIN vas_services v ON t.service_id = v.service_id
GROUP BY v.service_category
ORDER BY total_revenue DESC;

-- 2e. Revenue by subscriber type (Prepaid vs Postpaid)
SELECT s.subscriber_type, COUNT(DISTINCT t.subscriber_id) AS unique_subscribers, COUNT(t.transaction_id) AS total_transactions, ROUND(SUM(CASE WHEN t.transaction_status = 'Success' 
THEN t.amount ELSE 0 END), 2) AS total_revenue
FROM revenue_transactions t
JOIN subscribers s ON t.subscriber_id = s.subscriber_id
GROUP BY s.subscriber_type
ORDER BY total_revenue DESC;

-- 2f. Revenue by region
SELECT s.region, s.state, COUNT(DISTINCT t.subscriber_id) AS unique_subscribers, COUNT(t.transaction_id) AS total_transactions, ROUND(SUM(CASE WHEN t.transaction_status = 'Success' 
THEN t.amount ELSE 0 END), 2) AS total_revenue
FROM revenue_transactions t
JOIN subscribers s ON t.subscriber_id = s.subscriber_id
GROUP BY s.region, s.state
ORDER BY total_revenue DESC;


-- 3a. Overall ARPU
SELECT COUNT(DISTINCT t.subscriber_id) AS active_subscribers, ROUND(SUM(CASE WHEN t.transaction_status = 'Success' THEN t.amount ELSE 0 END), 2) AS total_revenue,
ROUND(SUM(CASE WHEN t.transaction_status = 'Success' THEN t.amount ELSE 0 END) / COUNT(DISTINCT t.subscriber_id), 2)  AS overall_arpu
FROM revenue_transactions t;

-- 3b. ARPU by subscriber type
SELECT s.subscriber_type, COUNT(DISTINCT t.subscriber_id) AS subscribers,
ROUND(SUM(CASE WHEN t.transaction_status = 'Success' THEN t.amount ELSE 0 END), 2) AS total_revenue,
ROUND(SUM(CASE WHEN t.transaction_status = 'Success' THEN t.amount ELSE 0 END) / COUNT(DISTINCT t.subscriber_id), 2)  AS arpu
FROM revenue_transactions t
JOIN subscribers s ON t.subscriber_id = s.subscriber_id
GROUP BY s.subscriber_type;

-- 3c. ARPU by ARPU band
SELECT s.arpu_band, COUNT(DISTINCT t.subscriber_id) AS subscribers,
    ROUND(SUM(CASE WHEN t.transaction_status = 'Success' THEN t.amount ELSE 0 END), 2) AS total_revenue,
    ROUND(SUM(CASE WHEN t.transaction_status = 'Success' THEN t.amount ELSE 0 END) / COUNT(DISTINCT t.subscriber_id), 2)  AS arpu
FROM revenue_transactions t
JOIN subscribers s ON t.subscriber_id = s.subscriber_id
GROUP BY s.arpu_band
ORDER BY arpu DESC;

-- 3d. Monthly ARPU trend
SELECT t.transaction_month, COUNT(DISTINCT t.subscriber_id) AS active_subscribers,
    ROUND(SUM(CASE WHEN t.transaction_status = 'Success' THEN t.amount ELSE 0 END), 2) AS monthly_revenue,
    ROUND(SUM(CASE WHEN t.transaction_status = 'Success' THEN t.amount ELSE 0 END) / COUNT(DISTINCT t.subscriber_id), 2)  AS monthly_arpu
FROM revenue_transactions t
GROUP BY t.transaction_month
ORDER BY t.transaction_month;




-- FAILURE RATE AND TRANSACTION RATE
-- 4a. Overall failure rate
SELECT COUNT(*) AS total_transactions, SUM(CASE WHEN transaction_status = 'Failed' THEN 1 ELSE 0 END) AS failed_count,
    SUM(CASE WHEN transaction_status = 'Reversed' THEN 1 ELSE 0 END) AS reversed_count,
    ROUND(SUM(CASE WHEN transaction_status = 'Failed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS failure_rate_pct,
    ROUND(SUM(CASE WHEN transaction_status = 'Reversed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS reversal_rate_pct
FROM revenue_transactions;

-- 4b. Failure rate by service
SELECT v.service_name, v.service_category, COUNT(t.transaction_id) AS total_transactions,
    SUM(CASE WHEN t.transaction_status = 'Failed' THEN 1 ELSE 0 END) AS failed_count,
    ROUND(SUM(CASE WHEN t.transaction_status = 'Failed' THEN 1 ELSE 0 END) * 100.0 / COUNT(t.transaction_id), 2)     AS failure_rate_pct
FROM revenue_transactions t
JOIN vas_services v ON t.service_id = v.service_id
GROUP BY v.service_id, v.service_name, v.service_category
ORDER BY failure_rate_pct DESC;

-- 4c. Failure breakdown by reason
SELECT failure_reason, COUNT(*) AS occurrence_count,
	ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_failures
FROM revenue_transactions
WHERE transaction_status = 'Failed'
GROUP BY failure_reason
ORDER BY occurrence_count DESC;

-- 4d. Failure rate by month
SELECT transaction_month, COUNT(*) AS total_transactions,
    SUM(CASE WHEN transaction_status != 'Success' THEN 1 ELSE 0 END) AS non_successful,
    ROUND(SUM(CASE WHEN transaction_status != 'Success' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS failure_rate_pct
FROM revenue_transactions
GROUP BY transaction_month
ORDER BY transaction_month;

-- SUBSCRIPYION AND CHURN KPIS
-- 5a. Subscription status breakdown
SELECT status, COUNT(*) AS subscription_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM subscriptions
GROUP BY status;

-- 5b. Service penetration rate
-- How many of the 30 subscribers are using each service
SELECT v.service_name, v.service_category, COUNT(DISTINCT s.subscriber_id) AS subscribers_on_service,
    (SELECT COUNT(*) FROM subscribers)    AS total_subscribers,
    ROUND(COUNT(DISTINCT s.subscriber_id) * 100.0 / (SELECT COUNT(*) FROM subscribers), 2)  AS penetration_rate_pct
FROM subscriptions s
JOIN vas_services v ON s.service_id = v.service_id
GROUP BY v.service_id, v.service_name, v.service_category
ORDER BY penetration_rate_pct DESC;

-- 5c. Average renewal count by service
-- Higher renewal = more loyal subscribers on that service
SELECT v.service_name, service_category,
    ROUND(AVG(s.renewal_count), 2) AS avg_renewals,
    MAX(s.renewal_count)           AS max_renewals,
    MIN(s.renewal_count)           AS min_renewals
FROM subscriptions s
JOIN vas_services v ON s.service_id = v.service_id
GROUP BY v.service_id, v.service_name, v.service_category
ORDER BY avg_renewals DESC;

-- 5d. Subscription channel preference
SELECT channel, COUNT(*) AS subscriptions,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)   AS channel_share_pct,
    ROUND(AVG(renewal_count), 2)        AS avg_renewals
FROM subscriptions
GROUP BY channel
ORDER BY subscriptions DESC;

-- 5e. Churned subscriber behaviour
-- What services were churned subscribers using before they left
SELECT s.account_status, v.service_name, v.service_category, COUNT(DISTINCT sub.subscriber_id) AS subscriber_count,
    ROUND(AVG(sub.renewal_count), 2) AS avg_renewals
FROM subscriptions sub
JOIN subscribers s  ON sub.subscriber_id = s.subscriber_id
JOIN vas_services v ON sub.service_id    = v.service_id
WHERE s.account_status IN ('Churned', 'Suspended')
GROUP BY s.account_status, v.service_name, v.service_category
ORDER BY s.account_status, subscriber_count DESC;


