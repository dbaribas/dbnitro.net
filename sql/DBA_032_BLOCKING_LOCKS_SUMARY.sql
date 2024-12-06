-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

SET TERMOUT OFF TERMOUT ON ECHO OFF FEEDBACK 6 HEADING ON LINESIZE 256 PAGESIZE 50000 TERMOUT ON TIMING ON TRIMOUT ON TRIMSPOOL ON VERIFY OFF timing on
prompt ##############################################################
prompt # BLOCKING LOCKS [ SUMARY ]
prompt ##############################################################
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
COLUMN waiting_instance_sid_serial  FORMAT a24          HEADING '[WAITING]|Instance - SID / Serial#'
COLUMN waiting_oracle_username      FORMAT a20          HEADING '[WAITING]|Oracle User'
COLUMN waiting_pid                  FORMAT a11          HEADING '[WAITING]|PID'
COLUMN waiting_machine              FORMAT a15          HEADING '[WAITING]|Machine'   TRUNC
COLUMN waiting_os_username          FORMAT a15          HEADING '[WAITING]|O/S User'
COLUMN waiter_lock_type_mode_req    FORMAT a35          HEADING 'Waiter Lock Type / Mode Requested'
COLUMN waiting_lock_time_min        FORMAT a10          HEADING '[WAITING]|Lock Time'
COLUMN waiting_instance_sid         FORMAT a15          HEADING '[WAITING]|Instance - SID'
COLUMN waiting_sql_text             FORMAT a105         HEADING '[WAITING]|SQL Text'    WRAP
COLUMN locking_instance_sid_serial  FORMAT a24          HEADING '[LOCKING]|Instance - SID / Serial#'
COLUMN locking_oracle_username      FORMAT a20          HEADING '[LOCKING]|Oracle User'
COLUMN locking_oracle_program       FORMAT a25          HEADING '[LOCKING]|Oracle Program'
COLUMN locking_pid                  FORMAT a11          HEADING '[LOCKING]|PID'
COLUMN locking_machine              FORMAT a15          HEADING '[LOCKING]|Machine'   TRUNC
COLUMN locking_os_username          FORMAT a15          HEADING '[LOCKING]|O/S User'
COLUMN locking_lock_time_min        FORMAT a10          HEADING '[LOCKING]|Lock Time'
COLUMN instance_name                FORMAT a8           HEADING 'Instance'
COLUMN sid                          FORMAT 999999       HEADING 'SID'
COLUMN session_status               FORMAT a9           HEADING 'Status'
COLUMN locking_oracle_user          FORMAT a20          HEADING 'Locking Oracle User'
COLUMN locking_os_user              FORMAT a20          HEADING 'Locking O/S User'
COLUMN locking_os_pid               FORMAT a11          HEADING 'Locking PID'
COLUMN locking_machine              FORMAT a15          HEADING 'Locking Machine'   TRUNC
COLUMN object_owner                 FORMAT a15          HEADING 'Object Owner'
COLUMN object_name                  FORMAT a25          HEADING 'Object Name'
COLUMN object_type                  FORMAT a15          HEADING 'Object Type'
COLUMN locked_mode                                      HEADING 'Locked Mode'
CLEAR BREAKS
select iw.instance_name || ' - ' || lw.sid || ' / ' || sw.serial#  waiting_instance_sid_serial
  , sw.username                                               waiting_oracle_username
  , ROUND(lw.ctime/60) || ' min.'                             waiting_lock_time_min
  , DECODE (   lh.type
             , 'CF', 'Control File'
             , 'DX', 'Distributed Transaction'
             , 'FS', 'File Set'
             , 'IR', 'Instance Recovery'
             , 'IS', 'Instance State'
             , 'IV', 'Libcache Invalidation'
             , 'LS', 'Log Start or Log Switch'
             , 'MR', 'Media Recovery'
             , 'RT', 'Redo Thread'
             , 'RW', 'Row Wait'
             , 'SQ', 'Sequence Number'
             , 'ST', 'Diskspace Transaction'
             , 'TE', 'Extend Table'
             , 'TT', 'Temp Table'
             , 'TX', 'Transaction'
             , 'TM', 'DML'
             , 'UL', 'PLSQL User_lock'
             , 'UN', 'User Name'
             , 'Nothing-' ) || ' / ' || DECODE ( lw.request
             , 0, 'None'                        /* Mon Lock equivalent */
             , 1, 'NoLock'                      /* N */
             , 2, 'Row-Share (SS)'              /* L */
             , 3, 'Row-Exclusive (SX)'          /* R */
             , 4, 'Share-Table'                 /* S */
             , 5, 'Share-Row-Exclusive (SSX)'   /* C */
             , 6, 'Exclusive'                   /* X */
             ,    '[Nothing]' )                                         waiter_lock_type_mode_req
  , ih.instance_name || ' - ' || lh.sid || ' / ' || sh.serial#          locking_instance_sid_serial
  , sh.username                                                         locking_oracle_username
  , sh.program                                                          locking_oracle_program
  , ROUND(lh.ctime/60) || ' min.'                                       locking_lock_time_min
FROM gv$lock     lw
  , gv$lock     lh
  , gv$instance iw
  , gv$instance ih
  , gv$session  sw
  , gv$session  sh
WHERE iw.inst_id  = lw.inst_id
  AND ih.inst_id  = lh.inst_id
  AND sw.inst_id  = lw.inst_id
  AND sh.inst_id  = lh.inst_id
  AND sw.sid      = lw.sid
  AND sh.sid      = lh.sid
  AND lh.id1      = lw.id1
  AND lh.id2      = lw.id2
  AND lh.request  = 0
  AND lw.lmode    = 0
  AND (lh.id1, lh.id2) IN (select id1, id2 FROM gv$lock WHERE request = 0 INTERSECT select id1, id2 FROM gv$lock WHERE lmode = 0)
ORDER BY iw.instance_name, lw.sid;