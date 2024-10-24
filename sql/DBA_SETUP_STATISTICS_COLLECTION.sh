-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 10/04/2024
-- DateModification.: 10/04/2024
-- EMAIL_1..........: dba.ribas@gmail.com
-- EMAIL_2..........: andre.ribas@icloud.com
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'

col object_name for a30
col object_type for a20
col owner for a20
col job_name for a30
col program_name for a40
col last_start_date for a30
col next_run_date for a30
col log_date for a20
col actual_start_date for a20
col CLIENT_NAME for a40
COL REPEAT_INTERVAL FOR A72
COL ENABLED FOR A10
COL WINDOW_NAME FOR A20
COL WINDOW_DURATION FOR A35 
COL JOB_NAME FOR A30 
COL WINDOW_START_TIME FOR A20 
COL JOB_DURATION FOR A23
COL JOB_INFO FOR A2 
COL JOB_STATUS FOR A10
COL JOB_START_TIME FOR A20
COL CONSUMER_GROUP FOR A25
COL WINDOW_GROUP FOR A15 
COL STATUS FOR A7 
DEFINE ROWNUM = 50


prompt
prompt #######################################################################
prompt # ENABLE AUTO_TASKS_JOB_CLASS
prompt #######################################################################
DECLARE v_count NUMBER;
BEGIN 
  SELECT COUNT(*) INTO v_count FROM all_objects WHERE object_name = 'AUTO_TASKS_JOB_CLASS';
IF v_count = 0 THEN 
  DBMS_SCHEDULER.CREATE_JOB_CLASS(job_class_name => 'AUTO_TASKS_JOB_CLASS', resource_consumer_group => 'LOW_GROUP', service => 'SYS$BACKGROUND');
  DBMS_OUTPUT.PUT_LINE('Job Class Was Successfully Created.');
ELSE
  DBMS_OUTPUT.PUT_LINE('Job Class Already Exists.');
END IF;
END;
/


prompt
prompt #######################################################################
prompt # VERIFY IF THE AUTO_TASKS_JOB_CLASS IS ENABLE
prompt #######################################################################
SELECT CLIENT_NAME
  , STATUS
  , CONSUMER_GROUP
  , CLIENT_TAG
  , WINDOW_GROUP 
FROM DBA_AUTOTASK_CLIENT 
WHERE CLIENT_NAME = 'auto optimizer stats collection';


prompt #######################################################################
prompt # This task is divided in this steps: Create Programs, Create Jobs and Enable Jobs
prompt #######################################################################


prompt
prompt #######################################################################
prompt # GATHER STATS - Default
prompt #######################################################################


prompt
prompt #######################################################################
prompt # Create Default Program GATHER_STATS_PROG
prompt #######################################################################
BEGIN DBMS_SCHEDULER.CREATE_PROGRAM(
    program_name   => 'GATHER_STATS_PROG'
  , program_type   => 'PLSQL_BLOCK'
  , program_action => 'BEGIN DBMS_STATS.GATHER_DATABASE_STATS(estimate_percent => 33
  , block_sample        => FALSE
  , method_opt          => ''FOR ALL COLUMNS SIZE AUTO''
  , degree              => null
  , granularity         => ''ALL''
  , cascade             => TRUE
  , stattab             => null
  , statid              => null
  , options             => ''GATHER STALE''
  , statown             => null
  , gather_sys          => FALSE
  , no_invalidate       => FALSE
  , gather_temp         => TRUE
  , gather_fixed        => FALSE
  , stattype            => ''ALL'');
  END;'
  , number_of_arguments => 0
  , comments            => 'Ribas Automatic Optimizer Statistics Collection Program - Default'
  , enabled             => TRUE);
END;
/

prompt
prompt #######################################################################
prompt # CREATE Default JOB GATHER_STATS_PROG_JOB
prompt #######################################################################
BEGIN DBMS_SCHEDULER.CREATE_JOB(
    job_name        => 'GATHER_STATS_JOB'
  , program_name    => 'GATHER_STATS_PROG'
  , start_date      =>  SYSTIMESTAMP
  , comments        => 'Ribas Automatic Optimizer Statistics Collection Program - Default'
  , repeat_interval => 'FREQ=DAILY; BYHOUR=2; BYMINUTE=0; BYSECOND=0'
  , enabled         => TRUE);
END;
/

prompt
prompt #######################################################################
prompt # Enable Default Program
prompt #######################################################################
BEGIN DBMS_SCHEDULER.ENABLE('GATHER_STATS_PROG');
END;
/


prompt #######################################################################
prompt # GATHER STATS - CUSTOM
prompt #######################################################################


