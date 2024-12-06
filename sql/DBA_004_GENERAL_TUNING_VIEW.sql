-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # GENERAL OVERVIEW                                           #
prompt ##############################################################
DECLARE
  v_value  NUMBER;
  format(p_value in NUMBER)
    RETURN VARCHAR2 IS
  BEGIN
    RETURN LPad(to_char(Round(p_value,2),'990.00') || '%',8,' ') || '  ';
  END;
BEGIN
  -- --------------------------
  -- Dictionary Cache Hit Ratio
  -- --------------------------
  select (1 - (Sum(getmisses)/(Sum(gets) + Sum(getmisses)))) * 100
  INTO v_value
  FROM v$rowcache;
  DBMS_Output.Put('Dictionary Cache Hit Ratio       : ' || Format(v_value));
  IF v_value < 90 THEN
    DBMS_Output.Put_Line('Increase SHARED_POOL_SIZE parameter to bring value above 90%');
  ELSE
    DBMS_Output.Put_Line('Value Acceptable.');
  END IF;
  -- -----------------------
  -- Library Cache Hit Ratio
  -- -----------------------
  select (1 -(Sum(reloads)/(Sum(pins) + Sum(reloads)))) * 100
  INTO v_value
  FROM v$librarycache;
  DBMS_Output.Put('Library Cache Hit Ratio          : ' || Format(v_value));
  IF v_value < 99 THEN
  DBMS_Output.Put_Line('Increase SHARED_POOL_SIZE parameter to bring value above 99%');
  ELSE
    DBMS_Output.Put_Line('Value Acceptable.');
  END IF;
  -- -------------------------------
  -- DB Block Buffer Cache Hit Ratio
  -- -------------------------------
  select (1 - (phys.value / (db.value + cons.value))) * 100
  INTO v_value
  FROM v$sysstat phys,v$sysstat db, v$sysstat cons
  WHERE phys.name = 'physical reads' AND db.name = 'db block gets' AND cons.name = 'consistent gets';
  DBMS_Output.Put('DB Block Buffer Cache Hit Ratio  : ' || Format(v_value));
  IF v_value < 89 THEN
    DBMS_Output.Put_Line('Increase DBA_BLOCK_BUFFERS parameter to bring value above 89%');
  ELSE
    DBMS_Output.Put_Line('Value Acceptable.');
  END IF;
  -- ---------------
  -- Latch Hit Ratio
  -- ---------------
  select (1 - (Sum(misses) / Sum(gets))) * 100
  INTO v_value
  FROM v$latch;
  DBMS_Output.Put('Latch Hit Ratio                  : ' || Format(v_value));
  IF v_value < 98 THEN
    DBMS_Output.Put_Line('Increase number of latches to bring the value above 98%');
  ELSE
    DBMS_Output.Put_Line('Value acceptable.');
  END IF;
  -- -----------------------
  -- Disk Sort Ratio
  -- -----------------------
  select (disk.value/mem.value) * 100
  INTO v_value
  FROM v$sysstat disk, v$sysstat mem
  WHERE disk.name = 'sorts (disk)'
  AND mem.name  = 'sorts (memory)';
  DBMS_Output.Put('Disk Sort Ratio                  : ' || Format(v_value));
  IF v_value > 5 THEN
    DBMS_Output.Put_Line('Increase SORT_AREA_SIZE parameter to bring value below 5%');
  ELSE
    DBMS_Output.Put_Line('Value Acceptable.');
  END IF;
  -- ----------------------
  -- Rollback Segment Waits
  -- ----------------------
  select (Sum(waits)/Sum(gets))*100
  INTO v_value
  FROM v$rollstat;
  DBMS_Output.Put('Rollback Segment Waits           : ' || Format(v_value));
  IF v_value > 5 THEN
    DBMS_Output.Put_Line('Increase number of Rollback Segments to bring the value below 5%');
  ELSE
    DBMS_Output.Put_Line('Value acceptable.');
  END IF;
  -- -------------------
  -- Dispatcher Workload
  -- -------------------
  select NVL((Sum(busy)/(Sum(busy)+Sum(idle))) * 100,0)
  INTO v_value
  FROM v$dispatcher;
  DBMS_Output.Put('Dispatcher Workload              : ' || Format(v_value));
  IF v_value > 50 THEN
    DBMS_Output.Put_Line('Increase MTS_DISPATCHERS to bring the value below 50%');
  ELSE
    DBMS_Output.Put_Line('Value acceptable.');
  END IF;
