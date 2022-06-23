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
# ------------------------------------------------------------------------
# Creating and Installing the DBNITRO Components
#
FOLDER="/opt"
DBNITRO="${FOLDER}/dbnitro"
#
if [[ ! -d ${DBNITRO}/ ]]; then
  mkdir -p ${DBNITRO}/
  chmod -R 775 ${DBNITRO}/
  chown -R oracle.oinstall ${DBNITRO}/
fi
cd ${DBNITRO}/
#
wget -O ${DBNITRO}/.OracleMenu.sh https://raw.githubusercontent.com/dbaribas/dbnitro/main/OracleMenu.sh
wget -O ${DBNITRO}/.Oracle_ASM_Functions https://raw.githubusercontent.com/dbaribas/dbnitro/main/Oracle_ASM_Functions
wget -O ${DBNITRO}/.Oracle_DBA_Functions https://raw.githubusercontent.com/dbaribas/dbnitro/main/Oracle_DBA_Functions
#
chown oracle.oinstall ${DBNITRO}/.OracleMenu.sh
chown oracle.oinstall ${DBNITRO}/.Oracle_ASM_Functions
chown oracle.oinstall ${DBNITRO}/.Oracle_DBA_Functions
#
chmod a+x ${DBNITRO}/dbnitro/.OracleMenu.sh
chmod g+w ${DBNITRO}/dbnitro/.OracleMenu.sh
chmod 775 ${DBNITRO}/dbnitro/.OracleMenu.sh
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
chown -R oracle.oinstall ${DBNITRO}/
#
# ------------------------------------------------------------------------
# Add the Content on Grid Profile
#
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
#
# ------------------------------------------------------------------------
# Add the Content on Oracle Profile
#
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
#
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
# THE SCRIPT FINISHES HERE
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
#
