#!/bin/sh
#
Author="Andre Augusto Ribas"
SoftwareVersion="1.0.9"
DateCreation="22/06/2022"
DateModification="29/09/2023"
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
if [[ $(which unzip | wc -l | awk '{ print $1 }') == 0 ]]; then
  echo " -- You need to install unzip app --"
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
SetUpDBNITRO() {
echo "Downloading DBNITRO Files"
cd ${FOLDER}/
wget -O /opt/DBNitro.zip https://github.com/dbaribas/dbnitro.net/archive/refs/heads/main.zip
unzip /opt/DBNitro.zip
mv /opt/dbnitro.net-main /opt/dbnitro
rm -f /opt/DBNitro.zip
#
chmod a+x ${DBNITRO}/bin/OracleMenu.sh
chmod g+w ${DBNITRO}/bin/OracleMenu.sh
chmod 775 ${DBNITRO}/bin/OracleMenu.sh
#
chmod a+x ${DBNITRO}/bin/OracleList.sh
chmod g+w ${DBNITRO}/bin/OracleList.sh
chmod 775 ${DBNITRO}/bin/OracleList.sh
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
mv ${DBNITRO}/bin/purgeLogs.sh /etc/cron.daily/purgeLogs.sh
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
# ROOT Crontab
# Purge Logs GI
# 00 20 * * * /opt/purgelogs/purgelogs.bin cleanup --orcl 30 --aud --lsnr --automigrate

# Purge Logs DB
# 00 21 * * * /opt/purgelogs/purgelogs.bin cleanup --days 30 --aud --lsnr --automigrate
}
#
#
# ------------------------------------------------------------------------
# Setup PurgLogs from Oracle Products (ONLY WITH GRID INFRASTRUCTURE)
#
SetUpPURGETFA() {
echo "Installing PURGE TFA Scripts"
cd ${DBNITRO}/
mv ${DBNITRO}/bin/purgeTFA.sh /etc/cron.daily/purgeTFA.sh
#
chmod a+x /etc/cron.daily/purgeTFA.sh
#
chmod -R 775 /etc/cron.daily/purgeTFA.sh
#
chown -R oracle.oinstall /etc/cron.daily/purgeTFA.sh
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
alias list='${DBNITRO}/bin/OracleList.sh'
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
alias list='${DBNITRO}/bin/OracleList.sh'
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
alias list'${DBNITRO}/bin/OracleList.sh'
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
  SetUpGrid
  SetUpOracle
  SetUpDBNITRO
  ### SetUpPURGELOGS
  ### SetUpPURGETFA
  SetupLogonBanner
  echo " -- Press ENTER to continue --"
  read
  LastOption="${OPT}"
  continue
elif [[ "${OPT}" == "UPDATE" ]]; then
  echo " -- Update DBNITRO Environment --"
  RemoveFolder
  SetUpGrid
  SetUpOracle
  SetUpDBNITRO
  ### SetUpPURGELOGS
  ### SetUpPURGETFA
  SetupLogonBanner
  echo " -- Press ENTER to continue --"
  read
  LastOption="${OPT}"
  continue
elif [[ "${OPT}" == "OLD_ENV" ]]; then
  echo " -- Install DBNITRO Environment for OLD Servers --"
  SetUpDBNITRO
  ### SetUpPURGELOGS
  ### SetUpPURGETFA
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
