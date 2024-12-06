-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # ASM: VERIFY DISK STATE AND COMPATIBILITY
prompt ##############################################################
col compatibility for a13
col database_compatibility for a22
select GROUP_NUMBER
  , NAME
  , TOTAL_MB
  , FREE_MB
  , STATE
  , COMPATIBILITY
  , DATABASE_COMPATIBILITY 
from v$asm_diskgroup;