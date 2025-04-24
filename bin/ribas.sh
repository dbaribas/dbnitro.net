#!/bin/sh
#!/usr/bin/perl
#
#########################################################################################################
#
Author="Andre Augusto Ribas"
SoftwareVersion="4.1.1"
DateOfCreation="07/09/2013"
DateOfModification="12/12/2022"
EMAIL="ribas@dbnitro.net"
GITHUB="https://github.com/dbaribas/dbnitro.net"
WEBSITE="http://dbnitro.net"
#
#########################################################################################################
# Standard Folders
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
#
#########################################################################################################
# Source Functions
#
for FUNC in $(ls ${FUNCTIONS}/*_Functions); do 
  source ${FUNC}
done
#
#########################################################################################################
#
# Separate Line Function
#
SepLine() {
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' - 
}
#
# Load Function
#
Load() {
  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "Load Process" --gauge "Load Process" 7 50 >&2
}
#
# Continue Function
#
Continue() {
  echo ""
  SepLine
  echo "Press Enter to Continue"
  read
  Load
}
#
#########################################################################################################
#
# dialog --infobox "Processing, please wait" 3 34 ; sleep 5
#
# "-------------------------------------------------------------------------------------------------------------"
# set -x                                                                         # Debug
# "-------------------------------------------------------------------------------------------------------------"
#
# Verify if the DIALOG exists on the Server OS
#
if [[ -z $(which dialog | egrep -v "grep|egrep") ]]; then
  clear
  SepLine
  echo " -- YOUR ENVIRONMENT DOES NOT HAVE THE DIALOG SOFTWARE, PLEASE INSTALL DIALOG AND TRY AGAIN --"
  SepLine
  exit 1
fi
#
#########################################################################################################
# Setting General Variables
#########################################################################################################
#
varOS=""                                       # Which Operation System
varOSDISTRO=""                                 # Operation System Distribution
varIP_ADDR_ALL=""                              # IP Address of First Adapter
varIP_ADDR=""                                  # IP Address of First Adapter
varKERNEL=""                                   # Operation System Kernel
varPhysical_CPU=""                             # Physical CPUs
varPhysical_CPUS=""                            # Server CPUs
varProc_FAMILY=""                              # Processor Family
varProc_TYPE=""                                # Processor Type
varTotal_MEMORY=""                             # Server Physical Memory (TOTAL)
varDisk_Usage=""                               #
varDisk_Infos=""                               #
varUsed_MEMORY=""                              # Server Physical Memory Used
varFree_MEMORY=""                              # Server Physical Memory Free
varSwap_MEMORY=""                              # Server Swap Memory (TOTAL)
varSwap_USED_MEMORY=""                         # Server Swap Memory Used
varSwap_Free_MEMORY=""                         # Server Swap Memory Free
varARCHITECTUREECTURE=""                       # Server Architecture         # Architecture:          x86_64
varCPU_OP_MODE_MODE=""                         # Server CPU Operation Mode   # CPU op-mode(s):        32-bit, 64-bit
varBytes_ORDER=""                              # Server Byte Order           # Byte Order:            Little Endian
varTHREADS=""                                  # Server Threads per CORE     # Thread(s) per core:    1
varCORES=""                                    # Server Cores per Sockets    # Core(s) per socket:    2
varSOCKETS=""                                  # Server CPUs Sockets         # CPU socket(s):         2
varVENDOR=""                                   # Server Vendor               # Vendor ID:             GenuineIntel
varCPU_FAMILY=""                               # Server CPU Family           # CPU family:            6
varMODEL=""                                    # Server Model                # Model:                 37
varCPU_MHZ=""                                  # Server CPU MHZ              # CPU MHz:               2663.778
varHOST=""                                     # Hostname of the Server
varRED=""                                      # Red Color
varYEL=""                                      # Yellow Color
varBLUE=""                                     # Blue Color
varGREEN=""                                    # Green Color
varBLACK=""                                    # Finish Color
varECHO=""                                     # Echo Option -e
varWHOAMI=""                                   # If is ROOT or Not
varSLEEP=""                                    # Sleep Command
varUPTIME=""                                   # SERVER UPTIME
varSRVHARDWARE=""                              # Hardware Verification Physical or Virtual
varSRVMEMBANK=""                               # Hardware Verification Memory
varSRVDISKS=""                                 # Hardware Verification Disk
varSRVTEMPERATURE=""                           # Hardware Verification Temperature
varWARNING=""                                  #
varCRITICAL=""                                 #
DIALOG_CANCEL="1"                              # 
DIALOG_ESC="255"                               # 
HEIGHT=0                                       # 
WIDTH=0                                        # 
ORATAB=""                                      # ORATAB has the Instances Names and Oracle Homes
#
#########################################################################################################
#
if [[ $(uname) = "SunOS" ]]; then
  varOS="Solaris"
  varOSDISTRO="SUN Solaris"
  varIP_ADDR_ALL=$(ifconfig)
  varIP_ADDR=$(ifconfig | egrep inet | awk '{ print $2 }' | head -2 | egrep -v 127.0.0.1 | head -1)
  varIP_ADDR=$(ip a | egrep -v -i "inet6|link|127.0.0.1|lo:" | egrep "inet" | awk '{ print $2 }' | head -1)
  varUPTIME=$(uptime | sed 's/.*up \([^,]*\), .*/\1/')
  varKERNEL=$(uname -r)
  varPhysical_CPU=$(/usr/sbin/psrinfo -p)
  varPhysical_CPUS=$(/usr/bin/kstat -m cpu_info | egrep "chip_id|core_id|module: cpu_info" | egrep cpu_info | wc -l | tr -d ' ')
  varProc_FAMILY=$(/usr/bin/kstat -m cpu_info | egrep brand | awk '{ print $2, '' $3, '' $4, '' $5, '' $6 }' | tail -1)
  varProc_TYPE=$(/usr/bin/kstat -m cpu_info | egrep fpu_type | awk '{ print $2, '' $3 }' | tail -1)
  varTotal_MEMORY=$(/usr/sbin/prtconf | egrep "Memory size:" | head | awk '{ foo = $3/1024; print foo "G"}' | egrep .[0-9]* | head -2 | tail -1)
  varDisk_Usage=$(df -h)
  varDisk_Infos=$(lsblk)
  varUsed_MEMORY=$(/usr/bin/prstat -Z 1 1 | tail -2 | awk '{print $4}' | head -1)
  varFree_MEMORY=$(/usr/bin/kstat -p unix:0:system_pages:freemem | awk '{ print $2 }' | awk '{ foo = $1/1024/1024 ; print foo "M" }')
  varSwap_MEMORY=$(df -kh swap | grep swap | awk '{ print $2 }')
  varSwap_USED_MEMORY=$(df -kh swap | egrep swap | awk '{ print $3 }')
  varSwap_Free_MEMORY=$(df -kh swap | egrep swap | awk '{ print $4 }')
  varARCHITECTURE=""
  varCPU_OP_MODE=""
  varBytes_ORDER=""
  varTHREADS=""
  varCORES=$(/usr/sbin/psrinfo -pv | grep "physical processor" | head -1 | awk '{ print $5 }')
  varSOCKETS=$(/usr/sbin/psrinfo -pv | grep "The physical processor has" | wc -l)
  varVENDOR=$(/usr/sbin/psrinfo -pv | grep "CPU" | head -1 | awk '{ print $1 }')
  varCPU_FAMILY=$(/usr/sbin/psrinfo -pv | grep "CPU" | head -1 | awk '{ print $2 }')
  varMODEL=$(/usr/sbin/psrinfo -pv | grep "CPU" | head -1 | awk '{ print $4 }')
  varCPU_MHZ=$(/usr/sbin/psrinfo -pv | grep "CPU" | head -1 | awk '{ print $7 }')
  varHOST=$(hostname)
  varRED="[\033[1;31m"
  varYEL="[\033[1;33m"
  varBLUE="[\033[1;34m"
  varGREEN="[\033[1;32m"
  varBLACK="\033[m]"
  varECHO=" -e "
  varWHOAMI=$(whoami)
  varSLEEP=""
  varWARNING=85
  varCRITICAL=95
  ORATAB="/var/opt/oracle/oratab"
#########################################################################################################
elif [[ $(uname) = "AIX" ]]; then
  varOS="AIX"
  varOSDISTRO="IBM AIX"
  varIP_ADDR_ALL=$(ifconfig)
  varIP_ADDR=$(ifconfig | egrep inet | awk '{ print $2 }' | head -2 | egrep -v 127.0.0.1 | head -1)
  varIP_ADDR=$(ip a | egrep -v -i "inet6|link|127.0.0.1|lo:" | egrep "inet" | awk '{ print $2 }' | head -1)
  varUPTIME=$(uptime | sed 's/.*up \([^,]*\), .*/\1/')
  varKERNEL=$(oslevel)
  varDF_STATUS=$(df -h | awk '{ print $5 }' | sed s/%//)
  varPhysical_CPU=""
  varPhysical_CPUS=$(pmcycles -m | wc -l)
  varProc_FAMILY=""
  varProc_TYPE=""
  varTotal_MEMORY=$(svmon | egrep memory | awk '{ print $2 }')
  varDisk_Usage=$(df -g)
  varDisk_Infos=$(lsblk)
  varUsed_MEMORY=$(svmon | egrep memory | awk '{ print $3 }')
  varFree_MEMORY=$(svmon | egrep memory | awk '{ print $4 }')
  varSwap_MEMORY=$(lsps -s | awk '{ print $1 }' | tail -1)
  varSwap_USED_MEMORY=$(lsps -s | awk '{ print $1 }' | tail -1)
  varSwap_Free_MEMORY=$(lsps -s | awk '{ print $1 }' | tail -1)
  varARCHITECTURE=""
  varCPU_OP_MODE=""
  varBytes_ORDER=""
  varTHREADS=""
  varCORES=""
  varSOCKETS=""
  varVENDOR=""
  varCPU_FAMILY=""
  varMODEL=""
  varCPU_MHZ=""
  varHOST=$(hostname)
  varRED="[\033[1;31m"
  varYEL="[\033[1;33m"
  varBLUE="[\033[1;34m"
  varGREEN="[\033[1;32m"
  varBLACK="\033[m]"
  varECHO=" -e "
  varWHOAMI=$(whoami)
  varSLEEP=""
  varWARNING=85
  varCRITICAL=95
  ORATAB="/etc/oratab"
#########################################################################################################
elif [[ $(uname) = "HP-UX" ]]; then
  varOS="HP-UX"
  varOSDISTRO="HP-UX"
  varIP_ADDR_ALL=$(ifconfig)
  varIP_ADDR=$(ifconfig | egrep inet | awk '{ print $2 }' | head -2 | egrep -v 127.0.0.1 | head -1)
  varIP_ADDR=$(ip a | egrep -v -i "inet6|link|127.0.0.1|lo:" | egrep "inet" | awk '{ print $2 }' | head -1)
  varUPTIME=$(uptime | sed 's/.*up \([^,]*\), .*/\1/')
  varKERNEL=$(oslevel)
  varDF_STATUS=$(df -h | awk '{ print $5 }' | sed s/%//)
  varPhysical_CPU=""
  varPhysical_CPUS=$(pmcycles -m | wc -l)
  varProc_FAMILY=""
  varProc_TYPE=""
  varTotal_MEMORY=$(svmon | egrep memory | awk '{ print $2 }')
  varDisk_Usage=$(df -g)
  varDisk_Infos=$(lsblk)
  varUsed_MEMORY=$(svmon | egrep memory | awk '{ print $3 }')
  varFree_MEMORY=$(svmon | egrep memory | awk '{ print $4 }')
  varSwap_MEMORY=$(lsps -s | awk '{ print $1 }' | tail -1)
  varSwap_USED_MEMORY=$(lsps -s | awk '{ print $1 }' | tail -1)
  varSwap_Free_MEMORY=$(lsps -s | awk '{ print $1 }' | tail -1)
  varARCHITECTURE=""
  varCPU_OP_MODE=""
  varBytes_ORDER=""
  varTHREADS=""
  varCORES=""
  varSOCKETS=""
  varVENDOR=""
  varCPU_FAMILY=""
  varMODEL=""
  varCPU_MHZ=""
  varHOST=$(hostname)
  varRED="[\033[1;31m"
  varYEL="[\033[1;33m"
  varBLUE="[\033[1;34m"
  varGREEN="[\033[1;32m"
  varBLACK="\033[m]"
  varECHO=" -e "
  varWHOAMI=$(whoami -m | awk '{ print $1 }')
  varSLEEP=""
  varWARNING=85
  varCRITICAL=95
  ORATAB="/var/opt/oracle/oratab"
#########################################################################################################
elif [[ $(uname) = "Linux" ]]; then
  varOS="Linux"
  varOSDISTRO=$(cat /etc/*-release | tail -1)
  varIP_ADDR_ALL=$(ifconfig)
  varIP_ADDR=$(ifconfig | egrep inet | awk '{ print $2 }' | head -2 | egrep -v 127.0.0.1 | head -1)
  varIP_ADDR=$(ip a | egrep -v -i "inet6|link|127.0.0.1|lo:" | egrep "inet" | awk '{ print $2 }' | head -1)
  varUPTIME=$(uptime | sed 's/.*up \([^,]*\), .*/\1/')
  varKERNEL=$(uname -r | cut -c -1,2,3,4,5,6)
  varDF_STATUS=$(df -h | awk '{ print $5 }' | sed s/%//)
  varPhysical_CPU=$(cat /proc/cpuinfo | egrep "physical id" | sort -u | wc -l)
  varPhysical_CPUS=$(cat /proc/cpuinfo | egrep processor | wc -l)
  varProc_FAMILY=$(cat /proc/cpuinfo | egrep vendor_id | tail -1 | awk '{ print $3 }')
  varProc_TYPE=$(cat /proc/cpuinfo | egrep "model name" | tail -1 | awk '{ print $4, $5, $6, $7, $8, $9 }')
  varTotal_MEMORY=$(free -g | egrep Mem | awk '{ print $2 }')
  varDisk_Usage=$(df -h)
  varDisk_Infos=$(lsblk)
  varUsed_MEMORY=$(free -h -m | egrep Mem | awk '{ print $3 }')
  varFree_MEMORY=$(free -h -m | egrep Mem | awk '{ print $4 }')
  varSwap_MEMORY=$(free -h -g | egrep Swap | awk '{ print $2 }')
  varSwap_USED_MEMORY=$(free -h -m | egrep Swap | awk '{ print $3 }')
  varSwap_Free_MEMORY=$(free -h -m | egrep Swap | awk '{ print $4 }')
  varARCHITECTURE=$(lscpu | egrep Architecture | awk '{ print $2 }')
  varCPU_OP_MODE=$(lscpu | egrep "CPU op-mode(s)" | awk '{ print $3, $4 }')
  varBytes_ORDER=$(lscpu | egrep "Byte Order" | awk '{ print $3, $4 }')
  varTHREADS=$(lscpu | egrep "Thread(s) per core" | awk '{ print $4 }')
  varCORES=$(lscpu | egrep "Core(s) per socket" | awk '{ print $4 }')
  varSOCKETS=$(lscpu | egrep "CPU socket(s)" | awk '{ print $3 }')
  varSOCKETS=$(lscpu | egrep "Socket(s)" | awk '{ print $2 }')
  varVENDOR=$(lscpu | egrep "Vendor" | awk '{ print $3 }')
  varCPU_FAMILY=$(lscpu | egrep "CPU family:" | awk '{ print $3 }')
  varMODEL=$(lscpu | egrep "Model" | awk '{ print $2 }')
  varCPU_MHZ=$(lscpu | egrep "CPU MHz:" | awk '{ print $3 }')
  varARCHITECTURE=$(cat /proc/cpuinfo | egrep "cache_alignment" | awk '{ print $3 }' | tail -1)
  varCPU_OP_MODE=$(cat /proc/cpuinfo | egrep "cache_alignment" | awk '{ print "32-bit, " $3"-bit" }' | tail -1)
  varCORES=$(cat /proc/cpuinfo | egrep "cpu cores" | awk '{ print $4 }' | tail -1)
  varVENDOR=$(cat /proc/cpuinfo | egrep "vendor_id" | awk '{ print $3 }' | tail -1)
  varCPU_FAMILY=$(cat /proc/cpuinfo | egrep "cpu family" | awk '{ print $4 }' | tail -1)
  varCPU_MHZ=$(cat /proc/cpuinfo | egrep "cpu MHz" | awk '{ print $4 }' | tail -1)
  varHOST=$(hostname)
  varRED="[\e[1;31;40m"
  varYEL="[\e[1;33;40m"
  varBLUE="[\e[1;34;40m"
  varGREEN="[\e[1;32;40m"
  varBLACK="\e[0m]"
  varECHO=" -e "
  varWHOAMI=$(whoami)
  varSLEEP=""
  varWARNING=85
  varCRITICAL=95
  ORATAB="/etc/oratab"
#########################################################################################################
else
  varOS="Unknown"
  varOSDISTRO="Unknown OS"
  varIP_ADDR_ALL=$(ifconfig)
  varIP_ADDR=$(ifconfig | egrep inet | awk '{ print $2 }' | head -2 | egrep -v 127.0.0.1 | head -1)
  varIP_ADDR=$(ip a | egrep -v -i "inet6|link|127.0.0.1|lo:" | egrep "inet" | awk '{ print $2 }' | head -1)
  varUPTIME=$(uptime | sed 's/.*up \([^,]*\), .*/\1/')
  varKERNEL=$(uname -r)
  varDF_STATUS=$(df -h | awk '{ print $5 }' | sed s/%//)
  varPhysical_CPU=""
  varPhysical_CPUS=$(cat /proc/cpuinfo | egrep processor | wc -l)
  varProc_FAMILY=""
  varProc_TYPE=""
  varTotal_MEMORY=$(free -m | egrep Mem | awk '{ print $2 }')
  varDisk_Usage=$(df -h)
  varDisk_Infos=$(lsblk)
  varUsed_MEMORY=""
  varFree_MEMORY=""
  varSwap_MEMORY=""
  varSwap_USED_MEMORY=""
  varSwap_Free_MEMORY=""
  varARCHITECTURE=""
  varCPU_OP_MODE=""
  varBytes_ORDER=""
  varTHREADS=""
  varCORES=""
  varSOCKETS=""
  varVENDOR=""
  varCPU_FAMILY=""
  varMODEL=""
  varCPU_MHZ=""
  varHOST=$(hostname)
  varRED="["
  varYEL="["
  varBLUE="["
  varGREEN="["
  varBLACK="]"
  varECHO=" "
  varWHOAMI=$(whoami)
  varSLEEP=""
  varWARNING=85
  varCRITICAL=95
  ORATAB="/etc/oratab"
fi
#
#########################################################################################################
#
if [[ "${varWHOAMI}" == "root" ]]; then
  dialog --backtitle "www.DBNITRO.net" --title "ROOT User" --no-collapse --colors --msgbox "YOUR USER IS ROOT, PLEASE USE AN OTHER USER TO ACCESS THIS SYSTEM" 7 130
  exit 1
fi
#
#########################################################################################################
#
if [[ "${varOS}" == "Unknown" ]]; then
  dialog --backtitle "www.DBNITRO.net" --title "Operation System" --no-collapse --colors --msgbox "THE OPERATION SYSTEM: ${OS} IS NOT SUPPORTED ON THIS SYSTEM" 7 130
  exit 1
fi
#
#########################################################################################################
#
if [[ "${ORACLE_HOME}" == "" ]]; then
  dialog --backtitle "www.DBNITRO.net" --title "ORACLE_HOME" --no-collapse --colors --msgbox "THE ORACLE_HOME VARIABLE IS NOT SET YET, SET THE VARIABLE AND TRY AGAIN" 7 130
  exit 1
fi
#
#########################################################################################################
#
if ! [[ -x ${ORACLE_HOME}/bin/sqlplus ]]; then
  dialog --backtitle "www.DBNITRO.net" --title "ORACLE SQLPLUS" --no-collapse --colors --msgbox "THE ORACLE SQLPLUS NOT WORKING YET, SET THE VARIABLES AND TRY AGAIN" 7 130
  exit 1
fi
#
#########################################################################################################
#
if [[ "${ORACLE_SID}" == "" ]]; then
  dialog --backtitle "www.DBNITRO.net" --title "ORACLE_SID" --no-collapse --colors --msgbox "THE ORACLE_SID VARIABLE IS NOT SET YET, SET THE VARIABLE AND TRY AGAIN" 7 130
  exit 1
fi
#
#########################################################################################################
#
varORA_PROCESS=$(ps -ef | egrep pmon | egrep -i ${ORACLE_SID} | awk '{ print $NF }' | cut -d '_' -f3)
#
if ! [[ "${ORACLE_SID}" == "${varORA_PROCESS}" ]]; then
  dialog --backtitle "www.DBNITRO.net" --title "ORACLE_SID" --no-collapse --colors --msgbox "THE ORACLE_SID VARIABLE IS NOT SET YET, SET THE VARIABLE AND TRY AGAIN" 7 130
  exit 1
fi
#
#########################################################################################################
#
if [[ $(cat ${ORATAB} | egrep "ASM*" | egrep -v "^#" | egrep -v "^$" | egrep -v agent | awk 'BEGIN {FS=":"} { printf("\t%s\n", $2)} ' | uniq | awk '{ print $1 }' | wc -l) == 0 ]]; then
  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "Verifying the GRID_HOME" --gauge "THE GRID_HOME VARIABLE DOES NOT EXIST" 7 70
else
  if [[ "${GRID_HOME}" == "" ]]; then
    for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "Setting the GRID_HOME" --gauge "THE GRID_HOME VARIABLE IS SETTING NOW" 7 70
    #
    GRID_HOME=$(cat ${ORATAB} | egrep "ASM*" | egrep -v "^#" | egrep -v "^$" | egrep -v agent | awk 'BEGIN {FS=":"} { printf("\t%s\n", $2) }' | uniq | awk '{ print $1 }')
    #
    for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "Variable: GRID_HOME" --gauge "THE GRID_HOME VARIABLE IS: ${GRID_HOME}" 7 70
  fi
fi
#
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "Main Menu" --no-collapse --colors --gauge "Open Main Menu" 7 50
#
#########################################################################################################
# Set Main Menu Variables
Func_Set_MainMenu_Var() {
sqlplus -S '/ as sysdba' > ${DBNITRO}/var/MainMenu.${ORACLE_SID}.var <<EOF | tail -2
set define off trims on newp none heads off echo off feed off numwidth 20 pagesize 0 null null verify off wrap off timing off serveroutput off termout off heading off;
alter session set nls_date_format='dd/mm/yyyy';
select 'varDB_RELEASE="' || substr(version,1,2) || '"'                                           from v\$instance;
select case when status in ('OPEN','OPEN READ ONLY') then   'varDB="Y"'   else 'varDB="N"'   end from v\$instance;
select case when count(instance_name) > 0 then              'varASM="Y"'  else 'varASM="N"'  end from v\$asm_client;
select case when value = 'TRUE' then                        'varRAC="Y"'  else 'varRAC="N"'  end from v\$parameter where name = 'cluster_database';
select case when value = 'TRUE' then                        'varODG="Y"'  else 'varODG="N"'  end from v\$parameter where name = 'dg_broker_start';
select case when value = 'TRUE' then                        'varOGG="Y"'  else 'varOGG="N"'  end from v\$parameter where name = 'enable_goldengate_replication';
select case when count(status) > 0 then                     'varWALL="Y"' else 'varWALL="N"' end from v\$encryption_wallet where status = 'AVAILABLE';
select case when count(cell_name) > 0 then                  'varEXA="Y"'  else 'varEXA="N"'  end from v\$cell_state;
quit;
EOF
}
#
#########################################################################################################
# Set Database Variables
Func_Set_Database_11_Var() {
sqlplus -S '/ as sysdba' > ${DBNITRO}/var/Database.${ORACLE_SID}.var <<EOF | tail -2
set define off trims on newp none heads off echo off feed off numwidth 20 pagesize 0 null null verify off wrap off timing off serveroutput off termout off heading off
alter session set nls_date_format='dd/mm/yyyy';
select 'varDB_MODE="'          || status                                                          || '"' from v\$instance;
select 'varDB_VERSION="'       || version                                                         || '"' from v\$instance;
select 'varDB_RELEASE="'       || substr(version,1,2)                                             || '"' from v\$instance;
select 'varDB_EDITION="'       || substr(banner, 21, 18)                                          || '"' from v\$version where banner like 'Oracle%';
select 'varDB_ACTIVE_STATE="'  || active_state                                                    || '"' from v\$instance;
select 'varDB_ROLE="'          || database_role                                                   || '"' from v\$database;
select 'varDB_UNIQ_NAME="'     || value                                                           || '"' from v\$parameter where name = 'db_unique_name';
select 'varDB_SRV_NAME="'      || value                                                           || '"' from v\$parameter where name = 'service_names';
select 'varDB_BLOC_SIZE_K="'   || value                                                           || '"' from v\$parameter where name = 'db_block_size';
select 'varDB_BLOC_SIZE_M="'   || value/1024                                                      || '"' from v\$parameter where name = 'db_block_size';
select 'varDB_MEM_MAX_M="'     || ltrim(to_char(value/1024/1024, '9G999G999D999'))                || '"' from v\$parameter where name = 'memory_max_target';
select 'varDB_MEM_MAX_G="'     || ltrim(to_char(value/1024/1024/1024, '9G999G999D999'))           || '"' from v\$parameter where name = 'memory_max_target';
select 'varDB_MEM_MAX_T="'     || ltrim(to_char(value/1024/1024/1024/1024, '9G999G999D999'))      || '"' from v\$parameter where name = 'memory_max_target';
select 'varDB_MEM_TAR_M="'     || ltrim(to_char(value/1024/1024, '9G999G999D999'))                || '"' from v\$parameter where name = 'memory_target';
select 'varDB_MEM_TAR_G="'     || ltrim(to_char(value/1024/1024/1024, '9G999G999D999'))           || '"' from v\$parameter where name = 'memory_target';
select 'varDB_MEM_TAR_T="'     || ltrim(to_char(value/1024/1024/1024/1024, '9G999G999D999'))      || '"' from v\$parameter where name = 'memory_target';
select 'varDB_SGA_MAX_M="'     || ltrim(to_char(value/1024/1024, '9G999G999D999'))                || '"' from v\$parameter where name = 'sga_max_size';
select 'varDB_SGA_MAX_G="'     || ltrim(to_char(value/1024/1024/1024, '9G999G999D999'))           || '"' from v\$parameter where name = 'sga_max_size';
select 'varDB_SGA_MAX_T="'     || ltrim(to_char(value/1024/1024/1024/1024, '9G999G999D999'))      || '"' from v\$parameter where name = 'sga_max_size';
select 'varDB_SGA_TAR_M="'     || ltrim(to_char(value/1024/1024, '9G999G999D999'))                || '"' from v\$parameter where name = 'sga_target';
select 'varDB_SGA_TAR_G="'     || ltrim(to_char(value/1024/1024/1024, '9G999G999D999'))           || '"' from v\$parameter where name = 'sga_target';
select 'varDB_SGA_TAR_T="'     || ltrim(to_char(value/1024/1024/1024/1024, '9G999G999D999'))      || '"' from v\$parameter where name = 'sga_target';
select 'varDB_PGA_LIM_K="'     || ltrim(to_char(value/1024, '9G999G999D999'))                     || '"' from v\$parameter where name = 'pga_aggregate_limit';
select 'varDB_PGA_LIM_M="'     || ltrim(to_char(value/1024/1024, '9G999G999D999'))                || '"' from v\$parameter where name = 'pga_aggregate_limit';
select 'varDB_PGA_LIM_G="'     || ltrim(to_char(value/1024/1024/1024, '9G999G999D999'))           || '"' from v\$parameter where name = 'pga_aggregate_limit';
select 'varDB_PGA_TAR_K="'     || ltrim(to_char(value/1024, '9G999G999D999'))                     || '"' from v\$parameter where name = 'pga_aggregate_target';
select 'varDB_PGA_TAR_M="'     || ltrim(to_char(value/1024/1024, '9G999G999D999'))                || '"' from v\$parameter where name = 'pga_aggregate_target';
select 'varDB_PGA_TAR_G="'     || ltrim(to_char(value/1024/1024/1024, '9G999G999D999'))           || '"' from v\$parameter where name = 'pga_aggregate_target';
select 'varDB_UPTIME="'        || to_date(startup_time, 'dd/mm/yyyy')                             || '"' from v\$instance;
select 'varDB_UPTIME_D="'      || (select to_date(sysdate, 'dd/mm/yyyy hh24:mi') - to_date(startup_time, 'dd/mm/yyyy hh24:mi') from v\$instance) || '"' from dual;
-- select 'varDB_VER_TIME="'   || to_char(max(action_time), 'dd/mm/yyyy')                         || '"' from DBA_REGISTRY_SQLPATCH where action in ('APPLY','UPGRADE','RU_APPLY');
select 'varDB_VER_TIME="'      || to_char(max(action_time), 'dd/mm/yyyy')                         || '"' from registry\$history where action in ('APPLY','UPGRADE','RU_APPLY');
-- select 'varDB_VER_TIME_D="' || ltrim(lpad(substr(substr(to_char((select sysdate from dual) - (select max(action_time) from DBA_REGISTRY_SQLPATCH where action in ('APPLY','UPGRADE','RU_APPLY'))),3),2), 16, '0'), '0') || '"' from dual;
select 'varDB_VER_TIME_D="'    || ltrim(lpad(substr(substr(to_char((select sysdate from dual) - (select max(action_time) from registry\$history where action in ('APPLY','UPGRADE','RU_APPLY'))),3),2), 16, '0'), '0') || '"' from dual;
select 'varDB_TOT_SIZE_M="'    || ltrim(to_char(sum(bytes)/1024/1024, '9G999G999D999'))           || '"' from (select sum(bytes) bytes from dba_data_files union all select sum(bytes) bytes from dba_temp_files union all select sum(bytes * members) from v\$log union all select sum(block_size * file_size_blks) from v\$controlfile);
select 'varDB_TOT_SIZE_G="'    || ltrim(to_char(sum(bytes)/1024/1024/1024, '9G999G999D999'))      || '"' from (select sum(bytes) bytes from dba_data_files union all select sum(bytes) bytes from dba_temp_files union all select sum(bytes * members) from v\$log union all select sum(block_size * file_size_blks) from v\$controlfile);
select 'varDB_TOT_SIZE_T="'    || ltrim(to_char(sum(bytes)/1024/1024/1024/1024, '9G999G999D999')) || '"' from (select sum(bytes) bytes from dba_data_files union all select sum(bytes) bytes from dba_temp_files union all select sum(bytes * members) from v\$log union all select sum(block_size * file_size_blks) from v\$controlfile);
select 'varDB_CACHE_SIZE_K="'  || ltrim(to_char(value/1024, '9G999G999D999'))                     || '"' from v\$parameter where name = 'db_cache_size';
select 'varDB_CACHE_SIZE_M="'  || ltrim(to_char(value/1024/1024, '9G999G999D999'))                || '"' from v\$parameter where name = 'db_cache_size';
select 'varDB_CACHE_SIZE_G="'  || ltrim(to_char(value/1024/1024/1024, '9G999G999D999'))           || '"' from v\$parameter where name = 'db_cache_size';
select 'varDB_SHARED_POOL_K="' || ltrim(to_char(value/1024, '9G999G999D999'))                     || '"' from v\$parameter where name = 'shared_pool_size';
select 'varDB_SHARED_POOL_M="' || ltrim(to_char(value/1024, '9G999G999D999'))                     || '"' from v\$parameter where name = 'shared_pool_size';
select 'varDB_SHARED_POOL_G="' || ltrim(to_char(value/1024, '9G999G999D999'))                     || '"' from v\$parameter where name = 'shared_pool_size';
select 'varDB_SCN="'           || current_scn                                                     || '"' from v\$DATABASE;
select case when log_mode = 'ARCHIVELOG' then 'varDB_ARCH_MODE="Y"' else 'varDB_ARCH_MODE="N"' end from v\$DATABASE ;
select decode(count(*), 0, 'varDB_PARTITION="N"', 'varDB_PARTITION="Y"') Partitioning from dba_part_tables where owner not in ('SYSMAN', 'SH', 'SYS', 'SYSTEM');
select distinct case when a.DETECTED_USAGES = 0 then 'varDB_SQL_TUNING="N"' else 'varDB_SQL_TUNING="Y"' end from dba_feature_usage_statistics a, v\$instance b where a.name = 'SQL Tuning Advisor' and a.version = b.version;
select case when value = 'TRUE' then 'varDB_SPATIAL="Y"' else 'varDB_SPATIAL=N"' end from v\$option where parameter = 'Spatial';
select distinct case when DETECTED_USAGES = 0 then 'varDB_MULTIMEDIA="N"' else 'varDB_MULTIMEDIA="Y"' end from dba_feature_usage_statistics a, v\$instance b where name  = 'Oracle Multimedia' and a.version = b.version;
select distinct case when DETECTED_USAGES = 0 then 'varDB_TEXT="N"' else 'varDB_TEXT="Y"' end from dba_feature_usage_statistics a, v\$instance b where name  = 'Oracle Text' and a.version = b.version;
select 'varDB_STBY_FILE_MAN="'           || value                  || '"' from v\$parameter where name = 'standby_file_management';
select case when FORCE_LOGGING = 'YES' then 'varDB_FORCE_LOGGING="Y"' else 'varDB_FORCE_LOGGING="N"' end from v\$DATABASE;
select case when FLASHBACK_ON = 'YES' then 'varDB_FLASBBACK_ON="Y"' else 'varDB_FLASBBACK_ON="N"' end from v\$DATABASE;
select 'varDB_FLASH_SIZE_M="'            || ltrim(to_char(space_limit/1024/1024, '9G999G999D999'))           || '"' from v\$recovery_file_dest;
select 'varDB_FLASH_SIZE_G="'            || ltrim(to_char(space_limit/1024/1024/1024, '9G999G999D999'))      || '"' from v\$recovery_file_dest;
select 'varDB_FLASH_SIZE_T="'            || ltrim(to_char(space_limit/1024/1024/1024/1024, '9G999G999D999')) || '"' from v\$recovery_file_dest;
select 'varDB_FLASH_RETENTION_MINUTES="' || ltrim(value)                                                     || '"' from v\$parameter where name = 'db_flashback_retention_target';
select 'varDB_FLASH_RETENTION_HOURS="'   || ltrim(value/60)                                                  || '"' from v\$parameter where name = 'db_flashback_retention_target';
select 'varDB_FLASH_RETENTION_DAYS="'    || ltrim(value/60/24)                                               || '"' from v\$parameter where name = 'db_flashback_retention_target';
select 'varDB_PROTECTION_MODE="'         || ltrim(protection_mode)                                           || '"' from v\$database;
select 'varDB_RECOVERY_FILE_DEST_G="'    || ltrim(to_char(value/1024/1024/1024, '9G999G999D999'))            || '"' from v\$parameter where name = 'db_recovery_file_dest_size';
select 'varDB_RECOVERY_FILE_DEST_T="'    || ltrim(to_char(value/1024/1024/1024/1024, '9G999G999D999'))       || '"' from v\$parameter where name = 'db_recovery_file_dest_size';
select 'varDB_RECOVERY_FILE_DEST_PERC="' || ltrim(to_char(decode(nvl(space_used, 0), 0, 0, ceil((space_used/space_limit) * 100)))) || '%"' from v\$recovery_file_dest;
select 'varDB_UNDO_RETENTION_SECONDS="'  || ltrim(value)                                || '"' from v\$parameter where name = 'undo_retention';
select 'varDB_UNDO_RETENTION_MINUTES="'  || ltrim(value/60)                             || '"' from v\$parameter where name = 'undo_retention';
select 'varDB_UNDO_RETENTION_HOURS="'    || ltrim(value/60/60)                          || '"' from v\$parameter where name = 'undo_retention';
select 'varDB_ARCH_LAG_TARGET="'         || ltrim(value)                                || '"' from v\$parameter where name = 'archive_lag_target';
select 'varDB_ARCH_LAG_TARGET_MINUTES="' || to_char(value/60)                           || '"' from v\$parameter where name = 'archive_lag_target';
select 'varDB_ARCH_LAG_TARGET_HOURS="'   || ltrim(to_char(round(value/60/60, 2)))       || '"' from v\$parameter where name = 'archive_lag_target';
select 'varDB_ARCH_LAG_TARGET_DAYS="'    || ltrim(to_char(round(value/60/60/24, 2)))    || '"' from v\$parameter where name = 'archive_lag_target';
select 'varDB_ARCH_LOG_FORMAT="'         || ltrim(value)                                || '"' from v\$parameter where name = 'log_archive_format';
select 'varDB_OPEN_CURSORS="'            || ltrim(value)                                || '"' from v\$parameter where name = 'open_cursors';
select 'varDB_PROCESSES="'               || ltrim(value)                                || '"' from v\$parameter where name = 'processes';
select 'varDB_RECYCLEBIN="'              || upper(value)                                || '"' from v\$parameter where name = 'recyclebin';
select 'varDB_ORA0600="'                 || count(*)                                    || '"' from sys.X\$DBGALERTEXT where MESSAGE_TEXT like '%ORA-00600%' and ORIGINATING_TIMESTAMP > sysdate-30 and rownum = 1;
select 'varDB_ORA_ERRORS="'              || count(*)                                    || '"' from sys.X\$DBGALERTEXT where (lower(MESSAGE_TEXT) like '%ora-%' or lower(MESSAGE_TEXT) like '%error%' or lower(MESSAGE_TEXT) like '%checkpoint not complete%' or lower(MESSAGE_TEXT) like '%fail%') and ORIGINATING_TIMESTAMP > sysdate-30 and rownum = 1;
select case when used_percent >= 80 then 'varDB_TBS_SPACE="WARNING"' when used_percent >= 90 then 'varDB_TBS_SPACE="CRITICAL"' else 'varDB_TBS_SPACE="SIZE OK"' end from dba_tablespace_usage_metrics where rownum = 1;
quit;
EOF
}
#
Func_Set_Database_Var() {
sqlplus -S '/ as sysdba' > ${DBNITRO}/var/Database.${ORACLE_SID}.var <<EOF | tail -2
set define off trims on newp none heads off echo off feed off numwidth 20 pagesize 0 null null verify off wrap off timing off serveroutput off termout off heading off
alter session set nls_date_format='dd/mm/yyyy';
select 'varDB_MODE="'          || status                                                          || '"' from v\$instance;
select 'varDB_VERSION="'       || version                                                         || '"' from v\$instance;
select 'varDB_RELEASE="'       || substr(version,1,2)                                             || '"' from v\$instance;
select 'varDB_EDITION="'       || edition                                                         || '"' from v\$instance;
select 'varDB_ACTIVE_STATE="'  || active_state                                                    || '"' from v\$instance;
select 'varDB_ROLE="'          || database_role                                                   || '"' from v\$database;
select 'varDB_UNIQ_NAME="'     || value                                                           || '"' from v\$parameter where name = 'db_unique_name';
select 'varDB_SRV_NAME="'      || value                                                           || '"' from v\$parameter where name = 'service_names';
select 'varDB_BLOC_SIZE_K="'   || value                                                           || '"' from v\$parameter where name = 'db_block_size';
select 'varDB_BLOC_SIZE_M="'   || value/1024                                                      || '"' from v\$parameter where name = 'db_block_size';
select 'varDB_MEM_MAX_M="'     || ltrim(to_char(value/1024/1024, '9G999G999D999'))                || '"' from v\$parameter where name = 'memory_max_target';
select 'varDB_MEM_MAX_G="'     || ltrim(to_char(value/1024/1024/1024, '9G999G999D999'))           || '"' from v\$parameter where name = 'memory_max_target';
select 'varDB_MEM_MAX_T="'     || ltrim(to_char(value/1024/1024/1024/1024, '9G999G999D999'))      || '"' from v\$parameter where name = 'memory_max_target';
select 'varDB_MEM_TAR_M="'     || ltrim(to_char(value/1024/1024, '9G999G999D999'))                || '"' from v\$parameter where name = 'memory_target';
select 'varDB_MEM_TAR_G="'     || ltrim(to_char(value/1024/1024/1024, '9G999G999D999'))           || '"' from v\$parameter where name = 'memory_target';
select 'varDB_MEM_TAR_T="'     || ltrim(to_char(value/1024/1024/1024/1024, '9G999G999D999'))      || '"' from v\$parameter where name = 'memory_target';
select 'varDB_SGA_MAX_M="'     || ltrim(to_char(value/1024/1024, '9G999G999D999'))                || '"' from v\$parameter where name = 'sga_max_size';
select 'varDB_SGA_MAX_G="'     || ltrim(to_char(value/1024/1024/1024, '9G999G999D999'))           || '"' from v\$parameter where name = 'sga_max_size';
select 'varDB_SGA_MAX_T="'     || ltrim(to_char(value/1024/1024/1024/1024, '9G999G999D999'))      || '"' from v\$parameter where name = 'sga_max_size';
select 'varDB_SGA_TAR_M="'     || ltrim(to_char(value/1024/1024, '9G999G999D999'))                || '"' from v\$parameter where name = 'sga_target';
select 'varDB_SGA_TAR_G="'     || ltrim(to_char(value/1024/1024/1024, '9G999G999D999'))           || '"' from v\$parameter where name = 'sga_target';
select 'varDB_SGA_TAR_T="'     || ltrim(to_char(value/1024/1024/1024/1024, '9G999G999D999'))      || '"' from v\$parameter where name = 'sga_target';
select 'varDB_PGA_LIM_K="'     || ltrim(to_char(value/1024, '9G999G999D999'))                     || '"' from v\$parameter where name = 'pga_aggregate_limit';
select 'varDB_PGA_LIM_M="'     || ltrim(to_char(value/1024/1024, '9G999G999D999'))                || '"' from v\$parameter where name = 'pga_aggregate_limit';
select 'varDB_PGA_LIM_G="'     || ltrim(to_char(value/1024/1024/1024, '9G999G999D999'))           || '"' from v\$parameter where name = 'pga_aggregate_limit';
select 'varDB_PGA_TAR_K="'     || ltrim(to_char(value/1024, '9G999G999D999'))                     || '"' from v\$parameter where name = 'pga_aggregate_target';
select 'varDB_PGA_TAR_M="'     || ltrim(to_char(value/1024/1024, '9G999G999D999'))                || '"' from v\$parameter where name = 'pga_aggregate_target';
select 'varDB_PGA_TAR_G="'     || ltrim(to_char(value/1024/1024/1024, '9G999G999D999'))           || '"' from v\$parameter where name = 'pga_aggregate_target';
select 'varDB_UPTIME="'        || to_date(startup_time, 'dd/mm/yyyy')                             || '"' from v\$instance;
select 'varDB_UPTIME_D="'      || (select to_date(sysdate, 'dd/mm/yyyy hh24:mi') - to_date(startup_time, 'dd/mm/yyyy hh24:mi') from v\$instance) || '"' from dual;
-- select 'varDB_VER_TIME="'   || to_char(max(action_time), 'dd/mm/yyyy')                         || '"' from DBA_REGISTRY_SQLPATCH where action in ('APPLY','UPGRADE','RU_APPLY');
select 'varDB_VER_TIME="'      || to_char(max(action_time), 'dd/mm/yyyy')                         || '"' from registry\$history where action in ('APPLY','UPGRADE','RU_APPLY');
-- select 'varDB_VER_TIME_D="' || ltrim(lpad(substr(substr(to_char((select sysdate from dual) - (select max(action_time) from DBA_REGISTRY_SQLPATCH where action in ('APPLY','UPGRADE','RU_APPLY'))),3),2), 16, '0'), '0') || '"' from dual;
select 'varDB_VER_TIME_D="'    || ltrim(lpad(substr(substr(to_char((select sysdate from dual) - (select max(action_time) from registry\$history where action in ('APPLY','UPGRADE','RU_APPLY'))),3),2), 16, '0'), '0') || '"' from dual;
select 'varDB_TOT_SIZE_M="'    || ltrim(to_char(sum(bytes)/1024/1024, '9G999G999D999'))           || '"' from (select sum(bytes) bytes from dba_data_files union all select sum(bytes) bytes from dba_temp_files union all select sum(bytes * members) from v\$log union all select sum(block_size * file_size_blks) from v\$controlfile);
select 'varDB_TOT_SIZE_G="'    || ltrim(to_char(sum(bytes)/1024/1024/1024, '9G999G999D999'))      || '"' from (select sum(bytes) bytes from dba_data_files union all select sum(bytes) bytes from dba_temp_files union all select sum(bytes * members) from v\$log union all select sum(block_size * file_size_blks) from v\$controlfile);
select 'varDB_TOT_SIZE_T="'    || ltrim(to_char(sum(bytes)/1024/1024/1024/1024, '9G999G999D999')) || '"' from (select sum(bytes) bytes from dba_data_files union all select sum(bytes) bytes from dba_temp_files union all select sum(bytes * members) from v\$log union all select sum(block_size * file_size_blks) from v\$controlfile);
select 'varDB_CACHE_SIZE_K="'  || ltrim(to_char(value/1024, '9G999G999D999'))                     || '"' from v\$parameter where name = 'db_cache_size';
select 'varDB_CACHE_SIZE_M="'  || ltrim(to_char(value/1024/1024, '9G999G999D999'))                || '"' from v\$parameter where name = 'db_cache_size';
select 'varDB_CACHE_SIZE_G="'  || ltrim(to_char(value/1024/1024/1024, '9G999G999D999'))           || '"' from v\$parameter where name = 'db_cache_size';
select 'varDB_SHARED_POOL_K="' || ltrim(to_char(value/1024, '9G999G999D999'))                     || '"' from v\$parameter where name = 'shared_pool_size';
select 'varDB_SHARED_POOL_M="' || ltrim(to_char(value/1024, '9G999G999D999'))                     || '"' from v\$parameter where name = 'shared_pool_size';
select 'varDB_SHARED_POOL_G="' || ltrim(to_char(value/1024, '9G999G999D999'))                     || '"' from v\$parameter where name = 'shared_pool_size';
select 'varDB_SCN="'           || current_scn                                                     || '"' from v\$DATABASE;
select case when log_mode = 'ARCHIVELOG' then 'varDB_ARCH_MODE="Y"' else 'varDB_ARCH_MODE="N"' end from v\$DATABASE ;
select decode(count(*), 0, 'varDB_PARTITION="N"', 'varDB_PARTITION="Y"') Partitioning from dba_part_tables where owner not in ('SYSMAN', 'SH', 'SYS', 'SYSTEM');
select distinct case when a.DETECTED_USAGES = 0 then 'varDB_SQL_TUNING="N"' else 'varDB_SQL_TUNING="Y"' end from dba_feature_usage_statistics a, v\$instance b where a.name = 'SQL Tuning Advisor' and a.version = b.version;
select case when value = 'TRUE' then 'varDB_SPATIAL="Y"' else 'varDB_SPATIAL=N"' end from v\$option where parameter = 'Spatial';
select distinct case when DETECTED_USAGES = 0 then 'varDB_MULTIMEDIA="N"' else 'varDB_MULTIMEDIA="Y"' end from dba_feature_usage_statistics a, v\$instance b where name  = 'Oracle Multimedia' and a.version = b.version;
select distinct case when DETECTED_USAGES = 0 then 'varDB_TEXT="N"' else 'varDB_TEXT="Y"' end from dba_feature_usage_statistics a, v\$instance b where name  = 'Oracle Text' and a.version = b.version;
select 'varDB_STBY_FILE_MAN="'           || value                  || '"' from v\$parameter where name = 'standby_file_management';
select case when FORCE_LOGGING = 'YES' then 'varDB_FORCE_LOGGING="Y"' else 'varDB_FORCE_LOGGING="N"' end from v\$DATABASE;
select case when FLASHBACK_ON = 'YES' then 'varDB_FLASBBACK_ON="Y"' else 'varDB_FLASBBACK_ON="N"' end from v\$DATABASE;
select 'varDB_FLASH_SIZE_M="'            || ltrim(to_char(space_limit/1024/1024, '9G999G999D999'))           || '"' from v\$recovery_file_dest;
select 'varDB_FLASH_SIZE_G="'            || ltrim(to_char(space_limit/1024/1024/1024, '9G999G999D999'))      || '"' from v\$recovery_file_dest;
select 'varDB_FLASH_SIZE_T="'            || ltrim(to_char(space_limit/1024/1024/1024/1024, '9G999G999D999')) || '"' from v\$recovery_file_dest;
select 'varDB_FLASH_RETENTION_MINUTES="' || ltrim(value)                                                     || '"' from v\$parameter where name = 'db_flashback_retention_target';
select 'varDB_FLASH_RETENTION_HOURS="'   || ltrim(value/60)                                                  || '"' from v\$parameter where name = 'db_flashback_retention_target';
select 'varDB_FLASH_RETENTION_DAYS="'    || ltrim(value/60/24)                                               || '"' from v\$parameter where name = 'db_flashback_retention_target';
select 'varDB_PROTECTION_MODE="'         || ltrim(protection_mode)                                           || '"' from v\$database;
select 'varDB_RECOVERY_FILE_DEST_G="'    || ltrim(to_char(value/1024/1024/1024, '9G999G999D999'))            || '"' from v\$parameter where name = 'db_recovery_file_dest_size';
select 'varDB_RECOVERY_FILE_DEST_T="'    || ltrim(to_char(value/1024/1024/1024/1024, '9G999G999D999'))       || '"' from v\$parameter where name = 'db_recovery_file_dest_size';
select 'varDB_RECOVERY_FILE_DEST_PERC="' || ltrim(to_char(decode(nvl(space_used, 0), 0, 0, ceil((space_used/space_limit) * 100)))) || '%"' from v\$recovery_file_dest;
select 'varDB_UNDO_RETENTION_SECONDS="'  || ltrim(value)                                || '"' from v\$parameter where name = 'undo_retention';
select 'varDB_UNDO_RETENTION_MINUTES="'  || ltrim(value/60)                             || '"' from v\$parameter where name = 'undo_retention';
select 'varDB_UNDO_RETENTION_HOURS="'    || ltrim(value/60/60)                          || '"' from v\$parameter where name = 'undo_retention';
select 'varDB_ARCH_LAG_TARGET="'         || ltrim(value)                                || '"' from v\$parameter where name = 'archive_lag_target';
select 'varDB_ARCH_LAG_TARGET_MINUTES="' || to_char(value/60)                           || '"' from v\$parameter where name = 'archive_lag_target';
select 'varDB_ARCH_LAG_TARGET_HOURS="'   || ltrim(to_char(round(value/60/60, 2)))       || '"' from v\$parameter where name = 'archive_lag_target';
select 'varDB_ARCH_LAG_TARGET_DAYS="'    || ltrim(to_char(round(value/60/60/24, 2)))    || '"' from v\$parameter where name = 'archive_lag_target';
select 'varDB_ARCH_LOG_FORMAT="'         || ltrim(value)                                || '"' from v\$parameter where name = 'log_archive_format';
select 'varDB_OPEN_CURSORS="'            || ltrim(value)                                || '"' from v\$parameter where name = 'open_cursors';
select 'varDB_PROCESSES="'               || ltrim(value)                                || '"' from v\$parameter where name = 'processes';
select 'varDB_RECYCLEBIN="'              || upper(value)                                || '"' from v\$parameter where name = 'recyclebin';
select 'varDB_ORA0600="'                 || count(*)                                    || '"' from sys.X\$DBGALERTEXT where MESSAGE_TEXT like '%ORA-00600%' and ORIGINATING_TIMESTAMP > sysdate-30 and rownum = 1;
select 'varDB_ORA_ERRORS="'              || count(*)                                    || '"' from sys.X\$DBGALERTEXT where (lower(MESSAGE_TEXT) like '%ora-%' or lower(MESSAGE_TEXT) like '%error%' or lower(MESSAGE_TEXT) like '%checkpoint not complete%' or lower(MESSAGE_TEXT) like '%fail%') and ORIGINATING_TIMESTAMP > sysdate-30 and rownum = 1;
select case when used_percent >= 80 then 'varDB_TBS_SPACE="WARNING"' when used_percent >= 90 then 'varDB_TBS_SPACE="CRITICAL"' else 'varDB_TBS_SPACE="SIZE OK"' end from dba_tablespace_usage_metrics where rownum = 1;
quit;
EOF
}
#
Func_Set_Dataguard_Var() {
cat > ${DBNITRO}/var/Dataguard.${ORACLE_SID}.var <<EOF # | tail -2
varDG_NAME=$(dgmgrl -silent / "show configuration" | egrep "Configuration - " | awk '{print $3}')
varDG_STATUS=$(dgmgrl -silent / "show configuration" | awk '/Configuration Status/ { getline; print $1; }')
varDG_PROTECT=$(dgmgrl -silent / "show configuration" | awk '/Protection Mode/ {print $3 }')
varDG_FAST=$(dgmgrl -silent / "show configuration" | egrep "Fast-Start Failover" | awk '{print $3 }')
varDG_FAST_THRES=$(dgmgrl -silent / "show configuration verbose" | awk '/FastStartFailoverThreshold/' | awk '{print $3}')
varDG_OPER_TIME=$(dgmgrl -silent / "show configuration verbose" | awk '/OperationTimeout/' | awk '{print $3}')
varDG_FAST_LIMIT=$(dgmgrl -silent / "show configuration verbose" | awk '/FastStartFailoverLagLimit/' | awk '{print $3}')
varDG_COMM_TIME=$(dgmgrl -silent / "show configuration verbose" | awk '/CommunicationTimeout/' | awk '{print $3}')
varDG_OBSER_RECO=$(dgmgrl -silent / "show configuration verbose" | awk '/ObserverReconnect/' | awk '{print $3}')
varDG_FAST_A_R=$(dgmgrl -silent / "show configuration verbose" | awk '/FastStartFailoverAutoReinstate/' | awk '{print $3}')
varDG_FAST_SHUT=$(dgmgrl -silent / "show configuration verbose" | awk '/FastStartFailoverPmyShutdown/' | awk '{print $3}')
varDG_BYST_CHANG=$(dgmgrl -silent / "show configuration verbose" | awk '/BystandersFollowRoleChange/' | awk '{print $3}')
varDG_OBSER_OVER=$(dgmgrl -silent / "show configuration verbose" | awk '/ObserverOverride/' | awk '{print $3}')
varDG_EXT_DEST1=$(dgmgrl -silent / "show configuration verbose" | awk '/ExternalDestination1/' | awk '{print $3}')
varDG_EXT_DEST=$(dgmgrl -silent / "show configuration verbose" | awk '/ExternalDestination2/' | awk '{print $3}')
varDG_PRIMARY_ACT=$(dgmgrl -silent / "show configuration verbose" | awk '/PrimaryLostWriteAction/' | awk '{print $3}')
EOF
}
#
# Verify if is an ODA Environment
if [[ -z /opt/oracle/oak/bin ]]; then
  varODA="Y"
else
  varODA="N"
fi
#
#########################################################################################################
# User Function
#########################################################################################################
#
Funk_DB_Users_Selecting() {
varDB_USERS_LIST="${DBNITRO}/var/Func_DB_Users_Selecting.${ORACLE_SID}.var"
echo "" > ${varDB_USERS_LIST}
sqlplus -S '/ as sysdba' > ${varDB_USERS_LIST} <<EOF | tail -2
set define off trims on newp none heads off echo off feed off numwidth 20 pagesize 0 null null verify off wrap off timing off serveroutput off termout off heading off
alter session set nls_date_format='dd/mm/yyyy';
select '"' || username || '"   ' || '   "' || default_tablespace || '"   off ' from dba_users order by 1;
select '"' || 'null'   || '"   ' || '   "' || 'null'             || '"   off ' from dba_users where rownum = 1; 
quit;
EOF
}
#
Funk_DB_Users_Settings() {
varDB_USERS_SELECTED=""
tempfile="${DBNITRO}/var/Func_DB_Users_Setting.${ORACLE_SID}.tmp"
echo "" > ${tempfile}
#
dialog --backtitle "DATABASE: Users Settings" --title "SELECT ONE USER/SCHEMA" --clear --radiolist "Press SPACE to toggle an option ON/OFF" 50 80 50 $(cat ${varDB_USERS_LIST}) 2> ${tempfile}
retval=$?
choice=$(cat ${tempfile})
case ${retval} in
    0)  echo "User Selected: ${choice}" ;;
    1)  echo "Cancel Pressed." ;;
  255)  echo "ESC Pressed." ;;
esac
varDB_USERS_SELECTED="${choice}"
}
#
#########################################################################################################
# PDB Function
#########################################################################################################
#
Func_DB_PDB_Selecting() {
varDB_PDB_LIST="${DBNITRO}/var/Func_DB_PDB_Selecting.${ORACLE_SID}.var"
echo "" > ${varDB_PDB_LIST}
sqlplus -S '/ as sysdba' > ${varDB_PDB_LIST} <<EOF | tail -2
set define off trims on newp none heads off echo off feed off numwidth 20 pagesize 0 null null verify off wrap off timing off serveroutput off termout off heading off
alter session set nls_date_format='dd/mm/yyyy';
select '"' || pluggable_name || '"' || 'pluggable_status' || '"   off ' from v\$container where container_id not in (1,2);
quit;
EOF
}
#
Func_DB_PDB_Setting() {
varDB_PDB_SELECTED=""
tempfile="${DBNITRO}/var/Func_DB_PDB_Setting.${ORACLE_SID}.tmp"
echo "" > ${tempfile}
#
dialog --backtitle "DATABASE: Users Settings" --title "SELECT ONE PLUGGABLE DATABASE" --clear --radiolist "Press SPACE to toggle an option ON/OFF" 50 80 50 $(cat ${varDB_PDB_LIST}) 2> ${tempfile}
retval=$?
choice=$(cat ${tempfile})
case ${retval} in
    0)  echo "PDB Selected: ${choice}" ;;
    1)  echo "Cancel Pressed." ;;
  255)  echo "ESC Pressed." ;;
esac
varDB_PDB_SELECTED=${choice}
}
#
#########################################################################################################
#
# Main Menu
#
#########################################################################################################
#
MainMenu() {
#
#########################################################################################################
# Variables Main Menu
#########################################################################################################
#
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "Variable: Main Menu" --no-collapse --colors --gauge "Loading Main Menu Variables" 7 50
#
Func_Set_MainMenu_Var
. ${DBNITRO}/var/MainMenu.${ORACLE_SID}.var
#
varDATE=$(date +%d\/%m\/%Y)
varTIME=$(date +%H\:%M)
#
DIALOG_CANCEL=1
DIALOG_ESC=255
#
display_result() {
  dialog --backtitle "www.DBNITRO.net" --title "Main Menu" --no-collapse --colors --msgbox "$result" 0 0
}
#
while true; do
exec 3>&1
SelectMainMenu=$(dialog --backtitle "www.DBNITRO.net" --title "Main Menu" --no-collapse --colors --clear --cancel-label "Exit" --menu "Select an Option:" 0 100 20 \
  "AUTHOR"                                   "All About the Author"                                                                                                \
  "INFOS"                                    "All About the System"                                                                                                \
  "UNIX"                                     "All About Oracle Linux/Unix"                                                                                         \
  "DATABASE"                                 "[\Zb\Z1 ${varDB} \Zn] All About Oracle Database Version: [\Zb\Z1 ${varDB_RELEASE} \Zn]"                              \
  "RMAN"                                     "[\Zb\Z1 ${varDB} \Zn] All About Oracle Backup & Recover"                                                             \
  "ASM"                                      "[\Zb\Z1 ${varASM} \Zn] All About Oracle ASM"                                                                         \
  "RAC"                                      "[\Zb\Z1 ${varRAC} \Zn] All About Oracle RAC (Real Application Cluster)"                                              \
  "DATAGUARD"                                "[\Zb\Z1 ${varODG} \Zn] All About Oracle DataGuard"                                                                   \
  "GOLDENGATE"                               "[\Zb\Z1 ${varOGG} \Zn] All About Oracle GoldenGate"                                                                  \
  "WALLET"                                   "[\Zb\Z1 ${varWALL} \Zn] All About Oracle Wallet (Security)"                                                          \
  "ODA"                                      "[\Zb\Z1 ${varODA} \Zn] All About Oracle Database Appliance"                                                          \
  "EXADATA"                                  "[\Zb\Z1 ${varEXA} \Zn] All About Oracle Exadata"                                                           2>&1 1>&3 )
exit_status=$?
exec 3>&-
case $exit_status in $DIALOG_CANCEL)
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "Exit Program" --gauge "Program Closed" 7 50 >&2
exit 1
;;
$DIALOG_ESC)
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "Exit Program" --gauge "Program Aborted" 7 50 >&2
exit 1
;;
esac
case ${SelectMainMenu} in
      AUTHOR)  AUTHOR "All About the Author"                                    ;;
       INFOS)  INFOS "All About the System"                                     ;;
        UNIX)  UNIX "All About Oracle Linux/Unix"                               ;;
    DATABASE)  DATABASE "All About Oracle Databases Version: ${varDB_RELEASE}"  ;;
        RMAN)  RMAN "All About Oracle Backup & Recover"                         ;;
         ASM)  ASM "All About Oracle ASM"                                       ;;
         RAC)  RAC "All About Oracle RAC (Real Application Cluster)"            ;;
   DATAGUARD)  DATAGUARD "All About Oracle DataGuard"                           ;;
  GOLDENGATE)  GOLDENGATE "All About Oracle GoldenGate"                         ;;
      WALLET)  WALLET "All About Oracle Wallet (Security)"                      ;;
         ODA)  ODA "All About Oracle Database Appliance"                        ;;
     EXADATA)  EXADATA "All About Oracle Exadata"                               ;;
  esac
