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
clear col bre comp
set pages 700 lines 700 long 9999999 numwidth 20 echo off verify off feedback off colsep '|'
col elapsed_time_in_sec format 9999.99
col first_load_time format a19
col last_load_time format a19
col SQL_FULLTEXT format a150
col child_number format 999 heading "CHLD|NUM"
col executions format 99999999 heading "EXECS"
col END_OF_FETCH_COUNT heading "FULL|EXECS"
col disk_reads heading "DISK|READS"
col buffer_gets heading "BUFFER|GETS"
col DIRECT_WRITES heading "DIRECT|WRITES"
col APPLICATION_WAIT_TIME heading "APP|WAIT|TIME"
col CONCURRENCY_WAIT_TIME heading "CONC|WAIT|TIME"
col CLUSTER_WAIT_TIME heading "CLUS|WAIT|TIME"
col USER_IO_WAIT_TIME heading "IO|WAIT|TIME"
col PLSQL_EXEC_TIME heading "PLSQL|EXEC|TIME"
col JAVA_EXEC_TIME heading "JAVA|EXEC|TIME"
col rows_processed format 999999999999 heading "ROWS|PROCESSED"
col optimizer_cost format 99999990 heading "COST"
col cpu_sec format 9999990.00 heading "CPU_TIME|SEC"
col elap_sec format 9999990.00 heading "ELAPSED|SEC"
col module format a50
col action format a50
col SHARABLE_MEM heading "SHARE|MEM"
col PERSISTENT_MEM heading "PERST|MEM"
col RUNTIME_MEM heading "RUN|MEM"
col LOADED_VERSIONS format 9999 heading "LOADED|VERS"
col KEPT_VERSIONS format 999 heading "KEPT|VERS"
col OPEN_VERSIONS format 999 heading "OPEN|VERS"
col loads format 9999
col INVALIDATIONS format 99999 heading "INVL"
col PARSE_CALLS format 99999999 heading "PARSE|CALLS"
col PARSING_USER_ID format 999999 heading "PARSING|USER|ID"
col PARSING_SCHEMA_ID format 999999 heading "PARSING|SCHEMA|ID"
prompt ##############################################################
prompt # CHECK MODULE AND ACTION                                    #
prompt ##############################################################
select child_number
  , MODULE
  , ACTION
  , PROGRAM_ID
  , PROGRAM_LINE#
from v$sql
-- where sql_id='${OPT}'
/
prompt
prompt ##############################################################
prompt # CHECK MEMORY                                               #
prompt ##############################################################
select child_number
  , SHARABLE_MEM
  , PERSISTENT_MEM
  , RUNTIME_MEM
  , LOADED_VERSIONS
  , KEPT_VERSIONS
  , OPEN_VERSIONS
  , LOADS
  , INVALIDATIONS
  , PARSE_CALLS
  , FIRST_LOAD_TIME
  , LAST_LOAD_TIME
  , PARSING_USER_ID
  , PARSING_SCHEMA_ID
from v$sql
-- where sql_id='${OPT}'
/
prompt
prompt ##############################################################
prompt # CHECK EXECS                                                #
prompt ##############################################################
select CHILD_NUMBER
  , EXECUTIONS
  , END_OF_FETCH_COUNT
  , DISK_READS
  , BUFFER_GETS
  , sorts
  , DIRECT_WRITES
  , FETCHES
  , ROWS_PROCESSED
  , OPTIMIZER_COST
from v$sql
-- where sql_id='${OPT}'
/
prompt
prompt ##############################################################
prompt # CHECK CPU TIME                                             #
prompt ##############################################################
select CHILD_NUMBER
  , round(cpu_time/1000000,2) CPU_SEC
  , round(elapsed_time/1000000,2) elap_sec
  , APPLICATION_WAIT_TIME
  , CONCURRENCY_WAIT_TIME
  , CLUSTER_WAIT_TIME
  , USER_IO_WAIT_TIME
  , PLSQL_EXEC_TIME
  , JAVA_EXEC_TIME
