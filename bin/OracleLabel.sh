#!/bin/sh
Author="Andre Augusto Ribas"
SoftwareVersion="1.0.1"
DateCreation="18/09/2023"
DateModification="19/09/2023"
EMAIL_1="dba.ribas@gmail.com"
EMAIL_2="andre.ribas@icloud.com"
WEBSITE="http://dbnitro.net"
#
# ------------------------------------------------------------------------
# Separate Line Function
#
SepLine() {
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' - 
}
#
# ------------------------------------------------------------------------
# Verify ROOT User
#
if [[ $(whoami) == "root" ]]; then
  SetClear
  SepLine
  echo " -- YOUR USER IS ROOT, YOU CAN NOT USE THIS SCRIPT WITH ROOT USER --"
  echo " -- PLEASE USE OTHER USER TO ACCESS THIS SCRIPTS --"
  break 1
fi
#
# ------------------------------------------------------------------------
# Verify OS Parameters and Variables
#
ORA_HOMES_IGNORE_0="REMOVED|REFHOME|DEPHOME|PLUGINS|/usr/lib/oracle/sbin"
ORA_HOMES_IGNORE_1="${ORA_HOMES_IGNORE_0}|goldengate|ogg|gg|middleware|agent"
ORA_HOMES_IGNORE_2="${ORA_HOMES_IGNORE_0}|goldengate|ogg|gg|middleware"
ORA_HOMES_IGNORE_3="${ORA_HOMES_IGNORE_0}|middleware|agent"
ORA_HOMES_IGNORE_4="${ORA_HOMES_IGNORE_0}|goldengate|ogg|gg|agent"
ORA_HOMES_IGNORE_5="+apx|-mgmtdb"
#
if [[ $(uname) == "SunOS" ]]; then
  OS="Solaris"
  ORATAB="/var/opt/oracle/oratab"
  ORA_INST="/var/opt/oracle/oraInst.loc"
  ORA_INVENTORY="$(cat ${ORA_INST} | egrep -i "inventory_loc" | cut -f2 -d '=')/ContentsXML/inventory.xml"
  ORA_SERVICES="$(ps -ef | egrep -i "pmon" | egrep -i -v "egrep|grep" | wc -l)"
  TMP="/tmp"
  TMPDIR="${TMP}"
  HOST=$(hostname)
  UPTIME=$(uptime | sed 's/.*up \([^,]*\), .*/\1/')
  ORA_HOMES=$(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_1}" | egrep -i "LOC"                                  | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  ORA_AGENT=$(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_2}" | egrep -i "LOC"   | egrep -i "agent"             | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  OGG_HOME=$(cat ${ORA_INVENTORY}  | egrep -i -v "^#|${ORA_HOMES_IGNORE_3}" | egrep -i "LOC"   | egrep -i "goldengate|ogg|gg" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  ORA_OMS=$(cat ${ORA_INVENTORY}   | egrep -i -v "^#|${ORA_HOMES_IGNORE_4}" | egrep -i "LOC"   | egrep -i "middleware"        | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  DBLIST=$(cat ${ORATAB}           | egrep -i -v "^#|${ORA_HOMES_IGNORE_5}" | egrep -i ":N|:Y" | cut -f1 -d ':'               | uniq               | sort)
  ASM=$(cat ${ORATAB}              | egrep -i -v "^#|${ORA_HOMES_IGNORE_5}" | egrep -i "+ASM*" | cut -f1 -d ':'               | uniq               | sort           | wc -l)
  T_MEM=$(free -g -h               | egrep -i "Mem"                         | awk '{ print $2 }')
  U_MEM=$(free -g -h               | egrep -i "Mem"                         | awk '{ print $3 }')
  F_MEM=$(free -g -h               | egrep -i "Mem"                         | awk '{ print $4 }')
  T_SWAP=$(free -g -h              | egrep -i "Swap"                        | awk '{ print $2 }')
  U_SWAP=$(free -g -h              | egrep -i "Swap"                        | awk '{ print $3 }')
  F_SWAP=$(free -g -h              | egrep -i "Swap"                        | awk '{ print $4 }')
  RED="\033[1;31m"
  RED2="\033[0;41m"
  YEL="\033[1;33m"
  BLU="\e[96m"
  BLU2="\033[0;44m"
  GRE="\033[1;32m"
  BLA="\033[m"
elif [[ $(uname) == "AIX" ]]; then
  OS="AIX"
  ORATAB="/etc/oratab"
  ORA_INST="/opt/oracle/etc/oraInst.loc"
  ORA_INVENTORY="$(cat ${ORA_INST} | egrep -i "inventory_loc" | cut -f2 -d '=')/ContentsXML/inventory.xml"
  ORA_SERVICES="$(ps -ef | egrep -i "pmon" | egrep -i -v "egrep|grep" | wc -l)"
  TMP="/tmp"
  TMPDIR="${TMP}"
  HOST=$(hostname -s)
  UPTIME=$(uptime | sed 's/.*up \([^,]*\), .*/\1/')
  ORA_HOMES=$(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_1}" | egrep -i "LOC"                                  | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  ORA_AGENT=$(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_2}" | egrep -i "LOC"   | egrep -i "agent"             | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  OGG_HOME=$(cat ${ORA_INVENTORY}  | egrep -i -v "^#|${ORA_HOMES_IGNORE_3}" | egrep -i "LOC"   | egrep -i "goldengate|ogg|gg" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  ORA_OMS=$(cat ${ORA_INVENTORY}   | egrep -i -v "^#|${ORA_HOMES_IGNORE_4}" | egrep -i "LOC"   | egrep -i "middleware"        | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  DBLIST=$(cat ${ORATAB}           | egrep -i -v "^#|${ORA_HOMES_IGNORE_5}" | egrep -i ":N|:Y" | cut -f1 -d ':'               | uniq               | sort)
  ASM=$(cat ${ORATAB}              | egrep -i -v "^#|${ORA_HOMES_IGNORE_5}" | egrep -i "+ASM*" | cut -f1 -d ':'               | uniq               | sort           | wc -l)
  T_MEM=$(svmon -G -O unit=GB      | egrep -i "memory"                      | awk '{ print $2 }')
  U_MEM=$(svmon -G -O unit=GB      | egrep -i "memory"                      | awk '{ print $3 }')
  F_MEM=$(svmon -G -O unit=GB      | egrep -i "memory"                      | awk '{ print $4 }')
  T_SWAP="NO"
  U_SWAP="NO"
  F_SWAP="NO"
  RED="\033[1;31m"
  RED2="\033[0;41m"
  YEL="\033[1;33m"
  BLU="\e[96m"
  BLU2="\033[0;44m"
  GRE="\033[1;32m"
  BLA="\033[m"
elif [[ $(uname) == "Linux" ]]; then
  OS="Linux"
  ORATAB="/etc/oratab"
  ORA_INST="/etc/oraInst.loc"
  ORA_INVENTORY="$(cat ${ORA_INST} | egrep -i "inventory_loc" | cut -f2 -d '=')/ContentsXML/inventory.xml"
  ORA_SERVICES="$(ps -ef | egrep -i "pmon" | egrep -i -v "egrep|grep" | wc -l)"
  TMP="/tmp"
  TMPDIR="${TMP}"
  HOST=$(hostname)
  UPTIME=$(uptime | sed 's/.*up \([^,]*\), .*/\1/')
  ORA_HOMES=$(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_1}" | egrep -i "LOC"                                  | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  ORA_AGENT=$(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_2}" | egrep -i "LOC"   | egrep -i "agent"             | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  OGG_HOME=$(cat ${ORA_INVENTORY}  | egrep -i -v "^#|${ORA_HOMES_IGNORE_3}" | egrep -i "LOC"   | egrep -i "goldengate|ogg|gg" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  ORA_OMS=$(cat ${ORA_INVENTORY}   | egrep -i -v "^#|${ORA_HOMES_IGNORE_4}" | egrep -i "LOC"   | egrep -i "middleware"        | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  DBLIST=$(cat ${ORATAB}           | egrep -i -v "^#|${ORA_HOMES_IGNORE_5}" | egrep -i ":N|:Y" | cut -f1 -d ':'               | uniq               | sort)
  ASM=$(cat ${ORATAB}              | egrep -i -v "^#|${ORA_HOMES_IGNORE_5}" | egrep -i "+ASM*" | cut -f1 -d ':'               | uniq               | sort           | wc -l)
  T_MEM=$(free -g -h               | egrep -i "Mem"                         | awk '{ print $2 }')
  U_MEM=$(free -g -h               | egrep -i "Mem"                         | awk '{ print $3 }')
  F_MEM=$(free -g -h               | egrep -i "Mem"                         | awk '{ print $4 }')
  T_SWAP=$(free -g -h              | egrep -i "Swap"                        | awk '{ print $2 }')
  U_SWAP=$(free -g -h              | egrep -i "Swap"                        | awk '{ print $3 }')
  F_SWAP=$(free -g -h              | egrep -i "Swap"                        | awk '{ print $4 }')
  RED="\e[1;31;40m"
  RED2="\033[0;41m"
  YEL="\e[1;33;40m"
  BLU="\e[96m"
  BLU2="\033[0;44m"
  GRE="\e[1;32;40m"
  BLA="\e[0m"
fi
#
# ------------------------------------------------------------------------
# Verify oraInst.loc file
#
if [[ ! -f ${ORA_INST} ]]; then
  SetClear
  SepLine
  echo " -- THIS SERVER DOES NOT HAVE AN ORACLE INSTALLATION YET --"
  SepLine
 return 1
fi
#
# ------------------------------------------------------------------------
# Verify ORATAB
#
if [[ ! -f ${ORATAB} ]]; then
  SetClear
  SepLine
  echo " -- YOU DO NOT HAVE THE ORATAB CONFIGURED --"
  echo " -- PLEASE CHECK YOUR CONFIGURATION --"
  SepLine
  return 1
fi
#
# ------------------------------------------------------------------------
# Verify ORACLE Inventory
#
if [[ ! -f ${ORA_INVENTORY} ]]; then
  SetClear
  SepLine
  echo " -- YOU DO NOT HAVE THE ORACLE INVENTORY IN YOUR ENVIRONMENT --"
  echo " -- PLEASE CHECK YOUR CONFIGURATION --"
  SepLine
  return 1
fi
#
# ------------------------------------------------------------------------
# Verify ORACLE Services
#
if [[ "${ORA_SERVICES} | xargs" == 0 ]]; then
  SetClear
  SepLine
  echo " -- YOU DO NOT HAVE THE ORACLE INVENTORY IN YOUR ENVIRONMENT --"
  echo " -- PLEASE CHECK YOUR CONFIGURATION --"
  SepLine
  return 1
fi
#
# ------------------------------------------------------------------------
# Function to display Oracle service status
#
OracleServices() {
#
echo " -- ORACLE PRODUCTS RUNNING SERVICES --"
#
printf "+%-16s+%-16s+%-16s+%-50s+\n" "----------------------" "----------------------" "----------------------" "------------------------------------------------------------"
printf "|%-16s|%-16s|%-16s|%-50s|\n" " SERVICE              " " STATUS               " " INFO                 " " ORACLE HOME                                                "
printf "+%-16s+%-16s+%-16s+%-50s+\n" "----------------------" "----------------------" "----------------------" "------------------------------------------------------------"
#
# ASM
#
if [[ "$(ps -ef | egrep -i "asm_pmon" | egrep -i -v "grep|egrep|sed" | awk '{ print $NF }' | sed s/asm_pmon_//g | uniq | sort | wc -l | xargs)" == 0 ]]; then 
  break
else
  ASM="$(cat ${ORATAB} | egrep -i "+asm" | egrep -i -v "+apx|-mgmtdb|grep|egrep" | egrep -i ":N|:Y" | cut -f1 -d ':')"
  ASM_HOME="$(cat ${ORATAB} | egrep -i "+asm" | egrep -i -v "+apx|-mgmtdb|grep|egrep" | egrep -i ":N|:Y" | cut -f2 -d ':')"
  printf "|%-22s|%-22s|%-22s|%-60s|\n" " ${ASM} " " RUNNING " " NO INFO " " ${ASM_HOME}"
fi
#
# LISTENER
#
if [[ "$(ps -ef | egrep -i "listener" | egrep -i -v "grep|egrep|zabbix" | wc -l | xargs | uniq)" == 0 ]]; then
  break
else
  for LISTENER in $(ps -ef | egrep -i "listener" | egrep -i -v "grep|egrep|zabbix" | awk '{ print $9 }' | uniq | sort); do
    LISTENER_PORT="$(ps -ef | egrep -i "listener" | egrep -i -v "grep|egrep|zabbix|sed" | awk '{ print $8 }' | uniq | sort | awk -F/ '{NF=NF-2}1' OFS=/)"
    printf "|%-22s|%-22s|%-22s|%-60s|\n" " ${LISTENER} " " RUNNING " " NO INFO " " $(ps -ef | egrep -i -w "${LISTENER}" | egrep -i -v "grep|egrep|zabbix" | awk '{ print $8 }' | uniq)"
  done
fi
#
# AGENT
#
if [[ "$(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_2}" | egrep -i "LOC" | egrep -i "agent" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort | wc -l | xargs)" == 0 ]]; then
  break
else
  for AGENT in $(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_2}" | egrep -i "LOC" | egrep -i "agent" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort); do
    printf "|%-22s|%-22s|%-22s|%-60s|\n" " AGENT " " RUNNING " " NO INFO " " ${AGENT}"
  done
fi
#
# MIDDLEWARE
#
if [[ "$(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_4}" | egrep -i "LOC" | egrep -i "middleware" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort | wc -l | xargs)" == 0 ]]; then
  break
else
  for OMS in $(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_4}" | egrep -i "LOC" | egrep -i "middleware" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort); do
    printf "|%-22s|%-22s|%-22s|%-60s|\n" " OMS " " RUNNING " " NO INFO " " ${OMS}"
  done
fi
#
# GOLDENGATE
#
if [[ "$(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_3}" | egrep -i "LOC" | egrep -i "goldengate|ogg|gg" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort | wc -l | xargs)" == 0 ]]; then
  break
else
  for OGG in $(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_3}" | egrep -i "LOC" | egrep -i "goldengate|ogg|gg" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort); do
    printf "|%-22s|%-22s|%-22s|%-60s|\n" " OGG " " RUNNING " " NO INFO " " ${OGG}"
  done
fi
#
# DATABASE
#
for DATABASE in $(ps -ef | egrep -i "ora_pmon" | egrep -i -v "grep|egrep|sed" | awk '{ print $NF }' | sed s/ora_pmon_//g | uniq | sort); do
  if [[ "$(ps -ef | egrep -i "ora_pmon" | egrep -i -v "grep|egrep|sed" | awk '{ print $NF }' | sed s/ora_pmon_//g | uniq | sort | wc -l | xargs)" == 0 ]]; then
    printf "|%-22s|%-22s|%-22s|%-60s|\n" " ${DATABASE} " " ${DATABASE_STATUS} " " ${DATABASE_ROLE} " " ${ORACLE_HOME}"
  else
ORAENV_ASK=NO
ORACLE_SID=${DATABASE}
. /usr/local/bin/oraenv <<< ${ORACLE_SID} > /dev/null
#
# DB STATUS
#
DATABASE_STATUS=$( 
{
  echo "set pages 0 lin 1000 feedback off;"
  echo "select status || ' | ' || (select case when value = 'TRUE' then '(RAC)' else '(SING)' end from v\$parameter where name = 'cluster_database') as status from v\$instance;"
} | sqlplus -S / as sysdba)
#
# DB ROLE
#
DATABASE_ROLE=$( 
{
  echo "set pages 0 lin 1000 feedback off;"
  echo "select database_role from v\$database;"
} | sqlplus -S / as sysdba)
#
# DB RESULT
#
  printf "|%-22s|%-22s|%-22s|%-60s|\n" " ${ORACLE_SID} " " ${DATABASE_STATUS} " " ${DATABASE_ROLE} " " ${ORACLE_HOME}"
  fi
done
#
printf "+%-16s+%-16s+%-16s+%-50s+\n" "----------------------" "----------------------" "----------------------" "------------------------------------------------------------"
#
echo " -- ORACLE PRODUCTS OWNER --"
printf "+%-16s+%-50s+%-16s+\n" "----------------------" "------------------------------------------------------------" "----------------------"
printf "|%-16s|%-50s|%-16s|\n" " HOME NAME            " " HOME                                                       " " OWNER                "
printf "+%-16s+%-50s+%-16s+\n" "----------------------" "------------------------------------------------------------" "----------------------"
#
# ASM HOME AND OWNER
#
if [[ "$(cat ${ORATAB} | egrep -i "+asm" | egrep -i -v "+apx|-mgmtdb|grep|egrep" | egrep -i ":N|:Y" | cut -f2 -d ':' | uniq | sort | wc -l | xargs)" == 0 ]]; then 
  break
else
  ASM="$(cat ${ORATAB} | egrep -i "+asm" | egrep -i -v "+apx|-mgmtdb|grep|egrep" | egrep -i ":N|:Y" | cut -f1 -d ':')"
  ASM_HOME="$(cat ${ORATAB} | egrep -i "+asm" | egrep -i -v "+apx|-mgmtdb|grep|egrep" | egrep -i ":N|:Y" | cut -f2 -d ':')"
  ASM_OWNER="$(ls -l ${ASM_HOME} | awk '{ print $3 }' | egrep -i -v "root" | egrep -Ev "^$" | uniq)"
  ASM_HOME_NAME="$(cat ${ORA_INVENTORY} | egrep -i "LOC" | egrep -i "${ASM_HOME}" | awk '{ print $2 }' |  cut -f2 -d '=' | cut -f2 -d '"')"
  printf "|%-22s|%-60s|%-22s|\n" " ${ASM_HOME_NAME} " " ${ASM_HOME} " " ${ASM_OWNER} "
  printf "+%-16s+%-50s+%-16s+\n" "----------------------" "------------------------------------------------------------" "----------------------"
fi
#
# AGENT HOME AND OWNER
#
if [[ "$(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_2}" | egrep -i "LOC" | egrep -i "agent" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort | wc -l | xargs)" == 0 ]]; then 
  break
else
for AGENT_HOME in $(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_2}" | egrep -i "LOC" | egrep -i "agent" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort); do
  AGENT_OWNER="$(ls -l ${AGENT_HOME} | awk '{ print $3 }' | egrep -i -v "root" | egrep -Ev "^$" | uniq)"
  AGENT_HOME_NAME="$(cat ${ORA_INVENTORY} | egrep -i "LOC" | egrep -i "${AGENT_HOME}" | awk '{ print $2 }' |  cut -f2 -d '=' | cut -f2 -d '"')"
  printf "|%-22s|%-60s|%-22s|\n" " ${AGENT_HOME_NAME} " " ${AGENT_HOME} " " ${AGENT_OWNER} "
  printf "+%-16s+%-50s+%-16s+\n" "----------------------" "------------------------------------------------------------" "----------------------"
done
fi
#
# OMS HOME AND OWNER
#
if [[ "$(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_4}" | egrep -i "LOC" | egrep -i "middleware" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort | wc -l | xargs)" == 0 ]]; then 
  break
else
for OMS_HOME in $(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_4}" | egrep -i "LOC" | egrep -i "middleware" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort); do
  OMS_OWNER="$(ls -l ${OMS_HOME} | awk '{ print $3 }' | egrep -i -v "root" | egrep -Ev "^$" | uniq)"
  OMS_HOME_NAME="$(cat ${ORA_INVENTORY} | egrep -i "LOC" | egrep -i "${OMS_HOME}" | awk '{ print $2 }' |  cut -f2 -d '=' | cut -f2 -d '"')"
  printf "|%-22s|%-60s|%-22s|\n" " ${OMS_HOME_NAME} " " ${OMS_HOME} " " ${OMS_OWNER} "
  printf "+%-16s+%-50s+%-16s+\n" "----------------------" "------------------------------------------------------------" "----------------------"
done
fi
#
# OGG HOME AND OWNER
#
if [[ "$(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_3}" | egrep -i "LOC" | egrep -i "goldengate|ogg|gg" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort | wc -l | xargs)" == 0 ]]; then 
  break
else
for OGG_HOME in $(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_3}" | egrep -i "LOC" | egrep -i "goldengate|ogg|gg" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort); do
  OGG_OWNER="$(ls -l ${OGG_HOME} | awk '{ print $3 }' | egrep -i -v "root" | egrep -Ev "^$" | uniq)"
  OGG_HOME_NAME="$(cat ${ORA_INVENTORY} | egrep -i "LOC" | egrep -i "${OGG_HOME}" | awk '{ print $2 }' |  cut -f2 -d '=' | cut -f2 -d '"')"
  printf "|%-22s|%-60s|%-22s|\n" " ${OGG_HOME_NAME} " " ${OGG_HOME} " " ${OGG_OWNER} "
  printf "+%-16s+%-50s+%-16s+\n" "----------------------" "------------------------------------------------------------" "----------------------"
done
fi
#
# DB HOME AND OWNER
#
if [[ "$(cat ${ORATAB} | egrep -i -v "+asm|+apx|-mgmtdb|grep|egrep" | egrep -i ":N|:Y" | cut -f2 -d ':' | uniq | sort | wc -l | xargs)" == 0 ]]; then 
  break
else
for DB_HOME in $(cat ${ORATAB} | egrep -i -v "+asm|+apx|-mgmtdb|grep|egrep" | egrep -i ":N|:Y" | cut -f2 -d ':' | uniq | sort); do
  DB_OWNER="$(ls -l ${DB_HOME} | awk '{ print $3 }' | egrep -i -v "root" | egrep -Ev "^$" | uniq)"
  DB_HOME_NAME="$(cat ${ORA_INVENTORY} | egrep -i "LOC" | egrep -i "${DB_HOME}" | awk '{ print $2 }' |  cut -f2 -d '=' | cut -f2 -d '"')"
  printf "|%-22s|%-60s|%-22s|\n" " ${DB_HOME_NAME} " " ${DB_HOME} " " ${DB_OWNER} "
  printf "+%-16s+%-50s+%-16s+\n" "----------------------" "------------------------------------------------------------" "----------------------"
done
fi
#
}
#
OracleServices
#
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
# THE SCRIPT FINISHES HERE
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
#