#!/bin/bash
Author="Andre Augusto Ribas"
SoftwareVersion="1.0.11"
DateCreation="07/01/2021"
DateModification="26/01/2021"
EMAIL_1="dba.ribas@gmail.com"
EMAIL_2="andre.ribas@icloud.com"
WEBSITE="dbnitro.net"
#
# Verify ROOT User
#
if [[ $(whoami) = "root" ]]; then
  clear
  echo "----------------------------------------------------------------------------------"
  echo " -- YOUR USER IS ROOT, YOU CAN NOT USE THIS SCRIPT WITH ROOT USER --"
  echo " -- PLEASE USE OTHER USER TO ACCESS THIS SCRIPTS --"
  exit 1
fi
#
# Verify ORACLE_BASE
#
export ORACLE_BASE="/u01/app/oracle"
if [[ ! -d ${ORACLE_BASE} ]]; then
  clear
  echo "----------------------------------------------------------------------------------"
  echo " -- YOU DO NOT HAVE THE ORACLE_BASE CONFIGURED --"
  echo " -- PLEASE CHECK YOUR CONFIGURATION --"
  exit 1
fi
#
# Verify oraInst.loc file
#
ORA_INST="/etc/oraInst.loc"
if [[ ! -f ${ORA_INST} ]]; then
  clear
  echo "----------------------------------------------------------------------------------"
  echo " -- THIS SERVER DOES NOT HAVE AN ORACLE INSTALLATION YET --"
  exit 1
fi
#
# Set ORACLE Inventory
#
ORA_INVENTORY=$(cat ${ORA_INST} | grep -i "inventory_loc" | cut -f2 -d '=')
#
# Verify INVENTORY HOMEs
#
ORA_HOMES_IGNORE="REMOVED|REFHOME|DEPHOME|PLUGINS|/usr/lib/oracle/sbin"
ORA_HOMES=$(cat ${ORA_INVENTORY}/ContentsXML/inventory.xml | egrep -i -v "${ORA_HOMES_IGNORE}" | grep -i "LOC" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq)
#
# Unsetting and Setting OS and ORATAB Variables
#
function unset_var()
{
for U_VAR in PATH ORACLE_HOSTNAME ORACLE_TERM ORACLE_HOME_ADR ADRCI_HOME ORACLE_UNQNAME ORACLE_SID ORACLE_HOME GRID_HOME OGG_HOME TFA_HOME OCK_HOME BASE OWNER OH DBS TNS OGG TFA OCK ORATOP OPATCH JAVA_HOME LD_LIBRARY_PATH CLASSPATH ALERTDB ALERTDG ALERTGG ALERTASM; do
  unset ${U_VAR} > /dev/null 2>&1
done
export PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/oracle/.local/bin:/home/oracle/bin
export PS1=$'[ ${LOGNAME}@\h:$(pwd): ]$ '
}
#
function unalias_var()
{
for U_ALIAS in rest res base oh dbs tns ogg tfa ock dblog dglog gglog asmlog sqlplus s asmcmd a rman r dgmgrl d adrci ad oggsci o p tns t l orat; do
  unalias ${U_ALIAS} > /dev/null 2>&1
done
}
#
# Verify OS Parameters
#
if [[ $(uname) = "SunOS" ]]; then
  OS="Solaris"
  ORATAB="/var/opt/oracle/oratab"
  TMP="/tmp"
  TMPDIR="${TMP}"
  HOST=$(hostname)
  UPTIME=$(uptime | sed 's/.*up \([^,]*\), .*/\1/')
  RED="\033[1;31m"
  YEL="\033[1;33m"
  BLU="\033[1;34m"
  GRE="\033[1;32m"
  BLA="\033[m"
elif [[ $(uname) = "AIX" ]]; then
  OS="AIX"
  ORATAB="/var/opt/oracle/oratab"
  TMP="/tmp"
  TMPDIR="${TMP}"
  HOST=$(hostname)
  UPTIME=$(uptime | sed 's/.*up \([^,]*\), .*/\1/')
  RED="\033[1;31m"
  YEL="\033[1;33m"
  BLU="\033[1;34m"
  GRE="\033[1;32m"
  BLA="\033[m"
