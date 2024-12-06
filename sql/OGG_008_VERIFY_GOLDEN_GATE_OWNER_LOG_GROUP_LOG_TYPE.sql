-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 1000 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # OGG: VERIFY GOLDENGATE OWNER, LOG_GROUP, LOG_TYPE
prompt ##############################################################
col owner format a20
col table_name for a20
col log_group_name format a20
col log_group_type format a20
select owner
  , log_group_name
  , table_name
  , log_group_type
  , always
  , generated
from dba_log_groups;
-- where owner = 'WLPAPP'
-- and log_group_name like 'OGGS%';