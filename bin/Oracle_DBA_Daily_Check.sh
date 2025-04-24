#!/bin/bash
Author="Andre Augusto Ribas"
SoftwareVersion="1.0.1"
DateCreation="15/10/2021"
DateModification="15/10/2021"
EMAIL="ribas@dbnitro.net"
GITHUB="https://github.com/dbaribas/dbnitro.net"
WEBSITE="http://dbnitro.net"
#
#ORACLE_BASE=/u01/app/oracle
#ORACLE_HOME=${ORACLE_BASE}/product/12.1.0.2/db_1
#ORACLE_SID=$ORACLE_SID
PATH=${PATH}:/usr/sbin:${ORACLE_HOME}/bin:${GRID_HOME}/bin:${ORACLE_HOME}/OPatch
LD_LIBRARY_PATH=${ORACLE_HOME}/lib:${GRID_HOME}/lib:/lib:/usr/lib
CLASSPATH=${ORACLE_HOME}/JRE:${ORACLE_HOME}/jlib:${ORACLE_HOME}/rdbms/jlib
SCRIPT_NAME="DailyCheck.sh"
SRV_NAME=$(uname -n)
MAIL_LIST="dba.ribas@gmail.com"
#
#case ${MAIL_LIST} in "dba.ribas@gmail.com")
#   echo
#   echo "###################################################################################################################"
#   echo "You Missed Something :-)"
#   echo "Please ADD your E-mail at line# 27 by replacing this template [youremail@yourcompany.com] with YOUR E-mail address."
#   echo "###################################################################################################################"
#   echo
#   echo "Script Terminated !"
#   echo
#   exit
#   ;;
#esac
#
# #########################
# THRESHOLDS:
# #########################
# Send an E-mail for each THRESHOLD if been reached:
# ADJUST the following THRESHOLD VALUES as per your requirements:
#
FSTHRESHOLD=95          # THRESHOLD FOR FILESYSTEM %USED   [OS]
CPUTHRESHOLD=95         # THRESHOLD FOR CPU %UTILIZATION   [OS]
TBSTHRESHOLD=95         # THRESHOLD FOR TABLESPACE %USED   [DB]
FRATHRESHOLD=95         # THRESHOLD FOR FLASH RECOVERY AREA %USED   [DB]
ASMTHRESHOLD=95         # THRESHOLD FOR ASM DISK GROUPS   [DB]
UNUSEINDXTHRESHOLD=1    # THRESHOLD FOR NUMBER OF UNUSABLE INDEXES   [DB]
INVOBJECTTHRESHOLD=1    # THRESHOLD FOR NUMBER OF INVALID OBJECTS   [DB]
FAILLOGINTHRESHOLD=1    # THRESHOLD FOR NUMBER OF FAILED LOGINS   [DB]
AUDITRECOTHRESHOLD=1    # THRESHOLD FOR NUMBER OF AUDIT RECORDS   [DB]
CORUPTBLKTHRESHOLD=1    # THRESHOLD FOR NUMBER OF CORRUPTED BLOCKS   [DB]
FAILDJOBSTHRESHOLD=1    # THRESHOLD FOR NUMBER OF FAILED JOBS   [DB]
#
# #########################
# Checking The FILESYSTEM:
# #########################
# Report Partitions that reach the threshold of Used Space:
#
touch /tmp/filesystem_DBA_BUNDLE.log
#
FSLOG=/tmp/filesystem_DBA_BUNDLE.log
#
echo "Reported By Script: ${SCRIPT_NAME}"  > ${FSLOG}
echo ""                                   >> ${FSLOG}
df -h                                     >> ${FSLOG}
df -h | grep -v "^Filesystem" | awk '{print substr($0, index($0, $2))}' | grep -v "/dev/mapper/" | grep -v "/dev/asm/" | awk '{print $(NF-1)" "$NF}' | while read OUTPUT
do
  PRCUSED=$(echo ${OUTPUT} | awk '{print $1}' | cut -d'%' -f1)
  FILESYS=$(echo ${OUTPUT} | awk '{print $2}')
  if [[ ${PRCUSED} > ${FSTHRESHOLD} ]]; then
    # mail -s "ALARM: Filesystem [${FILESYS}] on Server [${SRV_NAME}] has reached ${PRCUSED}% of USED space" $MAIL_LIST < ${FSLOG}
    echo ${FSLOG}
  fi
done
#
rm -f ${FSLOG}
#
# #############################
# Checking The CPU Utilization:
# #############################
#
# Report CPU Utilization if reach >= 95%:
#
OS_TYPE=$(uname -s)
#
touch /tmp/CPULOG_DBA_BUNDLE.log
#
CPUUTLLOG=/tmp/CPULOG_DBA_BUNDLE.log
#
# Getting CPU utilization in last 5 seconds:
#
case $(uname) in
Linux)
  CPU_REPORT_SECTIONS=$(iostat -c 1 5 | sed -e 's/,/./g' | tr -s ' ' ';' | sed '/^$/d' | tail -1 | grep ';' -o | wc -l)
  CPU_COUNT=$(cat /proc/cpuinfo|grep processor|wc -l)
  if [[ ${CPU_REPORT_SECTIONS} -ge 6 ]]; then
    CPU_IDLE=$(iostat -c 1 5 | sed -e 's/,/./g' | tr -s ' ' ';' | sed '/^$/d' | tail -1| cut -d ";" -f 7)
  else
    CPU_IDLE=$(iostat -c 1 5 | sed -e 's/,/./g' | tr -s ' ' ';' | sed '/^$/d' | tail -1| cut -d ";" -f 6)
  fi
;;
AIX)
  CPU_IDLE=$(iostat -t $INTERVAL_SEC $NUM_REPORT | sed -e 's/,/./g'|tr -s ' ' ';' | tail -1 | cut -d ";" -f 6)
  CPU_COUNT=$(lsdev -C|grep Process|wc -l)
;;
SunOS)
  CPU_IDLE=$(iostat -c $INTERVAL_SEC $NUM_REPORT | tail -1 | awk '{ print $4 }')
  CPU_COUNT=$(psrinfo -v | grep "Status of processor" | wc -l)
;;
HP-UX)
  SAR="/usr/bin/sar"
  CPU_COUNT=$(lsdev -C | grep Process | wc -l)
  if [[ ! -x $SAR ]]; then
    echo "sar command is not supported on your environment | CPU Check ignored"; CPU_IDLE=99
  else
    CPU_IDLE=$(/usr/bin/sar 1 5 | grep Average | awk '{ print $5 }')
fi
;;
*)
  echo "uname command is not supported on your environment | CPU Check ignored"; CPU_IDLE=99
;;
esac
#
# Getting Utilized CPU (100-%IDLE):
#
CPU_UTL_FLOAT=$(echo "scale=2; 100-($CPU_IDLE)" | bc)
#
# Convert the average from float number to integer:
#
touch /tmp/top_processes_DBA_BUNDLE.log
#
CPU_UTL=${CPU_UTL_FLOAT%.*}
#
if [[ -z ${CPU_UTL} ]]; then
  CPU_UTL=1
fi
if [[ ${CPU_UTL} -ge ${CPUTHRESHOLD} ]]; then
  echo "CPU STATS:"                                                                                                                           > /tmp/top_processes_DBA_BUNDLE.log
  echo "========="                                                                                                                           >> /tmp/top_processes_DBA_BUNDLE.log
  mpstat 1 5                                                                                                                                 >> /tmp/top_processes_DBA_BUNDLE.log
  echo ""                                                                                                                                    >> /tmp/top_processes_DBA_BUNDLE.log
  echo "VMSTAT Output:"                                                                                                                      >> /tmp/top_processes_DBA_BUNDLE.log
  echo "============="                                                                                                                       >> /tmp/top_processes_DBA_BUNDLE.log
  echo "[If the runqueue number in the (r) column exceeds the number of CPUs [${CPU_COUNT}] this indicates a CPU bottleneck on the system]." >> /tmp/top_processes_DBA_BUNDLE.log
  echo ""                                                                                                                                    >> /tmp/top_processes_DBA_BUNDLE.log
  vmstat 2 5                                                                                                                                 >> /tmp/top_processes_DBA_BUNDLE.log
  echo ""                                                                                                                                    >> /tmp/top_processes_DBA_BUNDLE.log
  echo "Top 10 Processes:"                                                                                                                   >> /tmp/top_processes_DBA_BUNDLE.log
  echo "================"                                                                                                                    >> /tmp/top_processes_DBA_BUNDLE.log
  echo ""                                                                                                                                    >> /tmp/top_processes_DBA_BUNDLE.log
  top -c -b -n 1|head -17                                                                                                                    >> /tmp/top_processes_DBA_BUNDLE.log
  ps -eo pcpu,pid,user,args | sort -k 1 -r | head -11                                                                                        >> /tmp/top_processes_DBA_BUNDLE.log
  #mail -s "ALERT: CPU Utilization on Server [${SRV_NAME}] has reached [${CPU_UTL}%]" $MAIL_LIST < /tmp/top_processes_DBA_BUNDLE.log
  cat /tmp/top_processes_DBA_BUNDLE.log
