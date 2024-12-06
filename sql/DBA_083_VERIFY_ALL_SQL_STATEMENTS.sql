-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set feedback off timing off
alter session set nls_date_format='yyyy-mm-dd';
set pages 5000 lines 80 timing on long 9999999 numwidth 20 heading on echo off verify off feedback on colsep '|' head off
prompt ##############################################################
prompt # VERIFY ALL SQL STATEMENTS
prompt ##############################################################
select /*+ CHOOSE*/
'Session Id...........................: ' || s.sid,
'Serial Num...........................: ' || s.serial#,
'User Name............................: ' || s.username,
'SQL ID...............................: ' || s.sql_id,
'Session Status.......................: ' || s.status,
'Client Process Id on Client Machine..: ' || '*' || s.process || '*' Client,
'Server Process ID....................: ' || p.spid Server,
'Sql_Address..........................: ' || s.sql_address,
'Sql_hash_value.......................: ' || s.sql_hash_value,
'Schema Name..........................: ' || s.SCHEMANAME,
'Program..............................: ' || s.program,
'Module...............................: ' || s.module,
'Action...............................: ' || s.action,
'Terminal.............................: ' || s.terminal,
'Client Machine.......................: ' || s.machine,
'LAST_CALL_ET.........................: ' || s.last_call_et,
'S.LAST_CALL_ET/3600..................: ' || s.last_call_et/3600
from v$session s, v$process p
where p.addr = s.paddr;
-- and s.sid = nvl('${ORACLE_SID}', s.sid);