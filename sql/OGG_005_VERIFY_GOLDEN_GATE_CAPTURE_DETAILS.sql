-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 1000 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # OGG: VERIFY GOLDENGATE CAPTURE DETAILS
prompt ##############################################################
SELECT component_name capture_name
  , count(*) open_transactions
  , sum(cumulative_message_count) LCRs
FROM GV$GOLDENGATE_TRANSACTION
WHERE component_type='CAPTURE'
group by component_name;