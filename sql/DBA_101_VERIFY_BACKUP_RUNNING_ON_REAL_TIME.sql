-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set feedback off timing off
alter session set nls_date_format='yyyy-mm-dd';
set pages 700 lines 1000 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # VERIFY BACKUP RUNNING ON REAL TIME
prompt ##############################################################
COL MESSAGE FORMAT A100
COL FILENAME FORMAT A100
SELECT SID
  , SERIAL#
  , START_TIME
  , ((SOFAR/TOTALWORK)*100) as TOTAL_WORKED
  , '%' as PERC
  , TIME_REMAINING
  , MESSAGE 
FROM V$SESSION_LONGOPS 
where TIME_REMAINING > 0 
ORDER BY TIME_REMAINING;
prompt
prompt ##############################################################
prompt
prompt ##############################################################
SELECT FILENAME
  , BYTES/1024/1024/1024
FROM GV$BACKUP_ASYNC_IO 
WHERE STATUS='IN PROGRESS';
prompt
prompt ##############################################################
prompt
prompt ##############################################################
SELECT INPUT_TYPE
  , TO_CHAR(START_TIME, 'yyyy-mm-dd, HH24:MI:SS') as STARTED
  , TO_CHAR(END_TIME, 'yyyy-mm-dd, HH24:MI:SS') as FINISHED
  , STATUS 
FROM V$RMAN_BACKUP_JOB_DETAILS 
ORDER BY START_TIME;