elif [[ $(uname) = "Linux" ]]; then
  OS="Linux"
  ORATAB="/etc/oratab"
  TMP="/tmp"
  TMPDIR="${TMP}"
  HOST=$(hostname)
  UPTIME=$(uptime | sed 's/.*up \([^,]*\), .*/\1/')
  RED="\e[1;31;40m"
  RED="\e[1;31;40m"
  YEL="\e[1;33;40m"
  YEL="\e[1;33;40m"
  BLU="\e[1;34;40m"
  GRE="\e[1;32;40m"
  BLA="\e[0m"
fi
#
# Verify ORATAB
#
if [[ ! -f ${ORATAB} ]]; then
  clear
  echo "----------------------------------------------------------------------------------"
  echo " -- YOU DO NOT HAVE THE ORATAB CONFIGURED --"
  echo " -- PLEASE CHECK YOUR CONFIGURATION --"
  exit 1
fi
#
# Verify ASM
#
if [[ $(cat ${ORATAB} | egrep ':N|:Y' | grep -i "+ASM*" | egrep -v -i '+apx|-mgmtdb' | cut -f1 -d ':' | uniq | wc -l) = 0 ]]; then
  # ASM DO NOT EXISTS
  ASM_EXISTS="NO"
else
  # ASM EXISTS
  ASM_EXISTS="YES"
  G_SID=$(cat ${ORATAB} | grep -i "+ASM*" | cut -f1 -d ':')
  G_HOME=$(cat ${ORATAB} | grep -i "+ASM*" | cut -f2 -d ':')
  #
  ASM_OWNER=$(ls -l ${GRID_HOME} | awk '{ print $3 }' | grep -v -i "root" | grep -Ev "^$" | uniq)
  if [[ "${ASM_OWNER}" = $(whoami) ]]; then
    # ASM IS ON THE ORACLE USER
    ASM_USER="YES"
  else
    # ASM IS NOT ON THE ORACLE USER
    ASM_USER="NO"
  fi
