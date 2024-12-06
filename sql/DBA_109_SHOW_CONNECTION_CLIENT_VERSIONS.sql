-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # DBA: SHOW CONNECTION CLIENT VERSIONS
prompt ##############################################################
col OSUSER for a20
col CLIENT_CONNECTION_STRING for a20
col NETWORK_SERVICE_BANNER for a80
col CLIENT_CHARSET for a15
col CLIENT_VERSION for a15
select INST_ID
  , SID
  , SERIAL#
  , AUTHENTICATION_TYPE
  , OSUSER
  , NETWORK_SERVICE_BANNER
  , CLIENT_CHARSET
  , CLIENT_CONNECTION
  , CLIENT_OCI_LIBRARY
  , CLIENT_VERSION
  , CLIENT_DRIVER
--  , CLIENT_CONNECTION_STRING
 from gv$session_connect_info;