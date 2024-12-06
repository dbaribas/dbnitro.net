-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # INSTANCE MODIFICABLES PARAMETERS
prompt ##############################################################
COLUMN name  FORMAT A50
COLUMN value FORMAT A110
select p.name
  , p.type
  , p.value
  , p.isses_modifiable
  , p.issys_modifiable
  , p.isinstance_modifiable
FROM v$parameter p
ORDER BY p.name;