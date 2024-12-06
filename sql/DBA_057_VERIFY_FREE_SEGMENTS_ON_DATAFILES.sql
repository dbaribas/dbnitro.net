-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 5000 lines 5000 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # VERIFY FREE SEGMENTS ON DATAFILES
prompt ##############################################################
col "Name" for a50
select file_id
  , block_id
  , blocks*8192/1024 MB
  , owner || '.' || segment_name "Name"
  , block_id*8192/1024 "Position MB"
from  dba_Extents
where file_id = 21
union
select file_id
  , block_id
  , blocks*8192/1024, 'Free' "Name"
  , block_id*8192/1024 "Position MB"
from dba_free_space
order by 1,2,3;