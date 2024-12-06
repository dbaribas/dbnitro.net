-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set feedback off timing off
alter session set nls_date_format='yyyy-mm-dd hh24:mi';
set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # LAST FILE OF LAST BACKUP ARCH
prompt ##############################################################
col PATH format a100
col tag format a30
col DEVICE format a10
col SIZE_BYTES_DISPLAY for a15
col BEGIN for a20
col END for a20
col STATUS for a20
select /*+ rule */ tag
  , device_type as DEVICE
  , handle as PATH
  , START_TIME as BEGIN
  , COMPLETION_TIME as END
  , rtrim(SIZE_BYTES_DISPLAY) as SIZE_BYTES_DISPLAY 
-- , status
from v$backup_piece_details
where session_recid > (select max(session_recid) -10000 from V$RMAN_BACKUP_JOB_DETAILS where START_TIME > sysdate-30 and input_type in('ARCHIVELOG') and status in ('COMPLETED','COMPLETED WITH WARNINGS'))
and START_TIME > sysdate-30
order by START_TIME;