SET DEFINE OFF;
SET SERVEROUTPUT ON;

PROMPT Creating GameHub schema for Team 7...
PROMPT Note: table suffixes are intentionally short so the required prefix stays Oracle-safe.

CREATE TABLE Spring26_S008_T7_StationType (
    station_type_code VARCHAR2(20) PRIMARY KEY,
    base_hourly_rate NUMBER(6,2) NOT NULL CHECK (base_hourly_rate > 0),
    default_capacity NUMBER(3) NOT NULL CHECK (default_capacity > 0)
);

CREATE TABLE Spring26_S008_T7_Customer (
    customer_id NUMBER PRIMARY KEY,
    customer_name VARCHAR2(100) NOT NULL,
    dob DATE NOT NULL,
    membership_status VARCHAR2(10) DEFAULT 'GUEST' NOT NULL
        CHECK (membership_status IN ('GUEST', 'MEMBER')),
    email VARCHAR2(255) NOT NULL UNIQUE,
    total_lifetime_spend NUMBER(10,2) DEFAULT 0 NOT NULL
        CHECK (total_lifetime_spend >= 0)
);

CREATE TABLE Spring26_S008_T7_Employee (
    employee_id NUMBER PRIMARY KEY,
    employee_name VARCHAR2(100) NOT NULL,
    hourly_rate NUMBER(7,2) NOT NULL CHECK (hourly_rate > 0)
);

CREATE TABLE Spring26_S008_T7_Game (
    game_id NUMBER PRIMARY KEY,
    game_name VARCHAR2(100) NOT NULL UNIQUE,
    genre VARCHAR2(40) NOT NULL,
    age_rating VARCHAR2(10) NOT NULL
        CHECK (age_rating IN ('E', 'E10+', 'T', 'M', 'AO')),
    competitive_status VARCHAR2(15) NOT NULL
        CHECK (competitive_status IN ('CASUAL', 'COMPETITIVE', 'BOTH')),
    multiplayer_capacity NUMBER(3) NOT NULL CHECK (multiplayer_capacity > 0),
    game_rating NUMBER(3,1) NOT NULL CHECK (game_rating BETWEEN 0 AND 10)
);

CREATE TABLE Spring26_S008_T7_CustPhone (
    customer_id NUMBER NOT NULL,
    phone_number VARCHAR2(20) NOT NULL,
    PRIMARY KEY (customer_id, phone_number),
    FOREIGN KEY (customer_id)
        REFERENCES Spring26_S008_T7_Customer(customer_id)
        ON DELETE CASCADE
);

CREATE TABLE Spring26_S008_T7_ZipCode (
    zip_code VARCHAR2(10) PRIMARY KEY,
    city VARCHAR2(50) NOT NULL,
    state_code VARCHAR2(2) NOT NULL
);

CREATE TABLE Spring26_S008_T7_Member (
    customer_id NUMBER PRIMARY KEY,
    join_date DATE NOT NULL,
    street VARCHAR2(100) NOT NULL,
    zip_code VARCHAR2(10) NOT NULL,
    FOREIGN KEY (customer_id)
        REFERENCES Spring26_S008_T7_Customer(customer_id)
        ON DELETE CASCADE,
    FOREIGN KEY (zip_code)
        REFERENCES Spring26_S008_T7_ZipCode(zip_code)
);

CREATE TABLE Spring26_S008_T7_EmpPhone (
    employee_id NUMBER NOT NULL,
    phone_number VARCHAR2(20) NOT NULL,
    PRIMARY KEY (employee_id, phone_number),
    FOREIGN KEY (employee_id)
        REFERENCES Spring26_S008_T7_Employee(employee_id)
        ON DELETE CASCADE
);

CREATE TABLE Spring26_S008_T7_EmpEmail (
    employee_id NUMBER NOT NULL,
    email_address VARCHAR2(255) NOT NULL,
    PRIMARY KEY (employee_id, email_address),
    UNIQUE (email_address),
    FOREIGN KEY (employee_id)
        REFERENCES Spring26_S008_T7_Employee(employee_id)
        ON DELETE CASCADE
);

CREATE TABLE Spring26_S008_T7_ShiftSlot (
    shift_id NUMBER PRIMARY KEY,
    employee_id NUMBER NOT NULL,
    shift_start TIMESTAMP NOT NULL,
    shift_end TIMESTAMP NOT NULL,
    CHECK (shift_end > shift_start),
    FOREIGN KEY (employee_id)
        REFERENCES Spring26_S008_T7_Employee(employee_id)
);

