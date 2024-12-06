-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # BLOCKING LOCKS [ USER DETAILS ]
prompt ##############################################################
col waiting_instance_sid_serial for a30
col waiting_oracle_username for a15
col waiting_os_username for a15
col waiting_machine for a40
col waiting_pid for a10
col locking_instance_sid_serial for a30
col locking_oracle_username for a25
col locking_os_username for a20
col locking_machine for a20
col loocking_program for a20
col locking_pid for a10
select iw.instance_name || ' - ' || lw.sid || ' / ' || sw.serial#  waiting_instance_sid_serial
  , sw.username                                                    waiting_oracle_username
  , sw.osuser                                                      waiting_os_username
  , sw.machine                                                     waiting_machine
  , pw.spid                                                        waiting_pid
  , ih.instance_name || ' - ' || lh.sid || ' / ' || sh.serial#     locking_instance_sid_serial
  , sh.username                                                    locking_oracle_username
  , sh.osuser                                                      locking_os_username
  , sh.machine                                                     locking_machine
  , sh.program                                                     loocking_program
  , ph.spid                                                        locking_pid
FROM gv$lock    lw
  , gv$lock     lh
  , gv$instance iw
  , gv$instance ih
  , gv$session  sw
  , gv$session  sh
  , gv$process  pw
  , gv$process  ph
WHERE iw.inst_id  = lw.inst_id
  AND ih.inst_id  = lh.inst_id
  AND sw.inst_id  = lw.inst_id
  AND sh.inst_id  = lh.inst_id
  AND pw.inst_id  = lw.inst_id
  AND ph.inst_id  = lh.inst_id
  AND sw.sid      = lw.sid
  AND sh.sid      = lh.sid
  AND lh.id1      = lw.id1
  AND lh.id2      = lw.id2
  AND lh.request  = 0
  AND lw.lmode    = 0
  AND (lh.id1, lh.id2) IN (select id1, id2 FROM gv$lock WHERE request = 0 INTERSECT select id1,id2 FROM gv$lock WHERE lmode = 0)
  AND sw.paddr  = pw.addr (+)
  AND sh.paddr  = ph.addr (+)
ORDER BY iw.instance_name, lw.sid;