fi
#
# Setting Variables
#
DBLIST=$(cat ${ORATAB} | egrep ':N|:Y' | egrep -v -i '+apx|-mgmtdb' | cut -f1 -d ':' | uniq)
#
# Setting Functions
#
function set_GLOGIN()
{
cat > /tmp/.glogin.sql <<EOF
set pages 700 lines 700 timing on time on colsep '|' trim on trims on numformat 999999999999999 heading on feedback on
COLUMN NAME FORMAT A20
COLUMN VALUE FORMAT A40
COLUMN FILE_NAME FORMAT A80
SET SQLPROMPT '&_user@&_connect_identifier> '
DEFINE _EDITOR=vi
EOF
}
#
function set_HOME()
{
  # Unset and Unalias
  unset_var
  unalias_var
  # Set GLOGIN
  set_GLOGIN
  # SET HOME
  local OPT=$1
  export ORACLE_HOSTNAME="${HOST}"
  export ORACLE_BASE="${ORACLE_BASE}"
  export ORACLE_HOME="${OPT}"
  export OGG_HOME="${ORACLE_BASE}/product/ogg_19c"
  export TFA_HOME="${ORACLE_HOME}/suptools/tfa/release/tfa_home"
  export OCK_HOME="${ORACLE_HOME}/suptools/orachk/orachk"
  export BASE="${ORACLE_BASE}"
  export OH="${ORACLE_HOME}"
  export DBS="${ORACLE_HOME}/dbs"
  export TNS="${ORACLE_HOME}/network/admin"
  export OGG="${OGG_HOME}"
  export TFA="${TFA_HOME}"
  export OCK="${OCK_HOME}"
  export ORATOP="${ORACLE_HOME}/suptools/oratop"
  export OPATCH="${ORACLE_HOME}/OPatch"
  export JAVA_HOME="${ORACLE_HOME}/jdk"
  if [[ "${ASM_EXISTS}" = "YES" ]]; then
    export GRID_HOME=${G_HOME}
    export LD_LIBRARY_PATH=/lib:/usr/lib:${ORACLE_HOME}/lib:${ORACLE_HOME}/perl/lib
    export CLASSPATH=${ORACLE_HOME}/JRE:${ORACLE_HOME}/jlib:${ORACLE_HOME}/rdbms/jlib
    export PATH=${PATH}:${ORACLE_HOME}/bin:${OPATCH}:${GRID_HOME}/bin:${ORACLE_HOME}/perl/bin:${JAVA_HOME}/bin:${OGG_HOME}:${TFA_HOME}/bin:${OCK_HOME}/
    # Aliases to CRSCTL STATUS
    alias rest='crsctl stat res -t -init'
    alias res='crsctl stat res -t'
    # Aliases to connect on ASMCMD
    alias asmcmd='rlwrap asmcmd'
    alias a='rlwrap asmcmd'
  else
    export LD_LIBRARY_PATH=/lib:/usr/lib:${ORACLE_HOME}/lib:${ORACLE_HOME}/perl/lib
    export CLASSPATH=${ORACLE_HOME}/JRE:${ORACLE_HOME}/jlib:${ORACLE_HOME}/rdbms/jlib
    export PATH=${PATH}:${ORACLE_HOME}/bin:${OPATCH}:${ORACLE_HOME}/perl/bin:${JAVA_HOME}/bin:${OGG_HOME}:${TFA_HOME}/bin:${OCK_HOME}/
  fi
  # Aliases to go to folder
  alias oh='cd ${ORACLE_HOME}'
  alias dbs='cd ${ORACLE_HOME}/dbs'
  alias tns='cd ${ORACLE_HOME}/network/admin'
  alias tfa='cd ${ORACLE_HOME}/suptools/tfa/release/tfa_home'
  alias ock='cd ${ORACLE_HOME}/suptools/orachk/orachk'
  # Aliases to connect on SQLPLUS
  alias sqlplus='rlwrap sqlplus @/tmp/.glogin.sql'
  alias s='rlwrap sqlplus / as sysdba @/tmp/.glogin.sql'
  # Aliases to connect on ADRCI
  alias adrci='rlwrap adrci'
  alias ad='rlwrap adrci'
  # Aliases to check PROCESSES
  alias p='ps -ef | grep pmon | grep -v grep'
  # Aliases to check LSNRCTL
  alias tns='rlwrap lsnrctl'
  alias t='rlwrap lsnrctl'
  alias l='rlwrap lsnrctl status'
  # Aliases to check MEMINFO
  alias meminfo='free -m -l -t'
  # Aliases to check PSMEM
  alias psmem='ps auxf | sort -nr -k 4'
  alias psmem10='ps auxf | sort -nr -k 4 | head -10'
  # Aliases to check PSCPU
  alias pscpu='ps auxf | sort -nr -k 3'
  alias pscpu10='ps auxf | sort -nr -k 3 | head -10'
  # Aliases to check CPUINFO
  alias cpuinfo='lscpu'
  #
  T_MEM=$(free -g -h | grep -i "Mem" | awk '{ print $2 }')
  U_MEM=$(free -g -h | grep -i "Mem" | awk '{ print $3 }')
  F_MEM=$(free -g -h | grep -i "Mem" | awk '{ print $4 }')
  T_SWAP=$(free -g -h | grep -i "Swap" | awk '{ print $2 }')
  U_SWAP=$(free -g -h | grep -i "Swap" | awk '{ print $3 }')
  F_SWAP=$(free -g -h | grep -i "Swap" | awk '{ print $4 }')
  #
  OWNER=$(ls -l ${ORACLE_HOME} | awk '{ print $3 }' | grep -v -i "root" | grep -Ev "^$" | uniq)
  #
  LSNRCTL=$(ps -ef | grep tnslsnr | grep -v "grep" | wc -l)
  if [[ "${LSNRCTL}" != 0 ]]; then
    DB_LISTNER=$(echo "${GRE} ONLINE ${BLA}")
  else
    DB_LISTNER=$(echo "${RED} OFFLINE ${BLA}")
  fi
  clear
  echo "+-----------------------------------------------------------------------------------------------------------------------------------------"
  echo -e "# UPTIME: [${RED} ${UPTIME} ${BLA}] | BASE: [${BLU} ${ORACLE_BASE} ${BLA}] | HOME: [${BLU} ${ORACLE_HOME} ${BLA}] | ONWER: [${RED} ${OWNER} ${BLA}]"
  echo -e "# LISTENER: [${DB_LISTNER}] | MEMORY: [${BLU} ${T_MEM} ${BLA}] | USED: [${RED} ${U_MEM} ${BLA}] | FREE: [${GRE} ${F_MEM} ${BLA}] | SWAP: [${BLU} ${T_SWAP} ${BLA}] | USED: [${RED} ${U_SWAP} ${BLA}] | FREE: [${GRE} ${F_SWAP} ${BLA}]"
  echo "+-----------------------------------------------------------------------------------------------------------------------------------------"
  #
  export PS1=$'[ HOME ]|[ ${LOGNAME}@\h:$(pwd): ]$ '
  umask 0022
}
#
function set_ASM_USER()
{
  echo " -- ASM USER IS DIFFERENT AS ORACLE USER --"
  echo " -- YOU MUST CONNECT AS OS USER: ${ASM_OWNER} --"
}
#
function set_ASM()
{
  # Unset and Unalias
  unset_var
  unalias_var
  # Set GLOGIN
  set_GLOGIN
  # SET ASM/GRID
  local OPT=$1
  export ORACLE_HOSTNAME="${HOST}"
  export ORACLE_BASE="${ORACLE_BASE}"
  export ORACLE_TERM=xterm
  export ORACLE_SID="${OPT}"
  export ORACLE_HOME="${G_HOME}"
  export GRID_HOME="${G_HOME}"
  export GRID_SID="${OPT}"
  export TFA_HOME="${ORACLE_HOME}/suptools/tfa/release/tfa_home"
  export OCK_HOME="${ORACLE_HOME}/suptools/orachk/orachk"
  export BASE="${ORACLE_BASE}"
  export OH="${ORACLE_HOME}"
  export DBS="${ORACLE_HOME}/dbs"
  export TNS="${ORACLE_HOME}/network/admin"
  export TFA="${TFA_HOME}"
  export OCK="${OCK_HOME}"
  export ORATOP="${ORACLE_HOME}/suptools/oratop"
  export OPATCH="${ORACLE_HOME}/OPatch"
  export JAVA_HOME="${ORACLE_HOME}/jdk"
  export LD_LIBRARY_PATH=/lib:/usr/lib:${ORACLE_HOME}/lib:${ORACLE_HOME}/perl/lib
  export CLASSPATH=${ORACLE_HOME}/JRE:${ORACLE_HOME}/jlib:${ORACLE_HOME}/rdbms/jlib
  export PATH=${PATH}:${ORACLE_HOME}/bin:${OPATCH}:${ORACLE_HOME}/perl/bin:${JAVA_HOME}/bin:${TFA_HOME}/bin:${OCK_HOME}/
  export HOME_ADR=$(echo "show homes" | adrci | grep "${OPT}")
  export ALERTASM="${ORACLE_BASE}/${HOME_ADR}/trace/alert_${GRID_SID}.log"
  # Aliases to CRSCTL STATUS
  alias rest='crsctl stat res -t -init'
  alias res='crsctl stat res -t'
  # Aliases to connect on ASMCMD
  alias asmcmd='rlwrap asmcmd'
  alias a='rlwrap asmcmd'
  # Aliases to go to folder
  alias oh='cd ${ORACLE_HOME}'
  alias dbs='cd ${ORACLE_HOME}/dbs'
  alias tns='cd ${ORACLE_HOME}/network/admin'
  alias tfa='cd ${ORACLE_HOME}/suptools/tfa/release/tfa_home'
  alias ock='cd ${ORACLE_HOME}/suptools/orachk/orachk'
  # Aliases to tail LOGS
  alias asmlog='tail -f ${ALERTASM}'
  # Aliases to connect on SQLPLUS
  alias sqlplus='rlwrap sqlplus'
  alias s='rlwrap sqlplus / as sysasm @/tmp/.glogin.sql'
  # Aliases to connect on ADRCI
  alias adrci='rlwrap adrci'
  alias ad='rlwrap adrci'
  # Aliases to check PROCESSES
  alias p='ps -ef | grep pmon | grep -v grep'
  # Aliases to check LSNRCTL
  alias tns='rlwrap lsnrctl'
  alias t='rlwrap lsnrctl'
  alias l='rlwrap lsnrctl status'
  # Aliases to connect on ORATOP
  alias orat='${ORATOP}/oratop -f -i 10 / as sysasm'
  # Aliases to check MEMINFO
  alias meminfo='free -m -l -t'
  # Aliases to check PSMEM
  alias psmem='ps auxf | sort -nr -k 4'
  alias psmem10='ps auxf | sort -nr -k 4 | head -10'
  # Aliases to check PSCPU
  alias pscpu='ps auxf | sort -nr -k 3'
  alias pscpu10='ps auxf | sort -nr -k 3 | head -10'
  # Aliases to check CPUINFO
  alias cpuinfo='lscpu'
  #
  T_MEM=$(free -g -h | grep -i "Mem" | awk '{ print $2 }')
  U_MEM=$(free -g -h | grep -i "Mem" | awk '{ print $3 }')
  F_MEM=$(free -g -h | grep -i "Mem" | awk '{ print $4 }')
  T_SWAP=$(free -g -h | grep -i "Swap" | awk '{ print $2 }')
  U_SWAP=$(free -g -h | grep -i "Swap" | awk '{ print $3 }')
  F_SWAP=$(free -g -h | grep -i "Swap" | awk '{ print $4 }')
  #
  PROC=$(ps -ef | grep pmon | grep -i "${ORACLE_SID}" | awk '{ print $NF }' | sed s/asm_pmon_//g)
  if [[ "${PROC[@]}" =~ "${ORACLE_SID}"* ]]; then
    DB_STATUS=$(echo "${GRE} ONLINE ${BLA}")
  else
    DB_STATUS=$(echo "${RED} OFFLINE ${BLA}")
  fi
  #
  LSNRCTL=$(ps -ef | grep tnslsnr | grep -v "grep" | wc -l)
  if [[ "${LSNRCTL}" != 0 ]]; then
    DB_LISTNER=$(echo "${GRE} ONLINE ${BLA}")
  else
    DB_LISTNER=$(echo "${RED} OFFLINE ${BLA}")
  fi
  #
  clear
  echo "+-----------------------------------------------------------------------------------------------------------------------------------------"
  echo -e "# UPTIME: [${RED} ${UPTIME} ${BLA}] | BASE: [${BLU} ${ORACLE_BASE} ${BLA}] | HOME: [${BLU} ${ORACLE_HOME} ${BLA}] | SID: [${RED} ${ORACLE_SID} ${BLA}] | STATUS: [${DB_STATUS}]"
  echo -e "# LISTENER: [${DB_LISTNER}] | MEMORY: [${BLU} ${T_MEM} ${BLA}] | USED: [${RED} ${U_MEM} ${BLA}] | FREE: [${GRE} ${F_MEM} ${BLA}] | SWAP: [${BLU} ${T_SWAP} ${BLA}] | USED: [${RED} ${U_SWAP} ${BLA}] | FREE: [${GRE} ${F_SWAP} ${BLA}]"
  echo "+-----------------------------------------------------------------------------------------------------------------------------------------"
  #
  export PS1=$'[ ${ORACLE_SID} ]|[ ${LOGNAME}@\h:$(pwd): ]$ '
  umask 0022
}
#
function set_DB()
{
  # Unset and Unalias
  unset_var
  unalias_var
  # Set GLOGIN
  set_GLOGIN
  # SET DATABASE
  local OPT=$1
  export ORACLE_HOSTNAME="${HOST}"
  export ORACLE_TERM=xterm
  export ORACLE_UNQNAME=$(echo ${HOME_ADR} | cut -f4 -d '/')
  export ORACLE_SID="${OPT}"
  export ORACLE_BASE="${ORACLE_BASE}"
  export ORACLE_HOME=$(cat ${ORATAB} | grep "${OPT}" | cut -f2 -d ':')
  export OGG_HOME="${ORACLE_BASE}/product/ogg_19c"
  export TFA_HOME="${ORACLE_HOME}/suptools/tfa/release/tfa_home"
  export OCK_HOME="${ORACLE_HOME}/suptools/orachk/orachk"
  export BASE="${ORACLE_BASE}"
  export OH="${ORACLE_HOME}"
  export DBS="${ORACLE_HOME}/dbs"
  export TNS="${ORACLE_HOME}/network/admin"
  export OGG="${OGG_HOME}"
  export TFA="${TFA_HOME}"
  export OCK="${OCK_HOME}"
  export ORATOP="${ORACLE_HOME}/suptools/oratop"
  export OPATCH="${ORACLE_HOME}/OPatch"
  export JAVA_HOME="${ORACLE_HOME}/jdk"
  if [[ "${ASM_EXISTS}" = "YES" ]]; then
    export GRID_HOME="${G_HOME}"
    export LD_LIBRARY_PATH=/lib:/usr/lib:${ORACLE_HOME}/lib:${GRID_HOME}/lib:${ORACLE_HOME}/perl/lib:${GRID_HOME}/perl/lib
    export CLASSPATH=${ORACLE_HOME}/JRE:${ORACLE_HOME}/jlib:${ORACLE_HOME}/rdbms/jlib:${GRID_HOME}/jlib:${GRID_HOME}/rdbms/jlib
    export PATH=${PATH}:${ORACLE_HOME}/bin:${OPATCH}:${GRID_HOME}/bin:${ORACLE_HOME}/perl/bin:${JAVA_HOME}/bin:${OGG_HOME}:${TFA_HOME}/bin:${OCK_HOME}/
	export HOME_ADR=$(echo "show homes" | adrci | grep "${OPT}")
    # Aliases to CRSCTL STATUS
    alias rest='crsctl stat res -t -init'
    alias res='crsctl stat res -t'
    # Aliases to connect on ASMCMD
    alias asmcmd='rlwrap asmcmd'
    alias a='rlwrap asmcmd'
  else
    export LD_LIBRARY_PATH=/lib:/usr/lib:${ORACLE_HOME}/lib:${ORACLE_HOME}/perl/lib
    export CLASSPATH=${ORACLE_HOME}/JRE:${ORACLE_HOME}/jlib:${ORACLE_HOME}/rdbms/jlib
    export PATH=${PATH}:${ORACLE_HOME}/bin:${OPATCH}:${ORACLE_HOME}/perl/bin:${JAVA_HOME}/bin:${OGG_HOME}:${TFA_HOME}/bin:${OCK_HOME}/
	export HOME_ADR=${ORACLE_BASE}$(echo "show homes" | adrci | grep "${OPT}")
  fi
  export ALERTDB="${ORACLE_BASE}/${HOME_ADR}/trace/alert_${ORACLE_SID}.log"
  export ALERTDG="${ORACLE_BASE}/${HOME_ADR}/trace/drc${ORACLE_SID}.log"
  export ALERTGG="${OGG_HOME}/ggserr.log"
  # Aliases to go to folder
  alias base='cd ${ORACLE_BASE}'
  alias oh='cd ${ORACLE_HOME}'
  alias dbs='cd ${ORACLE_HOME}/dbs'
  alias tns='cd ${ORACLE_HOME}/network/admin'
  alias ogg='cd ${ORACLE_BASE}/product/ogg_19c'
  alias tfa='cd ${ORACLE_HOME}/suptools/tfa/release/tfa_home'
  alias ock='cd ${ORACLE_HOME}/suptools/orachk/orachk'
  # Aliases to tail LOGS
  alias dblog='tail -f ${ALERTDB}'
  alias dglog='tail -f ${ALERTDG}'
  alias gglog='tail -f ${ALERTGG}'
  # Aliases to connect on SQLPLUS
  alias sqlplus='rlwrap sqlplus'
  alias s='rlwrap sqlplus / as sysdba @/tmp/.glogin.sql'
  # Aliases to connect on RMAN
  alias rman='rlwrap rman'
  alias r='rlwrap rman target /'
  # Aliases to connect on DGMGRL
  alias dgmgrl='rlwrap dgmgrl'
  alias d='rlwrap dgmgrl /'
  # Aliases to connect on ADRCI
  alias adrci='rlwrap adrci'
  alias ad='rlwrap adrci'
  # Aliases to connect on GGSCI
  alias oggsci='rlwrap ${OGG_HOME}/ggsci'
  alias o='rlwrap ${OGG_HOME}/ggsci'
  # Aliases to check PROCESSES
  alias p='ps -ef | grep pmon | grep -v grep'
  # Aliases to check LSNRCTL
  alias tns='rlwrap lsnrctl'
  alias t='rlwrap lsnrctl'
  alias l='rlwrap lsnrctl status'
  # Aliases to connect on ORATOP
  alias orat='${ORATOP}/oratop -f -i 10 / as sysdba'
  # Aliases to check MEMINFO
  alias meminfo='free -m -l -t'
  # Aliases to check PSMEM
  alias psmem='ps auxf | sort -nr -k 4'
  alias psmem10='ps auxf | sort -nr -k 4 | head -10'
  # Aliases to check PSCPU
  alias pscpu='ps auxf | sort -nr -k 3'
  alias pscpu10='ps auxf | sort -nr -k 3 | head -10'
  # Aliases to check CPUINFO
  alias cpuinfo='lscpu'
  #
  T_MEM=$(free -g -h | grep -i "Mem" | awk '{ print $2 }')
  U_MEM=$(free -g -h | grep -i "Mem" | awk '{ print $3 }')
  F_MEM=$(free -g -h | grep -i "Mem" | awk '{ print $4 }')
  T_SWAP=$(free -g -h | grep -i "Swap" | awk '{ print $2 }')
  U_SWAP=$(free -g -h | grep -i "Swap" | awk '{ print $3 }')
  F_SWAP=$(free -g -h | grep -i "Swap" | awk '{ print $4 }')
  #
  PROC=$(ps -ef | grep pmon | grep -i "${ORACLE_SID}" | awk '{ print $NF }' | sed s/ora_pmon_//g)
  if [[ "${PROC[@]}" =~ "${ORACLE_SID}"* ]]; then
    DB_STATUS=$(echo "${GRE} ONLINE ${BLA}")
  else
    DB_STATUS=$(echo "${RED} OFFLINE ${BLA}")
  fi
  #
  LSNRCTL=$(ps -ef | grep tnslsnr | grep -v "grep" | wc -l)
  if [[ "${LSNRCTL}" != 0 ]]; then
    DB_LISTNER=$(echo "${GRE} ONLINE ${BLA}")
  else
    DB_LISTNER=$(echo "${RED} OFFLINE ${BLA}")
  fi
  #
  clear
  echo "+-----------------------------------------------------------------------------------------------------------------------------------------"
  echo -e "# UPTIME: [${RED} ${UPTIME} ${BLA}] | BASE: [${BLU} ${ORACLE_BASE} ${BLA}] | HOME: [${BLU} ${ORACLE_HOME} ${BLA}] | SID: [${RED} ${ORACLE_SID} ${BLA}] | STATUS: [${DB_STATUS}]"
  echo -e "# LISTENER: [${DB_LISTNER}] | MEMORY: [${BLU} ${T_MEM} ${BLA}] | USED: [${RED} ${U_MEM} ${BLA}] | FREE: [${GRE} ${F_MEM} ${BLA}] | SWAP: [${BLU} ${T_SWAP} ${BLA}] | USED: [${RED} ${U_SWAP} ${BLA}] | FREE: [${GRE} ${F_SWAP} ${BLA}]"
  echo "+-----------------------------------------------------------------------------------------------------------------------------------------"
  #
  export PS1=$'[ ${ORACLE_SID} ]|[ ${LOGNAME}@\h:$(pwd): ]$ '
  umask 0022
}
#
# Main Menu
#
function MainMenu()
{
PS3="Select the Option: "
select OPT in ${ORA_HOMES} ${DBLIST} QUIT; do
if [[ "${OPT}" = "QUIT" ]]; then
  # Exit Menu
  echo " -- Exit Menu --"
elif [[ "${OPT}" == "+ASM"* ]]; then
  if [[ "${ASM_USER}" = "YES" ]]; then
    # Set ASM
    set_ASM ${OPT}
  else
    # ASM NOT SET
    set_ASM_USER
    continue
  fi
elif [[ "${ORA_HOMES[@]}" =~ "${OPT}" ]] && [[ "${OPT}" != "" ]]; then
  # Set HOME
  set_HOME ${OPT}
elif [[ "${DBLIST[@]}" =~ "${OPT}" ]] && [[ "${OPT}" != "" ]]; then
  # Set DATABASE
  set_DB ${OPT}
else
  echo " -- Invalid Option --"
  continue
fi
break
done
}
MainMenu
