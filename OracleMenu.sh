#!/bin/sh
Author="Andre Augusto Ribas"
SoftwareVersion="1.0.63"
DateCreation="07/01/2021"
DateModification="12/09/2022"
EMAIL_1="dba.ribas@gmail.com"
EMAIL_2="andre.ribas@icloud.com"
WEBSITE="http://dbnitro.net"
#
# ------------------------------------------------------------------------
# Separate Line Function
#
function SepLine() {
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' - 
}
#
# ------------------------------------------------------------------------
# Clear Screen Function
#
function SetClear() {
  printf "\033c"
}
#
# ------------------------------------------------------------------------
# DBNITRO Script Folder
#
FOLDER="/opt"
DBNITRO="${FOLDER}/dbnitro"
#
if [[ ! -d ${DBNITRO}/ ]]; then
  SetClear
  SepLine
  echo " -- YOUR SCRIPT FOLDER DOES NOT EXISTS, YOU HAVE TO CREATE THAT BEFORE YOU CONTINUE --"
  return 1
fi
#
if [[ ${DBNITRO} == "" ]]; then
  SetClear
  SepLine
  echo " -- YOUR SCRIPT FOLDER IS EMPTY, YOU HAVE TO CONFIGURE THAT BEFORE YOU CONTINUE --"
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
function HELP() {
SetClear
SepLine
echo -e "\
|#| GRID........: YOU CAN SELECT THE GRID OPTION AND WORK WITH GRID INSTANCE (ASM) AND TOOLS
|#| DATABASE....: YOU CAN SELECT THE DATABASE INSTANCE (SID) AND TOOLS
|#| HOMES.......: YOU CAN SELECT THE ORACLE HOME WITHOUT ANY INSTANCE (ASM/SID)
|#| OMS.........: YOU CAN SELECT THE ORACLE ENTERPRISE MANAGER (OMS) HOME AND TOOLS
|#| AGENT.......: YOU CAN SELECT THE ORACLE ENTERPRISE MANAGER AGENT HOME AND TOOLS
|#| GOLDENGATE..: YOU CAN SELECT THE ORACLE GOLDENGATE HOME AND TOOLS (ONLY AFTER SELECT THE ORACLE SID) ---> ogg
|#| CDB/PDB.....: YOU CAN SELECT THE ORACLE CONTAINER/PLUGGABLE DATABASE (ONLY AFTER SELECT THE ORACLE SID) ---> pdb"
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
ORA_HOMES_IGNORE_1="REMOVED|REFHOME|DEPHOME|PLUGINS|/usr/lib/oracle/sbin|middleware|agent"
ORA_HOMES_IGNORE_2="REMOVED|REFHOME|DEPHOME|PLUGINS|/usr/lib/oracle/sbin|middleware"
ORA_HOMES_IGNORE_3="REMOVED|REFHOME|DEPHOME|PLUGINS|/usr/lib/oracle/sbin|middleware|agent"
ORA_HOMES_IGNORE_4="REMOVED|REFHOME|DEPHOME|PLUGINS|/usr/lib/oracle/sbin|agent"
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
  ORA_AGENT=$(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_2}" | egrep -i "LOC"   | egrep -i "agent"             | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  OGG_HOME=$(cat ${ORA_INVENTORY}  | egrep -i -v "^#|${ORA_HOMES_IGNORE_3}" | egrep -i "LOC"   | egrep -i "goldengate|ogg|gg" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  ORA_OMS=$(cat ${ORA_INVENTORY}   | egrep -i -v "^#|${ORA_HOMES_IGNORE_4}" | egrep -i "LOC"   | egrep -i "middleware"        | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  DBLIST=$(cat ${ORATAB}           | egrep -i -v "^#|${ORA_HOMES_IGNORE_5}" | egrep -i ":N|:Y" | cut -f1 -d ':'               | uniq | sort)
  ASM=$(cat ${ORATAB}              | egrep -i -v "^#|${ORA_HOMES_IGNORE_5}" | egrep -i "+ASM*" | cut -f1 -d ':'               | uniq | sort | wc -l)
  T_MEM=$(free -g -h  | egrep -i "Mem"  | awk '{ print $2 }')
  U_MEM=$(free -g -h  | egrep -i "Mem"  | awk '{ print $3 }')
  F_MEM=$(free -g -h  | egrep -i "Mem"  | awk '{ print $4 }')
  T_SWAP=$(free -g -h | egrep -i "Swap" | awk '{ print $2 }')
  U_SWAP=$(free -g -h | egrep -i "Swap" | awk '{ print $3 }')
  F_SWAP=$(free -g -h | egrep -i "Swap" | awk '{ print $4 }')
  RED="\033[1;31m"
  YEL="\033[1;33m"
  BLU="\e[96m"
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
  ORA_AGENT=$(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_2}" | egrep -i "LOC"   | egrep -i "agent"             | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  OGG_HOME=$(cat ${ORA_INVENTORY}  | egrep -i -v "^#|${ORA_HOMES_IGNORE_3}" | egrep -i "LOC"   | egrep -i "goldengate|ogg|gg" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  ORA_OMS=$(cat ${ORA_INVENTORY}   | egrep -i -v "^#|${ORA_HOMES_IGNORE_4}" | egrep -i "LOC"   | egrep -i "middleware"        | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  DBLIST=$(cat ${ORATAB}           | egrep -i -v "^#|${ORA_HOMES_IGNORE_5}" | egrep -i ":N|:Y" | cut -f1 -d ':'               | uniq | sort)
  ASM=$(cat ${ORATAB}              | egrep -i -v "^#|${ORA_HOMES_IGNORE_5}" | egrep -i "+ASM*" | cut -f1 -d ':'               | uniq | sort | wc -l)
  T_MEM=$(svmon -G -O unit=GB | egrep -i "memory" | awk '{ print $2 }')
  U_MEM=$(svmon -G -O unit=GB | egrep -i "memory" | awk '{ print $3 }')
  F_MEM=$(svmon -G -O unit=GB | egrep -i "memory" | awk '{ print $4 }')
  T_SWAP="NO"
  U_SWAP="NO"
  F_SWAP="NO"
  RED="\033[1;31m"
  YEL="\033[1;33m"
  BLU="\e[96m"
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
  ORA_AGENT=$(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_2}" | egrep -i "LOC"   | egrep -i "agent"             | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  OGG_HOME=$(cat ${ORA_INVENTORY}  | egrep -i -v "^#|${ORA_HOMES_IGNORE_3}" | egrep -i "LOC"   | egrep -i "goldengate|ogg|gg" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  ORA_OMS=$(cat ${ORA_INVENTORY}   | egrep -i -v "^#|${ORA_HOMES_IGNORE_4}" | egrep -i "LOC"   | egrep -i "middleware"        | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)
  DBLIST=$(cat ${ORATAB}           | egrep -i -v "^#|${ORA_HOMES_IGNORE_5}" | egrep -i ":N|:Y" | cut -f1 -d ':'               | uniq | sort)
  ASM=$(cat ${ORATAB}              | egrep -i -v "^#|${ORA_HOMES_IGNORE_5}" | egrep -i "+ASM*" | cut -f1 -d ':'               | uniq | sort | wc -l)
  T_MEM=$(free -g -h  | egrep -i "Mem"  | awk '{ print $2 }')
  U_MEM=$(free -g -h  | egrep -i "Mem"  | awk '{ print $3 }')
  F_MEM=$(free -g -h  | egrep -i "Mem"  | awk '{ print $4 }')
  T_SWAP=$(free -g -h | egrep -i "Swap" | awk '{ print $2 }')
  U_SWAP=$(free -g -h | egrep -i "Swap" | awk '{ print $3 }')
  F_SWAP=$(free -g -h | egrep -i "Swap" | awk '{ print $4 }')
  RED="\e[1;31;40m"
  RED="\e[1;31;40m"
  YEL="\e[1;33;40m"
  YEL="\e[1;33;40m"
  BLU="\e[96m"
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
  return 1
fi
#
# ------------------------------------------------------------------------
# Verify ASM
#
if [[ ${ASM} == 0 ]]; then
  ASM_EXISTS="NO"
else
  ASM_EXISTS="YES"
  G_SID=$(cat ${ORATAB}  | egrep -i -v "^#" | egrep -i "+ASM*" | cut -f1 -d ':')
  G_HOME=$(cat ${ORATAB} | egrep -i -v "^#" | egrep -i "+ASM*" | cut -f2 -d ':')
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
function unset_var() {
if [[ $(uname) == "SunOS" ]]; then
  if [[ $(whoami) == "grid" ]]; then
  for U_VAR in ${VARIABLES}; do
    unset ${U_VAR} > /dev/null 2>&1
  done
  export PATH=/usr/local/bin:/bin:/sbin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/grid/.local/bin:/home/grid/bin
  export PS1=$'[ ${LOGNAME}@\h:$(pwd): ]$ '
  umask 0022
  #
  elif [[ $(whoami) == "oracle" ]]; then
  for U_VAR in ${VARIABLES}; do
    unset ${U_VAR} > /dev/null 2>&1
  done
  export PATH=/usr/local/bin:/bin:/sbin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/oracle/.local/bin:/home/oracle/bin
  export PS1=$'[ ${LOGNAME}@\h:$(pwd): ]$ ' 
  umask 0022
  fi
elif [[ $(uname) == "AIX" ]]; then
  if [[ $(whoami) == "grid" ]]; then
  for U_VAR in ${VARIABLES}; do
    unset ${U_VAR} > /dev/null 2>&1
  done
  export PATH=/usr/bin:/usr/sbin:/bin:/sbin:/etc:/usr/bin/X11:/usr/local/bin:/usr/local/sbin:/home/grid/.local/bin:/home/grid/bin
  export PS1=$'[ ${LOGNAME}@\h:$(pwd): ]$ '
  umask 0022
  #
  elif [[ $(whoami) == "oracle" ]]; then
  for U_VAR in ${VARIABLES}; do
    unset ${U_VAR} > /dev/null 2>&1
  done
  export PATH=/usr/bin:/usr/sbin:/bin:/sbin:/etc:/usr/bin/X11:/usr/local/bin:/usr/local/sbin:/home/oracle/.local/bin:/home/oracle/bin
  export PS1=$'[ ${LOGNAME}@\h:$(pwd): ]$ ' 
  umask 0022
  fi
elif [[ $(uname) == "Linux" ]]; then
  if [[ $(whoami) == "grid" ]]; then
  for U_VAR in ${VARIABLES}; do
    unset ${U_VAR} > /dev/null 2>&1
  done
  export PATH=/usr/local/bin:/bin:/sbin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/grid/.local/bin:/home/grid/bin
  export PS1=$'[ ${LOGNAME}@\h:$(pwd): ]$ '
  umask 0022
  #
  elif [[ $(whoami) == "oracle" ]]; then
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
function unalias_var() {
for UN_ALIAS in ${ALIASES}; do
  unalias ${UN_ALIAS} > /dev/null 2>&1
done
}
#
# ------------------------------------------------------------------------
# Alias and Setting OS
#
function alias_var() {
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
}
#
# ------------------------------------------------------------------------
# Show Database Info
#
function get_INFO() {
if [[ ${ORACLE_SID} == "" ]]; then
  echo " -- YOUR ENVIRONMENT DOES NOT HAVE CONFIGURED YET --"
  return 0
elif [[ $(ps -ef | egrep -i "pmon" | egrep -i "${ORACLE_SID}" | awk '{ print $NF }' | sed s/ora_pmon_//g | wc -l) == 0 ]]; then
  echo " -- YOUR ENVIRONMENT: ${ORACLE_SID} IS OFFLINE --"
  return 0
else
sqlplus -S '/ as sysdba' <<EOF
@${DBNITRO}/Oracle_SQL_DBA_Info.sql
quit;
EOF
fi
}
#
# ------------------------------------------------------------------------
# Show Database Options Usage Statistics
#
function get_OPTIONS() {
if [[ ${ORACLE_SID} == "" ]]; then
  echo " -- YOUR ENVIRONMENT DOES NOT HAVE CONFIGURED YET --"
  return 0
elif [[ $(ps -ef | egrep -i "pmon" | egrep -i "${ORACLE_SID}" | awk '{ print $NF }' | sed s/ora_pmon_//g | wc -l) == 0 ]]; then
  echo " -- YOUR ENVIRONMENT: ${ORACLE_SID} IS OFFLINE --"
  return 0
else
sqlplus -S '/ as sysdba' <<EOF
@${DBNITRO}/Oracle_SQL_Options_Packs_Usage_Statistics.sql
quit;
EOF
fi
}
#
# ------------------------------------------------------------------------
# Create Database Report
#
function get_REPORT() {
if [[ ${ORACLE_SID} == "" ]]; then
  echo " -- YOUR ENVIRONMENT DOES NOT HAVE CONFIGURED YET --"
  return 0
elif [[ $(ps -ef | egrep -i "pmon" | egrep -i "${ORACLE_SID}" | awk '{ print $NF }' | sed s/ora_pmon_//g | wc -l) == 0 ]]; then
  echo " -- YOUR ENVIRONMENT: ${ORACLE_SID} IS OFFLINE --"
  return 0
else
sqlplus -S '/ as sysdba' <<EOF
@${DBNITRO}/Oracle_SQL_Report_v.3.0.1.sql
quit;
EOF
fi
}
#
# ------------------------------------------------------------------------
# Setting GLOGIN Functions
#
function set_GLOGIN() {
if [[ ! -f ${DBNITRO}/.glogin.sql ]]; then
cat > ${DBNITRO}/.glogin.sql <<EOF
set pages 700 lines 700 timing on time on colsep '|' trim on trims on numformat 999999999999999 heading on feedback on
COLUMN NAME FORMAT A20
COLUMN VALUE FORMAT A40
COLUMN USERNAME FORMAT A30
COLUMN PROFILE FORMAT A20
COLUMN FILE_NAME FORMAT A80
SET SQLPROMPT '&_user@&_connect_identifier> '
DEFINE _EDITOR=vi
EOF
fi
}
#
# ------------------------------------------------------------------------
# Setting PDB GLOGIN Functions
#
function set_GLOGIN_PDB() {
if [[ ! -f ${DBNITRO}/.glogin_pdb.sql ]]; then
cat > ${DBNITRO}/.glogin_pdb.sql <<EOF
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
SET SQLPROMPT '&gname> '
EOF
fi
}
#
# ------------------------------------------------------------------------
# Check and Set the GoldenGate Environment
#
function set_OGG() {
if [[ ${ORACLE_SID} == "" ]]; then
  echo " -- YOUR ENVIRONMENT DOES NOT HAVE CONFIGURED YET --"
  return 0
elif [[ $(ps -ef | egrep -i "pmon" | egrep -i "${ORACLE_SID}" | awk '{ print $NF }' | sed s/ora_pmon_//g | wc -l) == 0 ]]; then
  echo " -- YOUR ENVIRONMENT: ${ORACLE_SID} IS OFFLINE --"
  return 0
else
OGG_STATUS=$(
{
  echo 'set pagesize 0 linesize 32767 feedback off verify off heading off echo off timing off;'
  echo 'show parameter enable_goldengate_replication;'
} | sqlplus -S / as sysdba
)
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
function set_PDB() {
if [[ ${ORACLE_SID} == "" ]]; then
  echo " -- YOUR ENVIRONMENT DOES NOT HAVE CONFIGURED YET --"
  return 0
elif [[ $(ps -ef | egrep -i "pmon" | egrep -i "${ORACLE_SID}" | awk '{ print $NF }' | sed s/ora_pmon_//g | wc -l) == 0 ]]; then
  echo " -- YOUR ENVIRONMENT: ${ORACLE_SID} IS OFFLINE --"
  return 0
else
#
VERSION=$(
{
  echo 'set pagesize 0 linesize 32767 feedback off verify off heading off echo off timing off;'
  echo 'select substr(version,1,2) as version from v$instance;'
} | sqlplus -S / as sysdba
)
#
CONTAINER=$(
{
  echo 'set pagesize 0 linesize 32767 feedback off verify off heading off echo off timing off;'
  echo 'select cdb from v$database;'
} | sqlplus -S / as sysdba
)
#
PLUGGABLES=$(
{
  echo 'set pagesize 0 linesize 32767 feedback off verify off heading off echo off timing off;'
  echo 'select count(NAME) from v$containers where con_id not in (0,1,2);'
} | sqlplus -S / as sysdba
)
fi
#
# ------------------------------------------------------------------------
# Verify the Version, CDB and PDB of the Database
#
if [[ ${VERSION} < 12 ]]; then
  echo " -- YOUR ENVIRONMENT DOES NOT HAVE CONTAINER TECHNOLOGY --"
  return 0
elif [[ ${CONTAINER} == "NO" ]]; then
  echo " -- YOUR ENVIRONMENT DOES NOT HAVE CONTAINER TECHNOLOGY CONFIGURED YET --"
  return 0
elif [[ ${PLUGGABLES} == 0 ]]; then
  echo " -- YOUR ENVIRONMENT DOES NOT HAVE PLUGGABLE DATABASES YET --"
  return 0
else
sqlplus -S '/ as sysdba' > ${DBNITRO}/.Pluggable.${ORACLE_SID}.var <<EOF | tail -2
set define off trims on newp none heads off echo off feed off numwidth 20 pagesize 0 null null verify off wrap off timing off serveroutput off termout off heading off
select name from v\$containers where con_id not in (0,1,2) order by 1;
quit;
EOF
fi
#
# ------------------------------------------------------------------------
# Select the CDB and PDB
#
echo "Options: "
select PDBS in $(cat ${DBNITRO}/.Pluggable.${ORACLE_SID}.var) "BACK TO CDB" QUIT; do
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
  export PS1=$'[ ${ORACLE_SID} ]|[ ${ORACLE_PDB_SID} ]|[ ${LOGNAME}@\h:$(pwd): ]$ '
  return 1
fi
done
}
#
# ------------------------------------------------------------------------
# Set Oracle Home
#
function set_HOME() {
unset_var
unalias_var
alias_var
local OPT=$1
export ORACLE_HOSTNAME="${HOST}"
export ORACLE_HOME="${OPT}"
export ORACLE_BASE="$(${ORACLE_HOME}/bin/orabase)"
export TFA_HOME="${ORACLE_HOME}/suptools/tfa/release/tfa_home"
export OCK_HOME="${ORACLE_HOME}/suptools/orachk"
export BASE="${ORACLE_BASE}"
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
  export PATH=${PATH}:${ORACLE_HOME}/bin:${OPATCH}:${GRID_HOME}/bin:${ORACLE_HOME}/perl/bin:${JAVA_HOME}/bin:${TFA_HOME}/bin:${OCK_HOME}/
  export HOME_ADR=$(echo 'set base ${GRID_BASE}; show homes' | adrci | egrep -i "+ASM*")
  export HOME_ADR_CRS=$(echo 'set base ${GRID_BASE}; show homes' | adrci | egrep -i "crs")
  export ALERTASM="${GRID_BASE}/${HOME_ADR}/trace/alert_+ASM*.log"
  export ALERTCRS="${GRID_BASE}/${HOME_ADR_CRS}/trace/alert.log"
  alias trc='cd ${ORACLE_BASE}/${HOME_ADR}/trace'
  alias asmlog='tail -f -n 100 ${ALERTASM} | egrep -i -v ${IGNORE_ERRORS}'
  alias crslog='tail -f -n 100 ${ALERTCRS} | egrep -i -v ${IGNORE_ERRORS}'
  alias res='crsctl stat res -t'
  alias rest='crsctl stat res -t -init'
  alias resp='crsctl stat res -p -init'
  alias asmcmd='rlwrap asmcmd'
  alias a='rlwrap asmcmd -p'
  alias rac-status='${DBNITRO}/rac-status.sh -a'
  alias asmdu='${DBNITRO}/asmdu.sh -g'
else
  export LD_LIBRARY_PATH=/lib:/usr/lib:/usr/lib64:${ORACLE_HOME}/lib:${ORACLE_HOME}/perl/lib:${ORACLE_HOME}/hs/lib
  export CLASSPATH=${ORACLE_HOME}/JRE:${ORACLE_HOME}/jlib:${ORACLE_HOME}/rdbms/jlib
  export PATH=${PATH}:${ORACLE_HOME}/bin:${OPATCH}:${ORACLE_HOME}/perl/bin:${JAVA_HOME}/bin:${TFA_HOME}/bin:${OCK_HOME}/
fi
export TNS_ADMIN="${ORACLE_HOME}/network/admin"
export ALERTLST="$(lsnrctl status | egrep -i "Listener Log File" | awk '{ print $4 }' | awk '{ print $1 }' | awk '{gsub("/alert/log.xml", "");print}')/trace/listener.log"
alias lsnlog='tail -f -n 100 ${ALERTLST} | egrep -i -v ${IGNORE_ERRORS}'
alias oh='cd ${ORACLE_HOME}'
alias dbs='cd ${ORACLE_HOME}/dbs'
alias tns='cd ${ORACLE_HOME}/network/admin'
alias tfa='cd ${ORACLE_HOME}/suptools/tfa/release/tfa_home'
alias ock='${OCK_HOME}/orachk'
alias sqlplus='rlwrap sqlplus'
alias s='rlwrap sqlplus / as sysdba @${DBNITRO}/.glogin.sql'
alias adrci='rlwrap adrci'
alias ad='rlwrap adrci'
alias p='ps -ef | egrep pmon | egrep -v egrep'
alias t='rlwrap lsnrctl'
alias l='rlwrap lsnrctl status'
#
OWNER=$(ls -l ${ORACLE_HOME} | awk '{ print $3 }' | egrep -v -i "root" | egrep -Ev "^$" | uniq)
#
if [[ ! -f ${ORACLE_HOME}/install/orabasetab ]]; then
  HOME_RW=$(echo "${RED} RW ${BLA}")
else
  HOME_STATUS=$(cat ${ORACLE_HOME}/install/orabasetab | egrep -i ":N|:Y" | cut -f4 -d ':' | uniq)
  if [[ ${HOME_STATUS} == "Y" ]]; then
    HOME_RW=$(echo "${GRE} RO ${BLA}")
  elif [[ ${HOME_STATUS} == "N" ]]; then
    HOME_RW=$(echo "${RED} RW ${BLA}")
  fi
fi
#
LSNRCTL=$(ps -ef | egrep -i "tnslsnr" | egrep -v "grep" | wc -l)
if [[ "${LSNRCTL}" != 0 ]]; then
  DB_LISTNER=$(echo "${GRE} ONLINE ${BLA}")
else
  DB_LISTNER=$(echo "${RED} OFFLINE ${BLA}")
fi
SetClear
SepLine
echo -e "# UPTIME: [${RED} ${UPTIME} ${BLA}] | BASE: [${BLU} ${ORACLE_BASE} ${BLA}] | HOME: [${BLU} ${ORACLE_HOME} ${BLA}] | RW_RO: [${HOME_RW}] | ONWER: [${RED} ${OWNER} ${BLA}]"
echo -e "# LISTENER: [${DB_LISTNER}] | MEMORY: [${BLU} ${T_MEM} ${BLA}] | USED: [${RED} ${U_MEM} ${BLA}] | FREE: [${GRE} ${F_MEM} ${BLA}] | SWAP: [${BLU} ${T_SWAP} ${BLA}] | USED: [${RED} ${U_SWAP} ${BLA}] | FREE: [${GRE} ${F_SWAP} ${BLA}]"
SepLine
#
export PS1=$'[ HOME ]|[ ${LOGNAME}@\h:$(pwd): ]$ '
umask 0022
}
#
function set_ASM() {
unset_var
unalias_var
alias_var
set_GLOGIN
source ${DBNITRO}/.Oracle_ASM_Functions
source ${DBNITRO}/.Oracle_RAC_Functions
source ${DBNITRO}/.Oracle_EXA_Functions
source ${DBNITRO}/.Oracle_ODG_Functions
source ${DBNITRO}/.Oracle_ASM_Functions
source ${DBNITRO}/.Oracle_ODA_Functions
local OPT=$1
export ORACLE_HOSTNAME="${HOST}"
export ORACLE_TERM=xterm
export ORACLE_SID="${OPT}"
export ORACLE_HOME="${G_HOME}"
export ORACLE_BASE="$(${ORACLE_HOME}/bin/orabase)"
export GRID_HOME="${ORACLE_HOME}"
export GRID_SID="${OPT}"
export TFA_HOME="${ORACLE_HOME}/suptools/tfa/release/tfa_home"
export OCK_HOME="${ORACLE_HOME}/suptools/orachk"
export BASE="${ORACLE_BASE}"
export OH="${ORACLE_HOME}"
export DBS="${ORACLE_HOME}/dbs"
export TNS="${ORACLE_HOME}/network/admin"
export TFA="${TFA_HOME}"
export OCK="${OCK_HOME}"
export OPATCH="${ORACLE_HOME}/OPatch"
export JAVA_HOME="${ORACLE_HOME}/jdk"
export LD_LIBRARY_PATH=/lib:/usr/lib:/usr/lib64:${ORACLE_HOME}/lib:${ORACLE_HOME}/perl/lib:${ORACLE_HOME}/hs/lib
export CLASSPATH=${ORACLE_HOME}/JRE:${ORACLE_HOME}/jlib:${ORACLE_HOME}/rdbms/jlib
export PATH=${PATH}:${ORACLE_HOME}/bin:${OPATCH}:${ORACLE_HOME}/perl/bin:${JAVA_HOME}/bin:${TFA_HOME}/bin:${OCK_HOME}/
export HOME_ADR=$(echo 'set base ${ORACLE_BASE}; show homes' | adrci | egrep -i "+ASM*")
export HOME_ADR_CRS=$(echo 'set base ${ORACLE_BASE}; show homes' | adrci | egrep -i "crs")
export TNS_ADMIN="${ORACLE_HOME}/network/admin"
export ALERTASM="${ORACLE_BASE}/${HOME_ADR}/trace/alert_+ASM*.log"
export ALERTCRS="${ORACLE_BASE}/${HOME_ADR_CRS}/trace/alert.log"
export ALERTLST="$(lsnrctl status | egrep -i "Listener Log File" | awk '{ print $4 }' | awk '{ print $1 }' | awk '{gsub("/alert/log.xml", "");print}')/trace/listener.log"
alias trc='cd ${ORACLE_BASE}/${HOME_ADR}/trace'
alias asmlog='tail -f -n 100 ${ALERTASM} | egrep -i -v ${IGNORE_ERRORS}'
alias crslog='tail -f -n 100 ${ALERTCRS} | egrep -i -v ${IGNORE_ERRORS}'
alias lsnlog='tail -f -n 100 ${ALERTLST} | egrep -i -v ${IGNORE_ERRORS}'
alias vlog='vim ${ALERTASM}'
alias res='crsctl stat res -t'
alias rest='crsctl stat res -t -init'
alias resp='crsctl stat res -p -init'
alias rac-status='${DBNITRO}/rac-status.sh -a'
alias asmdu='${DBNITRO}/asmdu.sh -g'
alias asmcmd='rlwrap asmcmd'
alias a='rlwrap asmcmd -p'
alias oh='cd ${ORACLE_HOME}'
alias dbs='cd ${ORACLE_HOME}/dbs'
alias tns='cd ${ORACLE_HOME}/network/admin'
alias tfa='cd ${ORACLE_HOME}/suptools/tfa/release/tfa_home'
alias ock='${OCK_HOME}/orachk'
alias sqlplus='rlwrap sqlplus'
alias s='rlwrap sqlplus / as sysasm @${DBNITRO}/.glogin.sql'
alias adrci='rlwrap adrci'
alias ad='rlwrap adrci'
alias p='ps -ef | egrep pmon | egrep -v egrep'
alias t='rlwrap lsnrctl'
alias l='rlwrap lsnrctl status'
#
if [[ ! -f ${ORACLE_HOME}/install/orabasetab ]]; then
  HOME_RW=$(echo "${RED} RW ${BLA}")
else
  HOME_STATUS=$(cat ${ORACLE_HOME}/install/orabasetab | egrep -i ":N|:Y" | cut -f4 -d ':' | uniq)
  if [[ ${HOME_STATUS} == "Y" ]]; then
    HOME_RW=$(echo "${GRE} RO ${BLA}")
  elif [[ ${HOME_STATUS} == "N" ]]; then
    HOME_RW=$(echo "${RED} RW ${BLA}")
  fi
fi
#
PROC=$(ps -ef | egrep -i "pmon" | egrep -i "${ORACLE_SID}" | awk '{ print $NF }' | sed s/asm_pmon_//g)
if [[ "${PROC[@]}" =~ "${ORACLE_SID}"* ]]; then
  DB_STATUS=$(echo "${GRE} ONLINE ${BLA}")
else
  DB_STATUS=$(echo "${RED} OFFLINE ${BLA}")
fi
#
LSNRCTL=$(ps -ef | egrep -i "tnslsnr" | egrep -v "grep" | wc -l)
if [[ "${LSNRCTL}" != 0 ]]; then
  DB_LISTNER=$(echo "${GRE} ONLINE ${BLA}")
else
  DB_LISTNER=$(echo "${RED} OFFLINE ${BLA}")
fi
#
SetClear
SepLine
echo -e "# UPTIME: [${RED} ${UPTIME} ${BLA}] | BASE: [${BLU} ${ORACLE_BASE} ${BLA}] | HOME: [${BLU} ${ORACLE_HOME} ${BLA}] | RW_RO: [${HOME_RW}] | SID: [${RED} ${ORACLE_SID} ${BLA}] | STATUS: [${DB_STATUS}]"
echo -e "# LISTENER: [${DB_LISTNER}] | MEMORY: [${BLU} ${T_MEM} ${BLA}] | USED: [${RED} ${U_MEM} ${BLA}] | FREE: [${GRE} ${F_MEM} ${BLA}] | SWAP: [${BLU} ${T_SWAP} ${BLA}] | USED: [${RED} ${U_SWAP} ${BLA}] | FREE: [${GRE} ${F_SWAP} ${BLA}]"
SepLine
#
export PS1=$'[ ${ORACLE_SID} ]|[ ${LOGNAME}@\h:$(pwd): ]$ '
umask 0022
}
#
# ------------------------------------------------------------------------
# Set the Database Environment
#
function set_DB() {
unset_var
unalias_var
alias_var
set_GLOGIN
source ${DBNITRO}/.Oracle_DBA_Functions
source ${DBNITRO}/.Oracle_RAC_Functions
source ${DBNITRO}/.Oracle_EXA_Functions
source ${DBNITRO}/.Oracle_ODG_Functions
source ${DBNITRO}/.Oracle_OGG_Functions
source ${DBNITRO}/.Oracle_STR_Functions
source ${DBNITRO}/.Oracle_PDB_Functions
source ${DBNITRO}/.Oracle_ASM_Functions
source ${DBNITRO}/.Oracle_ODA_Functions
source ${DBNITRO}/.Oracle_WALL_Functions
source ${DBNITRO}/.Oracle_RMAN_Functions
local OPT=$1
export ORACLE_HOSTNAME="${HOST}"
export ORACLE_TERM=xterm
export ORACLE_SID="${OPT}"
export ORACLE_HOME=$(cat ${ORATAB} | egrep "${ORACLE_SID}" | cut -f2 -d ':')
export ORACLE_BASE="$(${ORACLE_HOME}/bin/orabase)"
export TFA_HOME="${ORACLE_HOME}/suptools/tfa/release/tfa_home"
export OCK_HOME="${ORACLE_HOME}/suptools/orachk"
export BASE="${ORACLE_BASE}"
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
  export GRID_HOME=${G_HOME}
  export GRID_BASE="$(${GRID_HOME}/bin/orabase)"
  export LD_LIBRARY_PATH=/lib:/usr/lib:/usr/lib64:${ORACLE_HOME}/lib:${GRID_HOME}/lib:${ORACLE_HOME}/perl/lib:${GRID_HOME}/perl/lib:${ORACLE_HOME}/hs/lib
  export CLASSPATH=${ORACLE_HOME}/JRE:${ORACLE_HOME}/jlib:${ORACLE_HOME}/rdbms/jlib:${GRID_HOME}/jlib:${GRID_HOME}/rdbms/jlib
  export PATH=${PATH}:${ORACLE_HOME}/bin:${OPATCH}:${GRID_HOME}/bin:${ORACLE_HOME}/perl/bin:${JAVA_HOME}/bin:${TFA_HOME}/bin:${OCK_HOME}/
  alias res='crsctl stat res -t'
  alias rest='crsctl stat res -t -init'
  alias resp='crsctl stat res -p -init'
  alias rac-status='${DBNITRO}/rac-status.sh -a'
  alias asmdu='${DBNITRO}/asmdu.sh -g'
  alias asmcmd='rlwrap asmcmd'
  alias a='rlwrap asmcmd -p'
else
  export LD_LIBRARY_PATH=/lib:/usr/lib:/usr/lib64:${ORACLE_HOME}/lib:${ORACLE_HOME}/perl/lib:${ORACLE_HOME}/hs/lib
  export CLASSPATH=${ORACLE_HOME}/JRE:${ORACLE_HOME}/jlib:${ORACLE_HOME}/rdbms/jlib
  export PATH=${PATH}:${ORACLE_HOME}/bin:${OPATCH}:${ORACLE_HOME}/perl/bin:${JAVA_HOME}/bin:${TFA_HOME}/bin:${OCK_HOME}/
fi
#
export TNS_ADMIN="${ORACLE_HOME}/network/admin"
export HOME_ADR=$(echo 'set base ${ORACLE_BASE}; show homes' | adrci | egrep -w "${OPT}")
export ORACLE_UNQNAME=$(echo ${HOME_ADR} | cut -f4 -d '/')
export ALERTDB="${ORACLE_BASE}/${HOME_ADR}/trace/alert_${ORACLE_SID}.log"
export ALERTDG="${ORACLE_BASE}/${HOME_ADR}/trace/drc*.log"
export ALERTLST="$(lsnrctl status | egrep -i "Listener Log File" | awk '{ print $4 }' | awk '{ print $1 }' | awk '{gsub("/alert/log.xml", "");print}')/trace/listener.log"
alias trc='cd ${ORACLE_BASE}/${HOME_ADR}/trace'
alias lsnlog='tail -f -n 100 ${ALERTLST} | egrep -i -v ${IGNORE_ERRORS}'
alias vlog='vim ${ALERTDB}'
alias base='cd ${ORACLE_BASE}'
alias oh='cd ${ORACLE_HOME}'
alias dbs='cd ${ORACLE_HOME}/dbs'
alias tns='cd ${ORACLE_HOME}/network/admin'
alias tfa='cd ${ORACLE_HOME}/suptools/tfa/release/tfa_home'
alias ock='${OCK_HOME}/orachk'
alias dblog='tail -f -n 100 ${ALERTDB} | egrep -i -v ${IGNORE_ERRORS}'
alias dglog='tail -f -n 100 ${ALERTDG} | egrep -i -v ${IGNORE_ERRORS}'
alias sqlplus='rlwrap sqlplus'
alias s='rlwrap sqlplus / as sysdba @${DBNITRO}/.glogin.sql'
alias rman='rlwrap rman'
alias r='rlwrap rman target /'
alias dgmgrl='rlwrap dgmgrl'
alias d='rlwrap dgmgrl /'
alias adrci='rlwrap adrci'
alias ad='rlwrap adrci'
alias p='ps -ef | egrep pmon | egrep -v egrep'
alias t='rlwrap lsnrctl'
alias l='rlwrap lsnrctl status'
alias orat='${ORATOP}/oratop -f -i 10 / as sysdba'
alias pdb='set_PDB'
alias ogg='set_OGG'
alias INFO='get_INFO'
alias REPORT='get_REPORT'
alias OPTIONS='get_OPTIONS'
#
if [[ ! -f ${ORACLE_HOME}/install/orabasetab ]]; then
  HOME_RW=$(echo "${RED} RW ${BLA}")
else
  HOME_STATUS=$(cat ${ORACLE_HOME}/install/orabasetab | egrep -i ":N|:Y" | cut -f4 -d ':' | uniq)
  if [[ ${HOME_STATUS} == "Y" ]]; then
    HOME_RW=$(echo "${GRE} RO ${BLA}")
  elif [[ ${HOME_STATUS} == "N" ]]; then
    HOME_RW=$(echo "${RED} RW ${BLA}")
  fi
fi
#
PROC=$(ps -ef | egrep -i "pmon" | egrep -i "${ORACLE_SID}" | awk '{ print $NF }' | sed s/ora_pmon_//g)
if [[ "${PROC[@]}" =~ "${ORACLE_SID}"* ]]; then
  DB_STATUS=$(echo "${GRE} ONLINE ${BLA}")
else
  DB_STATUS=$(echo "${RED} OFFLINE ${BLA}")
fi
#
LSNRCTL=$(ps -ef | egrep -i "tnslsnr" | egrep -v "grep" | wc -l)
if [[ "${LSNRCTL}" != 0 ]]; then
  DB_LISTNER=$(echo "${GRE} ONLINE ${BLA}")
else
  DB_LISTNER=$(echo "${RED} OFFLINE ${BLA}")
fi
#
SetClear
SepLine
echo -e "# UPTIME: [${RED} ${UPTIME} ${BLA}] | BASE: [${BLU} ${ORACLE_BASE} ${BLA}] | HOME: [${BLU} ${ORACLE_HOME} ${BLA}] | RW_RO: [${HOME_RW}] | SID: [${RED} ${ORACLE_SID} ${BLA}] | STATUS: [${DB_STATUS}]"
echo -e "# LISTENER: [${DB_LISTNER}] | MEMORY: [${BLU} ${T_MEM} ${BLA}] | USED: [${RED} ${U_MEM} ${BLA}] | FREE: [${GRE} ${F_MEM} ${BLA}] | SWAP: [${BLU} ${T_SWAP} ${BLA}] | USED: [${RED} ${U_SWAP} ${BLA}] | FREE: [${GRE} ${F_SWAP} ${BLA}]"
SepLine
#
export PS1=$'[ ${ORACLE_SID} ]|[ ${LOGNAME}@\h:$(pwd): ]$ '
umask 0022
}
#
# ------------------------------------------------------------------------
# Set the OMS Home
#
function set_OMS() {
unset_var
unalias_var
alias_var
local OPT=$1
export ORACLE_HOSTNAME="${HOST}"
export ORACLE_HOME="${OPT}"
export OH="${ORACLE_HOME}"
export OPATCH="${ORACLE_HOME}/OPatch"
export JAVA_HOME="${ORACLE_HOME}/jdk"
export CLASSPATH=${ORACLE_HOME}/jlib
export LD_LIBRARY_PATH=/lib:/usr/lib:/usr/lib64:${ORACLE_HOME}/lib:${ORACLE_HOME}/perl/lib:${ORACLE_HOME}/instantclient
export PATH=${PATH}:${ORACLE_HOME}/bin:${OPATCH}:${ORACLE_HOME}/perl/bin:${JAVA_HOME}/bin
alias oh='cd ${ORACLE_HOME}'
alias p='ps -ef | egrep pmon | egrep -v egrep' # ???
#
OWNER=$(ls -l ${ORACLE_HOME} | awk '{ print $3 }' | egrep -i -v "root" | egrep -Ev "^$" | uniq)
#
OMS_STATUS=$(ps -ef | egrep -i "wlserver" | egrep -v "grep" | wc -l)
if [[ "${OMS_STATUS}" != 0 ]]; then
  OMS=$(echo "${GRE} ONLINE ${BLA}")
else
  OMS=$(echo "${RED} OFFLINE ${BLA}")
fi
#
SetClear
SepLine
echo -e "# UPTIME: [${RED} ${UPTIME} ${BLA}] | HOME: [${BLU} ${ORACLE_HOME} ${BLA}] | ONWER: [${RED} ${OWNER} ${BLA}] | OMS STATUS: [${OMS}]"
echo -e "# MEMORY: [${BLU} ${T_MEM} ${BLA}] | USED: [${RED} ${U_MEM} ${BLA}] | FREE: [${GRE} ${F_MEM} ${BLA}] | SWAP: [${BLU} ${T_SWAP} ${BLA}] | USED: [${RED} ${U_SWAP} ${BLA}] | FREE: [${GRE} ${F_SWAP} ${BLA}]"
SepLine
#
export PS1=$'[ OMS ]|[ ${LOGNAME}@\h:$(pwd): ]$ '
umask 0022
}
#
# ------------------------------------------------------------------------
# Set AGENT Home
#
function set_AGENT() {
unset_var
unalias_var
alias_var
# SET HOME
local OPT=$1
export ORACLE_HOSTNAME="${HOST}"
export ORACLE_HOME="${OPT}"
export OH="${ORACLE_HOME}"
export OPATCH="${ORACLE_HOME}/OPatch"
export JAVA_HOME="${ORACLE_HOME}/jdk"
export CLASSPATH=${ORACLE_HOME}/jlib
export LD_LIBRARY_PATH=/lib:/usr/lib:/usr/lib64:${ORACLE_HOME}/lib:${ORACLE_HOME}/perl/lib:${ORACLE_HOME}/instantclient
export PATH=${PATH}:${ORACLE_HOME}/bin:${OPATCH}:${ORACLE_HOME}/perl/bin:${JAVA_HOME}/bin
alias oh='cd ${ORACLE_HOME}'
alias adrci='rlwrap adrci'
alias ad='rlwrap adrci'
alias p='ps -ef | egrep pmon | egrep -v egrep' # ???
#
OWNER=$(ls -l ${ORACLE_HOME} | awk '{ print $3 }' | egrep -i -v "root" | egrep -Ev "^$" | uniq)
#
AGENT_STATUS=$(ps -ef | egrep -i "agent" | egrep -v "grep" | wc -l)
if [[ "${AGENT_STATUS}" != 0 ]]; then
  AGENT=$(echo "${GRE} ONLINE ${BLA}")
else
  AGENT=$(echo "${RED} OFFLINE ${BLA}")
fi
#
SetClear
SepLine
echo -e "# UPTIME: [${RED} ${UPTIME} ${BLA}] | HOME: [${BLU} ${ORACLE_HOME} ${BLA}] | ONWER: [${RED} ${OWNER} ${BLA}] | AGENT STATUS: [${AGENT}] "
echo -e "# MEMORY: [${BLU} ${T_MEM} ${BLA}] | USED: [${RED} ${U_MEM} ${BLA}] | FREE: [${GRE} ${F_MEM} ${BLA}] | SWAP: [${BLU} ${T_SWAP} ${BLA}] | USED: [${RED} ${U_SWAP} ${BLA}] | FREE: [${GRE} ${F_SWAP} ${BLA}]"
SepLine
#
export PS1=$'[ AGENT ]|[ ${LOGNAME}@\h:$(pwd): ]$ '
umask 0022
}
#
# ------------------------------------------------------------------------
#
# Main Menu
#
function MainMenu() {
PS3="Select the Option: "
select OPT in ${ORA_HOMES} ${ORA_OMS} ${ORA_AGENT} ${DBLIST} QUIT; do
if [[ "${OPT}" == "QUIT" ]]; then
  echo " -- Exit Menu --"
  return 1
elif [[ "${OPT}" == "+ASM"* ]]; then
  if [[ "${ASM_USER}" == "YES" ]]; then
    set_ASM ${OPT}
  else
    echo " -- ASM USER IS DIFFERENT AS ORACLE USER --"
    echo " -- YOU MUST CONNECT AS OS USER: ${ASM_OWNER} --"
    continue
  fi
elif [[ "${ORA_HOMES[@]}" =~ "${OPT}" ]] && [[ "${OPT}" != "" ]]; then
  set_HOME ${OPT}
elif [[ "${ORA_OMS[@]}" =~ "${OPT}" ]] && [[ "${OPT}" != "" ]]; then
  set_OMS ${OPT}
elif [[ "${ORA_AGENT[@]}" =~ "${OPT}" ]] && [[ "${OPT}" != "" ]]; then
  set_AGENT ${OPT}
elif [[ "${DBLIST[@]}" =~ "${OPT}" ]] && [[ "${OPT}" != "" ]]; then
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
