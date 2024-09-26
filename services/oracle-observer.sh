#!/bin/sh
Author="Andre Augusto Ribas"
SoftwareVersion="1.0.1"
DateCreation="23/07/2024"
DateModification="23/07/2024"
EMAIL_1="dba.ribas@gmail.com"
EMAIL_2="andre.ribas@icloud.com"
WEBSITE="http://dbnitro.net"
#
export LOG=/var/log/oracle_fsfoi_???_init.log
export LOCK=/var/lock/subsys/oracle_fsfoi_???.lock
export DATE=$(date +%d\/%m\/%Y\ %H\:%M)
export ORACLE_VERSION="19.3.0.1"
export ORACLE_BASE="/u01/app/oracle"
export ORACLE_HOME="${ORACLE_BASE}/product/${ORACLE_VERSION}/db_EE_01"

#
if [[ $1 == "" ]]; then
  echo "Usage: oracle {start|stop|restart|status}"
  exit 1
elif [[ $1 == "start" ]]; then

  dgmgrl -silent /@${SID} "start observer ${HOST} File is ${DAT} LogFile is ${LOG}" &

  echo "$(date +%Y-%m-%d_%H\:%M) - Oracle Dataguard Observer Start Successfully."
  echo "$(date +%Y-%m-%d_%H\:%M) - Oracle Dataguard Observer Start Successfully." >> /var/log/oracle-observer.log
elif [[ $1 == "stop" ]]; then

  echo "$(date +%Y-%m-%d_%H\:%M) - Oracle Dataguard Observer Stop Successfully."
  echo "$(date +%Y-%m-%d_%H\:%M) - Oracle Dataguard Observer Stop Successfully." >> /var/log/oracle-observer.log
elif [[ $1 == "restart" ]]; then

  echo "$(date +%Y-%m-%d_%H\:%M) - Oracle Dataguard Observer Stop Successfully."
  echo "$(date +%Y-%m-%d_%H\:%M) - Oracle Dataguard Observer Stop Successfully." >> /var/log/oracle-observer.log
  #

  echo "$(date +%Y-%m-%d_%H\:%M) - Oracle Dataguard Observer Start Successfully."
  echo "$(date +%Y-%m-%d_%H\:%M) - Oracle Dataguard Observer Start Successfully." >> /var/log/oracle-observer.log
elif [[ $1 == "status" ]]; then

else
  echo "Usage: oracle {start|stop|restart|status}"
  exit 1
fi


















-------------------------------------------------------------------------------

export ORACLE_HOSTNAME="$(hostname)"
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/19.3.0.1/client_01
export TFA_HOME="${ORACLE_HOME}/suptools/tfa/release/tfa_home"
export OCK_HOME="${ORACLE_HOME}/suptools/orachk"
export OB="${ORACLE_BASE}"
export OH="${ORACLE_HOME}"
export DBS="${ORACLE_HOME}/dbs"
export TNS="${ORACLE_HOME}/network/admin"
export TFA="${TFA_HOME}"
export OCK="${OCK_HOME}"
export ORATOP="${ORACLE_HOME}/suptools/oratop"
export OPATCH="${ORACLE_HOME}/OPatch"
export WALLET=/opt/oracle/wallet/
export JAVA_HOME="${ORACLE_HOME}/jdk"
export LD_LIBRARY_PATH=/lib:/usr/lib:/usr/lib64:${ORACLE_HOME}/lib:${ORACLE_HOME}/perl/lib:${ORACLE_HOME}/hs/lib
export CLASSPATH=${ORACLE_HOME}/JRE:${ORACLE_HOME}/jlib:${ORACLE_HOME}/rdbms/jlib
export PATH=${PATH}:${ORACLE_HOME}/bin:${OPATCH}:${ORACLE_HOME}/perl/bin:${JAVA_HOME}/bin:${TFA_HOME}/bin:${OCK_HOME}/:${DBNITRO}/bin
export TNS_ADMIN="${ORACLE_HOME}/network/admin"
alias ob='cd ${ORACLE_BASE}'
alias oh='cd ${ORACLE_HOME}'
alias dbs='cd ${ORACLE_HOME}/dbs'
alias tns='cd ${ORACLE_HOME}/network/admin'
alias tfa='cd ${ORACLE_HOME}/suptools/tfa/release/tfa_home'
alias opl='${OPATCH}/opatch lspatches | sort'
alias sqlplus='rlwrap sqlplus'
alias s='rlwrap sqlplus / as sysdba @${DBNITRO}/sql/glogin.sql'
alias dgmgrl='rlwrap dgmgrl /'
alias d='rlwrap dgmgrl /'
alias adrci='rlwrap adrci'
alias ad='rlwrap adrci'
alias p='ps -ef | egrep pmon | egrep -v egrep'
alias t='rlwrap lsnrctl'
alias l='lsnrctl status'
export PS1=$'[ HOME ]|[ ${LOGNAME}@\h:$(pwd): ]$ '
umask 0022


