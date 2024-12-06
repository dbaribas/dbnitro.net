-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # PDB: VERIFY SNAPSHOTS ON PDBS
prompt ##############################################################
col pdb_name for a10
col snapshot_mode for a15
select p.con_id
  , p.pdb_name
  , p.snapshot_mode
  , p.snapshot_interval
FROM cdb_pdbs p
ORDER BY 1;