fi
#
cat $CPUUTLLOG
#
rm -f ${CPUUTLLOG}
#
rm -f /tmp/top_processes_DBA_BUNDLE.log
#
# #########################
# Getting ORACLE_SID:
# #########################
# Exit with sending Alert mail if No DBs are running:
#
INS_COUNT=$( ps -ef | grep pmon | grep -v grep | grep -v ASM | wc -l )
#
if [[ $INS_COUNT -eq 0 ]]; then
  echo "Reported By Script: ${SCRIPT_NAME}:"                                            > /tmp/oracle_processes_DBA_BUNDLE.log
  echo " "                                                                             >> /tmp/oracle_processes_DBA_BUNDLE.log
  echo "The following are the processes running by oracle user on server ${SRV_NAME}:" >> /tmp/oracle_processes_DBA_BUNDLE.log
  echo " "                                                                             >> /tmp/oracle_processes_DBA_BUNDLE.log
  ps -ef | grep ora                                                                    >> /tmp/oracle_processes_DBA_BUNDLE.log
  #mail -s "ALARM: No Databases Are Running on Server: $SRV_NAME !!!" $MAIL_LIST < /tmp/oracle_processes_DBA_BUNDLE.log
  #
  cat /tmp/oracle_processes_DBA_BUNDLE.log
  #
  rm -f /tmp/oracle_processes_DBA_BUNDLE.log
  #
  exit
fi
#
# #########################
# Setting ORACLE_SID:
# #########################
#
for ORACLE_SID in $(ps -ef | grep pmon | grep -v grep | grep -v ASM | awk '{print $NF}' | sed -e 's/ora_pmon_//g' | grep -v sed | grep -v "s///g"); do
if [[ $ORACLE_SID == "-MGMTDB" ]]; then
  echo ""
  else
  export ORACLE_SID
fi
#
# #########################
# Getting ORACLE_HOME
# #########################
#
ORA_USER=$(ps -ef | grep ${ORACLE_SID} | grep pmon | grep -v grep | grep -v ASM | awk '{print $1}' | tail -1)
USR_ORA_HOME=$(grep ${ORA_USER} /etc/passwd | cut -f6 -d ':' | tail -1)
#
## If OS is Linux:
#
if [[ -f /etc/oratab ]]; then
  ORATAB=/etc/oratab
  ORACLE_HOME=$(grep -v '^\#' $ORATAB | grep -v '^$'| grep -i "^${ORACLE_SID}:" | perl -lpe'$_ = reverse' | cut -f3 | perl -lpe'$_ = reverse' |cut -f2 -d':')
  export ORACLE_HOME
#
## If OS is Solaris:
#
elif [[ -f /var/opt/oracle/oratab ]]; then
  ORATAB=/var/opt/oracle/oratab
  ORACLE_HOME=$(grep -v '^\#' $ORATAB | grep -v '^$' | grep -i "^${ORACLE_SID}:" | perl -lpe'$_ = reverse' | cut -f3 | perl -lpe'$_ = reverse' | cut -f2 -d':')
  export ORACLE_HOME
fi
#
## If oratab is not exist, or ORACLE_SID not added to oratab, find ORACLE_HOME in user's profile:
#
if [[ -z "${ORACLE_HOME}" ]]; then
  ORACLE_HOME=$(grep -h 'ORACLE_HOME=\/' $USR_ORA_HOME/.bash* $USR_ORA_HOME/.*profile | perl -lpe'$_ = reverse' | cut -f1 -d'=' | perl -lpe'$_ = reverse' | tail -1)
  export ORACLE_HOME
fi
#
# #########################
# Variables:
# #########################
#
export PATH=${PATH}:${ORACLE_HOME}/bin
#
export LOG_DIR=${USR_ORA_HOME}/BUNDLE_Logs
#
mkdir -p ${LOG_DIR}
#
chown -R ${ORA_USER} ${LOG_DIR}
#
chmod -R go-rwx ${LOG_DIR}
#
if [[ ! -d ${LOG_DIR} ]]; then
  mkdir -p /tmp/BUNDLE_Logs
  #
  LOG_DIR=/tmp/BUNDLE_Logs
  #
  chown -R ${ORA_USER} ${LOG_DIR}
  #
  chmod -R go-rwx ${LOG_DIR}
fi
#
# ########################
# Getting ORACLE_BASE:
# ########################
#
# Get ORACLE_BASE from user's profile if it EMPTY:
#
if [[ -z "${ORACLE_BASE}" ]]; then
  ORACLE_BASE=$(grep -h 'ORACLE_BASE=\/' $USR_ORA_HOME/.bash* $USR_ORA_HOME/.*profile | perl -lpe'$_ = reverse' | cut -f1 -d'=' | perl -lpe'$_ = reverse' | tail -1)
fi
#
# #########################
# Getting DB_NAME:
# #########################
#
VAL1=$(sqlplus -S / as sysdba <<EOF
conn / as sysdba
set pages 0 feedback off;
prompt
SELECT name from v\$database;
quit;
EOF
)
#
echo $VAL1
#
# Getting DB_NAME in Uppercase & Lowercase:
#
DB_NAME_UPPER=$(echo $VAL1 | perl -lpe '$_ = reverse' | awk '{print $1}' | perl -lpe '$_ = reverse')
DB_NAME_LOWER=$(echo "$DB_NAME_UPPER" | tr -s  '[:upper:]' '[:lower:]')
#
# DB_NAME is Uppercase or Lowercase?:
#
if [[ -d ${ORACLE_HOME}/diagnostics/${DB_NAME_LOWER} ]]; then
  DB_NAME=${DB_NAME_LOWER}
  echo ${DB_NAME}
  else
  DB_NAME=${DB_NAME_UPPER}
  echo ${DB_NAME}
fi
#
# ###################
# Checking DB Version:
# ###################
#
VAL311=$(sqlplus -S / as sysdba <<EOF
set pages 0 feedback off;
prompt
select version from v\$instance;
quit;
EOF
)
#
echo $VAL311
#
DB_VER=$(echo $VAL311 | perl -lpe '$_ = reverse' | awk '{print $1}' | perl -lpe '$_ = reverse' | cut -f1 -d '.')
echo $DB_VER
#
# #####################
# Getting DB Block Size:
# #####################
#
VAL312=$(sqlplus -S / as sysdba <<EOF
set pages 0 feedback off;
prompt
select value from v\$parameter where name='db_block_size';
quit;
EOF
)
echo $VAL312
#
blksize=$(echo $VAL312 | perl -lpe '$_ = reverse' | awk '{print $1}' | perl -lpe '$_ = reverse' | cut -f1 -d '.')
echo $blksize
#
# #####################
# Getting DB ROLE:
# #####################
#
VAL312=$(sqlplus -S / as sysdba <<EOF
set pages 0 feedback off;
prompt
select DATABASE_ROLE from v\$database;
quit;
EOF
)
echo $VAL312
#
DB_ROLE=$(echo $VAL312 | perl -lpe '$_ = reverse' | awk '{print $1}' | perl -lpe'$_ = reverse' | cut -f1 -d '.')
echo $DB_ROLE
#
case ${DB_ROLE} in
 PRIMARY) 
 DB_ROLE_ID=0
 ;;
 *) DB_ROLE_ID=1
 ;;
esac
#
# ######################################
# Check Flash Recovery Area Utilization:
# ######################################
#
VAL318=$(sqlplus -S / as sysdba <<EOF
set pages 0 feedback off;
prompt
select value from v\$parameter where name='db_recovery_file_dest';
quit;
EOF
)
echo $VAL318
#
FRA_LOC=$(echo ${VAL318} | perl -lpe '$_ = reverse' | awk '{print $1}' | perl -lpe '$_ = reverse' | cut -f1 -d '.')
echo $FRA_LOC
#
# If FRA is configured, check the its utilization:
#
if [[ ! -z ${FRA_LOC} ]]; then
  FRACHK1=$(sqlplus -S "/ as sysdba" << EOF
set pages 0 termout off echo off feedback off linesize 190
col name for A40
SELECT ROUND((SPACE_USED - SPACE_RECLAIMABLE)/SPACE_LIMIT * 100, 1) FROM V\$RECOVERY_FILE_DEST;
quit;
EOF
)
echo $FRACHK1
  else
  echo $FRACHK1
###fi
#
FRAPRCUSED=$(echo ${FRACHK1} | perl -lpe '$_ = reverse' | awk '{print $1}' | perl -lpe '$_ = reverse' | cut -f1 -d '.')
echo $FRAPRCUSED
#
# Convert FRAPRCUSED from float number to integer:
#
FRAPRCUSED=${FRAPRCUSED%.*}
if [[ -z ${FRAPRCUSED} ]]; then
  FRAPRCUSED=1
fi
#
# If FRA %USED >= the defined threshold then send an email alert:
#
if [[ ${FRAPRCUSED} -ge ${FRATHRESHOLD} ]]; then
  FRA_RPT=${LOG_DIR}/FRA_REPORT.log
