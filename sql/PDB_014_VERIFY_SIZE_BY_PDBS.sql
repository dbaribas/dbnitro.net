-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # PDB: VERIFY SIZE BY DATABASES
prompt ##############################################################
col name for a20
select con_id
  , name
  , SUM(SIZE_MB) 
from (select c.con_id
        , nvl(p.name, 'CDB') name
        , sum(bytes)/1024/1024 SIZE_MB 
      from cdb_data_files c, v$pdbs p 
      where c.con_id = p.con_id(+) 
      GROUP BY c.con_id,name
UNION
select c.con_id
  , nvl(p.name, 'CDB') name
  , sum(bytes)/1024/1024 SIZE_MB 
from cdb_temp_files c, v$pdbs p 
where c.con_id = p.con_id(+) 
GROUP BY c.con_id,name)
group by con_id,name
order by con_id;