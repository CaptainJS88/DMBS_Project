SET DEFINE OFF;
SET PAGESIZE 100;
SET LINESIZE 200;

PROMPT Query 1
-- English description: List the most played games by total player-hours, considering only games with at least 3 total booked hours.
SELECT
    g.game_name,
    g.genre,
    ROUND(SUM((CAST(b.end_time AS DATE) - CAST(b.start_time AS DATE)) * 24), 2) AS total_player_hours,
    COUNT(b.booking_id) AS total_sessions
FROM Spring26_S008_T7_Game g
JOIN Spring26_S008_T7_Booking b
    ON b.game_id = g.game_id
WHERE b.booking_status <> 'CANCELLED'
GROUP BY g.game_name, g.genre
HAVING SUM((CAST(b.end_time AS DATE) - CAST(b.start_time AS DATE)) * 24) >= 3
ORDER BY total_player_hours DESC, total_sessions DESC;

-- Expected output before update:
-- Valor Strike | FPS | 10 | 5
-- Galaxy FC | Sports | 8 | 5
-- Retro Smash Party | Fighting | 6 | 3
-- Cyber Builders Online | Sandbox | 6 | 3
-- Party Galaxy | Party | 6 | 3
-- Space Builders | Sandbox | 6 | 3
-- Mech Clash | Fighting | 4 | 2
-- Neon Strikers | Sports | 4 | 2
-- Dragon Kart | Racing | 4 | 2
-- VR Saber Clash | Rhythm | 3 | 3
-- Kingdom Tactics | Strategy | 3 | 2
-- Dance Party NX | Party | 3 | 2
-- Expected output after update:
-- Valor Strike | FPS | 10 | 5
-- Galaxy FC | Sports | 8 | 5
-- Space Builders | Sandbox | 6 | 3
-- Cyber Builders Online | Sandbox | 6 | 3
-- Party Galaxy | Party | 6 | 3
-- Retro Smash Party | Fighting | 6 | 3
-- Mech Clash | Fighting | 4 | 2
-- Neon Strikers | Sports | 4 | 2
-- Dragon Kart | Racing | 4 | 2
-- VR Saber Clash | Rhythm | 3 | 3
-- Kingdom Tactics | Strategy | 3 | 2
-- Dance Party NX | Party | 3 | 2

PROMPT Query 2
-- English description: Show the top 5 customers by number of bookings in the last 30 days, separating members and guests.
SELECT
    c.customer_id,
    c.customer_name,
    c.membership_status,
    COUNT(b.booking_id) AS booking_count,
    ROUND(
        SUM(s.hourly_rate * ((CAST(b.end_time AS DATE) - CAST(b.start_time AS DATE)) * 24)),
        2
    ) AS total_spent
FROM Spring26_S008_T7_Customer c
JOIN Spring26_S008_T7_Booking b
    ON b.customer_id = c.customer_id
JOIN Spring26_S008_T7_Station s
    ON s.station_id = b.station_id
WHERE b.start_time >= TIMESTAMP '2026-03-03 00:00:00'
GROUP BY c.customer_id, c.customer_name, c.membership_status
HAVING COUNT(b.booking_id) >= 1
ORDER BY booking_count DESC, total_spent DESC
FETCH FIRST 5 ROWS ONLY;

-- Expected output before update:
-- 1001 | Alex Patel | MEMBER | 6 | 182
-- 1018 | Isaac Murphy | MEMBER | 2 | 200
-- 1023 | Layla Hughes | MEMBER | 2 | 120
-- 1024 | Henry Flores | MEMBER | 2 | 112
-- 1013 | Harper Cole | MEMBER | 2 | 40
-- Expected output after update:
-- 1001 | Alex Patel | MEMBER | 6 | 182
-- 1010 | Noah Walker | MEMBER | 3 | 140
-- 1018 | Isaac Murphy | MEMBER | 2 | 200
-- 1023 | Layla Hughes | MEMBER | 2 | 120
-- 1024 | Henry Flores | MEMBER | 2 | 112

PROMPT Query 3
-- English description: Measure station utilization by station type and individual station using ROLLUP.
SELECT
    s.station_type_code,
    s.station_label,
    ROUND(
        SUM(
            NVL((CAST(b.end_time AS DATE) - CAST(b.start_time AS DATE)) * 24, 0)
        ),
        2
    ) AS booked_hours,
    COUNT(b.booking_id) AS booking_count
FROM Spring26_S008_T7_Station s
LEFT JOIN Spring26_S008_T7_Booking b
    ON b.station_id = s.station_id
   AND b.booking_status <> 'CANCELLED'
