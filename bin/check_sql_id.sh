#!/bin/sh
Author="Andre Augusto Ribas"
SoftwareVersion="1.0.1"
DateCreation="14/02/2025"
DateModification="17/02/2025"
EMAIL="ribas@dbnitro.net"
GITHUB="https://github.com/dbaribas/dbnitro.net"
WEBSITE="http://dbnitro.net"
#
if [[ ${1} == "" ]]; then
  echo " -- Option 1 is empty, you must to specify the SQL ID here --"
  exit 1
else
sqlplus / as sysdba <<EOF

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ------------------------------------------------------------------------------------------------------------------------
prompt -- Create Tuning Task:
DECLARE my_task_name VARCHAR2(30);
BEGIN my_task_name := DBMS_SQLTUNE.CREATE_TUNING_TASK(sql_id => '${1}'
  , scope       => 'COMPREHENSIVE'
  , time_limit  => 3600
  , task_name   => 'Ribas_SQL_Tuning_Task'
  , description => 'Tune query using sqlid');
end;
/


prompt ------------------------------------------------------------------------------------------------------------------------
prompt -- Execute Tuning task:
BEGIN DBMS_SQLTUNE.EXECUTE_TUNING_TASK(task_name => 'Ribas_SQL_Tuning_Task');
end;
/


prompt ------------------------------------------------------------------------------------------------------------------------
prompt -- Monitor the task executing using below query:
SELECT TASK_NAME, STATUS FROM DBA_ADVISOR_LOG WHERE TASK_NAME = 'Ribas_SQL_Tuning_Task';


prompt ------------------------------------------------------------------------------------------------------------------------
prompt -- To get detailed information:
SELECT DBMS_SQLTUNE.REPORT_TUNING_TASK('Ribas_SQL_Tuning_Task', 'TEXT', 'ALL', 'ALL') FROM DUAL;


prompt ------------------------------------------------------------------------------------------------------------------------
prompt -- Check the status is completed for the task and we can get recommendations of the advisor.
prompt -- Report Tuning task:
SELECT DBMS_SQLTUNE.REPORT_TUNING_TASK('Ribas_SQL_Tuning_Task') from DUAL;


prompt ------------------------------------------------------------------------------------------------------------------------
prompt -- Execute Task:
EXEC DBMS_SQLTUNE.execute_tuning_task(task_name => 'Ribas_SQL_Tuning_Task');


prompt ------------------------------------------------------------------------------------------------------------------------
prompt -- Report task:
SET LONG 10000 PAGESIZE 1000 LINESIZE 250
SELECT DBMS_SQLTUNE.REPORT_TUNING_TASK('Ribas_SQL_Tuning_Task') AS recommendations FROM dual;


prompt ------------------------------------------------------------------------------------------------------------------------
prompt -- Interrupt Tuning task:
EXEC DBMS_SQLTUNE.interrupt_tuning_task (task_name => 'Ribas_SQL_Tuning_Task');


prompt ------------------------------------------------------------------------------------------------------------------------
prompt -- Resume Tuning task:
EXEC DBMS_SQLTUNE.resume_tuning_task (task_name => 'Ribas_SQL_Tuning_Task');


prompt ------------------------------------------------------------------------------------------------------------------------
prompt -- Cancel Tuning task:
EXEC DBMS_SQLTUNE.cancel_tuning_task (task_name => 'Ribas_SQL_Tuning_Task');


prompt ------------------------------------------------------------------------------------------------------------------------
prompt -- Reset Tuning task:
EXEC DBMS_SQLTUNE.reset_tuning_task (task_name => 'Ribas_SQL_Tuning_Task');


prompt ------------------------------------------------------------------------------------------------------------------------
prompt -- Drop SQL Tuning task:
BEGIN DBMS_SQLTUNE.drop_tuning_task (task_name => 'Ribas_SQL_Tuning_Task');
END;
/

quit;

EOF
fi









prompt Check the PLAN_HASH_VALUE got changed for the specific statement and get SNAP_ID to create a tuning task.
set lines 155
col execs for 999,999,999
col avg_etime for 999,999.999
col avg_lio for 999,999,999.9
col begin_interval_time for a30
col node for 99999
break on plan_hash_value on startup_time skip 1
select ss.snap_id
  , ss.instance_number node
  , begin_interval_time
  , sql_id
  , plan_hash_value
  , nvl(executions_delta,0) execs
  , (elapsed_time_delta/decode(nvl(executions_delta,0),0,1,executions_delta))/1000000 avg_etime
  , (buffer_gets_delta/decode(nvl(buffer_gets_delta,0),0,1,executions_delta)) avg_lio
from DBA_HIST_SQLSTAT S
  , DBA_HIST_SNAPSHOT SS
where sql_id = '4kn7c0vxqant7'
and ss.snap_id = S.snap_id
and ss.instance_number = S.instance_number 
and executions_delta > 0
order by 1, 2, 3
/


Enter value for sql_id: 4kn7c0vxqant7

SNAP_ID NODE BEGIN_INTERVAL_TIME SQL_ID PLAN_HASH_VALUE EXECS AVG_ETIME AVG_LIO
---------- ------ ------------------------------ ------------- --------
15694 1 10-NOV-18 01.00.04.047 AM 483wz173punyb 2391860790 1 4,586.818 33,924,912.0
15695 1 10-NOV-18 02.00.18.928 AM 483wz173punyb 2 1,488.867 0,064,449.0
15696 1 10-NOV-18 03.00.03.192 AM 483wz173punyb 2 1,053.459 8,780,977.0


