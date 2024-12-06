-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # CLONE USER COMMANDS
prompt ##############################################################
col username for a30
col profile for a20
select username
  , account_status
  , default_tablespace
  , temporary_tablespace
  , profile
from dba_users
where username not in ('SYS','SYSTEM','XDB','XS$NULL','ANONYMOUS')
order by 1,2;