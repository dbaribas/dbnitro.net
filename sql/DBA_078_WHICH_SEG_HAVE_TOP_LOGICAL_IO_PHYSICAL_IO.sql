-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # WHICH SEG. HAVE TOP LOGICAL I/O - PHYSICAL I/O
prompt ##############################################################
col owner for a30
col OBJECT_NAME for a40
select ROWNUM AS Rank
  , Seg_Lio.*
FROM (select St.Owner
  , St.Obj#
  , St.Object_Type
  , St.Object_Name
  , to_char(St.VALUE) as VALUE
  , 'LIO' AS Unit
FROM v$segment_Statistics St
WHERE St.Statistic_Name = 'logical reads'
ORDER BY St.VALUE DESC) Seg_Lio WHERE ROWNUM <= 15
UNION ALL
select ROWNUM AS Rank
  , Seq_Pio_r.*
FROM (select St.Owner
  , St.Obj#
  , St.Object_Type
  , St.Object_Name
  , to_char(St.VALUE) as VALUE
  , 'PIO Reads' AS Unit
FROM V$segment_Statistics St
WHERE St.Statistic_Name = 'physical reads'
ORDER BY St.VALUE DESC) Seq_Pio_r
WHERE ROWNUM <= 15
UNION ALL
select ROWNUM AS Rank
  , Seq_Pio_w.*
FROM (select St.Owner
  , St.Obj#
  , St.Object_Type
  , St.Object_Name
  , to_char(St.VALUE) as VALUE
  , 'PIO Writes' AS Unit
FROM V$segment_Statistics St
WHERE St.Statistic_Name = 'physical writes'
ORDER BY St.VALUE DESC) Seq_Pio_w
WHERE ROWNUM <= 15;