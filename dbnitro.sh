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
mkdir -p /opt/dbnitro/
chmod -R 775 /opt/dbnitro/
chown -R oracle.oinstall /opt/dbnitro/
cd /opt/dbnitro/
#
wget -O /opt/dbnitro/.OracleMenu.sh https://raw.githubusercontent.com/dbaribas/dbnitro/main/OracleMenu.sh
wget -O /opt/dbnitro/.Oracle_ASM_Functions https://raw.githubusercontent.com/dbaribas/dbnitro/main/Oracle_ASM_Functions
wget -O /opt/dbnitro/.Oracle_DBA_Functions https://raw.githubusercontent.com/dbaribas/dbnitro/main/Oracle_DBA_Functions
#
chown oracle.oinstall /opt/dbnitro/.OracleMenu.sh
chown oracle.oinstall /opt/dbnitro/.Oracle_ASM_Functions
chown oracle.oinstall /opt/dbnitro/.Oracle_DBA_Functions
#
chmod a+x /opt/dbnitro/.OracleMenu.sh
chmod g+w /opt/dbnitro/.OracleMenu.sh
chmod 775 /opt/dbnitro/.OracleMenu.sh
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
chmod a+x /opt/dbnitro/asmdu.sh
chmod a+x /opt/dbnitro/cell-status.sh
chmod a+x /opt/dbnitro/change-password.sh
chmod a+x /opt/dbnitro/exa-howsmart.sh
chmod a+x /opt/dbnitro/exa-iblinkinfo.sh
chmod a+x /opt/dbnitro/exa-racklayout.sh
chmod a+x /opt/dbnitro/exa-versions.sh
chmod a+x /opt/dbnitro/gg-afterstop.sh
chmod a+x /opt/dbnitro/gg-info.sh
chmod a+x /opt/dbnitro/gg-start.sh
chmod a+x /opt/dbnitro/gg-status.sh
chmod a+x /opt/dbnitro/gg-stop.sh
chmod a+x /opt/dbnitro/list-ohpatches.sh
chmod a+x /opt/dbnitro/locks.sql
chmod a+x /opt/dbnitro/lspatches.sh
chmod a+x /opt/dbnitro/nfs-status.sh
chmod a+x /opt/dbnitro/oci-check-backups.sh
chmod a+x /opt/dbnitro/oraenv++
chmod a+x /opt/dbnitro/pidsid.sql
chmod a+x /opt/dbnitro/rac-mon.sh
chmod a+x /opt/dbnitro/rac-on_all_db.sh
chmod a+x /opt/dbnitro/rac-status-rh6.sh
chmod a+x /opt/dbnitro/rac-status.sh
chmod a+x /opt/dbnitro/rac-status_suresh.sh
chmod a+x /opt/dbnitro/rman-backup.sh
chmod a+x /opt/dbnitro/sidpid.sql
chmod a+x /opt/dbnitro/svc-set-failback-yes.sh
chmod a+x /opt/dbnitro/svc-show-config.sh
chmod a+x /opt/dbnitro/yal.sh
#
chown oracle.oinstall /opt/dbnitro/asmdu.sh
chown oracle.oinstall /opt/dbnitro/cell-status.sh
chown oracle.oinstall /opt/dbnitro/change-password.sh
chown oracle.oinstall /opt/dbnitro/exa-howsmart.sh
chown oracle.oinstall /opt/dbnitro/exa-iblinkinfo.sh
chown oracle.oinstall /opt/dbnitro/exa-racklayout.sh
chown oracle.oinstall /opt/dbnitro/exa-versions.sh
chown oracle.oinstall /opt/dbnitro/gg-afterstop.sh
chown oracle.oinstall /opt/dbnitro/gg-info.sh
chown oracle.oinstall /opt/dbnitro/gg-start.sh
chown oracle.oinstall /opt/dbnitro/gg-status.sh
chown oracle.oinstall /opt/dbnitro/gg-stop.sh
chown oracle.oinstall /opt/dbnitro/list-ohpatches.sh
chown oracle.oinstall /opt/dbnitro/locks.sql
chown oracle.oinstall /opt/dbnitro/lspatches.sh
chown oracle.oinstall /opt/dbnitro/nfs-status.sh
chown oracle.oinstall /opt/dbnitro/oci-check-backups.sh
chown oracle.oinstall /opt/dbnitro/oraenv++
chown oracle.oinstall /opt/dbnitro/pidsid.sql
chown oracle.oinstall /opt/dbnitro/rac-mon.sh
chown oracle.oinstall /opt/dbnitro/rac-on_all_db.sh
chown oracle.oinstall /opt/dbnitro/rac-status-rh6.sh
chown oracle.oinstall /opt/dbnitro/rac-status.sh
chown oracle.oinstall /opt/dbnitro/rac-status_suresh.sh
chown oracle.oinstall /opt/dbnitro/rman-backup.sh
chown oracle.oinstall /opt/dbnitro/sidpid.sql
chown oracle.oinstall /opt/dbnitro/svc-set-failback-yes.sh
chown oracle.oinstall /opt/dbnitro/svc-show-config.sh
chown oracle.oinstall /opt/dbnitro/yal.sh
#
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
# THE SCRIPT FINISHES HERE
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
#