done
}
#
#########################################################################################################
# System: How It Works
#########################################################################################################
#
INFOS() {
dialog --backtitle "www.DBNITRO.net" --title "Informations About the System" --no-collapse --colors --msgbox "\
\Zb\Z1 LINUX/UNIX.....(-):\Zn All About Oracle Linux/Unix
\Zb\Z1 DATABASE.......(+):\Zn All About Oracle Database Version: \Zb\Z1 ${varDB_RELEASE} \Zn
\Zb\Z1 RMAN...........(-):\Zn All About Oracle Backup & Recover
\Zb\Z1 ASM............(-):\Zn All About Oracle ASM
\Zb\Z1 RAC............(+):\Zn All About Oracle RAC (Real Application Cluster)
\Zb\Z1 DATAGUARD......(+):\Zn All About Oracle DataGuard
\Zb\Z1 GOLDENGATE.....(-):\Zn All About Oracle GoldenGate
\Zb\Z1 WALLET.........(-):\Zn All About Oracle Wallet (Security)
\Zb\Z1 ODA............(-):\Zn All About Oracle Database Appliance
\Zb\Z1 EXADATA........(-):\Zn All About Oracle Exadata
-----------------------------------------------------------------------------------------------
         Options With (+) Are Working on This System, With (-) Is Not Working Yet.
                  If You Have Any Question, Please Send an E-Mail.   " 0 0
}
#
#########################################################################################################
# Author: All About the Author
#########################################################################################################
#
AUTHOR() {
dialog --backtitle "www.DBNITRO.net" --title "Author" --no-collapse --colors --msgbox "\
\Zb\Z1 Author...................: ${Author}                 \Zn
\Zb\Z1 Software Version.........: ${SoftwareVersion}        \Zn
\Zb\Z1 Date of Creation.........: ${DateOfCreation}         \Zn
\Zb\Z1 Date of Modification.....: ${DateOfModification}     \Zn
\Zb\Z1 EMAIL....................: ${EMAIL_1}                \Zn
\Zb\Z1 EMAIL....................: ${EMAIL_2}                \Zn 
\Zb\Z1 WEBSITE..................: ${WEBSITE}                \Zn " 0 0
}
#
#########################################################################################################
#
# UNIX Menu
#
#########################################################################################################
#
UNIX() {
#
#########################################################################################################
# Verify UNIX
#########################################################################################################
#
#
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "Unix Menu" --no-collapse --colors --gauge "Open Unix Menu" 7 50
#
#########################################################################################################
# Variables UNIX Menu
#########################################################################################################
#
#
varDATE=$(date +%d\/%m\/%Y)
varTIME=$(date +%H\:%M)
#
while true; do
exec 3>&1
SelectUnix=$(dialog --backtitle "www.DBNITRO.net" --title "UNIX Menu" --clear --cancel-label "Back" --no-collapse --colors --inputbox "\
+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| OS: ${varOS} | UPTIME: ${varUPTIME} | KERNEL: ${varKERNEL} | PROCS: ${varPhysical_CPU} | CORES: ${varPhysical_CPUS} | MEMORY: ${varTotal_MEMORY} | MEM_USED: ${varUsed_MEMORY} | MEM_FREE: ${varFree_MEMORY} | SWAP: ${varSwap_MEMORY} | SWAP_USED: ${varSwap_USED_MEMORY} | SWAP_FREE: ${varSwap_Free_MEMORY}
+-+-+-----+---------------------------------------------------+-+-+-----+---------------------------------------------------+-+---------------------------+-+----------------------------------------------------+
|+|-|   1 | VERIFY DISTRIBUTION OF THE UNIX/LINUX             |+|-|   2 | VERIFY VERSION OF THE UNIX/LINUX [ KERNEL ]       |+| HOSTNAME..................: \Zb\Z1 ${varHOST}          \Zn
|+|-|   3 | VERIFY FAMILY OF PROCESSOR [ CPU ]                |+|-|   4 | VERIFY MODEL OF PROCESSOR [ CPU ]                 |+| IP_ADDRESS................: \Zb\Z1 ${varIP_ADDR}       \Zn
|+|-|   5 | VERIFY DISK USAGE                                 |+|-|   6 | VERIFY DISK INFOS                                 |+| PHYSICAL_CPU..............: \Zb\Z1 ${varPhysical_CPU}  \Zn
|+|-|   7 | VERIFY NETWORK CONFIGURATION                      |+|-|   8 | VERIFY KERNEL CONFIGURATION                       |+| PHYSICAL_CPU_COREs........: \Zb\Z1 ${varPhysical_CPUS} \Zn
|+|-|   9 | VERIFY [ /etc/hosts ] CONFIGURATION               |+|-|  10 | VERIFY [ /etc/sysconfig/selinux ] CONFIGURATION   |+| ARCHITECTURE..............: \Zb\Z1 ${varARCHITECTURE}  \Zn
|+|-|  11 | VERIFY [ /etc/security/limits.conf ] CONFIGURATION|+|-|  12 | VERIFY GROUPS AND USERS                           |+| OS_ENDIAN.................: \Zb\Z1 ${varBytes_ORDER}   \Zn
|+|-|  13 | VERIFY HUGE PAGES                                 |+|-|  14 | SHOW DMESG INFORMATIONS                           |+| CPU_THREADS...............: \Zb\Z1 ${varTHREADS}       \Zn
|+|-|  15 |                                                   |+|-|  16 |                                                   |+| CPU_CORES.................: \Zb\Z1 ${varCORES}         \Zn
|+|-|  17 |                                                   |+|-|  18 |                                                   |+| CPU_SOCKETS...............: \Zb\Z1 ${varSOCKETS}       \Zn
|+|-|  19 |                                                   |+|-|  20 |                                                   |+| CPU_FAMILY................: \Zb\Z1 ${varCPU_FAMILY}    \Zn
|+|-|  21 |                                                   |+|-|  22 |                                                   |+| CPU_MHz...................: \Zb\Z1 ${varCPU_MHZ}       \Zn
|+|-|  23 |                                                   |+|-|  24 |                                                   |+| ..........................: 
|+|-|  25 |                                                   |+|-|  26 |                                                   |+| ..........................: 
|+|-|  27 |                                                   |+|-|  28 |                                                   |+| ..........................: 
|+|-|  29 |                                                   |+|-|  30 |                                                   |+| ..........................: 
|+|-|  31 |                                                   |+|-|  32 |                                                   |+| ..........................: 
|+|-|  33 |                                                   |+|-|  34 |                                                   |+| ..........................: 
|+|-|  35 |                                                   |+|-|  36 |                                                   |+| ..........................: 
|+|-|  37 |                                                   |+|-|  38 |                                                   |+| ..........................: 
|+|-|  39 |                                                   |+|-|  40 |                                                   |+| ..........................: 
|+|-|  41 |                                                   |+|-|  42 |                                                   |+| ..........................: 
|+|-|  43 |                                                   |+|-|  44 |                                                   |+| ..........................: 
|+|-|  45 |                                                   |+|-|  46 |                                                   |+| ..........................: 
|+|-|  47 |                                                   |+|-|  48 |                                                   |+| ..........................: 
|+|-|  49 |                                                   |+|-|  50 |                                                   |+| ..........................: 
|+|-|  51 |                                                   |+|-|  52 |                                                   |+| ..........................: 
|+|-|  53 |                                                   |+|-|  54 |                                                   |+| ..........................: 
|+|-|  55 |                                                   |+|-|  56 |                                                   |+| ..........................: 
|+|-|  57 |                                                   |+|-|  58 |                                                   |+| ..........................: 
|+|-|  59 |                                                   |+|-|  60 |                                                   |+| ..........................: 
|+|-|  61 |                                                   |+|-|  62 |                                                   |+| ..........................: 
|+|-|  63 |                                                   |+|-|  64 |                                                   |+| ..........................: 
|+|-|  65 |                                                   |+|-|  66 |                                                   |+| ..........................: 
|+|-|  67 |                                                   |+|-|  68 |                                                   |+| ..........................: 
|+|-|  69 |                                                   |+|-|  70 |                                                   |+| ..........................: 
|+|-|  71 |                                                   |+|-|  72 |                                                   |+| ..........................: 
|+|-|  73 |                                                   |+|-|  74 |                                                   |+| ..........................: 
|+|-|  75 |                                                   |+|-|  76 |                                                   |+| ..........................: 
|+|-|  77 |                                                   |+|-|  78 |                                                   |+| ..........................: 
|+|-|  79 |                                                   |+|-|  80 |                                                   |+| ..........................: 
|+|-|  81 |                                                   |+|-|  82 |                                                   |+| ..........................: 
|+|-|  83 |                                                   |+|-|  84 |                                                   |+| ..........................: 
|+|-|  85 |                                                   |+|-|  86 |                                                   |+| ..........................: 
|+|-|  87 |                                                   |+|-|  88 |                                                   |+| ..........................: 
|+|-|  89 |                                                   |+|-|  90 |                                                   |+| ..........................: 
|+|-|  91 |                                                   |+|-|  92 |                                                   |+| ..........................: 
|+|-|  93 |                                                   |+|-|  94 |                                                   |+| ..........................: 
|+|-|  95 |                                                   |+|-|  96 |                                                   |+| ..........................: 
|+|-|  97 |                                                   |+|-|  98 |                                                   |+| ..........................: 
|+|-|  99 | REPORT                                            |+|-| 100 | EXTRAS                                            |+| ..........................: 
+-+-+-----+---------------------------------------------------+-+-+-----+---------------------------------------------------+-+---------------------------+-+----------------------------------------------------+
| CHOOSE ONE OF THOSE OPTIONS [ 0 - 100 ] | OPTIONS WITH [ @ ] HAS MORE FILTERS | VERSION: ${SoftwareVersion} | MODIFIED: ${DateofModification} | DATE & TIME: ${varDATE} ${varTIME}
+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+" 0 0 3>&1 1>&2 2>&3 3>&-)
exit_status=$?
exec 3>&-
case ${exit_status} in ${DIALOG_CANCEL})
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "Exit Program" --gauge "Program Closed" 7 50 >&2
MainMenu
;;
${DIALOG_ESC})
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "Exit Program" --gauge "Program Aborted" 7 50 >&2
MainMenu
;;
esac
case ${SelectUnix} in
  1)    dialog --backtitle "www.DBNITRO.net" --title "Unix: VERIFY DISTRIBUTION OF THE UNIX/LINUX" --no-collapse --colors --msgbox "${varOSDISTRO}" 0 0    ;;
  2)    dialog --backtitle "www.DBNITRO.net" --title "Unix: VERIFY VERSION OF THE UNIX/LINUX [ KERNEL ]" --no-collapse --colors --msgbox "${varKERNEL}" 0 0    ;;
  3)    dialog --backtitle "www.DBNITRO.net" --title "Unix: VERIFY FAMILY OF PROCESSOR [ CPU ]" --no-collapse --colors --msgbox "${varProc_FAMILY}" 0 0    ;;
  4)    dialog --backtitle "www.DBNITRO.net" --title "Unix: VERIFY MODEL OF PROCESSOR [ CPU ]" --no-collapse --colors --msgbox "${varProc_TYPE}" 7 70    ;;
  5)    dialog --backtitle "www.DBNITRO.net" --title "Unix: VERIFY DISK USAGE" --no-collapse --colors --msgbox "${varDisk_Usage}" 0 0    ;;
  6)    dialog --backtitle "www.DBNITRO.net" --title "Unix: VERIFY DISK USAGE" --no-collapse --colors --msgbox "${varDisk_Infos}" 0 0    ;;
  7)    dialog --backtitle "www.DBNITRO.net" --title "Unix: VERIFY NETWORK CONFIGURATION" --no-collapse --colors --msgbox "${varIP_ADDR_ALL}" 0 0    ;;
  8)    dialog --backtitle "www.DBNITRO.net" --title "Unix: VERIFY KERNEL CONFIGURATION" --no-collapse --colors --msgbox "$(cat /etc/sysctl.conf)" 0 0    ;;
  9)    dialog --backtitle "www.DBNITRO.net" --title "Unix: VERIFY [ /etc/hosts ] CONFIGURATION" --no-collapse --colors --msgbox "$(cat /etc/hosts)" 50 120    ;;
  10)   dialog --backtitle "www.DBNITRO.net" --title "Unix: VERIFY [ /etc/sysconfig/selinux ] CONFIGURATION" --no-collapse --colors --msgbox "$(cat /etc/sysconfig/selinux)" 0 0    ;;
  11)   dialog --backtitle "www.DBNITRO.net" --title "Unix: VERIFY [ /etc/security/limits.conf ] CONFIGURATION" --no-collapse --colors --msgbox "$(cat /etc/security/limits.conf)" 50 120    ;;
  12)   dialog --backtitle "www.DBNITRO.net" --title "Unix: VERIFY GROUPS AND USERS" --no-collapse --colors --msgbox "$(id grid || id oracle || id agent)" 15 210    ;;
  13)   dialog --backtitle "www.DBNITRO.net" --title "Unix: VERIFY HUGE PAGES" --no-collapse --colors --msgbox "Func_Unix_013" 15 210    ;;
  14)   dialog --backtitle "www.DBNITRO.net" --title "Unix: SHOW DMESG INFORMATIONS" --no-collapse --colors --msgbox "$(dmesg | egrep -i 'error|warning|critical|failed')" 50 180 ;;
  15)   dialog --backtitle "www.DBNITRO.net" --title "Unix: " --no-collapse --colors --msgbox "" 15 210    ;;
  16)   dialog --backtitle "www.DBNITRO.net" --title "Unix: " --no-collapse --colors --msgbox "" 15 210    ;;
  17)   dialog --backtitle "www.DBNITRO.net" --title "Unix: " --no-collapse --colors --msgbox "" 15 210    ;;
  18)   dialog --backtitle "www.DBNITRO.net" --title "Unix: " --no-collapse --colors --msgbox "" 15 210    ;;
  19)   dialog --backtitle "www.DBNITRO.net" --title "Unix: " --no-collapse --colors --msgbox "" 15 210    ;;
  20)   dialog --backtitle "www.DBNITRO.net" --title "Unix: " --no-collapse --colors --msgbox "" 15 210    ;;
  21)   dialog --backtitle "www.DBNITRO.net" --title "Unix: " --no-collapse --colors --msgbox "" 15 210    ;;
  22)   dialog --backtitle "www.DBNITRO.net" --title "Unix: " --no-collapse --colors --msgbox "" 15 210    ;;
  23)   dialog --backtitle "www.DBNITRO.net" --title "Unix: " --no-collapse --colors --msgbox "" 15 210    ;;
  24)   dialog --backtitle "www.DBNITRO.net" --title "Unix: " --no-collapse --colors --msgbox "" 15 210    ;;
  25)   dialog --backtitle "www.DBNITRO.net" --title "Unix: " --no-collapse --colors --msgbox "" 15 210    ;;
  26)   dialog --backtitle "www.DBNITRO.net" --title "Unix: " --no-collapse --colors --msgbox "" 15 210    ;;
  27)   dialog --backtitle "www.DBNITRO.net" --title "Unix: " --no-collapse --colors --msgbox "" 15 210    ;;
  28)   dialog --backtitle "www.DBNITRO.net" --title "Unix: " --no-collapse --colors --msgbox "" 15 210    ;;
  29)   dialog --backtitle "www.DBNITRO.net" --title "Unix: " --no-collapse --colors --msgbox "" 15 210    ;;
  99)   dialog --backtitle "www.DBNITRO.net" --title "Unix: " --no-collapse --colors --msgbox "" 15 210    ;;
  100)  dialog --backtitle "www.DBNITRO.net" --title "Unix: " --no-collapse --colors --msgbox "" 15 210    ;;
  esac
