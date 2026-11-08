

CREATE OR REPLACE VIEW users_mart AS
SELECT * FROM read_csv_auto('data/processed/users_mart.csv', header = true);
CREATE OR REPLACE VIEW payment_attempts_mart AS
SELECT * FROM read_csv_auto('data/processed/payment_attempts_mart.csv', header = true);

WITH user_metrics AS (
    SELECT
        assigned_group,
        COUNT(*) FILTER (WHERE opened_any) AS opened_users,
        COUNT(*) FILTER (WHERE opened_any AND success_any) AS successful_users,
        COUNT(*) AS assigned_users,
        COUNT(*) FILTER (WHERE success_any) AS itt_successful_users
    FROM users_mart
    WHERE assigned_group IN ('A', 'B')
    GROUP BY assigned_group
)
SELECT *,
       successful_users * 1.0 / NULLIF(opened_users, 0) AS open_to_success_cr,
       itt_successful_users * 1.0 / NULLIF(assigned_users, 0) AS itt_cr
FROM user_metrics
ORDER BY assigned_group;

SELECT assigned_group,
       COUNT(*) FILTER (WHERE opened_any) AS opened_users,
       COUNT(*) FILTER (WHERE entered_any) AS entered_users,
       COUNT(*) FILTER (WHERE confirmed_any) AS confirmed_users,
       COUNT(*) FILTER (WHERE success_any) AS successful_users
FROM users_mart
WHERE assigned_group IN ('A', 'B')
GROUP BY assigned_group
ORDER BY assigned_group;

SELECT assigned_group,
       COUNT(*) FILTER (WHERE opened) AS opened_attempts,
       COUNT(*) FILTER (WHERE entered) AS entered_attempts,
       COUNT(*) FILTER (WHERE confirmed) AS confirmed_attempts,
       COUNT(*) FILTER (WHERE success) AS successful_attempts
FROM payment_attempts_mart
WHERE assigned_group IN ('A', 'B')
GROUP BY assigned_group
ORDER BY assigned_group;

SELECT assigned_group,
       MEDIAN(minutes_open_to_enter) AS median_open_to_enter_min,
       MEDIAN(minutes_enter_to_confirm) AS median_enter_to_confirm_min,
       MEDIAN(minutes_confirm_to_success) AS median_confirm_to_success_min,
       MEDIAN(minutes_open_to_success) AS median_open_to_success_min
FROM payment_attempts_mart
WHERE assigned_group IN ('A', 'B')
GROUP BY assigned_group
ORDER BY assigned_group;

WITH device_metrics AS (
    SELECT assigned_group, device_type,
           COUNT(*) FILTER (WHERE opened_any) AS opened_users,
           COUNT(*) FILTER (WHERE opened_any AND success_any) AS successful_users
    FROM users_mart
    WHERE assigned_group IN ('A', 'B')
    GROUP BY assigned_group, device_type
)
SELECT *, successful_users * 1.0 / NULLIF(opened_users, 0) AS open_to_success_cr
FROM device_metrics
ORDER BY device_type, assigned_group;
