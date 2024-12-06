-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
col STATUS format a30
col DURATION format a10
col INPUT_TYPE for a20
col OPTIMIZED for a10
col BACKUP_SIZE for a20
col BEGIN for a20
col END for a20
prompt ##############################################################
prompt # BACKUP STATISTICS
prompt ##############################################################
prompt
select * from (select INPUT_TYPE
    , STATUS
    , OPTIMIZED
    , to_char(START_TIME,'yyyy-mm-dd hh24:mi') as BEGIN
    , to_char(END_TIME,'yyyy-mm-dd hh24:mi') as END
    , TIME_TAKEN_DISPLAY as DURATION
    , d.OUTPUT_BYTES_DISPLAY as BACKUP_SIZE
from V$RMAN_BACKUP_JOB_DETAILS d
where START_TIME > sysdate-30
-- and INPUT_TYPE = '${SRMAN_TYPE}'
-- and INPUT_TYPE in ('DB FULL', 'RECVR AREA', 'DB INCR', 'DATAFILE FULL', 'DATAFILE INCR', 'ARCHIVELOG', 'CONTROLFILE', 'SPFILE')
order by session_key, BEGIN desc);