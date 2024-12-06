-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # VERIFY SESSIONS
prompt ##############################################################
col MACHINE for a45
col OSUSER for a25
col EVENT for a30
col PROGRAM for a60
col username for a20
select MACHINE
  , OSUSER
  , USERNAME
  , SID
  , SERIAL#
  , event
  , PROGRAM
from v$session
where osuser not in ('GRID','grid','ORACLE','oracle')
order by 1,2,5,6;