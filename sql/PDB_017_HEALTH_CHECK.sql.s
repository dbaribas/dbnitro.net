-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL_1..........: dba.ribas@gmail.com
-- EMAIL_2..........: andre.ribas@icloud.com
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # 1. Check Database Status for CDB and PDBs
prompt ##############################################################
-- Status for both CDB and PDBs
col name for a25
SELECT NAME, OPEN_MODE, DATABASE_ROLE FROM V$DATABASE;
prompt # List of PDBs
SELECT CON_ID, NAME, OPEN_MODE FROM V$PDBS;

prompt ##############################################################
prompt # 2. Check Invalid Objects in CDB and PDBs
prompt ##############################################################
-- Invalid objects in CDB and PDBs
col owner for a20
col object_name for a40
SELECT CON_ID, OWNER, OBJECT_NAME, OBJECT_TYPE, STATUS FROM CDB_OBJECTS WHERE STATUS = 'INVALID' order by 1,2,3;

prompt ##############################################################
prompt # 3. Check Tablespace Usage for CDB and PDBs
prompt ##############################################################
prompt # CDB Tablespace Usage
SELECT TABLESPACE_NAME, TABLESPACE_SIZE,USED_PERCENT FROM  DBA_TABLESPACE_USAGE_METRICS;
prompt # PDB Tablespace Usage
SELECT CON_ID, TABLESPACE_NAME, USED_SPACE, TABLESPACE_SIZE, USED_PERCENT FROM CDB_TABLESPACE_USAGE_METRICS;

prompt ##############################################################
prompt # 4. Check Datafile Usage for CDB and PDBs
prompt ##############################################################
prompt # CDB Datafile usage
SELECT FILE_NAME, TABLESPACE_NAME, BYTES, MAXBYTES FROM DBA_DATA_FILES;
prompt # PDB Datafile usage
SELECT CON_ID, FILE_NAME, TABLESPACE_NAME, BYTES, MAXBYTES FROM CDB_DATA_FILES;

prompt ##############################################################
prompt # 5. Check Alerts/Errors in Alert Logs
prompt ##############################################################
-- Example OS command to view the alert log
-- tail -500 /u01/app/oracle/diag/rdbms/cdb1/CDB1/trace/alert_CDB1.log
-- tail -500 /u01/app/oracle/diag/rdbms/cdb1/PDB1/trace/alert_PDB1.log

prompt ##############################################################
prompt # 6. Check Active Sessions in CDB and PDBs
prompt ##############################################################
prompt # Active sessions in CDB
SELECT SID, SERIAL#, USERNAME, STATUS, MACHINE, PROGRAM FROM V$SESSION WHERE STATUS = 'ACTIVE';
-- prompt # 
-- SELECT CON_ID, SID, USERNAME, STATUS from CDB_WORKDSPACE_SESSIONS;

prompt ##############################################################
prompt # 7. Check Long-Running Queries in CDB and PDBs
prompt ##############################################################
prompt # Long-running queries in PDBs
-- SELECT SQL_ID, SQL_TEXT, CON_ID FROM CDB_HIST_SQLTEXT B;

prompt ##############################################################
prompt # 8. Check Redo Log Status for CDB and PDBs
prompt ##############################################################
prompt # CDB Redo log status
col member for a60
SELECT GROUP#, STATUS, MEMBER FROM V$LOGFILE;
prompt # PDB Redo log (through CDB view)
prompt # PDB not have seperate redo log files

prompt ##############################################################
prompt # 9. Check Backup Status
prompt ##############################################################
prompt # Check recent backups for CDB
SELECT SESSION_KEY, INPUT_TYPE, STATUS, START_TIME, END_TIME FROM V$RMAN_BACKUP_JOB_DETAILS  ORDER BY START_TIME DESC;

-- For PDBs, if managed independently, switch to the PDB context
-- ALTER SESSION SET CONTAINER = pdb_name;
SELECT * FROM V$RMAN_BACKUP_JOB_DETAILS;

prompt ##############################################################
prompt # 10. Check ASM Disk Group Usage (If using ASM)
prompt ##############################################################
prompt # Check space usage in ASM disk groups
SELECT NAME, TOTAL_MB, FREE_MB FROM V$ASM_DISKGROUP;

prompt ##############################################################
prompt # 11. Check Flashback Status
prompt ##############################################################
prompt # Check if Flashback is enabled for the CDB
SELECT FLASHBACK_ON FROM V$DATABASE;
-- prompt # For individual PDBs
-- SELECT NAME, FLASHBACK_ON FROM V$PDBS;

prompt ##############################################################
prompt # 12. Check all PDB tables
prompt ##############################################################
select * from CDB_ALL_TABLES;

prompt ##############################################################
prompt # 13. Check the auto task jobs:
prompt ##############################################################
select * from CDB_AUTOTASK_TASK;