prompt Create a tuning task for the specific statement from AWR snapshots:-
prompt Create, Execute and Report the task from given AWR snapshot IDs.
prompt Create Task:

DECLARE l_sql_tune_task_id VARCHAR2(100);
BEGIN l_sql_tune_task_id := DBMS_SQLTUNE.create_tuning_task (sql_id => '4kn7c0vxqant7'
  -- , begin_snap => 1868
  -- , end_snap => 1894
  , scope => DBMS_SQLTUNE.scope_comprehensive
  , time_limit => 300
  , task_name => '483wz173punyb_tuning_task'
  , description => 'Tuning task for statement 4kn7c0vxqant7 in AWR.');
DBMS_OUTPUT.put_line('l_sql_tune_task_id: ' || l_sql_tune_task_id);
END;
/

prompt Execute Task:
EXEC DBMS_SQLTUNE.execute_tuning_task(task_name => '483wz173punyb_tuning_task');

prompt Report task:
SET LONG 10000 PAGESIZE 1000 LINESIZE 200
SELECT DBMS_SQLTUNE.report_tuning_task('483wz173punyb_tuning_task') AS recommendations FROM dual;

prompt Interrupt Tuning task:
EXEC DBMS_SQLTUNE.interrupt_tuning_task (task_name => '483wz173punyb_tuning_task');

prompt Resume Tuning task:
EXEC DBMS_SQLTUNE.resume_tuning_task (task_name => '483wz173punyb_tuning_task');

prompt Cancel Tuning task:
EXEC DBMS_SQLTUNE.cancel_tuning_task (task_name => '483wz173punyb_tuning_task');

prompt Reset Tuning task:
EXEC DBMS_SQLTUNE.reset_tuning_task (task_name => '483wz173punyb_tuning_task');





















prompt Below are the steps to execute the Tuning Advisory

prompt STEP 1: Create tuning task for the specific SQL_ID:

declare task_nm varchar2(100);
  begin task_nm := dbms_sqltune.create_tuning_task(SQL_ID=> '&SQL_ID', TASK_NAME => 'SQL_TUNNING_TASK_SQL_ID');
end;
/

prompt NOTE: Replace sql_id in above statement
prompt STEP 2: Check the status of newly created task:
SELECT task_name, status FROM dba_advisor_log WHERE task_name = '&TASK_NAME';


STEP 3: Execute the newly created task:
exec dbms_sqltune.execute_tuning_task (TASK_NAME => '&TASK_NAME');


prompt Note: Please replace the task name as mentioned in step 1
prompt STEP 4: Check the status after executing the task:
SELECT task_name, status FROM dba_advisor_log WHERE task_name = '&TASK_NAME';


STEP 5: Execute the Below Query to get the Advisory Report:
SET LONG 10000 PAGESIZE 1000 LINESIZE 200
SELECT DBMS_SQLTUNE.report_tuning_task('&TASK_NAME') AS recommendations FROM dual;


####
BEGIN dbms_sqltune.create_sql_plan_baseline(task_name => 'SQL_TUNNING_TASK_SQL_ID', owner_name => 'SYS', plan_hash_value => 1715801588);
END;
/
####


prompt NOTE: Replace task name in above query
prompt STEP 6: To Drop the Tuning Task:
execute dbms_sqltune.drop_tuning_task('&TASK_NAME');
prompt To execute tuning advisory using AWR snap ID if sql_id is not present in cursor:


prompt STEP 7: Find the snap ID using below query:
select SQL_ID, PLAN_HASH_VALUE, TIMESTAMP FROM DBA_HIST_SQL_PLAN WHERE SQL_ID='&SQL_ID';
prompt
select snap_id, sql_id, plan_hash_value from dba_hist_sqlstat where sql_id='&SQL_ID' and plan_hash_value='&plan_hash_value' order by snap_id desc;


prompt STEP 8: Create Tuning Task:
DECLARE l_sql_tune_task_id  VARCHAR2(100);
BEGIN l_sql_tune_task_id := DBMS_SQLTUNE.create_tuning_task (sql_id => '4kn7c0vxqant7'
  -- , begin_snap  => 345
  -- , end_snap    => 349
  , scope       => DBMS_SQLTUNE.scope_comprehensive
  , time_limit  => 600
  , task_name   => '4kn7c0vxqant7_AWR_tuning_task'
  , description => 'Tuning task for statement 4kn7c0vxqant7 in AWR');
  DBMS_OUTPUT.put_line('l_sql_tune_task_id: ' || l_sql_tune_task_id);
END;
/

prompt NOTE: Replace the above highlighted values:
prompt STEP 9: After creation of tuning task you can follow the above steps from 2-9.











DECLARE l_plans_loaded  PLS_INTEGER;
  BEGIN l_plans_loaded := DBMS_SPM.load_plans_from_cursor_cache(sql_id => '&sql_id');
END;
/

-- Create baseline with a particular hash value

DECLARE l_plans_loaded  PLS_INTEGER;
  BEGIN l_plans_loaded := DBMS_SPM.load_plans_from_cursor_cache(sql_id => '&sql_id', plan_hash_value => '&plan_hash_value');
END;
/