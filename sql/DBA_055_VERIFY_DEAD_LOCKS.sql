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
prompt # VERIFY DEAD LOCKS
prompt ##############################################################
col username form A15
col sid form 9999999
col type form A4
col lmode form 9999999
col request form 9999999
col id1 form 9999990
col id2 form 9999990
col lmode for a20
col request for a20
break on id1 skip 1 dup
select sn.username
  , m.sid
  , m.type
  , DECODE(m.lmode, 0, 'None', 1, 'Null', 2, 'Row Share', 3, 'Row Excl.', 4, 'Share', 6, 'Exclusive', 5, 'S/Row Excl.', lmode, ltrim(to_char(lmode,'990'))) lmode
  , DECODE(m.request, 0, 'None', 1, 'Null', 2, 'Row Share', 3, 'Row Excl.', 4, 'Share', 5, 'S/Row Excl.', 6, 'Exclusive', request, ltrim(to_char(request,'990'))) request
  , m.id1
  , m.id2
FROM gv$session sn, gv$lock m
WHERE (sn.sid = m.sid AND m.request != 0) OR (sn.sid = m.sid AND m.request = 0 AND lmode != 4 AND (id1, id2)
IN (select s.id1, s.id2 FROM gv$lock s WHERE request != 0 AND s.id1 = m.id1 AND s.id2 = m.id2))
ORDER BY id1,id2, m.request;

-- select (select username FROM gv$session WHERE sid=a.sid) blocker
--   , a.sid || ',' || (select serial# from gv$session c where sid=a.sid) sess1
--   , ' is blocking ' as BLOCKING
--   , (select username FROM gv$session WHERE sid=b.sid) blockee
--   , b.sid || ',' || (select serial# from gv$session c where sid=b.sid) sess2
-- FROM gv$lock a, gv$lock b
-- WHERE a.block = 1
-- AND b.request > 0
-- AND a.id1 = b.id1
-- AND a.id2 = b.id2;