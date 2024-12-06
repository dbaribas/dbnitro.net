-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set feedback off timing off
alter session set nls_date_format='yyyy-mm-dd';
prompt
prompt ##############################################################
prompt # DATABASE FOLDERS                                           #
prompt ##############################################################
col folders for a200
select 'create or replace directory ' || directory_name || ' as ' || '''' || directory_path || ''';' as folders from all_directories;