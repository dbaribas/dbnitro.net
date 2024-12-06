-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # ASM: VERIFY CANDIDATE DISKS
prompt ##############################################################
prompt
BREAK ON report ON disk_group_name SKIP 1
col DISK_GROUP_NAME for a20
col DISK_FILE_PATH for a50
col DISK_FILE_FAIL_GROUP for a40
col DISK_FILE_NAME for a25
SELECT NVL(a.name, '[CANDIDATE]') disk_group_name
  , b.path disk_file_path
  , b.name disk_file_name
  , b.failgroup disk_file_fail_group
FROM v$asm_diskgroup a 
RIGHT OUTER JOIN v$asm_disk b USING (group_number)
ORDER BY a.name; 