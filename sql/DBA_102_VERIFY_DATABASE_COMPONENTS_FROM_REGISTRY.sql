-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set feedback off timing off
alter session set nls_date_format='yyyy-mm-dd';
set pages 700 lines 1000 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # VERIFY DATABASE COMPONENTS FROM REGISTRY
prompt ##############################################################
col COMP_ID format a15
col COMP_NAME format a50
col SCHEMA format a15
col STATUS format a15
col VERSION format a15
col CON_ID format 99
select CON_ID
  , COMP_ID
  , comp_name
  , schema
  , status
  , version 
from CDB_REGISTRY 
order by 1,2;