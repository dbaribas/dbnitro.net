-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # Tablespaces                                                #
prompt ##############################################################
col "USAGE (%)"          for a9
col "FREE (%)"           for a9
col Tablespace           for a20
col "Type"               for a12
col "USED USAGE"         for a12
col "FREE USAGE"         for a12
col "USED SIZE(MB)"      for a12
col "USED SIZE(GB)"      for a12
col "USED SIZE(TB)"      for a12
col "FREE SIZE(MB)"      for a12
col "FREE SIZE(GB)"      for a12
col "FREE SIZE(TB)"      for a12
col "MAX SIZE"           for a12
col "Status"             for a7
col "Status Size"        for a13
column "USED SIZE(MB)"   format 9g999g999g990 heading  'USED SIZE(MB)'
column "USED SIZE(GB)"   format 9g999g999g990 heading  'USED SIZE(GB)'
column "USED SIZE(TB)"   format 9g999g999g990 heading  'USED SIZE(TB)'
column "FREE SIZE(MB)"   format 9g999g999g990 heading  'FREE SIZE(MB)'
column "FREE SIZE(GB)"   format 9g999g999g990 heading  'FREE SIZE(GB)'
column "FREE SIZE(TB)"   format 9g999g999g990 heading  'FREE SIZE(TB)'
column "TOTAL SIZE(MB)"  format 9g999g999g990 heading  'TOTAL SIZE(MB)'
column "TOTAL SIZE(GB)"  format 9g999g999g990 heading  'TOTAL SIZE(GB)'
column "TOTAL SIZE(TB)"  format 9g999g999g990 heading  'TOTAL SIZE(TB)'
column "MAX SIZE(GB)"    format 9g999g999g990 heading  'MAX SIZE(GB)'
break on report
compute sum of "USED SIZE(MB)"   on report
compute sum of "USED SIZE(GB)"   on report
compute sum of "USED SIZE(TB)"   on report
compute sum of "FREE SIZE(MB)"   on report
compute sum of "FREE SIZE(GB)"   on report
compute sum of "FREE SIZE(TB)"   on report
compute sum of "TOTAL SIZE(MB)"  on report
compute sum of "TOTAL SIZE(GB)"  on report
compute sum of "TOTAL SIZE(TB)"  on report
compute sum of "MAX SIZE(GB)"    on report
select substr(A.tablespace_name,1,20) "Tablespace"
   , MAX(A.contents) "Type"
   , MAX(A.status) "Status"
-- , MAX(A.max_extents) "Max extents"
-- , MAX(A.pct_increase) "Pct_increase"
   , (SUM(B.BYTES) * COUNT(DISTINCT B.FILE_ID) / COUNT(B.FILE_ID)/1024/1024) - (ROUND(SUM(C.BYTES)/1024/1024/COUNT(DISTINCT B.FILE_ID))) "USED SIZE(MB)"
   , ROUND(SUM(C.BYTES)/1024/1024/COUNT(DISTINCT B.FILE_ID)) "FREE SIZE(MB)"
   , SUM(B.BYTES)*COUNT(DISTINCT B.FILE_ID)/COUNT(B.FILE_ID)/1024/1024 "TOTAL SIZE(MB)"
   , (SUM(B.BYTES)*COUNT(DISTINCT B.FILE_ID)/COUNT(B.FILE_ID)/1024/1024/1024)-(ROUND(SUM(C.BYTES)/1024/1024/1024/COUNT(DISTINCT B.FILE_ID))) "USED SIZE(GB)"
   , ROUND(SUM(C.BYTES)/1024/1024/1024/COUNT(DISTINCT B.FILE_ID)) "FREE SIZE(GB)"
   , SUM(B.BYTES)*COUNT(DISTINCT B.FILE_ID)/COUNT(B.FILE_ID)/1024/1024/1024 "TOTAL SIZE(GB)"
