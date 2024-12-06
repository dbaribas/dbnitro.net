-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # REDO LOG RECOMMENDED SIZE
prompt ##############################################################
prompt # Peak Redo Rate   Recommended Redo Log Size
prompt # <= 1 MB/s        1 GB
prompt # <= 5 MB/s        4 GB
prompt # <= 25 MB/s       16 GB
prompt # <= 50 MB/s       32 GB
prompt #  > 50 MB/s       64 GB
prompt ##############################################################
SELECT thread#
  , sequence#
  , to_char(completion_time, 'YYYY-MM-DD HH24:MI:SS') as time
  , blocks * block_size / 1024 / 1024 MB
  , (next_time - first_time) * 86400 sec
  , (blocks * block_size / 1024 / 1024) / ((next_time - first_time) * 86400) "MB/s"
FROM v$archived_log
WHERE ((next_time - first_time) * 86400 <> 0)
  AND first_time BETWEEN SYSDATE - INTERVAL '6' HOUR AND SYSDATE
  AND dest_id = 1
ORDER BY 1,2,3;