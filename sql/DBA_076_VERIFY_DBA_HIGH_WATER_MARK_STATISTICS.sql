-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # VERIFY DBA HIGH WATER MARK STATISTICS
prompt ##############################################################
col NAME for a30
col VERSION for a15
col HIGHWATER for a20
col LAST_VALUE for a20
col DESCRIPTION for a70
select distinct a.NAME
  , a.VERSION
  , to_char(HIGHWATER) as HIGHWATER
  , to_char(LAST_VALUE) as LAST_VALUE
  , DESCRIPTION
from DBA_HIGH_WATER_MARK_STATISTICS a, v$instance b
where a.version = b.version
order by 1,2;