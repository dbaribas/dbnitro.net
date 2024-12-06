-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # TOP 20 DB-CPU ACTIVITY                                     #
prompt ##############################################################
col STAT_NAME for a50
col "% PERC" for a10
select STAT_NAME
  , TIME_WAITED
  , case when pct_waited >= 0.5 then 'Critical' when pct_waited >= 0.2 then 'Warning' end as "Status"
  , to_char(round(pct_waited*100,1), '999D00') || '%' as "% PERC"
from (select STAT_NAME, time_waited, TIME_WAITED/sum(time_waited) over () pct_waited
from (select STAT_NAME, round(sum(VALUE)/(1000*1000)) AS time_waited
from GV$SYS_TIME_MODEL
group by STAT_NAME)
order by 2 desc)
where rownum <= 20;