-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # PDB: CHECK PRORPERTIES AND VALUES
prompt ##############################################################
col property_name for a35
col pdb_name for a50
col property_value for a35
col description for a100
select CON_ID 
  , PROPERTY_NAME
  , PROPERTY_VALUE
  , DESCRIPTION
FROM cdb_properties 
order by 1,2,3;