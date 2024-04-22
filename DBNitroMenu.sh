#!/bin/sh
#
Author="Andre Augusto Ribas"
SoftwareVersion="1.0.9"
DateCreation="22/06/2022"
DateModification="26/01/2024"
EMAIL_1="dba.ribas@gmail.com"
EMAIL_2="andre.ribas@icloud.com"
WEBSITE="http://dbnitro.net"
#
# ------------------------------------------------------------------------
# Verify if you are ROOT or not
#
if [[ "$(whoami)" != "root" ]]; then
  echo "#############################################"
  echo " -- YOU ARE NOT ROOT, YOU MUST BE ROOT TO EXECUTE THIS SCRIPT --"
  echo ""
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
  echo "#############################################"
  echo " -- You need to install wget app --"
  echo ""
  exit 1
fi
#
if [[ $(which unzip | wc -l | awk '{ print $1 }') == 0 ]]; then
  echo "#############################################"
  echo " -- You need to install unzip app --"
  echo ""
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
echo "#############################################"
echo " -- Removing DBNITRO Folder --"
echo ""
if [[ -d ${DBNITRO}/ ]]; then
  mv ${DBNITRO}/ /tmp/${DBNITRO}_$(date +%Y%m%d)
fi
}
#
SetUpDBNITRO() {
echo "#############################################"
echo " -- Downloading DBNITRO Files --"
echo ""
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
# Add the Content on Grid Profile
#
SetUpGrid() {
echo "#############################################"
echo " -- Seting UP GRID User --"
echo ""
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
echo "#############################################"
echo " -- Seting UP ORACLE User --"
echo ""
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
echo "#############################################"
echo " -- Seting UP ORACLE User on old environment --"
echo ""
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
echo "#############################################"
echo " -- Your Last Option Was: ${LastOption}"
echo ""
PS3="Select the Option: "
select OPT in INSTALL UPDATE OLD_ENV REMOVE HELP QUIT; do
if [[ "${OPT}" == "QUIT" ]]; then
  echo "#############################################"
  echo " -- Exit Menu --"
  echo ""
  exit 1
elif [[ "${OPT}" == "INSTALL" ]]; then
  echo "#############################################"
  echo " -- Install DBNITRO Environment --"
  echo ""
  SetUpGrid
  SetUpOracle
  SetUpDBNITRO
  SetupLogonBanner
  echo "#############################################"
  echo " -- Press ENTER to continue --"
  echo ""
  read
  LastOption="${OPT}"
  continue
elif [[ "${OPT}" == "UPDATE" ]]; then
  echo "#############################################"
  echo " -- Update DBNITRO Environment --"
  echo ""
  RemoveFolder
  SetUpGrid
  SetUpOracle
  SetUpDBNITRO
  SetupLogonBanner
  echo "#############################################"
  echo " -- Press ENTER to continue --"
  echo ""
  read
  LastOption="${OPT}"
  continue
elif [[ "${OPT}" == "OLD_ENV" ]]; then
  echo "#############################################"
  echo " -- Install DBNITRO Environment for OLD Servers --"
  echo ""
  SetUpDBNITRO
  SetUpOldOracle
  SetupLogonBanner
  echo "#############################################"
  echo " -- Press ENTER to continue --"
  echo ""
  read
  LastOption="${OPT}"
  continue
elif [[ "${OPT}" == "REMOVE" ]]; then
  echo "#############################################"
  echo " -- Remove DBNITRO Environment --"
  echo ""
  RemoveFolder
  echo "#############################################"
  echo " -- Press ENTER to continue --"
  echo ""
  read
  LastOption="${OPT}"
  continue
elif [[ "${OPT}" == "HELP" ]]; then
  echo "#############################################"
  echo " -- DBNITRO SETUP HELP --"
  echo ""
  HELP
  echo "#############################################"
  echo " -- Press ENTER to continue --"
  echo ""
  read
  continue
else
  echo "#############################################"
  echo " -- Invalid Option --"
  echo ""
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
