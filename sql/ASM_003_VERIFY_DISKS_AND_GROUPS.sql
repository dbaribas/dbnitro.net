-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # ASM: VERIFY DISKS AND GROUPS
prompt ##############################################################
prompt
col path for a50;
SELECT GROUP_NUMBER
  , DISK_NUMBER
  , NAME
  , PATH
  , FAILGROUP 
  , VOTING_FILE AS VOTING
  , header_status
  , MOUNT_STATUS
  , MODE_STATUS
  , STATE
FROM V$ASM_DISK 
ORDER BY 1,2,3;