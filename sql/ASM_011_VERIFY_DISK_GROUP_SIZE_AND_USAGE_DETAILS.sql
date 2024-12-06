-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # ASM: VERIFY DISK GROUP SIZE AND USAGE DETAILS
prompt ##############################################################
prompt
col name for a15
col lable for a15
col path for a70
select mount_status
  , header_status
  , mode_status
  , state
  , total_mb
  , free_mb
  , name
  , label
  , path
from v$asm_disk;