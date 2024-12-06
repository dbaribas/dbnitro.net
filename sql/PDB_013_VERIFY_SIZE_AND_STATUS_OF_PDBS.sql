-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # PDB: VERIFY SIZE AND STATUS OF DATABASES
prompt ##############################################################
COL NAME FOR A30
select name
  , open_mode
  , restricted
  , to_char(creation_time, 'DD/MM/YYYY HH24:MI:SS') as created
  , total_size/1024/1024/1024 as GB
from v$PDBS
order by 1,2,3;