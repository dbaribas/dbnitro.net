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
prompt # DBA: USER DETAILS SESSIONS
prompt ##############################################################
prompt
column box format a25
column session_id for a15
column spid format a10
column username format a20 
column program format a30
column os_user format a20
col LOGON_TIME for a20  
select b.sid || ',' || b.serial# || '@' || b.inst_id as session_id
  , a.spid
  , substr(b.machine,1,30) box
  , to_char(b.logon_time, 'yyyy-mm-dd hh24:mi:ss') logon_time
  , substr(b.username,1,30) username
  , substr(b.osuser,1,20) os_user
  , substr(b.program,1,30) program
  , status
  , b.last_call_et AS last_call_et_secs
  , b.sql_id 
 from gv\$session b,gv\$process a 
 where b.paddr = a.addr 
 and a.inst_id = b.inst_id  
 and type = 'USER'  
 order by b.inst_id,b.sid;