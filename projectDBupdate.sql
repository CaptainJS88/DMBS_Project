SET DEFINE OFF;
SET SERVEROUTPUT ON;

PROMPT Applying update batch for Team 7...

INSERT INTO Spring26_S008_T7_Booking
VALUES (
    6019,
    1010,
    4001,
    5009,
    TIMESTAMP '2026-04-01 13:00:00',
    TIMESTAMP '2026-04-01 15:00:00',
    'COMPLETED'
);

INSERT INTO Spring26_S008_T7_Manages VALUES (6019, 2001);

INSERT INTO Spring26_S008_T7_Booking
VALUES (
    6020,
    1010,
    4008,
    5012,
    TIMESTAMP '2026-04-02 17:00:00',
    TIMESTAMP '2026-04-02 19:00:00',
    'COMPLETED'
);

INSERT INTO Spring26_S008_T7_Manages VALUES (6020, 2007);

INSERT INTO Spring26_S008_T7_Member
VALUES (
    1007,
    DATE '2026-04-03',
    '742 Liberty Ave',
    '76011'
);

UPDATE Spring26_S008_T7_Customer
SET total_lifetime_spend = 200.00
WHERE customer_id = 1010;

UPDATE Spring26_S008_T7_Customer
SET total_lifetime_spend = 72.00
WHERE customer_id = 1007;

UPDATE Spring26_S008_T7_Station
SET current_status = 'AVAILABLE'
WHERE station_id = 4011;

DELETE FROM Spring26_S008_T7_Booking
WHERE booking_id = 6008;

COMMIT;

PROMPT Update batch complete.
