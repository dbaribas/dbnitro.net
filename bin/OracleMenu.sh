#!/bin/sh
Author="Andre Augusto Ribas"
SoftwareVersion="1.0.89"
DateCreation="07/01/2021"
DateModification="14/12/2023"
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
# Clear Screen Function
#
SetClear() {
  printf "\033c"
}
#
# ------------------------------------------------------------------------
# DBNITRO Script Folder
#
    FOLDER="/opt"
   DBNITRO="${FOLDER}/dbnitro"
      LOGS="${DBNITRO}/logs"
    BACKUP="${DBNITRO}/backup"
   REPORTS="${DBNITRO}/reports"
  BINARIES="${DBNITRO}/bin"
 VARIABLES="${DBNITRO}/var"
 FUNCTIONS="${DBNITRO}/functions"
STATEMENTS="${DBNITRO}/sql"
#
if [[ ! -d ${FOLDER}/ ]]; then
  SetClear
  SepLine
  echo " -- YOUR SCRIPT FOLDER DOES NOT EXISTS, YOU HAVE TO CREATE THAT BEFORE YOU CONTINUE --"
  return 1
fi
#
# ------------------------------------------------------------------------
# Verify ROOT User
#
if [[ $(whoami) == "root" ]]; then
  SetClear
  SepLine
  echo " -- YOUR USER IS ROOT, YOU CAN NOT USE THIS SCRIPT WITH ROOT USER --"
  echo " -- PLEASE USE OTHER USER TO ACCESS THIS SCRIPTS --"
  return 1
fi
#
# ------------------------------------------------------------------------
# Verify if all pre-reqs Softwares are installed
#
if [[ $(which rlwrap | wc -l | awk '{ print $1 }') == 0 ]]; then
  SetClear
  SepLine
  echo " -- You need to install rlwrap app --"
  return 1 
