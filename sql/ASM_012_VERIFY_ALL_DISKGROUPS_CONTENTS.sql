-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # ASM: VERIFY ALL DISKGROUPS CONTENTS
prompt ##############################################################
prompt
col full_path format a150
col full_alias_path format a150
SELECT concat('+' || gname, sys_connect_by_path(aname, '/')) full_alias_path
FROM (SELECT g.name gname, a.parent_index pindex, a.name aname, a.reference_index rindex FROM v$asm_alias a, v$asm_diskgroup g WHERE a.group_number = g.group_number)
START WITH (mod(pindex, power(2, 24))) = 0 
CONNECT BY PRIOR 
rindex = pindex
order by 1;