

CREATE OR REPLACE VIEW users_mart AS
SELECT * FROM read_csv_auto('data/processed/users_mart.csv', header = true);

CREATE OR REPLACE VIEW payment_attempts_mart AS
SELECT * FROM read_csv_auto('data/processed/payment_attempts_mart.csv', header = true);

SELECT 'users_mart' AS dataset, COUNT(*) AS rows, COUNT(DISTINCT user_id) AS distinct_ids
FROM users_mart
UNION ALL
SELECT 'payment_attempts_mart', COUNT(*), COUNT(DISTINCT payment_id)
FROM payment_attempts_mart;

SELECT user_id, COUNT(*) AS n
FROM users_mart GROUP BY user_id HAVING COUNT(*) > 1;

SELECT payment_id, COUNT(*) AS n
FROM payment_attempts_mart GROUP BY payment_id HAVING COUNT(*) > 1;

SELECT assigned_group, COUNT(*) AS users
FROM users_mart GROUP BY assigned_group ORDER BY assigned_group;

SELECT
    COUNT(*) FILTER (WHERE user_id IS NULL) AS missing_user_id,
    COUNT(*) FILTER (WHERE group_mismatch) AS group_mismatch_rows,
    COUNT(*) FILTER (WHERE step1_opened IS NULL) AS missing_open_timestamp,
    COUNT(*) FILTER (WHERE step4_success IS NOT NULL) AS successful_attempts
FROM payment_attempts_mart;