done
}
#
#########################################################################################################
#
# RMAN Menu
#
#########################################################################################################
#
RMAN() {
#
#########################################################################################################
# Verify RMAN
#########################################################################################################
#
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "RMAN Menu" --no-collapse --colors --gauge "Open RMAN Menu" 7 50
#
#########################################################################################################
# Variables RMAN Menu
#########################################################################################################
#
. ${DBNITRO}/var/MainMenu.${ORACLE_SID}.var
#
Func_Set_Database_Var
. ${DBNITRO}/var/Database.${ORACLE_SID}.var
#
varDATE=$(date +%d\/%m\/%Y)
varTIME=$(date +%H\:%M)
#
while true; do
exec 3>&1
SelectRMAN=$(dialog --backtitle "www.DBNITRO.net" --title "RMAN Menu" --clear --cancel-label "Back" --no-collapse --colors --inputbox "\
+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| OS: ${varOS} | UPTIME: ${varUPTIME} | KERNEL: ${varKERNEL} | PROCS: ${varPhysical_CPU} | MEMORY: ${varTotal_MEMORY} | MEM_USED: ${varUsed_MEMORY} | MEM_FREE: ${varFree_MEMORY} | SWAP: ${varSwap_MEMORY} | SWAP_USED: ${varSwap_USED_MEMORY} | SWAP_FREE: ${varSwap_Free_MEMORY}
+-+-+----+---------------------------------------------------+-+-+-----+---------------------------------------------------+-+---------------------------+-+----------------------------------------------------+
|+|-|  1 | VERIFY RMAN CONFIGURATIONS                        |+|-|   2 | VIEW GENERAL REPORT                               |+| ..........................: 
|+|-|  3 | LIST BACKUP                                       |+|-|   4 | LIST BACKUP SUMMARY                               |+| ..........................: 
|+|-|  5 | REPORT OBSOLETE                                   |+|-|   6 | LIST FAILURES                                     |+| ..........................: 
|+|-|  7 | LIST FAILURES CLOSED                              |+|-|   8 | ADVISE FAILURES                                   |+| ..........................: 
|+|-|  9 | REPORT VALIDATE DATABASE                          |+|-|  10 | RESTORE DATABASE PREVIEW                          |+| ..........................: 
|+|-| 11 | RESTORE DATABASE PREVIEW SUMMARY                  |+|-|  12 | RECOVER DATABASE PREVIEW                          |+| ..........................: 
|+|-| 13 | RECOVER DATABASE PREVIEW SUMMARY                  |+|-|  14 |                                                   |+| ..........................: 
|+|-| 15 |                                                   |+|-|  16 |                                                   |+| ..........................: 
|+|-| 17 |                                                   |+|-|  18 |                                                   |+| ..........................: 
|+|-| 19 |                                                   |+|-|  20 |                                                   |+| ..........................: 
|+|-| 21 |                                                   |+|-|  22 |                                                   |+| ..........................: 
|+|-| 23 |                                                   |+|-|  24 |                                                   |+| ..........................: 
|+|-| 25 |                                                   |+|-|  26 |                                                   |+| ..........................: 
|+|-| 27 |                                                   |+|-|  28 |                                                   |+| ..........................: 
|+|-| 29 |                                                   |+|-|  30 |                                                   |+| ..........................: 
|+|-| 31 |                                                   |+|-|  32 |                                                   |+| ..........................: 
|+|-| 33 |                                                   |+|-|  34 |                                                   |+| ..........................: 
|+|-| 35 |                                                   |+|-|  36 |                                                   |+| ..........................: 
|+|-| 37 |                                                   |+|-|  38 |                                                   |+| ..........................: 
|+|-| 39 |                                                   |+|-|  40 |                                                   |+| ..........................: 
|+|-| 41 |                                                   |+|-|  42 |                                                   |+| ..........................: 
|+|-| 43 |                                                   |+|-|  44 |                                                   |+| ..........................: 
|+|-| 45 |                                                   |+|-|  46 |                                                   |+| ..........................: 
|+|-| 47 |                                                   |+|-|  48 |                                                   |+| ..........................: 
|+|-| 49 |                                                   |+|-|  50 |                                                   |+| ..........................: 
|+|-| 51 |                                                   |+|-|  52 |                                                   |+| ..........................: 
|+|-| 53 |                                                   |+|-|  54 |                                                   |+| ..........................: 
|+|-| 55 |                                                   |+|-|  56 |                                                   |+| ..........................: 
|+|-| 57 |                                                   |+|-|  58 |                                                   |+| ..........................: 
|+|-| 59 |                                                   |+|-|  60 |                                                   |+| ..........................: 
|+|-| 61 |                                                   |+|-|  62 |                                                   |+| ..........................: 
|+|-| 63 |                                                   |+|-|  64 |                                                   |+| ..........................: 
|+|-| 65 |                                                   |+|-|  66 |                                                   |+| ..........................: 
|+|-| 67 |                                                   |+|-|  68 |                                                   |+| ..........................: 
|+|-| 69 |                                                   |+|-|  70 |                                                   |+| ..........................: 
|+|-| 71 |                                                   |+|-|  72 |                                                   |+| ..........................: 
|+|-| 73 |                                                   |+|-|  74 |                                                   |+| ..........................: 
|+|-| 75 |                                                   |+|-|  76 |                                                   |+| ..........................: 
|+|-| 77 |                                                   |+|-|  78 |                                                   |+| ..........................: 
|+|-| 79 |                                                   |+|-|  80 |                                                   |+| ..........................: 
|+|-| 81 |                                                   |+|-|  82 |                                                   |+| ..........................: 
|+|-| 83 |                                                   |+|-|  84 |                                                   |+| ..........................: 
|+|-| 85 |                                                   |+|-|  86 |                                                   |+| ..........................: 
|+|-| 87 |                                                   |+|-|  88 |                                                   |+| ..........................: 
|+|-| 89 |                                                   |+|-|  90 |                                                   |+| ..........................: 
|+|-| 91 |                                                   |+|-|  92 |                                                   |+| ..........................: 
|+|-| 93 |                                                   |+|-|  94 |                                                   |+| ..........................: 
|+|-| 95 |                                                   |+|-|  96 |                                                   |+| ..........................: 
|+|-| 97 |                                                   |+|-|  98 |                                                   |+| ..........................: 
|+|-| 99 | REPORT                                            |+|-| 100 | EXTRAS                                            |+| ..........................: 
+-+-+----+---------------------------------------------------+-+-+-----+---------------------------------------------------+-+---------------------------+-+----------------------------------------------------+
| CHOOSE ONE OF THOSE OPTIONS [ 0 - 100 ] | OPTIONS WITH [ @ ] HAS MORE FILTERS | VERSION: ${SoftwareVersion} | MODIFIED: ${DateofModification} | DATE & TIME: ${varDATE} ${varTIME}
+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+" 0 0 3>&1 1>&2 2>&3 3>&-)
exit_status=$?
exec 3>&-
case ${exit_status} in ${DIALOG_CANCEL})
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "Exit Program" --gauge "Program Closed" 7 50 >&2
MainMenu
;;
${DIALOG_ESC})
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "Exit Program" --gauge "Program Aborted" 7 50 >&2
MainMenu
;;
esac
case ${SelectRMAN} in
  1)    for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "RMAN: VERIFY RMAN CONFIGURATIONS" --gauge "RMAN: VERIFY RMAN CONFIGURATIONS" 7 50 >&2
    SepLine
    echo "RMAN: VERIFY RMAN CONFIGURATIONS"
    Func_RMAN_001
    Continue
    ;;
  2)    for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "RMAN: VIEW GENERAL REPORT" --gauge "RMAN: VIEW GENERAL REPORT" 7 50 >&2
    SepLine
    echo "RMAN: VIEW GENERAL REPORT"
    Func_RMAN_002
	Continue
    ;;
  3)    for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "RMAN: LIST BACKUP" --gauge "RMAN: LIST BACKUP" 7 50 >&2
    SepLine
    echo "RMAN: LIST BACKUP"
    Func_RMAN_003
    Continue
    ;;
  4)    for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "RMAN: LIST BACKUP SUMMARY" --gauge "RMAN: LIST BACKUP SUMMARY" 7 50 >&2
    SepLine
    echo "RMAN: LIST BACKUP SUMMARY"
    Func_RMAN_004
    Continue
    ;;
  5)    for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "RMAN: REPORT OBSOLETE" --gauge "RMAN: REPORT OBSOLETE" 7 50 >&2
    SepLine
    echo "RMAN: REPORT OBSOLETE"
    Func_RMAN_005
    Continue
    ;;
  6)    for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "RMAN: LIST FAILURES" --gauge "RMAN: LIST FAILURES" 7 50 >&2
    SepLine
    echo "RMAN: LIST FAILURES"
    Func_RMAN_006
    Continue
    ;;
  7)    for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "RMAN: LIST FAILURES CLOSED" --gauge "RMAN: LIST FAILURES CLOSED" 7 50 >&2
    SepLine
    echo "RMAN: LIST FAILURES CLOSED"
    Func_RMAN_007
    Continue
    ;;
  8)    for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "RMAN: ADVISE FAILURES" --gauge "RMAN: ADVISE FAILURES" 7 50 >&2
    SepLine
    echo "RMAN: ADVISE FAILURES"
    Func_RMAN_008
    Continue
    ;;
  9)    for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "RMAN: REPORT VALIDATE DATABASE" --gauge "RMAN: REPORT VALIDATE DATABASE" 7 50 >&2
    SepLine
    echo "RMAN: REPORT VALIDATE DATABASE"
    Func_RMAN_009
    Continue
    ;;
  10)    for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "RMAN: RESTORE DATABASE PREVIEW" --gauge "RMAN: RESTORE DATABASE PREVIEW" 7 50 >&2
    SepLine
    echo "RMAN: RESTORE DATABASE PREVIEW"
    Func_RMAN_010
    Continue
    ;;
  11)    for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "RMAN: RESTORE DATABASE PREVIEW SUMMARY" --gauge "RMAN: RESTORE DATABASE PREVIEW SUMMARY" 7 50 >&2
    SepLine
    echo "RMAN: RESTORE DATABASE PREVIEW SUMMARY"
    Func_RMAN_011
    Continue
    ;;
  12)    for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "RMAN: RECOVER DATABASE PREVIEW" --gauge "RMAN: RECOVER DATABASE PREVIEW" 7 50 >&2
    SepLine
    echo "RMAN: RECOVER DATABASE PREVIEW"
    Func_RMAN_012
    Continue
    ;;
  13)    for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "RMAN: RECOVER DATABASE PREVIEW SUMMARY" --gauge "RMAN: RECOVER DATABASE PREVIEW SUMMARY" 7 50 >&2
    SepLine
    echo "RMAN: RECOVER DATABASE PREVIEW SUMMARY"
    Func_RMAN_013
    Continue
    ;;
  14)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_014)" 0 0
    ;;
  15)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_015)" 0 0
    ;;
  16)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_016)" 0 0
    ;;
  17)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_017)" 0 0
    ;;
  18)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_018)" 0 0
    ;;
  19)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_019)" 0 0
    ;;
  20)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_020)" 0 0
    ;;
  21)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_021)" 0 0
    ;;
  22)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_022)" 0 0
    ;;
  23)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_023)" 0 0
    ;;
  24)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_024)" 0 0
    ;;
  25)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_025)" 0 0
    ;;
  26)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_026)" 0 0
    ;;
  27)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_027)" 0 0
    ;;
  28)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_028)" 0 0
    ;;
  29)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_029)" 0 0
    ;;
  30)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_030)" 0 0
    ;;
  31)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_031)" 0 0
    ;;
  32)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_032)" 0 0
    ;;
  33)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_033)" 0 0
    ;;
  34)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_034)" 0 0
    ;;
  35)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_035)" 0 0
    ;;
  36)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_036)" 0 0
    ;;
  37)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_037)" 0 0
    ;;
  38)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_038)" 0 0
    ;;
  39)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_039)" 0 0
    ;;
  40)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_040)" 0 0
    ;;
  41)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_041)" 0 0
    ;;
  42)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_042)" 0 0
    ;;
  43)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_043)" 0 0
    ;;
  44)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_044)" 0 0
    ;;
  45)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_045)" 0 0
    ;;
  46)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_046)" 0 0
    ;;
  47)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_047)" 0 0
    ;;
  48)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_048)" 0 0
    ;;
  49)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_049)" 0 0
    ;;
  50)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: " --no-collapse --colors --msgbox "$(Func_RMAN_050)" 0 0
    ;;
  99)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: REPORT" --no-collapse --colors --msgbox "$(Func_RMAN_099)" 0 0
    ;;
  100)    dialog --backtitle "www.DBNITRO.net" --title "RMAN: EXTRAS" --no-collapse --colors --msgbox "$(Func_RMAN_100)" 0 0
    ;;
  esac