fi
#
# ------------------------------------------------------------------------
# Help Function
#
HELP() {
SetClear
SepLine
echo -e "\
|#| HOMES........: YOU CAN SELECT THE ORACLE HOME WITHOUT ANY INSTANCE (ASM/SID)
|#| OMS..........: YOU CAN SELECT THE ORACLE ENTERPRISE MANAGER (OMS) HOME AND TOOLS
|#| AGENT........: YOU CAN SELECT THE ORACLE ENTERPRISE MANAGER (AGENT) HOME AND TOOLS
|#| GRID.........: YOU CAN SELECT THE GRID OPTION AND WORK WITH GRID INSTANCE (ASM) AND TOOLS
|#| DATABASE.....: YOU CAN SELECT THE DATABASE INSTANCE (SID) AND TOOLS
|#| CDB/PDB......: YOU CAN SELECT THE ORACLE CONTAINER/PLUGGABLE DATABASE (ONLY AFTER SELECT THE ORACLE SID) ---> pdb
|#| GOLDENGATE...: YOU CAN SELECT THE ORACLE GOLDENGATE HOME AND TOOLS (ONLY AFTER SELECT THE ORACLE SID) ---> ogg
|#| LIST.........: YOU CAN SEE THE ORACLE PRODUCTS RUNNING AND/OR INSTALLED
|#| INFO.........: YOU CAN SEE THE ORACLE DATABASE INFO
|#| DASH.........: YOU CAN SEE THE ORACLE DATABASE DASHBOARD
|#| DASH_INSTALL.: YOU CAN INSTALL THE ORACLE DATABASE DASHBOARD
|#| REPORT.......: YOU CAN SEE THE ORACLE DATABASE REPORT (SAVED ON ${REPORTS})
|#| OPTIONS......: YOU CAN SEE THE ORACLE DATABASE OPTIONS
|#| HUGEPAGES....: YOU CAN SEE THE ORACLE DATABASE HUGEPAGES RECOMMENDATIONS"
SepLine
}
#
# ------------------------------------------------------------------------
# IGNORE ERRORS
#
IGNORE_ERRORS="OGG-00987"
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
  VARIABLES_IGNORE="HISTCONTROL|HISTSIZE|HOME|HOSTNAME|DISPLAY|LANG|LESSOPEN|LOGNAME|LS_COLORS|MAIL|OLDPWD|PWD|SHELL|SHLVL|TERM|USER|XDG_SESSION_ID"
  ALIASES_IGNORE="db|egrep|fgrep|grep|l.|ll|ls|vi|which"
  VARIABLES=$(export | awk '{ print $3 }' | cut -f1 -d '=' | egrep -i -v ${VARIABLES_IGNORE})
  ALIASES=$(alias    | awk '{ print $2 }' | cut -f1 -d '=' | egrep -i -v ${ALIASES_IGNORE})
  TMP="/tmp"
  TMPDIR="${TMP}"
  HOST=$(hostname)
  UPTIME=$(uptime | sed 's/.*up \([^,]*\), .*/\1/')
  PS=$(PS1=$'[ ${LOGNAME}@\h:$(pwd): ]$ ')
  ORA_HOMES=$(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_1}" | egrep -i "LOC"                                  | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  ORA_AGENT=$(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_2}" | egrep -i "LOC"     | egrep -i "agent"             | awk '{ print $2 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  OGG_HOME=$(cat ${ORA_INVENTORY}  | egrep -i -v "^#|${ORA_HOMES_IGNORE_3}" | egrep -i "LOC"     | egrep -i "goldengate|ogg|gg" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  ORA_OMS=$(cat ${ORA_INVENTORY}   | egrep -i -v "^#|${ORA_HOMES_IGNORE_4}" | egrep -i "LOC"     | egrep -i "middleware"        | awk '{ print $2 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  DBLIST=$(cat ${ORATAB}           | egrep -i -v "^#|${ORA_HOMES_IGNORE_5}" | egrep -i ":N|:Y"   | cut -f1 -d ':'               | uniq               | sort)
  ASM=$(cat ${ORATAB}              | egrep -i -v "^#|${ORA_HOMES_IGNORE_5}" | egrep -i "+ASM*"   | cut -f1 -d ':'               | uniq               | sort           | wc -l)
  LSNRCTL="$(ps -ef                | egrep -v "grep|egrep|zabbix|webmin"    | egrep -i "tnslsnr" | wc -l)"
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
  VARIABLES_IGNORE="AUTHSTATE|DSM_LOG|EDITOR|ENV|EXTENDED_HISTORY|FCEDIT|HISTDATEFMT|HISTFILE|HISTSIZE|HOME|HOST|LANG|LC__FASTMSG|LOCPATH|LOGIN|LOGONNAME|MAIL|MAILMSG|MANPATH|MISSINGPV_VARYON|NLSPATH|NMON|ODMDIR|RES_RETRY|RES_TIMEOUT|SHELL|SSH_CLIENT|SSH_CONNECTION|SSH_TTY|TERM|TZ|USER|XAUTHORITY"
  ALIASES_IGNORE="db|egrep|fgrep|grep|l.|ll|ls|vi|which|autoload|command|history|integer|local"
  VARIABLES=$(export | awk '{ print $1 }' | cut -f1 -d '=' | egrep -i -v ${VARIABLES_IGNORE})
  ALIASES=$(alias    | awk '{ print $1 }' | cut -f1 -d '=' | egrep -i -v ${ALIASES_IGNORE})
  TMP="/tmp"
  TMPDIR="${TMP}"
  HOST=$(hostname -s)
  UPTIME=$(uptime | sed 's/.*up \([^,]*\), .*/\1/')
  PS=$(PS1=$'[ ${USER}@{HOST}:${PED}: ]$ ')
  ORA_HOMES=$(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_1}" | egrep -i "LOC"                                  | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  ORA_AGENT=$(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_2}" | egrep -i "LOC"     | egrep -i "agent"             | awk '{ print $2 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  OGG_HOME=$(cat ${ORA_INVENTORY}  | egrep -i -v "^#|${ORA_HOMES_IGNORE_3}" | egrep -i "LOC"     | egrep -i "goldengate|ogg|gg" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  ORA_OMS=$(cat ${ORA_INVENTORY}   | egrep -i -v "^#|${ORA_HOMES_IGNORE_4}" | egrep -i "LOC"     | egrep -i "middleware"        | awk '{ print $2 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  DBLIST=$(cat ${ORATAB}           | egrep -i -v "^#|${ORA_HOMES_IGNORE_5}" | egrep -i ":N|:Y"   | cut -f1 -d ':'               | uniq               | sort)
  ASM=$(cat ${ORATAB}              | egrep -i -v "^#|${ORA_HOMES_IGNORE_5}" | egrep -i "+ASM*".  | cut -f1 -d ':'               | uniq               | sort           | wc -l)
  LSNRCTL="$(ps -ef                | egrep -i -v "grep|egrep|zabbix|webmin" | egrep -i "tnslsnr" | wc -l)"
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
  VARIABLES_IGNORE="HISTCONTROL|HISTSIZE|HOME|HOSTNAME|DISPLAY|LANG|LESSOPEN|LOGNAME|LS_COLORS|MAIL|OLDPWD|PWD|SHELL|SHLVL|TERM|USER|XDG_SESSION_ID"
  ALIASES_IGNORE="db|egrep|fgrep|grep|l.|ll|ls|vi|which"
  VARIABLES=$(export | awk '{ print $3 }' | cut -f1 -d '=' | egrep -i -v ${VARIABLES_IGNORE})
  ALIASES=$(alias    | awk '{ print $2 }' | cut -f1 -d '=' | egrep -i -v ${ALIASES_IGNORE})
  TMP="/tmp"
  TMPDIR="${TMP}"
  HOST=$(hostname)
  UPTIME=$(uptime | sed 's/.*up \([^,]*\), .*/\1/')
  PS=$(PS1=$'[ ${LOGNAME}@\h:$(pwd): ]$ ')
  ORA_HOMES=$(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_1}" | egrep -i "LOC"                                  | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  ORA_AGENT=$(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_2}" | egrep -i "LOC"     | egrep -i "agent"             | awk '{ print $2 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  OGG_HOME=$(cat ${ORA_INVENTORY}  | egrep -i -v "^#|${ORA_HOMES_IGNORE_3}" | egrep -i "LOC"     | egrep -i "goldengate|ogg|gg" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  ORA_OMS=$(cat ${ORA_INVENTORY}   | egrep -i -v "^#|${ORA_HOMES_IGNORE_4}" | egrep -i "LOC"     | egrep -i "middleware"        | awk '{ print $2 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  DBLIST=$(cat ${ORATAB}           | egrep -i -v "^#|${ORA_HOMES_IGNORE_5}" | egrep -i ":N|:Y"   | cut -f1 -d ':'               | uniq               | sort)
  ASM=$(cat ${ORATAB}              | egrep -i -v "^#|${ORA_HOMES_IGNORE_5}" | egrep -i "+ASM*"   | cut -f1 -d ':'               | uniq               | sort           | wc -l)
  LSNRCTL="$(ps -ef                | egrep -i -v "grep|egrepzabbix|webmin"  | egrep -i "tnslsnr" | wc -l)"
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
# Set ORACLE Inventory
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
# Source Functions
#
for FUNC in $(ls ${FUNCTIONS}/*_Functions); do
  source ${FUNC}
done
#
# ------------------------------------------------------------------------
# Listener Services
#
ListenerService() {
if [[ "${LSNRCTL}" != 0 ]]; then 
  for LISTENER_SERVICE in $(ps -ef | egrep -i -v "grep|egrep|zabbix|webmin" | egrep -i "listener" | awk '{ print $9 }' | uniq | sort); do
    LISTENER_HOME="$(ps -ef | egrep -i -v "grep|egrep|zabbix|webmin" | egrep -i -w "${LISTENER_SERVICE}" | awk '{ print $8 }' | uniq | sort)"
    printf "|%-22s|%-70s|\n" "                     LISTENER " " [ ONLINE ] [ ${LISTENER_SERVICE} ] ${LISTENER_HOME} "
  done
else 
  printf "|%-22s|%-70s|\n" "                     LISTENER " " [ OFFLINE ] [ ${LISTENER_SERVICE} ] "
fi
}
#
# ------------------------------------------------------------------------
# Verify ASM
#
if [[ ${ASM} == 0 ]]; then
  ASM_EXISTS="NO"
else
  ASM_EXISTS="YES"
  G_SID=$(cat ${ORATAB}       | egrep -i -v "^#"   | egrep -i "+ASM*"   | cut -f1 -d ':')
  G_HOME=$(cat ${ORATAB}      | egrep -i -v "^#"   | egrep -i "+ASM*"   | cut -f2 -d ':')
  ASM_OWNER=$(ls -l ${G_HOME} | awk '{ print $3 }' | egrep -i -v "root" | egrep -Ev "^$" | uniq)
  if [[ "${ASM_OWNER}" == "$(whoami)" ]]; then
    ASM_USER="YES"
  else
    ASM_USER="NO"
  fi
fi
#
# ------------------------------------------------------------------------
# Unsetting and Setting OS and ORATAB Variables
#
unset_var() {
if [[ "$(uname)" == "SunOS" ]]; then
  if [[ "$(whoami)" == "grid" ]]; then
  for U_VAR in ${VARIABLES}; do
    unset ${U_VAR} > /dev/null 2>&1
  done
  export PATH=/usr/local/bin:/bin:/sbin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/grid/.local/bin:/home/grid/bin
  export PS1=$'[ ${LOGNAME}@\h:$(pwd): ]$ '
  umask 0022
  #
  elif [[ "$(whoami)" == "oracle" ]]; then
  for U_VAR in ${VARIABLES}; do
    unset ${U_VAR} > /dev/null 2>&1
  done
  export PATH=/usr/local/bin:/bin:/sbin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/oracle/.local/bin:/home/oracle/bin
  export PS1=$'[ ${LOGNAME}@\h:$(pwd): ]$ ' 
  umask 0022
  fi
elif [[ "$(uname)" == "AIX" ]]; then
  if [[ "$(whoami)" == "grid" ]]; then
  for U_VAR in ${VARIABLES}; do
    unset ${U_VAR} > /dev/null 2>&1
  done
  export PATH=/usr/bin:/usr/sbin:/bin:/sbin:/etc:/usr/bin/X11:/usr/local/bin:/usr/local/sbin:/home/grid/.local/bin:/home/grid/bin
  export PS1=$'[ ${LOGNAME}@\h:$(pwd): ]$ '
  umask 0022
  #
  elif [[ "$(whoami)" == "oracle" ]]; then
  for U_VAR in ${VARIABLES}; do
    unset ${U_VAR} > /dev/null 2>&1
  done
  export PATH=/usr/bin:/usr/sbin:/bin:/sbin:/etc:/usr/bin/X11:/usr/local/bin:/usr/local/sbin:/home/oracle/.local/bin:/home/oracle/bin
  export PS1=$'[ ${LOGNAME}@\h:$(pwd): ]$ ' 
  umask 0022
  fi
elif [[ "$(uname)" == "Linux" ]]; then
  if [[ "$(whoami)" == "grid" ]]; then
  for U_VAR in ${VARIABLES}; do
    unset ${U_VAR} > /dev/null 2>&1
  done
  export PATH=/usr/local/bin:/bin:/sbin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/grid/.local/bin:/home/grid/bin
  export PS1=$'[ ${LOGNAME}@\h:$(pwd): ]$ '
  umask 0022
  #
  elif [[ "$(whoami)" == "oracle" ]]; then
  for U_VAR in ${VARIABLES}; do
    unset ${U_VAR} > /dev/null 2>&1
  done
  export PATH=/usr/local/bin:/bin:/sbin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/oracle/.local/bin:/home/oracle/bin
  export PS1=$'[ ${LOGNAME}@\h:$(pwd): ]$ ' 
  umask 0022
  fi
fi
}
#
# ------------------------------------------------------------------------
# UnAlias and Setting OS
#
unalias_var() {
for UN_ALIAS in ${ALIASES}; do
  unalias ${UN_ALIAS} > /dev/null 2>&1
done
}
#
# ------------------------------------------------------------------------
# Alias and Setting OS
#
alias_var() {
alias lt='ls -lahrt'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias meminfo='free -g -h -l -t'
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
alias pscpu='ps auxf | sort -nr -k 3'
alias pscpu10='ps auxf | sort -nr -k 3 | head -10'
alias cpuinfo='lscpu'
alias list='${DBNITRO}/bin/OracleList.sh'
}
#
# ------------------------------------------------------------------------
# Show Database Info
#
get_INFO() {
if [[ ${ORACLE_SID} == "" ]]; then
  echo " -- YOUR ENVIRONMENT DOES NOT HAVE CONFIGURED YET --"
  return 0
elif [[ $(ps -ef | egrep -i "pmon" | egrep -i "${ORACLE_SID}" | awk '{ print $NF }' | sed s/ora_pmon_//g | wc -l) == 0 ]]; then
  echo " -- YOUR ENVIRONMENT: ${ORACLE_SID} IS OFFLINE --"
  return 0
else
  echo "@${DBNITRO}/sql/Oracle_SQL_DBA_Info.sql;" | sqlplus -S / as sysdba
fi
}
#
# ------------------------------------------------------------------------
# Install Database Dashboard
#
get_DASH_INSTALL() {
if [[ ${ORACLE_SID} == "" ]]; then
  echo " -- YOUR ENVIRONMENT DOES NOT HAVE CONFIGURED YET --"
  return 0
elif [[ $(ps -ef | egrep -i "pmon" | egrep -i "${ORACLE_SID}" | awk '{ print $NF }' | sed s/ora_pmon_//g | wc -l) == 0 ]]; then
  echo " -- YOUR ENVIRONMENT: ${ORACLE_SID} IS OFFLINE --"
  return 0
else
  echo "@/opt/dbnitro/sql/Oracle_Create_Dashboard.sql;" | sqlplus -S / as sysdba
fi
}
#
# ------------------------------------------------------------------------
# Show Database Dashboard
#
get_DASH() {
if [[ ${ORACLE_SID} == "" ]]; then
  echo " -- YOUR ENVIRONMENT DOES NOT HAVE CONFIGURED YET --"
  return 0
elif [[ $(ps -ef | egrep -i "pmon" | egrep -i "${ORACLE_SID}" | awk '{ print $NF }' | sed s/ora_pmon_//g | wc -l) == 0 ]]; then
  echo " -- YOUR ENVIRONMENT: ${ORACLE_SID} IS OFFLINE --"
  return 0
else
sqlplus -S '/ as sysdba' <<EOF
set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
alter session set current_schema=system;
SET LINESIZE 5000 pagesize 0 Arraysize 51 TAB OFF
prompt ##############################################################
prompt # ACCESSING THE DATABASE DASHBOARD
prompt ##############################################################
select * from table(jss.gtop(51));
/
quit;
EOF
fi
}
#
# ------------------------------------------------------------------------
# Show Database Options Usage Statistics
#
get_OPTIONS() {
if [[ ${ORACLE_SID} == "" ]]; then
  echo " -- YOUR ENVIRONMENT DOES NOT HAVE CONFIGURED YET --"
  return 0
elif [[ $(ps -ef | egrep -i "pmon" | egrep -i "${ORACLE_SID}" | awk '{ print $NF }' | sed s/ora_pmon_//g | wc -l) == 0 ]]; then
  echo " -- YOUR ENVIRONMENT: ${ORACLE_SID} IS OFFLINE --"
  return 0
else
  echo "@${DBNITRO}/sql/Oracle_SQL_DBA_Options_Packs_Usage_Statistics.sql;" | sqlplus -S / as sysdba
fi
}
#
# ------------------------------------------------------------------------
# Show Dataguard Status
#
get_ODG_STATUS() {
if [[ ${ORACLE_SID} == "" ]]; then
  echo " -- YOUR ENVIRONMENT DOES NOT HAVE CONFIGURED YET --"
  return 0
elif [[ $(ps -ef | egrep -i "pmon" | egrep -i "${ORACLE_SID}" | awk '{ print $NF }' | sed s/ora_pmon_//g | wc -l) == 0 ]]; then
  echo " -- YOUR ENVIRONMENT: ${ORACLE_SID} IS OFFLINE --"
  return 0
else
  echo "@${DBNITRO}/sql/Oracle_SQL_DBA_Dataguard_Status.sql;" | sqlplus -S / as sysdba
fi
}
#
# ------------------------------------------------------------------------
# Create Database Report
#
get_REPORT() {
if [[ ${ORACLE_SID} == "" ]]; then
  echo " -- YOUR ENVIRONMENT DOES NOT HAVE CONFIGURED YET --"
  return 0
elif [[ $(ps -ef | egrep -i "pmon" | egrep -i "${ORACLE_SID}" | awk '{ print $NF }' | sed s/ora_pmon_//g | wc -l) == 0 ]]; then
  echo " -- YOUR ENVIRONMENT: ${ORACLE_SID} IS OFFLINE --"
  return 0
else
  echo "@${DBNITRO}/sql/Oracle_SQL_DBA_Report_v.3.0.1.sql;" | sqlplus -S / as sysdba
fi
}
#
# ------------------------------------------------------------------------
# Setting GLOGIN Functions
#
set_GLOGIN() {
if [[ ! -f ${DBNITRO}/sql/glogin.sql ]]; then
cat > ${DBNITRO}/sql/glogin.sql <<EOF
set pages 700 lines 700 timing on time on colsep '|' trim on trims on numformat 999999999999999 heading on feedback on
COLUMN NAME FORMAT A20
COLUMN VALUE FORMAT A40
COLUMN USERNAME FORMAT A30
COLUMN PROFILE FORMAT A20
COLUMN FILE_NAME FORMAT A80
-- select 'Welcome, you are connected to ' || name || ' database' as Message from v\$database;
SET SQLPROMPT '&_user@&_connect_identifier> '
DEFINE _EDITOR=vi
EOF
fi
}
#
# ------------------------------------------------------------------------
# Setting PDB GLOGIN Functions
#
set_GLOGIN_PDB() {
if [[ ! -f ${DBNITRO}/sql/glogin_pdb.sql ]]; then
cat > ${DBNITRO}/sql/glogin_pdb.sql <<EOF
COLUMN NAME FORMAT A20
COLUMN VALUE FORMAT A40
COLUMN USERNAME FORMAT A30
COLUMN PROFILE FORMAT A20
COLUMN FILE_NAME FORMAT A80
SET SQLPROMPT '&_user@&_connect_identifier> '
DEFINE _EDITOR=vi
define gname=idle
set heading off termout off
column global_name new_value gname
col global_name noprint
-- select upper(sys_context('userenv', 'con_name') || '@' || sys_context('userenv', 'db_name')) global_name from dual;
-- select upper(sys_context('userenv', 'db_name') || '@' || sys_context('userenv', 'db_name')) global_name from dual;
select upper(sys_context('userenv', 'session_user') || '@' || sys_context('userenv', 'con_name') || '@' || sys_context('userenv', 'cdb_name')) global_name from dual;
-- select 'Welcome, you are connected to ' || name || ' database' as Message from v\$database;
SET SQLPROMPT '&gname> '
EOF
fi
}
#
# ------------------------------------------------------------------------
# Check and Set the GoldenGate Environment
#
set_OGG() {
if [[ "${ORACLE_SID}" == "" ]]; then
  echo " -- YOUR ENVIRONMENT DOES NOT HAVE CONFIGURED YET --"
  return 0
elif [[ $(ps -ef | egrep -i "pmon" | egrep -i "${ORACLE_SID}" | awk '{ print $NF }' | sed s/ora_pmon_//g | wc -l) == 0 ]]; then
  echo " -- YOUR ENVIRONMENT: ${ORACLE_SID} IS OFFLINE --"
  return 0
else
  OGG_STATUS="$(echo "show parameter enable_goldengate_replication;" | sqlplus -S / as sysdba | tail -2)"
fi
#
# ------------------------------------------------------------------------
#
if [[ $(echo ${OGG_STATUS} | awk '{ print $3 }') == "FALSE" ]]; then
  echo " -- YOUR ENVIRONMENT DOES NOT HAVE GOLDENGATE TECHNOLOGY --"
  return 0
else
  echo "Select the Option: "
select OGGHOME in ${OGG_HOME} QUIT; do
if [[ "${OGGHOME}" == "QUIT" ]]; then
  echo " -- Exit Menu --"
  return 1
else
  export OGG_HOME="${OGGHOME}"
  export OGG="${OGGHOME}"
  export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${OGG_HOME}/lib
  export PATH=${PATH}:${OGG_HOME}
  export ALERTGG="${OGG_HOME}/ggserr.log"
  alias ggsci='rlwrap ${OGG_HOME}/ggsci'
  alias g='rlwrap ${OGG_HOME}/ggsci'
  alias ggh='cd ${OGG_HOME}'
  alias gglog='tail -f -n 100 ${ALERTGG} | egrep -i -v ${IGNORE_ERRORS}'
  alias gglogv='vi ${ALERTGG}'
  alias ggmon='${DBNITRO}/bin/OracleGoldenGateMonitor.sh'
  echo " -- Golden Gate Environment: ${OGGHOME}"
  return 1
fi
done
fi
}
#
# ------------------------------------------------------------------------
# Check and Set the Database Version, Container and Pluggable Databases
#
set_PDB() {
if [[ "${ORACLE_SID}" == "" ]]; then
  echo " -- YOUR ENVIRONMENT DOES NOT HAVE CONFIGURED YET --"
  return 0
elif [[ $(ps -ef | egrep -i "pmon" | egrep -i "${ORACLE_SID}" | awk '{ print $NF }' | sed s/ora_pmon_//g | wc -l) == 0 ]]; then
  echo " -- YOUR ENVIRONMENT: ${ORACLE_SID} IS OFFLINE --"
  return 0
else
#
   VERSION="$(echo "select substr(version,1,2) as version from v\$instance;" | sqlplus -S / as sysdba | tail -2)"
 CONTAINER="$(echo "select cdb from v\$database;" | sqlplus -S / as sysdba | tail -2)"
PLUGGABLES="$(echo "select count(NAME) from v\$containers where con_id not in (0,1,2);" | sqlplus -S / as sysdba | tail -2)"
fi
#
# ------------------------------------------------------------------------
# Verify the Version, CDB and PDB of the Database
#
if [[ "${VERSION}" < 12 ]]; then
  echo " -- YOUR ENVIRONMENT DOES NOT HAVE CONTAINER TECHNOLOGY --"
  return 0
elif [[ "${CONTAINER}" == "NO" ]]; then
  echo " -- YOUR ENVIRONMENT DOES NOT HAVE CONTAINER TECHNOLOGY CONFIGURED YET --"
  return 0
elif [[ "${PLUGGABLES}" == 0 ]]; then
  echo " -- YOUR ENVIRONMENT DOES NOT HAVE PLUGGABLE DATABASES YET --"
  return 0
else
sqlplus -S '/ as sysdba' > ${DBNITRO}/var/Pluggable_${ORACLE_SID}.var <<EOF | tail -2
set define off trims on newp none heads off echo off feed off numwidth 20 pagesize 0 null null verify off wrap off timing off serveroutput off termout off heading off
select name as PDBS from v\$containers where con_id not in (0,1,2) order by 1;
quit;
EOF
fi
#
# ------------------------------------------------------------------------
# Select the CDB and PDB
#
echo "Options: "
select PDBS in "CDB\$ROOT" $(cat ${DBNITRO}/var/Pluggable_${ORACLE_SID}.var) QUIT; do # CHECK $ROOT if will work
if [[ "${PDBS}" == "BACK TO CDB" ]]; then
  export ORACLE_PDB_SID=""
  echo "PLUGGABLE DATABASE: CDB\$ROOT"
  export PS1=$'[ ${ORACLE_SID} ]|[ ${LOGNAME}@\h:$(pwd): ]$ '
  return 1
elif [[ "${PDBS}" == "QUIT" ]]; then
  echo " -- Exit Menu --"
  export PS1=$'[ ${ORACLE_SID} ]|[ ${LOGNAME}@\h:$(pwd): ]$ '
  return 1
else
  export ORACLE_PDB_SID="${PDBS}"
  echo "PLUGGABLE DATABASE: ${ORACLE_PDB_SID}"
  export PS1=$'[ ${ORACLE_SID} ]|[ PDB:${ORACLE_PDB_SID} ]|[ ${LOGNAME}@\h:$(pwd): ]$ '
  return 1
fi
done
}
#
# ------------------------------------------------------------------------
# Set Oracle Home
#
set_HOME() {
unset_var
unalias_var
alias_var
local OPT=$1
export ORACLE_HOSTNAME="${HOST}"
export ORACLE_HOME="${OPT}"
export ORACLE_BASE="$(${ORACLE_HOME}/bin/orabase)"
export TFA_HOME="${ORACLE_HOME}/suptools/tfa/release/tfa_home"
export OCK_HOME="${ORACLE_HOME}/suptools/orachk"
export OB="${ORACLE_BASE}"
export OH="${ORACLE_HOME}"
export DBS="${ORACLE_HOME}/dbs"
export TNS="${ORACLE_HOME}/network/admin"
export TFA="${TFA_HOME}"
export OCK="${OCK_HOME}"
export ORATOP="${ORACLE_HOME}/suptools/oratop"
export OPATCH="${ORACLE_HOME}/OPatch"
export JAVA_HOME="${ORACLE_HOME}/jdk"
if [[ "${ASM_EXISTS}" == "YES" ]]; then
  export GRID_HOME=${G_HOME}
  export GRID_BASE="$(${GRID_HOME}/bin/orabase)"
  export LD_LIBRARY_PATH=/lib:/usr/lib:/usr/lib64:${ORACLE_HOME}/lib:${ORACLE_HOME}/perl/lib:${ORACLE_HOME}/hs/lib
  export CLASSPATH=${ORACLE_HOME}/JRE:${ORACLE_HOME}/jlib:${ORACLE_HOME}/rdbms/jlib
  export PATH=${PATH}:${ORACLE_HOME}/bin:${OPATCH}:${GRID_HOME}/bin:${ORACLE_HOME}/perl/bin:${JAVA_HOME}/bin:${TFA_HOME}/bin:${OCK_HOME}/:${DBNITRO}/bin
  export HOME_ADR=$(echo 'set base ${GRID_BASE}; show homes' | adrci | egrep -i "+ASM*")
  export HOME_ADR_CRS=$(echo 'set base ${GRID_BASE}; show homes' | adrci | egrep -i "crs")
  export ALERTASM="${GRID_BASE}/${HOME_ADR}/trace/alert_+ASM*.log"
  export ALERTCRS="${GRID_BASE}/${HOME_ADR_CRS}/trace/alert.log"
  alias trc='cd ${ORACLE_BASE}/${HOME_ADR}/trace'
  alias asmlog='tail -f -n 100 ${ALERTASM} | egrep -i -v ${IGNORE_ERRORS}'
  alias asmlogv='vi ${ALERTASM}'
  alias crslog='tail -f -n 100 ${ALERTCRS} | egrep -i -v ${IGNORE_ERRORS}'
  alias crslogv='vi ${ALERTCRS}'
  alias res='crsctl stat res -t'
  alias rest='crsctl stat res -t -init'
  alias resp='crsctl stat res -p -init'
  alias asmcmd='rlwrap asmcmd'
  alias a='rlwrap asmcmd -p'
  alias rac-status='${DBNITRO}/bin/rac-status.sh -a'
  alias asmdu='${DBNITRO}/bin/asmdu.sh -g'
else
  export LD_LIBRARY_PATH=/lib:/usr/lib:/usr/lib64:${ORACLE_HOME}/lib:${ORACLE_HOME}/perl/lib:${ORACLE_HOME}/hs/lib
  export CLASSPATH=${ORACLE_HOME}/JRE:${ORACLE_HOME}/jlib:${ORACLE_HOME}/rdbms/jlib
  export PATH=${PATH}:${ORACLE_HOME}/bin:${OPATCH}:${ORACLE_HOME}/perl/bin:${JAVA_HOME}/bin:${TFA_HOME}/bin:${OCK_HOME}/:${DBNITRO}/bin
fi
export TNS_ADMIN="${ORACLE_HOME}/network/admin"
export ALERTLST="$(lsnrctl status | egrep -i "Listener Log File" | awk '{ print $4 }' | awk '{ print $1 }' | awk '{gsub("/alert/log.xml", "");print}')/trace/listener.log"
alias lsnlog='tail -f -n 100 ${ALERTLST} | egrep -i -v ${IGNORE_ERRORS}'
alias lsnlogv='vi ${ALERTLST}'
alias ob='cd ${ORACLE_BASE}'
alias oh='cd ${ORACLE_HOME}'
alias dbs='cd ${ORACLE_HOME}/dbs'
alias tns='cd ${ORACLE_HOME}/network/admin'
alias tfa='cd ${ORACLE_HOME}/suptools/tfa/release/tfa_home'
alias ock='${OCK_HOME}/orachk'
alias opl='${OPATCH}/opatch lspatches | sort'
alias sqlplus='rlwrap sqlplus'
alias s='rlwrap sqlplus / as sysdba @${DBNITRO}/sql/glogin.sql'
alias adrci='rlwrap adrci'
alias ad='rlwrap adrci'
alias p='ps -ef | egrep "pmon" | egrep -v egrep'
alias pb='ps -ef | egrep "d.bin" | egrep -v egrep'
alias t='rlwrap lsnrctl'
alias l='lsnrctl status'
alias list='${DBNITRO}/bin/OracleList.sh'
#
OWNER="$(ls -l ${ORACLE_HOME} | awk '{ print $3 }' | egrep -v -i "root" | egrep -Ev "^$" | uniq)"
#
if [[ ! -f ${ORACLE_HOME}/install/orabasetab ]]; then
  HOME_RW="RW"
else
  HOME_STATUS="$(cat ${ORACLE_HOME}/install/orabasetab | egrep -i ":N|:Y" | cut -f4 -d ':' | uniq)"
  if [[ ${HOME_STATUS} == "Y" ]]; then HOME_RW="[ RO ]"; elif [[ "${HOME_STATUS}" == "N" ]]; then HOME_RW="[ RW ]"; fi
fi
#
printf "+%-30s+%-70s+\n" "------------------------------" "----------------------------------------------------------------------"
printf "|%-16s|%-70s|\n" " DBNITRO.net                  " " ORACLE :: ${SELECTION} "
printf "+%-30s+%-70s+\n" "------------------------------" "----------------------------------------------------------------------"
printf "|%-22s|%-70s|\n" "                  ORACLE_BASE " " ${ORACLE_BASE} "
printf "|%-22s|%-70s|\n" "                  ORACLE_HOME " " ${ORACLE_HOME} "
printf "|%-22s|%-70s|\n" "                   OWNER_HOME " " ${OWNER} "
printf "|%-22s|%-70s|\n" "               ORACLE_VERSION " " $(sqlplus -v | egrep -i "Version" | awk '{ print $2 }') "
printf "|%-22s|%-70s|\n" "              HOME_READ/WRITE " " ${HOME_RW} "
ListenerService
printf "+%-30s+%-70s+\n" "------------------------------" "----------------------------------------------------------------------"
#
export PS1=$'[ HOME ]|[ ${LOGNAME}@\h:$(pwd): ]$ '
umask 0022
}
#
# ------------------------------------------------------------------------
# Set ASM Environment
#
set_ASM() {
unset_var
unalias_var
alias_var
set_GLOGIN
local OPT=$1
export ORACLE_HOSTNAME="${HOST}"
export ORACLE_TERM=xterm
export ORACLE_SID="${OPT}"
export ORACLE_HOME="${G_HOME}"
export GRID_HOME="${ORACLE_HOME}"
export GRID_BASE="$(${GRID_HOME}/bin/orabase)"
export GRID_SID="${OPT}"
export TFA_HOME="${ORACLE_HOME}/suptools/tfa/release/tfa_home"
export OCK_HOME="${ORACLE_HOME}/suptools/orachk"
export SID="${ORACLE_SID}"
export OB="${GRID_BASE}"
export OH="${ORACLE_HOME}"
export DBS="${ORACLE_HOME}/dbs"
export TNS="${ORACLE_HOME}/network/admin"
export TFA="${TFA_HOME}"
export OCK="${OCK_HOME}"
export OPATCH="${ORACLE_HOME}/OPatch"
export JAVA_HOME="${ORACLE_HOME}/jdk"
export LD_LIBRARY_PATH=/lib:/usr/lib:/usr/lib64:${ORACLE_HOME}/lib:${ORACLE_HOME}/perl/lib:${ORACLE_HOME}/hs/lib
export CLASSPATH=${ORACLE_HOME}/JRE:${ORACLE_HOME}/jlib:${ORACLE_HOME}/rdbms/jlib
export PATH=${PATH}:${ORACLE_HOME}/bin:${OPATCH}:${ORACLE_HOME}/perl/bin:${JAVA_HOME}/bin:${TFA_HOME}/bin:${OCK_HOME}/:${DBNITRO}/bin
export HOME_ADR=$(echo 'set base ${GRID_BASE}; show homes' | adrci | egrep -w "+ASM*")
export HOME_ADR_CRS=$(echo 'set base ${GRID_BASE}; show homes' | adrci | egrep -i "crs")
export GRID_ADR=$(echo 'set base ${GRID_BASE}; show homes' | ${GRID_HOME}/bin/adrci | egrep -i -w "listener")
export TNS_ADMIN="${ORACLE_HOME}/network/admin"
export ALERTASM="${GRID_BASE}/${HOME_ADR}/trace/alert_+ASM*.log"
export ALERTCRS="${GRID_BASE}/${HOME_ADR_CRS}/trace/alert.log"
export ALERTLST="$(lsnrctl status | egrep -i "Listener Log File" | awk '{ print $4 }' | awk '{ print $1 }' | awk '{gsub("/alert/log.xml", "");print}')/trace/listener.log"
alias gitrc='cd ${GRID_BASE}/${GRID_ADR}/trace'
alias gilsnlog='tail -f -n 100 ${GRID_BASE}/${GRID_ADR}/trace/listener.log | egrep -i -v ${IGNORE_ERRORS}'
alias gilsnlogv='vi ${GRID_BASE}/${GRID_ADR}/trace/listener.log'
alias trc='cd ${GRID_BASE}/${HOME_ADR}/trace'
alias asmlog='tail -f -n 100 ${ALERTASM} | egrep -i -v ${IGNORE_ERRORS}'
alias asmlogv='vi ${ALERTASM}'
alias crslog='tail -f -n 100 ${ALERTCRS} | egrep -i -v ${IGNORE_ERRORS}'
alias crslogv='vi ${ALERTCRS}'
alias lsnlog='tail -f -n 100 ${ALERTLST} | egrep -i -v ${IGNORE_ERRORS}'
alias lsnlogv='vi ${ALERTLST}'
alias res='crsctl stat res -t'
alias rest='crsctl stat res -t -init'
alias resp='crsctl stat res -p -init'
alias rac-status='${DBNITRO}/bin/rac-status.sh -a'
alias asmdu='${DBNITRO}/bin/asmdu.sh -g'
alias asmcmd='rlwrap asmcmd'
alias a='rlwrap asmcmd -p'
alias ob='cd ${GRID_BASE}'
alias oh='cd ${ORACLE_HOME}'
alias dbs='cd ${ORACLE_HOME}/dbs'
alias tns='cd ${ORACLE_HOME}/network/admin'
alias tfa='cd ${ORACLE_HOME}/suptools/tfa/release/tfa_home'
alias ock='${OCK_HOME}/orachk'
alias opl='${OPATCH}/opatch lspatches | sort'
alias sqlplus='rlwrap sqlplus'
alias s='rlwrap sqlplus / as sysasm @${DBNITRO}/sql/glogin.sql'
alias adrci='rlwrap adrci'
alias ad='rlwrap adrci'
alias p='ps -ef | egrep pmon | egrep -v egrep'
alias pb='ps -ef | egrep "d.bin" | egrep -v egrep'
alias t='rlwrap lsnrctl'
alias l='lsnrctl status'
alias list='${DBNITRO}/bin/OracleList.sh'
#
if [[ ! -f ${ORACLE_HOME}/install/orabasetab ]]; then
  HOME_RW="RW"
else
  HOME_STATUS="$(cat ${ORACLE_HOME}/install/orabasetab | egrep -i ":N|:Y" | cut -f4 -d ':' | uniq)"
  if [[ "${HOME_STATUS}" == "Y" ]]; then HOME_RW="[ RO ]"; elif [[ "${HOME_STATUS}" == "N" ]]; then HOME_RW="[ RW ]"; fi
fi
#
OWNER="$(ls -l ${GRID_HOME} | awk '{ print $3 }' | egrep -i -v "root" | egrep -Ev "^$" | uniq)"
#
PROC="$(ps -ef | egrep -i "asm_pmon" | egrep -i "${ORACLE_SID}" | awk '{ print $NF }' | sed s/asm_pmon_//g)"
if [[ "${PROC[@]}" =~ "${ORACLE_SID}"* ]]; then GRID_STATUS="[ ONLINE ]"; else GRID_STATUS="[ OFFLINE ]"; fi
#
CRSD="$(ps -ef | egrep -i -v "grep|egrep" | egrep -i "crsd.bin" | uniq | sort | wc -l)"
CRSD_HOME="$(ps -ef | egrep -i -v "grep|egrep" | egrep -i "crsd.bin" | awk '{ print $8 }' | uniq | sort)"
if [[ "${CRSD}" != 0 ]]; then GI_CRSD="[ ONLINE ]"; else GI_CRSD="[ OFFLINE ]"; fi
#
OCSSD="$(ps -ef | egrep -i -v "grep|egrep" | egrep -i "ocssd.bin" | uniq | sort | wc -l)"
OCSSD_HOME="$(ps -ef | egrep -i -v "grep|egrep" | egrep -i "ocssd.bin" | awk '{ print $8 }' | uniq | sort)"
if [[ "${OCSSD}" != 0 ]]; then GI_OCSSD="[ ONLINE ]"; else GI_OCSSD="[ OFFLINE ]"; fi
#
OHASD="$(ps -ef | egrep -i -v "grep|egrep" | egrep -i "ohasd.bin" | uniq | sort | wc -l)"
OHASD_HOME="$(ps -ef | egrep -i -v "grep|egrep" | egrep -i "ohasd.bin" | awk '{ print $8 }' | uniq | sort)"
if [[ "${OHASD}" != 0 ]]; then GI_OHASD="[ ONLINE ]"; else GI_OHASD="[ OFFLINE ]"; fi
#
printf "+%-30s+%-70s+\n" "------------------------------" "----------------------------------------------------------------------"
printf "|%-16s|%-70s|\n" " DBNITRO.net                  " " ORACLE :: ${SELECTION} "
printf "+%-30s+%-70s+\n" "------------------------------" "----------------------------------------------------------------------"
printf "|%-22s|%-70s|\n" "                    GRID_BASE " " ${GRID_BASE} "
printf "|%-22s|%-70s|\n" "                    GRID_HOME " " ${GRID_HOME} "
printf "|%-22s|%-70s|\n" "                     GRID_SID " " ${GRID_SID} "
printf "|%-22s|%-70s|\n" "                   GRID_OWNER " " ${OWNER} "
printf "|%-22s|%-70s|\n" "                 GRID_VERSION " " $(sqlplus -v | egrep -i "Version" | awk '{ print $2 }') "
printf "|%-22s|%-70s|\n" "              HOME_READ/WRITE " " ${HOME_RW} "
printf "|%-22s|%-70s|\n" "                   ASM_STATUS " " ${GRID_STATUS} "
ListenerService
printf "|%-22s|%-70s|\n" "                         CRSD " " ${GI_CRSD} ${CRSD_HOME} "
printf "|%-22s|%-70s|\n" "                        OCSSD " " ${GI_OCSSD} ${OCSSD_HOME} "
printf "|%-22s|%-70s|\n" "                        OHASD " " ${GI_OHASD} ${OHASD_HOME} "
printf "+%-30s+%-70s+\n" "------------------------------" "----------------------------------------------------------------------"
#
export PS1=$'[ ${ORACLE_SID} ]|[ ${LOGNAME}@\h:$(pwd): ]$ '
umask 0022
}
#
# ------------------------------------------------------------------------
# Set the Database Environment
#
set_DB() {
unset_var
unalias_var
alias_var
set_GLOGIN
local OPT=$1
export ORACLE_HOSTNAME="${HOST}"
export ORACLE_TERM=xterm
export ORACLE_SID="${OPT}"
export ORACLE_HOME="$(cat ${ORATAB} | egrep -i ":N|:Y" | egrep -w "${ORACLE_SID}" | cut -f2 -d ':')"
export ORACLE_BASE="$(${ORACLE_HOME}/bin/orabase)"
export TFA_HOME="${ORACLE_HOME}/suptools/tfa/release/tfa_home"
export OCK_HOME="${ORACLE_HOME}/suptools/orachk"
export SID="${ORACLE_SID}"
export OB="${ORACLE_BASE}"
export OH="${ORACLE_HOME}"
export DBS="${ORACLE_HOME}/dbs"
export TNS="${ORACLE_HOME}/network/admin"
export TFA="${TFA_HOME}"
export OCK="${OCK_HOME}"
export ORATOP="${ORACLE_HOME}/suptools/oratop"
export OPATCH="${ORACLE_HOME}/OPatch"
export JAVA_HOME="${ORACLE_HOME}/jdk"
#
if [[ "${ASM_EXISTS}" == "YES" ]]; then
  export GRID_HOME="${G_HOME}"
  export GRID_BASE=$(locate -b 'crsdata' | egrep -i -v "orainventory" | sed 's/crsdata//g')
  export GRID_ADR=$(echo 'set base ${GRID_BASE}; show homes' | ${GRID_HOME}/bin/adrci | egrep -i -w "listener")
  export LD_LIBRARY_PATH=/lib:/usr/lib:/usr/lib64:${ORACLE_HOME}/lib:${GRID_HOME}/lib:${ORACLE_HOME}/perl/lib:${GRID_HOME}/perl/lib:${ORACLE_HOME}/hs/lib
  export CLASSPATH=${ORACLE_HOME}/JRE:${ORACLE_HOME}/jlib:${ORACLE_HOME}/rdbms/jlib:${GRID_HOME}/jlib:${GRID_HOME}/rdbms/jlib
  export PATH=${PATH}:${ORACLE_HOME}/bin:${OPATCH}:${GRID_HOME}/bin:${ORACLE_HOME}/perl/bin:${JAVA_HOME}/bin:${TFA_HOME}/bin:${OCK_HOME}/:${DBNITRO}/bin
  alias gitrc='cd ${GRID_BASE}/${GRID_ADR}/trace'
  alias gilsnlog='tail -f -n 100 ${GRID_BASE}/${GRID_ADR}/trace/listener.log | egrep -i -v ${IGNORE_ERRORS}'
  alias gilsnlogv='vi ${GRID_BASE}/${GRID_ADR}/trace/listener.log'
  alias res='crsctl stat res -t'
  alias rest='crsctl stat res -t -init'
  alias resp='crsctl stat res -p -init'
  alias rac-status='${DBNITRO}/bin/rac-status.sh -a'
  alias asmdu='${DBNITRO}/bin/asmdu.sh -g'
  alias asmcmd='rlwrap asmcmd'
  alias a='rlwrap asmcmd -p'
else
  export LD_LIBRARY_PATH=/lib:/usr/lib:/usr/lib64:${ORACLE_HOME}/lib:${ORACLE_HOME}/perl/lib:${ORACLE_HOME}/hs/lib
  export CLASSPATH=${ORACLE_HOME}/JRE:${ORACLE_HOME}/jlib:${ORACLE_HOME}/rdbms/jlib
  export PATH=${PATH}:${ORACLE_HOME}/bin:${OPATCH}:${ORACLE_HOME}/perl/bin:${JAVA_HOME}/bin:${TFA_HOME}/bin:${OCK_HOME}/:${DBNITRO}/bin
fi
#
export TNS_ADMIN="${ORACLE_HOME}/network/admin"
export HOME_ADR=$(echo 'set base ${ORACLE_BASE}; show homes' | adrci | egrep -w "${OPT}")
export ORACLE_UNQNAME=$(echo ${HOME_ADR} | cut -f4 -d '/')
export ALERTDB="${ORACLE_BASE}/${HOME_ADR}/trace/alert_${ORACLE_SID}.log"
export ALERTDG="${ORACLE_BASE}/${HOME_ADR}/trace/drc*.log"
export ALERTLST="$(lsnrctl status | egrep -i "Listener Log File" | awk '{ print $4 }' | awk '{ print $1 }' | awk '{gsub("/alert/log.xml", "");print}')/trace/listener.log"
alias dbtrc='cd ${ORACLE_BASE}/${HOME_ADR}/trace'
alias lsnlog='tail -f -n 100 ${ALERTLST} | egrep -i -v ${IGNORE_ERRORS}'
alias lsnlogv='vi ${ALERTLST}'
alias dblog='tail -f -n 100 ${ALERTDB} | egrep -i -v ${IGNORE_ERRORS}'
alias dblogv='vi ${ALERTDB}'
alias dglog='tail -f -n 100 ${ALERTDG} | egrep -i -v ${IGNORE_ERRORS}'
alias dglogv='vi ${ALERTDG}'
alias ob='cd ${ORACLE_BASE}'
alias oh='cd ${ORACLE_HOME}'
alias dbs='cd ${ORACLE_HOME}/dbs'
alias tns='cd ${ORACLE_HOME}/network/admin'
alias tfa='cd ${ORACLE_HOME}/suptools/tfa/release/tfa_home'
alias ock='${OCK_HOME}/orachk'
alias opl='${OPATCH}/opatch lspatches | sort'
alias sqlplus='rlwrap sqlplus'
alias s='rlwrap sqlplus / as sysdba @${DBNITRO}/sql/glogin.sql'
alias rman='rlwrap rman'
alias r='rlwrap rman target /'
alias dgmgrl='rlwrap dgmgrl'
alias d='rlwrap dgmgrl /'
alias adrci='rlwrap adrci'
alias ad='rlwrap adrci'
alias p='ps -ef | egrep pmon | egrep -v egrep'
alias pb='ps -ef | egrep "d.bin" | egrep -v egrep'
alias t='rlwrap lsnrctl'
alias l='lsnrctl status'
alias orat='${ORATOP}/oratop -f -i 3 / as sysdba'
alias oratop='${ORATOP}/oratop'
alias odg-status='get_ODG_STATUS'
alias pdb='set_PDB'
alias ogg='set_OGG'
alias list='${DBNITRO}/bin/OracleList.sh'
alias INFO='get_INFO'
alias DASH='get_DASH'
alias DASH_INSTALL='get_DASH_INSTALL'
alias REPORT='get_REPORT'
alias DBNITRO='${DBNITRO}/bin/ribas.sh'
alias OPTIONS='get_OPTIONS'
alias HUGEPAGES='${DBNITRO}/bin/Oracle_DBA_Check_Hugepages.sh'
#
if [[ ! -f "${ORACLE_HOME}/install/orabasetab" ]]; then
  HOME_RW="RW"
else
  HOME_STATUS="$(cat ${ORACLE_HOME}/install/orabasetab | egrep -i ":N|:Y" | cut -f4 -d ':' | uniq)"
  if [[ "${HOME_STATUS}" == "Y" ]]; then HOME_RW="[ RO ]"; elif [[ "${HOME_STATUS}" == "N" ]]; then HOME_RW="[ RW ]"; fi
fi
#
OWNER="$(ls -l ${ORACLE_HOME} | awk '{ print $3 }' | egrep -i -v "root" | egrep -Ev "^$" | uniq)"
#
PROC="$(ps -ef | egrep -i "ora_pmon" | egrep -i "${ORACLE_SID}" | awk '{ print $NF }' | sed s/ora_pmon_//g)"
#
if [[ "${PROC[@]}" =~ "${ORACLE_SID}"* ]]; then DB_STATUS="[ ONLINE ]"; else DB_STATUS="[ OFFLINE ]"; fi
#
if [[ "$(ps -ef | egrep -i "ora_pmon" | egrep -i "${ORACLE_SID}" | awk '{ print $NF }' | sed s/ora_pmon_//g | wc -l | xargs)" != "0" ]]; then
  V_INSTANCE_STATUS="$(echo "select to_char(status) from v\$instance;" | sqlplus -S / as sysdba | tail -2)"
  if [[ "${V_INSTANCE_STATUS}" == "OPEN" ]] || [[ "${V_INSTANCE_STATUS}" == "OPEN READ ONLY" ]] || [[ "${V_INSTANCE_STATUS}" == "OPEN RESTRICTED" ]]; then
    printf "+%-30s+%-70s+\n" "------------------------------" "----------------------------------------------------------------------"
    printf "|%-16s|%-70s|\n" " DBNITRO.net                  " " ORACLE :: ${SELECTION} "
    printf "+%-30s+%-70s+\n" "------------------------------" "----------------------------------------------------------------------"
    printf "|%-22s|%-70s|\n" "                DATABASE_NAME " " $(echo "select to_char(name) from v\$database;" | sqlplus -S / as sysdba | tail -2) "
    printf "|%-22s|%-70s|\n" "         DATABASE_UNIQUE_NAME " " $(echo "select to_char(db_unique_name) from v\$database;" | sqlplus -S / as sysdba | tail -2) "
    printf "|%-22s|%-70s|\n" "                         DBID " " $(echo "select to_char(dbid) from v\$database;" | sqlplus -S / as sysdba | tail -2) "
    printf "|%-22s|%-70s|\n" "              DATABASE_STATUS " " $(echo "select to_char(database_status) from v\$instance;" | sqlplus -S / as sysdba | tail -2) "
    printf "|%-22s|%-70s|\n" "                DATABASE_ROLE " " $(echo "select to_char(database_role) from v\$database;" | sqlplus -S / as sysdba | tail -2) "
    printf "|%-22s|%-70s|\n" "              DATABASE_UPTIME " " $(echo "select to_char(startup_time, 'dd/mm/yyyy hh24:mi') from v\$instance;" | sqlplus -S / as sysdba | tail -2) "
    printf "|%-22s|%-70s|\n" "              INSTANCE_STATUS " " $(echo "select to_char(status) from v\$instance;" | sqlplus -S / as sysdba | tail -2) "
    printf "|%-22s|%-70s|\n" "                    OPEN_MODE " " $(echo "select to_char(open_mode) from v\$database;" | sqlplus -S / as sysdba | tail -2) "
    printf "|%-22s|%-70s|\n" "                     LOG_MODE " " $(echo "select case when log_mode = 'ARCHIVELOG' then 'YES' else 'NO' end from v\$database;" | sqlplus -S / as sysdba | tail -2) "
    printf "|%-22s|%-70s|\n" "                    FORCE_LOG " " $(echo "select to_char(force_logging) from v\$database;" | sqlplus -S / as sysdba | tail -2) "
    printf "|%-22s|%-70s|\n" "                    FLASHBACK " " $(echo "select to_char(flashback_on) from v\$database;" | sqlplus -S / as sysdba | tail -2) "
    printf "|%-22s|%-70s|\n" "            INSTANCE_SGA_SIZE " " $(echo "select trim(to_char(value/1024/1024/1024, '999,999.99')) || ' GB' from v\$parameter where name = 'sga_max_size';" | sqlplus -S / as sysdba | tail -2) "
    printf "|%-22s|%-70s|\n" "            INSTANCE_PGA_SIZE " " $(echo "select trim(to_char(value/1024/1024/1024, '999,999.99')) || ' GB' from v\$parameter where name = 'pga_aggregate_target';" | sqlplus -S / as sysdba | tail -2) "
    printf "|%-22s|%-70s|\n" "                DATAFILE_SIZE " " $(echo "select trim(to_char(sum(bytes)/1024/1024/1024, '999,999.99')) || ' GB' from dba_data_files;" | sqlplus -S / as sysdba | tail -2) "
    printf "|%-22s|%-70s|\n" "                     FRA_SIZE " " $(echo "select trim(to_char(sum(space_limit)/1024/1024/1024, '999,999.99')) || ' GB' from v\$recovery_file_dest;" | sqlplus -S / as sysdba| tail -2) "
    printf "|%-22s|%-70s|\n" "               USERS/SESSIONS " " $(echo "select to_char(count(*)) from v\$session WHERE username is not null and username not in ('SYS', 'SYSTEM');" | sqlplus -S / as sysdba| tail -2) "
    printf "|%-22s|%-70s|\n" "                 CHARACTERSET " " $(echo "select to_char(value) from nls_database_parameters where parameter = 'NLS_CHARACTERSET';" | sqlplus -S / as sysdba | tail -2) "
    printf "|%-22s|%-70s|\n" "                  ORACLE_BASE " " ${ORACLE_BASE} "
    printf "|%-22s|%-70s|\n" "                  ORACLE_HOME " " ${ORACLE_HOME} "
    printf "|%-22s|%-70s|\n" "              HOME_READ/WRITE " " ${HOME_RW} "
    printf "|%-22s|%-70s|\n" "               ORACLE_VERSION " " $(sqlplus -V | egrep -i "Version" | awk '{ print $2 }') "
    printf "|%-22s|%-70s|\n" "                 ORACLE_OWNER " " ${OWNER} "
    printf "|%-22s|%-70s|\n" "                   ORACLE_SID " " ${ORACLE_SID} "
    printf "|%-22s|%-70s|\n" "              DATABASE_STATUS " " ${DB_STATUS} "
    ListenerService
    printf "+%-30s+%-70s+\n" "------------------------------" "----------------------------------------------------------------------"
  fi
#
  if [[ "${V_INSTANCE_STATUS}" == "MOUNTED" ]]; then
    printf "+%-30s+%-70s+\n" "------------------------------" "----------------------------------------------------------------------"
    printf "|%-16s|%-70s|\n" " DBNITRO.net                  " " ORACLE :: ${SELECTION} "
    printf "+%-30s+%-70s+\n" "------------------------------" "----------------------------------------------------------------------"
    printf "|%-22s|%-70s|\n" "                DATABASE_NAME " " $(echo "select to_char(name) from v\$database;" | sqlplus -S / as sysdba | tail -2) "
    printf "|%-22s|%-70s|\n" "         DATABASE_UNIQUE_NAME " " $(echo "select to_char(db_unique_name) from v\$database;" | sqlplus -S / as sysdba | tail -2) "
    printf "|%-22s|%-70s|\n" "                         DBID " " $(echo "select to_char(dbid) from v\$database;" | sqlplus -S / as sysdba | tail -2) "
    printf "|%-22s|%-70s|\n" "              DATABASE_STATUS " " $(echo "select to_char(database_status) from v\$instance;" | sqlplus -S / as sysdba | tail -2) "
    printf "|%-22s|%-70s|\n" "                DATABASE_ROLE " " $(echo "select to_char(database_role) from v\$database;" | sqlplus -S / as sysdba | tail -2) "
    printf "|%-22s|%-70s|\n" "              DATABASE_UPTIME " " $(echo "select to_char(startup_time, 'dd/mm/yyyy hh24:mi') from v\$instance;" | sqlplus -S / as sysdba | tail -2) "
    printf "|%-22s|%-70s|\n" "              INSTANCE_STATUS " " $(echo "select to_char(status) from v\$instance;" | sqlplus -S / as sysdba | tail -2) "
    printf "|%-22s|%-70s|\n" "                    OPEN_MODE " " $(echo "select to_char(open_mode) from v\$database;" | sqlplus -S / as sysdba | tail -2) "
    printf "|%-22s|%-70s|\n" "                     LOG_MODE " " $(echo "select case when log_mode = 'ARCHIVELOG' then 'YES' else 'NO' end from v\$database;" | sqlplus -S / as sysdba | tail -2) "
    printf "|%-22s|%-70s|\n" "                    FORCE_LOG " " $(echo "select to_char(force_logging) from v\$database;" | sqlplus -S / as sysdba | tail -2) "
    printf "|%-22s|%-70s|\n" "                    FLASHBACK " " $(echo "select to_char(flashback_on) from v\$database;" | sqlplus -S / as sysdba | tail -2) "
    printf "|%-22s|%-70s|\n" "            INSTANCE_SGA_SIZE " " $(echo "select trim(to_char(value/1024/1024/1024, '999,999.99')) || ' GB' from v\$parameter where name = 'sga_max_size';" | sqlplus -S / as sysdba | tail -2) "
    printf "|%-22s|%-70s|\n" "            INSTANCE_PGA_SIZE " " $(echo "select trim(to_char(value/1024/1024/1024, '999,999.99')) || ' GB' from v\$parameter where name = 'pga_aggregate_target';" | sqlplus -S / as sysdba | tail -2) "
    printf "|%-22s|%-70s|\n" "                DATAFILE_SIZE " " DATABASE NOT OPENED  "
    printf "|%-22s|%-70s|\n" "                     FRA_SIZE " " $(echo "select trim(to_char(sum(space_limit)/1024/1024/1024, '999,999.99')) || ' GB' from v\$recovery_file_dest;" | sqlplus -S / as sysdba | tail -2) "
    printf "|%-22s|%-70s|\n" "               USERS/SESSIONS " " $(echo "select to_char(count(*)) from v\$session WHERE username is not null and username not in ('SYS', 'SYSTEM');" | sqlplus -S / as sysdba| tail -2) "
    printf "|%-22s|%-70s|\n" "                 CHARACTERSET " " DATABASE NOT OPENED  "
    printf "|%-22s|%-70s|\n" "                  ORACLE_BASE " " ${ORACLE_BASE} "
    printf "|%-22s|%-70s|\n" "                  ORACLE_HOME " " ${ORACLE_HOME} "
    printf "|%-22s|%-70s|\n" "              HOME_READ/WRITE " " ${HOME_RW} "
    printf "|%-22s|%-70s|\n" "               ORACLE_VERSION " " $(sqlplus -V | egrep -i "Version" | awk '{ print $2 }') "
    printf "|%-22s|%-70s|\n" "                 ORACLE_OWNER " " ${OWNER} "
    printf "|%-22s|%-70s|\n" "                   ORACLE_SID " " ${ORACLE_SID} "
    printf "|%-22s|%-70s|\n" "              DATABASE_STATUS " " ${DB_STATUS} "
    ListenerService
    printf "+%-30s+%-70s+\n" "------------------------------" "----------------------------------------------------------------------"
  fi
#
elif [[ "$(ps -ef | egrep -i "ora_pmon" | egrep -i "${ORACLE_SID}" | awk '{ print $NF }' | sed s/ora_pmon_//g | wc -l | xargs)" == "0" ]]; then
  printf "+%-30s+%-70s+\n" "------------------------------" "----------------------------------------------------------------------"
  printf "|%-16s|%-70s|\n" " DBNITRO.net                  " " ORACLE :: ${SELECTION} "
  printf "+%-30s+%-70s+\n" "------------------------------" "----------------------------------------------------------------------"
  printf "|%-22s|%-70s|\n" "                  ORACLE_BASE " " ${ORACLE_BASE} "
  printf "|%-22s|%-70s|\n" "                  ORACLE_HOME " " ${ORACLE_HOME} "
  printf "|%-22s|%-70s|\n" "              HOME_READ/WRITE " " ${HOME_RW} "
  printf "|%-22s|%-70s|\n" "               ORACLE_VERSION " " $(sqlplus -V | egrep -i "Version" | awk '{ print $2 }') "
  printf "|%-22s|%-70s|\n" "                 ORACLE_OWNER " " ${OWNER} "
  printf "|%-22s|%-70s|\n" "                   ORACLE_SID " " ${ORACLE_SID} "
  printf "|%-22s|%-70s|\n" "              DATABASE_STATUS " " ${DB_STATUS} "
  ListenerService
  printf "+%-30s+%-70s+\n" "------------------------------" "----------------------------------------------------------------------"
fi
export PS1=$'[ ${ORACLE_SID} ]|[ ${LOGNAME}@\h:$(pwd): ]$ '
umask 0022
}
#
# ------------------------------------------------------------------------
# Set the OMS Home
#
set_OMS() {
unset_var
unalias_var
alias_var
local OPT=$1
export ORACLE_HOSTNAME="${HOST}"
export ORACLE_HOME="$(cat ${ORA_INVENTORY} | egrep -i "${OPT}" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"')"
export OH="${ORACLE_HOME}"
export OMS_GC="$(locate -b gc_inst | uniq)"
export OPATCH="${ORACLE_HOME}/OPatch"
export JAVA_HOME="${ORACLE_HOME}/jdk"
export CLASSPATH=${ORACLE_HOME}/jlib
export LD_LIBRARY_PATH=/lib:/usr/lib:/usr/lib64:${ORACLE_HOME}/lib:${ORACLE_HOME}/perl/lib:${ORACLE_HOME}/instantclient
export PATH=${PATH}:${ORACLE_HOME}/bin:${OPATCH}:${ORACLE_HOME}/perl/bin:${JAVA_HOME}/bin:${DBNITRO}/bin
alias oh='cd ${ORACLE_HOME}'
alias opl='${OPATCH}/opatch lspatches | sort'
alias p='ps -ef | egrep "wlserver" | egrep -v "grep|egrep"'
alias pb='ps -ef | egrep "d.bin" | egrep -v egrep'
alias emlog='tail -f -n 100 ${OMS_GC}/em/EMGC_OMS1/sysman/log/emctl.log'
alias emlogv='vi ${OMS_GC}/em/EMGC_OMS1/sysman/log/emctl.log'
alias omslog='tail -f -n 100 ${OMS_GC}/em/EMGC_OMS1/sysman/log/emoms.log'
alias omslogv='vi ${OMS_GC}/em/EMGC_OMS1/sysman/log/emoms.log'
alias list='${DBNITRO}/bin/OracleList.sh'
#
OWNER="$(ls -l ${ORACLE_HOME} | awk '{ print $3 }' | egrep -i -v "root" | egrep -Ev "^$" | uniq)"
#
OMS_STATUS="$(ps -ef | egrep -i -v "grep|egrep" | egrep -i "wlserver" | wc -l | xargs)"
if [[ "${OMS_STATUS}" != 0 ]]; then OMS="[ ONLINE ]"; else OMS="[ OFFLINE ]"; fi
#
printf "+%-30s+%-70s+\n" "------------------------------" "----------------------------------------------------------------------"
printf "|%-16s|%-70s|\n" " DBNITRO.net                  " " ORACLE :: ${SELECTION} "
printf "+%-30s+%-70s+\n" "------------------------------" "----------------------------------------------------------------------"
printf "|%-22s|%-70s|\n" "                     OMS_HOME " " ${ORACLE_HOME} "
printf "|%-22s|%-70s|\n" "                    OMS_OWNER " " ${OWNER} "
printf "|%-22s|%-70s|\n" "                   OMS_STATUS " " ${OMS} "
printf "+%-30s+%-70s+\n" "------------------------------" "----------------------------------------------------------------------"
#
export PS1=$'[ OMS ]|[ ${LOGNAME}@\h:$(pwd): ]$ '
umask 0022
}
#
# ------------------------------------------------------------------------
# Set AGENT Home
#
set_AGENT() {
unset_var
unalias_var
alias_var
local OPT=$1
export ORACLE_HOSTNAME="${HOST}"
export ORACLE_HOME="$(cat ${ORA_INVENTORY} | egrep -i "${OPT}" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"')"
export OH="${ORACLE_HOME}"
export OPATCH="${ORACLE_HOME}/OPatch"
export JAVA_HOME="${ORACLE_HOME}/jdk"
export CLASSPATH=${ORACLE_HOME}/jlib
export LD_LIBRARY_PATH=/lib:/usr/lib:/usr/lib64:${ORACLE_HOME}/lib:${ORACLE_HOME}/perl/lib:${ORACLE_HOME}/instantclient
export PATH=${PATH}:${ORACLE_HOME}/bin:${OPATCH}:${ORACLE_HOME}/perl/bin:${JAVA_HOME}/bin:${DBNITRO}/bin
alias oh='cd ${ORACLE_HOME}'
alias opl='${OPATCH}/opatch lspatches | sort'
alias adrci='rlwrap adrci'
alias ad='rlwrap adrci'
alias p='ps -ef | egrep "agent" | egrep -v egrep'
alias pb='ps -ef | egrep "d.bin" | egrep -v egrep'
alias list='${DBNITRO}/bin/OracleList.sh'
#
OWNER="$(ls -l ${ORACLE_HOME} | awk '{ print $3 }' | egrep -i -v "root" | egrep -Ev "^$" | uniq)"
#
AGENT_STATUS="$(ps -ef | egrep -i -v "grep|egrep|zabbix" | egrep -i "agent_|perl" | uniq | sort | wc -l | xargs)"
if [[ "${AGENT_STATUS}" != 0 ]]; then AGENT="[ ONLINE ]"; else AGENT="[ OFFLINE ]"; fi
#
printf "+%-30s+%-70s+\n" "------------------------------" "----------------------------------------------------------------------"
printf "|%-16s|%-70s|\n" " DBNITRO.net                  " " ORACLE :: ${SELECTION} "
printf "+%-30s+%-70s+\n" "------------------------------" "----------------------------------------------------------------------"
printf "|%-22s|%-70s|\n" "                   AGENT_HOME " " ${ORACLE_HOME} "
printf "|%-22s|%-70s|\n" "                  AGENT_OWNER " " ${OWNER} "
printf "|%-22s|%-70s|\n" "                 AGENT_STATUS " " ${AGENT} "
printf "+%-30s+%-70s+\n" "------------------------------" "----------------------------------------------------------------------"
#
export PS1=$'[ AGENT ]|[ ${LOGNAME}@\h:$(pwd): ]$ '
umask 0022
}
#
# ------------------------------------------------------------------------
#
# Main Menu
#
MainMenu() {
SetClear
PS3="Select the Option: "
select OPT in ${ORA_HOMES} ${ORA_OMS} ${ORA_AGENT} ${DBLIST} QUIT; do
if [[ "${OPT}" == "QUIT" ]]; then
  echo " -- Exit Menu --"
  return 1
elif [[ "${OPT}" == "+ASM"* ]]; then
  if [[ "${ASM_USER}" == "YES" ]]; then
    SELECTION="ASM"
    set_ASM ${OPT}
  else
    echo " -- ASM USER IS DIFFERENT AS ORACLE USER --"
    echo " -- YOU MUST CONNECT AS OS USER: ${ASM_OWNER} --"
    continue
  fi
elif [[ "${ORA_HOMES[@]}" =~ "${OPT}" ]] && [[ "${OPT}" != "" ]]; then
  SELECTION="HOME"
  set_HOME ${OPT}
elif [[ "${ORA_OMS[@]}" =~ "${OPT}" ]] && [[ "${OPT}" != "" ]]; then
  SELECTION="OMS"
  set_OMS ${OPT}
elif [[ "${ORA_AGENT[@]}" =~ "${OPT}" ]] && [[ "${OPT}" != "" ]]; then
  SELECTION="AGENT"
  set_AGENT ${OPT}
elif [[ "${DBLIST[@]}" =~ "${OPT}" ]] && [[ "${OPT}" != "" ]]; then
  SELECTION="DATABASE"
  set_DB ${OPT}
else
  echo " -- Invalid Option --"
  continue
fi
break
done
}
MainMenu
#
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
# THE SCRIPT FINISHES HERE
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
#