#
FRACHK2=$(sqlplus -S / as sysdba << EOF
set linesize 199
col name for a100
col TOTAL_MB for 99999999999999999
col FREE_MB for  99999999999999999
SPOOL ${FRA_RPT}
PROMPT FLASH RECOVER AREA Utilization:
PROMPT -----------------------------------------------
SELECT NAME, SPACE_LIMIT/1024/1024 TOTAL_MB, (SPACE_LIMIT - SPACE_USED + SPACE_RECLAIMABLE)/1024/1024 AS FREE_MB, ROUND((SPACE_USED - SPACE_RECLAIMABLE)/SPACE_LIMIT * 100, 1) AS "%FULL" FROM V\$RECOVERY_FILE_DEST;
PROMPT
PROMPT FRA COMPONENTS:
PROMPT ------------------------------
select * from v\$flash_recovery_area_usage;
spool off
quit;
EOF
)
echo $FRACHK2
#
#mail -s "ALERT: FRA has reached ${FRAPRCUSED}% on database [${DB_NAME_UPPER}] on Server [${SRV_NAME}]" $MAIL_LIST < ${FRA_RPT}
#
echo ${FRA_RPT}
#
fi
#
rm -f ${FRAFULL}
#
rm -f ${FRA_RPT}
#
fi
#
# ################################
# Check ASM Diskgroup Utilization:
# ################################
#
VAL314=$(sqlplus -S / as sysdba <<EOF
set pages 0 feedback off;
prompt
select count(*) from v\$asm_diskgroup;
quit;
EOF
)
echo $VAL314
#
ASM_GROUP_COUNT=$(echo ${VAL314} | perl -lpe '$_ = reverse' | awk '{print $1}' | perl -lpe '$_ = reverse' | cut -f1 -d '.')
echo $ASM_GROUP_COUNT
#
# If ASM DISKS Are Exist, Check the size utilization:
#
if [[ ${ASM_GROUP_COUNT} > 0 ]]; then
ASM_UTL=${LOG_DIR}/ASM_UTILIZATION.log
#
ASMCHK1=$(sqlplus -S / as sysdba << EOF
set pages 0 termout off echo off feedback off linesize 190
col name for A40
spool ${ASM_UTL}
select name,ROUND((1-(free_mb / total_mb))*100, 2) "%FULL" from v\$asm_diskgroup;
spool off
quit;
EOF
)
echo $ASMCHK1
fi
#
ASMFULL=${LOG_DIR}/asm_full.log
cat ${ASM_UTL} | awk '{ print $1" "$NF }' | while read OUTPUT3; do
  ASMPRCUSED=$(echo ${OUTPUT3}|awk '{print $NF}')
  ASMDGNAME=$(echo ${OUTPUT3}|awk '{print $1}')
  echo "Reported By Script: ${SCRIPT_NAME}:"              > ${ASMFULL}
  echo " "                                               >> ${ASMFULL}
  echo "ASM_DISK_GROUP                  %USED"           >> ${ASMFULL}
  echo "----------------------          --------------"  >> ${ASMFULL}
  echo "${ASMDGNAME}                    ${ASMPRCUSED}%"  >> ${ASMFULL}
echo $ASMFULL
#
# Convert ASMPRCUSED from float number to integer:
#
ASMPRCUSED=${ASMPRCUSED%.*}
if [[ -z ${ASMPRCUSED} ]]; then
  ASMPRCUSED=1
fi
#
# If ASM %USED >= the defined threshold send an email for each DISKGROUP:
#
if [[ ${ASMPRCUSED} -ge ${ASMTHRESHOLD} ]]; then
ASM_RPT=${LOG_DIR}/ASM_REPORT.log
echo $ASM_RPT
#
ASMCHK2=$(sqlplus -S / as sysdba << EOF
set pages 100 linesize 199
col name for a35
SPOOL ${ASM_RPT}
prompt ASM DISK GROUPS:
PROMPT ------------------
select name,total_mb,free_mb,ROUND((1-(free_mb / total_mb))*100, 2) "%FULL" from v\$asm_diskgroup;
spool off
quit;
EOF
)
echo $ASMCHK2
#
#mail -s "ALERT: ASM DISK GROUP [${ASMDGNAME}] has reached ${ASMPRCUSED}% on database [${DB_NAME_UPPER}] on Server [${SRV_NAME}]" $MAIL_LIST < ${ASM_RPT}
#
echo ${ASM_RPT}
#
fi
#
done
#
echo $ASM_RPT
#
echo $ASMFULL
#
rm -f ${ASMFULL}
#
rm -f ${ASM_RPT}
#
### fi
#
# #########################
# Tablespaces Size Check:
# #########################
#
if [[ ${DB_VER} > 10 ]] && [[ ${DB_ROLE_ID} -eq 0 ]]; then
#
# If The Database Version is 11g Onwards:
#
touch ${LOG_DIR}/tablespaces_DBA_BUNDLE.log
#
TBSCHK=$(sqlplus -S / as sysdba << EOF
set pages 0 termout off echo off feedback off
col tablespace_name for A25
col y for 999999999 heading 'Total_MB'
col z for 999999999 heading 'Used_MB'
col bused for 999.99 heading '%Used'
spool ${LOG_DIR}/tablespaces_DBA_BUNDLE.log
select tablespace_name, (used_space*$blksize)/(1024*1024) Used_MB, (tablespace_size*$blksize)/(1024*1024) Total_MB, used_percent "%Used" from dba_tablespace_usage_metrics;
spool off
quit;
EOF
)
echo $TBSCHK
#
else
#
# If The Database Version is 10g Backwards:
# Check if AUTOEXTEND OFF (MAXSIZE=0) is set for any of the datafiles divide by ALLOCATED size else divide by MAXSIZE:
#
VAL33=$(sqlplus -S / as sysdba << EOF
SELECT COUNT(*) FROM DBA_DATA_FILES WHERE MAXBYTES=0;
quit;
EOF
)
echo $VAL33
#
VAL44=$(echo $VAL33| awk '{print $NF}')
case ${VAL44} in
  "0") CALCPERCENTAGE1="((sbytes - fbytes)*100 / MAXSIZE) bused " 
  ;;
    *) CALCPERCENTAGE1="round(((sbytes - fbytes) / sbytes) * 100,2) bused " 
  ;;
esac
VAL55=$(sqlplus -S / as sysdba << EOF
SELECT COUNT(*) FROM DBA_TEMP_FILES WHERE MAXBYTES=0;
quit;
EOF
)
echo $VAL44
#
VAL66=$(echo ${VAL55} | awk '{print $NF}')
case ${VAL66} in
  "0") CALCPERCENTAGE2="((sbytes - fbytes)*100 / MAXSIZE) bused " 
  ;;
    *) CALCPERCENTAGE2="round(((sbytes - fbytes) / sbytes) * 100,2) bused " 
  ;;
esac
#
TBSCHK=$(sqlplus -S / as sysdba << EOF
set pages 0 termout off echo off feedback off
col tablespace for A25
col "MAXSIZE MB" format 9999999999
col x for 999999999 heading 'Allocated MB'
col y for 999999999 heading 'Free MB'
col z for 999999999 heading 'Used MB'
col bused for 999.99 heading '%Used'
--bre on report
spool ${LOG_DIR}/tablespaces_DBA_BUNDLE.log
select a.tablespace_name tablespace
  , bb.MAXSIZE/1024/1024 "MAXSIZE MB"
  , sbytes/1024/1024 x
  , fbytes/1024/1024 y
  , (sbytes - fbytes)/1024/1024 z
  , $CALCPERCENTAGE1
--round(((sbytes - fbytes) / sbytes) * 100,2) bused
--((sbytes - fbytes)*100 / MAXSIZE) bused
from (select tablespace_name,sum(bytes) sbytes from dba_data_files group by tablespace_name ) a,
     (select tablespace_name,sum(bytes) fbytes,count(*) ext from dba_free_space group by tablespace_name) b,
     (select tablespace_name,sum(MAXBYTES) MAXSIZE from dba_data_files group by tablespace_name) bb
--where a.tablespace_name in (select tablespace_name from dba_tablespaces)
where a.tablespace_name = b.tablespace_name (+)
and a.tablespace_name = bb.tablespace_name
and round(((sbytes - fbytes) / sbytes) * 100,2) > 0
UNION ALL
select c.tablespace_name tablespace
  , dd.MAXSIZE/1024/1024 MAXSIZE_GB
  , sbytes/1024/1024 x
  , fbytes/1024/1024 y
  , (sbytes - fbytes)/1024/1024 obytes
  , $CALCPERCENTAGE2
from (select tablespace_name,sum(bytes) sbytes from dba_temp_files group by tablespace_name having tablespace_name in (select tablespace_name from dba_tablespaces)) c,
     (select tablespace_name,sum(bytes_free) fbytes,count(*) ext from v\$temp_space_header group by tablespace_name) d,
     (select tablespace_name,sum(MAXBYTES) MAXSIZE from dba_temp_files group by tablespace_name) dd
--where c.tablespace_name in (select tablespace_name from dba_tablespaces)
where c.tablespace_name = d.tablespace_name (+)
and c.tablespace_name = dd.tablespace_name
order by tablespace;
select tablespace_name
  , null
  , null
  , null
  , null
  , null || '100.00' 
from dba_data_files 
minus 
select tablespace_name
  , null
  , null
  , null
  , null
  , null || '100.00'
from dba_free_space;
spool off
quit;
EOF
)
echo $TBSCHK
fi
#
TBSLOG=${LOG_DIR}/tablespaces_DBA_BUNDLE.log
#
TBSFULL=${LOG_DIR}/full_tbs.log
#
cat ${TBSLOG} | awk '{ print $1" "$NF }' | while read OUTPUT2; do
  PRCUSED=$(echo ${OUTPUT2}|awk '{print $NF}')
  TBSNAME=$(echo ${OUTPUT2}|awk '{print $1}')
  echo "Reported By Script: ${SCRIPT_NAME}:"                            > ${TBSFULL}
  echo " "                                                             >> ${TBSFULL}
  echo "Tablespace_name          %USED"                                >> ${TBSFULL}
  echo "----------------------          -------------"                 >> ${TBSFULL}