done
}
#
#########################################################################################################
# RMAN: VERIFY RMAN CONFIGURATIONS
#########################################################################################################
#
#########################################################################################################
#
# Database Menu
#
#########################################################################################################
#
DATABASE() {
#
#########################################################################################################
# Verify DATABASE
#########################################################################################################
#
if [[ "${varDB}" == "N" ]]; then
  dialog --backtitle "www.DBNITRO.net" --title "Database Menu" --no-collapse --colors --msgbox "Your Database is Not Available" 7 70
  MainMenu
fi
#
#
#########################################################################################################
# Variables Database Menu
#########################################################################################################
#
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "Variable: Database Menu" --no-collapse --colors --gauge "Loading Database Variables" 7 50
#

. ${DBNITRO}/var/MainMenu.${ORACLE_SID}.var

if [[ ${varDB_RELEASE} = "11" ]]; then
  Func_Set_Database_11_Var
else
  Func_Set_Database_Var
fi

. ${DBNITRO}/var/Database.${ORACLE_SID}.var

#
### Verify if is in Containering Techonology ###
#
if [[ ${varDB_RELEASE} -ge 12 ]]; then
sqlplus -S '/ as sysdba' > ${DBNITRO}/var/Container.${ORACLE_SID}.var <<EOF | tail -2
set define off trims on newp none heads off echo off feed off numwidth 20 pagesize 0 null null verify off wrap off timing off serveroutput off termout off heading off
alter session set nls_date_format='dd/mm/yyyy';
select case when cdb = 'YES' then 'varDB_CONTAINER="Y"' else 'varDB_CONTAINER="N"' end from v\$database;
select 'varDB_PLUGGABLE_QTD="' || count(name)  || '"' from v\$containers where con_id not in (0,1,2);
select 'varDB_MAX_PDBS="'      || value        || '"' from v\$parameter where name = 'max_pdbs';
quit;
EOF
. ${DBNITRO}/var/Container.${ORACLE_SID}.var
else
  varDB_CONTAINER="N"
  varDB_PLUGGABLE_QTD="0"
  varDB_MAX_PDBS="0"
fi
#
### Verify the names of Pluggable Databases ###
#
if [[ ${varDB_CONTAINER} = "Y" ]] && [[ ${varDB_PLUGGABLE_QTD} != 0 ]]; then
sqlplus -S '/ as sysdba' > ${DBNITRO}/var/Pluggable.var <<EOF | tail -2
set define off trims on newp none heads off echo off feed off numwidth 20 pagesize 0 null null verify off wrap off timing off serveroutput off termout off heading off
alter session set nls_date_format='dd/mm/yyyy';
-- select 'ALL' from dual;
select name from v\$containers order by 1;
-- select name from v\$containers where con_id not in (0,1,2) order by 1;
quit;
EOF
  varDB_PDBS="${DBNITRO}/var/Pluggable.${ORACLE_SID}.var"
  varDB_PLUGGABLE="Y"
else
  varDB_PDBS="${DBNITRO}/var/Pluggable.${ORACLE_SID}.var"
  varDB_PLUGGABLE="N"
fi

#
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "Database Menu" --no-collapse --colors --gauge "Open Database Menu" 7 50
#
varDATE=$(date +%d\/%m\/%Y)
varTIME=$(date +%H\:%M)
#
while true; do
exec 3>&1
SelectDatabase=$(dialog --backtitle "www.DBNITRO.net" --title "Database Menu" --clear --cancel-label "Back" --no-collapse --colors --inputbox "\
+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| OS: ${varOS} | UPTIME: ${varUPTIME} | KERNEL: ${varKERNEL} | PROCS: ${varPhysical_CPU} | MEMORY: ${varTotal_MEMORY} | MEM_USED: ${varUsed_MEMORY} | MEM_FREE: ${varFree_MEMORY} | SWAP: ${varSwap_MEMORY} | SWAP_USED: ${varSwap_USED_MEMORY} | SWAP_FREE: ${varSwap_Free_MEMORY}
+-+-+-----+-------------------------------------------------------+-+-+-----+-------------------------------------------------------+-+------------------------------+-+-------------------------------------------------+
|+|-|   1 | DBA: VERIFY DATABASE VERSION                          |+|-|   2 | DBA: VERIFY INSTALLED PATCHES - DETAILS               |+| DATABASE_RELEASE.............: \Zb\Z1 ${varDB_RELEASE} \Zn
|+|-|   3 | DBA: INSTANCE INFORMATION + PGA & SGA                 |+|-|   4 | DBA: GENERAL TUNING VIEW                              |+| DATABASE_VERSION.............: \Zb\Z1 ${varDB_VERSION} \Zn
|+|+|   5 | DBA: DATABASE GROWN ON LASTS MONTHS                   |+|-|   6 | DBA: CONNECTIONS AVERAGE PER HOUR                     |+| DATABASE_EDITION.............: \Zb\Z1 ${varDB_EDITION} \Zn 
|+|-|   7 | DBA: TOP 20 DB-CPU ACTIVITY                           |+|-|   8 | DBA: VERIFY SESSIONS PER MEMORY                       |+| ACTIVE_STATE.................: \Zb\Z1 ${varDB_ACTIVE_STATE} \Zn
|+|-|   9 | DBA: DATABASE SIZE                                    |+|-|  10 | DBA: VERIFY SESSIONS PER I/O                          |+| OPEN_MODE....................: \Zb\Z1 ${varDB_MODE} \Zn
|+|-|  11 | DBA: HIT RATIO THE LASTS 30 DAYS                      |+|-|  12 | DBA: VERIFY LONG OPERATIONS                           |+| DATABASE_ROLE................: \Zb\Z1 ${varDB_ROLE} \Zn
|+|-|  13 | DBA: INVALIDS OBJECTS [ @ ]                           |+|-|  14 | DBA: JOBS CONTROL OF THE CLIENT [ @ ]                 |+| INSTANCE_NAME................: \Zb\Z1 ${ORACLE_SID} \Zn
|+|-|  15 | DBA: MATERIALIZEDS VIEWS DISABLED                     |+|-|  16 | DBA: VERIFY RUNNING JOBS                              |+| DB_UNIQUE_NAME...............: \Zb\Z1 ${varDB_UNIQ_NAME} \Zn
|+|-|  17 | DBA: KILL A RUNNING SESSION [ @ ]                     |+|-|  18 | DBA: VERIFY PROFILE INFORMATION                       |+| SERVICE_NAME.................: \Zb\Z1 ${varDB_SRV_NAME} \Zn
|+|-|  19 | DBA: BACKUP STATISTICS                                |+|-|  20 | DBA: QTD OF ARCHIVES PER HOUR                         |+| DB_BLOCK_SIZE................: \Zb\Z1 ${varDB_BLOC_SIZE_K}(K) # ${varDB_BLOC_SIZE_M}(M) \Zn
|+|-|  21 | DBA: LAST FILE OF LAST BACKUP ARCH - RMAN             |+|-|  22 | DBA: LAST FILE OF LAST BACKUP FULL - RMAN             |+| MEM_MAX_TARGET...............: \Zb\Z1 ${varDB_MEM_MAX_M}(M) # ${varDB_MEM_MAX_G}(G) # ${varDB_MEM_MAX_T}(T) \Zn
|+|-|  23 | DBA: ARCHIVES GENERATED PER DAY                       |+|-|  24 | DBA: BACKUP LOG OF LAST BACKUP FULL - RMAN            |+| MEM_TARGET...................: \Zb\Z1 ${varDB_MEM_TAR_M}(M) # ${varDB_MEM_TAR_G}(G) # ${varDB_MEM_TAR_T}(T) \Zn
|+|-|  25 | DBA: BACKUP LOG OF LASTS ARCHIVES - RMAN              |+|-|  26 | DBA: ERRORS ON ALERT LOG FILE                         |+| SGA_MAX_SIZE.................: \Zb\Z1 ${varDB_SGA_MAX_M}(M) # ${varDB_SGA_MAX_G}(G) # ${varDB_SGA_MAX_T}(T) \Zn
|+|-|  27 | DBA: ORACLE ENTERPRISE MANAGER ALERT                  |+|-|  28 | DBA: CAPTURE STATISTICS OF DATA DICTIONARY            |+| SGA_TARGET...................: \Zb\Z1 ${varDB_SGA_TAR_M}(M) # ${varDB_SGA_TAR_G}(G) # ${varDB_SGA_TAR_T}(T) \Zn
|+|-|  29 | DBA: CAPTURE STATISTICS OF ALL DATABASE               |+|-|  30 | DBA: BLOCKING LOCKS                                   |+| PGA_AGGREGATE_LIMIT..........: \Zb\Z1 ${varDB_PGA_LIM_K}(K) # ${varDB_PGA_LIM_M}(M) # ${varDB_PGA_LIM_G}(G) \Zn
|+|-|  31 | DBA: LOCKED OBJECTS                                   |+|-|  32 | DBA: BLOCKING LOCKS [ SUMARY ]                        |+| PGA_AGGREGATE_TARGET.........: \Zb\Z1 ${varDB_PGA_TAR_K}(K) # ${varDB_PGA_TAR_M}(M) # ${varDB_PGA_TAR_G}(G) \Zn
|+|-|  33 | DBA: BLOCKING LOCKS [ USER DETAILS ]                  |+|-|  34 | DBA: BLOCKING LOCKS [ WAITING SQL ]                   |+| DATABASE_UPTIME..............: \Zb\Z1 ${varDB_UPTIME} # ${varDB_UPTIME_D} Day(s) UP \Zn
|+|-|  35 | DBA: LOCKED OBJECTS [ DETAILS ]                       |+|-|  36 | DBA: DML AND DDL LOCKS                                |+| WAS_UPDATED_ON...............: \Zb\Z1 ${varDB_VER_TIME} # ${varDB_VER_TIME_D} Day(s) Ago \Zn
|+|-|  37 | DBA: DML TABLE LOCKS TIME                             |+|-|  38 | DBA: VERIFY SESSIONS [ @ ]                            |+| DATABASE_SIZE................: \Zb\Z1 ${varDB_TOT_SIZE_M}(M) # ${varDB_TOT_SIZE_G}(G) # ${varDB_TOT_SIZE_T}(T) \Zn
|+|-|  39 | DBA: TOP 20 DATABASE SESSIONS                         |+|-|  40 | DBA: VERIFY TABLESPACES                               |+| DB_CACHE_SIZE................: \Zb\Z1 ${varDB_CACHE_SIZE_K} # ${varDB_CACHE_SIZE_M}(M) # ${varDB_CACHE_SIZE_G}(G) \Zn
|+|-|  41 | DBA: VERIFY STATISTICS - TABLES [ @ ]                 |+|-|  42 | DBA: VERIFY STATISTICS - INDEXES [ @ ]                |+| SHARED_POOL_SIZE.............: \Zb\Z1 ${varDB_SHARED_POOL_K}(K) # ${varDB_SHARED_POOL_M}(M) # ${varDB_SHARED_POOL_G}(G) \Zn
|+|-|  43 | DBA: CAPTURE STATISTICS - OWNER [ @ ]                 |+|-|  44 | DBA: VALIDATE OBJECTS FROM ONE OWNER [ @ ]            |+| SCN..........................: \Zb\Z1 ${varDB_SCN} \Zn
|+|-|  45 | DBA: VERIFY TABLES SIZE, VALIDATE OBJ - OWNERS [ @ ]  |+|-|  46 | DBA: OWNER X OBJECTS X TYPE X QTD                     |+| ARCHIVE_MODE.................: \Zb\Z1 ${varDB_ARCH_MODE} \Zn
|+|-|  47 | DBA: VERIFY INSTANCE CHARACTERSET                     |+|-|  48 | DBA: CACHE HIT RATIO [ GOOD: > 90% ]                  |+| EXADATA......................: \Zb\Z1 ${varEXA} \Zn
|+|-|  49 | DBA: VERIFY INSTANCE INSTALLED PRODUCTS               |+|-|  50 | DBA: INSTANCE PROPERTIES                              |+| ASM / RAC....................: \Zb\Z1 ASM: ${varASM} # RAC: ${varRAC} \Zn
|+|-|  51 | DBA: INSTANCE OPTIONS                                 |+|-|  52 | DBA: INSTANCE DIFFERENTS PARAMETERS                   |+| DATAGUARD....................: \Zb\Z1 ${varODG} \Zn
|+|-|  53 | DBA: INSTANCE MODIFICABLES PARAMETERS                 |+|-|  54 | DBA: VERIFY DEAD LOCKS                                |+| GOLDENGATE...................: \Zb\Z1 ${varOGG} \Zn
|+|-|  55 | DBA: VERIFY SESSIONS PER I/O CONSUME                  |+|-|  56 | DBA: VERIFY FREE SEGMENTS ON DATAFILES                |+| PARTITIONING.................: \Zb\Z1 ${varDB_PARTITION} \Zn
|+|-|  57 | DBA: VERIFY WHICH DATAFILE CAN BE RESIZED [ @ ]       |+|-|  58 | DBA: VERIFY RECYCLEBIN                                |+| SQL_TUNING...................: 
|+|-|  59 | DBA: CLEAR REYICLEBIN                                 |+|-|  60 | DBA: VERIFY DATABASE SESSIONS                         |+| SPATIAL......................: \Zb\Z1 ${varDB_SPATIAL} \Zn
|+|-|  61 | DBA: VERIFY ACTIVES SESSIONS PER OWNER                |+|-|  62 | DBA: UNLOCKING A USER [ @ ]                           |+| MULTIMEDIA...................: \Zb\Z1 ${varDB_MULTIMEDIA} \Zn
|+|-|  63 | DBA: LOCKING A USER [ @ ]                             |+|-|  64 | DBA: REDO GROUPS INFORMATIONS                         |+| TEXT.........................: \Zb\Z1 ${varDB_TEXT} \Zn
|+|-|  65 | DBA: SHOW ALL CORRUPTED OBJECTS                       |+|-|  66 | DBA: VERIFY SPACE OF FLASH RECOVERY AREA              |+| STBY_FILE_MANAGEMENT.........: \Zb\Z1 ${varDB_STBY_FILE_MAN} \Zn
|+|-|  67 | DBA: TOTAL USERS COUNT ON DATABASE                    |+|-|  68 | DBA: VERIFY CONTROLFILES                              |+| FORCE_LOGGING................: \Zb\Z1 ${varDB_FORCE_LOGGING} \Zn
|+|-|  69 | DBA: VERIFY CONSUME PER CPU                           |+|-|  70 | DBA: QUICK TUNE                                       |+| FLASHBACK....................: \Zb\Z1 ${varDB_FLASBBACK_ON} \Zn
|+|-|  71 | DBA: VERIFY RECOMENDATIONS TUNING TOP 20 [ @ ]        |+|-|  72 | DBA: VERIFY TOP 20 TUNING HISTORY [ @ ]               |+| FLASHBACK_SIZE...............: \Zb\Z1 ${varDB_FLASH_SIZE_M}(M) # ${varDB_FLASH_SIZE_G}(G) # ${varDB_FLASH_SIZE_T}(T) \Zn
|+|-|  73 | DBA: VERIFY BACKGROUND PROCESSESS                     |+|-|  74 | DBA: TOP 100 QUERY RECOMMENDATIONS                    |+| FLASHBACK_RETENTION..........: \Zb\Z1 ${varDB_FLASH_RETENTION_MINUTES}(M) # ${varDB_FLASH_RETENTION_HOURS}(H) # ${varDB_FLASH_RETENTION_DAYS}(D) \Zn
|+|-|  75 | DBA: VERIFY DYNAMICS PARAMETERS [ SPFILE ]            |+|-|  76 | DBA: VERIFY DBA FEATURES USAGE STATISTICS             |+| PROTECTION_MODE..............: \Zb\Z1 ${varDB_PROTECTION_MODE} \Zn
|+|-|  77 | DBA: VERIFY DBA HIGH WATER MARK STATISTICS            |+|-|  78 | DBA: GLOBAL INFORMATION ABOUT I/O                     |+| DB_RECOVERY_DEST_SIZE........: \Zb\Z1 ${varDB_RECOVERY_FILE_DEST_G}(G) # ${varDB_RECOVERY_FILE_DEST_T}(T) # ${varDB_RECOVERY_FILE_DEST_PERC} \Zn
|+|-|  79 | DBA: WHICH SEG. HAVE TOP LOGICAL I/O - PHYSICAL I/O   |+|-|  80 | DBA: VERIFY DBLINKS & FOLDERS INFO                    |+| UNDO_RETENTION...............: \Zb\Z1 ${varDB_UNDO_RETENTION_SECONDS}(S) # ${varDB_UNDO_RETENTION_MINUTES}(M) # ${varDB_UNDO_RETENTION_HOURS}(H) \Zn
|+|-|  81 | DBA: IDENTIFYING WHEN A PASSWORD WAS LAST CHANGED     |+|-|  82 | DBA: VERIFY UNDO SEGMENTS                             |+| ARCH_LAG_TARGET..............: \Zb\Z1 ${varDB_ARCH_LAG_TARGET} # ${varDB_ARCH_LAG_TARGET_MINUTES}(M) # ${varDB_ARCH_LAG_TARGET_HOURS}(H) # ${varDB_ARCH_LAG_TARGET_DAYS}(D) \Zn
|+|-|  83 | DBA: VERIFY ALL SQL STATEMENTS                        |+|-|  84 | DBA: CLONE USER COMMANDS [ @ ]                        |+| LOG_ARCH_FORMAT..............: \Zb\Z1 ${varDB_ARCH_LOG_FORMAT} \Zn
|+|-|  85 | DBA: VERIFY ALL INFOS ABOUT SYSAUX                    |+|-|  86 | DBA: VERIFY ALL INFOS ABOUT I/O + LATENCY             |+| OPEN_CURSORS.................: \Zb\Z1 ${varDB_OPEN_CURSORS} \Zn
|+|-|  87 | DBA: VERIFY MAIN TOP WAIT EVENTS PER WEEK             |+|-|  88 | DBA: VERIFY OBJECTS SIZE                              |+| PROCESSES....................: \Zb\Z1 ${varDB_PROCESSES} \Zn
|+|-|  89 | DBA: GENERAL DATABASE OVERVIEW                        |+|-|  90 | DBA: DATABASE DASHBOARD                               |+| RECYCLEBIN...................: \Zb\Z1 ${varDB_RECYCLEBIN} \Zn
|+|-|  91 | DBA: VERIFY ALL SQL IDS STATEMENTS                    |+|-|  92 | DBA: VERIFY NLS CONFIGURATION                         |+| ORA-00600_ALERTLOG_( 30-D )..: \Zb\Z1 ${varDB_ORA0600} \Zn
|+|-|  93 | DBA: VERIFY FAILED LOGIN                              |+|-|  94 | DBA: VERIFY ALL SQL IDS STATEMENTS                    |+| ERRORS_ALERTLOG_( 30-D ).....: \Zb\Z1 ${varDB_ORA_ERRORS} \Zn
|+|-|  95 | DBA: VERIFY ALL PATCHES APPLIED                       |+|-|  96 | DBA: VERIFY CPU USAGE BY MINUTE                       |+| TBS_SPACE_(WARNING/CRITICAL).: \Zb\Z1 ${varDB_TBS_SPACE} \Zn
|+|-|  97 | DBA: VERIFY STANDBY CONFIGURATION                     |+|-|  98 | DBA: VERIFY GRANTS AND PERMISSIONS BY OWNER           |+| CONTAINER / MAX / QTD_PDB....: \Zb\Z1 CDB: ${varDB_CONTAINER} # MAX: ${varDB_MAX_PDBS} # PDBS: ${varDB_PLUGGABLE_QTD} \Zn
|+|-|  99 | DBA: USER DETAILS SESSIONS                            |+|-| 100 | DBA: VERIFY BACKUP RUNNING ON REAL TIME               |+| .............................:
|+|-| 101 | DBA: VERIFY DATABASE COMPONENTS FROM REGISTRY         |+|-| 102 | DBA: VERIFY ORACLE NET SEND AND RECEIVE SIZE VOLUME   |+| .............................:
+-+-+-----+-------------------------------------------------------+-+-+-----+-------------------------------------------------------+-+------------------------------+-+-------------------------------------------------+
| CHOOSE ONE OF THOSE OPTIONS [ 0 - 100 ] | OPTIONS WITH [ @ ] HAS MORE FILTERS | VERSION: ${SoftwareVersion} | MODIFIED: ${DateofModification} | DATE & TIME: ${varDATE} ${varTIME}
+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+" 0 0 3>&1 1>&2 2>&3 3>&-)
exit_status=$?
exec 3>&-
case ${exit_status} in ${DIALOG_CANCEL})
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "Exit Program" --gauge "Program Closed" 7 50 >&2
MainMenu
;;
${DIALOG_ESC})
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "Exit Program" --gauge "Program Aborted" 7 50 >&2
MainMenu
;;
esac
case ${SelectDatabase} in
  1)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY DATABASE VERSION" --gauge "DBA: VERIFY DATABASE VERSION" 7 50 >&2
      SepLine
      DBA_001
      Continue
  ;;
  2)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY INSTALLED PATCHES - DETAILS" --gauge "DBA: VERIFY INSTALLED PATCHES - DETAILS" 7 50 >&2
      SepLine
      DBA_002
      Continue
  ;;
  3)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: INSTANCE INFORMATION + PGA & SGA" --gauge "DBA: INSTANCE INFORMATION + PGA & SGA" 7 50 >&2
      SepLine
      DBA_003
      Continue
  ;;
  4)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: GENERAL TUNING VIEW" --gauge "DBA: GENERAL TUNING VIEW" 7 50 >&2
      SepLine
      DBA_004
      Continue
  ;;
  5)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: DATABASE GROWN ON LASTS MONTHS" --gauge "DBA: DATABASE GROWN ON LASTS MONTHS" 7 50 >&2
      SepLine
      DBA_005
      Continue
  ;;
  6)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: CONNECTIONS AVERAGE PER HOUR" --gauge "DBA: CONNECTIONS AVERAGE PER HOUR" 7 50 >&2
      SepLine
      DBA_006
      Continue
  ;;
  7)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: TOP 20 DB-CPU ACTIVITY" --gauge "DBA: TOP 20 DB-CPU ACTIVITY" 7 50 >&2
      SepLine
      DBA_007
      Continue
  ;;
  8)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY SESSIONS PER MEMORY" --gauge "DBA: VERIFY SESSIONS PER MEMORY" 7 50 >&2
      SepLine
      DBA_008
      Continue
  ;;
  9)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: DATABASE SIZE" --gauge "DBA: DATABASE SIZE" 7 50 >&2
      SepLine
      DBA_009
      Continue
  ;;
  10)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY SESSIONS PER I/O" --gauge "DBA: VERIFY SESSIONS PER I/O" 7 50 >&2
      SepLine
      DBA_010
      Continue
  ;;
  11)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: HIT RATIO THE LASTS 30 DAYS" --gauge "DBA: HIT RATIO THE LASTS 30 DAYS" 7 50 >&2
      SepLine
      DBA_011
      Continue
  ;;
  12)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY LONG OPERATIONS" --gauge "DBA: VERIFY LONG OPERATIONS" 7 50 >&2
      SepLine
      DBA_012
      Continue
  ;;
  13)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: INVALIDS OBJECTS [ @ ]" --gauge "DBA: INVALIDS OBJECTS [ @ ]" 7 50 >&2
      SepLine
      DBA_013
      Continue
  ;;
  14)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: JOBS CONTROL OF THE CLIENT [ @ ]" --gauge "DBA: JOBS CONTROL OF THE CLIENT [ @ ]" 7 50 >&2
      SepLine
      DBA_014
      Continue
  ;;
  15)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: MATERIALIZEDS VIEWS DISABLED" --gauge "" 7 50 >&2
      SepLine
      DBA_015
      Continue
  ;;
  16)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY RUNNING JOBS" --gauge "DBA: VERIFY RUNNING JOBS" 7 50 >&2
      SepLine
      DBA_016
      Continue
  ;;
  17)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: KILL A RUNNING SESSION [ @ ]" --gauge "DBA: KILL A RUNNING SESSION [ @ ]" 7 50 >&2
      SepLine
      DBA_017
      Continue
  ;;
  18)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY PROFILE INFORMATION" --gauge "DBA: VERIFY PROFILE INFORMATION" 7 50 >&2
      SepLine
      DBA_018
      Continue
  ;;
  19)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: BACKUP STATISTICS" --gauge "DBA: BACKUP STATISTICS" 7 50 >&2
      SepLine
      DBA_019
      Continue
  ;;
  20)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: QTD OF ARCHIVES PER HOUR" --gauge "DBA: QTD OF ARCHIVES PER HOUR" 7 50 >&2
      SepLine
      DBA_020
      Continue
  ;;
  21)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: LAST FILE OF LAST BACKUP ARCH - RMAN" --gauge "DBA: LAST FILE OF LAST BACKUP ARCH - RMAN" 7 50 >&2
      SepLine
      DBA_021
      Continue
  ;;
  22)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: LAST FILE OF LAST BACKUP FULL - RMAN" --gauge "DBA: LAST FILE OF LAST BACKUP FULL - RMAN" 7 50 >&2
      SepLine
      DBA_022
      Continue
  ;;
  23)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: ARCHIVES GENERATED PER DAY" --gauge "DBA: ARCHIVES GENERATED PER DAY" 7 50 >&2
      SepLine
      DBA_023
      Continue
  ;;
  24)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: BACKUP LOG OF LAST BACKUP FULL - RMAN" --gauge "DBA: BACKUP LOG OF LAST BACKUP FULL - RMAN" 7 50 >&2
      SepLine
      DBA_024
      Continue
  ;;
  25)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: BACKUP LOG OF LASTS ARCHIVES - RMAN" --gauge "DBA: BACKUP LOG OF LASTS ARCHIVES - RMAN" 7 50 >&2
      SepLine
      DBA_025
      Continue
  ;;
  26)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: ERRORS ON ALERT LOG FILE" --gauge "DBA: ERRORS ON ALERT LOG FILE" 7 50 >&2
      SepLine
      DBA_026
      Continue
  ;;
  27)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: ORACLE ENTERPRISE MANAGER ALERT" --gauge "DBA: ORACLE ENTERPRISE MANAGER ALERT" 7 50 >&2
      SepLine
      DBA_027
      Continue
  ;;
  28)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: CAPTURE STATISTICS OF DATA DICTIONARY" --gauge "DBA: CAPTURE STATISTICS OF DATA DICTIONARY" 7 50 >&2
      SepLine
      DBA_028
      Continue
  ;;
  29)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: CAPTURE STATISTICS OF ALL DATABASE" --gauge "DBA: CAPTURE STATISTICS OF ALL DATABASE" 7 50 >&2
      SepLine
      DBA_029
      Continue
  ;;
  30)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: BLOCKING LOCKS" --gauge "DBA: BLOCKING LOCKS" 7 50 >&2
      SepLine
      DBA_030
      Continue
  ;;
  31)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: LOCKED OBJECTS" --gauge "DBA: LOCKED OBJECTS" 7 50 >&2
      SepLine
      DBA_031
      Continue
  ;;
  32)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: BLOCKING LOCKS [ SUMARY ]" --gauge "DBA: BLOCKING LOCKS [ SUMARY ]" 7 50 >&2
      SepLine
      DBA_032
      Continue
  ;;
  33)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: BLOCKING LOCKS [ USER DETAILS ]" --gauge "DBA: BLOCKING LOCKS [ USER DETAILS ]" 7 50 >&2
      SepLine
      DBA_033
      Continue
  ;;
  34)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: BLOCKING LOCKS [ WAITING SQL ]" --gauge "DBA: BLOCKING LOCKS [ WAITING SQL ]" 7 50 >&2
      SepLine
      DBA_034
      Continue
  ;;
  35)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: LOCKED OBJECTS [ DETAILS ]" --gauge "DBA: LOCKED OBJECTS [ DETAILS ]" 7 50 >&2
      SepLine
      DBA_035
      Continue
  ;;
  36)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: DML AND DDL LOCKS" --gauge "DBA: DML AND DDL LOCKS" 7 50 >&2
      SepLine
      DBA_036
      Continue
  ;;
  37)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: DML TABLE LOCKS TIME" --gauge "DBA: DML TABLE LOCKS TIME" 7 50 >&2
      SepLine
      DBA_037
      Continue
  ;;
  38)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY SESSIONS [ @ ]" --gauge "DBA: VERIFY SESSIONS [ @ ]" 7 50 >&2
      SepLine
      DBA_038
      Continue
  ;;
  39)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: TOP 20 DATABASE SESSIONS" --gauge "DBA: TOP 20 DATABASE SESSIONS" 7 50 >&2
      SepLine
      DBA_039
      Continue
  ;;
  40)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY TABLESPACES" --gauge "DBA: VERIFY TABLESPACES" 7 50 >&2
      SepLine
      DBA_040
      Continue
  ;;
  41)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY STATISTICS - TABLES [ @ ]" --gauge "DBA: VERIFY STATISTICS - TABLES [ @ ]" 7 50 >&2
      SepLine
      DBA_041
      Continue
  ;;
  42)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY STATISTICS - INDEXES [ @ ]" --gauge "DBA: VERIFY STATISTICS - INDEXES [ @ ]" 7 50 >&2
      SepLine
      DBA_042
      Continue
  ;;
  43)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: CAPTURE STATISTICS - OWNER [ @ ]" --gauge "DBA: CAPTURE STATISTICS - OWNER [ @ ]" 7 50 >&2
      SepLine
      DBA_043
      Continue
  ;;
  44)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VALIDATE OBJECTS FROM ONE OWNER [ @ ]" --gauge "DBA: VALIDATE OBJECTS FROM ONE OWNER [ @ ]" 7 50 >&2
      SepLine
      DBA_044
      Continue
  ;;
  45)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY TABLES SIZE, VALIDATE OBJ - OWNERS [ @ ]" --gauge "DBA: VERIFY TABLES SIZE, VALIDATE OBJ - OWNERS [ @ ]" 7 50 >&2
      SepLine
      DBA_045
      Continue
  ;;
  46)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: OWNER X OBJECTS X TYPE X QTD" --gauge "DBA: OWNER X OBJECTS X TYPE X QTD" 7 50 >&2
      SepLine
      DBA_046
      Continue
  ;;
  47)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY INSTANCE CHARACTERSET" --gauge "DBA: VERIFY INSTANCE CHARACTERSET" 7 50 >&2
      SepLine
      DBA_047
      Continue
  ;;
  48)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: CACHE HIT RATIO [ GOOD: > 90% ]" --gauge "DBA: CACHE HIT RATIO [ GOOD: > 90% ]" 7 50 >&2
      SepLine
      DBA_048
      Continue
  ;;
  49)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY INSTANCE INSTALLED PRODUCTS" --gauge "DBA: VERIFY INSTANCE INSTALLED PRODUCTS" 7 50 >&2
      SepLine
      DBA_049
      Continue
  ;;
  50)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: INSTANCE PROPERTIES" --gauge "DBA: INSTANCE PROPERTIES" 7 50 >&2
      SepLine
      DBA_050
      Continue
  ;;
  51)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: INSTANCE OPTIONS" --gauge "DBA: INSTANCE OPTIONS" 7 50 >&2
      SepLine
      DBA_051
      Continue
  ;;
  52)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: INSTANCE DIFFERENTS PARAMETERS" --gauge "DBA: INSTANCE DIFFERENTS PARAMETERS" 7 50 >&2
      SepLine
      DBA_052
      Continue
  ;;
  53)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: INSTANCE MODIFICABLES PARAMETERS" --gauge "DBA: INSTANCE MODIFICABLES PARAMETERS" 7 50 >&2
      SepLine
      DBA_053
      Continue
  ;;
  54)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY DEAD LOCKS" --gauge "DBA: VERIFY DEAD LOCKS" 7 50 >&2
      SepLine
      DBA_054
      Continue
  ;;
  55)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY SESSIONS PER I/O CONSUME" --gauge "DBA: VERIFY SESSIONS PER I/O CONSUME" 7 50 >&2
      SepLine
      DBA_055
      Continue
  ;;
  56)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY FREE SEGMENTS ON DATAFILES" --gauge "DBA: VERIFY FREE SEGMENTS ON DATAFILES" 7 50 >&2
      SepLine
      DBA_056
      Continue
  ;;
  57)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY WHICH DATAFILE CAN BE RESIZED [ @ ]" --gauge "DBA: VERIFY WHICH DATAFILE CAN BE RESIZED [ @ ]" 7 50 >&2
      SepLine
      DBA_057
      Continue
  ;;
  58)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY RECYCLEBIN" --gauge "DBA: VERIFY RECYCLEBIN" 7 50 >&2
      SepLine
      DBA_058
      Continue
  ;;
  59)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: CLEAR REYICLEBIN" --gauge "DBA: CLEAR REYICLEBIN" 7 50 >&2
      SepLine
      DBA_059
      Continue
  ;;
  60)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY DATABASE SESSIONS" --gauge "DBA: VERIFY DATABASE SESSIONS" 7 50 >&2
      SepLine
      DBA_060
      Continue
  ;;
  61)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY ACTIVES SESSIONS PER OWNER" --gauge "DBA: VERIFY ACTIVES SESSIONS PER OWNER" 7 50 >&2
      SepLine
      DBA_061
      Continue
  ;;
  62)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: UNLOCKING A USER [ @ ]" --gauge "DBA: UNLOCKING A USER [ @ ]" 7 50 >&2
      SepLine
      DBA_062
      Continue
  ;;
  63)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: LOCKING A USER [ @ ]" --gauge "DBA: LOCKING A USER [ @ ]" 7 50 >&2
      SepLine
      DBA_063
      Continue
  ;;
  64)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: REDO GROUPS INFORMATIONS" --gauge "DBA: REDO GROUPS INFORMATIONS" 7 50 >&2
      SepLine
      DBA_064
      Continue
  ;;
  65)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: SHOW ALL CORRUPTED OBJECTS" --gauge "DBA: SHOW ALL CORRUPTED OBJECTS" 7 50 >&2
      SepLine
      DBA_065
      Continue
  ;;
  66)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY SPACE OF FLASH RECOVERY AREA" --gauge "DBA: VERIFY SPACE OF FLASH RECOVERY AREA" 7 50 >&2
      SepLine
      DBA_066
      Continue
  ;;
  67)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: TOTAL USERS COUNT ON DATABASE" --gauge "DBA: TOTAL USERS COUNT ON DATABASE" 7 50 >&2
      SepLine
      DBA_067
      Continue
  ;;
  68)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY CONTROLFILES" --gauge "DBA: VERIFY CONTROLFILES" 7 50 >&2
      SepLine
      DBA_068
      Continue
  ;;
  69)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY CONSUME PER CPU" --gauge "DBA: VERIFY CONSUME PER CPU" 7 50 >&2
      SepLine
      DBA_069
      Continue
  ;;
  70)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: QUICK TUNE" --gauge "DBA: QUICK TUNE" 7 50 >&2
      SepLine
      DBA_070
      Continue
  ;;
  71)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY RECOMENDATIONS TUNING TOP 20 [ @ ]" --gauge "DBA: VERIFY RECOMENDATIONS TUNING TOP 20 [ @ ]" 7 50 >&2
      SepLine
      DBA_071
      Continue
  ;;
  72)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY TOP 20 TUNING HISTORY [ @ ]" --gauge "DBA: VERIFY TOP 20 TUNING HISTORY [ @ ]" 7 50 >&2
      SepLine
      DBA_072
      Continue
  ;;
  73)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY BACKGROUND PROCESSESS" --gauge "DBA: VERIFY BACKGROUND PROCESSESS" 7 50 >&2
      SepLine
      DBA_073
      Continue
  ;;
  74)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: TOP 100 QUERY RECOMMENDATIONS" --gauge "DBA: TOP 100 QUERY RECOMMENDATIONS" 7 50 >&2
      SepLine
      DBA_074
      Continue
  ;;
  75)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY DYNAMICS PARAMETERS [ SPFILE ]" --gauge "DBA: VERIFY DYNAMICS PARAMETERS [ SPFILE ]" 7 50 >&2
      SepLine
      DBA_075
      Continue
  ;;
  76)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY DBA FEATURES USAGE STATISTICS" --gauge "DBA: VERIFY DBA FEATURES USAGE STATISTICS" 7 50 >&2
      SepLine
      DBA_076
      Continue
  ;;
  77)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY DBA HIGH WATER MARK STATISTICS" --gauge "DBA: VERIFY DBA HIGH WATER MARK STATISTICS" 7 50 >&2
      SepLine
      DBA_077
      Continue
  ;;
  78)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: GLOBAL INFORMATION ABOUT I/O" --gauge "DBA: GLOBAL INFORMATION ABOUT I/O" 7 50 >&2
      SepLine
      DBA_078
      Continue
  ;;
  79)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: WHICH SEG. HAVE TOP LOGICAL I/O - PHYSICAL I/O" --gauge "DBA: WHICH SEG. HAVE TOP LOGICAL I/O - PHYSICAL I/O" 7 50 >&2
      SepLine
      DBA_079
      Continue
  ;;
  80)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY DBLINKS & FOLDERS INFO" --gauge "DBA: VERIFY DBLINKS & FOLDERS INFO" 7 50 >&2
      SepLine
      DBA_080
      Continue
  ;;
  81)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: IDENTIFYING WHEN A PASSWORD WAS LAST CHANGED" --gauge "DBA: IDENTIFYING WHEN A PASSWORD WAS LAST CHANGED" 7 50 >&2
      SepLine
      DBA_081
      Continue
  ;;
  82)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY UNDO SEGMENTS" --gauge "DBA: VERIFY UNDO SEGMENTS" 7 50 >&2
      SepLine
      DBA_082
      Continue
  ;;
  83)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY ALL SQL STATEMENTS" --gauge "DBA: VERIFY ALL SQL STATEMENTS " 7 50 >&2
      SepLine
      DBA_083
      Continue
  ;;
  84)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: CLONE USER COMMANDS [ @ ]" --gauge "DBA: CLONE USER COMMANDS [ @ ]" 7 50 >&2
      SepLine
      DBA_084
      Continue
  ;;
  85)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY ALL INFOS ABOUT SYSAUX" --gauge "DBA: VERIFY ALL INFOS ABOUT SYSAUX" 7 50 >&2
      SepLine
      DBA_085
      Continue
  ;;
  86)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY ALL INFOS ABOUT I/O + LATENCY" --gauge "DBA: VERIFY ALL INFOS ABOUT I/O + LATENCY" 7 50 >&2
      SepLine
      DBA_086
      Continue
  ;;
  87)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY MAIN TOP WAIT EVENTS PER WEEK" --gauge "DBA: VERIFY MAIN TOP WAIT EVENTS PER WEEK" 7 50 >&2
      SepLine
      DBA_087
      Continue
  ;;
  88)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY OBJECTS SIZE" --gauge "DBA: VERIFY OBJECTS SIZE" 7 50 >&2
      SepLine
      DBA_088
      Continue
  ;;
  89)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: GENERAL DATABASE OVERVIEW" --gauge "DBA: GENERAL DATABASE OVERVIEW" 7 50 >&2
      SepLine
      DBA_089
      Continue
  ;;
  90)  for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: DATABASE DASHBOARD" --gauge "DBA: DATABASE DASHBOARD" 7 50 >&2
      SepLine
      DBA_090
      Continue
  ;;
  91) for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY ALL SQL IDS STATEMENTS" --gauge "DBA: VERIFY ALL SQL IDS STATEMENTS" 7 50 >&2
      SepLine
      DBA_091
      Continue
  ;;
  92) for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY NLS CONFIGURATION" --gauge "DBA: VERIFY NLS CONFIGURATION" 7 50 >&2
      SepLine
      DBA_092
      Continue
  ;;
  93) for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY FAILED LOGIN" --gauge "DBA: VERIFY FAILED LOGIN" 7 50 >&2
      SepLine
      DBA_093
      Continue
  ;;
  94) for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY ALL SQL IDS STATEMENTS" --gauge "DBA: VERIFY ALL SQL IDS STATEMENTS" 7 50 >&2
      SepLine
      DBA_094
      Continue
  ;;
  95) for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY ALL PATCHES APPLIED" --gauge "DBA: VERIFY ALL PATCHES APPLIED" 7 50 >&2
      SepLine
      DBA_095
      Continue
  ;;
  96) for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY CPU USAGE BY MINUTE" --gauge "DBA: VERIFY CPU USAGE BY MINUTE" 7 50 >&2
      SepLine
      DBA_096
      Continue
  ;;
  97) for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY STANDBY CONFIGURATION" --gauge "DBA: VERIFY STANDBY CONFIGURATION" 7 50 >&2
      SepLine
      DBA_097
      Continue
  ;;
  98) for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY GRANTS AND PERMISSIONS BY OWNER" --gauge "DBA: VERIFY GRANTS AND PERMISSIONS BY OWNER" 7 50 >&2
      SepLine
      DBA_098
      Continue
  ;;
  99) for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: USER DETAILS SESSIONS" --gauge "DBA: USER DETAILS SESSIONS" 7 50 >&2
      SepLine
      DBA_099
      Continue
  ;;
  100) for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY BACKUP RUNNING ON REAL TIME" --gauge "DBA: VERIFY BACKUP RUNNING ON REAL TIME" 7 50 >&2
      SepLine
      DBA_100
      Continue
  ;;
  101) for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY DATABASE COMPONENTS FROM REGISTRY" --gauge "DBA: VERIFY DATABASE COMPONENTS FROM REGISTRY" 7 50 >&2
      SepLine
      DBA_101
      Continue
  ;;
  102) for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DBA: VERIFY ORACLE NET SEND AND RECEIVE SIZE VOLUME" --gauge "DBA: VERIFY ORACLE NET SEND AND RECEIVE SIZE VOLUME" 7 50 >&2
      SepLine
      DBA_102
      Continue
  ;;
  esac
