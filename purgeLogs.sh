#!/bin/sh
#
Author="Andre Augusto Ribas"
SoftwareVersion="1.0.5"
DateCreation="28/09/2021"
DateModification="04/08/2022"
EMAIL_1="dba.ribas@gmail.com"
EMAIL_2="andre.ribas@icloud.com"
WEBSITE="http://dbnitro.net"
#
# ------------------------------------------------------------------------
# Creating and Installing the DBNITRO Components
#
FOLDER="/opt"
DBNITRO="${FOLDER}/dbnitro"
#
# ------------------------------------------------------------------------
# Check the Log
#
LOG=/var/log/oracle_purgelogs.log
if [[ ! -f ${LOG} ]]; then
  touch ${LOG}
fi
#
# ------------------------------------------------------------------------
# Starting Execution of purgeLogs
#
DATE=$(date +%Y\/%m\/%d_%H\:%M)
echo "${DATE}: Start Purging Logs" > ${LOG}
#
${DBNITRO}/bin/purgeLogs -automigrate
${DBNITRO}/bin/purgeLogs -days 30
${DBNITRO}/bin/purgeLogs -orcl 30
${DBNITRO}/bin/purgeLogs -days 30 -aud -lsnr
${DBNITRO}/bin/purgeLogs -orcl 30 -aud -lsnr
#
# ------------------------------------------------------------------------
# Finishing Execution of purgeLogs
#
DATE=$(date +%Y\/%m\/%d_%H\:%M)
echo "${DATE}: Stop Purging Logs" >> ${LOG}
#
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
# THE SCRIPT FINISHES HERE
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
#
