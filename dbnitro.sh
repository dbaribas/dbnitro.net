#!/bin/sh
#
Author="Andre Augusto Ribas"
SoftwareVersion="1.0.1"
DateCreation="22/06/2022"
DateModification="22/06/2022"
EMAIL_1="dba.ribas@gmail.com"
EMAIL_2="andre.ribas@icloud.com"
WEBSITE="http://dbnitro.net"
#
# ------------------------------------------------------------------------
# Verify if you are ROOT or not
#
if [[ "$(whoami)" != "root" ]]; then
  echo " -- YOU ARE NOT ROOT, YOU MUST BE ROOT TO EXECUTE THIS SCRIPT --"
  exit 1
fi
#
# ------------------------------------------------------------------------
# Verify if all pre-reqs Softwares are installed
#
if [[ $(which wget | wc -l | awk '{ print $1 }') == 0 ]]; then
  echo " -- You need to install wget app --"
  exit 1
fi
#
# ------------------------------------------------------------------------
# Creating and Installing the DBNITRO Components
#
FOLDER="/opt"
DBNITRO="${FOLDER}/dbnitro"
#
function RemoveFolder() {
if [[ -d ${DBNITRO}/ ]]; then
  rm -rf ${DBNITRO}/
fi
}
#
function CreateFolder() {
if [[ ! -d ${DBNITRO}/ ]]; then
  mkdir -p ${DBNITRO}/
fi
}
#
function SetUpDBNITRO() {
cd ${DBNITRO}/
#
wget -O ${DBNITRO}/.OracleMenu.sh        https://raw.githubusercontent.com/dbaribas/dbnitro/main/OracleMenu.sh
wget -O ${DBNITRO}/.Oracle_ASM_Functions https://raw.githubusercontent.com/dbaribas/dbnitro/main/Oracle_ASM_Functions
wget -O ${DBNITRO}/.Oracle_DBA_Functions https://raw.githubusercontent.com/dbaribas/dbnitro/main/Oracle_DBA_Functions
wget -O ${DBNITRO}/.Oracle_RAC_Functions https://raw.githubusercontent.com/dbaribas/dbnitro/main/Oracle_RAC_Functions
wget -O ${DBNITRO}/.Oracle_EXA_Functions https://raw.githubusercontent.com/dbaribas/dbnitro/main/Oracle_EXA_Functions
wget -O ${DBNITRO}/.Oracle_ODG_Functions https://raw.githubusercontent.com/dbaribas/dbnitro/main/Oracle_ODG_Functions
wget -O ${DBNITRO}/.Oracle_OGG_Functions https://raw.githubusercontent.com/dbaribas/dbnitro/main/Oracle_OGG_Functions
wget -O ${DBNITRO}/.Oracle_STR_Functions https://raw.githubusercontent.com/dbaribas/dbnitro/main/Oracle_STR_Functions
wget -O ${DBNITRO}/.Oracle_PDB_Functions https://raw.githubusercontent.com/dbaribas/dbnitro/main/Oracle_PDB_Functions
wget -O ${DBNITRO}/.Oracle_ODA_Functions https://raw.githubusercontent.com/dbaribas/dbnitro/main/Oracle_ODA_Functions
wget -O ${DBNITRO}/.Oracle_WALL_Functions https://raw.githubusercontent.com/dbaribas/dbnitro/main/Oracle_WALL_Functions
wget -O ${DBNITRO}/.Oracle_RMAN_Functions https://raw.githubusercontent.com/dbaribas/dbnitro/main/Oracle_RMAN_Functions
#
chmod a+x ${DBNITRO}/.OracleMenu.sh
chmod g+w ${DBNITRO}/.OracleMenu.sh
chmod 775 ${DBNITRO}/.OracleMenu.sh
#
wget https://raw.githubusercontent.com/freddenis/oracle-scripts/master/asmdu.sh
wget https://raw.githubusercontent.com/freddenis/oracle-scripts/master/cell-status.sh
wget https://raw.githubusercontent.com/freddenis/oracle-scripts/master/change-password.sh
wget https://raw.githubusercontent.com/freddenis/oracle-scripts/master/exa-howsmart.sh
wget https://raw.githubusercontent.com/freddenis/oracle-scripts/master/exa-iblinkinfo.sh
wget https://raw.githubusercontent.com/freddenis/oracle-scripts/master/exa-racklayout.sh
wget https://raw.githubusercontent.com/freddenis/oracle-scripts/master/exa-versions.sh
wget https://raw.githubusercontent.com/freddenis/oracle-scripts/master/gg-afterstop.sh
wget https://raw.githubusercontent.com/freddenis/oracle-scripts/master/gg-info.sh
wget https://raw.githubusercontent.com/freddenis/oracle-scripts/master/gg-start.sh
wget https://raw.githubusercontent.com/freddenis/oracle-scripts/master/gg-status.sh
wget https://raw.githubusercontent.com/freddenis/oracle-scripts/master/gg-stop.sh
wget https://raw.githubusercontent.com/freddenis/oracle-scripts/master/list-ohpatches.sh
wget https://raw.githubusercontent.com/freddenis/oracle-scripts/master/locks.sql
wget https://raw.githubusercontent.com/freddenis/oracle-scripts/master/lspatches.sh
wget https://raw.githubusercontent.com/freddenis/oracle-scripts/master/nfs-status.sh
wget https://raw.githubusercontent.com/freddenis/oracle-scripts/master/oci-check-backups.sh
wget https://raw.githubusercontent.com/freddenis/oracle-scripts/master/oraenv++
wget https://raw.githubusercontent.com/freddenis/oracle-scripts/master/pidsid.sql
wget https://raw.githubusercontent.com/freddenis/oracle-scripts/master/rac-mon.sh
wget https://raw.githubusercontent.com/freddenis/oracle-scripts/master/rac-on_all_db.sh
wget https://raw.githubusercontent.com/freddenis/oracle-scripts/master/rac-status-rh6.sh
wget https://raw.githubusercontent.com/freddenis/oracle-scripts/master/rac-status.sh
wget https://raw.githubusercontent.com/freddenis/oracle-scripts/master/rac-status_suresh.sh
wget https://raw.githubusercontent.com/freddenis/oracle-scripts/master/rman-backup.sh
wget https://raw.githubusercontent.com/freddenis/oracle-scripts/master/sidpid.sql
wget https://raw.githubusercontent.com/freddenis/oracle-scripts/master/svc-set-failback-yes.sh
wget https://raw.githubusercontent.com/freddenis/oracle-scripts/master/svc-show-config.sh
wget https://raw.githubusercontent.com/freddenis/oracle-scripts/master/yal.sh
#
chmod a+x ${DBNITRO}/*.sh
chmod a+x ${DBNITRO}/oraenv++
#
chmod -R 775 ${DBNITRO}/
chown -R oracle.oinstall ${DBNITRO}/
#
}
#
# ------------------------------------------------------------------------
# Setup PurgLogs from Oracle Products (ONLY WITH GRID INFRASTRUCTURE)
#
function SetUpPURGELOGS() {
cd ${DBNITRO}/
wget -O ${DBNITRO}/purgeLogs         https://raw.githubusercontent.com/dbaribas/dbnitro/main/purgeLogs
wget -O /etc/cron.daily/purgeLogs.sh https://raw.githubusercontent.com/dbaribas/dbnitro/main/purgeLogs.sh
#
chmod a+x ${DBNITRO}/purgeLogs
chmod a+x /etc/cron.daily/purgeLogs.sh
#
chmod -R 775 ${DBNITRO}/purgeLogs
chmod -R 775 /etc/cron.daily/purgeLogs.sh
#
chown -R oracle.oinstall ${DBNITRO}/purgeLogs
chown -R oracle.oinstall /etc/cron.daily/purgeLogs.sh
#
}
#
# ------------------------------------------------------------------------
# Add the Content on Grid Profile
#
function SetUpGrid() {
if [[ $(cat /etc/passwd | grep grid | wc -l) != 0 ]]; then
  cat > /home/grid/.bash_profile <<EOF
# .bash_profile

# Get the aliases and functions
if [[ -f ~/.bashrc ]]; then
       . ~/.bashrc
fi
#
# User specific environment and startup programs
#
export PATH=/usr/local/bin:/bin:/sbin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/grid/.local/bin:/home/grid/bin
export PS1=\$'[ \${LOGNAME}@\h:\$(pwd): ]\$ '
#
echo " -- TO SELECT ANY ORACLE PRODUCT, JUST TYPE: db --"
echo " -- IT WILL SHOW YOU ALL OPTIONS YOU CAN USE --"
alias db='. ${DBNITRO}/.OracleMenu.sh'
#
umask 0022
EOF
else
  echo " -- Your Environment does not have Grid User --"
  break
fi
}
#
# ------------------------------------------------------------------------
# Add the Content on Oracle Profile
#
function SetUpOracle() {
if [[ $(cat /etc/passwd | grep oracle | wc -l) != 0 ]]; then
  cat > /home/oracle/.bash_profile <<EOF
# .bash_profile

# Get the aliases and functions
if [[ -f ~/.bashrc ]]; then
       . ~/.bashrc
fi
#
# User specific environment and startup programs
#
export PATH=/usr/local/bin:/bin:/sbin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/oracle/.local/bin:/home/oracle/bin
export PS1=\$'[ \${LOGNAME}@\h:\$(pwd): ]\$ '
#
echo " -- TO SELECT ANY ORACLE PRODUCT, JUST TYPE: db --"
echo " -- IT WILL SHOW YOU ALL OPTIONS YOU CAN USE --"
alias db='. ${DBNITRO}/.OracleMenu.sh'
#
umask 0022
EOF
else
  echo " -- Your Environment does not have Grid User --"
  break
fi
}
#
function MainMenu() {
PS3="Select the Option: "
select OPT in INSTALL UPDATE OLD_ENV REMOVE QUIT; do
if [[ "${OPT}" == "QUIT" ]]; then
  echo " -- Exit Menu --"
elif [[ "${OPT}" == "INSTALL" ]]; then
  echo " -- Install DBNITRO Environment --"
  CreateFolder
  SetUpGrid
  SetUpOracle
  SetUpDBNITRO
  SetUpPURGELOGS
elif [[ "${OPT}" == "UPDATE" ]]; then
  echo " -- Update DBNITRO Environment --"
  RemoveFolder
  CreateFolder
  SetUpGrid
  SetUpOracle
  SetUpDBNITRO
  SetUpPURGELOGS
elif [[ "${OPT}" == "OLD_ENV" ]]; then
  echo " -- Install DBNITRO Environment for OLD Servers --"
  CreateFolder
  SetUpDBNITRO
  SetUpPURGELOGS
  echo "alias db='. ${DBNITRO}/.OracleMenu.sh'" >> /home/oracle/.bash_profile
elif [[ "${OPT}" == "REMOVE" ]]; then
  echo " -- Remove DBNITRO Environment --"
  RemoveFolder
else
  echo " -- Invalid Option --"
  continue
fi
break
done
}
#
MainMenu
#
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
# THE SCRIPT FINISHES HERE
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
#
