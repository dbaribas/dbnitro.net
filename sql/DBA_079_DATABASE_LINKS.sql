-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set feedback off timing off
alter session set nls_date_format='yyyy-mm-dd';
set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # DATABASE LINKS                                             #
prompt ##############################################################
set long 1000 serveroutput on verify off lines 700
DECLARE
   v_output CLOB := NULL;
BEGIN
   DBMS_OUTPUT.put_line ('DDL For Database Links');
   FOR tt IN (select owner, db_link FROM dba_db_links)
   LOOP
      select DBMS_METADATA.get_ddl ('DB_LINK', tt.db_link, tt.owner) INTO v_output FROM DUAL;
      DBMS_OUTPUT.put_line (v_output);
   END LOOP;
END;
/
prompt
set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
col owner for a15
col db_link for a30
col username for a15
col host for a100
select * from dba_db_links order by 1,2,3;
prompt
prompt ##############################################################
prompt # Verify Wich DB LINK are Opened                             #
prompt ##############################################################
COL DBA_LINK FORMAT A25 
COL OWNER_ID FORMAT 99999 HEADING "OWNID" 
COL LOGGED_ON FORMAT A5 HEADING "LOGON" 
COL HETEROGENEOUS FORMAT A5 HEADING "HETER" 
COL PROTOCOL FORMAT A8 
COL OPEN_CURSORS FORMAT 999 HEADING "OPN_CUR" 
COL IN_TRANSACTION FORMAT A3 HEADING "TXN" 
COL UPDATE_SENT FORMAT A6 HEADING "UPDATE" 
COL COMMIT_POINT_STRENGTH FORMAT 99999 HEADING "C_P_S" 
select * from v$DBLINK;