-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
Prompt # INSTANCE INFORMATION + PGA + SGA                           #
prompt ##############################################################
column "name"           format a60  heading "Name"
column "HOST NAME"      format a40  heading "Host|Name"
column "INSTANCE ID"    format a10  heading "Instance|Id"
column "INSTANCE NAME"  format a15  heading "Instance|Name"
column "INSTANCE ROLE"  format a20  heading "Instance|Role"
column "DATABASE ROLE"  format a20  heading "Database|Role"
column "STARTUP TIME"   format a20  heading "Startup|Time"
column "ACTIVE STATE"   format a10  heading "Active|State"
column "status"         format a15  heading "Status"
column "version"        format a15  heading "Version"
select to_char(inst_id)                           as "INSTANCE ID"
   , a.instance_name                              as "INSTANCE NAME"
   , a.host_name                                  as "HOST NAME"
   , a.version
   , a.status
   , a.instance_role                              as "INSTANCE ROLE"
   , b.DATABASE_ROLE                              as "DATABASE ROLE"
   , a.ACTIVE_STATE                               as "ACTIVE STATE"
   , to_char(a.startup_time,'yyyy-mm-dd hh24:mi') as "STARTUP TIME"
   , case when a.startup_time < sysdate then 'Status OK' when a.startup_time < sysdate - 7 then 'DB Restarted' else 'Verify Restarted DB' end as "Status DB"
from gv$instance a, v$database b
order by 1;
prompt
prompt ##############################################################
Prompt # PGA                                                        #
prompt ##############################################################
show parameter pga;
prompt
prompt ##############################################################
Prompt # SGA                                                        #
prompt ##############################################################
show parameter sga;
prompt
prompt ##############################################################
PROMPT # SHARED POOL                                                #
prompt ##############################################################
col name for a50
col SIZE_KB for a20
col SIZE_MB for a20
col SIZE_GB for a20
col SIZE_TB for a20
select name
  , to_char(bytes/1024, '999G999G999G999D999') as SIZE_KB
  , to_char(bytes/1024/1024, '999G999G999G999D999') as SIZE_MB
  , to_char(bytes/1024/1024/1024, '999G999G999G999D999') as SIZE_GB
  , to_char(bytes/1024/1024/1024/1024, '999G999G999G999D999') as SIZE_TB
  , RESIZEABLE
from v$sgainfo
order by name;
prompt
prompt ##############################################################
Prompt # SUM SGA                                                    #
prompt ##############################################################
SET SERVEROUTPUT ON
SET PAGESIZE 1000
SET LINESIZE 500
SET FEEDBACK OFF
select round(tot.bytes/1024/1024 ,2) total_mb
  , round(used.bytes/1024/1024 ,2) used_mb
  , round(free.bytes/1024/1024 ,2) free_mb
  , round(tot.bytes/1024/1024/1024 ,2) total_GB
  , round(used.bytes/1024/1024/1024 ,2) used_GB
  , round(free.bytes/1024/1024/1024 ,2) free_GB
  , round(tot.bytes/1024/1024/1024/1024 ,2) total_TB
  , round(used.bytes/1024/1024/1024/1024 ,2) used_TB
  , round(free.bytes/1024/1024/1024/1024 ,2) free_TB
from (select sum(bytes) bytes from v$sgastat where name != 'free memory') used
   , (select sum(bytes) bytes from v$sgastat where name = 'free memory') free
   , (select sum(bytes) bytes from v$sgastat) tot;
prompt
prompt ##############################################################
Prompt # CPU and Memory Info                                        #
prompt ##############################################################
col name for a21 
col stat_name for a25 
col value for a15
col comments for a70
select STAT_NAME
  , to_char(VALUE) as VALUE 
  , comments 
from v$osstat 
where stat_name in ('NUM_CPUS','NUM_CPU_CORES','NUM_CPU_SOCKETS') 
union 
select STAT_NAME
  , round(VALUE/1024/1024/1024, 2) || ' GB' 
  , comments 
from v$osstat 
where stat_name in ('PHYSICAL_MEMORY_BYTES');
prompt
prompt ##############################################################
prompt # TOTAL USED MEMORY                                          #
prompt ##############################################################
select decode(grouping(nm), 1, 'total', nm) nm
  , round(sum(val/1024/1024)) mb
from (select 'sga' nm, sum(value) val from v$sga union all select 'pga', sum(a.value) from v$sesstat a, v$statname b where b.name = 'session pga memory' and a.statistic# = b.statistic#)
group by rollup(nm);