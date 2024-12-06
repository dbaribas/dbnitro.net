-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 50000 lines 32767 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # Session related Queries                                    #
prompt ##############################################################
prompt # Last/Latest Running SQL                                    #
prompt ##############################################################
col username for a20
col "Last SQL" for a130
col "SID" for a15
select s.username
  , s.sid || ',' || s.serial# || '@' || t.inst_id as "SID"
  , t.sql_id
  , t.sql_text "Last SQL"
FROM gv$session s, gv$sqlarea t
WHERE s.sql_address = t.address
AND s.sql_hash_value = t.hash_value;
