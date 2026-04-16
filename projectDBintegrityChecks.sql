SET DEFINE OFF;
SET PAGESIZE 100;
SET LINESIZE 200;

PROMPT ==========================================
PROMPT GameHub Integrity Checks
PROMPT Rows returned by anomaly checks usually mean a problem.
PROMPT ==========================================

PROMPT
PROMPT Check 1: Row counts by table
SELECT 'Spring26_S008_T7_StationType' AS table_name, COUNT(*) AS row_count FROM Spring26_S008_T7_StationType
UNION ALL
SELECT 'Spring26_S008_T7_Customer', COUNT(*) FROM Spring26_S008_T7_Customer
UNION ALL
SELECT 'Spring26_S008_T7_CustPhone', COUNT(*) FROM Spring26_S008_T7_CustPhone
UNION ALL
SELECT 'Spring26_S008_T7_ZipCode', COUNT(*) FROM Spring26_S008_T7_ZipCode
UNION ALL
SELECT 'Spring26_S008_T7_Member', COUNT(*) FROM Spring26_S008_T7_Member
UNION ALL
SELECT 'Spring26_S008_T7_Employee', COUNT(*) FROM Spring26_S008_T7_Employee
UNION ALL
SELECT 'Spring26_S008_T7_EmpPhone', COUNT(*) FROM Spring26_S008_T7_EmpPhone
UNION ALL
SELECT 'Spring26_S008_T7_EmpEmail', COUNT(*) FROM Spring26_S008_T7_EmpEmail
UNION ALL
SELECT 'Spring26_S008_T7_ShiftSlot', COUNT(*) FROM Spring26_S008_T7_ShiftSlot
UNION ALL
SELECT 'Spring26_S008_T7_Station', COUNT(*) FROM Spring26_S008_T7_Station
UNION ALL
SELECT 'Spring26_S008_T7_Game', COUNT(*) FROM Spring26_S008_T7_Game
UNION ALL
SELECT 'Spring26_S008_T7_GameSupport', COUNT(*) FROM Spring26_S008_T7_GameSupport
UNION ALL
SELECT 'Spring26_S008_T7_Booking', COUNT(*) FROM Spring26_S008_T7_Booking
UNION ALL
SELECT 'Spring26_S008_T7_Manages', COUNT(*) FROM Spring26_S008_T7_Manages
ORDER BY table_name;

PROMPT
PROMPT Check 2: StationType domain violations
SELECT *
FROM Spring26_S008_T7_StationType
WHERE base_hourly_rate <= 0
   OR default_capacity <= 0;

PROMPT
PROMPT Check 3: Customer domain violations
SELECT *
FROM Spring26_S008_T7_Customer
WHERE membership_status NOT IN ('GUEST', 'MEMBER')
   OR total_lifetime_spend < 0
   OR dob >= DATE '2026-04-15';

PROMPT
PROMPT Check 4: Duplicate customer emails
SELECT email, COUNT(*) AS duplicate_count
FROM Spring26_S008_T7_Customer
GROUP BY email
HAVING COUNT(*) > 1;

PROMPT
PROMPT Check 5: Customer phones whose parent customer is missing
SELECT cp.*
FROM Spring26_S008_T7_CustPhone cp
LEFT JOIN Spring26_S008_T7_Customer c
    ON c.customer_id = cp.customer_id
WHERE c.customer_id IS NULL;

PROMPT
PROMPT Check 6: Coverage check - customers without phone numbers
SELECT c.customer_id, c.customer_name
FROM Spring26_S008_T7_Customer c
LEFT JOIN Spring26_S008_T7_CustPhone cp
    ON cp.customer_id = c.customer_id
WHERE cp.customer_id IS NULL
ORDER BY c.customer_id;

PROMPT
PROMPT Check 7: Member rows whose customer is missing
SELECT m.*
FROM Spring26_S008_T7_Member m
LEFT JOIN Spring26_S008_T7_Customer c
    ON c.customer_id = m.customer_id
WHERE c.customer_id IS NULL;