prompt
prompt #######################################################################
prompt # CREATE PROGRAM GATHER_STATS_STALE_CUSTOM
prompt #######################################################################
BEGIN DBMS_SCHEDULER.CREATE_PROGRAM(
    program_name        => 'GATHER_STATS_STALE_CUSTOM'
  , program_action      => 'BEGIN DBMS_STATS.GATHER_DATABASE_STATS(estimate_percent => 33
  , block_sample        => FALSE
  , method_opt          => ''FOR ALL INDEXED COLUMNS SIZE 254''
  , degree              => null
  , granularity         => ''ALL''
  , cascade             => TRUE
  , stattab             => null
  , statid              => null
  , options             => ''GATHER STALE''
  , statown             => null
  , gather_sys          => FALSE
  , no_invalidate       => FALSE
  , gather_temp         => TRUE
  , gather_fixed        => FALSE
  , stattype            => ''ALL''); 
END;'
  , program_type        => 'PLSQL_BLOCK'
  , number_of_arguments => 0
  , comments            => 'Ribas Custom Automatic Optimiser Statistics Collection Program - Stale'
  , enabled             => TRUE);
END;
/

prompt 
prompt #######################################################################
prompt # CREATE JOB GATHER_STATS_STALE_CUSTOM_JOB
prompt #######################################################################
BEGIN DBMS_SCHEDULER.CREATE_JOB(
      job_name       => 'GATHER_STATS_STALE_CUSTOM_JOB'
    , program_name   => 'GATHER_STATS_STALE_CUSTOM'
    , schedule_name  => 'WEEKNIGHT_WINDOW'
    , job_class      => 'AUTO_TASKS_JOB_CLASS'
    , comments       => 'Ribas Custom Automatic Optimiser Statistics Collection Program - Stale'
    , auto_drop      => FALSE
    , enabled        => TRUE);
  DBMS_SCHEDULER.SET_ATTRIBUTE(
      name           => 'GATHER_STATS_STALE_CUSTOM_JOB'
    , attribute      => 'stop_on_window_close'
    , value          => FALSE);
  DBMS_SCHEDULER.ENABLE('GATHER_STATS_STALE_CUSTOM_JOB');
END;
/


prompt
prompt #######################################################################
prompt # ENABLE PROGRAM GATHER_STATS_STALE_CUSTOM
prompt #######################################################################
BEGIN DBMS_SCHEDULER.ENABLE('GATHER_STATS_STALE_CUSTOM');
END;
/


prompt #######################################################################
prompt # GATHER STATS - FULL
prompt #######################################################################


prompt
prompt #######################################################################
prompt # CREATE PROGRAM GATHER_STATS_FULL_CUSTOM
prompt #######################################################################
BEGIN DBMS_SCHEDULER.CREATE_PROGRAM(
    program_name            => 'GATHER_STATS_FULL_CUSTOM'
  , program_action          => 'BEGIN DBMS_STATS.GATHER_DATABASE_STATS(estimate_percent => 33
  , block_sample            => FALSE
  , method_opt              => ''FOR ALL INDEXED COLUMNS SIZE 254''
  , degree                  => null
  , granularity             => ''ALL''
  , cascade                 => TRUE
  , stattab                 => null
  , statid                  => null
  , options                 => ''GATHER''
  , statown                 => null
  , gather_sys              => FALSE
  , no_invalidate           => FALSE
  , gather_temp             => TRUE
  , gather_fixed            => FALSE
  , stattype                => ''ALL'');
END;'
  , program_type            => 'PLSQL_BLOCK'
  , number_of_arguments     => 0
  , comments                => 'Ribas Custom Automatic Optimiser Statistics Collection Program - full'
  , enabled                 => TRUE);
END;
/

prompt
prompt #######################################################################
prompt # CREATE JOB GATHER_STATS_FULL_CUSTOM_JOB
prompt #######################################################################
BEGIN DBMS_SCHEDULER.CREATE_JOB(
      job_name      => 'GATHER_STATS_FULL_CUSTOM_JOB'
    , program_name  => 'GATHER_STATS_FULL_CUSTOM'
    , schedule_name => 'WEEKEND_WINDOW'
    , job_class     => 'AUTO_TASKS_JOB_CLASS'
    , comments      => 'Ribas Custom Automatic Optimiser Statistics Collection Program - full'
    , auto_drop     => FALSE
    , enabled       => FALSE);
  DBMS_SCHEDULER.SET_ATTRIBUTE(name => 'GATHER_STATS_FULL_CUSTOM_JOB'
    , attribute     => 'stop_on_window_close'
    , value         => FALSE);
  DBMS_SCHEDULER.ENABLE('GATHER_STATS_FULL_CUSTOM_JOB');
END;
/

prompt
prompt #######################################################################
prompt # ENABLE JOB GATHER_STATS_FULL_CUSTOM_JOB
prompt #######################################################################
BEGIN DBMS_SCHEDULER.ENABLE('GATHER_STATS_FULL_CUSTOM_JOB');
END;
/