done
}
#
#########################################################################################################
# Database: VERIFY DATABASE VERSION
#########################################################################################################
#  

#
#########################################################################################################
#
# ASM Menu
#
#########################################################################################################
#
ASM() {
#
#########################################################################################################
# Verify ASM
#########################################################################################################
#
if [[ ${varASM} = "N" ]]; then
  dialog --backtitle "www.DBNITRO.net" --title "ASM Menu" --no-collapse --colors --msgbox "Your ASM is Not Available" 7 70
  MainMenu
fi
#
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "ASM Menu" --no-collapse --colors --gauge "Open ASM Menu" 7 50
#
#########################################################################################################
# Variables ASM Menu
#########################################################################################################
#
# . ${DBNITRO}/var/ASM.${ORACLE_SID}.var
#
varDATE=$(date +%d\/%m\/%Y)
varTIME=$(date +%H\:%M)
#
while true; do
exec 3>&1
SelectASM=$(dialog --backtitle "www.DBNITRO.net" --title "ASM Menu" --clear --cancel-label "Back" --no-collapse --colors --inputbox "\
+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| OS: ${varOS} | UPTIME: ${varUPTIME} | KERNEL: ${varKERNEL} | PROCS: ${varPhysical_CPU} | MEMORY: ${varTotal_MEMORY} | MEM_USED: ${varUsed_MEMORY} | MEM_FREE: ${varFree_MEMORY} | SWAP: ${varSwap_MEMORY} | SWAP_USED: ${varSwap_USED_MEMORY} | SWAP_FREE: ${varSwap_Free_MEMORY}
+-+-+-----+---------------------------------------------------+-+-+-----+---------------------------------------------------+-+---------------------------+-+----------------------------------------------------+
|+|-|   1 | VERIFY ALL GRID SERVICES                          |+|-|   2 | VERIFY ALL GRID SERVICES - DETAILS                |+| ..........................: 
|+|-|   3 | VERIFY ASM DISKS ATTRIBUTES                       |+|-|   4 | VERIFY ASM INTELLIGENT DATA PLACEMENT INFORMATIONS|+| ..........................: 
|+|-|   5 |                                                   |+|-|   6 |                                                   |+| ..........................: 
|+|-|   7 |                                                   |+|-|   8 |                                                   |+| ..........................: 
|+|-|   9 |                                                   |+|-|  10 |                                                   |+| ..........................: 
|+|-|  11 |                                                   |+|-|  12 |                                                   |+| ..........................: 
|+|-|  13 |                                                   |+|-|  14 |                                                   |+| ..........................: 
|+|-|  15 |                                                   |+|-|  16 |                                                   |+| ..........................: 
|+|-|  17 |                                                   |+|-|  18 |                                                   |+| ..........................: 
|+|-|  19 |                                                   |+|-|  20 |                                                   |+| ..........................: 
|+|-|  21 |                                                   |+|-|  22 |                                                   |+| ..........................: 
|+|-|  23 |                                                   |+|-|  24 |                                                   |+| ..........................: 
|+|-|  25 |                                                   |+|-|  26 |                                                   |+| ..........................: 
|+|-|  27 |                                                   |+|-|  28 |                                                   |+| ..........................: 
|+|-|  29 |                                                   |+|-|  30 |                                                   |+| ..........................: 
|+|-|  31 |                                                   |+|-|  32 |                                                   |+| ..........................: 
|+|-|  33 |                                                   |+|-|  34 |                                                   |+| ..........................: 
|+|-|  35 |                                                   |+|-|  36 |                                                   |+| ..........................: 
|+|-|  37 |                                                   |+|-|  38 |                                                   |+| ..........................: 
|+|-|  39 |                                                   |+|-|  40 |                                                   |+| ..........................: 
|+|-|  41 |                                                   |+|-|  42 |                                                   |+| ..........................: 
|+|-|  43 |                                                   |+|-|  44 |                                                   |+| ..........................: 
|+|-|  45 |                                                   |+|-|  46 |                                                   |+| ..........................: 
|+|-|  47 |                                                   |+|-|  48 |                                                   |+| ..........................: 
|+|-|  49 |                                                   |+|-|  50 |                                                   |+| ..........................: 
|+|-|  51 |                                                   |+|-|  52 |                                                   |+| ..........................: 
|+|-|  53 |                                                   |+|-|  54 |                                                   |+| ..........................: 
|+|-|  55 |                                                   |+|-|  56 |                                                   |+| ..........................: 
|+|-|  57 |                                                   |+|-|  58 |                                                   |+| ..........................: 
|+|-|  59 |                                                   |+|-|  60 |                                                   |+| ..........................: 
|+|-|  61 |                                                   |+|-|  62 |                                                   |+| ..........................: 
|+|-|  63 |                                                   |+|-|  64 |                                                   |+| ..........................: 
|+|-|  65 |                                                   |+|-|  66 |                                                   |+| ..........................: 
|+|-|  67 |                                                   |+|-|  68 |                                                   |+| ..........................: 
|+|-|  69 |                                                   |+|-|  70 |                                                   |+| ..........................: 
|+|-|  71 |                                                   |+|-|  72 |                                                   |+| ..........................: 
|+|-|  73 |                                                   |+|-|  74 |                                                   |+| ..........................: 
|+|-|  75 |                                                   |+|-|  76 |                                                   |+| ..........................: 
|+|-|  77 |                                                   |+|-|  78 |                                                   |+| ..........................: 
|+|-|  79 |                                                   |+|-|  80 |                                                   |+| ..........................: 
|+|-|  81 |                                                   |+|-|  82 |                                                   |+| ..........................: 
|+|-|  83 |                                                   |+|-|  84 |                                                   |+| ..........................: 
|+|-|  85 |                                                   |+|-|  86 |                                                   |+| ..........................: 
|+|-|  87 |                                                   |+|-|  88 |                                                   |+| ..........................: 
|+|-|  89 |                                                   |+|-|  90 |                                                   |+| ..........................: 
|+|-|  91 |                                                   |+|-|  92 |                                                   |+| ..........................: 
|+|-|  93 |                                                   |+|-|  94 |                                                   |+| ..........................: 
|+|-|  95 |                                                   |+|-|  96 |                                                   |+| ..........................: 
|+|-|  97 |                                                   |+|-|  98 | OPATCH VERSION + DETAILS                          |+| ..........................: 
|+|-|  99 | REPORT                                            |+|-| 100 | EXTRAS                                            |+| ..........................: 
+-+-+-----+---------------------------------------------------+-+-+-----+---------------------------------------------------+-+---------------------------+-+----------------------------------------------------+
| CHOOSE ONE OF THOSE OPTIONS [ 0 - 100 ] | OPTIONS WITH [ @ ] HAS MORE FILTERS | VERSION: ${SoftwareVersion} | MODIFIED: ${DateofModification} | DATE & TIME: ${varDATE} ${varTIME}
+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+" 0 0 3>&1 1>&2 2>&3 3>&-)
exit_status=$?
exec 3>&-
case ${exit_status} in ${DIALOG_CANCEL})
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "Exit Program" --gauge "Program Closed" 7 50 >&2
MainMenu
;;
${DIALOG_ESC})
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "Exit Program" --gauge "Program Aborted" 7 50 >&2
MainMenu
;;
esac
case ${SelectASM} in
  1)  dialog --backtitle "www.DBNITRO.net" --title "ASM: VERIFY ALL GRID SERVICES" --no-collapse --colors --msgbox "$(${GRID_HOME}/bin/crsctl stat res -t)" 0 0
      SepLine
      ASM_001
      Continue
  ;;
  2)  dialog --backtitle "www.DBNITRO.net" --title "ASM: VERIFY ALL GRID SERVICES - DETAILS" --no-collapse --colors --msgbox "$(${GRID_HOME}/bin/crsctl stat res)" 0 0
      SepLine
      ASM_002
      Continue
  ;;
  3)  dialog --backtitle "www.DBNITRO.net" --title "ASM: VERIFY ASM DISKS ATTRIBUTES" --no-collapse --colors --msgbox "$(Func_ASM_003)" 0 0
      SepLine
      ASM_002
      Continue
  ;;
  4)  dialog --backtitle "www.DBNITRO.net" --title "ASM: VERIFY ASM INTELLIGENT DATA PLACEMENT INFORMATIONS" --no-collapse --colors --msgbox "$(Func_ASM_004)" 0 0
      SepLine
      ASM_002
      Continue
	;;
  98) dialog --backtitle "www.DBNITRO.net" --title "ASM: OPATCH VERSION + DETAILS" --no-collapse --colors --msgbox "$(Func_ASM_005)" 0 0
      SepLine
      ASM_002
      Continue
  ;;
  99) dialog --backtitle "www.DBNITRO.net" --title "ASM: REPORT" --no-collapse --colors --msgbox "$(Func_ASM_099)" 0 0
      SepLine
      ASM_002
      Continue
	;;
  100)  dialog --backtitle "www.DBNITRO.net" --title "ASM: EXTRAS" --no-collapse --colors --msgbox "$(Func_ASM_100)" 0 0
        SepLine
        ASM_002
        Continue
	;;
  esac
