-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 2000 lines 2000 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # VERIFY SESSIONS PER I/O
prompt ##############################################################
col username for a25
col osuser for a25
select NVL(s.username, '(oracle)') AS username
  , s.osuser
  , s.sid
  , s.serial#
  , si.block_gets
  , si.consistent_gets
  , si.physical_reads
  , si.block_changes
  , si.consistent_changes
FROM v$session s, v$sess_io si
WHERE s.sid = si.sid
and s.osuser not in ('GRID','grid','ORACLE','oracle')
ORDER BY s.username, s.osuser, si.physical_reads;