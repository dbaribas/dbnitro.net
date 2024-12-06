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
prompt # WHICH SESSION IS BLOCKING OTHER SESSION                    #
prompt ##############################################################
select (select username FROM gv$session WHERE sid=a.sid) blocker
  , a.sid
  , ' is blocking ' as BLOCKING
  , (select username FROM gv$session WHERE sid=b.sid) blockee
  , b.sid
FROM gv$lock a, gv$lock b
WHERE a.block = 1
AND b.request > 0
AND a.id1 = b.id1
AND a.id2 = b.id2;