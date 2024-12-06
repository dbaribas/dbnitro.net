-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set feedback off timing off
alter session set nls_date_format='yyyy-mm-dd';
set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # QTD OF ARCHIVES PER HOUR
prompt ##############################################################
col 00 for a5
col 01 for a5
col 02 for a5
col 03 for a5
col 04 for a5
col 05 for a5
col 06 for a5
col 07 for a5
col 08 for a5
col 09 for a5
col 10 for a5
col 11 for a5
col 12 for a5
col 13 for a5
col 14 for a5
col 15 for a5
col 16 for a5
col 17 for a5
col 18 for a5
col 19 for a5
col 20 for a5
col 21 for a5
col 22 for a5
col 23 for a5
select trunc(first_time) day
  , to_char(sum(decode(to_char(first_time,'HH24'),'00',1,0)), '9999') "00"
  , to_char(sum(decode(to_char(first_time,'HH24'),'01',1,0)), '9999') "01"
  , to_char(sum(decode(to_char(first_time,'HH24'),'02',1,0)), '9999') "02"
  , to_char(sum(decode(to_char(first_time,'HH24'),'03',1,0)), '9999') "03"
  , to_char(sum(decode(to_char(first_time,'HH24'),'04',1,0)), '9999') "04"
  , to_char(sum(decode(to_char(first_time,'HH24'),'05',1,0)), '9999') "05"
  , to_char(sum(decode(to_char(first_time,'HH24'),'06',1,0)), '9999') "06"
  , to_char(sum(decode(to_char(first_time,'HH24'),'07',1,0)), '9999') "07"
  , to_char(sum(decode(to_char(first_time,'HH24'),'08',1,0)), '9999') "08"
  , to_char(sum(decode(to_char(first_time,'HH24'),'09',1,0)), '9999') "09"
  , to_char(sum(decode(to_char(first_time,'HH24'),'10',1,0)), '9999') "10"
  , to_char(sum(decode(to_char(first_time,'HH24'),'11',1,0)), '9999') "11"
  , to_char(sum(decode(to_char(first_time,'HH24'),'12',1,0)), '9999') "12"
  , to_char(sum(decode(to_char(first_time,'HH24'),'13',1,0)), '9999') "13"
  , to_char(sum(decode(to_char(first_time,'HH24'),'14',1,0)), '9999') "14"
  , to_char(sum(decode(to_char(first_time,'HH24'),'15',1,0)), '9999') "15"
  , to_char(sum(decode(to_char(first_time,'HH24'),'16',1,0)), '9999') "16"
  , to_char(sum(decode(to_char(first_time,'HH24'),'17',1,0)), '9999') "17"
  , to_char(sum(decode(to_char(first_time,'HH24'),'18',1,0)), '9999') "18"
  , to_char(sum(decode(to_char(first_time,'HH24'),'19',1,0)), '9999') "19"
  , to_char(sum(decode(to_char(first_time,'HH24'),'20',1,0)), '9999') "20"
  , to_char(sum(decode(to_char(first_time,'HH24'),'21',1,0)), '9999') "21"
  , to_char(sum(decode(to_char(first_time,'HH24'),'22',1,0)), '9999') "22"
  , to_char(sum(decode(to_char(first_time,'HH24'),'23',1,0)), '9999') "23"
from gv$log_history
where first_time > trunc(sysdate - 30)
and first_time < sysdate + 1
group by trunc(first_time)
order by 1;