# echo ${OUTPUT2}|awk '{print $1"                              "$NF}'  >> ${TBSFULL}
  echo "${TBSNAME}                        ${PRCUSED}%"                 >> ${TBSFULL}
# Convert PRCUSED from float number to integer:
#
PRCUSED=${PRCUSED%.*}
if [[ -z ${PRCUSED} ]]; then
  PRCUSED=1
  echo $PRCUSED
fi
#
# If the tablespace %USED >= the defined threshold send an email for each tablespace:
#
if [[ ${PRCUSED} -ge ${TBSTHRESHOLD} ]]; then
#
#mail -s "ALERT: TABLESPACE [${TBSNAME}] reached ${PRCUSED}% on database [${DB_NAME_UPPER}] on Server [${SRV_NAME}]" $MAIL_LIST < ${TBSFULL}
#
echo ${TBSFULL}
fi
#
done
#
cat ${LOG_DIR}/tablespaces_DBA_BUNDLE.log
#
cat ${LOG_DIR}/full_tbs.log
#
rm -f ${LOG_DIR}/tablespaces_DBA_BUNDLE.log
#
rm -f ${LOG_DIR}/full_tbs.log
#
# ############################################
# Checking BLOCKING SESSIONS ON THE DATABASE:
# ############################################
#
VAL77=$(sqlplus -S / as sysdba << EOF
select count(*) from gv\$LOCK l1, gv\$SESSION s1, gv\$LOCK l2, gv\$SESSION s2
where s1.sid=l1.sid and s2.sid=l2.sid and l1.BLOCK=1 and l2.request > 0 and l1.id1=l2.id1 and l2.id2=l2.id2;
quit;
EOF
)
echo $VAL77
#
VAL88=$(echo $VAL77| awk '{print $NF}')
case ${VAL88} in
  "0") 
  ;;
    *)
echo $VAL88
#
touch ${LOG_DIR}/blocking_sessions.log
#
VAL99=$(sqlplus -S / as sysdba << EOF
set linesize 190 pages 0 echo off feedback off
col BLOCKING_STATUS for a90
spool ${LOG_DIR}/blocking_sessions.log
select 'User: '||s1.username || '@' || s1.machine || '(SID=' || s1.sid ||' ) running SQL_ID:'||s1.sql_id||' is blocking User: '|| s2.username || '@' || s2.machine || '(SID=' || s2.sid || ') running SQL_ID:'||s2.sql_id||' For '||s2.SECONDS_IN_WAIT||' sec
------------------------------------------------------------------------------
Warn user '||s1.username||' Or use the following statement to kill his session:
------------------------------------------------------------------------------
ALTER SYSTEM KILL SESSION '''||s1.sid||','||s1.serial#||''' immediate;' AS blocking_status
from gv\$LOCK l1, gv\$SESSION s1, gv\$LOCK l2, gv\$SESSION s2
 where s1.sid=l1.sid and s2.sid=l2.sid
 and l1.BLOCK=1 and l2.request > 0
 and l1.id1 = l2.id1
 and l2.id2 = l2.id2
 order by s2.SECONDS_IN_WAIT desc;
spool off
quit;
EOF
)
echo $VAL99
#
#mail -s "ALERT: BLOCKING SESSIONS detected on database [${DB_NAME_UPPER}] on Server [${SRV_NAME}]" $MAIL_LIST < ${LOG_DIR}/blocking_sessions.log
#
cat ${LOG_DIR}/blocking_sessions.log
#
rm -f ${LOG_DIR}/blocking_sessions.log
;;
esac
#
# ############################################
# Checking UNUSABLE INDEXES ON THE DATABASE:
# ############################################
#
VAL111=$(sqlplus -S / as sysdba << EOF
set pages 0 feedback off echo off;
select count(*) from DBA_INDEXES where status='UNUSABLE';
quit;
EOF
)
echo $VAL111
#
VAL222=$(echo $VAL111 | awk '{print $NF}')
if [[ ${VAL222} > ${UNUSEINDXTHRESHOLD} ]]; then
 echo $VAL222
#
VAL333=$(sqlplus -s / as sysdba << EOF
set linesize 160 pages 0 echo off feedback off
spool ${LOG_DIR}/unusable_indexes.log
PROMPT FIX UN-USABLE INDEXES USING THE FOLLOWING STATEMENTS:
PROMPT ------------------------------------------------------------------------------
PROMPT
select 'ALTER INDEX '||OWNER||'.'||INDEX_NAME||' REBUILD ONLINE;' from dba_indexes where status='UNUSABLE';
spool off
quit;
EOF
)
echo $VAL333
#
#mail -s "INFO: UNUSABLE INDEXES detected on database [${DB_NAME_UPPER}] on Server [${SRV_NAME}]" $MAIL_LIST < ${LOG_DIR}/unusable_indexes.log
#
echo $${LOG_DIR}/unusable_indexes.log
#
rm -f ${LOG_DIR}/unusable_indexes.log
#
fi
#
# ############################################
# Checking INVALID OBJECTS ON THE DATABASE:
# ############################################
#
VAL444=$(sqlplus -S / as sysdba << EOF
set pages 0 feedback off echo off;
select count(*) from dba_objects where status <> 'VALID';
quit;
EOF
)
echo $VAL444
#
VAL555=$(echo ${VAL444} | awk '{print $NF}')
if [[ ${VAL555} > ${INVOBJECTTHRESHOLD} ]]; then
VAL666=$(sqlplus -S / as sysdba << EOF
set linesize 190 pages 100
spool ${LOG_DIR}/invalid_objects.log
col SUBOBJECT_NAME for a30
col status for a15
col "OWNER.OBJECT_NAME" for a65
select OWNER||'.'||OBJECT_NAME "OWNER.OBJECT_NAME",SUBOBJECT_NAME,OBJECT_TYPE,status,to_char(LAST_DDL_TIME,'DD-MON-YY HH24:mi:ss') LAST_DDL_TIME from DBA_INVALID_OBJECTS;
set pages 0 echo off feedback off
PROMPT ----------------------------------------------------------------------------------------------------
PROMPT YOU CAN FIX THOSE INVALID OBJECTS USING THE FOLLOWING STATEMENTS:
PROMPT ----------------------------------------------------------------------------------------------------
select 'alter package '||owner||'.'||object_name||' compile;' from dba_objects where status <> 'VALID' and object_type like '%PACKAGE%' union
select 'alter type '||owner||'.'||object_name||' compile specification;' from dba_objects where status <> 'VALID' and object_type like '%TYPE%'union
select 'alter '||object_type||' '||owner||'.'||object_name||' compile;' from dba_objects where status <> 'VALID' and object_type not in ('PACKAGE','PACKAGE BODY','SYNONYM','TYPE','TYPE BODY') union
select 'alter public synonym '||object_name||' compile;' from dba_objects where status <> 'VALID' and object_type ='SYNONYM';
spool off
exit;
EOF
)
echo $VAL555
#
#mail -s "WARNING: ${VAL555} INVALID OBJECTS detected on database [${DB_NAME_UPPER}] on Server [${SRV_NAME}]" $MAIL_LIST < ${LOG_DIR}/invalid_objects.log
#
cat ${LOG_DIR}/invalid_objects.log
#
rm -f ${LOG_DIR}/invalid_objects.log
#
fi
#
# ###############################################
# Checking FAILED LOGIN ATTEMPTS ON THE DATABASE:
# ###############################################
#
VAL777=$(sqlplus -S / as sysdba << EOF
set pages 0 feedback off echo off;
select /*+ parallel 2 */ COUNT(*) from DBA_AUDIT_SESSION where returncode = 1017 and timestamp > (sysdate-1);
quit;
EOF
)
echo $VAL777
#
VAL888=$(echo $VAL777 | awk '{print $NF}')
if [[ ${VAL888} > ${FAILLOGINTHRESHOLD} ]]; then
  echo $VAL888
