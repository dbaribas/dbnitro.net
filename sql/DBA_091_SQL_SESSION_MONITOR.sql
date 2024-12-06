-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 50000 lines 32767 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # DBA: SQL SESSION MONITOR
prompt ##############################################################
COL SID FORMAT a15
COL STATUS FORMAT A8
COL PROCESS FORMAT A10
COL SCHEMANAME FORMAT A16
COL OSUSER FORMAT A20
COL SQL_TEXT FORMAT A120 HEADING 'SQL QUERY'
COL PROGRAM FORMAT A30
SELECT s.sid || ',' || s.serial# as sid
  , s.status
  , s.process
  , s.schemaname
  , s.osuser
  , a.sql_text
  , p.program
FROM v$session s
  , v$sqlarea a
  , v$process p
WHERE s.SQL_HASH_VALUE = a.HASH_VALUE
AND s.SQL_ADDRESS = a.ADDRESS
AND s.PADDR = p.ADDR
order by 1,2,3;
prompt
prompt ##############################################################
prompt # Total user count on database
prompt ##############################################################
compute SUM of tot on report
compute SUM of active on report
compute SUM of inactive on report
col username for a50
select DECODE(username,NULL,'INTERNAL',USERNAME) Username
  , count(*) TOT
  , COUNT(DECODE(status,'ACTIVE',STATUS)) ACTIVE
  , COUNT(DECODE(status,'INACTIVE',STATUS)) INACTIVE
from gv$session 
where status in ('ACTIVE','INACTIVE') 
group by username
order by 1,2,3;
prompt
prompt ##############################################################
prompt # Users Details Session
prompt ##############################################################
column box format a30
column sid format a15
column spid format a10
column username format a30
column program format a30
column os_user format a20
column LOGON_TIME format a20
select b.inst_id
  , b.sid || ',' || b.serial# as sid
  , a.spid
  , substr(b.machine,1,30) box
  , to_char(b.logon_time, 'dd-mon-yyyy hh24:mi:ss') logon_time
  , substr(b.username,1,30) username
  , substr(b.osuser,1,20) os_user
  , substr(b.program,1,30) program
  , status
  , b.last_call_et AS last_call_et_secs
  , b.sql_id 
from gv$session b
  , gv$process a 
where b.paddr = a.addr
and a.inst_id = b.inst_id 
and type='USER' 
order by logon_time;
prompt
prompt ##############################################################
prompt #
prompt ##############################################################
column box format a30
column sid format a15
column spid format a10
column username format a30
column program format a30
column os_user format a20
select b.sid || ',' || b.serial# as sid
  , a.spid
  , substr(b.machine,1,30) box
  , b.logon_time logon_date
  , to_char (b.logon_time, 'hh24:mi:ss') logon_time
  , substr(b.username,1,30) username
  , substr(b.osuser,1,20) os_user
  , substr(b.program,1,30) program
  , status
  , b.last_call_et AS last_call_et_secs
  , b.sql_id 
from v$session b
  , v$process a 
where b.paddr = a.addr
and type='USER' 
order by b.sid;
prompt
prompt ##############################################################
prompt # All Active and Inactive connections
prompt ##############################################################
col program for a40
col machine for a30
col terminal for a15
col sid for a15
col action for a15
select s.sid || ',' || s.serial# as sid
--  , '' || s.process || '' Client
--  , p.spid as Server
  , s.sql_address
  , s.sql_hash_value
  , s.username
--  , s.action
  , s.program
--  , s.terminal
  , s.machine
  , s.status
  , s.last_call_et
  , s.last_call_et/3600 
from gv$session s
  , gv$process p 
where p.addr=s.paddr 
and s.type != 'BACKGROUND'
order by 1,2,3;
prompt
prompt ##############################################################
prompt # Find active transactions
prompt ##############################################################
col name format a15 
col sid format a15
col username format a15 
col osuser format a20
col name format a40
col start_time format a17 
col status format a12 
tti 'Active transactions' 
select s.sid || ',' || s.serial# as sid
  , username
  , t.start_time
  , r.name
  , t.used_ublk "USED BLKS"
  , decode(t.space, 'YES', 'SPACE TX', decode(t.recursive, 'YES', 'RECURSIVE TX', decode(t.noundo, 'YES', 'NO UNDO TX', t.status))) status 
from sys.v_$transaction t
  , sys.v_$rollname r
  , sys.v_$session s 
where t.xidusn = r.usn 
and t.ses_addr = s.saddr
order by 1,2,3;