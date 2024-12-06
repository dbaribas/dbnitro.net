-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set feedback off timing off
alter session set nls_date_format='yyyy-mm-dd';
set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # VERIFY INSTANCE INSTALLED PRODUCTS
prompt ##############################################################
col version_full for a15
col status for a10
col schema for a12
col comp_name for a40
select comp_name
  , version_full
--  , status
  , modified
--  , to_char(modified, 'yyyy-mm-dd HH24:MM:SS') as modified
  , schema
  , status
FROM dba_registry
order by 1, 2, 3;