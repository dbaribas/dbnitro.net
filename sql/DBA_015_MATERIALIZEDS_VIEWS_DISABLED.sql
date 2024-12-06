-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # MATERIALIZEDS VIEWS DISABLED
prompt ##############################################################
col owner for a20
col type for a20
select owner
   , type
   , tablespace_name
   , round(sum(mb)) as mb
from (select owner,'mview' as type, tablespace_name, round(sum(bytes)/1024/1024) as mb from dba_segments where (owner,segment_name) in
     (select owner, mview_name from dba_mviews) group by owner, segment_type, tablespace_name
union
select owner
  , 'mview_log' as type
  , tablespace_name
  , round(sum(bytes)/1024/1024) as mb
from dba_segments
where (owner, segment_name) in
(select log_owner, log_table from dba_snapshot_logs)
group by owner, segment_type, tablespace_name
union
select owner
  , 'mview_index' as type
  , tablespace_name
  , round(sum(bytes)/1024/1024) as mb
from dba_segments
where (owner,segment_name) in
(select owner, index_name from dba_indexes where (owner,table_name) in
(select owner, mview_name from dba_mviews))
group by owner, segment_type, tablespace_name) t1
group by owner,type,tablespace_name;