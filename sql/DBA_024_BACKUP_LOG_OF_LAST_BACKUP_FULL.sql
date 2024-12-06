-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # BACKUP LOG OF LAST BACKUP FULL
prompt ##############################################################
select decode(status, 'COMPLETED', 0,1) as STATUS
  , case when decode(status, 'COMPLETED', 0,1) = 0 then 'Backup Not Running' else 'Backup Running' end as "Running Y/N"
from v$RMAN_BACKUP_JOB_DETAILS
where session_key = (select max(session_key) from v$RMAN_BACKUP_JOB_DETAILS where START_TIME > sysdate - 30 and input_type in('DB FULL', 'DB INCR','CONTROLFILE'));