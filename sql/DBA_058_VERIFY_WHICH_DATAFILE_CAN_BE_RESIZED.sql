-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # VERIFY WHICH DATAFILE CAN BE RESIZED
prompt ##############################################################
column file_name format a120 word_wrapped
column smallest format 999,999,990 heading "Smallest|Size|Poss."
column currsize format 999,999,990 heading "Current|Size"
column savings format 999,999,990 heading "Poss.|Savings"
break on report
compute sum of smallest on report
compute sum of currsize on report
compute sum of savings on report
column value new_val blksize for a10
prompt ##############################################################
PROMPT # DB BLOCK SIZE                                              #
prompt ##############################################################
select value from v$parameter where name = 'DBA_block_size';
prompt
prompt ##############################################################
prompt # INFORMATIONS ABOUT DATAFILES                               #
prompt ##############################################################
select 'DATAFILE ' as DATAFILE
  , file_name
  , ceil((nvl(hwm,1) * &&blksize)/1024/1024) smallest
  , ceil(blocks * &&blksize/1024/1024) currsize
  , ceil(blocks * &&blksize/1024/1024) - ceil((nvl(hwm,1) * &&blksize)/1024/1024) savings
  , case when ceil(blocks * &&blksize/1024/1024) - ceil((nvl(hwm,1) * &&blksize)/1024/1024) > 100 then 'Recomended' else 'Not Recomended' end as "Recomendation"
from dba_data_files a, (select file_id, max(block_id + blocks - 1) hwm from dba_extents group by file_id) b
where a.file_id = b.file_id(+);
prompt
prompt ##############################################################
prompt # COMMANDS TO RESIZE THE DATAFILES                           #
prompt ##############################################################
column "SQL Command" for a175 word_wrapped
select 'alter database datafile ''' || file_name || ''' resize ' || ceil((nvl(hwm,1) * &&blksize)/1024/1024) || 'M;' as "SQL Command"
from dba_data_files a, (select file_id, max(block_id + blocks - 1) hwm from dba_extents group by file_id) b
where a.file_id = b.file_id(+)
and ceil(blocks*&&blksize/1024/1024) - ceil((nvl(hwm,1)*&&blksize)/1024/1024) > 0;