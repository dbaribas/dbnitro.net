-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
col member FORMAT A90
col group# format 999
col status for a15
col "Thread#" for a10
col TOTAL_MB format 999,999,999,999
col TOTAL_GB format 999,999,999,999
col TOTAL_MB for a20
col TOTAL_GB for a20
break on report
break on top_stat_name skip 1
compute sum of TOTAL_MB on report
compute sum of TOTAL_GB on report
cl break
prompt ##############################################################
prompt # OnLine RedoLogs                                            #
prompt ##############################################################
select t1.GROUP#
   , to_char(t2.thread#) as "Thread#"
   , t1.TYPE
   , t2.status
   , t1.MEMBER
   , t1.IS_RECOVERY_DEST_FILE
   , to_char(t2.bytes/1024/1024, '9G999G999D999') TOTAL_MB
   , to_char(t2.bytes/1024/1024/1024, '999D999') TOTAL_GB
from v$logfile t1, v$log t2
where t1.group# = t2.group#
order by 1,2,3,4;
prompt
prompt ##############################################################
prompt # Standby RedoLogs                                           #
prompt ##############################################################
select s1.group#
  , to_char(s2.THREAD#) as "Thread#"
  , s1.type
  , s2.status
  , s1.member
  , 'N/A' as "N/A"
  , to_char(s2.bytes/1024/1024, '9G999G999D999') TOTAL_MB
  , to_char(s2.bytes/1024/1024/1024, '999D999') TOTAL_GB
from v$logfile s1, v$standby_log s2
where s1.group# = s2.group#
and s1.type = 'STANDBY'
order by 1,2,3,4;
prompt
prompt ##############################################################
prompt # Archiving Details                                          #
prompt ##############################################################
select PROCESS
  , STATUS
  , to_char(THREAD#) as "THREAD#"
  , SEQUENCE#
  , BLOCK#
  , BLOCKS
FROM V$MANAGED_STANDBY;
prompt
prompt ##############################################################
prompt # Utilization of Current Redo Log ( in % )                   #
prompt ##############################################################
column "Percent Full" for 999.99 heading "Percent Full"
select le.leseq "Current log sequence No"
  , 100 * cp.cpodr_bno/le.lesiz "Percent Full"
  , cp.cpodr_bno "Current Block No"
  , le.lesiz "Size of Log in Blocks" 
from x$kcccp cp, x$kccle le 
where le.leseq =CP.cpodr_seq 
and bitand(le.leflg,24) = 8;