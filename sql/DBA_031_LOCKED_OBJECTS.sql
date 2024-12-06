-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

SET ECHO OFF FEEDBACK 6 HEADING ON LINESIZE 500 PAGESIZE 50000 TERMOUT ON TIMING OFF TRIMOUT ON TRIMSPOOL ON VERIFY OFF timing on
prompt ##############################################################
prompt # LOCKED OBJECTS
prompt ##############################################################
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
COLUMN instance_name                FORMAT a9           HEADING 'Instance'
COLUMN sid                          FORMAT 999999       HEADING 'SID'
COLUMN sid_serial                   FORMAT a20          HEADING 'SID / Serial#'
COLUMN session_status               FORMAT a9           HEADING 'Status'
COLUMN locking_oracle_user          FORMAT a20          HEADING 'Locking Oracle User'
COLUMN object_owner                 FORMAT a20          HEADING 'Object Owner'
COLUMN object_name                  FORMAT a30          HEADING 'Object Name'
COLUMN object_type                  FORMAT a25          HEADING 'Object Type'
COLUMN locked_mode                  FORMAT a35          HEADING 'Locked Mode'
CLEAR BREAKS
select i.instance_name                    instance_name
  , l.session_id || ' / ' || s.serial#    sid_serial
  , s.status                              session_status
  , l.oracle_username                     locking_oracle_user
  , o.owner                               object_owner
  , o.object_name                         object_name
  , o.object_type                         object_type
  , DECODE (   l.locked_mode
             , 0, 'None'                        /* Mon Lock equivalent */
             , 1, 'NoLock'                      /* N */
             , 2, 'Row-Share (SS)'              /* L */
             , 3, 'Row-Exclusive (SX)'          /* R */
             , 4, 'Share-Table'                 /* S */
             , 5, 'Share-Row-Exclusive (SSX)'   /* C */
             , 6, 'Exclusive'                   /* X */
             ,    '[Nothing]' )                 locked_mode
FROM dba_objects       o
  , gv$session        s
  , gv$locked_object  l
  , gv$instance       i
WHERE i.inst_id     = l.inst_id
  AND s.inst_id     = l.inst_id
  AND s.sid         = l.session_id
  AND o.object_id   = l.object_id
ORDER BY i.instance_name, l.session_id;