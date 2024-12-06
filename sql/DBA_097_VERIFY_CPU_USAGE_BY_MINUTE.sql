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
prompt # VERIFY CPU USAGE BY MINUTE
prompt ##############################################################
col sample_time for a20
col CONFIGURATION head "CONFIG" for 99.99
col ADMINISTRATIVE head "ADMIN" for 99.99
col OTHER for 99.99
col OTHER for a10
col CLUST for a10
col QUEUEING for a10
col NETWORK for a10
col ADMINISTRATIVE for a10
col CONFIGURATION for a10
col COMMIT for a10
col APPLICATION for a15
col CONCURRENCY for a15
col SYSTEM_IO for a10
col USER_IO for a10
col SCHEDULER for a10
col CPU for a10
col BACKGROUND_CPU for a15
SELECT TO_CHAR(SAMPLE_TIME, 'yyyy-mm-dd HH24:MI:SS') AS SAMPLE_TIME
  , to_char(ROUND(OTHER/60, 3)) AS OTHER
  , to_char(ROUND(CLUST/60, 3)) AS CLUST
  , to_char(ROUND(QUEUEING/60, 3)) AS QUEUEING
  , to_char(ROUND(NETWORK/60, 3)) AS NETWORK
  , to_char(ROUND(ADMINISTRATIVE/60, 3)) AS ADMINISTRATIVE
  , to_char(ROUND(CONFIGURATION/60, 3)) AS CONFIGURATION
  , to_char(ROUND(COMMIT/60, 3)) AS COMMIT
  , to_char(ROUND(APPLICATION/60, 3)) AS APPLICATION
  , to_char(ROUND(CONCURRENCY/60, 3)) AS CONCURRENCY
  , to_char(ROUND(SIO/60, 3)) AS SYSTEM_IO
  , to_char(ROUND(UIO/60, 3)) AS USER_IO
  , to_char(ROUND(SCHEDULER/60, 3)) AS SCHEDULER
  , to_char(ROUND(CPU/60, 3)) AS CPU
  , to_char(ROUND(BCPU/60, 3)) AS BACKGROUND_CPU
FROM (SELECT TRUNC(SAMPLE_TIME, 'MI') AS SAMPLE_TIME
        , DECODE(SESSION_STATE, 'ON CPU'
	      , DECODE(SESSION_TYPE, 'BACKGROUND', 'BCPU', 'ON CPU')
	      , WAIT_CLASS) AS WAIT_CLASS 
      FROM V$ACTIVE_SESSION_HISTORY 
      WHERE SAMPLE_TIME > SYSDATE - INTERVAL '2' HOUR 
      AND SAMPLE_TIME <= TRUNC(SYSDATE, 'MI')) ASH PIVOT(COUNT(*) FOR WAIT_CLASS IN 
      ('ON CPU' AS CPU
       , 'BCPU' AS BCPU
       , 'Scheduler' AS SCHEDULER
       , 'User I/O' AS UIO
       , 'System I/O' AS SIO
       , 'Concurrency' AS CONCURRENCY
       , 'Application' AS APPLICATION
       , 'Commit' AS COMMIT
       , 'Configuration' AS CONFIGURATION
       , 'Administrative' AS ADMINISTRATIVE
       , 'Network' AS NETWORK
       , 'Queueing' AS QUEUEING
       , 'Cluster' AS CLUST
       , 'Other' AS OTHER))
order by 1;