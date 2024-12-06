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
prompt # ORACLE ENTERPRISE MANAGER ALERT
prompt ##############################################################
col message_type for a30
col reason for a110
col date_alert for a20
col SUGGESTED_ACTION for a30
select to_char(TIME_SUGGESTED, 'yyyy-mm-dd hh24:mi') DATE_ALERT
  , message_type
  , reason
  , SUGGESTED_ACTION
FROM dba_outstanding_alerts
order by DATE_ALERT;