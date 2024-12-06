-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # TOP 20 DATABASE SESSIONS
prompt ##############################################################
col rank form 99
col sql_id for a15
col MACHINE for a30
col event for a30
-- col CPUMins for a10
-- col CPUHours for a10
col username for a20
col OSUSER for a20
col PROGRAM for a30
select rownum as rank
  , a.sid
  , a.serial#
  , a.sql_id
  , a.username
  , a.osuser
  , a.machine
  , a.program
--, a.event
  , a.CPUMins
  , a.CPUHours
  , a.CPUDays
from (select v.sid
        , serial#
        , sql_id
        , username
        , osuser
        , machine
        , program
    --  , event
        , round(v.value/(100*60), 0) CPUMins
        , round(v.value/60/60)/100 CPUHours
        , round(v.value/60/60/24)/100 CPUDays
      FROM gv$statname s, gv$sesstat v, gv$session sess
      WHERE s.name = 'CPU used by this session'
      and sess.sid = v.sid
      and v.statistic# = s.statistic#
      and v.value > 0
      ORDER BY v.value DESC) a
where rownum < 21
and osuser not in ('GRID','grid','ORACLE','oracle');