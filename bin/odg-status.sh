#!/bin/sh
#
Author="Andre Augusto Ribas"
SoftwareVersion="1.0.1"
DateCreation="07/07/2023"
DateModification="07/07/2023"
EMAIL="dba.ribas@gmail.com"
GITHUB="https://github.com/dbaribas/dbnitro.net"
WEBSITE="http://dbnitro.net"
#
# ------------------------------------------------------------------------
# Verify if you are ROOT or not
# Send Mail Funcion
send_mail_and_exit () {
  ### cat ${MON_STATUS} | mailx -s "UMB ODG Monitoring ${ORACLE_SID}@${HOSTNAME} Status=${1}" -r ${RECEIPIENT} ${RECEIPIENT}
  #mail -s "${MON_STATUS}" -a ${MON_STATUS} ${RECEIPIENT} < ${MON_STATUS} ${RECEIPIENT}
  #exit 1
  echo "Sending email"
}
#
# ------------------------------------------------------------------------
# Hostname and Script Variable
#
HOSTNAME="$(hostname)"
RECEIPIENT="ribas@dbnitro.net"
ORATAB="/etc/oratab"
SCRIPT_FULL_NAME="$0"
SCRIPT_NAME="$(basename ${0})"
PRIMARY=""
STANDBY=""
#
# ------------------------------------------------------------------------
# Script Usage Options
#
if [[ "$#" != 2 ]]; then
  echo "Usage: ${SCRIPT_NAME} -s <ORACLE_SID>"
  exit 1
else
  ORACLE_SID=${2}
  MON_STATUS="/opt/dbnitro/logs/monitoring_status_${ORACLE_SID}.txt"
fi
#
echo "Monitoring Status Database ${ORACLE_SID}@${HOSTNAME} $(date)" > ${MON_STATUS}
#
# ------------------------------------------------------------------------
# Searching Database ID on System
#
if [[ $(cat "${ORATAB}" | egrep -i -v "^#" | egrep -i "${ORACLE_SID}:" | cut -f1 -d ':') != $2 ]]; then
  STATUS=ERROR
  echo "${STATUS}: database ${ORACLE_SID} not found in ${ORATAB}"
  echo "${STATUS}: database ${ORACLE_SID} not found in ${ORATAB}" >> ${MON_STATUS}
  send_mail_and_exit ${STATUS} 1
fi
#
# ------------------------------------------------------------------------
# Seting Variables
#
. ${HOME}/.bash_profile

ORACLE_SID=${ORACLE_SID}
ORAENV_ASK=NO

. /usr/local/bin/oraenv
#
# ------------------------------------------------------------------------
# Verifying Database Role
#
DATABASE_ROLE=$(sqlplus -S / as sysdba <<EOF
set pages 0 heading off
select DATABASE_ROLE, DB_UNIQUE_NAME from v\$database;
quit;
EOF
)
#
if [[ $(echo ${DATABASE_ROLE} | awk '{ print $1 }') == "PRIMARY" ]]; then
  PRIMARY=1
  echo "Database Role: ${DATABASE_ROLE}" >> ${MON_STATUS}
elif [[ $(echo ${DATABASE_ROLE} | awk '{ print $1,$2 }') == "PHYSICAL STANDBY" ]]; then
  STANDBY=1
  echo "Database Role: ${DATABASE_ROLE}" >> ${MON_STATUS}
else
  echo "ERROR: Unknown Database_Role ${DATABASE_ROLE}" >> ${MON_STATUS}
  send_mail_and_exit ERROR 1
fi
#
DB_UNIQUE_NAME=$(echo "${DATABASE_ROLE}" | awk '/PRIMARY/ {print $2;} /PHYSICAL STANDBY/ {print $3;}')
DB_UNIQUE_NAME_LC=$(echo ${DB_UNIQUE_NAME} | tr "[A-Z]" "[a-z]")
#
echo "Dataguard Monitoring (Configuration, Databases and Archive Destinations Without error):" >> ${MON_STATUS}
#
# ------------------------------------------------------------------------
# Collecting Dataguard Informations
#
if [[ ! -z "${PRIMARY}" ]]; then
DG_CONFIG=$(dgmgrl -silent / <<EOF
show configuration;
quit;
EOF
)
#
echo "${DG_CONFIG}" >> ${MON_STATUS}
#
if [[ $(echo "${DG_CONFIG}" | egrep -i "ora-|error" | wc -l) == 1 ]]; then
  STATUS=ERROR
else
  STATUS=OK
