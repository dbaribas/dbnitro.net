-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # DBA: TOTAL USERS COUNT ON DATABASE
prompt ##############################################################
prompt
break on report
compute SUM of tot on report
compute SUM of active on report
compute SUM of inactive on report
col username for a50
select DECODE(username,NULL,'INTERNAL',USERNAME) Username
  , count(*) TOT
  , COUNT(DECODE(status,'ACTIVE',STATUS)) ACTIVE
  , COUNT(DECODE(status,'INACTIVE',STATUS)) INACTIVE
from gv$session
where status in ('ACTIVE','INACTIVE')
group by username;