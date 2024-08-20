-- |
-- +-------------------------------------------------------------------------------------------+
-- | Objetivo   : GAP Replicacao Data Guard                                                    |
-- | Criador    : Roberto Fernandes Sobrinho                                                   |
-- | Data       : 30/05/2024                                                                   |
-- | Exemplo    : @dg.sql                                                                      |
-- | Arquivo    : dg.sql                                                                       |
-- | Referncia  :                                                                              |
-- | Modificacao: 1.1 - DBASobrinho - Ajustinho de nada, incluido o MAX                        |
-- +-------------------------------------------------------------------------------------------+
-- |                                                                https://dbasobrinho.com.br |
-- +-------------------------------------------------------------------------------------------+
-- |Peppa Pig diz: "Eu adoro pular em poças de Lama"
-- +-------------------------------------------------------------------------------------------+
SET TERMOUT OFF;
ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD HH24:MI:SS';
EXEC dbms_application_info.set_module( module_name => 'd[dg.sql]', action_name =>  'd[dg.sql]');
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
COLUMN DG_CONF NEW_VALUE DG_CONF NOPRINT;
select value DG_CONF from v$parameter a where name = 'log_archive_config';
SET TERMOUT ON;
PROMPT
PROMPT +-------------------------------------------------------------------------------------------+
PROMPT | https://github.com/dbasobrinho/g_gold/blob/main/dg.sql                                    |
PROMPT +-------------------------------------------------------------------------------------------+
PROMPT | Script   : GAP Replicacao Data Guard                             +-+-+-+-+-+-+-+-+-+-+-+  |
PROMPT | Instancia: &current_instance                                     |d|b|a|s|o|b|r|i|n|h|o|  |
PROMPT | Versao   : 1.1                                                   +-+-+-+-+-+-+-+-+-+-+-+  |
PROMPT +-------------------------------------------------------------------------------------------+
PROMPT | DG_CONF  : &DG_CONF
PROMPT +-------------------------------------------------------------------------------------------+
PROMPT
SET ECHO OFF FEEDBACK 10 HEADING ON LINES 188 PAGES 300 TERMOUT ON TIMING OFF TRIMOUT ON TRIMSPOOL ON VERIFY OFF
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
COLUMN REPLICACAO_DG          FORMAT a100       HEAD 'REPLICACAO DG CONFIGURACAO'
COLUMN STANDBY_LAST_RECEIVED  FORMAT 9999999    HEAD 'ULTIMO ARC|ORIGEM'          justify CENTER
COLUMN STANDBY_LAST_APPLIED   FORMAT 9999999    HEAD 'ULTIMO ARC|DESTINO'         justify CENTER
COLUMN STANDBY_DT_LAST_APP    FORMAT a19        HEAD 'ULTIMA DATA|DESTINO'        justify CENTER
COLUMN data_atual             FORMAT a19        HEAD 'DATA|ATUAL'                 justify CENTER
COLUMN MINUTOS                FORMAT 999999     HEAD 'DIF|MIN'                    justify CENTER
COLUMN ARC_DIFF               FORMAT 999999     HEAD 'DIF|ARC'                    justify CENTER
COLUMN DATABASE_ROLE          FORMAT a16        HEAD 'DATABASE|PERFIL'            justify CENTER
COLUMN PROTECTION_MODE        FORMAT a20        HEAD 'MODO|PROTECAO'              justify CENTER
COLUMN thread                 FORMAT 99999      HEAD 'THREAD|'                    justify CENTER
COLUMN SWITCHOVER_STATUS      FORMAT a16        HEAD 'SWITCHOVER|STATUS'          justify CENTER
COLUMN DEST_ID                FORMAT 999        HEAD 'ID|DEST'                    justify CENTER
COLUMN NAME                   FORMAT a10        HEAD 'DEST|NAME'                  justify CENTER
COLUMN ST                     FORMAT a03        HEAD 'ST'                         justify CENTER
COLUMN NAME                   FORMAT a20        HEAD 'NAME|DESTINATION'           justify CENTER
SET COLSEP '|' FEEDBACK    off
PROMPT +-------------------------------------------------------------------------------------------+
PROMPT | Status FUZZY Datafiles
PROMPT +-------------------------------------------------------------------------------------------+
COLUMN STATUS                FORMAT a10        HEAD 'STATUS'             justify CENTER
COLUMN FUZZY                 FORMAT a08        HEAD 'FUZZY'              justify CENTER
COLUMN CHECKPOINT_CHANGE     FORMAT a25        HEAD 'CHECKPOINT CHANGE'  justify CENTER 
COLUMN CHECKPOINT_TIME       FORMAT a25        HEAD 'CHECKPOINT TIME'    justify CENTER 
COLUMN CNT                   FORMAT 9999999    HEAD 'TOTAL'              justify CENTER 
select status,to_char(checkpoint_change#) checkpoint_change
  , to_char(checkpoint_time, 'YYYY-MM-DD HH24:MI:SS') as checkpoint_time
  , count(*) cnt ,fuzzy
from v$datafile_header
group by status
  , checkpoint_change#
  , checkpoint_time
  , fuzzy
order by status
  , checkpoint_change#
  , checkpoint_time
/
SET FEEDBACK on
PROMPT
PROMPT +-------------------------------------------------------------------------------------------+
PROMPT | Data Guard GAP Status
PROMPT +-------------------------------------------------------------------------------------------+
PROMPT
SET FEEDBACK off
select case when ARC_DIFF <= 3 then ':)' when ARC_DIFF > 3 AND ARC_DIFF <= 8 then ':|' ELSE ':(' END ST
  , z.DATABASE_ROLE
  , z.PROTECTION_MODE
  , z.SWITCHOVER_STATUS
  , z.name
  , z.thread
  , z.STANDBY_LAST_RECEIVED
  , z.STANDBY_LAST_APPLIED
  , z.STANDBY_DT_LAST_APP
  , /*z.data_atual,*/ 
  z.MINUTOS
  , z.ARC_DIFF
from (
SELECT /*+ PARALLEL(8) */
  c.DATABASE_ROLE
  , c.PROTECTION_MODE
  , C.SWITCHOVER_STATUS
  , a.DEST_ID
  , (select max(nvl2(xx.name,xx.DEST_ID || ' - ' || xx.name,null)) from v$archived_log xx where xx.DEST_ID = a.DEST_ID
     and xx.resetlogs_change#=(SELECT resetlogs_change# FROM v$database)
     and SEQUENCE# = (select max(yy.SEQUENCE#) from v$archived_log yy where yy.resetlogs_change# = (SELECT resetlogs_change# FROM v$database) and yy.DEST_ID = xx.DEST_ID)) as name
  , a.thread# thread
  , b.last_seq STANDBY_LAST_RECEIVED 
  , a.applied_seq STANDBY_LAST_APPLIED
  , TO_CHAR(a.last_app_timestamp,'YYYY-MM-DD HH24:MI:SS') as STANDBY_DT_LAST_APP
  , TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS') as data_atual
  , (sysdate - a.last_app_timestamp) *24*60 as MINUTOS
  , b.last_seq - a.applied_seq ARC_DIFF
FROM (SELECT /*+ PARALLEL(8) */
        DEST_ID,thread#
        , Max(sequence#) applied_seq
        , Max(next_time) last_app_timestamp
      FROM gv$archived_log
      WHERE applied = 'YES'
      and resetlogs_change#=(SELECT resetlogs_change# FROM v$database)
      GROUP BY DEST_ID,thread#) a,
       (SELECT /*+ PARALLEL(8) */
          DEST_ID,thread#
          , Max (sequence#) last_seq
        FROM gv$archived_log
        where resetlogs_change#=(SELECT resetlogs_change# FROM v$database)
        GROUP BY DEST_ID,thread#) b,
  (SELECT DATABASE_ROLE
     , DB_UNIQUE_NAME INSTANCE
     , OPEN_MODE
     , PROTECTION_MODE
     , PROTECTION_LEVEL
     , SWITCHOVER_STATUS
   FROM V$DATABASE) c
WHERE a.thread# = b.thread#
and a.DEST_ID = b.DEST_ID) z
where UPPER(z.NAME) NOT LIKE '%ARCHIVELOG%'
and ((z.DATABASE_ROLE = 'PRIMARY'and (z.thread,z.DEST_ID ) in (SELECT INST_ID thread#, DEST_ID FROM GV$ARCHIVE_DEST_STATUS WHERE STATUS <> 'INACTIVE')) or (z.DATABASE_ROLE <> 'PRIMARY'))
order by z.name, z.thread
/
PROMPT 