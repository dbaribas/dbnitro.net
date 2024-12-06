-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
set feedback off serverout on wrap off
prompt ##############################################################
prompt # PREPARE FOR PATCHING
prompt ##############################################################
col file_name for a50
col name for a50
col member for a50
col file_id for a5
col "Percent Used" for a20
col segment_name for a30
col tablespace_name for a30
col STATUS for a16
col owner for a20
col table_name for a35
col index_name for a35
col username format a25
col default_tablespace format a25
col temporary_tablespace format a25
prompt ##############################################################
prompt # DATABASE HEALTH CHECK REPORT
prompt ##############################################################
prompt # DATABASE STATUS
prompt ##############################################################
select INSTANCE_NAME, STATUS, DATABASE_STATUS, ACTIVE_STATE, STARTUP_TIME from gv$instance;
prompt ##############################################################
prompt # DATABASE NAME AND MODE
prompt ##############################################################
select name, open_mode, log_mode from gv$database;
prompt ##############################################################
prompt # COUNT OF TABLESPACES
prompt ##############################################################
select count(*) AS "No. of tablespaces" from v$tablespace;
prompt ##############################################################
prompt # COUNT OF DATAFILES
prompt ##############################################################
select count(*) AS "No. of Datafiles" from dba_data_files;
prompt ##############################################################
prompt # COUNT OF INVALID OBJECTS
prompt ##############################################################
select count(*) from dba_objects where status='INVALID';
prompt ##############################################################
prompt # COUNT OF ARCHIVED GENERATED LAST DAY
prompt ##############################################################
Select count(*) "No. of Archive Logs generated" from v$log_history  where to_char(first_time,'yyyy-mm-dd') in (to_char(sysdate-1,'yyyy-mm-dd'));
prompt ##############################################################
prompt # DB PHYSICAL SIZE
prompt ##############################################################
select sum(bytes/1024/1024/1024) "DB Physical Size(GB)" from dba_data_files;
prompt ##############################################################
prompt # DB ACUTAL SIZE
prompt ##############################################################
select sum(bytes/1024/1024/1024) "DB Actual Size(GB)" from dba_segments;
prompt ##############################################################
prompt # PATCH APPLIED
prompt ##############################################################
col action_time for a28
col action for a8
col version for a8
col comments for a30
col status for a10
select patch_id,  version, status, Action,Action_time from dba_registry_sqlpatch order by action_time;
prompt ##############################################################
prompt # INVALID OBJECTS
prompt ##############################################################
Select count(*) from dba_objects where status='INVALID';
prompt ##############################################################
prompt # Check registry component status
prompt ##############################################################
col comp_id for a10
col version for a11
col status for a10
col comp_name for a38
select comp_id,comp_name,version,status from dba_registry;
prompt ##############################################################
prompt # Check the SYSTEM and SYSAUS tablespace
prompt ##############################################################
column "MAXSIZE (MB)"  format 9,999,990.00
column "USED (MB)" format 9,999,990.00
select a.tablespace_name
  , a.bytes_alloc/(1024*1024) "MAXSIZE (MB)"
  , nvl(b.tot_used,0)/(1024*1024) "USED (MB)" 
from (select tablespace_name, sum(bytes) physical_bytes, sum(decode(autoextensible, 'NO', bytes, 'YES', maxbytes)) bytes_alloc from dba_data_files group by tablespace_name) a
  , (select tablespace_name, sum(bytes) tot_used from dba_segments  group by tablespace_name ) b
where  a.tablespace_name = b.tablespace_name (+) 
and a.tablespace_name not in (select distinct tablespace_name from dba_temp_files) 
and a.tablespace_name in ('SYSTEM','SYSAUX');
column tablespace_name format a40
column file_name format a50
prompt ##############################################################
prompt # Datafiles and tablespace detail
prompt ##############################################################
select tablespace_name,file_name from dba_data_files;
column table_owner format a40
column partition_name format a40
prompt ##############################################################
prompt # Check partition table present in database rather than SYS,SYSTEM Schema
prompt ##############################################################
select table_owner,table_name,partition_name,high_value from dba_tab_partitions where table_owner not in ('SYS','SYSTEM');
column owner format a30
column table_name format a30
column index_name format a30
column status format a25
prompt ##############################################################
prompt # Details of the indexes
prompt ##############################################################
SELECT DP.OWNER,DP.TABLE_NAME,DP.INDEX_NAME,DI.STATUS FROM DBA_PART_INDEXES DP,DBA_IND_PARTITIONS DI WHERE DP.OWNER = DI.INDEX_OWNER AND DP.INDEX_NAME = DI.INDEX_NAME and dp.owner not in ('SYS','SYSTEM');
column name format a40
column value format a40
prompt ##############################################################
prompt # check the value of db_files parameter
prompt ##############################################################
select name,value from v$parameter where lower(name) like 'db_file%';
column datafilespresent format 99999
prompt ##############################################################
prompt # Exact value of datafiles present in the database
prompt ##############################################################
select count(*) as datafilespresent from v$datafile;
column objectinvalidcount format 99999 
prompt ##############################################################
prompt # Object Invalid count in database
prompt ##############################################################
select count(*) as objectinvalidcount from dba_objects where status = 'INVALID';
prompt ##############################################################
prompt # list of invalid objects 
prompt ##############################################################
col object_name format a40
col owner format a30
select object_name,owner,object_type from dba_objects where status = 'INVALID';
