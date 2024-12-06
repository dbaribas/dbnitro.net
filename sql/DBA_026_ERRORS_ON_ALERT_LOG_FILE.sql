-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set feedback off timing off
var days_back number;
exec :days_back := 15;
set pages 3000 lines 3000 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
set feedback off
prompt ##############################################################
prompt # ERRORS ON ALERT LOG FILE
prompt ##############################################################
col "DATE_TIME" for a20
col host_address for a16
col MESSAGE_TEXT for a140
select to_char(ORIGINATING_TIMESTAMP, 'yyyy-mm-dd HH24:MI:SS') as "DATE_TIME"
  , host_address, MESSAGE_TEXT
from sys.X$DBGALERTEXT
where (lower(MESSAGE_TEXT) like '%ora-%' or lower(MESSAGE_TEXT) like '%error%' or lower(MESSAGE_TEXT) like '%checkpoint not complete%' or lower(MESSAGE_TEXT) like '%fail%')
and ORIGINATING_TIMESTAMP > sysdate-:days_back
order by ORIGINATING_TIMESTAMP;
col total for a80
prompt
prompt ##############################################################
select '[ GENERAL ERRORS ] Total of Occurrences on The Lasts ' || :days_back || ' Days: ' || count(*) as "Total"
from sys.X$DBGALERTEXT
where (lower(MESSAGE_TEXT) like '%error%' or lower(MESSAGE_TEXT) like '%checkpoint not complete%' or lower(MESSAGE_TEXT) like '%fail%')
and ORIGINATING_TIMESTAMP > sysdate-:days_back;
prompt
prompt ##############################################################
select '[ ORACLE ERRORS ] Total of Occurrences on The Lasts ' || :days_back || ' Days: ' || count(*) as "Total"
from sys.X$DBGALERTEXT
where (lower(MESSAGE_TEXT) like '%ora-%' or lower(MESSAGE_TEXT) like '%error%' or lower(MESSAGE_TEXT) like '%fail%')
and ORIGINATING_TIMESTAMP > sysdate-:days_back;
prompt
prompt ##############################################################
select '[ ORA-00600 ] Total of Occurrences on The Lasts ' || :days_back || ' Days: ' || count(*) as "Total"
from sys.X$DBGALERTEXT
where MESSAGE_TEXT like '%ORA-00600%'
and ORIGINATING_TIMESTAMP > sysdate-:days_back;
prompt
prompt ##############################################################
select '[ ORA-00700 ] Total of Occurrences on The Lasts ' || :days_back || ' Days: ' || count(*) as "Total"
from sys.X$DBGALERTEXT
where MESSAGE_TEXT like '%ORA-00700%'
and ORIGINATING_TIMESTAMP > sysdate-:days_back;
prompt
prompt ##############################################################
select '[ ORA-07445 ] Total of Occurrences on The Lasts ' || :days_back || ' Days: ' || count(*) as "Total"
from sys.X$DBGALERTEXT
where MESSAGE_TEXT like '%ORA-07445%'
and ORIGINATING_TIMESTAMP > sysdate-:days_back;