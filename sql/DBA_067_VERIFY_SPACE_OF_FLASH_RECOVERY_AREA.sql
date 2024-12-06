-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # VERIFY SPACE OF FLASH RECOVERY AREA
prompt ##############################################################
col name for a75
col size_m for 999,999,999
col used_m for 999,999,999
col "% USED" for a30
select name
   , ceil(space_limit/1024/1024) SIZE_M
   , ceil(space_used/1024/1024) USED_M
   , case when ceil((space_used/space_limit)*100) < 80 then ceil((space_used/space_limit)*100) || '% - Status OK' when ceil((space_used/space_limit)*100) < 90 then ceil((space_used/space_limit)*100) || '% - Warning' else ceil((space_used/space_limit)*100) || '% - Critical' end as "% USED"
-- , decode(nvl(space_used, 2), 0, 0) as "#"
FROM v$recovery_file_dest
ORDER BY name;
prompt
prompt ##############################################################
prompt # VERIFY SPACE OF FLASH RECOVERY AREA - DETAILS
prompt ##############################################################
col "Status Space" for a20
select FILE_TYPE
   , PERCENT_SPACE_USED
   , PERCENT_SPACE_RECLAIMABLE
   , NUMBER_OF_FILES
-- , CON_ID
   , case when PERCENT_SPACE_USED < 80 then 'Space OK' when PERCENT_SPACE_USED < 90 then 'Warning' else 'Critical' end as "Status Space"
FROM V$RECOVERY_AREA_USAGE;