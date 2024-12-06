-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 2000 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # OWNER X OBJECTS X TYPE X QTD
prompt ##############################################################
col owner for a30
col object_type for a20
Clear Breaks
Break on owner Skip 1
Compute Sum LABEL 'TOTAL' Of Qtde On owner
select owner
  , object_type
  , count(*) Qtde 
from dba_objects 
where owner not in ('SYS','SYSTEM','SYSMAN','DBSNMP') 
group by owner, object_type
union
select owner
  , 'CONSTRAINT ' || constraint_type
  , count(*) 
from dba_constraints 
where owner not in ('SYS','SYSTEM','SYSMAN','DBSNMP') 
group by owner, 'CONSTRAINT ' || constraint_type;
prompt
prompt ##############################################################
prompt # SHOW SIZE BY OWNER
prompt ##############################################################
col owner for a30
SELECT * 
FROM (SELECT OWNER
        , SUM(BYTES)/1048576 MB
      from DBA_SEGMENTS 
      GROUP BY OWNER ORDER BY MB DESC) 
WHERE ROWNUM < 20;