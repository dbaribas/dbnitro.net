-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # CONNECTIONS AVERAGE PER HOUR                               #
prompt ##############################################################
prompt 
select to_char(TRUNC(s.begin_interval_time,'HH24'),'yyyy-mm-dd HH24:MI:SS') snap_begin
  , sum(r.current_utilization) sessions
FROM dba_hist_resource_limit r, dba_hist_snapshot s
WHERE (TRUNC(s.begin_interval_time,'HH24'), s.snap_id ) IN
(--select the Maximum of the Snapshot IDs within an hour if more than one snapshot IDs
--have the same number of sessions within that hour , so then picking one of the snapIds
select TRUNC(sn.begin_interval_time,'HH24'),MAX(rl.snap_id)
FROM dba_hist_resource_limit rl,dba_hist_snapshot sn
WHERE TRUNC(sn.begin_interval_time) >= TRUNC(sysdate-1)
AND rl.snap_id = sn.snap_id
AND rl.resource_name = 'sessions'
AND rl.instance_number = sn.instance_number
AND (TRUNC(sn.begin_interval_time,'HH24'),rl.CURRENT_UTILIZATION ) IN
(--select the Maximum no.of sessions for a given begin interval time
-- All the snapshots within a given hour will have the same begin interval time when TRUNC is used
-- for HH24 and we are selecting the Maximum sessions for a given one hour
select TRUNC(s.begin_interval_time,'HH24'),MAX(r.CURRENT_UTILIZATION) "no_of_sess"
FROM dba_hist_resource_limit r,dba_hist_snapshot s
WHERE r.snap_id = s.snap_id
AND TRUNC(s.begin_interval_time) >= TRUNC(sysdate-1)
AND r.instance_number=s.instance_number
AND r.resource_name = 'sessions'
GROUP BY TRUNC(s.begin_interval_time,'HH24'))
GROUP BY TRUNC(sn.begin_interval_time,'HH24'),CURRENT_UTILIZATION)
AND r.snap_id = s.snap_id
AND r.instance_number = s.instance_number
AND r.resource_name = 'sessions'
GROUP BY to_char(TRUNC(s.begin_interval_time,'HH24'),'yyyy-mm-dd HH24:MI:SS')
ORDER BY snap_begin;