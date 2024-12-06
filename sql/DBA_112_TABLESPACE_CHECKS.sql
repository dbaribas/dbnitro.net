-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 18/11/2024
-- DateModification.: 18/11/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing off colsep '|' trim on trims on numformat 999999999999999 heading on feedback off
prompt ##############################################################
prompt # DBA: TABLESPACE CHECK
prompt ##############################################################
col Tablespace FOR a40
col "Actual Size" FOR a20
col "% Used" FOR a15
col "Max Size" FOR a20
col "File Type" FOR a15
WITH total_usage AS (
  SELECT df.tablespace_name
    , ts.bigfile AS bigfile_status
    , COUNT(*) AS num_datafiles
    , ROUND(SUM(df.bytes)/1024/1024/1024, 2) AS used_size_gb
    , ROUND(SUM(df.maxbytes)/1024/1024/1024/1024, 2) AS max_size_gb
    , ROUND((SUM(df.bytes)/SUM(df.maxbytes)) * 100, 2) AS usage_percentage
  FROM (SELECT tablespace_name, bytes, maxbytes FROM dba_data_files
        UNION ALL
        SELECT tablespace_name, bytes, maxbytes FROM dba_temp_files) df
  JOIN dba_tablespaces ts
  ON df.tablespace_name = ts.tablespace_name
  GROUP BY df.tablespace_name, ts.bigfile)
SELECT tablespace_name || ' => [' || num_datafiles || ']' AS "Tablespace"
  , CASE WHEN bigfile_status = 'YES' THEN 'Bigfile' ELSE 'Smallfile' END AS "File Type"
  , CONCAT(used_size_gb, ' GB') AS "Actual Size"
  , CONCAT(usage_percentage, ' %') AS "% Used"
  , CONCAT(max_size_gb, ' GB') AS "Max Size"
  , CASE WHEN usage_percentage > 90 THEN 'Critical' WHEN usage_percentage > 80 THEN 'Warning' ELSE 'OK' END AS "Status"
FROM total_usage
ORDER BY tablespace_name;