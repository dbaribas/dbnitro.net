set verify off lin 700
col username form a30
col program form a80
col sid form 9999
select username
  , sid
  , program 
from v$session
where username is not null 
and username not in ('SYS','SYSMAN','DBSNMP','SYSTEM')
order by 1,2,3;
prompt

define m_sid = &1

column name              format a40
column value             format 999999999999
column category          format a10
column allocated         format 999999999999
column used              format 999999999999
column max_allocated     format 999999999999
column pga_used_mem      format 999999999999
column pga_alloc_mem     format 999999999999
column pga_freeable_mem  format 999999999999
column pga_max_mem       format 999999999999
select name
  , round(value/1024,2) kb_value
from v$sesstat ss
  , v$statname sn
where sn.name like '%ga memory%'
and ss.statistic# = sn.statistic#
and ss.sid = &m_sid
order by 1,2;
prompt
select category
  , round(allocated/1024,2) Kb_alocados
  , round(used/1024,2) Kb_usados
  , round(max_allocated/1024,2) Kb_max_alocados
from v$process_memory
where pid = (select pid from v$process where addr = (select paddr from V$session where sid = &m_sid));
prompt
select round(pga_used_mem/1024,2)     Kb_pga_used_mem
  , round(pga_alloc_mem/1024,2)    kb_pga_alloc_mem
  , round(pga_freeable_mem/1024,2) kb_pga_freeable_mem
  , round(pga_max_mem/1024,2)      kb_pga_max_mem
from v$process
where addr = (select paddr from V$session where sid = &m_sid);