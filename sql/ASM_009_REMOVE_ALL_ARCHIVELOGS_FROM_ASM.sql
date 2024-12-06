-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # ASM: REMOVING ALL ARCHIVELOGS FROM ASM
prompt ##############################################################
prompt
col command for a180
SELECT 'alter diskgroup ' || dg.name || ' drop file ''+' || dg.name || '' || SYS_CONNECT_BY_PATH(al.name,'/') || ''';' as command
FROM v$asm_alias al, v$asm_file fi, v$asm_diskgroup dg
WHERE al.file_number = fi.file_number(+)
AND al.group_number = dg.group_number
AND fi.type = 'ARCHIVELOG'
START WITH alias_index = 0
CONNECT BY PRIOR al.reference_index = al.parent_index;