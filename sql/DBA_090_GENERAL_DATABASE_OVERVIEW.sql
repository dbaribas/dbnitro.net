-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set feedback off timing off
alter session set nls_date_format='yyyy-mm-dd';
set pages 1000 lines 5000 timing off long 9999999 numwidth 20 heading on echo off verify on colsep '|' head off TRIMSPOOL ON NEWPAGE NONE
prompt ##############################################################
prompt # GENERAL DATABASE OVERVIEW
prompt ##############################################################
col PROPERTY_NAME for a25
col PROPERTY_VALUE for a15
col DESCRIPTION for a35
col DIRECTORY_PATH for a70
col directory_name for a25
col OWNER for a10
col DBA_LINK for a40
col HOST for a20
col "User_Concurrent_Queue_Name" format a50 heading 'Manager'
col "Running_Processes" for 9999 heading 'Running'
break on utl_file_dir
select '------------------------ Getting Database Information ------------------------' from dual;
select 'Database Name.....................: ' || name from v$database;
select 'Database Status...................: ' || open_mode from v$database;
select 'Archiving Status..................: ' || log_mode from v$database;
select 'Global Name.......................: ' || global_name from global_name;
select 'Service Name......................: ' || value from v$parameter where name = 'service names';
select 'Creation Date.....................: ' || to_char(created,'yyyy-mm-dd HH24:MI:SS') from v$database;
select 'Checking For Missing File.........: ' || count(*) from v$recover_file;
select 'Checking Missing File Name .......: ' || count(*) from v$datafile where name like '%MISS%';
select 'Total SGA MB......................: ' || round(sum(value)/(1024*1024)) || ' MB' from v$sga ;
select 'Total SGA GB......................: ' || round(sum(value)/(1024*1024*1024)) || ' GB' from v$sga ;
select 'Total SGA TB......................: ' || round(sum(value)/(1024*1024*1024*1024)) || ' TB' from v$sga ;
select 'Database Version..................: ' || version from v$instance;
select 'Database Size MB..................: ' || trim(to_char(sum(bytes)/1024/1024,'9G999G999D99')) || ' MB' from (select sum(bytes) bytes from dba_data_files
union all
select sum(bytes) bytes from dba_temp_files
union all
select sum(bytes * members) from v$log
union all
select sum(block_size * file_size_blks) from v$controlfile);
select 'Database Size GB..................: ' || trim(to_char(sum(bytes)/1024/1024/1024,'9G999G999D99')) || ' GB' from (select sum(bytes) bytes from dba_data_files
union all
select sum(bytes) bytes from dba_temp_files
union all
select sum(bytes * members) from v$log
union all
select sum(block_size * file_size_blks) from v$controlfile);
select 'Database Size TB..................: ' || trim(to_char(sum(bytes)/1024/1024/1024/1024,'9G999G999D99')) || ' TB' from (select sum(bytes) bytes from dba_data_files
union all
select sum(bytes) bytes from dba_temp_files
union all
select sum(bytes * members) from v$log
union all
select sum(block_size * file_size_blks) from v$controlfile);
select 'Temporary Tablespace..............: ' || property_value from database_properties where property_name like 'default_temp_tablespace';
select 'Apps Temp Tablespace..............: ' || temporary_tablespace from dba_users where username like '%APPS%';
select 'Temp Tablespace Size..............: ' || sum(maxbytes/1024/1024/1024) || ' GB' from dba_temp_files group by tablespace_name;
select 'No of Invalid Object .............: ' || count(*) from dba_objects where status = 'INVALID' ;
select 'plsql Code Type...................: ' || value from v$parameter2 where name = 'plsql_code_type';
select 'plsql Subdir Count................: ' || value from v$parameter2 where name = 'plsql_native_library_subdir_count';
select 'plsql Native Library Dir..........: ' || value from v$parameter2 where name = 'plsql_native_library_dir';
select 'Shared Pool Size.........,........: ' || (value/1024/1024) || ' MB' from v$parameter where name = 'shared_pool_size';
select 'Log Buffer........................: ' || (value/1024/1024) || ' MB' from v$parameter where name = 'log_buffer';
select 'Buffer Cache MB...................: ' || (value/1024/1024) || ' MB' from v$parameter where name = 'DBA_cache_size';
select 'Buffer Cache GB...................: ' || (value/1024/1024/1024) || ' GB' from v$parameter where name = 'DBA_cache_size';
select 'Buffer Cache TB...................: ' || (value/1024/1024/1024/1024) || ' TB' from v$parameter where name = 'DBA_cache_size';
select 'Large Pool Size MB................: ' || (value/1024/1024) || ' MB' from v$parameter where name = 'large_pool_size';
select 'Large Pool Size GB................: ' || (value/1024/1024/1024) || ' GB' from v$parameter where name = 'large_pool_size';
select 'Java Pool Size MB.................: ' || (value/1024/1024) || ' MB' from v$parameter where name = 'java_pool_size';
select 'Java Pool Size GB.................: ' || (value/1024/1024/1024) || ' GB' from v$parameter where name = 'java_pool_size';
select 'utl_file_dir......................: ' || value from v$parameter2 where name = 'utl_file_dir';
select directory_name || '................: ' || directory_path from all_directories where rownum < 15;