from v$sql
-- where sql_id='${OPT}'
/
prompt
prompt ##############################################################
prompt # CHECK SQL FULL TEXT OF STATEMENT                           #
prompt ##############################################################
select SQL_FULLTEXT
from v$sql;
-- where sql_id='${OPT}';
prompt
prompt ##############################################################
prompt # CHECK OBJECT LOB OF THE STATEMENT                          #
prompt ##############################################################
select distinct object_name LOB_NAME
from sys.x$kglob, dba_objects
where KGLNAOBJ like 'table%'
and object_id = to_number(regexp_substr(KGLNAOBJ, '[^_]+', 1, 4),'xxxx');
-- and kglobt03 = '${OPT}';
prompt
prompt ##############################################################
prompt # CHECK CPU COSTS OF THE STATEMENT                           #
prompt ##############################################################
select SQL_ID
  , PLAN_HASH_VALUE
  , sum(EXECUTIONS_DELTA) EXECUTIONS
  , sum(ROWS_PROCESSED_DELTA) CROWS
  , trunc(sum(CPU_TIME_DELTA)/1000000/60) CPU_MINS
  , trunc(sum(ELAPSED_TIME_DELTA)/1000000/60) ELA_MINS
from DBA_HIST_SQLSTAT
-- where SQL_ID in ('${OPT}')
group by SQL_ID , PLAN_HASH_VALUE
order by SQL_ID, CPU_MINS
/
prompt
prompt ##############################################################
prompt # CHECK XPLAN FROM AWR REPORT                                #
prompt ##############################################################
-- select * FROM table(DBMS_XPLAN.DISPLAY_AWR('${SQL_ID}'))
/
prompt
prompt ##############################################################
prompt # CHECK SQL BASELINE FOR DIFFERENT EXECUTION PLAN PER TIME   #
prompt ##############################################################
select
-- q.snap_id,
to_char(s.begin_interval_time,'yyyy-mm-dd hh24:mi:ss') begin_interval_time,
-- to_char(s.end_interval_time,'yyyy-mm-dd hh24:mi:ss') end_interval_time,
PLAN_HASH_VALUE,
-- ROWS_PROCESSED_DELTA,
round(ROWS_PROCESSED_DELTA/executions_delta,0) rows_processed,
executions_delta executions_per_report,
round(executions_delta/900,0) executions_per_sec,
-- buffer_gets_delta,
round(buffer_gets_DELTA/executions_delta,0) buffer_gets,
round(DISK_READS_DELTA/executions_delta,0) disk_read,
round(ELAPSED_TIME_DELTA/executions_delta/1000000,3) elapsed_time_in_sec
from dba_hist_sqlstat q, dba_hist_snapshot s
where q.snap_id = s.snap_id
and  sql_id='${OPT}'
and  executions_delta > 0
order by q.snap_id
/
prompt
prompt ##############################################################
prompt # CHECK SQL BASELINE FOR EXECUTION PLAN                      #
prompt ##############################################################
col execs for 999,999,999
col avg_etime for 999,999.999
col avg_lio for 999,999,999.9
col begin_interval_time for a20
col node for 99999
break on plan_hash_value on startup_time skip 1
select ss.snap_id
  , ss.instance_number node
  , to_char(begin_interval_time, 'yyyy-mm-dd HH24:mm:ss') as begin_interval_time
  , sql_id
  , plan_hash_value
  , nvl(executions_delta,0) execs
  , (elapsed_time_delta/decode(nvl(executions_delta,0),0,1,executions_delta))/1000000 avg_etime
  , (buffer_gets_delta/decode(nvl(buffer_gets_delta,0),0,1,executions_delta)) avg_lio
from DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS
-- where sql_id = '${OPT}'
and ss.snap_id = S.snap_id
and ss.instance_number = S.instance_number
and executions_delta > 0
order by 1, 2, 3;
undefine SQL_ID
quit;