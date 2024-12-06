-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # DBA: VERIFY FAILED LOGIN 
prompt ##############################################################
col username for a15
col os_username for a20
col userhost for a30
col client_id for a20
select username
  , os_username
  , userhost
  , client_id
  , trunc(timestamp)
  , count(*) failed_logins
from dba_audit_trail
where returncode = 1017 --1017 is invalid username/password
and timestamp > sysdate - 7
group by username, os_username, userhost, client_id, trunc(timestamp)
order by 1,2,3;
prompt
prompt ##############################################################
prompt # DBA: VERIFY FAILED LOGIN DETAILS
prompt ##############################################################
col ntimestamp# for a30
col userid for a20
col userhost for a30
col spare1 for a20
col comment$text for a70
select ntimestamp#
  , userid
  , userhost
  , spare1
  , comment$text 
from sys.aud$ 
where returncode=1017 
order by 1,2,3;
prompt
prompt ##############################################################
prompt # DBA: VERIFY FAILED LOGIN DETAILS II
prompt ##############################################################
col username for a15
col os_username for a20
col userhost for a40
col client_id for a20
select OS_USERNAME
  , USERNAME
  , USERHOST
  , to_char(timestamp,'YYYY-MM-DD HH24:MI:SS') as time
  , returncode
from dba_audit_trail 
where returncode > 0
order by 1,2,3;
prompt
prompt ##############################################################
prompt # DBA: VERIFY FAILED LOGIN DETAILS III
prompt ##############################################################
col username for a15  
col userhost for a40
col timestamp for a20
col terminal for a23  
SELECT username
  , userhost
  , terminal
  , to_char(timestamp,'YYYY-MM-DD HH24:MI:SS') "TIMESTAMP"
  , CASE when returncode = 1017 then 'INVALID-attempt' when returncode = 28000 then 'account locked' end "FAILED LOGIN ACTION" 
FROM dba_audit_session 
where timestamp > sysdate -1/9 
and returncode in (1017,28000)
order by 1,2,3;