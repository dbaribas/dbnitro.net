-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

SET TERMOUT ON TERMOUT ON ECHO OFF FEEDBACK 6 HEADING ON LINESIZE 256 PAGESIZE 50000 TERMOUT ON TIMING ON TRIMOUT ON TRIMSPOOL ON VERIFY OFF timing on colsep '|'
prompt ##############################################################
prompt # DML TABLE LOCKS TIME
prompt ##############################################################
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
COLUMN instance_name                FORMAT a10          HEADING 'Instance'
COLUMN locking_oracle_user          FORMAT a20          HEADING 'Locking Oracle User'
COLUMN sid_serial                   FORMAT a15          HEADING 'SID / Serial#'
COLUMN mode_held                    FORMAT a15          HEADING 'Mode Held'
COLUMN mode_requested               FORMAT a15          HEADING 'Mode Requested'
COLUMN lock_type                    FORMAT a15          HEADING 'Lock Type'
COLUMN object                       FORMAT a42          HEADING 'Object'
COLUMN program                      FORMAT a20          HEADING 'Program'
COLUMN lock_time_min                FORMAT 999,999      HEADING 'Lock Time (min)'
COLUMN lock_time_hours              FORMAT 999,999      HEADING 'Lock Time (hours)'
COLUMN lock_time_days               FORMAT 999,999      HEADING 'Lock Time (days)'
CLEAR BREAKS
select i.instance_name instance_name
  , l.sid || ' / ' || s.serial# sid_serial
  , s.username locking_oracle_user
  , DECODE(   l.lmode
            , 1, NULL
            , 2, 'Row Share'
            , 3, 'Row Exclusive'
            , 4, 'Share'
            , 5, 'Share Row Exclusive'
            , 6, 'Exclusive'
            ,    'None') mode_held
  , DECODE(   l.request
            , 1, NULL
            , 2, 'Row Share'
            , 3, 'Row Exclusive'
            , 4, 'Share'
            , 5, 'Share Row Exclusive'
            , 6, 'Exclusive'
            ,    'None') mode_requested
  , DECODE (   l.type
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
             ,       'Nothing'
           ) lock_type
  , o.owner || '.' || o.object_name object
  , ROUND(l.ctime/60, 2) lock_time_min
  , ROUND(l.ctime/60/60, 2) lock_time_hours
  , ROUND(l.ctime/60/60/24, 2) lock_time_days
FROM v$instance    i
   , v$session     s
   , v$lock        l
   , dba_objects   o
   , dba_tables    t
WHERE l.id1            =  o.object_id
  AND s.sid            =  l.sid
  AND o.owner          =  t.owner
  AND o.object_name    =  t.table_name
  AND o.owner          <> 'SYS'
  AND l.type           =  'TM'
ORDER BY i.instance_name, l.sid;