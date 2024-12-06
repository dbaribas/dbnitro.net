-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # PDB: CHECK UPTIME OF ALL PDBS
prompt ##############################################################
col name for a20
col "database uptime" for a30
select name
  , floor(sysdate-cast(open_time as date)) || ' Days ' || floor(((sysdate-cast(open_time as date))-floor(sysdate-cast(open_time as date)))*24) || ' hours ' || round(((sysdate-cast(open_time as date)-floor(sysdate-cast(open_time as date))*24)-floor((sysdate-cast(open_time as date)-floor(sysdate-cast(open_time as date))*24)))*60) || ' minutes ' "Database Uptime" 
from v$containers;