#
VAL999=$(sqlplus -S / as sysdba << EOF
set linesize 190 pages 100
spool ${LOG_DIR}/failed_logins.log
PROMPT FAILED LOGIN ATTEMPT [SESSION DETAILS]:
PROMPT --------------------------------------------------------------------
col OS_USERNAME for a20
col USERNAME for a25
col TERMINAL for a30
col ACTION_NAME for a20
col TIMESTAMP for a21
col USERHOST for a40
select /*+ parallel 2 */ to_char (EXTENDED_TIMESTAMP, 'DD-MON-YYYY HH24:MI:SS') TIMESTAMP
  , OS_USERNAME
  , USERNAME
  , TERMINAL
  , USERHOST
  , ACTION_NAME
from DBA_AUDIT_SESSION
where returncode = 1017
and timestamp > (sysdate -1)
order by 1;
spool off
quit;
EOF
)
echo $VAL999
#
#mail -s "INFO: FAILED LOGIN ATTEMPT detected on database [${DB_NAME_UPPER}] on Server [${SRV_NAME}]" $MAIL_LIST < ${LOG_DIR}/failed_logins.log
#
cat ${LOG_DIR}/failed_logins.log
#
rm -f ${LOG_DIR}/failed_logins.log
#
fi
#
# ###############################################
# Checking AUDIT RECORDS ON THE DATABASE:
# ###############################################
#
VAL70=$(sqlplus -S / as sysdba << EOF
set pages 0 feedback off echo off;
SELECT (SELECT COUNT(*) FROM dba_audit_trail
where ACTION_NAME not like 'LOGO%' and ACTION_NAME not in ('SELECT','SET ROLE') and timestamp > SYSDATE-1)+(SELECT COUNT(*) FROM dba_fga_audit_trail WHERE timestamp > SYSDATE-1) AUD_REC_COUNT FROM dual;
quit;
EOF
)
echo $VAL70
#
touch ${LOG_DIR}/audit_records.log
#
VAL80=$(echo ${VAL70} | awk '{print $NF}')
if [[ ${VAL80} > ${AUDITRECOTHRESHOLD} ]]; then
  echo $VAL80
#
VAL90=$(sqlplus -S / as sysdba << EOF
set linesize 190 pages 100
spool ${LOG_DIR}/audit_records.log
col EXTENDED_TIMESTAMP for a36
col OWNER for a25
col OBJ_NAME for a25
col OS_USERNAME for a20
col USERNAME for a25
col USERHOST for a21
col ACTION_NAME for a25
col ACTION_OWNER_OBJECT for a55
prompt ----------------------------------------------------------
prompt Audit records in the last 24Hours AUD$...
prompt ----------------------------------------------------------
select extended_timestamp,OS_USERNAME,USERNAME,USERHOST,ACTION_NAME||'  '||OWNER||' . '||OBJ_NAME ACTION_OWNER_OBJECT
from dba_audit_trail
where
ACTION_NAME not like 'LOGO%'
and ACTION_NAME not in ('SELECT','SET ROLE')
-- and USERNAME not in ('CRS_ADMIN','DBSNMP')
-- and OS_USERNAME not in ('workflow')
-- and OBJ_NAME not like '%TMP_%'
-- and OBJ_NAME not like 'WRKDETA%'
-- and OBJ_NAME not in ('PBCATTBL','SETUP','WRKIB','REMWORK')
and timestamp > SYSDATE-1 order by EXTENDED_TIMESTAMP;
prompt ----------------------------------------------------------
prompt Fine Grained Auditing Data ...
prompt ----------------------------------------------------------
col sql_text for a70
col time for a36
col USERHOST for a21
col db_user for a15
select to_char(timestamp,'DD-MM-YYYY HH24:MI:SS') as time,db_user,userhost,sql_text,SQL_BIND
from dba_fga_audit_trail
where
timestamp > SYSDATE-1
-- and policy_name='PAYROLL_TABLE'
order by EXTENDED_TIMESTAMP;
spool off
quit;
EOF
)
echo $VAL90
#
#mail -s "INFO: AUDIT RECORDS on database [${DB_NAME_UPPER}] on Server [${SRV_NAME}]" $MAIL_LIST < ${LOG_DIR}/audit_records.log
#
cat ${LOG_DIR}/audit_records.log
#
rm -f ${LOG_DIR}/audit_records.log
#
fi
#
# ############################################
# Checking CORRUPTED BLOCKS ON THE DATABASE:
# ############################################
# It won't validate the datafiles nor scan for corrupted blocks, it will just check V$DATABASE_BLOCK_CORRUPTION view if populated.
#
VAL10=$(sqlplus -S / as sysdba << EOF
set pages 0 feedback off echo off;
select count(*) from V\$DATABASE_BLOCK_CORRUPTION;
quit;
EOF
)
echo $VAL10
#
VAL20=$(echo $VAL10 | awk '{print $NF}')
if [[ ${VAL20} > ${CORUPTBLKTHRESHOLD} ]]; then
  echo $VAL20
#
VAL30=$(sqlplus -S / as sysdba << EOF
set linesize 190 pages 100
spool ${LOG_DIR}/corrupted_blocks.log
PROMPT CORRUPTED BLOCKS DETAILS:
PROMPT --------------------------------------
select * from V\$DATABASE_BLOCK_CORRUPTION;
spool off
quit;
EOF
)
echo $VAL30
#
#mail -s "ALARM: CORRUPTED BLOCKS detected on database [${DB_NAME_UPPER}] on Server [${SRV_NAME}]" $MAIL_LIST < ${LOG_DIR}/corrupted_blocks.log
#
cat ${LOG_DIR}/corrupted_blocks.log
#
rm -f ${LOG_DIR}/corrupted_blocks.log
#
fi
#
# ############################################
# Checking FAILED JOBS ON THE DATABASE:
# ############################################
#
VAL40=$(sqlplus -S / as sysdba << EOF
set pages 0 feedback off echo off;
--SELECT (SELECT COUNT(*) FROM dba_jobs where failures <> '0') + (SELECT COUNT(*) FROM dba_scheduler_jobs where FAILURE_COUNT <> '0') FAIL_COUNT FROM dual;
SELECT (SELECT COUNT(*) FROM dba_jobs where failures <> '0') + (SELECT COUNT(*) FROM DBA_SCHEDULER_JOB_RUN_DETAILS where LOG_DATE > sysdate-1 and STATUS<>'SUCCEEDED') FAIL_COUNT FROM dual;
quit;
EOF
)
echo $VAL40
#
VAL50=$(echo ${VAL40} | awk '{print $NF}')
if [[ ${VAL50} > ${FAILDJOBSTHRESHOLD} ]]; then
  echo $VAL50