PROMPT
PROMPT Check 8: Member rows whose zip code is missing
SELECT m.*
FROM Spring26_S008_T7_Member m
LEFT JOIN Spring26_S008_T7_ZipCode z
    ON z.zip_code = m.zip_code
WHERE z.zip_code IS NULL;

PROMPT
PROMPT Check 9: Members not marked MEMBER in Customer
SELECT m.customer_id, c.customer_name, c.membership_status
FROM Spring26_S008_T7_Member m
JOIN Spring26_S008_T7_Customer c
    ON c.customer_id = m.customer_id
WHERE c.membership_status <> 'MEMBER'
ORDER BY m.customer_id;

PROMPT
PROMPT Check 10: Customers marked MEMBER but missing a Member row
SELECT c.customer_id, c.customer_name, c.membership_status
FROM Spring26_S008_T7_Customer c
LEFT JOIN Spring26_S008_T7_Member m
    ON m.customer_id = c.customer_id
WHERE c.membership_status = 'MEMBER'
  AND m.customer_id IS NULL
ORDER BY c.customer_id;

PROMPT
PROMPT Check 11: Members with no non-cancelled booking
SELECT m.customer_id, c.customer_name
FROM Spring26_S008_T7_Member m
JOIN Spring26_S008_T7_Customer c
    ON c.customer_id = m.customer_id
LEFT JOIN Spring26_S008_T7_Booking b
    ON b.customer_id = m.customer_id
   AND b.booking_status <> 'CANCELLED'
WHERE b.booking_id IS NULL
ORDER BY m.customer_id;

PROMPT
PROMPT Check 12: Employees with invalid hourly rates
SELECT *
FROM Spring26_S008_T7_Employee
WHERE hourly_rate <= 0;

PROMPT
PROMPT Check 13: Employee phones whose parent employee is missing
SELECT ep.*
FROM Spring26_S008_T7_EmpPhone ep
LEFT JOIN Spring26_S008_T7_Employee e
    ON e.employee_id = ep.employee_id
WHERE e.employee_id IS NULL;

PROMPT
PROMPT Check 14: Coverage check - employees without phone numbers
SELECT e.employee_id, e.employee_name
FROM Spring26_S008_T7_Employee e
LEFT JOIN Spring26_S008_T7_EmpPhone ep
    ON ep.employee_id = e.employee_id
WHERE ep.employee_id IS NULL
ORDER BY e.employee_id;

PROMPT
PROMPT Check 15: Employee emails whose parent employee is missing
SELECT ee.*
FROM Spring26_S008_T7_EmpEmail ee
LEFT JOIN Spring26_S008_T7_Employee e
    ON e.employee_id = ee.employee_id
WHERE e.employee_id IS NULL;

PROMPT
PROMPT Check 16: Duplicate employee email addresses
SELECT email_address, COUNT(*) AS duplicate_count
FROM Spring26_S008_T7_EmpEmail
GROUP BY email_address
HAVING COUNT(*) > 1;

PROMPT
PROMPT Check 17: Coverage check - employees without email addresses
SELECT e.employee_id, e.employee_name
FROM Spring26_S008_T7_Employee e
LEFT JOIN Spring26_S008_T7_EmpEmail ee
    ON ee.employee_id = e.employee_id
WHERE ee.employee_id IS NULL
ORDER BY e.employee_id;

PROMPT
PROMPT Check 18: Shift slots with impossible time ranges
SELECT *
FROM Spring26_S008_T7_ShiftSlot
WHERE shift_end <= shift_start;

PROMPT
PROMPT Check 19: Shift slots whose employee is missing
SELECT ss.*
FROM Spring26_S008_T7_ShiftSlot ss
LEFT JOIN Spring26_S008_T7_Employee e
    ON e.employee_id = ss.employee_id
WHERE e.employee_id IS NULL;

PROMPT
PROMPT Check 20: Overlapping shifts for the same employee
SELECT
    a.employee_id,
    a.shift_id AS shift_id_1,
    b.shift_id AS shift_id_2,
    a.shift_start AS shift_1_start,
    a.shift_end AS shift_1_end,
    b.shift_start AS shift_2_start,
    b.shift_end AS shift_2_end
