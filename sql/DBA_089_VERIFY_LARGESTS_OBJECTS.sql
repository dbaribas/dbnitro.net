-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set feedback off timing off
alter session set nls_date_format='yyyy-mm-dd';
set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # VERIFY LARGESTS OBJECTS
prompt ##############################################################
col owner format a30
col segment_name format a50
col segment_type format a20
col tablespace_name format a20
col mb format 999,999,999,999
col gb format 999,999,999,999
col tb format 999,999,999,999
select owner
  , segment_name
  , segment_type
  , tablespace_name
  , mb
  , gb
  , tb
from (select owner
        , segment_name
        , segment_type
        , tablespace_name
        , bytes/1024/1024 "MB"
        , bytes/1024/1024/1024 "GB"
        , bytes/1024/1024/1024/1024 "TB"
      from dba_segments
      order by bytes desc)
where rownum < 26;