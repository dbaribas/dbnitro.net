-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # PDB: VERIFY AVAILABILITY OF SNAPSHOTS ON PDBS
prompt ##############################################################
col con_name for a10
col snapshot_name for a30
col snapshot_scn for 9999999
col full_snapshot_path for a50
select con_id
  , con_name
  , snapshot_name
  , snapshot_scn
  , full_snapshot_path 
FROM cdb_pdb_snapshots
ORDER BY con_id, snapshot_scn;