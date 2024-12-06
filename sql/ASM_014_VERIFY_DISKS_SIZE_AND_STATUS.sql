-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # ASM: VERIFY DISKS SIZE AND STATUS
prompt ##############################################################
prompt
col NAME for a15
select GROUP_NUMBER DG#
  , name
  , ALLOCATION_UNIT_SIZE AU_SZ
  , STATE
  , TYPE
  , TOTAL_MB
  , FREE_MB
  , OFFLINE_DISKS 
from v$asm_diskgroup;