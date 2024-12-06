-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # VERIFY DYNAMICS PARAMETERS [ SPFILE ]
prompt ##############################################################
col sid for a10
col name for a45
col type for a15
col display_value for a100
select sid
  , name
  , type
  , display_value
from v$spparameter
order by name;