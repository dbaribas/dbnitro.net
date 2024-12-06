-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # PDB: VERIFY PROPERTIES OF SNAPSHOTS ON PDBS
prompt ##############################################################
col property_name for a20
col pdb_name for a10
col property_value for a15
col description for a50
select pr.con_id
  , p.pdb_name
  , pr.property_name
  , pr.property_value
  , pr.description 
FROM cdb_properties pr
JOIN cdb_pdbs p ON pr.con_id = p.con_id 
WHERE pr.property_name = 'MAX_PDBA_SNAPSHOTS' 
ORDER BY pr.property_name;