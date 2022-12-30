#!/bin/sh
#
Author="Andre Augusto Ribas"
SoftwareVersion="1.0.5"
DateCreation="22/06/2022"
DateModification="16/11/2022"
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
function HELP() {
SetClear
SepLine
echo -e "\
|#| INSTALL...: YOU CAN INSTALL THE DBNITRO SCRIPTS AND FUNCTIONS
|#| UPDATE....: YOU CAN UPDATE THE DBNITRO INSTALLATION
|#| OLD_ENV...: YOU CAN INSTALL AND ENABLE THE FUNCTIONALITIES IN AN OLD ENVIRONMENT
|#| REMOVE....: YOU CAN REMOVE THE DBNITRO INSTALLATION
|#| HELP......: YOU CAN CHECK THE OPTIONS"
SepLine
}
#
# ------------------------------------------------------------------------
# Creating and Installing the DBNITRO Components
#
FOLDER="/opt"                       # ===> HERE YOU HAVE TO CONFIGURE THE PATH OF DBNITRO, WHERE IT WILL BE INSTALLED
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
  mkdir -p ${DBNITRO}/bin/
  mkdir -p ${DBNITRO}/var/
  mkdir -p ${DBNITRO}/reports/
  mkdir -p ${DBNITRO}/functions/
  mkdir -p ${DBNITRO}/sql/
