-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # QUICK TUNE
prompt ##############################################################
COL "MEMORY TYPE" FOR A16
--HEAD "SGA + RATIOS"
--COL "Total_Mem(Ko)" FOR A12
--COL "Free(Ko)" FOR A8
COL "###" FOR A3
COL "MEMORY RATIOS" FOR A28
COL "RATIO %" FOR A7
COL IDEAL FOR A8 ;
compute sum of "Total_Mem K" on report
compute sum of "Free K" on report
break on report ;
select pool as "MEMORY TYPE"
  , Total_Mem as "ALLOCATION K"
  , Free_Mem as "FREE K"
  , '###' "###"
  , RUBRIQUE "MEMORY RATIOS"
  , to_char(round(RATIO*100,1),'999.9') "RATIO %"
  , IDEAL
from (select rownum0, A.pool, A.Total_Mem, B.Free_Mem from (select (rownum) rownum0, A.* from (select pool, round(sum(bytes)/1024,0) Total_Mem from v$sgastat where pool is not null group by pool
UNION
select name, round(bytes/1024) from v$sgastat where pool is null and name !='fixed_sga') A
UNION ALL
select 6,'Sort Area Size' ,round(value/1024,0) from v$parameter where name in ('sort_area_size')
UNION ALL
select 7,'Hash Area Size' ,round(value/1024,0) from v$parameter where name in ('hash_area_size')) A, (select pool, round(bytes/1024,0) Free_Mem from v$sgastat where name = 'free memory'
UNION ALL
select 'DBA_block_buffers', (select count(*) from v$bh where status='free')*(select (round(value/1024,0)) from v$parameter where name = 'DBA_block_size') from dual ) B where A.pool=B.pool(+)) SGA, (select 6 rownum0, 'DATA DICTIONARY CACHE' "RUBRIQUE", sum(getmisses)/sum(gets) "RATIO", ' < 15 %' "IDEAL" from v$rowcache
UNION ALL
select 3,'SHARED POOL HIT RATIO',sum(pinhits-reloads)/sum(pins),' > 85 %' from v$librarycache
UNION ALL
select 4 ,'SHARED POOL RELOAD %',sum (reloads)/sum(pins), ' <  2 %' from v$librarycache
UNION ALL
select 2,'BUFFER CACHE Hit Ratio', (1-(sum(decode(name, 'physical reads', value, 0))/(sum(decode(name, 'db block gets',value,0)) + (sum(decode(name,'consistent gets', value, 0)))))), ' > 95 %' from v$sysstat
UNION ALL
select 1,'BUFFER CACHE MISS RATIO', ((G-F)/(G-F+C+E)),' < 15 %' from (select sum(value) C  from v$sysstat where name like '%- consistent read gets') c, (select value E from v$sysstat where name = 'db block gets') e, (select value F from v$sysstat where name = 'physical reads direct') f, (select value G from v$sysstat where name = 'physical reads') g
UNION ALL
select 5, 'LOG BUFFER REQUESTS Ratio', -- '#Redo Space requests/#redo entries'
((req.value * 50)/entries.value), ' < 0.02%' from v$sysstat req, v$sysstat entries where req.name='redo log space requests' and entries.name = 'redo entries'
UNION ALL
select 7,'MEM SORTS/TOTAL SORTS', mem.value/(mem.value+disk.value),' > 95 %' from v$sysstat mem, v$sysstat disk where mem.name = 'sorts (memory)' and disk.name = 'sorts (disk)') RATIOS where SGA.rownum0(+) = RATIOS.ROWNUM0 order by SGA.rownum0 asc;