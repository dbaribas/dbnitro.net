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
prompt # DBA: VERIFY ORACLE NET SEND AND RECEIVE SIZE VOLUME
prompt ##############################################################
col name for a50
col event for a50
col format_size for a20
col format_size2 for a20
col FORMAT_NUMBER for a20
col FORMAT_NUMBER2 for a20
select name
  , dbms_xplan.FORMAT_SIZE(value) as FORMAT_SIZE
  , dbms_xplan.FORMAT_SIZE2(value) FORMAT_SIZE2 
from v$sysstat 
where name like 'bytes%SQL*Net%' 
and value > 0 
order by value desc;
prompt
prompt ##############################################################
prompt # DBA: VERIFY ORACLE NET SEND AND RECEIVE SIZE VOLUME
prompt ##############################################################
select event
  , dbms_xplan.FORMAT_NUMBER(total_waits) as FORMAT_NUMBER
  , dbms_xplan.FORMAT_NUMBER2(total_waits) as FORMAT_NUMBER2 
from v$system_event 
where event like '%SQL*Net%' 
order by total_waits desc;