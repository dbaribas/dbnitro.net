-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 1000 lines 1000 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # LOCKED OBJECTS [ DETAILS ]
prompt ##############################################################
col INSTANCE for a10
col status for a10
col OBJECT_NAME for a30
col MACHINE for a30
col oracle_user for a15
col OS_USER for a15
col PROGRAM for a25
col USER for a10
col OWNER for a15
col OS_PID for a8
col LOCKED_MODE for a20
col OBJECT_TYPE for a15
col OBJECT_OWNER for a15
col LOCKING_OS_PID for a8
col LOCKING_OS_USER for a20
select i.instance_name        instance
  , l.session_id              sid
  , s.status                  status
  , l.oracle_username         oracle_user
  , o.owner                   owner
  , s.osuser                  os_user
  , s.machine                 machine
  , p.spid                    os_pid
  , o.object_name             object_name
  , o.object_type             object_type
  , s.program                 program
  , DECODE (   l.locked_mode
             , 0, 'None'                        /* Mon Lock equivalent */
             , 1, 'NoLock'                      /* N */
             , 2, 'Row-Share (SS)'              /* L */
             , 3, 'Row-Exclusive (SX)'          /* R */
             , 4, 'Share-Table'                 /* S */
             , 5, 'Share-Row-Exclusive (SSX)'   /* C */
             , 6, 'Exclusive'                   /* X */
             ,    '[Nothing]')                  locked_mode
FROM dba_objects       o
  , gv$session        s
  , gv$process        p
  , gv$locked_object  l
  , gv$instance       i
WHERE i.inst_id     = l.inst_id
  AND s.inst_id     = l.inst_id
  AND s.inst_id     = p.inst_id
  AND s.sid         = l.session_id
  AND o.object_id   = l.object_id
  AND s.paddr       = p.addr
ORDER BY i.instance_name, l.session_id;