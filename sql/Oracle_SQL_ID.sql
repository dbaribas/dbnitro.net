SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('g8m9anc6dbgtv', NULL, 'ALL'));


SELECT * FROM V$SQL_PLAN WHERE SQL_ID = 'g8m9anc6dbgtv';






col "Last SQL" for a100
SELECT t.inst_id
  , s.username
  , s.sid
  , s.serial#
  , t.sql_id
  , t.sql_text "Last SQL"
FROM gv$session s, gv$sqlarea t
WHERE s.sql_address = t.address 
AND s.sql_hash_value =t.hash_value;

col HOST_NAME for a20
col EVENT for a40
col MACHINE for a30
col SQL_TEXT for a50
col USERNAME for a15
select sid
  , serial#
  , a.sql_id
  , a.SQL_TEXT
  , S.USERNAME
  , i.host_name
  , machine
  , S.event
  , S.seconds_in_wait sec_wait
  , to_char(logon_time, 'DD/MM/YYYY HH24:MI') login
from gv$session S, gV$SQLAREA A, gv$instance i
where S.username is not null
-- and S.status='ACTIVE'
AND S.sql_address=A.address
and s.inst_id=a.inst_id and i.inst_id = a.inst_id
and sql_text not like 'select S.USERNAME,S.seconds_in_wait%';

select b.sid
  , b.status
  , b.last_call_et
  , b.program
  , c.sql_id
  , c.sql_text
from v$session b,v$sqlarea c
where b.sql_id=c.sql_id;

alter session set nls_date_format = 'dd/mm/yyyy hh24:mi';
col target format a30
col opname format a40
select sid
  , opname
  , target
  , round(sofar/totalwork*100,2)   as percent_done
  , start_time
  , last_update_time
  , time_remaining
from v$session_longops;






SQLID() {
local SQLID=$1
if [[ "${SQLID}" == "" ]]; then
  echo ""
  echo " -- YOU NEED TO EXECUTE THIS FUNCTION WITH THE SQL_ID AFTER THE NAME: EXAMPLE: SQLID xxx000xxx000xxx"
  echo ""
else
sqlplus -S / as sysdba <<EOF
set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # SQL ID
prompt ##############################################################
col sql_id for a15
col sql_text for a40
SELECT sql_id
  , sql_text
  , elapsed_time / 1000000 AS elapsed_seconds
  , cpu_time / 1000000 AS cpu_seconds
  , executions
  , buffer_gets
  , disk_reads
  , optimizer_cost
  , plan_hash_value
FROM gv\$sql
WHERE sql_id = '${SQLID}';
quit;
EOF
fi
}



