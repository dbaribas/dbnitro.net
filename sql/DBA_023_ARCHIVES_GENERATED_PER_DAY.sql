-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set feedback off timing off
alter session set nls_date_format='yyyy-mm-dd';
set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # ARCHIVES GENERATED PER DAY
prompt ##############################################################
col day for a20
col SIZE_MB for a20
col SIZE_GB for a20
col SIZE_TB for a20
select trunc(first_time) as day
  , to_char(sum(blocks * block_size)/1024/1024,'9G999G999D999') SIZE_MB
  , to_char(sum(blocks * block_size)/1024/1024/1024,'9G999G999D999') SIZE_GB
  , to_char(sum(blocks * block_size)/1024/1024/1024/1024,'9G999G999D999') SIZE_TB
from gv$archived_log
where trunc(first_time) > sysdate -30
and trunc(first_time) < sysdate +1
group by trunc(first_time)
order by 1;