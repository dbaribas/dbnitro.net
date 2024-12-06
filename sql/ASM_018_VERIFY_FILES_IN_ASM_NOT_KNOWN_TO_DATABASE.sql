-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # ASM: VERIFY FILES IN ASM NOT KNOWN TO DATABASE
prompt ##############################################################
prompt
col full_alias_path for a120
col file_type for a30
select concat('+'||gname, sys_connect_by_path(aname, '/')) full_alias_path
  , system_created
  , alias_directory
  , file_type
from (select b.name gname
        , a.parent_index pindex
        , a.name aname
        , a.reference_index rindex
        , a.system_created
        , a.alias_directory
        , c.type file_type
      from v$asm_alias a, v$asm_diskgroup b, v$asm_file c
      where a.group_number = b.group_number
      and a.group_number = c.group_number(+)
      and a.file_number = c.file_number(+)
      and a.file_incarnation = c.incarnation(+))
where alias_directory = 'N'
start with (mod(pindex, power(2, 24))) = 0
and rindex in (select a.reference_index from v$asm_alias a, v$asm_diskgroup b where a.group_number = b.group_number and (mod(a.parent_index, power(2, 24))) = 0)
connect by prior rindex = pindex;