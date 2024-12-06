-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
select to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') current_time from dual;
prompt ##############################################################
prompt # ASM: BLOCKER IN ASM
prompt ##############################################################
prompt
column username format a10
column module format a50
column blocker format a7
column waiter format a7
column lmode format 9999
column request format 9999
column inst_id format 9999
column sid format 9999
col username format a6
col sid format 9999
col osuser format a14
col s# format 99999
col server format a10
col client format a10
col pname format a10
select b.inst_id||'/'||b.sid blocker
-- , s.module
  , w.inst_id||'/'||w.sid waiter
  , b.type
  , b.id1
  , b.id2
  , b.lmode
  , w.request
from gv$lock b, 
(select inst_id
   , sid
   , type
   , id1
   , id2
   , lmode
   , request
from gv$lock 
where request > 0) w
-- gv$session s
where b.lmode > 0
and (b.id1 = w.id1 and b.id2 = w.id2 and b.type = w.type)
--and (b.sid = s.sid and b.inst_id = s.inst_id)
order by b.inst_id, b.sid;