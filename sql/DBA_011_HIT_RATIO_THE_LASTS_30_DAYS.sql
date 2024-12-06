-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set feedback off timing off
exec dbms_application_info.set_action('latches');
set pages 2000 lines 2000 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # HIT RATIO THE LASTS 30 DAYS
prompt ##############################################################
col name for a60
col instance_name for a30
select instance_name
   , name
   , case when hit_ratio < 95 then 'Warning' when hit_ratio < 99 then 'Critical' end as hit_ratio
   , sleep_miss
from (select i.instance_name, l.name, round((gets-misses)/decode(gets,0,1,gets),3)*100 hit_ratio, round(sleeps/decode(misses,0,1,misses),3) sleep_miss
from gv$latch l, gv$instance i
where l.gets != 0
and l.inst_id = i.inst_id)
where hit_ratio < 100
order by hit_ratio;