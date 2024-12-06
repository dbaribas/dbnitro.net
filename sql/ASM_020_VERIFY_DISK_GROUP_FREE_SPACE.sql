-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # ASM: VERIFY DISK GROUPS FREE SPACE
prompt ##############################################################
prompt
col name for a30
select NAME
  , ALLOCATION_UNIT_SIZE
  , STATE
  , TYPE
  , TOTAL_MB
  , FREE_MB
  , (FREE_MB/TOTAL_MB)*100 PCt_FREE 
from v$asm_diskgroup 
order by name, PCt_FREE;