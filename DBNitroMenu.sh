#!/bin/sh
#
Author="Andre Augusto Ribas"
SoftwareVersion="1.0.5"
DateCreation="22/06/2022"
DateModification="17/01/2023"
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
#
LastOption="NONE"
#
# ------------------------------------------------------------------------
# Setup of Logon Banner
SetupLogonBanner() {
cat > /etc/motd.d/dbnitro <<EOF
--------------------------------------------------------------------------------------------------------------------

 -- https://www.dbnitro.net
 -- https://github.com/dbaribas/dbnitro.net
 -- dba.ribas@gmail.com

 -- Welcome to the Oracle Database Server.
 -- This Server has 2 different users to manage the Oracle System:
 -- User Grid is responsible for the GRID Infrastructure, Listener, Network, Services, Diskgroups and so on.
 -- User Oracle is resposible for all RDBMS Systems and Database Instances.
 -- On both users, you just need to execute " db ", choose an option you what to work and done.

--------------------------------------------------------------------------------------------------------------------
EOF
}
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
# Help to use this script
#
HELP() {
echo -e "\
|#| INSTALL...: YOU CAN INSTALL THE DBNITRO SCRIPTS AND FUNCTIONS
|#| UPDATE....: YOU CAN UPDATE THE DBNITRO INSTALLATION
|#| OLD_ENV...: YOU CAN INSTALL AND ENABLE THE FUNCTIONALITIES IN AN OLD ENVIRONMENT
|#| REMOVE....: YOU CAN REMOVE THE DBNITRO INSTALLATION
|#| HELP......: YOU CAN CHECK THE OPTIONS"
}
#
# ------------------------------------------------------------------------
# Creating and Installing the DBNITRO Components
#
FOLDER="/opt"                       # ===> HERE YOU HAVE TO CONFIGURE THE PATH OF DBNITRO, WHERE IT WILL BE INSTALLED
DBNITRO="${FOLDER}/dbnitro"
#
RemoveFolder() {
echo "Removing DBNITRO Folder"
if [[ -d ${DBNITRO}/ ]]; then
  rm -rf ${DBNITRO}/
fi
}
#
CreateFolder() {
echo "Creating DBNITRO Folder"
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
SetUpDBNITRO() {
echo "Downloading DBNITRO Files"
cd ${DBNITRO}/
# ===> Here is the DBNITRO Files
wget -O ${DBNITRO}/bin/OracleMenu.sh                                     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/OracleMenu.sh
wget -O ${DBNITRO}/bin/Oracle_DBA_Check_Hugepages.sh                     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/Oracle_DBA_Check_Hugepages.sh
wget -O ${DBNITRO}/bin/Oracle_Golden_Gate_Monitor.sh                     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/Oracle_Golden_Gate_Monitor.sh
wget -O ${DBNITRO}/bin/Oracle_Check_Instance.pl                          https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/Oracle_Check_Instance.pl
wget -O ${DBNITRO}/bin/Oracle_DBA_Daily_Check.sh                         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/Oracle_DBA_Daily_Check.sh
wget -O ${DBNITRO}/sql/Oracle_SQL_DBA_Info.sql                           https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/Oracle_SQL_DBA_Info.sql
wget -O ${DBNITRO}/sql/Oracle_SQL_DBA_H_Check.sql                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/Oracle_SQL_DBA_H_Check.sql
wget -O ${DBNITRO}/sql/Oracle_SQL_Report_v.3.0.1.sql                     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/Oracle_SQL_Report_v.3.0.1.sql
wget -O ${DBNITRO}/sql/Oracle_SQL_Check_Hugepages.sql                    https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/Oracle_SQL_Check_Hugepages.sql
wget -O ${DBNITRO}/sql/Oracle_SQL_DBA_Options_Packs_Usage_Statistics.sql https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/Oracle_SQL_DBA_Options_Packs_Usage_Statistics.sql
wget -O ${DBNITRO}/functions/Oracle_ASM_Functions                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/functions/Oracle_ASM_Functions
wget -O ${DBNITRO}/functions/Oracle_DBA_Functions                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/functions/Oracle_DBA_Functions
wget -O ${DBNITRO}/functions/Oracle_RAC_Functions                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/functions/Oracle_RAC_Functions
wget -O ${DBNITRO}/functions/Oracle_EXA_Functions                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/functions/Oracle_EXA_Functions
wget -O ${DBNITRO}/functions/Oracle_ODG_Functions                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/functions/Oracle_ODG_Functions
wget -O ${DBNITRO}/functions/Oracle_OGG_Functions                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/functions/Oracle_OGG_Functions
wget -O ${DBNITRO}/functions/Oracle_STR_Functions                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/functions/Oracle_STR_Functions
wget -O ${DBNITRO}/functions/Oracle_PDB_Functions                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/functions/Oracle_PDB_Functions
wget -O ${DBNITRO}/functions/Oracle_ODA_Functions                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/functions/Oracle_ODA_Functions
wget -O ${DBNITRO}/functions/Oracle_WALL_Functions                       https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/functions/Oracle_WALL_Functions
wget -O ${DBNITRO}/functions/Oracle_RMAN_Functions                       https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/functions/Oracle_RMAN_Functions
# ===> Here is the Fred Denis Scripts
wget -O ${DBNITRO}/bin/asmdu.sh                                          https://raw.githubusercontent.com/freddenis/oracle-scripts/master/asmdu.sh
wget -O ${DBNITRO}/bin/cell-status.sh                                    https://raw.githubusercontent.com/freddenis/oracle-scripts/master/cell-status.sh
wget -O ${DBNITRO}/bin/change-password.sh                                https://raw.githubusercontent.com/freddenis/oracle-scripts/master/change-password.sh
wget -O ${DBNITRO}/bin/exa-howsmart.sh                                   https://raw.githubusercontent.com/freddenis/oracle-scripts/master/exa-howsmart.sh
wget -O ${DBNITRO}/bin/exa-iblinkinfo.sh                                 https://raw.githubusercontent.com/freddenis/oracle-scripts/master/exa-iblinkinfo.sh
wget -O ${DBNITRO}/bin/exa-racklayout.sh                                 https://raw.githubusercontent.com/freddenis/oracle-scripts/master/exa-racklayout.sh
wget -O ${DBNITRO}/bin/exa-versions.sh                                   https://raw.githubusercontent.com/freddenis/oracle-scripts/master/exa-versions.sh
wget -O ${DBNITRO}/bin/gg-afterstop.sh                                   https://raw.githubusercontent.com/freddenis/oracle-scripts/master/gg-afterstop.sh
wget -O ${DBNITRO}/bin/gg-info.sh                                        https://raw.githubusercontent.com/freddenis/oracle-scripts/master/gg-info.sh
wget -O ${DBNITRO}/bin/gg-start.sh                                       https://raw.githubusercontent.com/freddenis/oracle-scripts/master/gg-start.sh
wget -O ${DBNITRO}/bin/gg-status.sh                                      https://raw.githubusercontent.com/freddenis/oracle-scripts/master/gg-status.sh
wget -O ${DBNITRO}/bin/gg-stop.sh                                        https://raw.githubusercontent.com/freddenis/oracle-scripts/master/gg-stop.sh
wget -O ${DBNITRO}/bin/list-ohpatches.sh                                 https://raw.githubusercontent.com/freddenis/oracle-scripts/master/list-ohpatches.sh
wget -O ${DBNITRO}/bin/lspatches.sh                                      https://raw.githubusercontent.com/freddenis/oracle-scripts/master/lspatches.sh
wget -O ${DBNITRO}/bin/nfs-status.sh                                     https://raw.githubusercontent.com/freddenis/oracle-scripts/master/nfs-status.sh
wget -O ${DBNITRO}/bin/oci-check-backups.sh                              https://raw.githubusercontent.com/freddenis/oracle-scripts/master/oci-check-backups.sh
wget -O ${DBNITRO}/bin/oraenv++                                          https://raw.githubusercontent.com/freddenis/oracle-scripts/master/oraenv++
wget -O ${DBNITRO}/bin/rac-mon.sh                                        https://raw.githubusercontent.com/freddenis/oracle-scripts/master/rac-mon.sh
wget -O ${DBNITRO}/bin/rac-on_all_db.sh                                  https://raw.githubusercontent.com/freddenis/oracle-scripts/master/rac-on_all_db.sh
wget -O ${DBNITRO}/bin/rac-status-rh6.sh                                 https://raw.githubusercontent.com/freddenis/oracle-scripts/master/rac-status-rh6.sh
wget -O ${DBNITRO}/bin/rac-status.sh                                     https://raw.githubusercontent.com/freddenis/oracle-scripts/master/rac-status.sh
wget -O ${DBNITRO}/bin/rac-status_suresh.sh                              https://raw.githubusercontent.com/freddenis/oracle-scripts/master/rac-status_suresh.sh
wget -O ${DBNITRO}/bin/rman-backup.sh                                    https://raw.githubusercontent.com/freddenis/oracle-scripts/master/rman-backup.sh
wget -O ${DBNITRO}/bin/svc-set-failback-yes.sh                           https://raw.githubusercontent.com/freddenis/oracle-scripts/master/svc-set-failback-yes.sh
wget -O ${DBNITRO}/bin/svc-show-config.sh                                https://raw.githubusercontent.com/freddenis/oracle-scripts/master/svc-show-config.sh
wget -O ${DBNITRO}/bin/yal.sh                                            https://raw.githubusercontent.com/freddenis/oracle-scripts/master/yal.sh
wget -O ${DBNITRO}/sql/locks.sql                                         https://raw.githubusercontent.com/freddenis/oracle-scripts/master/locks.sql
wget -O ${DBNITRO}/sql/pidsid.sql                                        https://raw.githubusercontent.com/freddenis/oracle-scripts/master/pidsid.sql
wget -O ${DBNITRO}/sql/sidpid.sql                                        https://raw.githubusercontent.com/freddenis/oracle-scripts/master/sidpid.sql
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
SetUpPURGELOGS() {
echo "Installing PURGE LOGS Scripts"
cd ${DBNITRO}/
wget -O ${DBNITRO}/bin/purgeLogs         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/purgeLogs
wget -O /etc/cron.daily/purgeLogs.sh     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/purgeLogs.sh
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
SetUpGrid() {
echo "Seting UP GRID User"
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
alias db='. ${DBNITRO}/bin/OracleMenu.sh'
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
SetUpOracle() {
echo "Seting UP ORACLE User"
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
alias db='. ${DBNITRO}/bin/OracleMenu.sh'
umask 0022
EOF
else
  echo " -- Your Environment does not have Grid User --"
  break
fi
}
#
# ------------------------------------------------------------------------
# Setup Old Oracle Enviromnets
#
SetUpOldOracle() {
echo "Seting UP ORACLE User on old environment"
cat >> /home/oracle/.bash_profile <<EOF
alias db='. ${DBNITRO}/bin/OracleMenu.sh'
umask 0022
EOF
}
#
# ------------------------------------------------------------------------
# Main Menu
#
MainMenu() {
echo " -- Your Last Option Was: ${LastOption}"
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
  SetupLogonBanner
  echo " -- Press ENTER to continue --"
  read
  LastOption="${OPT}"
  continue
elif [[ "${OPT}" == "UPDATE" ]]; then
  echo " -- Update DBNITRO Environment --"
  RemoveFolder
  CreateFolder
  SetUpGrid
  SetUpOracle
  SetUpDBNITRO
  SetUpPURGELOGS
  SetupLogonBanner
  echo " -- Press ENTER to continue --"
  read
  LastOption="${OPT}"
  continue
elif [[ "${OPT}" == "OLD_ENV" ]]; then
  echo " -- Install DBNITRO Environment for OLD Servers --"
  CreateFolder
  SetUpDBNITRO
  SetUpPURGELOGS
  SetUpOldOracle
  SetupLogonBanner
  echo " -- Press ENTER to continue --"
  read
  LastOption="${OPT}"
  continue
elif [[ "${OPT}" == "REMOVE" ]]; then
  echo " -- Remove DBNITRO Environment --"
  RemoveFolder
  echo " -- Press ENTER to continue --"
  read
  LastOption="${OPT}"
  continue
elif [[ "${OPT}" == "HELP" ]]; then
  echo " -- DBNITRO SETUP HELP --"
  HELP
  echo " -- Press ENTER to continue --"
  read
  continue
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