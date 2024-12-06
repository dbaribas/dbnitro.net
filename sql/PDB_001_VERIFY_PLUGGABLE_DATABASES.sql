-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # PDB: VERIFY PLUGGABLE DATABASES
prompt ##############################################################
col NAME for a30
select CON_ID
  , NAME
  , OPEN_MODE
  , DBID
  , CON_UID
  , GUID 
FROM V$CONTAINERS 
ORDER BY CON_ID;