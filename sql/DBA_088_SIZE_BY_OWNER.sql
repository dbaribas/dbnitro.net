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
prompt # SIZE BY OWNER                                              #
prompt ##############################################################
col size_mb for a20
col size_gb for a20
col size_tb for a20
col owner for a30
select owner
  , to_char(sum(bytes)/1024/1024,'999G999G999D999') as SIZE_MB
  , to_char(sum(bytes)/1024/1024/1024,'999G999G999D999') as SIZE_GB
  , to_char(sum(bytes)/1024/1024/1024/1024,'999G999G999D999') as SIZE_TB
From dba_segments
group by owner
order by owner;