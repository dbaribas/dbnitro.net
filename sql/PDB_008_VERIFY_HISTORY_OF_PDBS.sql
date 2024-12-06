-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # PDB: VERIFY THE HISTORY OF PDBS
prompt ##############################################################
col db_name for a10 
col CLONED_FROM_PDB_NAME for a25 
col pdb_name for a18 
select DB_NAME
  , CON_ID
  , PDB_NAME
  , OPERATION
  , to_char(OP_TIMESTAMP, 'dd/mm/yyyy hh24:mi:ss') as time
  , CLONED_FROM_PDB_NAME
FROM CDB_PDB_HISTORY
order by con_id;