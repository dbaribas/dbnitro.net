-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # INVALIDS OBJECTS
prompt ##############################################################
col owner for a25
col OBJECT_TYPE for a25
col "Total of invalids objects." for a30
select owner
   , decode(object_type,null,'========================>', object_type) as "OBJECT_TYPE"
   , count(object_type) as "TOTAL"
   , decode(grouping(owner),0,null,1,'Total of invalids objects.') as " "
from dba_objects where status <> 'VALID'
group by rollup (owner, object_type)
order by owner, object_type desc;