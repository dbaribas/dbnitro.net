-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # PDB: VERIFY SNAPSHOT REFRESH ON PDBS
prompt ##############################################################
col pdb_name for a15
select pdb_id
  , pdb_name
  , status
  , refresh_mode
  , logging
from dba_pdbs
order by 1,2,3;