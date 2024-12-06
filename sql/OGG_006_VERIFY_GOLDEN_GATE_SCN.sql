-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 1000 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # OGG: VERIFY GOLDENGATE SCN
prompt ##############################################################
col db_name for a15;
select INST_ID
  , SESSION_ID
  , SESSION_NAME
  , SESSION_STATE
  , DB_NAME
  , NUM_PROCESS
  , START_SCN
--  , END_SCN
  , SPILL_SCN
  , PROCESSED_SCN
  , PREPARED_SCN
  , READ_SCN MAX_MEMORY_SIZE
  , USED_MEMORY_SIZE PINNED_TXN
  , PINNED_COMMITTED_TXN
from GV$LOGMNR_SESSION;