-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # BLOCKING LOCKS [ WAITING SQL ]
prompt ##############################################################
select iw.instance_name || ' - ' || lw.sid || ' / ' || sw.serial#  waiting_instance_sid_serial
  , aw.sql_text                                                    waiting_sql_text
FROM gv$lock     lw
  , gv$lock     lh
  , gv$instance iw
  , gv$instance ih
  , gv$session  sw
  , gv$session  sh
  , gv$sqlarea  aw
WHERE iw.inst_id  = lw.inst_id
  AND ih.inst_id  = lh.inst_id
  AND sw.inst_id  = lw.inst_id
  AND sh.inst_id  = lh.inst_id
  AND aw.inst_id  = lw.inst_id
  AND sw.sid      = lw.sid
  AND sh.sid      = lh.sid
  AND lh.id1      = lw.id1
  AND lh.id2      = lw.id2
  AND lh.request  = 0
  AND lw.lmode    = 0
  AND (lh.id1, lh.id2) IN (select id1, id2 FROM gv$lock WHERE request = 0 INTERSECT select id1, id2 FROM gv$lock WHERE lmode = 0)
  AND sw.sql_address  = aw.address
ORDER BY iw.instance_name, lw.sid;