-- , (SUM(B.BYTES)*COUNT(DISTINCT B.FILE_ID)/COUNT(B.FILE_ID)/1024/1024/1024/1024)-(ROUND(SUM(C.BYTES)/1024/1024/1024/1024/COUNT(DISTINCT B.FILE_ID))) "USED SIZE(TB)"
   , ROUND(SUM(C.BYTES)/1024/1024/1024/1024/COUNT(DISTINCT B.FILE_ID)) "FREE SIZE(TB)"
   , SUM(B.BYTES)*COUNT(DISTINCT B.FILE_ID)/COUNT(B.FILE_ID)/1024/1024/1024/2014 "TOTAL SIZE(TB)"
-- , (SUM(B.BLOCKS)*COUNT(DISTINCT B.FILE_ID)/COUNT(B.FILE_ID))-(SUM(C.BLOCKS)/COUNT(DISTINCT B.FILE_ID)) "USED BLOCKS"
-- , SUM(C.BLOCKS)/COUNT(DISTINCT B.FILE_ID) "FREE BLOCKS"
   , TO_CHAR(100-(SUM(C.BLOCKS)*100*COUNT(B.FILE_ID)/(SUM(B.BLOCKS)*COUNT(DISTINCT B.FILE_ID)))/COUNT(DISTINCT B.FILE_ID),'999.99') || '%' "USAGE (%)"
   , TO_CHAR((SUM(C.BLOCKS)*100*COUNT(B.FILE_ID)/(SUM(B.BLOCKS)*COUNT(DISTINCT B.FILE_ID)))/COUNT(DISTINCT B.FILE_ID),'999.99') || '%' "FREE (%)"
-- , SUM(B.BLOCKS)*COUNT(DISTINCT B.FILE_ID)/COUNT(B.FILE_ID) "TOTAL BLOCKS"
   , SUM(B.MAXBYTES)*COUNT(DISTINCT B.FILE_ID)/COUNT(B.FILE_ID)/1024/1024/1024 "MAX SIZE(GB)"
   , case
       when TO_CHAR(100 - (SUM(C.BLOCKS) * 100 * COUNT(B.FILE_ID) / (SUM(B.BLOCKS) * COUNT(DISTINCT B.FILE_ID))) / COUNT(DISTINCT B.FILE_ID)) < 80 then 'Size OK'
       when TO_CHAR(100 - (SUM(C.BLOCKS) * 100 * COUNT(B.FILE_ID) / (SUM(B.BLOCKS) * COUNT(DISTINCT B.FILE_ID))) / COUNT(DISTINCT B.FILE_ID)) between 80 and 90 then 'Warning'
       else 'Critical' end as "Status Size"
from dba_tablespaces A, DBA_DATA_FILES B, DBA_FREE_SPACE C
WHERE A.TABLESPACE_NAME=B.TABLESPACE_NAME
AND A.TABLESPACE_NAME=C.TABLESPACE_NAME
GROUP BY A.TABLESPACE_NAME
order by 1;
prompt
prompt ##############################################################
prompt # Datafiles                                                  #
prompt ##############################################################
TTITLE OFF
BTITLE OFF
SET FEEDBACK ON
column "Size (M)" format 9g999g999g990     heading 'Size (M)'
column "Size (G)" format 9g999g999g990     heading 'Size (G)'
column "Used (M)" format 9g999g999g990     heading 'Used (M)'
column "Used (G)" format 9g999g999g990     heading 'Used (G)'
column "Free (M)" format 9g999g999g990     heading 'Free (M)'
column "Free (G)" format 9g999g999g990     heading 'Free (G)'
column "MAX (G)"  format 9g999g999g990     heading 'MAX (G)'
col "FILE NAME"          for a80
col "AUTOEXTENSIBLE"     for a15
col "Status"             for a10
col "Tablespace Name"    for a20
col "Used (%)"           for a11
-- col "Size (M)"        for a11
-- col "Size (g)"        for a11
-- col "Used (M)"        for a15
-- col "Used (G)"        for a15
-- col "Free (M)"        for a15
-- col "Free (G)"        for a15
-- col "Max (G)"         for a15
select Substr(df.tablespace_name,1,20)           "Tablespace Name"
  , Substr(df.file_name, 1, 80)                  "File Name"
