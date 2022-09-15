#!/bin/sh
Author="Andre Augusto Ribas"
SoftwareVersion="1.0.1"
DateCreation="13/04/2021"
DateModification="13/04/2021"
EMAIL_1="dba.ribas@gmail.com"
EMAIL_2="andre.ribas@icloud.com"
WEBSITE="http://dbnitro.net"
#
#--------------------------------------------------------------------------------------------
# GoldenGate Monitoring 
#--------------------------------------------------------------------------------------------
#
function SepLine() 
{
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -  
}
#
# Gera Info 1
#
function GeraInfo1()
{
${OGG_HOME}/ggsci << EOF > ${OGG_HOME}/gerainfoacs.txt
info all
exit
EOF
}
#
# Gera Info 2
#
function GeraInfo2()
{
${OGG_HOME}/ggsci << EOF > ${OGG_HOME}/gerainfoacs.txt
info *
exit
EOF
}
#
while true
clear
do
#
SepLine
#
echo "INSTANCE: ${ORACLE_SID} | DATE: $(date)"
#
DATABKP=$(date +%H:%M)
#
SepLine
#
echo "LASTS CHECKPOINTS"
#
SepLine
#
GeraInfo2
#
awk -v DTHORA=${DATABKP} '
{ 
  if ( $1 == "REPLICAT" ) 
    printf( "%s", $2 " ---> ")
  else 
  if ( $3 == "RBA" )
    if (substr($2,1,5) == DTHORA) {system("tput sgr0 ~/"); print substr($2,1,8)}
    else if ( substr(DTHORA,4,5) - substr($2,4,5) <0 ) {system("tput bold ~/"); print "LAG ---> (" DTHORA " - " substr($2,1,5)") = " substr(DTHORA,1,2) - substr($2,1,2)":" substr($2,4,5) - substr(DTHORA,4,5)}
    else if ( $3 == "RBA" ) {system("tput bold ~/"); print "LAG ---> (" DTHORA " - " substr($2,1,5)") = " substr(DTHORA,1,2)-substr($2,1,2)":" substr(DTHORA,4,5) - substr($2,4,5)}
}' ${OGG_HOME}/gerainfoacs.txt
#
SepLine
#
echo "PROCESS     STATUS      NAME        LAG           CHECKPOINT"
#
SepLine
#
GeraInfo1
#
awk '
{
  if      ( $5 >  "00:05:00" && $2 == "RUNNING" ) {system("tput bold ~/"); system("tput setaf 3 ~/"); print $0 "<--- CHKPOINT!"; system("tput sgr0 ~/");}
  else if ( $4 >= "00:05:00" && $2 == "RUNNING" ) {system("tput bold ~/"); system("tput setaf 3 ~/"); print $0 "<--- LAG HIGH!"; system("tput sgr0 ~/");}
  else if ( $4 <  "00:05:00" && $2 == "RUNNING" ) {system("tput setaf 9 ~/"); print $0; system("tput sgr0 ~/");}
  else if ( $2 == "ABENDED" ) {system("tput bold ~/") system("tput setaf 1 ~/"); print $0 "<--- " $2; system("tput sgr0 ~/")}
  else if ( $2 == "STOPPED" ) {system("tput bold ~/") system("tput setaf 1 ~/"); print $0 "<--- " $2; system("tput sgr0 ~/")}
  else system("tput sgr0 ~/");
}' ${OGG_HOME}/gerainfoacs.txt
#
SepLine
#
echo "FREE AND USED SPACE ON FILESYSTEM OF GOLDENGATE STAGE"
#
SepLine
#
echo "STAGE: $(df -h /u02 | grep -v -i "filesystem" | awk '{ print $6 }') | \
TOTAL: $(df -h /u02 | grep -v -i "filesystem" | awk '{ print $2 }') | \
USED: $(df -h /u02 | grep -v -i "filesystem" | awk '{ print $3, $5 }') | \
FREE: $(df -h /u02 | grep -v -i "filesystem" | awk '{ print $4 }')"
#
SepLine
#
sleep 15
#
done