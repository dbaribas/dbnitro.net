-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on colsep '|' feedback off trimspool on echo off heading on wrap off
prompt ##############################################################
prompt # VERIFY TOP 20 TUNING HISTORY
prompt ##############################################################
select * from (select SQL_ID ,
sum(decode(session_state,'ON CPU',1,0)) as CPU,
sum(decode(session_state,'WAITING',1,0)) - sum(decode(session_state, 'WAITING', decode(wait_class, 'User I/O',1,0),0)) as WAIT,
sum(decode(session_state,'WAITING', decode(wait_class, 'User I/O',1,0),0)) as IO,
sum(decode(session_state,'ON CPU',1,1)) as TOTAL
from v$active_session_history
where SQL_ID is not NULL
group by sql_id
order by sum(decode(session_state,'ON CPU',1,1)) desc)
where rownum < 21;