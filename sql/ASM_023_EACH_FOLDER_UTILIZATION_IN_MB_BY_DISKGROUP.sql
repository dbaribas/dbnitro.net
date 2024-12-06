-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # ASM: EACH FOLDER UTILIZATION IN MB BY DISKGROUP
prompt ##############################################################
prompt
column inst format a20 heading 'Inst'
column file_type format a20 heading 'File type'
column mg format 99,999,999
break on inst skip 1
compute sum  of mg on inst
whenever sqlerror exit 1
select inst
  , file_type
  , sum(mg) mg 
from (select substr(full_alias_path, 2, instr(full_alias_path, '/', 2, 1)-2) as INST
        , file_type
        , round((szbytes)/1048576) as MG 
      from (select lower(concat('', sys_connect_by_path(aname, '/'))) full_alias_path
              , system_created
              , alias_directory
              , file_type
              , szbytes 
            from (select b.name gname
                    , a.parent_index pindex
                    , a.name aname
                    , a.reference_index rindex
                    , a.system_created
                    , a.alias_directory
                    , c.type file_type
                    , c.bytes szbytes
                  from v$asm_alias a, v$asm_diskgroup b, v$asm_file c
                  where a.group_number = b.group_number
                  and a.group_number = c.group_number(+)
                  and a.file_number = c.file_number(+)
                  and a.file_incarnation = c.incarnation(+))
start with (mod(pindex, power(2, 24))) = 0
and rindex in (select a.reference_index 
               from v$asm_alias a, v$asm_diskgroup b 
               where a.group_number = b.group_number 
               and (mod(a.parent_index, power(2, 24))) = 0)
connect by prior rindex = pindex)
where szbytes is not null)
group by inst, file_type;