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
prompt # VERIFY NLS CONFIGURATION                                   #
prompt ##############################################################
COL PARAMETER FOR A30
COL DATABASE FOR A30
COL INSTANCE FOR A30
COL SESSION FOR A30
SELECT DB.PARAMETER
  , DB.VALUE "DATABASE"
  , I.VALUE "INSTANCE"
  , S.VALUE "SESSION"
FROM NLS_DATABASE_PARAMETERS DB, NLS_INSTANCE_PARAMETERS I, NLS_SESSION_PARAMETERS S
WHERE DB.PARAMETER=I.PARAMETER(+) AND DB.PARAMETER=S.PARAMETER(+)
ORDER BY 1;