GROUP BY ROLLUP (s.station_type_code, s.station_label)
ORDER BY s.station_type_code, s.station_label;

-- Expected output before update:
-- GROUP_ROOM | GR-01 | 6 | 3
-- GROUP_ROOM | GR-02 | 2 | 1
-- GROUP_ROOM | GR-03 | 4 | 2
-- GROUP_ROOM | GR-04 | 2 | 1
-- GROUP_ROOM | GR-05 | 2 | 1
-- GROUP_ROOM | GR-06 | 2 | 1
-- GROUP_ROOM | null | 18 | 9
-- NINTENDO | NT-01 | 5 | 3
-- NINTENDO | NT-02 | 2 | 1
-- NINTENDO | NT-03 | 2 | 1
-- NINTENDO | NT-04 | 2 | 1
-- NINTENDO | NT-05 | 2 | 1
-- NINTENDO | null | 13 | 7
-- PC | PC-01 | 4 | 3
-- PC | PC-02 | 6 | 3
-- PC | PC-03 | 0 | 0
-- PC | PC-04 | 4 | 2
-- PC | PC-05 | 2 | 1
-- PC | PC-06 | 2 | 1
-- PC | PC-07 | 2 | 1
-- PC | PC-08 | 2 | 1
-- PC | null | 22 | 12
-- PLAYSTATION | PS-01 | 6 | 3
-- PLAYSTATION | PS-02 | 4 | 2
-- PLAYSTATION | PS-03 | 2 | 1
-- PLAYSTATION | PS-04 | 2 | 1
-- PLAYSTATION | PS-05 | 0 | 0
-- PLAYSTATION | PS-06 | 2 | 1
-- PLAYSTATION | PS-07 | 2 | 1
-- PLAYSTATION | null | 18 | 9
-- VR | VR-01 | 2 | 2
-- VR | VR-02 | 2 | 2
-- VR | VR-03 | 2 | 2
-- VR | VR-04 | 1 | 1
-- VR | VR-05 | 1 | 1
-- VR | VR-06 | 1 | 1
-- VR | VR-07 | 1 | 1
-- VR | null | 10 | 10
-- XBOX | XB-01 | 5 | 3
-- XBOX | XB-02 | 2 | 1
-- XBOX | XB-03 | 4 | 2
-- XBOX | XB-04 | 1 | 1
-- XBOX | XB-05 | 4 | 2
-- XBOX | XB-06 | 1 | 1
-- XBOX | XB-07 | 2 | 1
-- XBOX | null | 19 | 11
-- null | null | 100 | 58
-- Expected output after update:
-- GROUP_ROOM | GR-01 | 8 | 4
-- GROUP_ROOM | GR-02 | 2 | 1
-- GROUP_ROOM | GR-03 | 4 | 2
-- GROUP_ROOM | GR-04 | 2 | 1
-- GROUP_ROOM | GR-05 | 2 | 1
-- GROUP_ROOM | GR-06 | 2 | 1
-- GROUP_ROOM | null | 20 | 10
-- NINTENDO | NT-01 | 5 | 3
-- NINTENDO | NT-02 | 2 | 1
-- NINTENDO | NT-03 | 2 | 1
-- NINTENDO | NT-04 | 2 | 1
-- NINTENDO | NT-05 | 2 | 1
-- NINTENDO | null | 13 | 7
-- PC | PC-01 | 6 | 4
-- PC | PC-02 | 6 | 3
-- PC | PC-03 | 0 | 0
-- PC | PC-04 | 4 | 2
-- PC | PC-05 | 2 | 1
-- PC | PC-06 | 2 | 1
-- PC | PC-07 | 2 | 1
-- PC | PC-08 | 2 | 1
-- PC | null | 24 | 13
-- PLAYSTATION | PS-01 | 6 | 3
-- PLAYSTATION | PS-02 | 4 | 2
-- PLAYSTATION | PS-03 | 2 | 1
-- PLAYSTATION | PS-04 | 2 | 1
-- PLAYSTATION | PS-05 | 0 | 0
-- PLAYSTATION | PS-06 | 2 | 1
-- PLAYSTATION | PS-07 | 2 | 1
-- PLAYSTATION | null | 18 | 9
-- VR | VR-01 | 2 | 2
-- VR | VR-02 | 2 | 2
-- VR | VR-03 | 2 | 2
-- VR | VR-04 | 1 | 1
-- VR | VR-05 | 1 | 1
-- VR | VR-06 | 1 | 1
-- VR | VR-07 | 1 | 1
-- VR | null | 10 | 10
-- XBOX | XB-01 | 5 | 3
-- XBOX | XB-02 | 0 | 0
-- XBOX | XB-03 | 4 | 2
-- XBOX | XB-04 | 1 | 1
-- XBOX | XB-05 | 4 | 2
-- XBOX | XB-06 | 1 | 1
-- XBOX | XB-07 | 2 | 1
-- XBOX | null | 17 | 10
-- null | null | 102 | 59