-------------------------------------------------------------------------------


ln -s /opt/oracle/network/admin/tnsnames.ora /u01/app/oracle/product/19.3.0.1/client_01/network/admin/tnsnames.ora
ln -s /opt/oracle/network/admin/sqlnet.ora /u01/app/oracle/product/19.3.0.1/client_01/network/admin/sqlnet.ora

-------------------------------------------------------------------------------

vim /opt/oracle/network/admin/sqlnet.ora

WALLET_LOCATION = (SOURCE = (METHOD = FILE)(METHOD_DATA = (DIRECTORY = /opt/oracle/wallet/)))

SQLNET.WALLET_OVERRIDE = TRUE

-------------------------------------------------------------------------------

connect sys/Yh73uMb.23

Wallet Password: 77UlMyB.5D

cd /opt/oracle/wallet/

mkstore -wrl /opt/oracle/wallet/ -create
mkstore -wrl /opt/oracle/wallet/ -createEntry oracle.security.client.default_username SYS
mkstore -wrl /opt/oracle/wallet/ -createEntry oracle.security.client.default_password oracle

mkstore -wrl /opt/oracle/wallet/ -createCredential UMBP sys
mkstore -wrl /opt/oracle/wallet/ -createCredential UMBP_DGMGRL sys
mkstore -wrl /opt/oracle/wallet/ -createCredential UMBS sys
mkstore -wrl /opt/oracle/wallet/ -createCredential UMBS_DGMGRL sys

mkstore -wrl /opt/oracle/wallet/ -createCredential CVZ001P sys
mkstore -wrl /opt/oracle/wallet/ -createCredential CVZ001P_DGMGRL sys
mkstore -wrl /opt/oracle/wallet/ -createCredential CVZ001S sys
mkstore -wrl /opt/oracle/wallet/ -createCredential CVZ001S_DGMGRL sys

mkstore -wrl /opt/oracle/wallet/ -createCredential CVZ002P sys
mkstore -wrl /opt/oracle/wallet/ -createCredential CVZ002P_DGMGRL sys
mkstore -wrl /opt/oracle/wallet/ -createCredential CVZ002S sys
mkstore -wrl /opt/oracle/wallet/ -createCredential CVZ002S_DGMGRL sys

mkstore -wrl /opt/oracle/wallet/ -createCredential CVZ003P sys
mkstore -wrl /opt/oracle/wallet/ -createCredential CVZ003P_DGMGRL sys
mkstore -wrl /opt/oracle/wallet/ -createCredential CVZ003S sys
mkstore -wrl /opt/oracle/wallet/ -createCredential CVZ003S_DGMGRL sys

mkstore -wrl /opt/oracle/wallet/ -createCredential CVZ101T sys
mkstore -wrl /opt/oracle/wallet/ -createCredential CVZ101T_DGMGRL sys
mkstore -wrl /opt/oracle/wallet/ -createCredential CVZ101S sys
mkstore -wrl /opt/oracle/wallet/ -createCredential CVZ101S_DGMGRL sys

mkstore -wrl /opt/oracle/wallet/ -createCredential CVZ102T sys
mkstore -wrl /opt/oracle/wallet/ -createCredential CVZ102T_DGMGRL sys
mkstore -wrl /opt/oracle/wallet/ -createCredential CVZ102S sys
mkstore -wrl /opt/oracle/wallet/ -createCredential CVZ102S_DGMGRL sys

mkstore -wrl /opt/oracle/wallet/ -listCredential

mkstore -wrl /opt/oracle/wallet/ -list


dgmgrl /@UMBP
dgmgrl /@UMBS
dgmgrl /@CVZ001P
dgmgrl /@CVZ001S
dgmgrl /@CVZ002P
dgmgrl /@CVZ002S
dgmgrl /@CVZ003P
dgmgrl /@CVZ003S
dgmgrl /@CVZ101T
dgmgrl /@CVZ101S
dgmgrl /@CVZ102T
dgmgrl /@CVZ102S





