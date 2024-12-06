-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 17/10/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

-- set feedback off timing off
-- alter session set nls_date_format='yyyy-mm-dd';
set pages 700 lines 1000 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # DBA: CHECK SYSAUX TABLESPACE
prompt ##############################################################

SELECT OCCUPANT_NAME
  , SCHEMA_NAME
  , MOVE_PROCEDURE
  , SPACE_USAGE_KBYTES/1024 AS MB
FROM V$SYSAUX_OCCUPANTS 
ORDER BY 1,2,3;