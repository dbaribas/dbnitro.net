-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 1000 lines 1000 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # VERIFY SESSIONS PER MEMORY                                 #
prompt ##############################################################
col name for a25
col program for a60
COL username for A20
COL module for A20
col machine for a50
select se.sid
  , n.name
  , s.program
  , s.machine
  , s.username
  , round(max(se.value)/(1024*1024),2) "MEM (MB)"
from v$sesstat se, v$statname n, v$session s
where n.statistic# = se.statistic#
and s.sid = se.sid
and s.username != 'SYSTEM'
and n.name in ('session pga memory','session uga memory')
group by s.username, s.machine, se.sid,n.name, s.program
order by 6;