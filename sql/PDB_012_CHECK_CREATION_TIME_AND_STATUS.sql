-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # PDB: CHECK CREATION TIME AND STATUS
prompt ##############################################################
col pdb_name for a30
select pdb_name
  , to_char(creation_time, 'dd/mm/yyyy hh24:mi:ss') as creation_time
  , status 
from dba_pdbs
order by 1,2,3;