-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # ASM: FILES THAT ARE NOTE IN USE CURRENTLY ON ASM DISKS
prompt ##############################################################
prompt
col full_alias_path format a100
col ftype format a20
select * 
from (select x.gnum
        , x.filnum
        , x.full_alias_path
        , f.ftype 
      from (SELECT gnum
              , filnum
              , concat('+'||gname, sys_connect_by_path(aname, '/')) full_alias_path
            FROM (SELECT g.name gname
                    , a.parent_index pindex
                    , a.name aname
                    , a.reference_index rindex
                    , a.group_number gnum
                    , a.file_number filnum
                  FROM v$asm_alias a, v$asm_diskgroup g
                  WHERE a.group_number = g.group_number)
START WITH (mod(pindex, power(2, 24))) = 0 CONNECT BY PRIOR rindex = pindex) x,
(select group_number gnum
   , file_number filnum
   , type ftype 
 from v$asm_file order by group_number,file_number) f
where x.filnum != 4294967295
and x.gnum = f.gnum 
and x.filnum = f.filnum
MINUS
select x.gnum
  , x.filnum
  , x.full_alias_path
  , f.ftype
from (select id1 gnum
        ,id2 filnum 
      from v$lock 
      where type = 'FA' 
      and (lmode=4 or lmode=2)) l
      , (SELECT gnum
           , filnum
           , concat('+'||gname, sys_connect_by_path(aname, '/')) full_alias_path
         FROM (SELECT g.name gname
                 , a.parent_index pindex
                 , a.name aname
                 , a.reference_index rindex
                 , a.group_number gnum
                 , a.file_number filnum
               FROM v$asm_alias a, v$asm_diskgroup g
               WHERE a.group_number = g.group_number)
START WITH (mod(pindex, power(2, 24))) = 0 CONNECT BY PRIOR rindex = pindex) x, 
(select group_number gnum
   , file_number filnum
   , type ftype 
 from v$asm_file 
 order by group_number,file_number) f
where x.filnum != 4294967295 
and x.gnum = l.gnum
and x.filnum = l.filnum 
and x.gnum = f.gnum 
and x.filnum = f.filnum) q
order by q.gnum, q.ftype;