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
prompt # IDENTIFYING WHEN A PASSWORD WAS LAST CHANGED
prompt ##############################################################
col name form a30
col "Created" for a20
col "Last_Changed" for a20
select name
  , ctime as "Created"
  , ptime as "Last_Changed"
  , case when ptime = ctime then 'Never Changed' when ptime < sysdate - 30 and ctime < sysdate - 30 then 'Change Recomended' else 'Recently Changed' end as "Result"
FROM sys.user$ a, dba_users b
where a.name = b.username
order by 1;