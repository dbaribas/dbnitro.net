-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 1000 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # OGG: VERIFY GOLDENGATE CAPTURE
prompt ##############################################################
col capture_message_create_time for a30;
col enqueue_message_create_time for a27;
col available_message_create_time for a30;
SELECT capture_name
  , to_char(capture_time, 'mm/dd/yyyy hh24:mi') capture_time
  , capture_message_number
  , to_char(capture_message_create_time ,'mm/dd/yyyy hh24:mi') capture_message_create_time
  , to_char(enqueue_time,'mm/dd/yyyy hh24:mi') enqueue_time
  , enqueue_message_number
  , to_char(enqueue_message_create_time, 'mm/dd/yyyy hh24:mi') enqueue_message_create_time
  , available_message_number
  , to_char(available_message_create_time,'mm/dd/yyyy hh24:mi') available_message_create_time
FROM GV$GOLDENGATE_CAPTURE;