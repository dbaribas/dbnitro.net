-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # VERIFY STATISTICS - TABLES
prompt ##############################################################
col schema for a20
col object for a50
select S.Owner as                                        "Schema"
  , S.Table_Name as                                      "Object"
  , S.Object_Type as                                     "Object Type"
  , S.Num_Rows as                                        "Qtd. of Lines"
  , To_Char(S.Last_Analyzed, 'yyyy-mm-dd HH24:mm:ss') as "Last Analyzed"
  , case when S.Last_Analyzed > sysdate - 7
    then 'Status OK' when S.Last_Analyzed > sysdate - 30 then 'Warning' else 'Critical' end as "Status of Statistics"
FROM sys.dba_tab_statistics S
ORDER BY S.Owner, S.Table_Name, S.Num_Rows, S.Last_Analyzed;
prompt
prompt ##############################################################
prompt # Quantity of Objects with Status OK - (Collected on the lasts 7 days)
prompt ##############################################################
col owner for a30
select a.owner, count(*)
from sys.dba_tab_statistics a
where a.last_analyzed > sysdate - 7
group by a.owner
order by a.owner;
prompt
prompt ##############################################################
prompt # Quantity of Objects with Warning - (Collected between 7 and 30 days)
prompt ##############################################################
col owner for a30
select a.owner, count(*)
from sys.dba_tab_statistics a
where a.last_analyzed < sysdate - 7
and a.last_analyzed < sysdate - 30
group by a.owner
order by a.owner;
prompt
prompt ##############################################################
prompt # Quantity of Objects with Critical - (Collected more them 30 days)
prompt ##############################################################
col owner for a30
select a.owner, count(*)
from sys.dba_tab_statistics a
where a.last_analyzed > sysdate - 30
and a.last_analyzed < sysdate - 90
group by a.owner
order by a.owner;