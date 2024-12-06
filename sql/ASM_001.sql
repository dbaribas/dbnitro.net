-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # 
prompt ##############################################################
col diskgroup for a25
col diskname for a25
col path for a35
select a.name DiskGroup
  , b.name DiskName
  , b.total_mb
  , (b.total_mb-b.free_mb) Used_MB
  , b.free_mb
  , b.path
  , b.header_status
from v$asm_disk b
  , v$asm_diskgroup a
where a.group_number (+) = b.group_number
order by b.group_number, b.name;





set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # 
prompt ##############################################################
select FAILGROUP
  , FAILGROUP_TYPE
  , count(*) 
from v$asm_disk 
group by FAILGROUP, FAILGROUP_TYPE 
order by 1,2,3;



set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # 
prompt ##############################################################
select name
  , disk_number
  , path
  , mount_status
  , header_status
  , mode_status
  , state
  , failgroup
  , repair_timer 
from v$asm_disk 
-- where group_number = 1 
order by disk_number;



set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # 
prompt ##############################################################
col PATH for a50
col HEADER_STATUS for a15
col STATE for a15
col FAILGROUP for a20
col FAILGROUP_TYPE for a25
select group_number as gn
  , path
  , name
  , header_status
  , state
  , failgroup
  , FAILGROUP_TYPE
from v$asm_disk 
order by 1,2,3,4,5;



set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # 
prompt ##############################################################
column "Diskgroup" format A30
column "Imbalance" format 99.9 Heading "Percent|Imbalance"
column "Variance" format 99.9 Heading "Percent|Disk Size|Variance"
column "MinFree" format 999.99 heading "Minimum|Percent|Free"
column "DiskCnt" format 9999 Heading "Disk|Count"
column "Type" format A10 Heading "Diskgroup|Redundancy"
SELECT g.name "Diskgroup"
  , 100*(max((d.total_mb-d.free_mb)/d.total_mb)-min((d.total_mb-d.free_mb)/d.total_mb))/max((d.total_mb-d.free_mb)/d.total_mb) "Imbalance"
  , 100*(max(d.total_mb)-min(d.total_mb))/max(d.total_mb) "Variance"
  , 100*(min(d.free_mb/d.total_mb)) "MinFree"
  , count(*) "DiskCnt"
  , g.type "Type"
FROM v$asm_disk d
  , v$asm_diskgroup g
WHERE d.group_number = g.group_number 
and d.group_number <> 0 
-- and d.state = 'NORMAL' 
-- and d.mount_status = 'CACHED'
GROUP BY g.name, g.type
order by 1,2,3;



set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # 
prompt ##############################################################
column path format a30
column DiskGroup format a15
column DiskName format a30
col free_mb for 999,999,999 
compute sum of total_mb on DiskGroup 
compute sum of free_mb on DiskGroup 
break on DiskGroup skip 1 on report 
select a.name DiskGroup, 
 b.disk_number Disk#, 
 b.name DiskName, 
 b.total_mb, 
 b.free_mb, 
 b.path, 
 b.header_status 
from v$asm_disk b
  , v$asm_diskgroup a 
where a.group_number (+) = b.group_number 
and b.header_status != 'FOREIGN'
order by b.group_number, b.disk_number, b.name;



set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # 
prompt ##############################################################
COLUMN group_name FORMAT a20 HEAD 'Disk Group|Name'
COLUMN sector_size FORMAT 99,999 HEAD 'Sector|Size'
COLUMN block_size FORMAT 99,999 HEAD 'Block|Size'
COLUMN allocation_unit_size FORMAT 999,999,999 HEAD 'Allocation|Unit Size'
COLUMN state FORMAT a11 HEAD 'State'
COLUMN type FORMAT a6 HEAD 'Type'
COLUMN total_mb FORMAT 999,999,999 HEAD 'Total Size (MB)'
COLUMN used_mb FORMAT 999,999,999 HEAD 'Used Size (MB)'
COLUMN pct_used FORMAT 999.99 HEAD 'Pct. Used'
break on report on disk_group_name skip 1
compute sum label "Grand Total: " of total_mb used_mb on report
SELECT
 name group_name
 , sector_size sector_size
 , block_size block_size
 , allocation_unit_size allocation_unit_size
 , state state
 , type type
 , total_mb total_mb
 , (total_mb - free_mb) used_mb
 , ROUND((1 - (free_mb / total_mb)) * 100, 2) pct_used
FROM v$asm_diskgroup
ORDER BY name;



set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # 
prompt ##############################################################
COLUMN disk_group_name FORMAT a20 HEAD 'Disk Group Name'
COLUMN file_name FORMAT a30 HEAD 'File Name'
COLUMN bytes FORMAT 9,999,999,999,999 HEAD 'Bytes'
COLUMN space FORMAT 9,999,999,999,999 HEAD 'Space'
COLUMN type FORMAT a18 HEAD 'File Type'
COLUMN redundancy FORMAT a12 HEAD 'Redundancy'
COLUMN striped FORMAT a8 HEAD 'Striped'
COLUMN creation_date FORMAT a20 HEAD 'Creation Date'
break on report on disk_group_name skip 1
compute sum label "" of bytes space on disk_group_name
compute sum label "Grand Total: " of bytes space on report
SELECT
 g.name disk_group_name
 , a.name file_name
 , f.bytes bytes
 , f.space space
 , f.type type
 , TO_CHAR(f.creation_date, 'YYYY-MON-DD HH24:MI:SS') creation_date
FROM v$asm_file f 
JOIN v$asm_alias a USING (group_number, file_number)
JOIN v$asm_diskgroup g USING (group_number)
WHERE system_created = 'Y'
ORDER BY g.name, file_number;





