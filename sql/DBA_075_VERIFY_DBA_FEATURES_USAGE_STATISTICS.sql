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
prompt # VERIFY DBA FEATURES USAGE STATISTICS
prompt ##############################################################
col "NAME" for a70
col "DETECTED USAGES" for a20
col "USING NOW Y/N" for a15
select name
  , case when DETECTED_USAGES = 0 then 'Never Used' else to_char(DETECTED_USAGES) || ' Time(s) Used' end as "DETECTED USAGES"
  , case when CURRENTLY_USED = 'FALSE' then 'Not Using' when CURRENTLY_USED = 'TRUE' then 'Using' else 'UNKNOWN' end as "USING NOW Y/N"
  , FIRST_USAGE_DATE
  , LAST_USAGE_DATE
from dba_feature_usage_statistics a, v$instance b
where a.version = b.version
order by 1;