fi
#
echo "DGCfgStatus=${STATUS}" >> ${MON_STATUS}
#
# ------------------------------------------------------------------------
# Collecting Dataguard Database Informations
#
# PRIM_DB=`echo "${DG_CONFIG}" | awk '/Primary database/ {print $1; exit;}'`
PRIM_DB=${DB_UNIQUE_NAME}
SHOW_PRIM_DB=$(dgmgrl -silent / <<EOF
show database ${PRIM_DB};
quit;
EOF
)
#
echo "${SHOW_PRIM_DB}" >> ${MON_STATUS}
#
# ------------------------------------------------------------------------
# Show Errors Information 
#
ARCH_DEST_ERR=$(sqlplus -S "/ as sysdba" <<EOF
whenever sqlerror exit 1
whenever oserror exit 1
column dest_name format a24
set feedback off trimspool on pages 0 lines 128
select dest_name, status, error from v\$archive_dest_status where type = 'PHYSICAL' and  status != 'VALID' or error is not null;
quit;
EOF
)
#
echo "Archive destinations errors:" >> ${MON_STATUS}
#
if [[ $(echo "${ARCH_DEST_ERR}" | wc -l) == 1 ]]; then
  echo "${ARCH_DEST_ERR}" >> ${MON_STATUS}
else
  echo "" >> ${MON_STATUS}
fi
if [[ $(echo "${SHOW_PRIM_DB}" | egrep -i "ora-|error" | wc -l) == 1 ]] || [[ -n "${ARCH_DEST_ERR}" ]]; then
  STATUS=ERROR
else
  if [[ $(echo "${SHOW_PRIM_DB}" | egrep -i "transport-on" | wc -l) == 1 ]]; then
    STATUS=OK
  else
    STATUS=ERROR
  fi
fi
echo "DGPrimStatus=${STATUS}" >> ${MON_STATUS}
fi
#
# ------------------------------------------------------------------------
#
#if [ ! -z "$PRIMARY" ] ; then
#  PHYS_STBY_DB_LIST=`echo "$DG_CONFIG" | awk '/Physical standby database/ {DB_LIST=DB_LIST" "$1;} END {print DB_LIST;}'`
#  for PHYS_STBY_DB in `echo $PHYS_STBY_DB_LIST`
#  do
#    SHOW_STBY_DB=`dgmgrl -silent / <<EOF
#show database $PHYS_STBY_DB;
#EOF`
#    echo "$SHOW_STBY_DB\n" >>$MON_STATUS
#
#    if echo "$SHOW_STBY_DB" | egrep -i "ora-|error" >/dev/null
#    then
#      STATUS=ERROR
#    else
#      STATUS=OK
#    fi
#    echo "DGStbyStatus=$STATUS\n" >>$MON_STATUS
#  done
#fi
#
# ------------------------------------------------------------------------
# 
if [[ ! -z "${STANDBY}" ]]; then
#  PHYS_STBY_DB=`echo "${DG_CONFIG}" | awk -v DB_UNIQUE_NAME=${DB_UNIQUE_NAME_LC} '/Physical standby database/ {if ( $1 = DB_UNIQUE_NAME ) {print $1; exit;}}'`
PHYS_STBY_DB=${DB_UNIQUE_NAME}
SHOW_STBY_DB=$(dgmgrl -silent / <<EOF
show database ${PHYS_STBY_DB};
quit;
EOF
)
#
echo "${SHOW_STBY_DB}" >> ${MON_STATUS}
  if [[ $(echo "${SHOW_STBY_DB}" | egrep -i "ora-|error" | wc -l) == 1 ]]; then
    STATUS=ERROR
  else
    if [[ $(echo "${SHOW_STBY_DB}" | egrep -i "apply-on" | wc -l) == 1 ]]; then
      STATUS=OK
    else
      STATUS=ERROR
    fi
  fi
echo "DGStbyStatus=${STATUS}" >> ${MON_STATUS}
fi
#
# ------------------------------------------------------------------------
# Collecting FileSystem Informations
#
FS_PCT_USED_ERR=80
#
echo "Filesystem monitoring (pct_used less ${FS_PCT_USED_ERR}%):" >> ${MON_STATUS}
#
FS_USAGE=$(df -h ${ORACLE_HOME})
#
RC_DF=$?
#
echo "${FS_USAGE}" >> ${MON_STATUS}
#
if [[ "${RC_DF}" -eq 0 ]]; then
  STATUS=`echo "${FS_USAGE}" | tr -d "%" | awk -v FS_PCT_USED_ERR=${FS_PCT_USED_ERR} 'BEGIN {FLAG=0; STATUS="OK";} /^Filesystem/ {FLAG=1; next;} {if ( FLAG == 1 ) {if ( $5 > FS_PCT_USED_ERR ) {STATUS="ERROR";}}} END {print STATUS;}'`
else
  STATUS="ERROR"
