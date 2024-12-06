-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # VERIFY PROFILE INFORMATION
prompt ##############################################################
col profile for a40
col resource_type for a30
COL RESOURCE_NAME FOR A40
COL LIMIT FOR A40
select profile
  , resource_name
  , resource_type
  , limit
from dba_profiles
order by 1,2;