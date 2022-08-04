#!/bin/sh
#
Author="Andre Augusto Ribas"
SoftwareVersion="1.0.3"
DateCreation="28/09/2021"
DateModification="30/09/2021"
EMAIL_1="dba.ribas@gmail.com"
EMAIL_2="andre.ribas@icloud.com"
WEBSITE="http://dbnitro.net"
#
# Check the Log
#
LOG=/var/log/oracle_purge_logs.log
if [[ ! -f ${LOG} ]]; then
  touch ${LOG}
fi
echo "" > ${LOG}
#
# Execution of purgeLogs
#
/u00/Scripts/purgeLogs -automigrate
/u00/Scripts/purgeLogs -days 30
/u00/Scripts/purgeLogs -orcl 30
/u00/Scripts/purgeLogs -days 30 -aud -lsnr
/u00/Scripts/purgeLogs -orcl 30 -aud -lsnr
#
# Right the Log
#
DATE=$(date +%Y\/%m\/%d_%H\:%M)
echo "${DATE}: Successfully Done" > ${LOG}