FROM Spring26_S008_T7_ShiftSlot a
JOIN Spring26_S008_T7_ShiftSlot b
    ON a.employee_id = b.employee_id
   AND a.shift_id < b.shift_id
   AND a.shift_start < b.shift_end
   AND b.shift_start < a.shift_end
ORDER BY a.employee_id, a.shift_id, b.shift_id;

PROMPT
PROMPT Check 21: Stations whose station type is missing
SELECT s.*
FROM Spring26_S008_T7_Station s
LEFT JOIN Spring26_S008_T7_StationType st
    ON st.station_type_code = s.station_type_code
WHERE st.station_type_code IS NULL;

PROMPT
PROMPT Check 22: Station domain violations
SELECT *
FROM Spring26_S008_T7_Station
WHERE current_status NOT IN ('AVAILABLE', 'OCCUPIED', 'MAINTENANCE')
   OR hourly_rate <= 0
   OR max_capacity <= 0;

PROMPT
PROMPT Check 23: Informational - stations whose capacity differs from station type default
SELECT
    s.station_id,
    s.station_label,
    s.station_type_code,
    s.max_capacity,
    st.default_capacity
FROM Spring26_S008_T7_Station s
JOIN Spring26_S008_T7_StationType st
    ON st.station_type_code = s.station_type_code
WHERE s.max_capacity <> st.default_capacity
ORDER BY s.station_id;

PROMPT
PROMPT Check 24: Games with invalid domain values
SELECT *
FROM Spring26_S008_T7_Game
WHERE age_rating NOT IN ('E', 'E10+', 'T', 'M', 'AO')
   OR competitive_status NOT IN ('CASUAL', 'COMPETITIVE', 'BOTH')
   OR multiplayer_capacity <= 0
   OR game_rating < 0
   OR game_rating > 10;

PROMPT
PROMPT Check 25: Duplicate game names
SELECT game_name, COUNT(*) AS duplicate_count
FROM Spring26_S008_T7_Game
GROUP BY game_name
HAVING COUNT(*) > 1;

PROMPT
PROMPT Check 26: GameSupport rows whose game is missing
SELECT gs.*
FROM Spring26_S008_T7_GameSupport gs
LEFT JOIN Spring26_S008_T7_Game g
    ON g.game_id = gs.game_id
WHERE g.game_id IS NULL;

PROMPT
PROMPT Check 27: GameSupport rows whose station type is missing
SELECT gs.*
FROM Spring26_S008_T7_GameSupport gs
LEFT JOIN Spring26_S008_T7_StationType st
    ON st.station_type_code = gs.station_type_code
WHERE st.station_type_code IS NULL;

PROMPT
PROMPT Check 28: Booking rows whose customer is missing
SELECT b.*
FROM Spring26_S008_T7_Booking b
LEFT JOIN Spring26_S008_T7_Customer c
    ON c.customer_id = b.customer_id
WHERE c.customer_id IS NULL;

PROMPT
PROMPT Check 29: Booking rows whose station is missing
SELECT b.*
FROM Spring26_S008_T7_Booking b
LEFT JOIN Spring26_S008_T7_Station s
    ON s.station_id = b.station_id
WHERE s.station_id IS NULL;

PROMPT
PROMPT Check 30: Booking rows whose game is missing
SELECT b.*
FROM Spring26_S008_T7_Booking b
LEFT JOIN Spring26_S008_T7_Game g
    ON g.game_id = b.game_id
WHERE g.game_id IS NULL;

PROMPT
PROMPT Check 31: Booking domain violations
SELECT *
FROM Spring26_S008_T7_Booking
WHERE booking_status NOT IN ('ACTIVE', 'COMPLETED', 'CANCELLED')
   OR end_time <= start_time;

PROMPT
PROMPT Check 32: Bookings whose game is unsupported on the booked station type
SELECT
    b.booking_id,
    b.station_id,
    s.station_type_code,
    b.game_id,
    g.game_name
FROM Spring26_S008_T7_Booking b
JOIN Spring26_S008_T7_Station s
    ON s.station_id = b.station_id