fi
#
echo "FSUsageStatus=${STATUS}" >> ${MON_STATUS}
#
# ------------------------------------------------------------------------
# Check Tablespace Usage
#
if [[ ! -z "${PRIMARY}" ]]; then
TBS_PCT_USED=95
echo "Tablespace monitoring (pct_used less ${TBS_PCT_USED}%):" >> ${MON_STATUS}
TBS_USAGE=$(sqlplus -S "/ as sysdba" <<EOF
whenever sqlerror exit 1
whenever oserror exit 1
set feedback off
column used_percent format 99999.99 heading PCT_USED
select tablespace_name, used_percent from dba_tablespace_usage_metrics order by tablespace_name;
quit;
EOF
)
#
RC_TBS_USAGE=$?
#
echo "${TBS_USAGE}" >> ${MON_STATUS}
#
if [[ "${RC_TBS_USAGE}" -eq 0 ]]; then
  STATUS=$(echo "${TBS_USAGE}" | awk -v TBS_PCT_USED=${TBS_PCT_USED} 'BEGIN {FLAG=0; STATUS="OK";} /^----/ {FLAG=1; next;} {if ( FLAG == 1 ) {if ( $2 >= TBS_PCT_USED ) {STATUS="ERROR";}}} END {print STATUS;}')
else
  STATUS="ERROR"
fi
#
echo "TbsUsageStatus=${STATUS}" >> ${MON_STATUS}
#
fi
#
# ------------------------------------------------------------------------
# Check Dataguard Status
#
if [[ ! -z "${STANDBY}" ]]; then
TRANSPORT_LAG_ERR=60
APPLY_LAG_ERR=60
APPLY_FINISH_TIME_ERR=60
ESTIMATED_STARTUP_TIME_ERR=300
echo "Dataguard stats monitoring:" >> ${MON_STATUS}
#
DG_STATS=$(sqlplus -S "/ as sysdba" <<EOF
column SECONDS format 999999999
whenever sqlerror exit 1
whenever oserror exit 1
select NAME, NVL(EXTRACT(DAY FROM TO_DSINTERVAL(VALUE))*24*60*60 + EXTRACT(HOUR FROM TO_DSINTERVAL(VALUE))*60*60 + EXTRACT(MINUTE FROM TO_DSINTERVAL(VALUE))*60 + EXTRACT(SECOND FROM TO_DSINTERVAL(VALUE)),0) SECONDS from v\$dataguard_stats where name in ('transport lag','apply lag','apply finish time') 
union
select NAME, to_number(VALUE) SECONDS from v\$dataguard_stats where name = 'estimated startup time';
quit;
EOF
)
#
RC_DG_STATS=$?
#
echo "${DG_STATS}" >> ${MON_STATUS}
#
# ------------------------------------------------------------------------
# Search Error
#
if [[ "${RC_DG_STATS}" -eq 0 ]]; then
STATUS=$(echo "${DG_STATS}" | awk -v TRANSPORT_LAG_ERR=${TRANSPORT_LAG_ERR} -v APPLY_LAG_ERR=${APPLY_LAG_ERR} -v APPLY_FINISH_TIME_ERR=${APPLY_FINISH_TIME_ERR} -v ESTIMATED_STARTUP_TIME_ERR=${ESTIMATED_STARTUP_TIME_ERR} 'BEGIN {STATUS="OK";}
/^transport lag/          {if ( $3 > TRANSPORT_LAG_ERR          || NF != 3 ) {STATUS="ERROR";}}
/^apply lag/              {if ( $3 > APPLY_LAG_ERR              || NF != 3 ) {STATUS="ERROR";}}
/^apply finish time/      {if ( $4 > APPLY_FINISH_TIME_ERR      || NF != 4 ) {STATUS="ERROR";}}
/^estimated startup time/ {if ( $4 > ESTIMATED_STARTUP_TIME_ERR || NF != 4 ) {STATUS="ERROR";}}
END {print STATUS;}')
  echo "DataguardStatsStatus=${STATUS}" >> ${MON_STATUS}
else
  STATUS="ERROR"
  echo "DataguardStatsStatus=${STATUS}" >> ${MON_STATUS}
fi
fi
#
# ------------------------------------------------------------------------
# Finish Script
#
if [[ $(egrep "Status=ERROR" ${MON_STATUS} | wc -l) == 1 ]]; then
  FINAL_STATUS=ERROR
else
  FINAL_STATUS=OK
fi
#
# ------------------------------------------------------------------------
# Sending Mail
#
cat ${MON_STATUS}
if [[ "${FINAL_STATUS}" = "ERROR" ]]; then
  send_mail_and_exit ${FINAL_STATUS} 0
fi
#
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
# THE SCRIPT FINISHES HERE
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
#