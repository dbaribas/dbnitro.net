-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 1000 lines 1000 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # DBA: DATABASE SIZE                                              #
prompt ##############################################################
col "SIZE MB" for a20
col "SIZE GB" for a20
col "SIZE TB" for a20
select to_char(sum(bytes)/1024/1024, '9G999G999D99') "SIZE MB"
  , to_char(sum(bytes)/1024/1024/1024, '9G999G999D99') "SIZE GB"
  , to_char(sum(bytes)/1024/1024/1024/1024, '9G999G999D999') "SIZE TB"
from (select sum(bytes) bytes from dba_data_files
union all
select sum(bytes) bytes from dba_temp_files
union all
select sum(bytes * members) from v$log
union all
select sum(block_size * file_size_blks) from v$controlfile);
prompt
prompt ##############################################################
prompt # DBA: DATAFILES AND DATABASE SIZE
prompt ##############################################################
col files for a30
col db_size for a30
select 'Number of Files: ' || dbms_xplan.FORMAT_NUMBER(count(*)) as FILES
  , 'Database Size: ' || dbms_xplan.FORMAT_SIZE(sum(bytes)) as DB_SIZE
from dba_data_files;