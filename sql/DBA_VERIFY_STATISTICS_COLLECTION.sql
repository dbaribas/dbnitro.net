-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 10/04/2024
-- DateModification.: 10/04/2024
-- EMAIL_1..........: dba.ribas@gmail.com
-- EMAIL_2..........: andre.ribas@icloud.com
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ########################################################
prompt # Check Statistics Collection - Standard, Stale and Full
prompt ########################################################
col owner for a20
col job_name for a30
col program_name for a40
col last_start_date for a30
col next_run_date for a30
col log_date for a20
col actual_start_date for a20
COL REPEAT_INTERVAL FOR A72
COL ENABLED FOR A10
COL STATUS FOR A14
COL WINDOW_NAME FOR A20
COL WINDOW_DURATION FOR A35
COL JOB_NAME FOR A30
COL WINDOW_START_TIME FOR A20
COL JOB_DURATION FOR A23
COL JOB_INFO FOR A2
COL JOB_STATUS FOR A10
COL JOB_START_TIME FOR A20
SELECT owner
  , job_name
  , TO_CHAR(actual_start_date, 'YYYY-MM-DD hh24:mi:ss') as actual_start_date
  , status
  , error#
FROM DBA_SCHEDULER_JOB_RUN_DETAILS
WHERE job_name in ('GATHER_STATS_JOB','GATHER_STATS_STALE_CUSTOM_JOB','GATHER_STATS_FULL_CUSTOM_JOB')
AND actual_start_date >= SYSTIMESTAMP - INTERVAL '7' DAY
ORDER BY owner, job_name, actual_start_date;