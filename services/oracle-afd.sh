#!/bin/sh
Author="Andre Augusto Ribas"
SoftwareVersion="1.0.1"
DateCreation="11/07/2024"
DateModification="11/07/2024"
EMAIL_1="dba.ribas@gmail.com"
EMAIL_2="andre.ribas@icloud.com"
WEBSITE="http://dbnitro.net"
#
if [[ $1 == "" ]]; then
  echo "Usage: oracle {start|stop|restart|status}"
  exit 1
elif [[ $1 == "start" ]]; then
  /u01/app/19.3.0.1/grid/bin/afdload start
  lsmod | grep oracleafd
  echo "$(date +%Y-%m-%d_%H\:%M) - Oracle AFD Load Started Successfully."
  echo "$(date +%Y-%m-%d_%H\:%M) - Oracle AFD Load Started Successfully." >> /var/log/afdload.log
elif [[ $1 == "stop" ]]; then
  /u01/app/19.3.0.1/grid/bin/afdload stop
  lsmod | grep oracleafd
  echo "$(date +%Y-%m-%d_%H\:%M) - Oracle AFD Load Stopped Successfully."
  echo "$(date +%Y-%m-%d_%H\:%M) - Oracle AFD Load Stopped Successfully." >> /var/log/afdload.log
elif [[ $1 == "restart" ]]; then
  /u01/app/19.3.0.1/grid/bin/afdload stop
  lsmod | grep oracleafd
  echo "$(date +%Y-%m-%d_%H\:%M) - Oracle AFD Load Stopped Successfully."
  echo "$(date +%Y-%m-%d_%H\:%M) - Oracle AFD Load Stopped Successfully." >> /var/log/afdload.log
  #
  /u01/app/19.3.0.1/grid/bin/afdload start
  lsmod | grep oracleafd
  echo "$(date +%Y-%m-%d_%H\:%M) - Oracle AFD Load Started Successfully."
  echo "$(date +%Y-%m-%d_%H\:%M) - Oracle AFD Load Started Successfully." >> /var/log/afdload.log
elif [[ $1 == "status" ]]; then
  lsmod | grep oracleafd
else
  echo "Usage: oracle {start|stop|restart|status}"
  exit 1
fi