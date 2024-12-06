-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set feedback off timing off
alter session set nls_date_format='yyyy-mm-dd';
set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|' trim on trims on numformat 999999999999999
prompt ##############################################################
prompt # VERIFY ALL INFOS ABOUT I/O & LATENCY
prompt ##############################################################
col name for a70
select to_char(sn.END_INTERVAL_TIME, 'yyyy-mm-dd HH24:MI:SS') "End snapshot time"
  , sum(after.PHYRDS + after.PHYWRTS - before.PHYWRTS - before.PHYRDS) "number of IOs"
  , trunc(10 * sum(after.READTIM + after.WRITETIM - before.WRITETIM - before.READTIM) / sum(1 + after.PHYRDS + after.PHYWRTS - before.PHYWRTS - before.PHYRDS)) "ave IO time (ms)"
  , trunc((select value from v$parameter where name = 'DBA_block_size') * sum(after.PHYBLKRD + after.PHYBLKWRT - before.PHYBLKRD - before.PHYBLKWRT) / sum(1 + after.PHYRDS + after.PHYWRTS - before.PHYWRTS - before.PHYRDS)) "ave IO size (bytes)"
from DBA_HIST_FILESTATXS before
  , DBA_HIST_FILESTATXS after
  , DBA_HIST_SNAPSHOT sn
where after.file# = before.file#
and after.snap_id = before.snap_id + 1
and before.instance_number = after.instance_number
and after.snap_id = sn.snap_id
and after.instance_number = sn.instance_number
group by to_char(sn.END_INTERVAL_TIME, 'yyyy-mm-dd HH24:MI:SS')
order by to_char(sn.END_INTERVAL_TIME, 'yyyy-mm-dd HH24:MI:SS');
prompt
prompt ##############################################################
prompt # Physical Reads and Writes                                  #
prompt ##############################################################
col name for a100
select NAME
  , PHYRDS "Physical Reads"
  , round((PHYRDS / PD.PHYS_READS)*100,2) "Read %"
  , PHYWRTS "Physical Writes"
  , round(PHYWRTS * 100 / PD.PHYS_WRTS,2) "Write %"
  , fs.PHYBLKRD+FS.PHYBLKWRT "Total Block I/O's"
from (select sum(PHYRDS) PHYS_READS, sum(PHYWRTS) PHYS_WRTS from v$filestat) pd
  , v$datafile df
  , v$filestat fs
where df.FILE# = fs.FILE#
order by fs.PHYBLKRD+fs.PHYBLKWRT desc;
prompt
prompt ##############################################################
prompt # ??? #
prompt ##############################################################
col event for a70
col total_waits for a15
col total_timeouts for a15
col time_waited for a15
select EVENT
  , to_char(TOTAL_WAITS) as TOTAL_WAITS
  , to_char(TOTAL_TIMEOUTS) as TOTAL_TIMEOUTS
  , to_char(TIME_WAITED) as TIME_WAITED
  , round(AVERAGE_WAIT,2) "Average Wait"
from v$system_event
order by event, to_char(TOTAL_WAITS);
prompt
prompt ##############################################################
prompt # Datafiles Sync Status                                      #
prompt ##############################################################
col name format a100
select distinct name
  , asynch_io
from v$datafile d
inner join v$iostat_file f on d.file# = f.file_no
order by 1, 2;
prompt
-- SET SERVEROUTPUT ON
-- DECLARE
  -- lat  INTEGER;
  -- iops INTEGER;
  -- mbps INTEGER;
-- BEGIN
  -- DBMS_RESOURCE_MANAGER.CALIBRATE_IO(
    -- 1    /* # of disks */
    -- , 10   /* maximum tolerable latency in milliseconds */
    -- , iops /* I/O rate per second */
    -- , mbps /* throughput, MB per second */
    -- , lat  /* actual latency in milliseconds */
   -- );
  -- DBMS_OUTPUT.PUT_LINE('max_iops = ' || iops);
  -- DBMS_OUTPUT.PUT_LINE('latency  = ' || lat);
  -- DBMS_OUTPUT.PUT_LINE('max_mbps = ' || mbps);
-- END;
-- /
prompt ##############################################################
prompt # Datafiles Size Reads                                       #
prompt ##############################################################
col name for a100
select d.name
  , f.file_no
  , f.small_read_megabytes
  , f.small_read_reqs
  , f.large_read_megabytes
--  , f.large_read_reqs
from v$iostat_file f
inner join v$datafile d on f.file_no = d.file#
order by 1, 2;