done
}
#
#
#
#########################################################################################################
#
# RAC Menu
#
#########################################################################################################
#
RAC() {
#
#########################################################################################################
# Verify RAC
#########################################################################################################
#
clear
if [[ ${varRAC} = "N" ]]; then
  dialog --backtitle "www.DBNITRO.net" --title "RAC Menu" --no-collapse --colors --msgbox "Your RAC is Not Available" 7 70
  MainMenu
fi
#
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "RAC Menu" --no-collapse --colors --gauge "Open RAC Menu" 7 50
#
#########################################################################################################
# Variables RAC Menu
#########################################################################################################
#
# . ${DBNITRO}/var/RAC.${ORACLE_SID}.var
#
varDATE=$(date +%d\/%m\/%Y)
varTIME=$(date +%H\:%M)
#
while true; do
exec 3>&1
SelectRAC=$(dialog --backtitle "www.DBNITRO.net" --title "RAC Menu" --clear --cancel-label "Back" --no-collapse --colors --inputbox "\
+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| OS: ${varOS} | UPTIME: ${varUPTIME} | KERNEL: ${varKERNEL} | PROCS: ${varPhysical_CPU} | MEMORY: ${varTotal_MEMORY} | MEM_USED: ${varUsed_MEMORY} | MEM_FREE: ${varFree_MEMORY} | SWAP: ${varSwap_MEMORY} | SWAP_USED: ${varSwap_USED_MEMORY} | SWAP_FREE: ${varSwap_Free_MEMORY}
+-+-+----+---------------------------------------------------+-+-+-----+---------------------------------------------------+-+---------------------------+-+----------------------------------------------------+
|+|-|  1 |                                                   |+|-|   2 |                                                   |+| ..........................: 
|+|-|  3 |                                                   |+|-|   4 |                                                   |+| ..........................: 
|+|-|  5 |                                                   |+|-|   6 |                                                   |+| ..........................: 
|+|-|  7 |                                                   |+|-|   8 |                                                   |+| ..........................: 
|+|-|  9 |                                                   |+|-|  10 |                                                   |+| ..........................: 
|+|-| 11 |                                                   |+|-|  12 |                                                   |+| ..........................: 
|+|-| 13 |                                                   |+|-|  14 |                                                   |+| ..........................: 
|+|-| 15 |                                                   |+|-|  16 |                                                   |+| ..........................: 
|+|-| 17 |                                                   |+|-|  18 |                                                   |+| ..........................: 
|+|-| 19 |                                                   |+|-|  20 |                                                   |+| ..........................: 
|+|-| 21 |                                                   |+|-|  22 |                                                   |+| ..........................: 
|+|-| 23 |                                                   |+|-|  24 |                                                   |+| ..........................: 
|+|-| 25 |                                                   |+|-|  26 |                                                   |+| ..........................: 
|+|-| 27 |                                                   |+|-|  28 |                                                   |+| ..........................: 
|+|-| 29 |                                                   |+|-|  30 |                                                   |+| ..........................: 
|+|-| 31 |                                                   |+|-|  32 |                                                   |+| ..........................: 
|+|-| 33 |                                                   |+|-|  34 |                                                   |+| ..........................: 
|+|-| 35 |                                                   |+|-|  36 |                                                   |+| ..........................: 
|+|-| 37 |                                                   |+|-|  38 |                                                   |+| ..........................: 
|+|-| 39 |                                                   |+|-|  40 |                                                   |+| ..........................: 
|+|-| 41 |                                                   |+|-|  42 |                                                   |+| ..........................: 
|+|-| 43 |                                                   |+|-|  44 |                                                   |+| ..........................: 
|+|-| 45 |                                                   |+|-|  46 |                                                   |+| ..........................: 
|+|-| 47 |                                                   |+|-|  48 |                                                   |+| ..........................: 
|+|-| 49 |                                                   |+|-|  50 |                                                   |+| ..........................: 
|+|-| 51 |                                                   |+|-|  52 |                                                   |+| ..........................: 
|+|-| 53 |                                                   |+|-|  54 |                                                   |+| ..........................: 
|+|-| 55 |                                                   |+|-|  56 |                                                   |+| ..........................: 
|+|-| 57 |                                                   |+|-|  58 |                                                   |+| ..........................: 
|+|-| 59 |                                                   |+|-|  60 |                                                   |+| ..........................: 
|+|-| 61 |                                                   |+|-|  62 |                                                   |+| ..........................: 
|+|-| 63 |                                                   |+|-|  64 |                                                   |+| ..........................: 
|+|-| 65 |                                                   |+|-|  66 |                                                   |+| ..........................: 
|+|-| 67 |                                                   |+|-|  68 |                                                   |+| ..........................: 
|+|-| 69 |                                                   |+|-|  70 |                                                   |+| ..........................: 
|+|-| 71 |                                                   |+|-|  72 |                                                   |+| ..........................: 
|+|-| 73 |                                                   |+|-|  74 |                                                   |+| ..........................: 
|+|-| 75 |                                                   |+|-|  76 |                                                   |+| ..........................: 
|+|-| 77 |                                                   |+|-|  78 |                                                   |+| ..........................: 
|+|-| 79 |                                                   |+|-|  80 |                                                   |+| ..........................: 
|+|-| 81 |                                                   |+|-|  82 |                                                   |+| ..........................: 
|+|-| 83 |                                                   |+|-|  84 |                                                   |+| ..........................: 
|+|-| 85 |                                                   |+|-|  86 |                                                   |+| ..........................: 
|+|-| 87 |                                                   |+|-|  88 |                                                   |+| ..........................: 
|+|-| 89 |                                                   |+|-|  90 |                                                   |+| ..........................: 
|+|-| 91 |                                                   |+|-|  92 |                                                   |+| ..........................: 
|+|-| 93 |                                                   |+|-|  94 |                                                   |+| ..........................: 
|+|-| 95 |                                                   |+|-|  96 |                                                   |+| ..........................: 
|+|-| 97 |                                                   |+|-|  98 |                                                   |+| ..........................: 
|+|-| 99 | REPORT                                            |+|-| 100 | EXTRAS                                            |+| ..........................: 
+-+-+----+---------------------------------------------------+-+-+-----+---------------------------------------------------+-+---------------------------+-+----------------------------------------------------+
| CHOOSE ONE OF THOSE OPTIONS [ 0 - 100 ] | OPTIONS WITH [ @ ] HAS MORE FILTERS | VERSION: ${SoftwareVersion} | MODIFIED: ${DateofModification} | DATE & TIME: ${varDATE} ${varTIME}
+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+" 0 0 3>&1 1>&2 2>&3 3>&-)
exit_status=$?
exec 3>&-
case ${exit_status} in ${DIALOG_CANCEL})
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "Exit Program" --gauge "Program Closed" 7 50 >&2
MainMenu
;;
${DIALOG_ESC})
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "Exit Program" --gauge "Program Aborted" 7 50 >&2
MainMenu
;;
esac
case ${SelectRAC} in
  01) dialog --backtitle "www.DBNITRO.net" --title "RAC: " --no-collapse --colors --msgbox "$(Func_RAC_001)" 0 0
      SepLine
      RAC_001
      Continue
      ;;
  02) dialog --backtitle "www.DBNITRO.net" --title "RAC: " --no-collapse --colors --msgbox "$(Func_RAC_002)" 0 0
      SepLine
      RAC_002
      Continue
      ;;
  99) dialog --backtitle "www.DBNITRO.net" --title "RAC: REPORT" --no-collapse --colors --msgbox "$(Func_RAC_099)" 0 0
      SepLine
      RAC_099
      Continue
      ;;
  100) dialog --backtitle "www.DBNITRO.net" --title "ASM: EXTRAS" --no-collapse --colors --msgbox "$(Func_RAC_100)" 0 0
       SepLine
       RAC_100
       Continue
       ;;
  esac
