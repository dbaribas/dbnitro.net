#!/bin/sh
Author="Andre Augusto Ribas"
SoftwareVersion="1.0.5"
DateCreation="21/11/2024"
DateModification="31/12/2024"
EMAIL="ribas@dbnitro.net"
GITHUB="https://github.com/dbaribas/dbnitro.net"
WEBSITE="http://dbnitro.net"
#
if [[ "$(whoami)" == "root" ]]; then
  echo " -- YOU ARE NOT ROOT, YOU MUST BE ROOT TO EXECUTE THIS SCRIPT --"
  exit 1
fi
#
# Function to get databases from /etc/oratab
get_databases() {
  egrep -v '^#|^$|+ASM' /etc/oratab | cut -d: -f1 | uniq | sort
}
#
# Function to monitor a specific database
monitor_database() {
  local DB_NAME="${1}"
}
#
executions() {
#
V_CONN="sqlplus -S / as sysdba"
#
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' - 
#
printf "+%-50s+\n"       "--------------------------------------------------"
printf "|%-50s%-s|\n"    " ORACLE SYSTEM                                    "
printf "+%-50s+%-70s+\n" "--------------------------------------------------" "----------------------------------------------------------------------"
printf "|%-50s|%-70s|\n" " SERVICE                                          " " Results are from the last 24 hours                                   "
printf "+%-50s+%-70s+\n" "--------------------------------------------------" "----------------------------------------------------------------------"
printf "|%-50s|%-70s|\n" " Database Name...................................." " $(echo "select name from v\$database;" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database Software Release........................" " $(echo "select substr(banner,1,67) from v\$version where banner like 'Oracle Database%';" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database Version................................." " $(echo "select 'Version: ' || version || ' | Full Version: ' || version_full from v\$instance;" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database Platform................................" " $(echo "select PLATFORM_NAME from v\$database;" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database Status.................................." " $(echo "select status from v\$instance;" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database Open Mode..............................." " $(echo "select open_mode from v\$database;" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database Role...................................." " $(echo "select database_role from v\$database;" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database Characterset............................" " $(echo "select to_char(value) from nls_database_parameters where parameter = 'NLS_CHARACTERSET';" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database Type...................................." " $(echo "select database_type from v\$instance;" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database Size...................................." " $(echo "select trim(to_char(SUM(bytes/1024/1024), '999,999,990.00')) || ' MB | ' || trim(to_char(SUM(bytes/1024/1024/1024), '999,999,990.00')) || ' GB | ' || trim(to_char(SUM(bytes/1024/1024/1024/1024), '999,999,990.00')) || ' TB' FROM dba_data_files;" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database CPU....................................." " $(echo "select to_char(value) || ' => ' || comments from v\$osstat where stat_name in ('NUM_CPUS','NUM_CPU_CORES','NUM_CPU_SOCKETS');" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database Memory.................................." " $(echo "select round(value/1024/1024/1024, 2) || ' GB => Physical Memory' from v\$osstat where stat_name in ('PHYSICAL_MEMORY_BYTES');" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database SGA....................................." " $(echo "select trim(to_char(sum(value/1024/1024), '999G999G999G999D999')) || ' MB' || ' | ' || trim(to_char(sum(value/1024/1024/1024), '999G999G999G999D999')) || ' GB' from v\$sga;" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database PGA....................................." " $(echo "select trim(to_char(SUM(value/1024/1024), '999G999G999G999D999')) || ' MB' || ' | ' || trim(to_char(SUM(value/1024/1024/1024), '999G999G999G999D999')) || ' GB' from v\$pgastat WHERE name = 'total PGA allocated';" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database Process Limit..........................." " $(echo "select 'Process Limit: ' || trim(initial_allocation) || ' | Max Utilization: ' || max_utilization from v\$resource_limit where resource_name = 'processes';" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database Sessions Limit.........................." " $(echo "select 'Sessions Limit: ' || trim(initial_allocation) || ' | Max Utilization: ' || max_utilization from v\$resource_limit where resource_name = 'sessions';" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database Availability............................" " $(echo "select 'Started Up: ' ||to_char(startup_time, 'YYYY-MM-DD hh24:mi') from v\$instance;" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database Tablespaces............................." " $(echo "select LISTAGG(status_count, ' | ') WITHIN GROUP (ORDER BY CASE WHEN status = 'Total' THEN 1 WHEN status = 'OK' THEN 2 WHEN status = 'Warning' THEN 3 WHEN status = 'Critical' THEN 4 END) AS status_summary FROM (SELECT 'Total: ' || COUNT(*) AS status_count, 'Total' AS status FROM (SELECT DISTINCT df.tablespace_name FROM dba_data_files df) UNION ALL SELECT 'OK: ' || COUNT(*) AS status_count, 'OK' AS status FROM (SELECT df.tablespace_name FROM dba_data_files df LEFT JOIN dba_free_space fs ON df.tablespace_name = fs.tablespace_name GROUP BY df.tablespace_name HAVING ROUND((SUM(df.bytes) - NVL(SUM(fs.bytes), 0)) / SUM(df.bytes) * 100, 2) <= 80) UNION ALL SELECT 'Warning: ' || COUNT(*) AS status_count, 'Warning' AS status FROM (SELECT df.tablespace_name FROM dba_data_files df LEFT JOIN dba_free_space fs ON df.tablespace_name = fs.tablespace_name GROUP BY df.tablespace_name HAVING ROUND((SUM(df.bytes) - NVL(SUM(fs.bytes), 0)) / SUM(df.bytes) * 100, 2) > 80 AND ROUND((SUM(df.bytes) - NVL(SUM(fs.bytes), 0)) / SUM(df.bytes) * 100, 2) <= 90) UNION ALL SELECT 'Critical: ' || COUNT(*) AS status_count, 'Critical' AS status FROM (SELECT df.tablespace_name FROM dba_data_files df LEFT JOIN dba_free_space fs ON df.tablespace_name = fs.tablespace_name GROUP BY df.tablespace_name HAVING ROUND((SUM(df.bytes) - NVL(SUM(fs.bytes), 0)) / SUM(df.bytes) * 100, 2) > 90)) final_summary;" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database Datafiles..............................." " $(echo "select dbms_xplan.FORMAT_NUMBER(count(*)) || 'Datafiles' from dba_data_files;" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database Online Redologs........................." " $(echo "select count(*) || ' Groups | ' || count(DISTINCT group#) || ' Files With ' || bytes/1024/1024 || ' MB Each' AS result from v\$log GROUP BY bytes;" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database Standby Redologs........................" " $(echo "select case when count(*) = 0 THEN 'No Standby Groups Found' ELSE count(*) || ' Groups | ' || count(DISTINCT group#) || ' Files With ' || bytes/1024/1024 || ' MB Each' end AS result from v\$standby_log GROUP BY bytes;" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database Dataguard..............................." " $(echo "select case when value = 'FALSE' then 'NO' when value = 'TRUE' then 'YES' end from v\$parameter where name = 'dg_broker_start';" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database Jobs...................................." " $(echo "select 'Jobs Success: ' || count(CASE WHEN status = 'SUCCEEDED' THEN 1 END) || ' | Jobs NOT Success: ' || count(CASE WHEN status != 'SUCCEEDED' THEN 1 END) from dba_scheduler_job_run_details WHERE log_date >= SYSDATE - 1;" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database Statistics.............................." " $(echo "select 'GATHER_STATS_JOB: ' || status FROM DBA_SCHEDULER_JOB_RUN_DETAILS WHERE job_name = 'GATHER_STATS_JOB' AND actual_start_date >= SYSTIMESTAMP - 1;" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database Archivelog Mode........................." " $(echo "select case when log_mode ='ARCHIVELOG' then 'YES' else 'NO' end from v\$database;" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database Archive Lag Target......................" " $(echo "select value || ' Seconds' from v\$parameter where name = 'archive_lag_target';" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database Undo Retention.........................." " $(echo "select value || ' Seconds' from v\$parameter where name = 'undo_retention';" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database Flash Recovery Area....................." " $(echo "select 'Total: ' || trim(to_char(space_limit/1024/1024/1024, '999,999.99')) || ' GB => Used: ' || trim(to_char(space_used/1024/1024/1024, '999,999.99')) || ' GB => ' || round((space_used/space_limit) * 100, 2) || '%' FROM v\$recovery_file_dest;" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database Flashback ON............................" " $(echo "select to_char(flashback_on) from v\$database;" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database Force Logging..........................." " $(echo "select to_char(force_logging) from v\$database;" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database Alert Log..............................." " $(echo "select count(*) || ' Oracle Errors' from sys.X\$DBGALERTEXT where (lower(MESSAGE_TEXT) like '%ora-%' or lower(MESSAGE_TEXT) like '%error%' or lower(MESSAGE_TEXT) like '%fail%') and ORIGINATING_TIMESTAMP > sysdate - 1;" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database Backup.................................." " $(echo "select 'Full: ' || (select count(*) from V\$RMAN_BACKUP_JOB_DETAILS WHERE INPUT_TYPE = 'DB FULL' AND START_TIME > SYSDATE - 1) || ' times | ' || 'Inc: ' || (select count(*) from V\$RMAN_BACKUP_JOB_DETAILS WHERE INPUT_TYPE = 'INCREMENTAL' AND START_TIME > SYSDATE - 1) || ' times | ' || 'Arch: ' || (SELECT COUNT(*) from V\$RMAN_BACKUP_JOB_DETAILS WHERE INPUT_TYPE = 'ARCHIVELOG' AND START_TIME > SYSDATE - 1) || ' times' AS backup_summary from dual;" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database Components Status......................." " $(echo "select 'Valid: ' || count(CASE WHEN status = 'VALID' THEN 1 END) || ' | Invalid: ' || count(CASE WHEN status = 'INVALID' THEN 1 END) || ' | OPTION OFF: ' || count(CASE WHEN status not in ('INVALID','VALID') THEN 1 END)  from DBA_REGISTRY;" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database Objects Status.........................." " $(echo "select 'Invalid Ojbects: ' || trim(count(*)) from all_objects where status != 'VALID';" | ${V_CONN} | tail -2) "
printf "|%-50s|%-70s|\n" " Database Patches................................." " $(echo "select 'Patch ID: ' || patch_id || ' | Applied: ' || to_char(action_time, 'YYYY-MM-DD hh24:mm:ss') from dba_registry_sqlpatch where description like '%Release Update%' order by action_time DESC FETCH FIRST 1 ROW ONLY;" | ${V_CONN} | tail -2) "
printf "+%-50s+%-70s+\n" "--------------------------------------------------" "----------------------------------------------------------------------"
}
#
# Main script logic
if [[ "${1}" == "-db" ]]; then
  if [[ "${2}" == "all" ]]; then
    DATABASES=$(get_databases)
    for DBS in ${DATABASES}; do
      monitor_database "${DBS}"
      ORAENV_ASK="NO"
      ORACLE_SID="${DBS}"
      . /usr/local/bin/oraenv <<< ${ORACLE_SID} > /dev/null
      executions
    done
  elif [[ -n "${2}" ]]; then
    monitor_database "${2}"
    ORAENV_ASK="NO"
    ORACLE_SID="${2}"
    . /usr/local/bin/oraenv <<< ${ORACLE_SID} > /dev/null
    executions
  else
    echo "Error: Missing database name or 'all' after -db."
    exit 1
  fi
else
  echo "Usage: sh monitoring.sh -db [ all | <DB_NAME> ]"
  exit 1
fi
#
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
# THE SCRIPT FINISHES HERE
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
#
