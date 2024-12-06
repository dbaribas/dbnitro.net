-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

SET TERMOUT OFF TERMOUT ON ECHO OFF FEEDBACK 6 HEADING ON LINESIZE 256 PAGESIZE 50000 TERMOUT ON TRIMOUT ON TRIMSPOOL ON VERIFY OFF timing on colsep '|'
prompt ##############################################################
prompt # DML AND DDL LOCKS
prompt ##############################################################
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
COLUMN instance_name         FORMAT a10       HEADING 'Instance'
COLUMN sid_serial            FORMAT a15       HEADING 'SID / Serial#'
COLUMN session_status        FORMAT a9        HEADING 'Status'
COLUMN locking_oracle_user   FORMAT a20       HEADING 'Locking Oracle User'
COLUMN lock_type             FORMAT a9        HEADING 'Lock Type'
COLUMN mode_held             FORMAT a10       HEADING 'Mode Held'
COLUMN object                FORMAT a42       HEADING 'Object'
COLUMN program               FORMAT a20       HEADING 'Program'
COLUMN wait_time_sec         FORMAT 999,999   HEADING 'Wait Time (sec)'
COLUMN wait_time_min         FORMAT 999,999   HEADING 'Wait Time (min)'
COLUMN wait_time_hour        FORMAT 999,999   HEADING 'Wait Time (hour)'
CLEAR BREAKS
select i.instance_name                   as instance_name
  , l.session_id || ' / ' || s.serial#   as sid_serial
  , s.status                             as session_status
  , s.username                           as locking_oracle_user
  , l.lock_type                          as lock_type
  , l.mode_held                          as mode_held
  , o.owner || '.' || o.object_name      as object
  , SUBSTR(s.program, 0, 20)             as program
  , ROUND(w.seconds_in_wait, 2)          as wait_time_sec
  , ROUND(w.seconds_in_wait/60, 2)       as wait_time_min
  , ROUND(w.seconds_in_wait/60/60, 2)    as wait_time_hour
FROM v$instance      i
   , v$session       s
   , dba_locks       l
   , dba_objects     o
   , v$session_wait  w
WHERE s.sid = l.session_id
AND l.lock_type IN ('DML','DDL')
AND l.lock_id1 = o.object_id
AND l.session_id = w.sid
ORDER BY i.instance_name, l.session_id;