-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # INSTANCE DIFFERENTS PARAMETERS
prompt ##############################################################
COLUMN name          FORMAT A30
COLUMN current_value FORMAT A110
COLUMN sid           FORMAT A10
COLUMN spfile_value  FORMAT A70
select p.name
  , i.instance_name as sid
  , upper(p.value) as current_value
  , sp.sid
  , upper(sp.value) as spfile_value
FROM v$spparameter sp
  , v$parameter p
  , v$instance i
WHERE sp.name = p.name
AND upper(sp.value) != upper(p.value);