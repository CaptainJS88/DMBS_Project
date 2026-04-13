SET DEFINE OFF;
SET PAGESIZE 100;
SET LINESIZE 200;

PROMPT Query 1
-- English description: List the most played games by total player-hours, considering only games with at least 3 total booked hours.
SELECT
    g.game_name,
    g.genre,
    ROUND(SUM(b.actual_duration_hours), 2) AS total_player_hours,
    COUNT(b.booking_id) AS total_sessions
FROM Spring26_S008_T7_Game g
JOIN Spring26_S008_T7_Booking b
    ON b.game_id = g.game_id
WHERE b.booking_status <> 'CANCELLED'
GROUP BY g.game_name, g.genre
HAVING SUM(b.actual_duration_hours) >= 3
ORDER BY total_player_hours DESC, total_sessions DESC;

-- Expected output: paste the Oracle result here before final submission.

PROMPT Query 2
-- English description: Show the top 5 customers by number of bookings in the last 30 days, separating members and guests.
SELECT
    c.customer_id,
    c.customer_name,
    c.membership_status,
    COUNT(b.booking_id) AS booking_count,
    ROUND(SUM(b.booking_cost), 2) AS total_spent
FROM Spring26_S008_T7_Customer c
JOIN Spring26_S008_T7_Booking b
    ON b.customer_id = c.customer_id
WHERE b.start_time >= TIMESTAMP '2026-03-03 00:00:00'
GROUP BY c.customer_id, c.customer_name, c.membership_status
HAVING COUNT(b.booking_id) >= 1
ORDER BY booking_count DESC, total_spent DESC
FETCH FIRST 5 ROWS ONLY;

-- Expected output: paste the Oracle result here before final submission.

PROMPT Query 3
-- English description: Measure station utilization by station type and individual station using ROLLUP.
SELECT
    s.station_type_code,
    s.station_label,
    ROUND(SUM(NVL(b.actual_duration_hours, 0)), 2) AS booked_hours,
    COUNT(b.booking_id) AS booking_count
FROM Spring26_S008_T7_Station s
LEFT JOIN Spring26_S008_T7_Booking b
    ON b.station_id = s.station_id
   AND b.booking_status <> 'CANCELLED'
GROUP BY ROLLUP (s.station_type_code, s.station_label)
ORDER BY s.station_type_code, s.station_label;

-- Expected output: paste the Oracle result here before final submission.

PROMPT Query 4
-- English description: Calculate average labor cost per booking by day of week and shift using ROLLUP.
SELECT
    TO_CHAR(ss.shift_start, 'DY') AS shift_day,
    ss.shift_name,
    ROUND(
        SUM(
            e.hourly_rate * ((CAST(ss.shift_end AS DATE) - CAST(ss.shift_start AS DATE)) * 24)
        ) / NULLIF(COUNT(DISTINCT b.booking_id), 0),
        2
    ) AS avg_labor_cost_per_booking
FROM Spring26_S008_T7_ShiftSlot ss
JOIN Spring26_S008_T7_Employee e
    ON e.employee_id = ss.employee_id
LEFT JOIN Spring26_S008_T7_Booking b
    ON b.employee_id = ss.employee_id
   AND b.start_time >= ss.shift_start
   AND b.end_time <= ss.shift_end
GROUP BY ROLLUP (TO_CHAR(ss.shift_start, 'DY'), ss.shift_name)
ORDER BY shift_day, ss.shift_name;

-- Expected output: paste the Oracle result here before final submission.

PROMPT Query 5
-- English description: Find customers who have booked every station type offered by the gaming hub.
SELECT
    c.customer_id,
    c.customer_name
FROM Spring26_S008_T7_Customer c
WHERE NOT EXISTS (
    SELECT st.station_type_code
    FROM Spring26_S008_T7_StationType st
    WHERE NOT EXISTS (
        SELECT 1
        FROM Spring26_S008_T7_Booking b
        JOIN Spring26_S008_T7_Station s
            ON s.station_id = b.station_id
        WHERE b.customer_id = c.customer_id
          AND s.station_type_code = st.station_type_code
    )
)
ORDER BY c.customer_id;

-- Expected output: paste the Oracle result here before final submission.

PROMPT Query 6
-- English description: Identify underperforming arena-themed games with no bookings, broken down by supported station type.
SELECT
    g.game_name,
    g.genre,
    gs.station_type_code
FROM Spring26_S008_T7_Game g
JOIN Spring26_S008_T7_GameSupport gs
    ON gs.game_id = g.game_id
WHERE g.game_name LIKE '%Arena%'
  AND NOT EXISTS (
      SELECT 1
      FROM Spring26_S008_T7_Booking b
      WHERE b.game_id = g.game_id
        AND b.booking_status <> 'CANCELLED'
  )
ORDER BY g.game_name, gs.station_type_code;

-- Expected output: paste the Oracle result here before final submission.
