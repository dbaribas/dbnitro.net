-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL_1..........: dba.ribas@gmail.com
-- EMAIL_2..........: andre.ribas@icloud.com
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # ASM: VERIFY DISKS READ AND WRITE VALUES
prompt ##############################################################
prompt
SELECT SUBSTR(dgs.name,1,10) AS diskgroup
  , SUBSTR(ds.name,1,10) AS asmdisk
  , ds.mount_status
  , ds.state
  , ds.reads
  , ds.writes
  , ds.read_time
  , ds.write_time
  , bytes_read
  , bytes_written
FROM V$ASM_DISKGROUP_STAT dgs, V$ASM_DISK_STAT ds
WHERE dgs.group_number = ds.group_number;