PROMPT Query 4
-- English description: Calculate average labor cost per booking by day of week and shift using ROLLUP.
SELECT
    TO_CHAR(ss.shift_start, 'DY') AS shift_day,
    CASE
        WHEN EXTRACT(HOUR FROM ss.shift_start) BETWEEN 6 AND 11 THEN 'MORNING'
        WHEN EXTRACT(HOUR FROM ss.shift_start) BETWEEN 12 AND 15 THEN 'AFTERNOON'
        WHEN EXTRACT(HOUR FROM ss.shift_start) BETWEEN 16 AND 19 THEN 'EVENING'
        ELSE 'NIGHT'
    END AS shift_name,
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
GROUP BY ROLLUP (
    TO_CHAR(ss.shift_start, 'DY'),
    CASE
        WHEN EXTRACT(HOUR FROM ss.shift_start) BETWEEN 6 AND 11 THEN 'MORNING'
        WHEN EXTRACT(HOUR FROM ss.shift_start) BETWEEN 12 AND 15 THEN 'AFTERNOON'
        WHEN EXTRACT(HOUR FROM ss.shift_start) BETWEEN 16 AND 19 THEN 'EVENING'
        ELSE 'NIGHT'
    END
)
ORDER BY shift_day, shift_name;

-- Expected output before update:
-- FRI | AFTERNOON | 166.4
-- FRI | EVENING | 139.48
-- FRI | MORNING | 152.2
-- FRI | NIGHT | 160.2
-- FRI | null | 154.57
-- MON | AFTERNOON | 172
-- MON | EVENING | 136.5
-- MON | MORNING | 163.33
-- MON | null | 155.83
-- SAT | AFTERNOON | 164
-- SAT | EVENING | 133
-- SAT | MORNING | 144.5
-- SAT | null | 140.7
-- SUN | AFTERNOON | 160
-- SUN | EVENING | 136.5
-- SUN | MORNING | 168
-- SUN | NIGHT | 149
-- SUN | null | 153.75
-- THU | AFTERNOON | 157.6
-- THU | EVENING | 147
-- THU | MORNING | 161
-- THU | NIGHT | 155.2
-- THU | null | 156.57
-- TUE | AFTERNOON | 164
-- TUE | EVENING | 141.75
-- TUE | NIGHT | 154
-- TUE | null | 155.55
-- WED | AFTERNOON | 160
-- WED | EVENING | 133
-- WED | MORNING | 145
-- WED | NIGHT | 166
-- WED | null | 147
-- null | null | 151.07
-- Expected output after update:
-- FRI | AFTERNOON | 166.4
-- FRI | EVENING | 139.48
-- FRI | MORNING | 152.2
-- FRI | NIGHT | 160.2
-- FRI | null | 154.57
-- MON | AFTERNOON | 172
-- MON | EVENING | 136.5
-- MON | MORNING | 163.33
-- MON | null | 155.83
-- SAT | AFTERNOON | 164
-- SAT | EVENING | 133
-- SAT | MORNING | 144.5
-- SAT | null | 141.56
-- SUN | AFTERNOON | 160
-- SUN | EVENING | 136.5
-- SUN | MORNING | 168
-- SUN | NIGHT | 149
-- SUN | null | 153.75
-- THU | AFTERNOON | 159.73
-- THU | EVENING | 147
-- THU | MORNING | 161
-- THU | NIGHT | 155.2
-- THU | null | 157.63
-- TUE | AFTERNOON | 164
-- TUE | EVENING | 141.75
-- TUE | NIGHT | 154
-- TUE | null | 155.55
-- WED | AFTERNOON | 160
-- WED | EVENING | 133
-- WED | MORNING | 144.67
-- WED | NIGHT | 166
-- WED | null | 146.57
-- null | null | 151.57

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

-- Expected output before update:
-- 1001 | Alex Patel
-- Expected output after update:
-- 1001 | Alex Patel

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

-- Expected output before update:
-- Battle Arena Origins | MOBA | GROUP_ROOM
-- Battle Arena Origins | MOBA | PC
-- Expected output after update:
-- no rows selected
