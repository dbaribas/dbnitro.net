-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # VERIFY DATABASE SESSIONS
prompt ##############################################################
select total_sessions
  , active_sessions
  , (total_sessions - active_sessions) inactive_sessions
  , round( 100 * active_sessions / total_sessions, 2) pct_active
  , round( 100 * (total_sessions - active_sessions) / total_sessions, 2) pct_inactive
from (select count(*) total_sessions from v\$session where type <> 'BACKGROUND') st,
     (select count(*) active_sessions from v\$session where  status = 'ACTIVE' and type <> 'BACKGROUND') sa;