JOIN Spring26_S008_T7_Game g
    ON g.game_id = b.game_id
LEFT JOIN Spring26_S008_T7_GameSupport gs
    ON gs.game_id = b.game_id
   AND gs.station_type_code = s.station_type_code
WHERE gs.game_id IS NULL
ORDER BY b.booking_id;

PROMPT
PROMPT Check 33: Overlapping active/completed bookings on the same station
SELECT
    a.station_id,
    a.booking_id AS booking_id_1,
    b.booking_id AS booking_id_2,
    a.start_time AS booking_1_start,
    a.end_time AS booking_1_end,
    b.start_time AS booking_2_start,
    b.end_time AS booking_2_end
FROM Spring26_S008_T7_Booking a
JOIN Spring26_S008_T7_Booking b
    ON a.station_id = b.station_id
   AND a.booking_id < b.booking_id
   AND a.booking_status <> 'CANCELLED'
   AND b.booking_status <> 'CANCELLED'
   AND a.start_time < b.end_time
   AND b.start_time < a.end_time
ORDER BY a.station_id, a.booking_id, b.booking_id;

PROMPT
PROMPT Check 34: Manages rows whose booking is missing
SELECT m.*
FROM Spring26_S008_T7_Manages m
LEFT JOIN Spring26_S008_T7_Booking b
    ON b.booking_id = m.booking_id
WHERE b.booking_id IS NULL;

PROMPT
PROMPT Check 35: Manages rows whose employee is missing
SELECT m.*
FROM Spring26_S008_T7_Manages m
LEFT JOIN Spring26_S008_T7_Employee e
    ON e.employee_id = m.employee_id
WHERE e.employee_id IS NULL;

PROMPT
PROMPT Check 36: Bookings with no manager assigned
SELECT b.booking_id, b.customer_id, b.station_id, b.game_id
FROM Spring26_S008_T7_Booking b
LEFT JOIN Spring26_S008_T7_Manages m
    ON m.booking_id = b.booking_id
WHERE m.booking_id IS NULL
ORDER BY b.booking_id;

PROMPT
PROMPT Check 37: Manager assignments not covered by any shift slot
SELECT
    m.booking_id,
    m.employee_id,
    b.start_time,
    b.end_time
FROM Spring26_S008_T7_Manages m
JOIN Spring26_S008_T7_Booking b
    ON b.booking_id = m.booking_id
LEFT JOIN Spring26_S008_T7_ShiftSlot ss
    ON ss.employee_id = m.employee_id
   AND b.start_time >= ss.shift_start
   AND b.end_time <= ss.shift_end
WHERE ss.shift_id IS NULL
ORDER BY m.booking_id, m.employee_id;

PROMPT
PROMPT Check 38: Informational - bookings with more than one manager
SELECT booking_id, COUNT(*) AS manager_count
FROM Spring26_S008_T7_Manages
GROUP BY booking_id
HAVING COUNT(*) > 1
ORDER BY booking_id;

PROMPT
PROMPT Check 39: Summary of member status sync
SELECT
    c.membership_status,
    COUNT(*) AS customer_count,
    SUM(CASE WHEN m.customer_id IS NOT NULL THEN 1 ELSE 0 END) AS member_rows
FROM Spring26_S008_T7_Customer c
LEFT JOIN Spring26_S008_T7_Member m
    ON m.customer_id = c.customer_id
GROUP BY c.membership_status
ORDER BY c.membership_status;

PROMPT
PROMPT Check 40: Summary of bookings and managers
SELECT
    b.booking_status,
    COUNT(*) AS booking_count,
    SUM(CASE WHEN m.booking_id IS NOT NULL THEN 1 ELSE 0 END) AS bookings_with_manager_rows
FROM Spring26_S008_T7_Booking b
LEFT JOIN (
    SELECT DISTINCT booking_id
    FROM Spring26_S008_T7_Manages
) m
    ON m.booking_id = b.booking_id
GROUP BY b.booking_status
ORDER BY b.booking_status;

PROMPT ==========================================
PROMPT Integrity checks complete.
PROMPT ==========================================
