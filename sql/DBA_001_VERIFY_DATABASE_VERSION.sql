-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # VERIFY DATABASE VERSION                                    #
prompt ##############################################################
col INSTANCE for a10
col SERVER for a50
col VERSION for a20
col STATUS for a8
col active_state for a12
col "STARTUP TIME" for a20
select INSTANCE_NAME AS INSTANCE
  , HOST_NAME AS SERVER
  , VERSION
  , STATUS
  , active_state
  , to_char(startup_time,'yyyy-mm-dd hh24:mi') as "STARTUP TIME"
  , case when startup_time < sysdate then 'Status OK' when startup_time < sysdate - 7 then 'DB Restarted' else 'Verify Restarted DB' end as "Status DB"
from gv$instance;