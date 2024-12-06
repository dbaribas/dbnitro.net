-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # ASM: VERIFY DISK GROUP USAGE
prompt ##############################################################
prompt
col diskgroup for a15
col diskname for a15
col path for a35
select a.name DiskGroup
  , b.name DiskName
  , b.header_status
  , b.total_mb
  , (b.total_mb - b.free_mb) Used_MB
  , b.free_mb
  , b.path
from v$asm_disk b, v$asm_diskgroup a
where a.group_number (+) = b.group_number
order by b.group_number, b.name;