done
}

#
#########################################################################################################
#
# DATAGUARD Menu
#
#########################################################################################################
#
DATAGUARD() {
#
#########################################################################################################
# Verify DATAGUARD
#########################################################################################################
#
clear
if [[ ${varODG} = "N" ]]; then
  dialog --backtitle "www.DBNITRO.net" --title "DATAGUARD Menu" --no-collapse --colors --msgbox "Your DATAGUARD is Not Available" 7 70
  MainMenu
  # exit 1
fi
#
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "DATAGUARD Menu" --no-collapse --colors --gauge "Open DATAGUARD Menu" 7 50
#
#########################################################################################################
# Variables DATAGUARD Menu
#########################################################################################################
#
. ${DBNITRO}/var/MainMenu.${ORACLE_SID}.var
#
. ${DBNITRO}/var/Database.${ORACLE_SID}.var
#
. ${DBNITRO}/var/Dataguard.${ORACLE_SID}.var
#
varDATE=$(date +%d\/%m\/%Y)
varTIME=$(date +%H\:%M)
#
while true; do
exec 3>&1
SelectODG=$(dialog --backtitle "www.DBNITRO.net" --title "DATAGUARD Menu" --clear --cancel-label "Back" --no-collapse --colors --inputbox "\
+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| OS: ${varOS} | UPTIME: ${varUPTIME} | KERNEL: ${varKERNEL} | PROCS: ${varPhysical_CPU} | MEMORY: ${varTotal_MEMORY} | MEM_USED: ${varUsed_MEMORY} | MEM_FREE: ${varFree_MEMORY} | SWAP: ${varSwap_MEMORY} | SWAP_USED: ${varSwap_USED_MEMORY} | SWAP_FREE: ${varSwap_Free_MEMORY}
+-+-+----+---------------------------------------------------+-+-+-----+---------------------------------------------------+-+---------------------------+-+----------------------------------------------------+
|+|-|  1 | VERIFY DATAGUARD CONFIGURATION                    |+|-|   2 | VERIFY DATAGUARD STATUS                           |+| Dataguard Config Name.....: ${varDG_NAME}
|+|-|  3 | VERIFY DATAGUARD PARAMETERS                       |+|-|   4 | DATAGUARD STATUS APPLYING                         |+| Dataguard Config Status...: ${varDG_STATUS}
|+|-|  5 | VERIFY DATAGUARD HEALTH CHECK                     |+|-|   6 | VERIFY GOLDEN GATE STATUS                         |+| Dataguard Protection......: ${varDG_PROTECT}
|+|-|  7 |                                                   |+|-|   8 |                                                   |+| Dataguard Faststart.......: ${varDG_FAST}
|+|-|  9 |                                                   |+|-|  10 |                                                   |+| ..........................: ${varDG_FAST_THRES}
|+|-| 11 |                                                   |+|-|  12 |                                                   |+| ..........................: ${varDG_OPER_TIME}
|+|-| 13 |                                                   |+|-|  14 |                                                   |+| ..........................: ${varDG_FAST_LIMIT}
|+|-| 15 |                                                   |+|-|  16 |                                                   |+| ..........................: ${varDG_COMM_TIME}
|+|-| 17 |                                                   |+|-|  18 |                                                   |+| ..........................: ${varDG_OBSER_RECO}
|+|-| 19 |                                                   |+|-|  20 |                                                   |+| ..........................: ${varDG_FAST_A_R}
|+|-| 21 |                                                   |+|-|  22 |                                                   |+| ..........................: ${varDG_FAST_SHUT}
|+|-| 23 |                                                   |+|-|  24 |                                                   |+| ..........................: ${varDG_BYST_CHANG}
|+|-| 25 |                                                   |+|-|  26 |                                                   |+| ..........................: ${varDG_OBSER_OVER}
|+|-| 27 |                                                   |+|-|  28 |                                                   |+| ..........................: ${varDG_EXT_DEST1}
|+|-| 29 |                                                   |+|-|  30 |                                                   |+| ..........................: ${varDG_EXT_DEST}
|+|-| 31 |                                                   |+|-|  32 |                                                   |+| ..........................: ${varDG_PRIMARY_ACT}
|+|-| 33 |                                                   |+|-|  34 |                                                   |+| ..........................: 
|+|-| 35 |                                                   |+|-|  36 |                                                   |+| ..........................: 
|+|-| 37 |                                                   |+|-|  38 |                                                   |+| ..........................: 
|+|-| 39 |                                                   |+|-|  40 |                                                   |+| ..........................: 
|+|-| 41 |                                                   |+|-|  42 |                                                   |+| ..........................: 
|+|-| 43 |                                                   |+|-|  44 |                                                   |+| ..........................: 
|+|-| 45 |                                                   |+|-|  46 |                                                   |+| ..........................: 
|+|-| 47 |                                                   |+|-|  48 |                                                   |+| ..........................: 
|+|-| 49 |                                                   |+|-|  50 |                                                   |+| ..........................: 
|+|-| 51 |                                                   |+|-|  52 |                                                   |+| ..........................: 
|+|-| 53 |                                                   |+|-|  54 |                                                   |+| ..........................: 
|+|-| 55 |                                                   |+|-|  56 |                                                   |+| ..........................: 
|+|-| 57 |                                                   |+|-|  58 |                                                   |+| ..........................: 
|+|-| 59 |                                                   |+|-|  60 |                                                   |+| ..........................: 
|+|-| 61 |                                                   |+|-|  62 |                                                   |+| ..........................: 
|+|-| 63 |                                                   |+|-|  64 |                                                   |+| ..........................: 
|+|-| 65 |                                                   |+|-|  66 |                                                   |+| ..........................: 
|+|-| 67 |                                                   |+|-|  68 |                                                   |+| ..........................: 
|+|-| 69 |                                                   |+|-|  70 |                                                   |+| ..........................: 
|+|-| 71 |                                                   |+|-|  72 |                                                   |+| ..........................: 
|+|-| 73 |                                                   |+|-|  74 |                                                   |+| ..........................: 
|+|-| 75 |                                                   |+|-|  76 |                                                   |+| ..........................: 
|+|-| 77 |                                                   |+|-|  78 |                                                   |+| ..........................: 
|+|-| 79 |                                                   |+|-|  80 |                                                   |+| ..........................: 
|+|-| 81 |                                                   |+|-|  82 |                                                   |+| ..........................: 
|+|-| 83 |                                                   |+|-|  84 |                                                   |+| ..........................: 
|+|-| 85 |                                                   |+|-|  86 |                                                   |+| ..........................: 
|+|-| 87 |                                                   |+|-|  88 |                                                   |+| ..........................: 
|+|-| 89 |                                                   |+|-|  90 |                                                   |+| ..........................: 
|+|-| 91 |                                                   |+|-|  92 |                                                   |+| ..........................: 
|+|-| 93 |                                                   |+|-|  94 |                                                   |+| ..........................: 
|+|-| 95 |                                                   |+|-|  96 |                                                   |+| ..........................: 
|+|-| 97 |                                                   |+|-|  98 |                                                   |+| ..........................: 
|+|-| 99 | REPORT                                            |+|-| 100 | EXTRAS                                            |+| ..........................: 
+-+-+----+---------------------------------------------------+-+-+-----+---------------------------------------------------+-+---------------------------+-+----------------------------------------------------+
| CHOOSE ONE OF THOSE OPTIONS [ 0 - 100 ] | OPTIONS WITH [ @ ] HAS MORE FILTERS | VERSION: ${SoftwareVersion} | MODIFIED: ${DateofModification} | DATE & TIME: ${varDATE} ${varTIME}
+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+" 0 0 3>&1 1>&2 2>&3 3>&-)
exit_status=$?
exec 3>&-
case ${exit_status} in ${DIALOG_CANCEL})
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "Exit Program" --gauge "Program Closed" 7 50 >&2
MainMenu
;;
${DIALOG_ESC})
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "Exit Program" --gauge "Program Aborted" 7 50 >&2
MainMenu
;;
esac
case ${SelectODG} in
  01)  dialog --backtitle "www.DBNITRO.net" --title "DATAGUARD: VERIFY DATAGUARD CONFIGURATION" --no-collapse --colors --msgbox "$(Func_ODG_001)" 0 0
       SepLine
       ODG_001
       Continue
       ;;
  02)  dialog --backtitle "www.DBNITRO.net" --title "DATAGUARD: VERIFY DATAGUARD STATUS" --no-collapse --colors --msgbox "$(Func_ODG_002)" 0 0
       SepLine
       ODG_002
       Continue
       ;;
  03)  dialog --backtitle "www.DBNITRO.net" --title "DATAGUARD: VERIFY DATAGUARD PARAMETERS" --no-collapse --colors --msgbox "$(Func_ODG_003)" 0 0
       SepLine
       ODG_003
       Continue
       ;;
  04)  dialog --backtitle "www.DBNITRO.net" --title "DATAGUARD: DATAGUARD STATUS APPLYING" --no-collapse --colors --msgbox "$(Func_ODG_004)" 0 0
       SepLine
       ODG_004
       Continue
       ;;
  05)  dialog --backtitle "www.DBNITRO.net" --title "DATAGUARD: " --no-collapse --colors --msgbox "$(Func_ODG_005)" 0 0
       SepLine
       ODG_005
       Continue
       ;;
  06)  dialog --backtitle "www.DBNITRO.net" --title "DATAGUARD: " --no-collapse --colors --msgbox "$(Func_ODG_006)" 0 0
       SepLine
       ODG_006
       Continue
      ;;
  07)  dialog --backtitle "www.DBNITRO.net" --title "DATAGUARD: " --no-collapse --colors --msgbox "$(Func_ODG_007)" 0 0
       SepLine
       ODG_007
       Continue
       ;;
  08)  dialog --backtitle "www.DBNITRO.net" --title "DATAGUARD: " --no-collapse --colors --msgbox "$(Func_ODG_008)" 0 0
       SepLine
       ODG_008
       Continue
       ;;
  09)  dialog --backtitle "www.DBNITRO.net" --title "DATAGUARD: " --no-collapse --colors --msgbox "$(Func_ODG_009)" 0 0
       SepLine
       ODG_009
       Continue
       ;;
  10)  dialog --backtitle "www.DBNITRO.net" --title "DATAGUARD: " --no-collapse --colors --msgbox "$(Func_ODG_010)" 0 0
       SepLine
       ODG_010
       Continue
       ;;
  11)  dialog --backtitle "www.DBNITRO.net" --title "DATAGUARD: " --no-collapse --colors --msgbox "$(Func_ODG_011)" 0 0
       SepLine
       ODG_011
       Continue
       ;;
  12)  dialog --backtitle "www.DBNITRO.net" --title "DATAGUARD: " --no-collapse --colors --msgbox "$(Func_ODG_012)" 0 0
       SepLine
       ODG_012
       Continue
       ;;
  99)  dialog --backtitle "www.DBNITRO.net" --title "DATAGUARD: REPORT" --no-collapse --colors --msgbox "$(Func_ODG_099)" 0 0
       SepLine
       ODG_099
       Continue
	     ;;
  100) dialog --backtitle "www.DBNITRO.net" --title "DATAGUARD: EXTRAS" --no-collapse --colors --msgbox "$(Func_ODG_100)" 0 0
       SepLine
       ODG_100
       Continue
	     ;;
  esac
done
}
#
#########################################################################################################
# DATAGUARD: VERIFY DATAGUARD CONFIGURATION
#########################################################################################################
#

#
#########################################################################################################
#
# GOLDENGATE Menu
#
#########################################################################################################
#
GOLDENGATE() {
#
#########################################################################################################
# Verify GOLDENGATE
#########################################################################################################
#
clear
if [[ ${varOGG} = "N" ]]; then
  dialog --backtitle "www.DBNITRO.net" --title "GOLDENGATE Menu" --no-collapse --colors --msgbox "Your GOLDENGATE is Not Available" 7 70
  MainMenu
fi
#
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "GOLDENGATE Menu" --no-collapse --colors --gauge "Open GOLDENGATE Menu" 7 50
#
#########################################################################################################
# Variables GOLDENGATE Menu
#########################################################################################################
#
. ${DBNITRO}/var/Database.${ORACLE_SID}.var
#
# . ${DBNITRO}/var/Goldengate.${ORACLE_SID}.var
#
varDATE=$(date +%d\/%m\/%Y)
varTIME=$(date +%H\:%M)
#
while true; do
exec 3>&1
SelectOGG=$(dialog --backtitle "www.DBNITRO.net" --title "GOLDENGATE Menu" --clear --cancel-label "Back" --no-collapse --colors --inputbox "\
+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| OS: ${varOS} | UPTIME: ${varUPTIME} | KERNEL: ${varKERNEL} | PROCS: ${varPhysical_CPU} | MEMORY: ${varTotal_MEMORY} | MEM_USED: ${varUsed_MEMORY} | MEM_FREE: ${varFree_MEMORY} | SWAP: ${varSwap_MEMORY} | SWAP_USED: ${varSwap_USED_MEMORY} | SWAP_FREE: ${varSwap_Free_MEMORY}
+-+-+----+---------------------------------------------------+-+-+-----+---------------------------------------------------+-+---------------------------+-+----------------------------------------------------+
|+|-|  1 | VERIFY GOLDEN GATE CONFIGURATION                  |+|-|   2 |                                                   |+| ..........................: 
|+|-|  3 |                                                   |+|-|   4 |                                                   |+| ..........................: 
|+|-|  5 |                                                   |+|-|   6 |                                                   |+| ..........................: 
|+|-|  7 |                                                   |+|-|   8 |                                                   |+| ..........................: 
|+|-|  9 |                                                   |+|-|  10 |                                                   |+| ..........................: 
|+|-| 11 |                                                   |+|-|  12 |                                                   |+| ..........................: 
|+|-| 13 |                                                   |+|-|  14 |                                                   |+| ..........................: 
|+|-| 15 |                                                   |+|-|  16 |                                                   |+| ..........................: 
|+|-| 17 |                                                   |+|-|  18 |                                                   |+| ..........................: 
|+|-| 19 |                                                   |+|-|  20 |                                                   |+| ..........................: 
|+|-| 21 |                                                   |+|-|  22 |                                                   |+| ..........................: 
|+|-| 23 |                                                   |+|-|  24 |                                                   |+| ..........................: 
|+|-| 25 |                                                   |+|-|  26 |                                                   |+| ..........................: 
|+|-| 27 |                                                   |+|-|  28 |                                                   |+| ..........................: 
|+|-| 29 |                                                   |+|-|  30 |                                                   |+| ..........................: 
|+|-| 31 |                                                   |+|-|  32 |                                                   |+| ..........................: 
|+|-| 33 |                                                   |+|-|  34 |                                                   |+| ..........................: 
|+|-| 35 |                                                   |+|-|  36 |                                                   |+| ..........................: 
|+|-| 37 |                                                   |+|-|  38 |                                                   |+| ..........................: 
|+|-| 39 |                                                   |+|-|  40 |                                                   |+| ..........................: 
|+|-| 41 |                                                   |+|-|  42 |                                                   |+| ..........................: 
|+|-| 43 |                                                   |+|-|  44 |                                                   |+| ..........................: 
|+|-| 45 |                                                   |+|-|  46 |                                                   |+| ..........................: 
|+|-| 47 |                                                   |+|-|  48 |                                                   |+| ..........................: 
|+|-| 49 |                                                   |+|-|  50 |                                                   |+| ..........................: 
|+|-| 51 |                                                   |+|-|  52 |                                                   |+| ..........................: 
|+|-| 53 |                                                   |+|-|  54 |                                                   |+| ..........................: 
|+|-| 55 |                                                   |+|-|  56 |                                                   |+| ..........................: 
|+|-| 57 |                                                   |+|-|  58 |                                                   |+| ..........................: 
|+|-| 59 |                                                   |+|-|  60 |                                                   |+| ..........................: 
|+|-| 61 |                                                   |+|-|  62 |                                                   |+| ..........................: 
|+|-| 63 |                                                   |+|-|  64 |                                                   |+| ..........................: 
|+|-| 65 |                                                   |+|-|  66 |                                                   |+| ..........................: 
|+|-| 67 |                                                   |+|-|  68 |                                                   |+| ..........................: 
|+|-| 69 |                                                   |+|-|  70 |                                                   |+| ..........................: 
|+|-| 71 |                                                   |+|-|  72 |                                                   |+| ..........................: 
|+|-| 73 |                                                   |+|-|  74 |                                                   |+| ..........................: 
|+|-| 75 |                                                   |+|-|  76 |                                                   |+| ..........................: 
|+|-| 77 |                                                   |+|-|  78 |                                                   |+| ..........................: 
|+|-| 79 |                                                   |+|-|  80 |                                                   |+| ..........................: 
|+|-| 81 |                                                   |+|-|  82 |                                                   |+| ..........................: 
|+|-| 83 |                                                   |+|-|  84 |                                                   |+| ..........................: 
|+|-| 85 |                                                   |+|-|  86 |                                                   |+| ..........................: 
|+|-| 87 |                                                   |+|-|  88 |                                                   |+| ..........................: 
|+|-| 89 |                                                   |+|-|  90 |                                                   |+| ..........................: 
|+|-| 91 |                                                   |+|-|  92 |                                                   |+| ..........................: 
|+|-| 93 |                                                   |+|-|  94 |                                                   |+| ..........................: 
|+|-| 95 |                                                   |+|-|  96 |                                                   |+| ..........................: 
|+|-| 97 |                                                   |+|-|  98 |                                                   |+| ..........................: 
|+|-| 99 | REPORT                                            |+|-| 100 | EXTRAS                                            |+| ..........................: 
+-+-+----+---------------------------------------------------+-+-+-----+---------------------------------------------------+-+---------------------------+-+----------------------------------------------------+
| CHOOSE ONE OF THOSE OPTIONS [ 0 - 100 ] | OPTIONS WITH [ @ ] HAS MORE FILTERS | VERSION: ${SoftwareVersion} | MODIFIED: ${DateofModification} | DATE & TIME: ${varDATE} ${varTIME}
+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+" 0 0 3>&1 1>&2 2>&3 3>&-)
exit_status=$?
exec 3>&-
case ${exit_status} in ${DIALOG_CANCEL})
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "Exit Program" --gauge "Program Closed" 7 50 >&2
MainMenu
;;
${DIALOG_ESC})
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "Exit Program" --gauge "Program Aborted" 7 50 >&2
MainMenu
;;
esac
case ${SelectOGG} in
  01)  dialog --backtitle "www.DBNITRO.net" --title "GOLDENGATE: VERIFY GOLDEN GATE CONFIGURATION" --no-collapse --colors --msgbox "$(Func_OGG_001)" 0 0
       SepLine
       OGG_001
       Continue
  ;;
  02)  dialog --backtitle "www.DBNITRO.net" --title "GOLDENGATE: " --no-collapse --colors --msgbox "$(Func_OGG_002)" 0 0
       SepLine
       OGG_002
       Continue
  ;;
  03)  dialog --backtitle "www.DBNITRO.net" --title "GOLDENGATE: " --no-collapse --colors --msgbox "$(Func_OGG_003)" 0 0
       SepLine
       OGG_003
       Continue
  ;;
  04)  dialog --backtitle "www.DBNITRO.net" --title "GOLDENGATE: " --no-collapse --colors --msgbox "$(Func_OGG_004)" 0 0
       SepLine
       OGG_004
       Continue
  ;;
  99)  dialog --backtitle "www.DBNITRO.net" --title "GOLDENGATE: " --no-collapse --colors --msgbox "$(Func_OGG_099)" 0 0
       SepLine
       OGG_099
       Continue
	;;
  100) dialog --backtitle "www.DBNITRO.net" --title "GOLDENGATE: " --no-collapse --colors --msgbox "$(Func_OGG_100)" 0 0
       SepLine
       OGG_100
       Continue
  ;;
  esac
done
}
#
#########################################################################################################
# GOLDENGATE: 
#########################################################################################################
#

