-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # ASM: VERIFY DISKS TYPE AND STATUS
prompt ##############################################################
col PATH for a40
col DG_NAME for a15
col DG_STATE for a10
col FAILGROUP for a20
select dg.name dg_name
  , dg.state dg_state
  , dg.type
  , d.disk_number dsk_no
  , d.path
  , d.mount_status
  , d.FAILGROUP
  , d.state
from v$asm_diskgroup dg, v$asm_disk d
where dg.group_number = d.group_number
order by dg_name, dsk_no;