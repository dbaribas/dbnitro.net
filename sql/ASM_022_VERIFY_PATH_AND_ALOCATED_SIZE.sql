-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # ASM: VERIFY PATH AND ALOCATED SIZE
prompt ##############################################################
prompt
col GROUP_NUMBER format 9999 heading "GRP_NO"
col "GRP_NAME" format a24
col "DSK_NAME" format a24
col path format a80
col ALLOC_MB format 999,999,999
col FREE_MB format 999,999,999
col PCT_FREE format 999.00
select d.GROUP_NUMBER
  , g.name "GRP_NAME"
  , d.name "DSK_NAME"
  , d.path
  , d.OS_MB "ALLOC_MB"
  , d.free_MB "FREE_MB"
  , d.free_MB*100/d.OS_MB "PCT_FREE" 
from V$asm_disk d, v$asm_diskgroup g 
where d.GROUP_NUMBER = g.GROUP_NUMBER
order by 1,2,3;