#
#########################################################################################################
#
# WALLET Menu
#
#########################################################################################################
#
WALLET() {
#
#########################################################################################################
# Verify WALLET
#########################################################################################################
#
clear
if [[ ${varWALL} = "N" ]]; then
  dialog --backtitle "www.DBNITRO.net" --title "WALLET Menu" --no-collapse --colors --msgbox "Your WALLET is Not Available" 7 70
  MainMenu
fi
#
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "WALLET Menu" --no-collapse --colors --gauge "Open WALLET Menu" 7 50
#
#########################################################################################################
# Variables WALLET Menu
#########################################################################################################
#
. ${DBNITRO}/var/Database.${ORACLE_SID}.var
#
# . ${DBNITRO}/var/Wallet.${ORACLE_SID}.var
#
varDATE=$(date +%d\/%m\/%Y)
varTIME=$(date +%H\:%M)
#
while true; do
exec 3>&1
SelectWALL=$(dialog --backtitle "www.DBNITRO.net" --title "WALLET Menu" --clear --cancel-label "Back" --no-collapse --colors --inputbox "\
+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| OS: ${varOS} | UPTIME: ${varUPTIME} | KERNEL: ${varKERNEL} | PROCS: ${varPhysical_CPU} | MEMORY: ${varTotal_MEMORY} | MEM_USED: ${varUsed_MEMORY} | MEM_FREE: ${varFree_MEMORY} | SWAP: ${varSwap_MEMORY} | SWAP_USED: ${varSwap_USED_MEMORY} | SWAP_FREE: ${varSwap_Free_MEMORY}
+-+-+----+---------------------------------------------------+-+-+-----+---------------------------------------------------+-+---------------------------+-+----------------------------------------------------+
|+|-|  1 |                                                   |+|-|   2 |                                                   |+| ..........................: 
|+|-|  3 |                                                   |+|-|   4 |                                                   |+| ..........................: 
|+|-|  5 |                                                   |+|-|   6 |                                                   |+| ..........................: 
|+|-|  7 |                                                   |+|-|   8 |                                                   |+| ..........................: 
|+|-|  9 |                                                   |+|-|  10 |                                                   |+| ..........................: 
|+|-| 11 |                                                   |+|-|  12 |                                                   |+| ..........................: 
|+|-| 13 |                                                   |+|-|  14 |                                                   |+| ..........................: 
|+|-| 15 |                                                   |+|-|  16 |                                                   |+| ..........................: 
|+|-| 17 |                                                   |+|-|  18 |                                                   |+| ..........................: 
|+|-| 19 |                                                   |+|-|  20 |                                                   |+| ..........................: 
|+|-| 21 |                                                   |+|-|  22 |                                                   |+| ..........................: 
|+|-| 23 |                                                   |+|-|  24 |                                                   |+| ..........................: 
|+|-| 25 |                                                   |+|-|  26 |                                                   |+| ..........................: 
|+|-| 27 |                                                   |+|-|  28 |                                                   |+| ..........................: 
|+|-| 29 |                                                   |+|-|  30 |                                                   |+| ..........................: 
|+|-| 31 |                                                   |+|-|  32 |                                                   |+| ..........................: 
|+|-| 33 |                                                   |+|-|  34 |                                                   |+| ..........................: 
|+|-| 35 |                                                   |+|-|  36 |                                                   |+| ..........................: 
|+|-| 37 |                                                   |+|-|  38 |                                                   |+| ..........................: 
|+|-| 39 |                                                   |+|-|  40 |                                                   |+| ..........................: 
|+|-| 41 |                                                   |+|-|  42 |                                                   |+| ..........................: 
|+|-| 43 |                                                   |+|-|  44 |                                                   |+| ..........................: 
|+|-| 45 |                                                   |+|-|  46 |                                                   |+| ..........................: 
|+|-| 47 |                                                   |+|-|  48 |                                                   |+| ..........................: 
|+|-| 49 |                                                   |+|-|  50 |                                                   |+| ..........................: 
|+|-| 51 |                                                   |+|-|  52 |                                                   |+| ..........................: 
|+|-| 53 |                                                   |+|-|  54 |                                                   |+| ..........................: 
|+|-| 55 |                                                   |+|-|  56 |                                                   |+| ..........................: 
|+|-| 57 |                                                   |+|-|  58 |                                                   |+| ..........................: 
|+|-| 59 |                                                   |+|-|  60 |                                                   |+| ..........................: 
|+|-| 61 |                                                   |+|-|  62 |                                                   |+| ..........................: 
|+|-| 63 |                                                   |+|-|  64 |                                                   |+| ..........................: 
|+|-| 65 |                                                   |+|-|  66 |                                                   |+| ..........................: 
|+|-| 67 |                                                   |+|-|  68 |                                                   |+| ..........................: 
|+|-| 69 |                                                   |+|-|  70 |                                                   |+| ..........................: 
|+|-| 71 |                                                   |+|-|  72 |                                                   |+| ..........................: 
|+|-| 73 |                                                   |+|-|  74 |                                                   |+| ..........................: 
|+|-| 75 |                                                   |+|-|  76 |                                                   |+| ..........................: 
|+|-| 77 |                                                   |+|-|  78 |                                                   |+| ..........................: 
|+|-| 79 |                                                   |+|-|  80 |                                                   |+| ..........................: 
|+|-| 81 |                                                   |+|-|  82 |                                                   |+| ..........................: 
|+|-| 83 |                                                   |+|-|  84 |                                                   |+| ..........................: 
|+|-| 85 |                                                   |+|-|  86 |                                                   |+| ..........................: 
|+|-| 87 |                                                   |+|-|  88 |                                                   |+| ..........................: 
|+|-| 89 |                                                   |+|-|  90 |                                                   |+| ..........................: 
|+|-| 91 |                                                   |+|-|  92 |                                                   |+| ..........................: 
|+|-| 93 |                                                   |+|-|  94 |                                                   |+| ..........................: 
|+|-| 95 |                                                   |+|-|  96 |                                                   |+| ..........................: 
|+|-| 97 |                                                   |+|-|  98 |                                                   |+| ..........................: 
|+|-| 99 | REPORT                                            |+|-| 100 | EXTRAS                                            |+| ..........................: 
+-+-+----+---------------------------------------------------+-+-+-----+---------------------------------------------------+-+---------------------------+-+----------------------------------------------------+
| CHOOSE ONE OF THOSE OPTIONS [ 0 - 100 ] | OPTIONS WITH [ @ ] HAS MORE FILTERS | VERSION: ${SoftwareVersion} | MODIFIED: ${DateofModification} | DATE & TIME: ${varDATE} ${varTIME}
+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+" 0 0 3>&1 1>&2 2>&3 3>&-)
exit_status=$?
exec 3>&-
case ${exit_status} in ${DIALOG_CANCEL})
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "Exit Program" --gauge "Program Closed" 7 50 >&2
MainMenu
;;
${DIALOG_ESC})
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "Exit Program" --gauge "Program Aborted" 7 50 >&2
MainMenu
;;
esac
case ${SelectWALL} in
  01)  dialog --backtitle "www.DBNITRO.net" --title "WALLET: " --no-collapse --colors --msgbox "$(Func_WALL_001)" 0 0
    ;;
  02)  dialog --backtitle "www.DBNITRO.net" --title "WALLET: " --no-collapse --colors --msgbox "$(Func_WALL_002)" 0 0
    ;;
  99)  dialog --backtitle "www.DBNITRO.net" --title "WALLET: REPORT" --no-collapse --colors --msgbox "$(Func_WALL_099)" 0 0
    ;;
  100) dialog --backtitle "www.DBNITRO.net" --title "WALLET: EXTRAS" --no-collapse --colors --msgbox "$(Func_WALL_100)" 0 0
    ;;
  esac
done
}
#
#########################################################################################################
# WALLET: 
#########################################################################################################
#

#
#########################################################################################################
#
# ODA Menu
#
#########################################################################################################
#
ODA() {
#
#########################################################################################################
# Verify ODA
#########################################################################################################
#
clear
if [[ ${varODA} = "N" ]]; then
  dialog --backtitle "www.DBNITRO.net" --title "ODA Menu" --no-collapse --colors --msgbox "Your ODA is Not Available" 7 70
  MainMenu
fi
#
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "ODA Menu" --no-collapse --colors --gauge "Open ODA Menu" 7 50
#
#########################################################################################################
# Variables ODA Menu
#########################################################################################################
#
# . ${DBNITRO}/var/ODA.${ORACLE_SID}.var
#
varDATE=$(date +%d\/%m\/%Y)
varTIME=$(date +%H\:%M)
#
while true; do
exec 3>&1
SelectODA=$(dialog --backtitle "www.DBNITRO.net" --title "ODA Menu" --clear --cancel-label "Back" --no-collapse --colors --inputbox "\
+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| OS: ${varOS} | UPTIME: ${varUPTIME} | KERNEL: ${varKERNEL} | PROCS: ${varPhysical_CPU} | MEMORY: ${varTotal_MEMORY} | MEM_USED: ${varUsed_MEMORY} | MEM_FREE: ${varFree_MEMORY} | SWAP: ${varSwap_MEMORY} | SWAP_USED: ${varSwap_USED_MEMORY} | SWAP_FREE: ${varSwap_Free_MEMORY}
+-+-+----+---------------------------------------------------+-+-+-----+---------------------------------------------------+-+---------------------------+-+----------------------------------------------------+
|+|-|  1 |                                                   |+|-|   2 |                                                   |+| ..........................: 
|+|-|  3 |                                                   |+|-|   4 |                                                   |+| ..........................: 
|+|-|  5 |                                                   |+|-|   6 |                                                   |+| ..........................: 
|+|-|  7 |                                                   |+|-|   8 |                                                   |+| ..........................: 
|+|-|  9 |                                                   |+|-|  10 |                                                   |+| ..........................: 
|+|-| 11 |                                                   |+|-|  12 |                                                   |+| ..........................: 
|+|-| 13 |                                                   |+|-|  14 |                                                   |+| ..........................: 
|+|-| 15 |                                                   |+|-|  16 |                                                   |+| ..........................: 
|+|-| 17 |                                                   |+|-|  18 |                                                   |+| ..........................: 
|+|-| 19 |                                                   |+|-|  20 |                                                   |+| ..........................: 
|+|-| 21 |                                                   |+|-|  22 |                                                   |+| ..........................: 
|+|-| 23 |                                                   |+|-|  24 |                                                   |+| ..........................: 
|+|-| 25 |                                                   |+|-|  26 |                                                   |+| ..........................: 
|+|-| 27 |                                                   |+|-|  28 |                                                   |+| ..........................: 
|+|-| 29 |                                                   |+|-|  30 |                                                   |+| ..........................: 
|+|-| 31 |                                                   |+|-|  32 |                                                   |+| ..........................: 
|+|-| 33 |                                                   |+|-|  34 |                                                   |+| ..........................: 
|+|-| 35 |                                                   |+|-|  36 |                                                   |+| ..........................: 
|+|-| 37 |                                                   |+|-|  38 |                                                   |+| ..........................: 
|+|-| 39 |                                                   |+|-|  40 |                                                   |+| ..........................: 
|+|-| 41 |                                                   |+|-|  42 |                                                   |+| ..........................: 
|+|-| 43 |                                                   |+|-|  44 |                                                   |+| ..........................: 
|+|-| 45 |                                                   |+|-|  46 |                                                   |+| ..........................: 
|+|-| 47 |                                                   |+|-|  48 |                                                   |+| ..........................: 
|+|-| 49 |                                                   |+|-|  50 |                                                   |+| ..........................: 
|+|-| 51 |                                                   |+|-|  52 |                                                   |+| ..........................: 
|+|-| 53 |                                                   |+|-|  54 |                                                   |+| ..........................: 
|+|-| 55 |                                                   |+|-|  56 |                                                   |+| ..........................: 
|+|-| 57 |                                                   |+|-|  58 |                                                   |+| ..........................: 
|+|-| 59 |                                                   |+|-|  60 |                                                   |+| ..........................: 
|+|-| 61 |                                                   |+|-|  62 |                                                   |+| ..........................: 
|+|-| 63 |                                                   |+|-|  64 |                                                   |+| ..........................: 
|+|-| 65 |                                                   |+|-|  66 |                                                   |+| ..........................: 
|+|-| 67 |                                                   |+|-|  68 |                                                   |+| ..........................: 
|+|-| 69 |                                                   |+|-|  70 |                                                   |+| ..........................: 
|+|-| 71 |                                                   |+|-|  72 |                                                   |+| ..........................: 
|+|-| 73 |                                                   |+|-|  74 |                                                   |+| ..........................: 
|+|-| 75 |                                                   |+|-|  76 |                                                   |+| ..........................: 
|+|-| 77 |                                                   |+|-|  78 |                                                   |+| ..........................: 
|+|-| 79 |                                                   |+|-|  80 |                                                   |+| ..........................: 
|+|-| 81 |                                                   |+|-|  82 |                                                   |+| ..........................: 
|+|-| 83 |                                                   |+|-|  84 |                                                   |+| ..........................: 
|+|-| 85 |                                                   |+|-|  86 |                                                   |+| ..........................: 
|+|-| 87 |                                                   |+|-|  88 |                                                   |+| ..........................: 
|+|-| 89 |                                                   |+|-|  90 |                                                   |+| ..........................: 
|+|-| 91 |                                                   |+|-|  92 |                                                   |+| ..........................: 
|+|-| 93 |                                                   |+|-|  94 |                                                   |+| ..........................: 
|+|-| 95 |                                                   |+|-|  96 |                                                   |+| ..........................: 
|+|-| 97 |                                                   |+|-|  98 |                                                   |+| ..........................: 
|+|-| 99 | REPORT                                            |+|-| 100 | EXTRAS                                            |+| ..........................: 
+-+-+----+---------------------------------------------------+-+-+-----+---------------------------------------------------+-+---------------------------+-+----------------------------------------------------+
| CHOOSE ONE OF THOSE OPTIONS [ 0 - 100 ] | OPTIONS WITH [ @ ] HAS MORE FILTERS | VERSION: ${SoftwareVersion} | MODIFIED: ${DateofModification} | DATE & TIME: ${varDATE} ${varTIME}
+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+" 0 0 3>&1 1>&2 2>&3 3>&-)
exit_status=$?
exec 3>&-
case ${exit_status} in ${DIALOG_CANCEL})
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "Exit Program" --gauge "Program Closed" 7 50 >&2
MainMenu
;;
${DIALOG_ESC})
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "Exit Program" --gauge "Program Aborted" 7 50 >&2
MainMenu
;;
esac
case ${SelectODA} in
  01)    dialog --backtitle "www.DBNITRO.net" --title "DATABASE APPLIANCE: " --no-collapse --colors --msgbox "$(Func_ODA_001)" 0 0
    ;;
  02)    dialog --backtitle "www.DBNITRO.net" --title "DATABASE APPLIANCE: " --no-collapse --colors --msgbox "$(Func_ODA_001)" 0 0
    ;;
  99)    dialog --backtitle "www.DBNITRO.net" --title "DATABASE APPLIANCE: REPORT" --no-collapse --colors --msgbox "$(Func_ODA_099)" 0 0
    ;;
  100)    dialog --backtitle "www.DBNITRO.net" --title "DATABASE APPLIANCE: EXTRAS" --no-collapse --colors --msgbox "$(Func_ODA_100)" 0 0
    ;;
  esac
done
}
#
#########################################################################################################
# ODA: 
#########################################################################################################
#

#
#########################################################################################################
#
# EXADATA Menu
#
#########################################################################################################
#
EXADATA() {
#
#########################################################################################################
# Verify EXADATA
#########################################################################################################
#
clear
if [[ ${varEXA} = "N" ]]; then
  dialog --backtitle "www.DBNITRO.net" --title "EXADATA Menu" --no-collapse --colors --msgbox "Your EXADATA is Not Available" 7 70
  MainMenu
fi
#
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "EXADATA Menu" --no-collapse --colors --gauge "Open EXADATA Menu" 7 50
#
#########################################################################################################
# Variables EXADATA Menu
#########################################################################################################
#
# . ${DBNITRO}/var/EXA.${ORACLE_SID}.var
#
varDATE=$(date +%d\/%m\/%Y)
varTIME=$(date +%H\:%M)
#
while true; do
exec 3>&1
SelectEXA=$(dialog --backtitle "www.DBNITRO.net" --title "EXADATA Menu" --clear --cancel-label "Back" --no-collapse --colors --inputbox "\
+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| OS: ${varOS} | UPTIME: ${varUPTIME} | KERNEL: ${varKERNEL} | PROCS: ${varPhysical_CPU} | MEMORY: ${varTotal_MEMORY} | MEM_USED: ${varUsed_MEMORY} | MEM_FREE: ${varFree_MEMORY} | SWAP: ${varSwap_MEMORY} | SWAP_USED: ${varSwap_USED_MEMORY} | SWAP_FREE: ${varSwap_Free_MEMORY}
+-+-+----+---------------------------------------------------+-+-+-----+---------------------------------------------------+-+---------------------------+-+----------------------------------------------------+
|+|-|  1 | Exadata Rack Layout                               |+|-|   2 | Exadata Many Rack Layout                          |+| ..........................: 
|+|-|  3 | Verify Cell Status                                |+|-|   4 | Verify ASM DU                                     |+| ..........................: 
|+|-|  5 | Verify How Smart                                  |+|-|   6 | Verify EXADATA Version                            |+| ..........................: 
|+|-|  7 | Verify EXADATA LSPATCHES                          |+|-|   8 | Verify EXADATA Many LSPATCHES                     |+| ..........................: 
|+|-|  9 | Verify RAC / CLUSTER Status                       |+|-|  10 | Verify EXADATA RAC / CLUSTER Monitor              |+| ..........................: 
|+|-| 11 | Verify Exadata RAC on All DB                      |+|-|  12 |                                                   |+| ..........................: 
|+|-| 13 |                                                   |+|-|  14 |                                                   |+| ..........................: 
|+|-| 15 |                                                   |+|-|  16 |                                                   |+| ..........................: 
|+|-| 17 |                                                   |+|-|  18 |                                                   |+| ..........................: 
|+|-| 19 |                                                   |+|-|  20 |                                                   |+| ..........................: 
|+|-| 21 |                                                   |+|-|  22 |                                                   |+| ..........................: 
|+|-| 23 |                                                   |+|-|  24 |                                                   |+| ..........................: 
|+|-| 25 |                                                   |+|-|  26 |                                                   |+| ..........................: 
|+|-| 27 |                                                   |+|-|  28 |                                                   |+| ..........................: 
|+|-| 29 |                                                   |+|-|  30 |                                                   |+| ..........................: 
|+|-| 31 |                                                   |+|-|  32 |                                                   |+| ..........................: 
|+|-| 33 |                                                   |+|-|  34 |                                                   |+| ..........................: 
|+|-| 35 |                                                   |+|-|  36 |                                                   |+| ..........................: 
|+|-| 37 |                                                   |+|-|  38 |                                                   |+| ..........................: 
|+|-| 39 |                                                   |+|-|  40 |                                                   |+| ..........................: 
|+|-| 41 |                                                   |+|-|  42 |                                                   |+| ..........................: 
|+|-| 43 |                                                   |+|-|  44 |                                                   |+| ..........................: 
|+|-| 45 |                                                   |+|-|  46 |                                                   |+| ..........................: 
|+|-| 47 |                                                   |+|-|  48 |                                                   |+| ..........................: 
|+|-| 49 |                                                   |+|-|  50 |                                                   |+| ..........................: 
|+|-| 51 |                                                   |+|-|  52 |                                                   |+| ..........................: 
|+|-| 53 |                                                   |+|-|  54 |                                                   |+| ..........................: 
|+|-| 55 |                                                   |+|-|  56 |                                                   |+| ..........................: 
|+|-| 57 |                                                   |+|-|  58 |                                                   |+| ..........................: 
|+|-| 59 |                                                   |+|-|  60 |                                                   |+| ..........................: 
|+|-| 61 |                                                   |+|-|  62 |                                                   |+| ..........................: 
|+|-| 63 |                                                   |+|-|  64 |                                                   |+| ..........................: 
|+|-| 65 |                                                   |+|-|  66 |                                                   |+| ..........................: 
|+|-| 67 |                                                   |+|-|  68 |                                                   |+| ..........................: 
|+|-| 69 |                                                   |+|-|  70 |                                                   |+| ..........................: 
|+|-| 71 |                                                   |+|-|  72 |                                                   |+| ..........................: 
|+|-| 73 |                                                   |+|-|  74 |                                                   |+| ..........................: 
|+|-| 75 |                                                   |+|-|  76 |                                                   |+| ..........................: 
|+|-| 77 |                                                   |+|-|  78 |                                                   |+| ..........................: 
|+|-| 79 |                                                   |+|-|  80 |                                                   |+| ..........................: 
|+|-| 81 |                                                   |+|-|  82 |                                                   |+| ..........................: 
|+|-| 83 |                                                   |+|-|  84 |                                                   |+| ..........................: 
|+|-| 85 |                                                   |+|-|  86 |                                                   |+| ..........................: 
|+|-| 87 |                                                   |+|-|  88 |                                                   |+| ..........................: 
|+|-| 89 |                                                   |+|-|  90 |                                                   |+| ..........................: 
|+|-| 91 |                                                   |+|-|  92 |                                                   |+| ..........................: 
|+|-| 93 |                                                   |+|-|  94 |                                                   |+| ..........................: 
|+|-| 95 |                                                   |+|-|  96 |                                                   |+| ..........................: 
|+|-| 97 |                                                   |+|-|  98 |                                                   |+| ..........................: 
|+|-| 99 | REPORT                                            |+|-| 100 | EXTRAS                                            |+| ..........................: 
+-+-+----+---------------------------------------------------+-+-+-----+---------------------------------------------------+-+---------------------------+-+----------------------------------------------------+
| CHOOSE ONE OF THOSE OPTIONS [ 0 - 100 ] | OPTIONS WITH [ @ ] HAS MORE FILTERS | VERSION: ${SoftwareVersion} | MODIFIED: ${DateofModification} | DATE & TIME: ${varDATE} ${varTIME}
+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+" 0 0 3>&1 1>&2 2>&3 3>&-)
exit_status=$?
exec 3>&-
case ${exit_status} in ${DIALOG_CANCEL})
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "Exit Program" --gauge "Program Closed" 7 50 >&2
MainMenu
;;
${DIALOG_ESC})
for ((i = 0 ; i <= 100; i+=10)); do sleep 0.01; echo $i; done | dialog --backtitle "www.DBNITRO.net" --title "Exit Program" --gauge "Program Aborted" 7 50 >&2
MainMenu
;;
esac
case ${SelectEXA} in
  01)    dialog --backtitle "www.DBNITRO.net" --title "EXADATA: Exadata Rack Layout" --no-collapse --colors --msgbox "$(Func_EXA_001)" 0 0
    ;;
  02)    dialog --backtitle "www.DBNITRO.net" --title "EXADATA: Exadata Many Rack Layout" --no-collapse --colors --msgbox "$(Func_EXA_002)" 0 0
    ;;
  03)    dialog --backtitle "www.DBNITRO.net" --title "EXADATA: Verify Cell Status" --no-collapse --colors --msgbox "$(Func_EXA_003)" 0 0
    ;;
  04)    dialog --backtitle "www.DBNITRO.net" --title "EXADATA: Verify ASM DU" --no-collapse --colors --msgbox "$(Func_EXA_004)" 0 0
    ;;
  05)    dialog --backtitle "www.DBNITRO.net" --title "EXADATA: Verify How Smart" --no-collapse --colors --msgbox "$(Func_EXA_005)" 0 0
    ;;
  06)    dialog --backtitle "www.DBNITRO.net" --title "EXADATA: Verify EXADATA Version" --no-collapse --colors --msgbox "$(Func_EXA_006)" 0 0
    ;;
  07)    dialog --backtitle "www.DBNITRO.net" --title "EXADATA: Verify EXADATA LSPATCHES" --no-collapse --colors --msgbox "$(Func_EXA_007)" 0 0
    ;;
  08)    dialog --backtitle "www.DBNITRO.net" --title "EXADATA: Verify EXADATA Many LSPATCHES" --no-collapse --colors --msgbox "$(Func_EXA_008)" 0 0
    ;;
  09)    dialog --backtitle "www.DBNITRO.net" --title "EXADATA: Verify RAC / CLUSTER Status" --no-collapse --colors --msgbox "$(Func_EXA_009)" 0 0
    ;;
  10)    dialog --backtitle "www.DBNITRO.net" --title "EXADATA: Verify EXADATA RAC / CLUSTER Monitor" --no-collapse --colors --msgbox "$(Func_EXA_010)" 0 0
    ;;
  11)    dialog --backtitle "www.DBNITRO.net" --title "EXADATA: Verify Exadata RAC on All DB" --no-collapse --colors --msgbox "$(Func_EXA_011)" 0 0
    ;;
  12)    dialog --backtitle "www.DBNITRO.net" --title "EXADATA: " --no-collapse --colors --msgbox "$(Func_EXA_012)" 0 0
    ;;
  13)    dialog --backtitle "www.DBNITRO.net" --title "EXADATA: " --no-collapse --colors --msgbox "$(Func_EXA_013)" 0 0
    ;;
  99)    dialog --backtitle "www.DBNITRO.net" --title "EXADATA: REPORT" --no-collapse --colors --msgbox "$(Func_EXA_099)" 0 0
    ;;
  100)   dialog --backtitle "www.DBNITRO.net" --title "EXADATA: EXTRAS" --no-collapse --colors --msgbox "$(Func_EXA_100)" 0 0
    ;;
  esac
done
}
#
#########################################################################################################
#########################################################################################################
#########################################################################################################
#########################################################################################################
#
MainMenu
#
#########################################################################################################
# Finish of the System
#########################################################################################################
#