#
VAL60=$(sqlplus -S / as sysdba << EOF
set linesize 190 pages 100
spool ${LOG_DIR}/failed_jobs.log
PROMPT DBMS_JOBS:
PROMPT -----------
col LAST_RUN for a25
col NEXT_RUN for a25
set long 9999999
--select dbms_xmlgen.getxml('select job,schema_user,failures,LAST_DATE LAST_RUN,NEXT_DATE NEXT_RUN from dba_jobs where failures <> 0') xml from dual;
select job,schema_user,failures,to_char(LAST_DATE,'DD-Mon-YYYY hh24:mi:ss')LAST_RUN,to_char(NEXT_DATE,'DD-Mon-YYYY hh24:mi:ss')NEXT_RUN from dba_jobs where failures <> '0';
PROMPT DBMS_SCHEDULER:
PROMPT ----------------
col OWNER for a25
col JOB_NAME for a40
col STATE for a11
col STATUS for a11
col FAILURE_COUNT for 999 heading 'Fail'
col RUNTIME_IN_LAST24H for a25
col RUN_DURATION for a14
--HTML format Outputs:
--Set Markup Html On Entmap On Spool On Preformat Off
-- Get the whole failed runs in the last 24 hours:
select to_char(LOG_DATE,'DD-Mon-YYYY hh24:mi:ss')RUNTIME_IN_LAST24H,OWNER,JOB_NAME,STATUS,ERROR#,RUN_DURATION from DBA_SCHEDULER_JOB_RUN_DETAILS where LOG_DATE > sysdate-1 and STATUS<>'SUCCEEDED';
--XML Output
--select dbms_xmlgen.getxml('select to_char(LOG_DATE,''DD-Mon-YYYY hh24:mi:ss'')RUNTIME_IN_LAST24H,OWNER,JOB_NAME,STATUS,ERROR#,RUN_DURATION from DBA_SCHEDULER_JOB_RUN_DETAILS where LOG_DATE > sysdate-1 and STATUS<>''SUCCEEDED''') xml from dual;
spool off
quit;
EOF
)
echo $VAL60
#
#mail -s "WARNING: FAILED JOBS detected on database [${DB_NAME_UPPER}] on Server [${SRV_NAME}]" $MAIL_LIST < ${LOG_DIR}/failed_jobs.log
#
cat ${LOG_DIR}/failed_jobs.log
#
rm -f ${LOG_DIR}/failed_jobs.log
#
fi
#
# ############################################
# Checking Advisors:
# ############################################
# If the database version is 10g onward collect the advisors recommendations:
#
if [[ ${DB_VER} > 9 ]]; then
VAL611=$(sqlplus -S / as sysdba << EOF
set linesize 190 pages 100
spool ${LOG_DIR}/advisors.log
PROMPT REPORTED BY: dbdailychk.sh
PROMPT -----------------------------------------
PROMPT Tablespaces Size:
PROMPT -------------------------
PROMPT Based on Datafile MAXSIZE:
PROMPT ..........................................
set pages 1000 linesize 1000 tab off
col tablespace_name for A25
col Total_MB for 999999999999
col Used_MB for 999999999999
col '%Used' for 999.99
comp sum of Total_MB on report
comp sum of Used_MB   on report
bre on report
select tablespace_name,
       (tablespace_size*$blksize)/(1024*1024) Total_MB,
       (used_space*$blksize)/(1024*1024) Used_MB,
       used_percent "%Used"
from dba_tablespace_usage_metrics;
PROMPT ----------------------
PROMPT Active Incidents:
PROMPT ----------------------
set linesize 170
col RECENT_PROBLEMS_1_WEEK_BACK for a45
select PROBLEM_KEY RECENT_PROBLEMS_1_WEEK_BACK,to_char(FIRSTINC_TIME,'DD-MON-YY HH24:mi:ss') FIRST_OCCURENCE,to_char(LASTINC_TIME,'DD-MON-YY HH24:mi:ss')
LAST_OCCURENCE FROM V\$DIAG_PROBLEM WHERE LASTINC_TIME > SYSDATE -10;
PROMPT OUTSTANDING ALERTS:
PROMPT ----------------------
select * from DBA_OUTSTANDING_ALERTS;
PROMPT ------------------------------
PROMPT ADVISORS STATUS:
PROMPT ------------------------------
col CLIENT_NAME for a60
col window_group for a60
col STATUS for a15
SELECT client_name, status, consumer_group, window_group FROM dba_autotask_client ORDER BY client_name;
PROMPT ------------------------------
PROMPT SQL TUNING ADVISOR:
PROMPT ------------------------------
PROMPT Last Execution of SQL TUNING ADVISOR:
PROMPT ---------------------------------------------------------
col TASK_NAME for a60
SELECT task_name, status, TO_CHAR(execution_end,'DD-MON-YY HH24:MI') Last_Execution FROM dba_advisor_executions where TASK_NAME='SYS_AUTO_SQL_TUNING_TASK' and execution_end>sysdate-1;
variable Findings_Report CLOB;
   BEGIN
   :Findings_Report :=DBMS_SQLTUNE.REPORT_AUTO_TUNING_TASK(
   begin_exec => NULL,
   end_exec => NULL,
   type => 'TEXT',
   level => 'TYPICAL',
   section => 'ALL',
   object_id => NULL,
   result_limit => NULL);
   END;
   /
   print :Findings_Report
PROMPT ------------------------------
PROMPT MEMORY ADVISORS:
PROMPT ------------------------------
PROMPT SGA ADVISOR:
PROMPT ----------------------
col ESTD_DB_TIME for 99999999999999999
col ESTD_DB_TIME_FACTOR for 9999999999999999999999999999
select * from V\$SGA_TARGET_ADVICE where SGA_SIZE_FACTOR > .6 and SGA_SIZE_FACTOR < 1.6;
PROMPT --------------------------------------
PROMPT Buffer Cache ADVISOR:
PROMPT --------------------------------------
col ESTD_SIZE_MB for 9999999999999
col ESTD_PHYSICAL_READS for 99999999999999999999
col ESTD_PHYSICAL_READ_TIME for 99999999999999999999
select SIZE_FACTOR "%SIZE",SIZE_FOR_ESTIMATE ESTD_SIZE_MB,ESTD_PHYSICAL_READS,ESTD_PHYSICAL_READ_TIME,ESTD_PCT_OF_DB_TIME_FOR_READS
from V\$DB_CACHE_ADVICE where SIZE_FACTOR >.8 and SIZE_FACTOR<1.3;
PROMPT --------------------------------------
PROMPT Shared Pool ADVISOR:
PROMPT --------------------------------------
col SIZE_MB for 99999999999
col SIZE_FACTOR for 99999999
col ESTD_SIZE_MB for 99999999999999999999
col LIB_CACHE_SAVED_TIME for 99999999999999999999999999
select SHARED_POOL_SIZE_FOR_ESTIMATE SIZE_MB,SHARED_POOL_SIZE_FACTOR "%SIZE",SHARED_POOL_SIZE_FOR_ESTIMATE/1024/1024 ESTD_SIZE_MB,ESTD_LC_TIME_SAVED LIB_CACHE_SAVED_TIME,
ESTD_LC_LOAD_TIME PARSING_TIME from V\$SHARED_POOL_ADVICE
where SHARED_POOL_SIZE_FACTOR > .9 and SHARED_POOL_SIZE_FACTOR  < 1.6;
PROMPT --------------------------------------
PROMPT PGA ADVISOR:
PROMPT --------------------------------------
col SIZE_FACTOR  for 999999999
col ESTD_SIZE_MB for 99999999999999999999
col MB_PROCESSED for 99999999999999999999
col ESTD_TIME for 99999999999999999999
select PGA_TARGET_FACTOR "%SIZE",PGA_TARGET_FOR_ESTIMATE/1024/1024 ESTD_SIZE_MB,BYTES_PROCESSED/1024/1024 MB_PROCESSED,
ESTD_TIME,ESTD_PGA_CACHE_HIT_PERCENTAGE PGA_HIT,ESTD_OVERALLOC_COUNT PGA_SHORTAGE
from V\$PGA_TARGET_ADVICE where PGA_TARGET_FACTOR > .7 and PGA_TARGET_FACTOR < 1.6;
PROMPT --------------------------------------
PROMPT SEGMENT ADVISOR:
PROMPT --------------------------------------
select 'Task Name : ' || f.task_name || chr(10) || 'Start Run Time : ' || TO_CHAR(execution_start, 'dd-mon-yy hh24:mi') || chr (10) || 'Segment Name : ' || o.attr2 || chr(10) || 'Segment Type : ' || o.type || chr(10) || 'Partition Name : ' || o.attr3 || chr(10) || 'Message : ' || f.message || chr(10) || 'More Info : ' || f.more_info || chr(10) || '------------------------------------------------------' Advice
FROM dba_advisor_findings f
,dba_advisor_objects o
,dba_advisor_executions e
WHERE o.task_id = f.task_id
AND o.object_id = f.object_id
AND f.task_id = e.task_id
AND e. execution_start > sysdate - 1
AND e.advisor_name = 'Segment Advisor'
ORDER BY f.task_name;
PROMPT --------------------------------------
PROMPT DATABASE GROWTH: [In the Last ~8 days]
PROMPT --------------------------------------
set serveroutput on
Declare
    v_BaselineSize    number(20);
    v_CurrentSize    number(20);
    v_TotalGrowth    number(20);
    v_Space        number(20);
    cursor usageHist is
            select a.snap_id, SNAP_TIME, sum(TOTAL_SPACE_ALLOCATED_DELTA) over ( order by a.SNAP_ID) ProgSum
        from
            (select SNAP_ID, sum(SPACE_ALLOCATED_DELTA) TOTAL_SPACE_ALLOCATED_DELTA
            from DBA_HIST_SEG_STAT
            group by SNAP_ID
            having sum(SPACE_ALLOCATED_TOTAL) <> 0
            order by 1 ) a,
            (select distinct SNAP_ID, to_char(END_INTERVAL_TIME,'DD-Mon-YYYY HH24:Mi') SNAP_TIME
            from DBA_HIST_SNAPSHOT) b
        where a.snap_id=b.snap_id;
Begin
    select sum(SPACE_ALLOCATED_DELTA) into v_TotalGrowth from DBA_HIST_SEG_STAT;
    select sum(bytes) into v_CurrentSize from dba_segments;
    v_BaselineSize := (v_CurrentSize - v_TotalGrowth) ;
    dbms_output.put_line('SNAP_TIME           Database Size(GB)');
    for row in usageHist loop
            v_Space := (v_BaselineSize + row.ProgSum)/(1024*1024*1024);
        dbms_output.put_line(row.SNAP_TIME || '           ' || to_char(v_Space) );
    end loop;
end;
/
PROMPT ASM STATISTICS:
PROMPT --------------------------------------
select name,state,OFFLINE_DISKS,total_mb,free_mb,ROUND((1-(free_mb / total_mb))*100, 2) "%FULL" from v\$asm_diskgroup;
PROMPT FRA STATISTICS:
PROMPT --------------------------------------
PROMPT FRA_SIZE:
PROMPT --------------------------------------
col name for a25
SELECT NAME,NUMBER_OF_FILES,SPACE_LIMIT/1024/1024/1024 AS TOTAL_SIZE_GB,SPACE_USED/1024/1024/1024 SPACE_USED_GB,
SPACE_RECLAIMABLE/1024/1024/1024 SPACE_RECLAIMABLE_GB,ROUND((SPACE_USED-SPACE_RECLAIMABLE)/SPACE_LIMIT * 100, 1) AS "%FULL_AFTER_CLAIM",
ROUND((SPACE_USED)/SPACE_LIMIT * 100, 1) AS "%FULL_NOW" FROM V\$RECOVERY_FILE_DEST;
PROMPT FRA_COMPONENTS:
PROMPT --------------------------------------
select * from v\$flash_recovery_area_usage;
PROMPT --------------------------------------
PROMPT CURRENT OS / HARDWARE STATISTICS:
PROMPT --------------------------------------
select stat_name,value from v\$osstat;
PROMPT --------------------------------------
PROMPT RECYCLEBIN OBJECTS#:
PROMPT --------------------------------------
set feedback off
select count(*) COUNT from dba_recyclebin;
set feedback on
PROMPT --------------------------------------
PROMPT [Note: Consider Purging DBA_RECYCLEBIN for better performance]
PROMPT --------------------------------------
PROMPT FLASHBACK RESTORE POINTS:
PROMPT --------------------------------------
select * from V\$RESTORE_POINT;
PROMPT --------------------------------------
PROMPT HEALTH MONITOR:
PROMPT --------------------------------------
select name,type,status,description,repair_script from V\$HM_RECOMMENDATION where time_detected > sysdate -1;
PROMPT --------------------------------------
PROMPT REDO LOG SWITCHES:
PROMPT --------------------------------------
set linesize 199
col day for a11
SELECT to_char(first_time,'YYYY-MON-DD') day,
to_char(sum(decode(to_char(first_time,'HH24'),'00',1,0)),'9999') "00",
to_char(sum(decode(to_char(first_time,'HH24'),'01',1,0)),'9999') "01",
to_char(sum(decode(to_char(first_time,'HH24'),'02',1,0)),'9999') "02",
to_char(sum(decode(to_char(first_time,'HH24'),'03',1,0)),'9999') "03",
to_char(sum(decode(to_char(first_time,'HH24'),'04',1,0)),'9999') "04",
to_char(sum(decode(to_char(first_time,'HH24'),'05',1,0)),'9999') "05",
to_char(sum(decode(to_char(first_time,'HH24'),'06',1,0)),'9999') "06",
to_char(sum(decode(to_char(first_time,'HH24'),'07',1,0)),'9999') "07",
to_char(sum(decode(to_char(first_time,'HH24'),'08',1,0)),'9999') "08",
to_char(sum(decode(to_char(first_time,'HH24'),'09',1,0)),'9999') "09",
to_char(sum(decode(to_char(first_time,'HH24'),'10',1,0)),'9999') "10",
to_char(sum(decode(to_char(first_time,'HH24'),'11',1,0)),'9999') "11",
to_char(sum(decode(to_char(first_time,'HH24'),'12',1,0)),'9999') "12",
to_char(sum(decode(to_char(first_time,'HH24'),'13',1,0)),'9999') "13",
to_char(sum(decode(to_char(first_time,'HH24'),'14',1,0)),'9999') "14",
to_char(sum(decode(to_char(first_time,'HH24'),'15',1,0)),'9999') "15",
to_char(sum(decode(to_char(first_time,'HH24'),'16',1,0)),'9999') "16",
to_char(sum(decode(to_char(first_time,'HH24'),'17',1,0)),'9999') "17",
to_char(sum(decode(to_char(first_time,'HH24'),'18',1,0)),'9999') "18",
to_char(sum(decode(to_char(first_time,'HH24'),'19',1,0)),'9999') "19",
to_char(sum(decode(to_char(first_time,'HH24'),'20',1,0)),'9999') "20",
to_char(sum(decode(to_char(first_time,'HH24'),'21',1,0)),'9999') "21",
to_char(sum(decode(to_char(first_time,'HH24'),'22',1,0)),'9999') "22",
to_char(sum(decode(to_char(first_time,'HH24'),'23',1,0)),'9999') "23"
from v\$log_history where first_time > sysdate-1
GROUP by to_char(first_time,'YYYY-MON-DD') order by 1 asc;
spool off
quit;
EOF
)
echo $VAL611
#
#mail -s "ADVISORS: For Database [${DB_NAME_UPPER}] on Server: [${SRV_NAME}]" $MAIL_LIST < ${LOG_DIR}/advisors.log
#
cat ${LOG_DIR}/advisors.log
#
fi
#
# #########################
# Getting ALERTLOG path:
# #########################
#
VAL2=$(sqlplus -S / as sysdba <<EOF
set pages 0 feedback off;
prompt
SELECT value from v\$parameter where NAME='background_dump_dest';
quit;
EOF
)
echo $VAL2
#
ALERTZ=$(echo $VAL2 | perl -lpe'$_ = reverse' |awk '{print $1}'|perl -lpe'$_ = reverse')
ALERTDB=${ALERTZ}/alert_${ORACLE_SID}.log
#
echo $ALERTZ
echo $ALERTDB
#
# ###########################
# Checking Database Errors:
# ###########################
# Determine the ALERTLOG path:
#
if [[ -f ${ALERTDB} ]]; then
  ALERTLOG=${ALERTDB}
