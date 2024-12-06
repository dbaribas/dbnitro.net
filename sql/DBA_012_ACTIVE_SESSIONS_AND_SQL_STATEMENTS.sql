-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 2000 lines 2000 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # ACTIVE SESSIONS AND SQL STATEMENTS                         #
prompt ##############################################################
column USERNAME for a15
column "SID/SERIAL" for a15
column "WAITING SEG" format a12 heading "WAITING|SEG"
column SQL_TEXT for a100
column machine for a35
column osuser for a15
select S.USERNAME
  , '( ' || s.sid || ',' || s.serial# || ' )' as "SID/SERIAL"
  , s.machine
  , s.osuser
  , to_char(s.seconds_in_wait) as "WAITING SEG"
  , t.sql_id
  , sql_text
from v$sqltext_with_newlines t, V$SESSION s
where t.address = s.sql_address and t.hash_value = s.sql_hash_value and s.status = 'ACTIVE'
order by s.sid, t.piece;
prompt
prompt ##############################################################
prompt # LOCKED OBJECT ON LONG OPERATIONS                           #
prompt ##############################################################
col OBJECT_NAME for a30
select object_name
  , object_type
  , session_id
  , type
  , lmode
  , request
  , block
  , ctime
from v$locked_object, all_objects, v$lock
where v$locked_object.object_id = all_objects.object_id 
and v$lock.id1 = all_objects.object_id 
and v$lock.sid = v$locked_object.session_id
order by session_id, ctime desc, object_name;
prompt
prompt ##############################################################
prompt # OPERATION NAME, HOW LONG ARE RUNNING, MESSAGE              #
prompt ##############################################################
col OPNAME for a35
col TARGET for a40
col UNITS for a10
col sofar for a10
column "TOTAL WORK" for a10 heading "TOTAL|WORK"
column "ELAPSED SECONDS" for a10 heading "ELAPSED|SECONDS"
column MESSAGE for a90
column sql_id for a15
select distinct * from (select opname
              , target
						  , to_char(sofar) as sofar
						  , sql_id
						  , to_char(totalwork) as "TOTAL WORK"
						  , units
						  , to_char(elapsed_seconds) as "ELAPSED SECONDS"
						  , substr(message,1,90) as message
						from v$session_longops 
						order by start_time desc) 
where rownum <= 20;
prompt
prompt ##############################################################
prompt # ??? #
prompt ##############################################################
col OPNAME for a35
col TARGET for a15
select opname
  , target
  , osuser
  , sl.sql_id
  , sl.sql_hash_value
  , elapsed_seconds
  , time_remaining
FROM v$session_longops sl
inner join v$session s ON sl.SID = s.SID AND sl.SERIAL# = s.SERIAL# WHERE time_remaining > 0;
prompt
prompt ##############################################################
prompt # ??? #
prompt ##############################################################
col username for a15
col sql_fulltext for a75
col TARGET for a20
select s.username
  , sl.sid
  , sq.executions
  , sl.last_update_time
  , sl.sql_id
  , sl.sql_hash_value
  , opname
  , target
  , elapsed_seconds
  , time_remaining
  , sq.sql_fulltext
FROM v$session_longops sl
INNER JOIN v$sql sq ON sq.sql_id = sl.sql_id
INNER JOIN v$session s ON sl.SID = s.SID AND sl.serial# = s.serial#
WHERE time_remaining > 0;
prompt
prompt ##############################################################
prompt #  #
prompt ##############################################################
col sql_id for a15
col units for a15
col opname for a35
col started for a20
col now for a20
select sql_id
  , opname
  , to_char(start_time, 'yyyy-mm-dd HH24:MI:SS') as started
  , to_char(sysdate, 'yyyy-mm-dd HH24:MI:SS') as now
--  , trunc(((((86400*(sysdate-start_time))/60)/60)/24)/7) weeks
  , trunc((((86400*(sysdate-start_time))/60)/60)/24) days
  , trunc(((86400*(sysdate-start_time))/60)/60)-24*(trunc((((86400*(sysdate-start_time))/60)/60)/24)) hours
  , trunc((86400*(sysdate-start_time))/60)-60*(trunc(((86400*(sysdate-start_time))/60)/60)) minutes
  , trunc(86400*(sysdate-start_time))-60*(trunc((86400*(sysdate-start_time))/60)) seconds
  , sofar
  , totalwork
  , units
--  , round(elapsed_seconds/60/60,2) as seconds
  , round(time_remaining/60/60,2) as remaining
FROM v$session_longops
WHERE sofar != totalwork;