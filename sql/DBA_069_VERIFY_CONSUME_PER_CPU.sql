-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # VERIFY CONSUME PER CPU
prompt ##############################################################
COLUMN wait_class format a20
COLUMN name       format a55
COLUMN time_sec   format 999,999,999,999.99
COLUMN time_min   format 999,999,999,999,999.99
COLUMN time_hou   format 999,999,999,999,999,999.99
COLUMN time_day   format 999,999,999,999,999,999,999.99
COLUMN pct        format 999,99
COLUMN "% Used"   format a8 JUSTIFY RIGHT
select wait_class
   , NAME
   , ROUND(time_secs, 2) time_sec
   , ROUND(time_secs/60, 2) time_min
   , ROUND(time_secs/60/60, 2) time_hou
   , ROUND(time_secs/60/60/24, 2) time_day
   , ' ' || ROUND(time_secs * 100 / SUM (time_secs) OVER (), 2) || '%' as "% Used"
FROM (select n.wait_class, e.event NAME, e.time_waited / 100 time_secs FROM v$system_event e, v$event_name n WHERE n.NAME = e.event AND n.wait_class <> 'Idle' AND time_waited > 0
      UNION
      select 'CPU', 'server CPU', SUM (VALUE / 1000000) time_secs FROM v$sys_time_model WHERE stat_name IN ('background cpu time', 'DB CPU'))
-- where ROUND(time_secs*100/SUM(time_secs) OVER (), 2) > 0
-- where "% Used" > 0
ORDER BY time_sec DESC;