elif [[ -f $ORACLE_BASE/admin/${ORACLE_SID}/bdump/alert_${ORACLE_SID}.log ]]; then
  ALERTLOG=$ORACLE_BASE/admin/${ORACLE_SID}/bdump/alert_${ORACLE_SID}.log
elif [[ -f $ORACLE_HOME/diagnostics/${DB_NAME}/diag/rdbms/${DB_NAME}/${ORACLE_SID}/trace/alert_${ORACLE_SID}.log ]]; then
  ALERTLOG=$ORACLE_HOME/diagnostics/${DB_NAME}/diag/rdbms/${DB_NAME}/${ORACLE_SID}/trace/alert_${ORACLE_SID}.log
else
  ALERTLOG=$(/usr/bin/find ${ORACLE_BASE} -iname alert_${ORACLE_SID}.log -print 2>/dev/null)
fi
#
# Rename the old log generated by the script (if exists):
#
if [[ -f ${LOG_DIR}/alert_${ORACLE_SID}_new.log ]]; then
  mv ${LOG_DIR}/alert_${ORACLE_SID}_new.log ${LOG_DIR}/alert_${ORACLE_SID}_old.log
  # Create new log:
  tail -1000 ${ALERTLOG} > ${LOG_DIR}/alert_${ORACLE_SID}_new.log
  # Extract new entries by comparing old & new logs:
  echo "Reported By Script: ${SCRIPT_NAME}" > ${LOG_DIR}/diff_${ORACLE_SID}.log
  echo " " >> ${LOG_DIR}/diff_${ORACLE_SID}.log
  diff ${LOG_DIR}/alert_${ORACLE_SID}_old.log ${LOG_DIR}/alert_${ORACLE_SID}_new.log | grep ">" | cut -f2 -d'>' >> ${LOG_DIR}/diff_${ORACLE_SID}.log
  # Search for errors:
  ERRORS=$(cat ${LOG_DIR}/diff_${ORACLE_SID}.log | egrep 'ORA-\|TNS-' | egrep -v 'ORA-2396' | tail -1)
  FILE_ATTACH=${LOG_DIR}/diff_${ORACLE_SID}.log
else
  # Create new log:
  echo "Reported By Script: ${SCRIPT_NAME}" > ${LOG_DIR}/alert_${ORACLE_SID}_new.log
  echo " " >> ${LOG_DIR}/alert_${ORACLE_SID}_new.log
  tail -1000 ${ALERTLOG} >> ${LOG_DIR}/alert_${ORACLE_SID}_new.log
  # Search for errors:
  ERRORS=$(cat ${LOG_DIR}/alert_${ORACLE_SID}_new.log | egrep 'ORA-\|TNS-' | egrep -v "ORA-2396" | tail -1)
  FILE_ATTACH=${LOG_DIR}/alert_${ORACLE_SID}_new.log
