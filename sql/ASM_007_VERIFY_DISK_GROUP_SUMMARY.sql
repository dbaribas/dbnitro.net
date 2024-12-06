-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # ASM: VERIFY DISK GROUP SUMMARY
prompt ##############################################################
col path for a35
col Diskgroup for a15
col DiskName for a20
col disk# for 999
col total_mb for 999,999,999
col free_mb for 999,999,999
compute sum of total_mb on DiskGroup
compute sum of free_mb on DiskGroup
break on DiskGroup skip 1 on report
select a.name DiskGroup
  , b.disk_number Disk
  , b.name DiskName
  , b.os_mb
  , b.total_mb
  , b.free_mb
  , b.path
  , b.header_status
from v$asm_disk b, v$asm_diskgroup a
where a.group_number (+) = b.group_number
order by b.group_number, b.disk_number, b.name;