END;
/
SET FEEDBACK ON
prompt
prompt ##############################################################
prompt # Waits by Class                                             #
prompt ##############################################################
col waits for a50
select 'Waits by Class | ' || wait_class as Waits
  , time_waited
FROM v$system_wait_class
WHERE wait_class != 'Idle'
ORDER BY time_waited DESC;
prompt
prompt ##############################################################
Prompt # Wait Class Breakdown                                       #
prompt ##############################################################
col waits for a50
select 'Wait Class Breakdown | ' || wait_class as Waits
  , ROUND(aas, 2)
FROM (select n.wait_class, m.time_waited/m.INTSIZE_CSEC AAS
FROM v$waitclassmetric m, v$system_wait_class n
WHERE m.wait_class_id = n.wait_class_id
AND n.wait_class != 'Idle'
UNION ALL
select 'CPU', value/100 AAS
FROM v$sysmetric
WHERE metric_name = 'CPU Usage Per Sec'
AND group_id = 2);
prompt
prompt ##############################################################
prompt # High-Level View                                            #
prompt ##############################################################
select  wait_class
  , total_waits
  , round(100 * (total_waits / sum_waits),2) pct_waits
  , time_waited, round(100 * (time_waited / sum_time),2) pct_time
from (select wait_class, total_waits, time_waited from v$system_wait_class where wait_class != 'idle'),
     (select sum(total_waits) sum_waits, sum(time_waited) sum_time from v$system_wait_class where wait_class != 'idle')
order by 5 desc;
prompt
prompt ##############################################################
prompt # Top Wait Events                                            #
prompt ##############################################################
select h.event "wait event"
  , sum(h.wait_time + h.time_waited) "total wait time"
from v$active_session_history h
  , v$event_name e
where h.sample_time between sysdate - 1/24 and sysdate
and h.event_id = e.event_id
and e.wait_class = 'idle'
group by h.event
order by 2 desc;
prompt
prompt ##############################################################
prompt # Table Scans                                                #
prompt ##############################################################
select to_char(sn.begin_interval_time,'YYYYMMDD hh24:mi:ss') start_date
  , to_char(sn.end_interval_time,'YYYYMMDD hh24:mi:ss') end_date
  , newmem.value-oldmem.value fts
from dba_hist_sysstat oldmem
  , dba_hist_sysstat newmem
  , dba_hist_snapshot sn
where sn.snap_id = (select max(snap_id) from dba_hist_snapshot)
and newmem.snap_id = sn.snap_id
and oldmem.snap_id = sn.snap_id-1
and oldmem.stat_name = 'table scans (long tables)'
and newmem.stat_name = 'table scans (long tables)';
prompt
prompt ##############################################################
prompt # Top SQL                                                    #
prompt ##############################################################
select h.user_id
  , u.username
  , sql.sql_text
  , sum(h.wait_time + h.time_waited) "total wait time"
from v$active_session_history h
  , v$sqlarea sql
  , dba_users u
  , v$event_name e
where h.sample_time between sysdate - 1/24 and sysdate
and h.sql_id = sql.sql_id
and h.user_id = u.user_id
and h.sql_id is not null
and e.event_id = h.event_id
and e.wait_class = 'idle'
group by h.user_id,sql.sql_text, u.username order by 4 desc;