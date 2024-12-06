-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # PDB: VERIFY VIOLATIONS ON PDBS
prompt ##############################################################
col time for a20
col message for a180
select to_char(time, 'dd/mm/yyyy hh24:mi:ss') as time
  , substr(message, 1,180) as message
from pdb_plug_in_violations;