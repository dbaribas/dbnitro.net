-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # VALIDATE OBJECTS FROM ONE OWNER
prompt ##############################################################
col username for a30
col account_status for a25
col profile for a25
col default_tablespace for a25
col temporary_tablespace for a25
select username
   , account_status
   , profile
   , default_tablespace
   , temporary_tablespace
from dba_users
order by 1;

prompt ##############################################################
prompt # VALIDATE OBJECTS FROM ONE OWNER
prompt ##############################################################
-- begin dbms_utility.compile_schema('${OPT}',false);
-- end;
-- /