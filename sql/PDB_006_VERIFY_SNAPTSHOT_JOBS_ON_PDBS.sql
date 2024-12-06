-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # PDB: VERIFY SNAPSHOT JOBS ON PDB
prompt ##############################################################
col owner for a10
col job_name for a30
col repeat_interval for a50
select owner
  , job_name
  , repeat_interval
FROM dba_scheduler_jobs
WHERE job_name LIKE '%SNAPSHOT'
ORDER BY owner, job_name;