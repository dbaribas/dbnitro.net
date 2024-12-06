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
set feedback off trimspool on echo off wrap off;
prompt ##############################################################
prompt # REPORT SQL MONITOR                                         #
prompt ##############################################################
select dbms_sqltune.report_sql_monitor from dual;
prompt
prompt ##############################################################
prompt # GLOBAL INFORMATION ABOUT I/O                               #
prompt ##############################################################
set pages 700 lines 700 timing on long 10000000 longchunksize 10000000 colsep '|' numwidth 20 heading on echo on verify on feedback on colsep '|' lin 200 ver off;
COL instance_number FOR 9999 HEA 'Inst';
COL end_time HEA 'End Time';
COL plan_hash_value HEA 'Plan|Hash Value';
COL executions_total FOR 999,999 HEA 'Execs|Total';
COL rows_per_exec HEA 'Rows Per Exec';
COL et_secs_per_exec HEA 'Elap Secs|Per Exec';
COL cpu_secs_per_exec HEA 'CPU Secs|Per Exec';
COL io_secs_per_exec HEA 'IO Secs|Per Exec';
COL cl_secs_per_exec HEA 'Clus Secs|Per Exec';
COL ap_secs_per_exec HEA 'App Secs|Per Exec';
COL cc_secs_per_exec HEA 'Conc Secs|Per Exec';
COL pl_secs_per_exec HEA 'PLSQL Secs|Per Exec';
COL ja_secs_per_exec HEA 'Java Secs|Per Exec';
select h.instance_number
   , TO_CHAR(CAST(s.end_interval_time AS DATE), 'yyyy-mm-dd HH24:MI:SS') end_time
   , h.plan_hash_value
   , h.executions_total
   , TO_CHAR(ROUND(h.rows_processed_total / h.executions_total), '999,999,999,999') rows_per_exec
   , TO_CHAR(ROUND(h.elapsed_time_total / h.executions_total / 1e6, 3), '999,990.000') et_secs_per_exec
   , TO_CHAR(ROUND(h.cpu_time_total / h.executions_total / 1e6, 3), '999,990.000') cpu_secs_per_exec
   , TO_CHAR(ROUND(h.iowait_total / h.executions_total / 1e6, 3), '999,990.000') io_secs_per_exec
   , TO_CHAR(ROUND(h.clwait_total / h.executions_total / 1e6, 3), '999,990.000') cl_secs_per_exec
   , TO_CHAR(ROUND(h.apwait_total / h.executions_total / 1e6, 3), '999,990.000') ap_secs_per_exec
   , TO_CHAR(ROUND(h.ccwait_total / h.executions_total / 1e6, 3), '999,990.000') cc_secs_per_exec
   , TO_CHAR(ROUND(h.plsexec_time_total / h.executions_total / 1e6, 3), '999,990.000') pl_secs_per_exec
   , TO_CHAR(ROUND(h.javexec_time_total / h.executions_total / 1e6, 3), '999,990.000') ja_secs_per_exec
FROM dba_hist_sqlstat h, dba_hist_snapshot s
WHERE h.sql_id = '${SQL_ID}'
AND h.executions_total > 0
AND s.snap_id = h.snap_id
AND s.dbid = h.dbid
AND s.instance_number = h.instance_number
ORDER BY h.sql_id, h.instance_number, s.end_interval_time, h.plan_hash_value;
prompt
prompt ##############################################################
prompt # For Full Table scans:
prompt ##############################################################
select sql_text 
from v$sqltext t, v$sql_plan p
where t.hash_value = p.hash_value 
and p.operation = 'TABLE ACCESS'
and p.options = 'FULL'
order by p.hash_value, t.piece;
prompt
prompt ##############################################################
prompt # For Fast Full Index scans:
prompt ##############################################################
select sql_text 
from v$sqltext t, v$sql_plan p
where t.hash_value = p.hash_value 
and p.operation = 'INDEX'
and p.options = 'FULL SCAN'
order by p.hash_value, t.piece;
prompt
prompt ##############################################################
prompt # Control File Reads and Writes
prompt ##############################################################
select P1
  , P2 
from v$SESSION_WAIT
where EVENT like 'control file%';