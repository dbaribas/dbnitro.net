-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set feedback off timing off
alter session set nls_date_format='yyyy-mm-dd';
set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|' trim on trims on numformat 999999999999999
-- Auslesen Event Historie (cursor: mutex S) - je Report
prompt ##############################################################
prompt # VERIFY MAIN TOP WAIT EVENTS PER WEEK
prompt ##############################################################
col begin_interval_time format a20
col end_interval_time format a20
col AVG_WAIT_TIME_MSEC for a30
col EVENT_NAME for a40
col total_waits for a15
col total_waited_sec for a15
col week for a5
col AVG_WAIT_TIME_MSEC for 999999999,99
select dhs.snap_id
  , to_char(dhs.begin_interval_time,'iw') week
  , to_char(dhs.begin_interval_time,'yyyy-mm-dd hh24:mi:ss') begin_interval_time
  , to_char(dhs.end_interval_time,'yyyy-mm-dd hh24:mi:ss') end_interval_time
  , to_char(event_name) event_name
  , to_char(total_waits) total_waits
  , to_char(round(total_waited_micro/1000000)) as total_waited_sec
  , decode(total_waits,0,0,round(total_waited_micro/total_waits/1000,2)) avg_wait_time_msec
FROM (select snap_id
        , event_name
        , total_waits - lag( total_waits) OVER(ORDER BY snap_id) AS total_waits
        , time_waited_micro - lag (time_waited_micro) over (ORDER BY snap_id) as total_waited_micro
      FROM dba_hist_system_event
      WHERE event_name in ('db file sequential read','direct path read','direct path read temp','direct path sync','direct path write','direct path write temp','log file sync','db file scattered read','cursor: mutex S')
      ORDER BY snap_id) details,
dba_hist_snapshot dhs
WHERE dhs.snap_id = details.snap_id
and total_waits > 0
-- and begin_interval_time > sysdate - 12/24
ORDER BY dhs.snap_id;