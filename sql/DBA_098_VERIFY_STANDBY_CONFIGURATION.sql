-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set feedback off timing off
alter session set nls_date_format='yyyy-mm-dd';
set pages 700 lines 1000 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # DBA: Basic Configuration
prompt ##############################################################
column name for a30
column display_value for a100
column ID format 99
column "SRLs" format 99
column active format 99
column type format a4
column ID format 99
column "SRLs" format 99
column active format 99
column type format a4
column PROTECTION_MODE for a20
column RECOVERY_MODE for a20
column db_mode for a15
SELECT name, display_value 
FROM v$parameter 
WHERE name IN ('db_name'
  , 'db_unique_name'
  , 'log_archive_config'
  , 'log_archive_dest_2'
  , 'log_archive_dest_state_2'
  , 'fal_client'
  , 'fal_server'
  , 'standby_file_management'
  , 'standby_archive_dest'
  , 'db_file_name_convert'
  , 'log_file_name_convert'
  , 'remote_login_passwordfile'
  , 'local_listener'
  , 'dg_broker_start'
  , 'dg_broker_config_file1'
  , 'dg_broker_config_file2'
  , 'log_archive_max_processes') 
order by name;
prompt
prompt ##############################################################
prompt # DBA: Database Role, Archive, Flashback, Force Logging
prompt ##############################################################
column name for a10
column DATABASE_ROLE for a10
column force_logging for a13
SELECT name
  , db_unique_name
  , DATABASE_ROLE
  , log_mode
  , force_logging
  , flashback_on
  , protection_mode
  , PROTECTION_LEVEL
  , OPEN_MODE
  , switchover_status 
from v$database;
prompt
prompt ##############################################################
prompt # DBA: Database Threads
prompt ##############################################################
select thread#
  , max(sequence#) 
from v$archived_log 
group by thread#;
prompt
prompt ##############################################################
prompt #
prompt ##############################################################
column severity for a15
column message for a70
column timestamp for a20
select severity
  , error_code
  , to_char(timestamp,'DD-MON-YYYY HH24:MI:SS') "timestamp"
  , message 
from v$dataguard_status 
where dest_id=2;
prompt
prompt ##############################################################
prompt # DBA: Database Configuration Standby Details
prompt ##############################################################
col recovery_mode for a25
select ds.dest_id id
  , ad.status
  , ds.database_mode db_mode
  , ad.archiver type
  , ds.recovery_mode
  , ds.protection_mode
  , ds.standby_logfile_count "SRLs"
  , ds.standby_logfile_active active
  , ds.archived_seq#
from v$archive_dest_status ds
  , v$archive_dest ad
where ds.dest_id = ad.dest_id
and ad.status != 'INACTIVE'
order by ds.dest_id;
prompt
prompt ##############################################################
prompt # DBA: Recovery File Dest Usage
prompt ##############################################################
column FILE_TYPE format a20
col name format a60
select name
  , floor(space_limit/1024/1024) "Size MB"
  , ceil(space_used/1024/1024) "Used MB"
from v$recovery_file_dest
order by name;
prompt
prompt ##############################################################
prompt # ON STANDBY
prompt ##############################################################
column name for a30
column display_value for a100
col value for a10
col PROTECTION_MODE for a15
col DATABASE_Role for a15
SELECT name
  , display_value 
FROM v$parameter 
WHERE name IN ('db_name'
  , 'db_unique_name'
  , 'log_archive_config'
  , 'log_archive_dest_2'
  , 'log_archive_dest_state_2'
  , 'fal_client'
  , 'fal_server'
  , 'standby_file_management'
  , 'standby_archive_dest'
  , 'db_file_name_convert'
  , 'log_file_name_convert'
  , 'remote_login_passwordfile'
  , 'local_listener'
  , 'dg_broker_start'
  , 'dg_broker_config_file1'
  , 'dg_broker_config_file2'
  , 'log_archive_max_processes') 
order by name;
prompt
prompt ##############################################################
prompt #
prompt ##############################################################
col name for a10
col DATABASE_ROLE for a10
SELECT name
  , db_unique_name
  , protection_mode
  , DATABASE_ROLE
  , OPEN_MODE 
from v$database;
prompt
prompt ##############################################################
prompt #
prompt ##############################################################
select thread#
  , max(sequence#) 
from v$archived_log 
where applied='YES' 
group by thread#;
prompt
prompt ##############################################################
prompt #
prompt ##############################################################
select process
  , status
  , thread#
  , sequence# 
from v$managed_standby;
prompt
prompt ##############################################################
prompt #
prompt ##############################################################
SELECT ARCH.THREAD# "Thread"
  , ARCH.SEQUENCE# "Last Sequence Received"
  , APPL.SEQUENCE# "Last Sequence Applied"
  , (ARCH.SEQUENCE# - APPL.SEQUENCE#) "Difference"
FROM 
(SELECT THREAD#, SEQUENCE# FROM V$ARCHIVED_LOG WHERE (THREAD#, FIRST_TIME) IN 
(SELECT THREAD#, MAX(FIRST_TIME) FROM V$ARCHIVED_LOG GROUP BY THREAD#)) ARCH,
(SELECT THREAD#, SEQUENCE# FROM V$LOG_HISTORY WHERE (THREAD#, FIRST_TIME) IN 
(SELECT THREAD#, MAX(FIRST_TIME) FROM V$LOG_HISTORY GROUP BY THREAD#)) APPL
WHERE ARCH.THREAD# = APPL.THREAD# ORDER BY 1;
prompt
prompt ##############################################################
prompt #
prompt ##############################################################
col name for a30 
select * from v$dataguard_stats; 
prompt
prompt ##############################################################
prompt #
prompt ##############################################################
select * from v$archive_gap; 
prompt
prompt ##############################################################
prompt #
prompt ##############################################################
col name format a60 
select name
  , floor(space_limit/1024/1024) "Size MB"
  , ceil(space_used/1024/1024) "Used MB" 
from v$recovery_file_dest 
order by name;