fi
#
# Send mail in case error exist:
#
case "$ERRORS" in *ORA-*|*TNS-*)
#
#mail -s "ALERT: Instance [${ORACLE_SID}] on Server [${SRV_NAME}] reporting errors: ${ERRORS}" ${MAIL_LIST} < ${FILE_ATTACH}
#
cat ${FILE_ATTACH}
esac
#
# #####################
# Reporting Offline DBs:
# #####################
# Populate ${LOG_DIR}/alldb_DBA_BUNDLE.log from ORATAB:
#
grep -v '^\#' $ORATAB | grep -v "ASM" |grep -v "${DB_NAME_LOWER}:"| grep -v "${DB_NAME_UPPER}:"|  grep -v '^$' | grep "^" | cut -f1 -d':' > ${LOG_DIR}/alldb_DBA_BUNDLE.log
#
# Populate ${LOG_DIR}/updb_DBA_BUNDLE.log:
#
echo $ORACLE_SID >> ${LOG_DIR}/updb_DBA_BUNDLE.log
echo $DB_NAME >> ${LOG_DIR}/updb_DBA_BUNDLE.log
# End looping for databases:
#
done
#
# Continue Reporting Offline DBs...
# Sort the lines alphabetically with removing duplicates:
#
sort ${LOG_DIR}/updb_DBA_BUNDLE.log | uniq -d > ${LOG_DIR}/updb_DBA_BUNDLE.log.sort
sort ${LOG_DIR}/alldb_DBA_BUNDLE.log > ${LOG_DIR}/alldb_DBA_BUNDLE.log.sort
diff ${LOG_DIR}/alldb_DBA_BUNDLE.log.sort ${LOG_DIR}/updb_DBA_BUNDLE.log.sort > ${LOG_DIR}/diff_DBA_BUNDLE.sort
echo "The Following Instances are POSSIBLY Down on $SRV_NAME :" > ${LOG_DIR}/offdb_DBA_BUNDLE.log
grep "^< " ${LOG_DIR}/diff_DBA_BUNDLE.sort | cut -f2 -d'<' >> ${LOG_DIR}/offdb_DBA_BUNDLE.log
echo " " >> ${LOG_DIR}/offdb_DBA_BUNDLE.log
echo "If those instances are permanently offline, please hash their entries in $ORATAB to let the script ignore them in the next run." >> ${LOG_DIR}/offdb_DBA_BUNDLE.log
OFFLINE_DBS_NUM=$(cat ${LOG_DIR}/offdb_DBA_BUNDLE.log | wc -l)
#
# If OFFLINE_DBS is not null:
#
if [[ ${OFFLINE_DBS_NUM} -gt 3 ]]; then
  echo ""                           >> ${LOG_DIR}/offdb_DBA_BUNDLE.log
  echo "Current Running Instances:" >> ${LOG_DIR}/offdb_DBA_BUNDLE.log
  echo "************************"   >> ${LOG_DIR}/offdb_DBA_BUNDLE.log
  ps -ef|grep pmon|grep -v grep     >> ${LOG_DIR}/offdb_DBA_BUNDLE.log
  echo ""                           >> ${LOG_DIR}/offdb_DBA_BUNDLE.log
#
VALX1=$(sqlplus -S / as sysdba <<EOF
set pages 100;
spool ${LOG_DIR}/running_instances.log
set linesize 160
col BLOCKED for a7
col STARTUP_TIME for a19
select instance_name INS_NAME,STATUS,DATABASE_STATUS DB_STATUS,LOGINS,BLOCKED,to_char(STARTUP_TIME,'DD-MON-YY HH24:MI:SS') STARTUP_TIME from v\$instance;
spool off
quit;
EOF
)
echo $VALX1
#
cat ${LOG_DIR}/running_instances.log >> ${LOG_DIR}/offdb_DBA_BUNDLE.log
#
#mail -s "ALARM: Database Inaccessible on Server: [$SRV_NAME]" $MAIL_LIST < ${LOG_DIR}/offdb_DBA_BUNDLE.log
#
cat ${LOG_DIR}/offdb_DBA_BUNDLE.log
#
fi
#
# Wiping Logs:
#cat /dev/null >  ${LOG_DIR}/updb_DBA_BUNDLE.log
#cat /dev/null >  ${LOG_DIR}/alldb_DBA_BUNDLE.log
#cat /dev/null >  ${LOG_DIR}/updb_DBA_BUNDLE.log.sort
#cat /dev/null >  ${LOG_DIR}/alldb_DBA_BUNDLE.log.sort
#cat /dev/null >  ${LOG_DIR}/diff_DBA_BUNDLE.sort
#
rm -f ${LOG_DIR}/updb_DBA_BUNDLE.log
rm -f ${LOG_DIR}/alldb_DBA_BUNDLE.log
rm -f ${LOG_DIR}/updb_DBA_BUNDLE.log.sort
rm -f ${LOG_DIR}/alldb_DBA_BUNDLE.log.sort
rm -f ${LOG_DIR}/diff_DBA_BUNDLE.sort
#
# ###########################
# Checking Listeners log:
# ###########################
# In case there is NO Listeners are running send an (Alarm):
#
LSN_COUNT=$(ps -ef | grep -v grep | grep tnslsnr | wc -l)
#
if [[ ${LSN_COUNT} -eq 0 ]]; then
  echo "Reported By Script: ${SCRIPT_NAME}"                                                  > ${LOG_DIR}/listener_processes.log
  echo " "                                                                                  >> ${LOG_DIR}/listener_processes.log
  echo "The following are the processes running by user ${ORA_USER} on server ${SRV_NAME}:" >> ${LOG_DIR}/listener_processes.log
  echo " "                                                                                  >> ${LOG_DIR}/listener_processes.log
  ps -ef | grep -v grep | grep oracle                                                       >> ${LOG_DIR}/listener_processes.log
#
#mail -s "ALARM: No Listeners Are Running on Server: $SRV_NAME !!!" $MAIL_LIST < ${LOG_DIR}/listener_processes.log
#
cat ${LOG_DIR}/listener_processes.log
#
# In case there is a listener running analyze it's log:
#
else
  for LISTENER_NAME in $(ps -ef | grep -v grep | grep tnslsnr | awk '{print $8}'); do
    LISTENER_HOME=$(ps -ef | grep -v grep | grep tnslsnr | grep "${LISTENER_NAME} " | awk '{print $(NF-2)}' | sed -e 's/\/bin\/tnslsnr//g' | grep -v sed | grep -v "s///g")
    TNS_ADMIN=${LISTENER_HOME}/network/admin
    LISTENER_LOGDIR=$(${LISTENER_HOME}/bin/lsnrctl status ${LISTENER_NAME} | grep "Listener Log File" | awk '{print $NF}' | sed -e 's/\/alert\/log.xml//g')
    LISTENER_LOG=${LISTENER_LOGDIR}/trace/${LISTENER_NAME}.log
    # Determine if the listener name is in Upper/Lower case:
    if [[ -f  ${LISTENER_LOG} ]]; then
      # Listner_name is Uppercase:
      LISTENER_NAME=$(echo ${LISTENER_NAME} | perl -lpe'$_ = reverse' | perl -lpe'$_ = reverse')
      LISTENER_LOG=${LISTENER_LOGDIR}/trace/${LISTENER_NAME}.log
    else
      # Listener_name is Lowercase:
      LISTENER_NAME=$(echo "${LISTENER_NAME}" | tr -s  '[:upper:]' '[:lower:]')
      LISTENER_LOG=${LISTENER_LOGDIR}/trace/${LISTENER_NAME}.log
    fi
#
# Rename the old log (If exists):
#
  if [[ -f ${LOG_DIR}/alert_${LISTENER_NAME}_new.log ]]; then
    mv ${LOG_DIR}/alert_${LISTENER_NAME}_new.log ${LOG_DIR}/alert_${LISTENER_NAME}_old.log
    # Create a new log:
    tail -1000 ${LISTENER_LOG} > ${LOG_DIR}/alert_${LISTENER_NAME}_new.log
    # Get the new entries:
    echo "Reported By Script: ${SCRIPT_NAME}" > ${LOG_DIR}/diff_${LISTENER_NAME}.log
    echo " " >> ${LOG_DIR}/diff_${LISTENER_NAME}.log
    diff ${LOG_DIR}/alert_${LISTENER_NAME}_old.log  ${LOG_DIR}/alert_${LISTENER_NAME}_new.log | grep ">" | cut -f2 -d'>' >> ${LOG_DIR}/diff_${LISTENER_NAME}.log
    # Search for errors:
    ERRORS=$(cat ${LOG_DIR}/diff_${LISTENER_NAME}.log | grep "TNS-" | tail -1)
    SRVC_REG=$(cat ${LOG_DIR}/diff_${LISTENER_NAME}.log | grep "service_register")
    FILE_ATTACH=${LOG_DIR}/diff_${LISTENER_NAME}.log
    # If no old logs exist:
  else
    # Just create a new log without doing any comparison:
    echo "Reported By Script: ${SCRIPT_NAME}" > ${LOG_DIR}/alert_${LISTENER_NAME}_new.log
    echo " " >> ${LOG_DIR}/alert_${LISTENER_NAME}_new.log
    tail -1000 ${LISTENER_LOG} >> ${LOG_DIR}/alert_${LISTENER_NAME}_new.log
    # Search for errors:
    ERRORS=$(cat ${LOG_DIR}/alert_${LISTENER_NAME}_new.log | grep "TNS-" | tail -1)
    SRVC_REG=$(cat ${LOG_DIR}/alert_${LISTENER_NAME}_new.log | grep "service_register")
    FILE_ATTACH=${LOG_DIR}/alert_${LISTENER_NAME}_new.log
  fi
  # Report TNS Errors (Alert)
  case "$ERRORS" in
    *TNS-*)
	#
	#mail -s "ALERT: Listener [${LISTENER_NAME}] on Server [${SRV_NAME}] reporting errors: ${ERRORS}" $MAIL_LIST < ${FILE_ATTACH}
	#
    cat ${FILE_ATTACH}
esac
#
# Report Registered Services to the listener (Info)
case "${SRVC_REG}" in
  *service_register*)
#
mail -s "INFO: Service Registered on Listener [${LISTENER_NAME}] on Server [${SRV_NAME}] | TNS poisoning posibility" $MAIL_LIST < ${FILE_ATTACH}
#
cat ${FILE_ATTACH}
#
esac
#
done
#
fi
#
# #############
# END OF SCRIPT
# #############