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
prompt # Patches Status                                             #
prompt # Registry History                                           #
prompt ##############################################################
col time for a25
col Target for a35
col Action for a100
col action_time for a40
col product for a50
col version for a30
col status for a30
col comments for a30
select to_char(action_time,'yyyy-mm-dd HH24:MI:SS') time
  , namespace || ' ' || version as Target
  , action || ' ' || comments as Action
  , version
  , case when action_time < sysdate - 120 then 'Need Patch Apply' else 'Updated Recently' end as "Patch Info"
from dba_registry_history
order by action_time;
prompt ##############################################################
prompt # PSU History                                                #
prompt ##############################################################
col action for a20
col namespace for a40
col version for a30
col comments for a100
select to_char(action_time,'yyyy-mm-dd HH24:MI:SS') as TIME
  , ACTION
  , NAMESPACE
  , VERSION
--  , BUNDLE_SERIES
  , COMMENTS
from sys.registry$history
-- where bundle_series = 'PSU'
order by action_time;
prompt ##############################################################
prompt # Product Components                                         #
prompt ##############################################################
col version for a40
col status for a50
select PRODUCT
  , VERSION
  , status
FROM SYS.PRODUCT_COMPONENT_VERSION;