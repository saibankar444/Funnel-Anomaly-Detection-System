-- Total Visitors (unique users who had a session)
SELECT COUNT(DISTINCT user_id) AS total_visitors 
FROM sessions;

-- Sessions with Transactions
SELECT COUNT(DISTINCT session_id) AS sessions_with_transactions 
FROM transactions;

-- Sessions with Successful Payments
SELECT COUNT(DISTINCT session_id) AS successful_sessions 
FROM transactions 
WHERE status = 'success';

-- Sessions with Failed Payments
SELECT COUNT(DISTINCT session_id) AS failed_sessions 
FROM transactions 
WHERE status = 'failed';

-- Conversion Rate (% of transactions that succeeded)
SELECT 
  ROUND(
    (SELECT COUNT(DISTINCT session_id) FROM transactions WHERE status = 'success') * 100.0 /
    (SELECT COUNT(DISTINCT session_id) FROM transactions),
    2
  ) AS conversion_rate_percent;

-- Failure Rate by Location
SELECT 
  u.location,
  COUNT(CASE WHEN t.status = 'failed' THEN 1 END) * 100.0 / COUNT(*) AS failure_rate_percent
FROM transactions t
JOIN sessions s ON t.session_id = s.session_id
JOIN users u ON s.user_id = u.user_id
GROUP BY u.location;


-- Users With More Than 1 Failed Transaction
SELECT s.user_id, COUNT(*) AS failed_count
FROM transactions t
JOIN sessions s ON t.session_id = s.session_id
WHERE t.status = 'failed'
GROUP BY s.user_id
HAVING COUNT(*) > 1;

-- High-Value Failures (> ₹4000)
SELECT *
FROM transactions 
WHERE status = 'failed' AND amount > 4000;


-- Total Success Amount by Location
SELECT 
  u.location,
  SUM(t.amount) AS total_success_amount
FROM transactions t
JOIN sessions s ON t.session_id = s.session_id
JOIN users u ON s.user_id = u.user_id
WHERE t.status = 'success'
GROUP BY u.location;