fi
}
#
function SetUpDBNITRO() {
cd ${DBNITRO}/
# ===> Here is the DBNITRO Files
wget -O ${DBNITRO}/bin/OracleMenu.sh                                     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/OracleMenu.sh
wget -O ${DBNITRO}/bin/Oracle_DBA_Check_Hugepages.sh                     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/Oracle_DBA_Check_Hugepages.sh
wget -O ${DBNITRO}/bin/Oracle_Golden_Gate_Monitor.sh                     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/Oracle_Golden_Gate_Monitor.sh
wget -O ${DBNITRO}/bin/Oracle_Check_Instance.pl                          https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/Oracle_Check_Instance.pl
wget -O ${DBNITRO}/bin/Oracle_DBA_Daily_Check.sh                         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/Oracle_DBA_Daily_Check.sh
wget -O ${DBNITRO}/sql/Oracle_SQL_DBA_Info.sql                           https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/Oracle_SQL_DBA_Info.sql
wget -O ${DBNITRO}/sql/Oracle_SQL_DBA_H_Check.sql                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/Oracle_SQL_DBA_H_Check.sql
wget -O ${DBNITRO}/sql/Oracle_SQL_Report_v.3.0.1.sql                     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/Oracle_SQL_Report_v.3.0.1.sql
wget -O ${DBNITRO}/sql/Oracle_SQL_Check_Hugepages.sql                    https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/Oracle_SQL_Check_Hugepages.sql
wget -O ${DBNITRO}/sql/Oracle_SQL_Options_Packs_Usage_Statistics.sql     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/Oracle_SQL_Options_Packs_Usage_Statistics.sql
wget -O ${DBNITRO}/functions/Oracle_ASM_Functions                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/Oracle_ASM_Functions
wget -O ${DBNITRO}/functions/Oracle_DBA_Functions                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/Oracle_DBA_Functions
wget -O ${DBNITRO}/functions/Oracle_RAC_Functions                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/Oracle_RAC_Functions
wget -O ${DBNITRO}/functions/Oracle_EXA_Functions                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/Oracle_EXA_Functions
wget -O ${DBNITRO}/functions/Oracle_ODG_Functions                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/Oracle_ODG_Functions
wget -O ${DBNITRO}/functions/Oracle_OGG_Functions                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/Oracle_OGG_Functions
wget -O ${DBNITRO}/functions/Oracle_STR_Functions                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/Oracle_STR_Functions
wget -O ${DBNITRO}/functions/Oracle_PDB_Functions                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/Oracle_PDB_Functions
wget -O ${DBNITRO}/functions/Oracle_ODA_Functions                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/Oracle_ODA_Functions
wget -O ${DBNITRO}/functions/Oracle_WALL_Functions                       https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/Oracle_WALL_Functions
wget -O ${DBNITRO}/functions/Oracle_RMAN_Functions                       https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/Oracle_RMAN_Functions
# ===> Here is the Fred Denis Scripts
wget -o ${DBNITRO}/bin/asmdu.sh                                          https://raw.githubusercontent.com/freddenis/oracle-scripts/master/asmdu.sh
wget -o ${DBNITRO}/bin/cell-status.sh                                    https://raw.githubusercontent.com/freddenis/oracle-scripts/master/cell-status.sh
wget -o ${DBNITRO}/bin/change-password.sh                                https://raw.githubusercontent.com/freddenis/oracle-scripts/master/change-password.sh
wget -o ${DBNITRO}/bin/exa-howsmart.sh                                   https://raw.githubusercontent.com/freddenis/oracle-scripts/master/exa-howsmart.sh
wget -o ${DBNITRO}/bin/exa-iblinkinfo.sh                                 https://raw.githubusercontent.com/freddenis/oracle-scripts/master/exa-iblinkinfo.sh
wget -o ${DBNITRO}/bin/exa-racklayout.sh                                 https://raw.githubusercontent.com/freddenis/oracle-scripts/master/exa-racklayout.sh
wget -o ${DBNITRO}/bin/exa-versions.sh                                   https://raw.githubusercontent.com/freddenis/oracle-scripts/master/exa-versions.sh
wget -o ${DBNITRO}/bin/gg-afterstop.sh                                   https://raw.githubusercontent.com/freddenis/oracle-scripts/master/gg-afterstop.sh
wget -o ${DBNITRO}/bin/gg-info.sh                                        https://raw.githubusercontent.com/freddenis/oracle-scripts/master/gg-info.sh
wget -o ${DBNITRO}/bin/gg-start.sh                                       https://raw.githubusercontent.com/freddenis/oracle-scripts/master/gg-start.sh
wget -o ${DBNITRO}/bin/gg-status.sh                                      https://raw.githubusercontent.com/freddenis/oracle-scripts/master/gg-status.sh
wget -o ${DBNITRO}/bin/gg-stop.sh                                        https://raw.githubusercontent.com/freddenis/oracle-scripts/master/gg-stop.sh
wget -o ${DBNITRO}/bin/list-ohpatches.sh                                 https://raw.githubusercontent.com/freddenis/oracle-scripts/master/list-ohpatches.sh
wget -o ${DBNITRO}/bin/lspatches.sh                                      https://raw.githubusercontent.com/freddenis/oracle-scripts/master/lspatches.sh
wget -o ${DBNITRO}/bin/nfs-status.sh                                     https://raw.githubusercontent.com/freddenis/oracle-scripts/master/nfs-status.sh
wget -o ${DBNITRO}/bin/oci-check-backups.sh                              https://raw.githubusercontent.com/freddenis/oracle-scripts/master/oci-check-backups.sh
wget -o ${DBNITRO}/bin/oraenv++                                          https://raw.githubusercontent.com/freddenis/oracle-scripts/master/oraenv++
wget -o ${DBNITRO}/bin/rac-mon.sh                                        https://raw.githubusercontent.com/freddenis/oracle-scripts/master/rac-mon.sh
wget -o ${DBNITRO}/bin/rac-on_all_db.sh                                  https://raw.githubusercontent.com/freddenis/oracle-scripts/master/rac-on_all_db.sh
wget -o ${DBNITRO}/bin/rac-status-rh6.sh                                 https://raw.githubusercontent.com/freddenis/oracle-scripts/master/rac-status-rh6.sh
wget -o ${DBNITRO}/bin/rac-status.sh                                     https://raw.githubusercontent.com/freddenis/oracle-scripts/master/rac-status.sh
wget -o ${DBNITRO}/bin/rac-status_suresh.sh                              https://raw.githubusercontent.com/freddenis/oracle-scripts/master/rac-status_suresh.sh
wget -o ${DBNITRO}/bin/rman-backup.sh                                    https://raw.githubusercontent.com/freddenis/oracle-scripts/master/rman-backup.sh
wget -o ${DBNITRO}/bin/svc-set-failback-yes.sh                           https://raw.githubusercontent.com/freddenis/oracle-scripts/master/svc-set-failback-yes.sh
wget -o ${DBNITRO}/bin/svc-show-config.sh                                https://raw.githubusercontent.com/freddenis/oracle-scripts/master/svc-show-config.sh
wget -o ${DBNITRO}/bin/yal.sh                                            https://raw.githubusercontent.com/freddenis/oracle-scripts/master/yal.sh
wget -o ${DBNITRO}/sql/locks.sql                                         https://raw.githubusercontent.com/freddenis/oracle-scripts/master/locks.sql
wget -o ${DBNITRO}/sql/pidsid.sql                                        https://raw.githubusercontent.com/freddenis/oracle-scripts/master/pidsid.sql
wget -o ${DBNITRO}/sql/sidpid.sql                                        https://raw.githubusercontent.com/freddenis/oracle-scripts/master/sidpid.sql
#
chmod a+x ${DBNITRO}/bin/OracleMenu.sh
chmod g+w ${DBNITRO}/bin/OracleMenu.sh
chmod 775 ${DBNITRO}/bin/OracleMenu.sh
#
chmod a+x ${DBNITRO}/bin/*.sh
chmod a+x ${DBNITRO}/bin/oraenv++
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
wget -O ${DBNITRO}/bin/purgeLogs         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/purgeLogs
wget -O /etc/cron.daily/purgeLogs.sh     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/purgeLogs.sh
#
chmod a+x ${DBNITRO}/bin/purgeLogs
chmod a+x /etc/cron.daily/purgeLogs.sh
#
chmod -R 775 ${DBNITRO}/bin/purgeLogs
chmod -R 775 /etc/cron.daily/purgeLogs.sh
#
chown -R oracle.oinstall ${DBNITRO}/bin/purgeLogs
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
echo " -- IT WILL SHOW YOU ALL OPTIONS YOU CAN USE OR TYPE: HELP --"
alias db='. ${DBNITRO}/bin/OracleMenu.sh'
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
echo " -- IT WILL SHOW YOU ALL OPTIONS YOU CAN USE OR TYPE: HELP --"
alias db='. ${DBNITRO}/bin/OracleMenu.sh'
#
umask 0022
EOF
else
  echo " -- Your Environment does not have Grid User --"
  break
fi
}
#
function SetUpOldOracle() {
cat >> /home/oracle/.bash_profile <<EOF
-- TO SELECT ANY ORACLE PRODUCT, JUST TYPE: db --            
-- IT WILL SHOW YOU ALL OPTIONS YOU CAN USE OR TYPE: HELP --
alias db='. ${DBNITRO}/bin/OracleMenu.sh'
umask 0022
EOF
}
#
function MainMenu() {
PS3="Select the Option: "
select OPT in INSTALL UPDATE OLD_ENV REMOVE HELP QUIT; do
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
  SetUpOldOracle
elif [[ "${OPT}" == "REMOVE" ]]; then
  echo " -- Remove DBNITRO Environment --"
  RemoveFolder
elif [[ "${OPT}" == "HELP" ]]; then
  echo " -- DBNITRO SETUP HELP --"
  HELP
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
