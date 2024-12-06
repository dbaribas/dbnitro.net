-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # CACHE HIT RATIO GOOD: > 90%
prompt ##############################################################
select sum(gets) "Data Dict Gets"
   , sum(getmisses) "Data Dict Cache Misses"
   , round((1-(sum(getmisses)/sum(gets)))*100) "DATA DICT CACHE HIT RATIO"
   , round(sum(getmisses)*100/sum(gets)) "% MISSED"
   , case when round((1-(sum(getmisses)/sum(gets)))*100) < 90 then 'Critical' else 'Status OK' end as status
from v$rowcache;