prompt #######################################################################
prompt # ENABLE WEEKNIGHT AND WEEKEND WINDOW SCHEDULERS
prompt #######################################################################


prompt
prompt #######################################################################
prompt # Enable Weeknight Window Jobs
prompt #######################################################################
BEGIN DBMS_SCHEDULER.ENABLE('WEEKNIGHT_WINDOW');
END;
/

prompt
prompt #######################################################################
prompt # Enable Weekend Window Jobs
prompt #######################################################################
BEGIN DBMS_SCHEDULER.ENABLE('WEEKEND_WINDOW');
END;
/


prompt #######################################################################
prompt # VERIFY THE STATUS OF STATISTICS JOBS
prompt #######################################################################


prompt
prompt #######################################################################
prompt # PROGRAM STATISTICS COLLECTION - STANDARD, STALE and FULL CUSTOM
prompt #######################################################################
SELECT owner
  , program_name
  , enabled
FROM DBA_SCHEDULER_PROGRAMS 
WHERE program_name in ('GATHER_STATS_PROG','GATHER_STATS_STALE_CUSTOM','GATHER_STATS_FULL_CUSTOM') 
order by 1,2,3;

prompt
prompt #######################################################################
prompt # SCHEDULER JOB STATISTICS COLLECTION - STANDARD, STALE and FULL
prompt #######################################################################
SELECT owner
  , job_name
  , state
  , run_count
  , to_char(last_start_date, 'YYYY-MM-DD HH24:MI:SS') as last_start_date
  , to_char(next_run_date, 'YYYY-MM-DD HH24:MI:SS') as next_run_date 
FROM DBA_SCHEDULER_JOBS 
WHERE job_name in ('GATHER_STATS_JOB','GATHER_STATS_STALE_CUSTOM_JOB','GATHER_STATS_FULL_CUSTOM_JOB') 
order by 1,2,3;

prompt
prompt #######################################################################
prompt # SCHEDULER JOB STATISTICS COLLECTION - STANDARD, STALE and FULL - DETAILS I
prompt #######################################################################
SELECT owner
  , job_name
  , to_char(log_date, 'YYYY-MM-DD HH24:MI:SS') as log_date
  , status
  , to_char(actual_start_date, 'YYYY-MM-DD HH24:MI:SS') as actual_start_date 
FROM DBA_SCHEDULER_JOB_RUN_DETAILS 
WHERE job_name in ('GATHER_STATS_JOB','GATHER_STATS_STALE_CUSTOM_JOB','GATHER_STATS_FULL_CUSTOM_JOB') 
order by 1,2,3;

prompt
prompt #######################################################################
prompt # SCHEDULER JOB STATISTICS WINDOW DURATION
prompt #######################################################################
SELECT WINDOW_NAME
  , REPEAT_INTERVAL
  , TO_CHAR(EXTRACT(DAY FROM DURATION),'90') || ' Days ' || TO_CHAR(EXTRACT(HOUR FROM DURATION),'90') || ' Hours ' || TO_CHAR(EXTRACT(MINUTE FROM DURATION),'90') || ' Minutes ' WINDOW_DURATION
  , ENABLED
FROM DBA_SCHEDULER_WINDOWS
order by 1,2,3;

prompt
prompt #######################################################################
prompt # AUTOTASL Jobs History
prompt #######################################################################
SELECT * FROM (SELECT JOB_NAME
                 , CLIENT_NAME
                 , WINDOW_NAME
                 , TO_CHAR(WINDOW_START_TIME,'YYYY-MM-DD HH24:MI:SS') WINDOW_START_TIME
                 , TO_CHAR(EXTRACT(DAY FROM WINDOW_DURATION),'00') || ' Days ' || TO_CHAR(EXTRACT(HOUR FROM WINDOW_DURATION),'00') || ' Hours ' || TO_CHAR(EXTRACT(MINUTE FROM WINDOW_DURATION),'00') || ' Minutes ' WINDOW_DURATION
                 , JOB_STATUS
                 , TO_CHAR(JOB_START_TIME,'YYYY-MM-DD HH24:MI:SS') JOB_START_TIME
                 , TO_CHAR(EXTRACT(DAY FROM JOB_DURATION),'90') || ' D' || TO_CHAR(EXTRACT(HOUR FROM JOB_DURATION),'90') || ' H' || TO_CHAR(EXTRACT(MINUTE FROM JOB_DURATION),'90') || ' M' || TO_CHAR(EXTRACT(SECOND FROM JOB_DURATION),'90') || ' S' JOB_DURATION
                 , JOB_ERROR 
              FROM DBA_AUTOTASK_JOB_HISTORY 
              -- WHERE CLIENT_NAME='auto optimizer stats collection' 
              ORDER BY JOB_START_TIME DESC) 
WHERE ROWNUM < '&ROWNUM'
order by 1,2,3;