--  , AUTOEXTENSIBLE as                          "AUTOEXTENSIBLE"
  , status as                                    "Status"
  , round(df.bytes/1024/1024, 2)                 "Size (M)"
  , round(e.used_bytes/1024/1024, 2)             "Used (M)"
  , round(f.free_bytes/1024/1024, 2)             "Free (M)"
--  , case when round(df.bytes/1024/1024, 2) = round(e.used_bytes/1024/1024, 2) then 'Full/100%' else to_char(round(f.free_bytes/1024/1024, 2)) end as "Free (M)"
  , round(df.bytes/1024/1024/1024, 2)            "Size (G)"
  , round(e.used_bytes/1024/1024/1024, 2)        "Used (G)"
  , round(f.free_bytes/1024/1024/1024, 2)        "Free (G)"
--  , case when Round(df.bytes/1024/1024/1024, 2) = Round(e.used_bytes/1024/1024/1024, 2) then 'Full/100%' else to_char(Round(f.free_bytes/1024/1024/1024, 2)) end as "Free (G)"
  , df.maxbytes/1024/1024/1024 as                "Max (G)"
  , rpad(' '|| Rpad ('X',Round(e.used_bytes*10/df.bytes,0), 'X'),11,'-') "Used (%)"
FROM DBA_DATA_FILES df,
   (select file_id, Sum(Decode(bytes,NULL,0,bytes)) used_bytes FROM dba_extents GROUP by file_id) E,
   (select Max(bytes) free_bytes, file_id FROM dba_free_space GROUP BY file_id) f
WHERE e.file_id (+) = df.file_id
AND df.file_id = f.file_id (+)
ORDER BY df.tablespace_name, df.file_name;
prompt
prompt ##############################################################
prompt # TempFiles                                                  #
prompt ##############################################################
column "Size (M)" format 9g999g999 heading 'Size (M)'
column "Used (M)" format 9g999g999 heading 'Used (M)'
column "Free (M)" format 9g999g999 heading 'Free (M)'
column "Size (G)" format 9g999g999 heading 'Size (G)'
column "Used (G)" format 9g999g999 heading 'Used (G)'
column "Free (G)" format 9g999g999 heading 'Free (G)'
column "MAX (G)"  format 9g999g999 heading 'MAX (G)'
col "FILE NAME"          for a80
col "AUTOEXTENSIBLE"     for a15
col "Status"             for a10
col "Tablespace Name"    for a20
col "Used (%)"           for a11
col "Free (M)"           for a9
col "Free (G)"           for a9
-- col "Max (G)"         for a15
select substr(df.tablespace_name,1,20) as    "Tablespace Name"
  , substr(df.file_name, 1, 80) as           "File Name"
  , AUTOEXTENSIBLE as                        "AUTOEXTENSIBLE"
  , status as                                "Status"
  , round(df.bytes/1024/1024, 2) as          "Size (M)"
  , round(e.used_bytes/1024/1024, 2) as      "Used (M)"
  , case when Round(df.bytes/1024/1024, 2) = Round(e.used_bytes/1024/1024, 2) then 'Full/100%' else to_char(Round(f.free_bytes/1024/1024, 2)) end as "Free (M)"
  , round(df.bytes/1024/1024/1024, 2) as     "Size (G)"
  , round(e.used_bytes/1024/1024/1024, 2) as "Used (G)"
  , case when Round(df.bytes/1024/1024/1024, 2) = Round(e.used_bytes/1024/1024/1024, 2) then 'Full/100%' else to_char(Round(f.free_bytes/1024/1024/1024, 2)) end as "Free (G)"
  , df.maxbytes/1024/1024/1024 as            "Max (G)"
  , rpad(' '|| Rpad ('X',Round(e.used_bytes*10/df.bytes,0), 'X'),11,'-') as "Used (%)"
FROM DBA_TEMP_FILES df,
   (select file_id, sum(Decode(bytes,NULL,0,bytes)) used_bytes FROM dba_extents GROUP by file_id) E,
   (select max(bytes) free_bytes, file_id FROM dba_free_space GROUP BY file_id) f
WHERE e.file_id (+) = df.file_id
AND df.file_id  = f.file_id (+)
ORDER BY df.tablespace_name, df.file_name;