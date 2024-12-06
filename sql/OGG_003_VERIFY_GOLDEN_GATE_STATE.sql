-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 1000 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # OGG: VERIFY GOLDENGATE STATE
prompt ##############################################################
col state for a30;
col capture_name for a30;
col bytes_of_redo_mined for a30;
SELECT sid
  , serial#
  , capture#
  , CAPTURE_NAME
  , STARTUP_TIME
  , CAPTURE_TIME
  , state
  , SGA_USED
  , BYTES_OF_REDO_MINED
  , to_char(STATE_CHANGED_TIME, 'yyyy-mm-dd hh24:mi') STATE_CHANGED_TIME
FROM V$GOLDENGATE_CAPTURE;