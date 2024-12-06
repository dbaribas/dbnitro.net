-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 1000 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # OGG: VERIFY GOLDENGATE CAPTURES, QUEUE AND STATUS
prompt ##############################################################
col CAPTURE_NAME for a20;
col QUEUE_NAME for a15;
col START_SCN for 9999999999;
col STATUS for a10;
col CAPTURED_SCN for 9999999999;
col APPLIED_SCN for 9999999999;
col SOURCE_DATABASE for a10;
col LOGMINER_ID for 9999999;
col REQUIRED_CHECKPOINTSCN for a30;
col STATUS_CHANGE_TIME for a15;
col ERROR_NUMBER for a15;
col ERROR_MESSAGE for a10;
col CAPTURE_TYPE for a10;
col START_TIME for a30
SELECT CAPTURE_NAME
  , QUEUE_NAME
  , START_SCN
  , STATUS
  , CAPTURED_SCN
  , APPLIED_SCN
  , SOURCE_DATABASE
  , LOGMINER_ID
  , REQUIRED_CHECKPOINT_SCN
  , STATUS_CHANGE_TIME
  , ERROR_NUMBER
  , ERROR_MESSAGE
  , CAPTURE_TYPE
  , START_TIME
FROM DBA_CAPTURE;