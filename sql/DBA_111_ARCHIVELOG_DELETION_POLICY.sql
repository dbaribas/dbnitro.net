-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 18/11/2024
-- DateModification.: 18/11/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # Which Archived Logs Are Reclaimable
prompt ##############################################################
select applied
  , deleted
  , decode(rectype,11,'YES','NO') reclaimable
  , count(*)
  , min(sequence#)
  , max(sequence#) 
from v$archived_log left outer 
join sys.x$kccagf using(recid) 
where is_recovery_dest_file='YES' 
and name is not null 
group by applied
  , deleted
  , decode(rectype,11,'YES','NO') 
order by 5;


prompt ##############################################################
prompt # 
prompt ##############################################################
column deleted format a7 
column reclaimable format a11 
select applied
  , deleted
  , backup_count 
  , decode(rectype,11,'YES','NO') reclaimable,count(*) 
  , to_char(min(completion_time),'YYYY-MM-DD hh24:mi:ss') first_time 
  , to_char(max(completion_time),'YYYY-MM-DD hh24:mi:ss') last_time 
  , min(sequence#) first_seq,max(sequence#) last_seq 
from v$archived_log left outer join sys.x$kccagf using(recid) 
where is_recovery_dest_file='YES' 
group by applied
  , deleted
  , backup_count
  , decode(rectype,11,'YES','NO') 
order by min(sequence#);



prompt ##############################################################
prompt # 
prompt ##############################################################
column is_recovery_dest_file format a21
select deleted
  , status
  , is_recovery_dest_file
  , thread#
  , min(sequence#)
  , max(sequence#)
  , min(first_time)
  , max(next_time)
  , count(distinct sequence#)
  , archived
  , applied
  , backup_count
  , count("x$kccagf")
from (select deleted
        , thread#
        , sequence#
        , status
        , name
        , first_time
        , next_time
        , case x$kccagf.rectype when 11 then recid end "x$kccagf"
        , count(case archived when 'YES' then 'YES' end) over(partition by thread#,sequence#) archived
        , count(case applied when 'YES' then 'YES' end) over(partition by thread#,sequence#) applied
        , sum(backup_count) over(partition by thread#,sequence#) backup_count
        , listagg(is_recovery_dest_file || ':' || dest_id, ',') within group(order by dest_id) over(partition by thread#,sequence#) is_recovery_dest_file
      from v$archived_log left outer join sys.x$kccagf using(recid)) 
group by deleted
  , status
  , is_recovery_dest_file
  , thread#
  , archived
  , applied
  , backup_count
order by max(sequence#)
  , min(sequence#)
  , thread#
  , deleted desc
  , status;
