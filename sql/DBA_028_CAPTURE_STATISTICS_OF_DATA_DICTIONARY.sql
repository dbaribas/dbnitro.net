-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # CAPTURE STATISTICS OF DATA DICTIONARY                      #
prompt # WAIT A MOMENT PLEASE, THE STATISTICS COLLECTION IS RUNNING #
prompt ##############################################################
exec DBMS_STATS.GATHER_DICTIONARY_STATS;
-- exec DBMS_STATS.SET_PARAM(AUTOSTATS_TARGET,'ORACLE');
-- exec dbms_stats.gather_system_stats();
-- exec dbms_stats.gather_system_stats('start');
-- exec dbms_stats.gather_system_stats('stop');
-- exec dbms_stats.gather_system_stats('interval',60);
-- exec DBMS_STATS.GATHER_SCHEMA_STATS ('SYS');