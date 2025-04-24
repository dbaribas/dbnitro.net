#!/bin/sh
Author="Andre Augusto Ribas"
SoftwareVersion="1.0.1"
DateCreation="29/11/2023"
DateModification="29/11/2023"
EMAIL="ribas@dbnitro.net"
GITHUB="https://github.com/dbaribas/dbnitro.net"
WEBSITE="http://dbnitro.net"
#
#--------------------------------------------------------------------------------------------
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
#--------------------------------------------------------------------------------------------
# Vefiry which OS is running
#
if [[ $(uname) == "SunOS" ]]; then
  OS="Solaris"
elif [[ $(uname) == "AIX" ]]; then
  OS="AIX"
elif [[ $(uname) == "Linux" ]]; then
  OS="Linux"
fi
#
#--------------------------------------------------------------------------------------------
# GoldenGate Monitoring 
#
SepLine() {
if [[ $(uname) == "SunOS" ]]; then
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
elif [[ $(uname) == "AIX" ]]; then
  printf '%*s' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
elif [[ $(uname) == "Linux" ]]; then
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
fi
}
#
#--------------------------------------------------------------------------------------------
# Gera Info 1
#
GeraInfo1() {
  echo "show configuration lag verbose" | dgmgrl / > ${LOGS}/GeraInfoODG.txt
}
#
#--------------------------------------------------------------------------------------------
# Gera Info 2
#
GeraInfo2() {
  echo "show configuration lag verbose" | dgmgrl / > ${OGG_HOME}/GeraInfoODG.txt
EOF
}
#
#--------------------------------------------------------------------------------------------
#

# Configuration
cat ${LOGS}/gerainfodg.txt | egrep -w 'Configuration -' | awk '{ print $3 }'

# Primary Database
cat ${LOGS}/gerainfodg.txt | egrep -w 'Primary database' | awk '{ print $1 }'

# Physical standby database
cat ${LOGS}/gerainfodg.txt | egrep -w 'Physical standby database' | awk '{ print $1 }'

# Transport Lag
cat ${LOGS}/gerainfodg.txt | egrep -w 'Transport Lag' | awk '{ print $3 }'

# Apply Lag
cat ${LOGS}/gerainfodg.txt | egrep -w 'Apply Lag' | awk '{ print $3 }'

# Fast-Start Failover
cat ${LOGS}/gerainfodg.txt | egrep -w 'Fast-Start Failover:' | awk '{ print $3 }'









while true; clear; do
SepLine
echo "INSTANCE: ${ORACLE_SID} | DATE: $(date)"
#
DATABKP=$(date +%H:%M)
#
SepLine
#
echo "LASTS CHECKPOINTS"
#
SepLine
#
GeraInfo2
awk -v DTHORA=${DATABKP} ' { 
if ( $1 == "REPLICAT" ) 
  printf( "%s", $2 " ---> ")
else 
     if ( $3 == "RBA" )
     if (substr($2,1,5) == DTHORA) {system("tput sgr0 ~/"); print substr($2,1,8)}
else if ( substr(DTHORA,4,5) - substr($2,4,5) <0 ) {system("tput bold ~/"); print "LAG ---> (" DTHORA " - " substr($2,1,5)") = " substr(DTHORA,1,2) - substr($2,1,2)":" substr($2,4,5) - substr(DTHORA,4,5)}
else if ( $3 == "RBA" ) {system("tput bold ~/"); print "LAG ---> (" DTHORA " - " substr($2,1,5)") = " substr(DTHORA,1,2)-substr($2,1,2)":" substr(DTHORA,4,5) - substr($2,4,5)}
}' ${OGG_HOME}/gerainfoacs.txt
#
SepLine
#
echo "PROCESS     STATUS      NAME        LAG           CHECKPOINT"
#
SepLine
#
GeraInfo1
awk ' {
       if ( $5 >  "00:05:00" && $2 == "RUNNING" ) {system("tput bold ~/"); system("tput setaf 3 ~/"); print $0 "<--- CHKPOINT!"; system("tput sgr0 ~/");}
  else if ( $4 >= "00:05:00" && $2 == "RUNNING" ) {system("tput bold ~/"); system("tput setaf 3 ~/"); print $0 "<--- LAG HIGH!"; system("tput sgr0 ~/");}
  else if ( $4 <  "00:05:00" && $2 == "RUNNING" ) {system("tput setaf 9 ~/"); print $0; system("tput sgr0 ~/");}
  else if ( $2 == "ABENDED" ) {system("tput bold ~/") system("tput setaf 1 ~/"); print $0 "<--- " $2; system("tput sgr0 ~/")}
  else if ( $2 == "STOPPED" ) {system("tput bold ~/") system("tput setaf 1 ~/"); print $0 "<--- " $2; system("tput sgr0 ~/")}
  else system("tput sgr0 ~/");
}' ${OGG_HOME}/gerainfoacs.txt
#
if [[ $(uname) == "SunOS" ]]; then
  DISK_TOTAL=$(df -h ${OGG_HOME} | grep -v -i "filesystem" | awk '{ print $2 }')
  DISK_USED=$(df -h ${OGG_HOME} | grep -v -i "filesystem" | awk '{ print $3, $5 }')
  DISK_FREE=$(df -h ${OGG_HOME} | grep -v -i "filesystem" | awk '{ print $4 }')
elif [[ $(uname) == "AIX" ]]; then
  DISK_TOTAL=$(df -g ${OGG_HOME} | grep -v -i "filesystem" | awk '{ print $2 }')
  DISK_USED=$(df -g ${OGG_HOME} | grep -v -i "filesystem" | awk '{ print $4 }')
  DISK_FREE=$(df -g ${OGG_HOME} | grep -v -i "filesystem" | awk '{ print $3 }')
elif [[ $(uname) == "Linux" ]]; then
  DISK_TOTAL=$(df -h ${OGG_HOME} | grep -v -i "filesystem" | awk '{ print $2 }')
  DISK_USED=$(df -h ${OGG_HOME} | grep -v -i "filesystem" | awk '{ print $3, " - ", $5 }')
  DISK_FREE=$(df -h ${OGG_HOME} | grep -v -i "filesystem" | awk '{ print $4 }')
fi
SepLine
#
echo "FREE AND USED SPACE ON FILESYSTEM OF GOLDENGATE STAGE"
#
SepLine
#
echo "STAGE: ${OGG_HOME} | TOTAL: ${DISK_TOTAL} | USED: ${DISK_USED} | FREE: ${DISK_FREE}"
#
SepLine
#
sleep 15
#
done
#
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
# THE SCRIPT FINISHES HERE
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
#