scp /opt/oracle/wallet/* ???

-------------------------------------------------------------------------------
#

vim /opt/oracle/scripts/oracle_start_observer_umbp.sh

#!/bin/bash
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=${ORACLE_BASE}/product/19.3.0.1/client_01
export PATH=${PATH}:${ORACLE_HOME}/bin
export LD_LIBRARY_PATH=${ORACLE_HOME}/lib
export SID=UMBP
export LOG=/opt/oracle/scripts/oracle_start_observer_umbp.log
${ORACLE_HOME}/bin/dgmgrl -silent /@${SID} "start observer file="${LOG}""


chmod a+x /opt/oracle/scripts/oracle_start_observer_umbp.sh

-------------------------------------------------------------------------------

vim /opt/oracle/scripts/oracle_stop_observer_umbp.sh

#!/bin/bash
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=${ORACLE_BASE}/product/19.3.0.1/client_01
export PATH=${PATH}:${ORACLE_HOME}/bin
export LD_LIBRARY_PATH=${ORACLE_HOME}/lib
export SID=UMBP
${ORACLE_HOME}/bin/dgmgrl -silent /@${SID} "stop observer $(hostname)"


chmod a+x /opt/oracle/scripts/oracle_stop_observer_umbp.sh


-------------------------------------------------------------------------------

vim /etc/sysconfig/oracle

cat << EOF > /etc/sysconfig/oracle
ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=${ORACLE_BASE}/product/19.3.0.1/client_01
LD_LIBRARY_PATH=${ORACLE_HOME}/lib
TNS_ADMIN=/opt/oracle/network/admin
PATH=${PATH}:${ORACLE_HOME}/bin
EOF

chown oracle.oinstall /etc/sysconfig/oracle

-------------------------------------------------------------------------------


vim /etc/systemd/system/oracle-fsfo-umbp.service

[Unit]
Description=Service for Oracle Fast_Start Failover Observer Startup UMBP
After=network.target

[Service]
EnvironmentFile=/opt/oracle/scripts/env.UMBP
Type=forking
Restart=no

Type=simple

User=oracle
Group=oinstall

RemainAfterExit=YES
Restart=on-abort
RestartSec=5

ExecStart=/bin/bash -c '$ORACLE_HOME/bin/dgmgrl -silent /@$SID "start observer $(hostname) LogFile is /opt/oracle/logs/oracle_fsfo_umbp.log" & '
ExecStop=/bin/bash -c '$ORACLE_HOME/bin/dgmgrl -silent /@$SID "stop observer $(hostname)"'

[Install]
WantedBy=multi-user.target




systemctl daemon-reload
systemctl reset-failed oracle-fsfo-umbp.service
systemctl enable oracle-fsfo-umbp.service
systemctl start oracle-fsfo-umbp.service
systemctl status -l oracle-fsfo-umbp.service
systemctl list-units --type service





[root@mth-mlg-007 ~]# cat /etc/systemd/system/oracle-rdbms.service
##################################################################################
#
# Nadeem Siddique - UMB AG, Switzerland 2021.
#
# Invoking Oracle scripts to start/shutdown Instances defined in /etc/oratab
# and starts Listener

[Unit]
Description=Oracle Database(s) and Listener
After=network.target

[Service]
EnvironmentFile=/etc/sysconfig/env.oracledb_19c
Type=forking
Restart=no

User=oracle
Group=oinstall
ExecStart=/oracle/local/dba/bin/oracle_start_stop.ksh start
ExecStop=/oracle/local/dba/bin/oracle_start_stop.ksh stop

[Install]
WantedBy=multi-user.target
[root@mth-mlg-007 ~]#





[root@mth-mlg-007 ~]# cat /etc/sysconfig/env.oracledb_19c
ORACLE_BASE=/oracle
ORACLE_HOME=/oracle/product/19.0.0/dbhome_2/
TNS_ADMIN=/oracle/network/admin
[root@mth-mlg-007 ~]#




# -------------------------------------------------------------------------------------
# Oracle Dataguard Observer
# -------------------------------------------------------------------------------------
#
# Create and modify the File of the Linux Service
#

touch /opt/oracle/scripts/oracle_fsfo_umbp
chmod a+x /opt/oracle/scripts/oracle_fsfo_umbp
chown oracle.oinstall /opt/oracle/scripts/oracle_fsfo_umbp
vim /opt/oracle/scripts/oracle_fsfo_umbp

#
# -------------------------------------------------------------------------------------
#
#!/bin/bash
# chkconfig: 2345 95 25
# description: Oracle Dataguard FSFO Service UMBP
# processname: oracle
#./etc/rc.d/init.d/functions
#
SID=UMBP
HOST=$(hostname)
LOGS=/opt/oracle/logs
LOG=${LOGS}/oracle_fsfo_${SID}.log
DAT=${LOGS}/oracle_fsfo_${SID}.dat
LOCK=${LOGS}/oracle_fsfo_${SID}.lock
DATE=$(date +%d\/%m\/%Y\ %H\:%M)
ORACLE_VERSION="19.3.0.1"
ORACLE_BASE="/u01/app/oracle"
ORACLE_HOME="${ORACLE_BASE}/product/${ORACLE_VERSION}/client_01"
#
if [[ ! -f ${LOG} ]]; then
  touch ${LOG}
fi
#
if [[ ! -f ${DAT} ]]; then
  touch ${DAT}
fi
#
if [[ ! -f ${LOCK} ]]; then
  touch ${LOCK}
fi
#
StartObserver() {
  dgmgrl -silent /@${SID} "start observer ${HOST} File is ${DAT} LogFile is ${LOG}" &
}
#
StopObserver() {
  dgmgrl -silent /@${SID} "stop observer ${HOST}" &
}
#
case "$1" in
start) >> ${LOG}
  echo ">-------------------------------------------------------------------<"
  echo " -- Startup of Oracle Dataguard Observer: ${HOST} | ${SID} --"
  echo ">-------------------------------------------------------------------<"
  StartObserver
  ;;
stop) >> ${LOG}
  echo ">-------------------------------------------------------------------<"
  echo " -- Shutdown of Oracle Dataguard Observer: ${HOST} | ${SID} --"
  echo ">-------------------------------------------------------------------<"
  StopObserver
  rm -f ${LOCK}
  ;;
restart) >> ${LOG}
  echo ">-------------------------------------------------------------------<"
  echo " -- Restart of Oracle Dataguard Observer: ${HOST} | ${SID} --"
  echo ">-------------------------------------------------------------------<"
  StopObserver
  rm -f ${LOCK}
  sleep 5
  StartObserver
  ;;
*)
  echo "Usage: oracle_fsfo_${SID} {start|stop|restart}"
  exit 1
esac
exit 0

#
# -------------------------------------------------------------------------------------
# Add the file on the Linux
#

chkconfig --add oracle_fsfo_umbp
chkconfig oracle_fsfo_umbp on

#
# -------------------------------------------------------------------------------------
# Execute the file services
#

/etc/init.d/oracle_fsfo_umbp start
/etc/init.d/oracle_fsfo_umbp stop
/etc/init.d/oracle_fsfo_umbp restart






ln -s /opt/oracle/scripts/oracle_fsfo_UMBP /etc/init.d/oracle_fsfo_umbp
ln -s /opt/oracle/scripts/oracle_fsfo_CVZ001P /etc/init.d/oracle_fsfo_cvz001p
ln -s /opt/oracle/scripts/oracle_fsfo_CVZ002P /etc/init.d/oracle_fsfo_cvz002p
ln -s /opt/oracle/scripts/oracle_fsfo_CVZ003P /etc/init.d/oracle_fsfo_cvz003p
ln -s /opt/oracle/scripts/oracle_fsfo_CVZ101S /etc/init.d/oracle_fsfo_cvz101s
ln -s /opt/oracle/scripts/oracle_fsfo_CVZ102S /etc/init.d/oracle_fsfo_cvz102s



chkconfig --add oracle_fsfo_umbp
chkconfig --add oracle_fsfo_cvz001p
chkconfig --add oracle_fsfo_cvz002p
chkconfig --add oracle_fsfo_cvz003p
chkconfig --add oracle_fsfo_cvz101s
chkconfig --add oracle_fsfo_cvz102s


chkconfig oracle_fsfo_umbp on
chkconfig oracle_fsfo_cvz001p on
chkconfig oracle_fsfo_cvz002p on
chkconfig oracle_fsfo_cvz003p on
chkconfig oracle_fsfo_cvz101s on
chkconfig oracle_fsfo_cvz102s on









ln -s /opt/oracle/scripts/oracle_fsfo_UMBS /etc/init.d/oracle_fsfo_umbs
ln -s /opt/oracle/scripts/oracle_fsfo_CVZ001S /etc/init.d/oracle_fsfo_cvz001s
ln -s /opt/oracle/scripts/oracle_fsfo_CVZ002S /etc/init.d/oracle_fsfo_cvz002s
ln -s /opt/oracle/scripts/oracle_fsfo_CVZ003S /etc/init.d/oracle_fsfo_cvz003s
ln -s /opt/oracle/scripts/oracle_fsfo_CVZ101T /etc/init.d/oracle_fsfo_cvz101t
ln -s /opt/oracle/scripts/oracle_fsfo_CVZ102T /etc/init.d/oracle_fsfo_cvz102t





chkconfig --add oracle_fsfo_umbs
chkconfig --add oracle_fsfo_cvz001s
chkconfig --add oracle_fsfo_cvz002s
chkconfig --add oracle_fsfo_cvz003s
chkconfig --add oracle_fsfo_cvz101t
chkconfig --add oracle_fsfo_cvz102t


chkconfig oracle_fsfo_umbs on
chkconfig oracle_fsfo_cvz001s on
chkconfig oracle_fsfo_cvz002s on
chkconfig oracle_fsfo_cvz003s on
chkconfig oracle_fsfo_cvz101t on
chkconfig oracle_fsfo_cvz102t on







