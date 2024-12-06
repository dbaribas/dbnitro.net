-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set feedback off timing off
exec dbms_application_info.set_action('DB growth');
alter session set nls_date_format='yyyy-mm-dd';
set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
col month for a20
col GROWTH_MB format 999,999,999,999,999
col GROWTH_GB format 999,999,999,999,999
col GROWTH_TB format 999,999,999,999,999
col GROWTH_MB for a25
col GROWTH_GB for a25
col GROWTH_TB for a25
prompt ##############################################################
prompt # DATABASE GROWN ON LASTS MONTHS                             #
prompt ##############################################################
select trunc(creation_time, 'MM') month
  , to_char(round(sum(bytes/1024/1024)), '9G999G999') growth_mb
  , to_char(round(sum(bytes/1024/1024/1024)), '9G999G999') growth_gb
  , to_char(round(sum(bytes/1024/1024/1024/1024)), '9G999G999') growth_tb
FROM v$datafile
GROUP BY trunc(creation_time, 'MM')
ORDER BY trunc(creation_time, 'MM');
prompt
prompt ##############################################################
prompt # VERIFY DATABASE ENCREASY PER DAY / WEEK / MONTH
prompt ##############################################################
COL "Database Size" FORMAT a13
COL "Used Space" FORMAT a11
COL "Used in %" FORMAT a11
COL "Free in %" FORMAT a11
COL "Database Name" FORMAT a13
COL "Free Space" FORMAT a12
COL "Growth DAY" FORMAT a11
COL "Growth WEEK" FORMAT a12
COL "Growth MONTH" FORMAT a12
COL "Growth DAY in %" FORMAT a16
COL "Growth WEEK in %" FORMAT a16
COL "Growth MONTH in %" FORMAT a16
SELECT (select min(to_char(creation_time, 'yyyy-mm-dd HH24:mm:ss')) from v$datafile)                                                                                                        "Create Time"
  , (select name from v$database)                                                                                                                                                           "Database Name"
  , ROUND((SUM(USED.BYTES)/1024/1024/1024),2)                                                                                                                                     || ' GB'  "Database Size"
  , ROUND((SUM(USED.BYTES)/1024/1024/1024) - ROUND(FREE.K/1024/1024/1024),2)                                                                                                      || ' GB'  "Used Space"
  , ROUND(((SUM(USED.BYTES)/1024/1024/1024) - (FREE.K/1024/1024/1024))/ROUND(SUM(USED.BYTES)/1024/1024/1024,2)*100,2)                                                             || '% GB' "Used in %"
  , ROUND((FREE.K/1024/1024/1024),2)                                                                                                                                              || ' GB'  "Free Space"
  , ROUND(((SUM(USED.BYTES)/1024/1024/1024) - ((SUM(USED.BYTES)/1024/1024/1024) - ROUND(FREE.K/1024/1024/1024)))/ROUND(SUM(USED.BYTES)/1024/1024/1024,2 )*100,2)                  || '% GB' "Free in %"
  , ROUND(((SUM(USED.BYTES)/1024/1024/1024) - (FREE.K/1024/1024/1024))/(select sysdate-min(creation_time) from v$datafile),2)                                                     || ' GB'  "Growth DAY"
  , ROUND(((SUM(USED.BYTES)/1024/1024/1024) - (FREE.K/1024/1024/1024))/(select sysdate-min(creation_time) from v$datafile)/ROUND((SUM(USED.BYTES)/1024/1024/1024),2)*100,3)       || '% GB' "Growth DAY in %"
  , ROUND(((SUM(USED.BYTES)/1024/1024/1024) - (FREE.K/1024/1024/1024))/(select sysdate-min(creation_time) from v$datafile)*7,2)                                                   || ' GB'  "Growth WEEK"
  , ROUND((((SUM(USED.BYTES)/1024/1024/1024) - (FREE.K/1024/1024/1024))/(select sysdate-min(creation_time) from v$datafile)/ROUND((SUM(USED.BYTES)/1024/1024/1024),2)*100)*7,3)   || '% GB' "Growth WEEK in %"
  , ROUND(((SUM(USED.BYTES)/1024/1024/1024) - (FREE.K/1024/1024/1024))/(select sysdate-min(creation_time) from v$datafile)*30,2)                                                  || ' GB'  "Growth MONTH"
  , ROUND((((SUM(USED.BYTES)/1024/1024/1024) - (FREE.K/1024/1024/1024))/(select sysdate-min(creation_time) from v$datafile)/ROUND((SUM(USED.BYTES)/1024/1024/1024),2)*100)*30,3)  || '% GB' "Growth MONTH in %"
FROM (SELECT BYTES FROM V$DATAFILE
UNION ALL
SELECT BYTES FROM V$TEMPFILE
UNION ALL
SELECT BYTES FROM V$LOG) USED, (SELECT SUM(BYTES) AS K FROM dba_free_space) FREE
GROUP BY FREE.K;