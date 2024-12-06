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
prompt # SHOW INFORMATION ABOUT PATCHES                             #
prompt ##############################################################
COLUMN action_time FORMAT A20
COLUMN action FORMAT A10
-- COLUMN bundle_series FORMAT A10
COLUMN comments FORMAT A30
COLUMN description FORMAT A90
COLUMN namespace FORMAT A20
COLUMN status FORMAT A15
COLUMN version FORMAT A10
SELECT TO_CHAR(action_time, 'YYYY-MM-DD HH24:MI:SS') AS action_time
  , action
  , status
  , description
-- , version
  , patch_id
-- , bundle_series
FROM sys.dba_registry_sqlpatch
ORDER by action_time;
prompt
prompt ##############################################################
prompt # SHOW INFORMATION ABOUT PATCHES WITH DETAILS                #
prompt ##############################################################
col version for a25
col namespace for a25
col comments for a85
SELECT TO_CHAR(action_time, 'YYYY-MM-DD HH24:MI:SS') AS action_time
  , action
  , namespace
  , version
--  , id
  , comments
  , bundle_series
FROM sys.registry$history
ORDER by action_time;
prompt
prompt ##############################################################
prompt # Displays contents of the patches (BP/PSU) registry and history
prompt ##############################################################
SET SERVEROUT ON LONG 2000000
COLUMN action_time FORMAT A20
COLUMN action FORMAT A10
COLUMN status FORMAT A10
COLUMN description FORMAT A100
COLUMN source_version FORMAT A20
COLUMN target_version FORMAT A20
alter session set "_exclude_seed_cdb_view"=FALSE;
select CON_ID
  , TO_CHAR(action_time, 'YYYY-MM-DD HH24:MI:SS') AS action_time
  , PATCH_ID
  , PATCH_TYPE
  , ACTION
  , DESCRIPTION
  , SOURCE_VERSION
  , TARGET_VERSION
from CDB_REGISTRY_SQLPATCH
order by CON_ID, action_time, patch_id;
prompt
prompt ##############################################################
prompt # Displays the space being used to store patch rollback zip files
prompt ##############################################################
column patch_id format 9999999999
column ru_version format a15
column lob_size_md format 9999
COLUMN ru_build_ts FORMAT A20
COLUMN SUBSTR(description,1,40) FORMAT A40
col PATCH_DESCRIPTION for a50
-- ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'YYYY-DD-YY HH24:MI:SS';
ALTER SESSION SET "_EXCLUDE_SEED_CDB_VIEW" = FALSE;
SELECT patch_id
  , ru_version
  , TO_CHAR(ru_build_timestamp, 'YYYY-MM-DD HH24:MI:SS') AS ru_build_ts
  , round(dbms_lob.getlength(patch_directory) / 1024 / 1024) lob_size_mb
FROM sys.registry$sqlpatch_ru_info;
prompt
SELECT patch_id
  , SUBSTR(description,1,40) PATCH_DESCRIPTION
  , TO_CHAR(source_build_timestamp, 'YYYY-MM-DD HH24:MI:SS') AS patch_build_ts
  , round(dbms_lob.getlength(patch_directory) / 1024 / 1024) lob_size_mb
FROM sys.registry$sqlpatch
WHERE patch_type <> 'RU';
prompt
SELECT con_id
  , round(sum(dbms_lob.getlength(patch_directory) / 1024 / 1024)) total_lob_size_mba
FROM containers(sys.registry$sqlpatch_ru_info)
GROUP BY con_id
ORDER BY con_id;
prompt
SELECT con_id
  , round(sum(dbms_lob.getlength(patch_directory) / 1024 / 1024)) total_lob_size_mba
FROM containers(sys.registry$sqlpatch)
GROUP BY con_id
ORDER BY con_id;