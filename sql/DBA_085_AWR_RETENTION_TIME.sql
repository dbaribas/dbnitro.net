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
prompt # AWR Retention Time                                         #
prompt ##############################################################
select a.dbid
  , c.name
  , b.instance_name
  , a.retention
from DBA_HIST_WR_CONTROL a, v$instance b, v$database c
where a.dbid = c.dbid (+);
prompt
prompt ##############################################################
prompt # Statistics Retention History                               #
prompt ##############################################################
select dbms_stats.get_stats_history_retention from dual;
prompt
prompt ##############################################################
prompt # Statistics Availability History                            #
prompt ##############################################################
select dbms_stats.get_stats_history_availability from dual;
prompt
prompt ##############################################################
prompt # Duration Time of SnapShots                                 #
prompt ##############################################################
col "Start Time" for a25
col "End Time" for a25
select min(snap_id) as "First Snap ID"
  , max(snap_id) as "Last Snap ID"
  , min(to_char(begin_interval_time,'yyyy-mm-dd HH24:MI:SS')) as "Start Time"
  , max(to_char(end_interval_time,'yyyy-mm-dd HH24:MI:SS')) as "End Time"
from dba_hist_snapshot;
prompt
prompt ##############################################################
prompt # Infos About SYSAUX TBS                                     #
prompt ##############################################################
COLUMN "Item" FORMAT A25
COLUMN "Space Used (GB)" FORMAT 999.999
COLUMN "Schema" FORMAT A25
COLUMN "Move Procedure" FORMAT A50
select occupant_name "Item"
  , space_usage_kbytes/1048576 "Space Used (GB)"
  , schema_name "Schema"
  , move_procedure "Move Procedure"
FROM gv_$sysaux_occupants
ORDER BY 1;
prompt
prompt ##############################################################
prompt # Controlling the Size and Age of the OS Audit Trail         #
prompt ##############################################################
COLUMN parameter_name FORMAT A30
COLUMN parameter_value FORMAT A20
COLUMN audit_trail FORMAT A20
select * FROM dba_audit_mgmt_config_params
WHERE parameter_name LIKE 'AUDIT FILE MAX%';