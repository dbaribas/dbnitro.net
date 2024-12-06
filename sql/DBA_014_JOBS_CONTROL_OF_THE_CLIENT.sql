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
prompt # JOBS CONTROL OF THE CLIENT
prompt ##############################################################
col COMMENTS for a90
col JOB_NAME for a40
col RUN_COUNT for a10
col owner for a10
col state for a12
col SCHEDULE_TYPE for a16
col LAST_EXEC for a20
col enabled for a8
select JOB_NAME
 , STATE
 , ENABLED
 , PROGRAM_OWNER as OWNER
 , SCHEDULE_TYPE
 , to_char(RUN_COUNT) as RUN_COUNT
 , to_char(LAST_START_DATE, 'yyyy-mm-dd HH:MM:SS') as LAST_EXEC
 , substr(COMMENTS,1,90) as COMMENTS
FROM DBA_SCHEDULER_JOBS
ORDER BY 1,2,3,4,5,6,7;
prompt
prompt ##############################################################
prompt # Show All Submited RDBMS Jobs
prompt ##############################################################
col proc format a50    heading 'Proc'
col job  format 99999  heading 'job#'
col subu format a10    heading 'Submiter' trunc
col lsd  format a10    heading 'Last|OK|Date'
col lst  format a5     heading 'Last|OK|Time'
col nrd  format a10    heading 'Next|Run|Date'
col nrt  format a5     heading 'Next|Run|Time'
col fail format 999    heading 'Errors'
col ok   format a2     heading 'OK'
select job
  , log_user as subu
  , what as proc
  , to_char(last_date,'MM/DD/YYYY') as lsd
  , substr(last_sec,1,5) as lst
  , to_char(next_date,'MM/DD/YYYY') as nrd
  , substr(next_sec,1,5) as nrt
  , failures as fail
  , decode(broken,'Y','N','Y') ok
from sys.dba_jobs;