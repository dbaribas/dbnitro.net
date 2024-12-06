-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set feedback off timing off
alter session set nls_date_format='yyyy-mm-dd';
set pages 1000 lines 1000 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|' LONG 1000000 LONGCHUNKSIZE 100000 SERVEROUTPUT ON
prompt ##############################################################
prompt # DBA: START AN ADVISOR TASK
prompt ##############################################################
DECLARE
  v_tname   VARCHAR2(128) := 'TEST_TASK_DBNITRO';
  v_ename   VARCHAR2(128) := NULL;
  v_report  CLOB := NULL;
  v_script  CLOB := NULL;
BEGIN
  v_tname  := DBMS_STATS.CREATE_ADVISOR_TASK(v_tname);
  v_ename  := DBMS_STATS.EXECUTE_ADVISOR_TASK(v_tname);
  v_report := DBMS_STATS.REPORT_ADVISOR_TASK(v_tname);
  DBMS_OUTPUT.PUT_LINE(v_report);
END;
/