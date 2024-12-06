-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # ASM: VERIFY DISK GROUP % USAGE
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
FROM v$asm_disk d, v$asm_diskgroup g
WHERE d.group_number = g.group_number 
and d.group_number <> 0 
-- and d.state = 'NORMAL' 
and d.mount_status = 'CACHED'
GROUP BY g.name, g.type; 