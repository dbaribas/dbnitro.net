-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 1000 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
set on verify off
prompt ##############################################################
prompt # VERIFY RUNNING JOBS
prompt ##############################################################
prompt
col "Last Date" for a30
col "This Date" for a30
select a.job "Job"
  , a.sid
  , a.failures "Failures"
  , Substr(To_Char(a.last_date,'yyyy-mm-dd HH24:MI:SS'),1,20) "Last Date"
  , Substr(To_Char(a.this_date,'yyyy-mm-dd HH24:MI:SS'),1,20) "This Date"
FROM dba_jobs_running a;