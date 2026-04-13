SET DEFINE OFF;
SET SERVEROUTPUT ON;
SET ECHO ON;

PROMPT ==========================================
PROMPT Team 7 Demo Run Starting
PROMPT ==========================================

@"/Users/abhi/Desktop/DBMS Gaming Hub Project/Phase4/projectDBdrop.sql"
@"/Users/abhi/Desktop/DBMS Gaming Hub Project/Phase4/projectDBcreate.sql"
@"/Users/abhi/Desktop/DBMS Gaming Hub Project/Phase4/projectDBinsert.sql"

PROMPT ==========================================
PROMPT Running queries before updates
PROMPT ==========================================
@"/Users/abhi/Desktop/DBMS Gaming Hub Project/Phase4/projectDBqueries.sql"

@"/Users/abhi/Desktop/DBMS Gaming Hub Project/Phase4/projectDBupdate.sql"

PROMPT ==========================================
PROMPT Running queries after updates
PROMPT ==========================================
@"/Users/abhi/Desktop/DBMS Gaming Hub Project/Phase4/projectDBqueries.sql"

PROMPT ==========================================
PROMPT Team 7 Demo Run Complete
PROMPT ==========================================