CREATE TABLE Spring26_S008_T7_Station (
    station_id NUMBER PRIMARY KEY,
    station_label VARCHAR2(50) NOT NULL UNIQUE,
    station_type_code VARCHAR2(20) NOT NULL,
    room_name VARCHAR2(50),
    current_status VARCHAR2(12) DEFAULT 'AVAILABLE' NOT NULL
        CHECK (current_status IN ('AVAILABLE', 'OCCUPIED', 'MAINTENANCE')),
    hourly_rate NUMBER(6,2) NOT NULL CHECK (hourly_rate > 0),
    max_capacity NUMBER(3) NOT NULL CHECK (max_capacity > 0),
    FOREIGN KEY (station_type_code)
        REFERENCES Spring26_S008_T7_StationType(station_type_code)
);

CREATE TABLE Spring26_S008_T7_GameSupport (
    game_id NUMBER NOT NULL,
    station_type_code VARCHAR2(20) NOT NULL,
    PRIMARY KEY (game_id, station_type_code),
    FOREIGN KEY (game_id)
        REFERENCES Spring26_S008_T7_Game(game_id)
        ON DELETE CASCADE,
    FOREIGN KEY (station_type_code)
        REFERENCES Spring26_S008_T7_StationType(station_type_code)
);

CREATE TABLE Spring26_S008_T7_Booking (
    booking_id NUMBER PRIMARY KEY,
    customer_id NUMBER NOT NULL,
    station_id NUMBER NOT NULL,
    game_id NUMBER NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    booking_status VARCHAR2(10) DEFAULT 'COMPLETED' NOT NULL
        CHECK (booking_status IN ('ACTIVE', 'COMPLETED', 'CANCELLED')),
    CHECK (end_time > start_time),
    FOREIGN KEY (customer_id)
        REFERENCES Spring26_S008_T7_Customer(customer_id),
    FOREIGN KEY (station_id)
        REFERENCES Spring26_S008_T7_Station(station_id),
    FOREIGN KEY (game_id)
        REFERENCES Spring26_S008_T7_Game(game_id)
);

CREATE TABLE Spring26_S008_T7_Manages (
    booking_id NUMBER NOT NULL,
    employee_id NUMBER NOT NULL,
    PRIMARY KEY (booking_id, employee_id),
    FOREIGN KEY (booking_id)
        REFERENCES Spring26_S008_T7_Booking(booking_id)
        ON DELETE CASCADE,
    FOREIGN KEY (employee_id)
        REFERENCES Spring26_S008_T7_Employee(employee_id)
        ON DELETE CASCADE
);

CREATE OR REPLACE TRIGGER S26S008T7_member_chk
BEFORE INSERT OR UPDATE ON Spring26_S008_T7_Member
FOR EACH ROW
DECLARE
    v_booking_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_booking_count
    FROM Spring26_S008_T7_Booking
    WHERE customer_id = :NEW.customer_id
      AND booking_status <> 'CANCELLED';

    IF v_booking_count = 0 THEN
        RAISE_APPLICATION_ERROR(
            -20001,
            'A customer must have at least one booking before becoming a member.'
        );
    END IF;
END;
/

CREATE OR REPLACE TRIGGER S26S008T7_member_sync
AFTER INSERT OR DELETE ON Spring26_S008_T7_Member
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        UPDATE Spring26_S008_T7_Customer
        SET membership_status = 'MEMBER'
        WHERE customer_id = :NEW.customer_id;
    ELSIF DELETING THEN
        UPDATE Spring26_S008_T7_Customer
        SET membership_status = 'GUEST'
        WHERE customer_id = :OLD.customer_id;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER S26S008T7_booking_chk
BEFORE INSERT OR UPDATE ON Spring26_S008_T7_Booking
FOR EACH ROW
DECLARE
    v_station_type Spring26_S008_T7_Station.station_type_code%TYPE;
    v_supported NUMBER;
BEGIN
    SELECT station_type_code
    INTO v_station_type
    FROM Spring26_S008_T7_Station
    WHERE station_id = :NEW.station_id;

    SELECT COUNT(*)
    INTO v_supported
    FROM Spring26_S008_T7_GameSupport
    WHERE game_id = :NEW.game_id
      AND station_type_code = v_station_type;

    IF v_supported = 0 THEN
        RAISE_APPLICATION_ERROR(
            -20002,
            'The selected game is not supported on the chosen station type.'
        );
    END IF;
END;
/

PROMPT Schema creation complete.
