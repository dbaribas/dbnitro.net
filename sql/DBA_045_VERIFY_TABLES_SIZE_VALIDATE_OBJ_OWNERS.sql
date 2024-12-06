-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 5000 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # VERIFY TABLES SIZE, VALIDATE OBJ - OWNERS
prompt ##############################################################
col "OWNER" for a25
col "Table Name" for a35
col "Table Space" for a25
col "Last Analyzed" for a30
col "Status of Statistics" for a20
select t.owner as                                        "OWNER"
  , t.table_name as                                      "Table Name"
  , t.TABLESPACE_NAME as                                 "Table Space"
  , t.num_rows as                                        "Rows"
  , t.avg_row_len as                                     "Avg Row Len"
  , trunc((t.blocks * p.value)/1024/1024) as             "Size MB" -- numero de blocos X o seu tamanho em KBs
  , to_Char(t.Last_Analyzed, 'yyyy-mm-dd HH24:mm:ss') as "Last Analyzed"
  , case when t.Last_Analyzed > sysdate - 7 then 'Status OK' when t.Last_Analyzed > sysdate - 30 then 'Warning' else 'Critical' end as "Status of Statistics"
FROM dba_tables t, v$parameter p
WHERE p.name = 'DBA_block_size'
ORDER BY 1,2;