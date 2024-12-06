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
prompt # VERIFY UNDO SEGMENTS
prompt ##############################################################
select to_char(begin_time, 'yyyy-mm-dd HH24:MI') begin_time
  , to_char(end_time, 'yyyy-mm-dd HH24:MI') end_time
  , tuned_undoretention
from v$undostat
order by end_time;
prompt
prompt ##############################################################
prompt # VERIFY UNDO SEGMENTS - DETAILS
prompt ##############################################################
select TO_CHAR(BEGIN_TIME, 'yyyy-mm-dd HH24:MI') BEGIN_TIME
  , TO_CHAR(END_TIME, 'yyyy-mm-dd HH24:MI') END_TIME
  , UNDOTSN
  , UNDOBLKS
  , TXNCOUNT
  , MAXCONCURRENCY AS "MAXCON"
FROM v$UNDOSTAT
WHERE rownum <= 144;
prompt
prompt ##############################################################
prompt # VERIFY UNDO SEGMENTS - STATUS
prompt ##############################################################
select segment_name
  , status
FROM dba_rollback_segs;
prompt
prompt ##############################################################
prompt # VERIFY UNDO SEGMENTS - ROLLBACK
prompt ##############################################################
column "% Waits" format 999.99 heading "% Waits"
select rn.Name "Rollback Segment"
  , rs.RSSize/1024 "Size (KB)"
  , rs.Gets "Gets"
  , rs.waits "Waits"
  , (rs.Waits/rs.Gets)*100 "% Waits"
  , rs.Shrinks "# Shrinks"
  , rs.Extends "# Extends"
FROM sys.v_$rollName rn, sys.v_$rollStat rs
WHERE rn.usn = rs.usn
order by "Size (KB)", "Waits", "% Waits";