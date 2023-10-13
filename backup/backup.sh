#!/bin/sh
# "-------------------------------------------------------------------------------------------------------------"
#
Author="Andre Augusto Ribas"
SoftwareVersion="3.2.19"
DateCreation="25/01/2011"
DateModification="11/10/2023"
EMAIL_1="andre.ribas@icloud.com"
EMAIL_2="dba.ribas@gmail.com"
WEBSITE="http://dbnitro.net"
#
# "-------------------------------------------------------------------------------------------------------------"
# set -x                                                                         # Debug
# "-------------------------------------------------------------------------------------------------------------"
#
# Separate Line Function
#
function SepLine() {
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -  
}
#
function SetClear() {
  printf "\033c"
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Environment Variables
# "-------------------------------------------------------------------------------------------------------------"
#
StartTime=$(date +%s)
# "-------------------------------------------------------------------------------------------------------------"
#
if [[ "$(whoami)" == "root" ]]; then
  SetClear
  SepLine
  echo " -- YOUR USER IS ROOT, YOU CAN NOT USE THIS SCRIPT WITH ROOT USER --"
  echo " -- PLEASE USE OTHER USER TO ACCESS THIS SCRIPTS --"
  exit 1
fi
#
# "-------------------------------------------------------------------------------------------------------------"
#
OS=""
ORATAB=""
if [[ $(uname) == "SunOS" ]]; then
  OS="Solaris"
  ORATAB="/var/opt/oracle/oratab"
  TERM=xterm
elif [[ $(uname) == "AIX" ]]; then
  OS="AIX"
  ORATAB="/var/opt/oracle/oratab"
  TERM=xterm
elif [[ $(uname) == "Linux" ]]; then
  OS="Linux"
  ORATAB="/etc/oratab"
  TERM=xterm
elif [[ $(uname) == "Darwin" ]]; then
  OS="Darwin"
  ORATAB="/var/opt/oracle/oratab"
  TERM=xterm
else
  OS="Unknown"
  ORATAB="/var/opt/oracle/oratab"
  TERM=xterm
fi
#
# "-------------------------------------------------------------------------------------------------------------"
#
if [[ "${OS}" == "Unknown" ]]; then
  SetClear
  SepLine
  echo -e "$(date +%Y%m%d_%H\:%M\:%S): THE OPERATION SYSTEM: ${OS} IS NOT SUPPORTED ON THIS SCRIPT"
  SepLine
  exit 1
else
  SetClear
  SepLine
  echo -e "$(date +%Y%m%d_%H\:%M\:%S): THE OPERATION SYSTEM: ${OS} IS SUPPORTED ON THIS SCRIPT"
  SepLine
fi
#
# "-------------------------------------------------------------------------------------------------------------"
# ORAENV
# "-------------------------------------------------------------------------------------------------------------"
#
# ~.oraenv <<< $1
# /usr/local/bin/oraenv <<< $1
# /usr/local/bin/oraenv <<< $1 > /dev/null
#
ORAENV_ASK=NO
#
ORACLE_SID=$1
#
. /usr/local/bin/oraenv <<< ${ORACLE_SID} > /dev/null
#
DB_SID=$(grep -v '^\#' ${ORATAB} | grep -v '^$' | grep -i "^${ORACLE_SID}:" | cut -f3 | cut -f1 -d ':')
#
ORACLE_HOME=$(grep -v '^\#' ${ORATAB} | grep -v '^$' | grep -i "^${ORACLE_SID}:" | cut -f3 | cut -f2 -d ':')
#
PATH=${PATH}:${ORACLE_HOME}/bin
#
# "-------------------------------------------------------------------------------------------------------------"
# ORATAB & ORACLE_SID
# "-------------------------------------------------------------------------------------------------------------"
#
if [[ "${ORACLE_SID}" == "${DB_SID}" ]]; then
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): THE [ ORATAB and ORACLE_SID ] MATCH RIGH ON YOUR ENVIRONMENT"
  SepLine
else
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): THE [ ORATAB and ORACLE_SID ] DO NOT MATCH RIGH ON YOUR ENVIRONMENT"
  SepLine
  exit 1
fi
#
# "-------------------------------------------------------------------------------------------------------------"
# Help
# "-------------------------------------------------------------------------------------------------------------"
#
function Help() {
echo -e "\
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > Full or full ]
[ FULL ..................................... :: Report .................................... :: 1 of 8 ] OK
[ FULL ..................................... :: ExecFullCrosscheck ........................ :: 2 of 8 ] OK
[ FULL ..................................... :: ExecFull .................................. :: 3 of 8 ] OK
[ FULL ..................................... :: ExecCTRL .................................. :: 4 of 8 ] OK
[ FULL ..................................... :: ExecSPFile ................................ :: 5 of 8 ] OK
[ FULL ..................................... :: ValidFull ................................. :: 6 of 8 ] OK
[ FULL ..................................... :: ValidFullCheckLogical ..................... :: 7 of 8 ] OK
[ FULL ..................................... :: ListFull .................................. :: 8 of 8 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > FullClean or fullclean ]
[ FULL CLEAN ............................... :: ExecFullCrosscheck ........................ :: 1 of 3 ] OK
[ FULL CLEAN ............................... :: ExecFullClean ............................. :: 2 of 3 ] OK
[ FULL CLEAN ............................... :: ListFull .................................. :: 3 of 3 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > FullArchAll or fullarchall ]
[ FULL ARCHIVE ALL ......................... :: Report .................................... :: 1 of 8 ] OK
[ FULL ARCHIVE ALL ......................... :: ExecFullArchAllCrosscheck ................. :: 2 of 8 ] OK
[ FULL ARCHIVE ALL ......................... :: ExecFullArchAll ........................... :: 3 of 8 ] OK
[ FULL ARCHIVE ALL ......................... :: ExecCTRL .................................. :: 4 of 8 ] OK
[ FULL ARCHIVE ALL ......................... :: ExecSPFile ................................ :: 5 of 8 ] OK
[ FULL ARCHIVE ALL ......................... :: ValidFullArchAll .......................... :: 6 of 8 ] OK
[ FULL ARCHIVE ALL ......................... :: ValidFullArchAllCheckLogical .............. :: 7 of 8 ] OK
[ FULL ARCHIVE ALL ......................... :: ListFullArchAll ........................... :: 8 of 8 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > FullArchAllClean or fullarchallclean ]
[ FULL ARCHIVE ALL CLEAN ................... :: ExecFullArchAllCrosscheck ................. :: 1 of 3 ] OK
[ FULL ARCHIVE ALL CLEAN ................... :: ExecFullArchAllClean ...................... :: 2 of 3 ] OK
[ FULL ARCHIVE ALL CLEAN ................... :: ListFullArchAll ........................... :: 3 of 3 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > ArchAll or archall ]
[ ARCHIVE ALL .............................. :: Report .................................... :: 1 of 4 ] OK
[ ARCHIVE ALL .............................. :: ExecArchAllCrosscheck ..................... :: 2 of 4 ] OK
[ ARCHIVE ALL .............................. :: ExecArchAll ............................... :: 3 of 4 ] OK
[ ARCHIVE ALL .............................. :: ListArchAll ............................... :: 4 of 4 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > ArchAllClean or archallclean ]
[ ARCHIVE ALL CLEAN ........................ :: ExecArchAllClean .......................... :: 1 of 3 ] OK
[ ARCHIVE ALL CLEAN ........................ :: ExecArchAllCrosscheck ..................... :: 2 of 3 ] OK
[ ARCHIVE ALL CLEAN ........................ :: ListArchAll ............................... :: 3 of 3 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > IncLev0 or inclev0 ]
[ INCREMENTAL LEVEL 0 ...................... :: Report .................................... :: 1 of 8 ] OK
[ INCREMENTAL LEVEL 0 ...................... :: ExecIncLev0Crosscheck ..................... :: 2 of 8 ] OK
[ INCREMENTAL LEVEL 0 ...................... :: ExecIncLev0 ............................... :: 3 of 8 ] OK
[ INCREMENTAL LEVEL 0 ...................... :: ExecCTRL .................................. :: 4 of 8 ] OK
[ INCREMENTAL LEVEL 0 ...................... :: ExecSPFile ................................ :: 5 of 8 ] OK
[ INCREMENTAL LEVEL 0 ...................... :: ValidIncLev0 .............................. :: 6 of 8 ] OK
[ INCREMENTAL LEVEL 0 ...................... :: ValidIncLev0Logical ....................... :: 7 of 8 ] OK
[ INCREMENTAL LEVEL 0 ...................... :: ListIncLev0 ............................... :: 8 of 8 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > IncLev0Clean or inclev0clean ]
[ INCREMENTAL LEVEL 0 CLEAN ................ :: ExecIncLev0Crosscheck ..................... :: 1 of 3 ] OK
[ INCREMENTAL LEVEL 0 CLEAN ................ :: ExecIncLev0Clean .......................... :: 2 of 3 ] OK
[ INCREMENTAL LEVEL 0 CLEAN ................ :: ListIncLev0 ............................... :: 3 of 3 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > IncLev1Diff or inclev1diff ]
[ INCREMENTAL LEVEL 1 DIFFERENTIAL ......... :: Report .................................... :: 1 of 8 ] OK
[ INCREMENTAL LEVEL 1 DIFFERENTIAL ......... :: ExecIncLev1DiffCrosscheck ................. :: 2 of 8 ] OK
[ INCREMENTAL LEVEL 1 DIFFERENTIAL ......... :: ExecIncLev1Diff ........................... :: 3 of 8 ] OK
[ INCREMENTAL LEVEL 1 DIFFERENTIAL ......... :: ExecCTRL .................................. :: 4 of 8 ] OK
[ INCREMENTAL LEVEL 1 DIFFERENTIAL ......... :: ExecSPFile ................................ :: 5 of 8 ] OK
[ INCREMENTAL LEVEL 1 DIFFERENTIAL ......... :: ValidIncLev1Diff .......................... :: 6 of 8 ] OK
[ INCREMENTAL LEVEL 1 DIFFERENTIAL ......... :: ValidIncLev1DiffLogical ................... :: 7 of 8 ] OK
[ INCREMENTAL LEVEL 1 DIFFERENTIAL ......... :: ListIncLev1Diff ........................... :: 8 of 8 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > IncLev1DiffClean or inclev1diffclean ]
[ INCREMENTAL LEVEL 1 DIFFERENTIAL CLEAN ... :: ExecIncLev1DiffCrosscheck ................. :: 1 of 3 ] OK
[ INCREMENTAL LEVEL 1 DIFFERENTIAL CLEAN ... :: ExecIncLev1DiffClean ...................... :: 2 of 3 ] OK
[ INCREMENTAL LEVEL 1 DIFFERENTIAL CLEAN ... :: ListIncLev1Diff ........................... :: 3 of 3 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > IncLev1Cum or inclev1cum ]
[ INCREMENTAL LEVEL 1 CUMULATIVE ........... :: Report .................................... :: 1 of 8 ] OK
[ INCREMENTAL LEVEL 1 CUMULATIVE ........... :: ExecIncLev1CumCrosscheck .................. :: 2 of 8 ] OK
[ INCREMENTAL LEVEL 1 CUMULATIVE ........... :: ExecIncLev1Cum ............................ :: 3 of 8 ] OK
[ INCREMENTAL LEVEL 1 CUMULATIVE ........... :: ExecCTRL .................................. :: 4 of 8 ] OK
[ INCREMENTAL LEVEL 1 CUMULATIVE ........... :: ExecSPFile ................................ :: 5 of 8 ] OK
[ INCREMENTAL LEVEL 1 CUMULATIVE ........... :: ValidIncLev1Cum ........................... :: 6 of 8 ] OK
[ INCREMENTAL LEVEL 1 CUMULATIVE ........... :: ValidIncLev1CumLogical .................... :: 7 of 8 ] OK
[ INCREMENTAL LEVEL 1 CUMULATIVE ........... :: ListIncLev1Cum ............................ :: 8 of 8 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > IncLev1CumClean or inclev1cumclean ]
[ INCREMENTAL LEVEL 1 CUMULATIVE CLEAN ..... :: ExecIncLev1CumCrosscheck .................. :: 1 of 3 ] OK
[ INCREMENTAL LEVEL 1 CUMULATIVE CLEAN ..... :: ExecIncLev1CumClean ....................... :: 2 of 3 ] OK
[ INCREMENTAL LEVEL 1 CUMULATIVE CLEAN ..... :: ListIncLev1Cum ............................ :: 3 of 3 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > CopyDB or copydb ]
[ COPY DATABASE ............................ :: Report .................................... :: 1 of 8 ] OK
[ COPY DATABASE ............................ :: ExecCopyDBCrosscheck ...................... :: 2 of 8 ] OK
[ COPY DATABASE ............................ :: ExecCopyDB ................................ :: 3 of 8 ] OK
[ COPY DATABASE ............................ :: ExecCTRL .................................. :: 4 of 8 ] OK
[ COPY DATABASE ............................ :: ExecSPFile ................................ :: 5 of 8 ] OK
[ COPY DATABASE ............................ :: ValidCopyDB ............................... :: 6 of 8 ] OK
[ COPY DATABASE ............................ :: ValidCopyDBLogical ........................ :: 7 of 8 ] OK
[ COPY DATABASE ............................ :: ListCopyDB ................................ :: 8 of 8 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > CopyDBClean or copydbclean ]
[ COPY DATABASE CLEAN ...................... :: ExecCopyDBCrosscheck ...................... :: 1 of 3 ] OK
[ COPY DATABASE CLEAN ...................... :: ExecCopyDBClean ........................... :: 2 of 3 ] OK
[ COPY DATABASE CLEAN ...................... :: ListCopyDB ................................ :: 3 of 3 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > CopyDF < DATAFILE NUMBER > or copydf < DATAFILE NUMBER > ]
[ COPY DATAFILE ............................ :: Report .................................... :: 1 of 8 ] OK
[ COPY DATAFILE ............................ :: ExecCopyDFCrosscheck ...................... :: 2 of 8 ] OK
[ COPY DATAFILE ............................ :: ExecCopyDF ................................ :: 3 of 8 ] OK
[ COPY DATAFILE ............................ :: ExecCTRL .................................. :: 4 of 8 ] OK
[ COPY DATAFILE ............................ :: ExecSPFile ................................ :: 5 of 8 ] OK
[ COPY DATAFILE ............................ :: ValidCopyDF ............................... :: 6 of 8 ] OK
[ COPY DATAFILE ............................ :: ValidCopyDFLogical ........................ :: 7 of 8 ] OK
[ COPY DATAFILE ............................ :: ListCopyDF ................................ :: 8 of 8 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > CopyDBClean or copydfclean ]
[ COPY DATAFILE CLEAN ...................... :: ExecCopyDFCrosscheck ...................... :: 1 of 3 ] OK
[ COPY DATAFILE CLEAN ...................... :: ExecCopyDFClean ........................... :: 2 of 3 ] OK
[ COPY DATAFILE CLEAN ...................... :: ListCopyDF ................................ :: 3 of 3 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > SPFile or spfile ]
[ SPFILE ................................... :: ExecSPFileCrosscheck ...................... :: 1 of 3 ] OK
[ SPFILE ................................... :: ExecSPFile ................................ :: 2 of 3 ] OK
[ SPFILE ................................... :: ListSPFile ................................ :: 3 of 3 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > SPFileClean or spfileclean ]
[ SPFILE CLEAN ............................. :: ExecSPFileCrosscheck ...................... :: 1 of 3 ] OK
[ SPFILE CLEAN ............................. :: ExecSPFileClean ........................... :: 2 of 3 ] OK
[ SPFILE CLEAN ............................. :: ListSPFile ................................ :: 3 of 3 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > CTRL or ctrl ]
[ CONTROLFILE .............................. :: ExecCTRLCrosscheck ........................ :: 1 of 4 ] OK
[ CONTROLFILE .............................. :: ExecCTRL .................................. :: 2 of 4 ] OK
[ CONTROLFILE .............................. :: ValidCTRL ................................. :: 3 of 4 ] OK
[ CONTROLFILE .............................. :: ListCTRL .................................. :: 4 of 4 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > CTRLClean or ctrlclean ]
[ CONTROLFILE CLEAN ........................ :: ExecCTRLCrosscheck ........................ :: 1 of 3 ] OK
[ CONTROLFILE CLEAN ........................ :: ExecCTRLClean ............................. :: 2 of 3 ] OK
[ CONTROLFILE CLEAN ........................ :: ListCTRL .................................. :: 3 of 3 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > TBS < TABLESPACE NAME > or tbs < TABLESPACE NAME > ]
[ TABLESPACE ............................... :: ExecTBS ................................... :: 1 of 3 ] OK
[ TABLESPACE ............................... :: ValidTBS .................................. :: 2 of 3 ] OK
[ TABLESPACE ............................... :: ListTBS ................................... :: 3 of 3 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > PDB < PLUGGABLE DATABASE > or pdb < PLUGGABLE DATABASE > ]
[ PLUGGABLE ................................ :: Report .................................... :: 1 of 8 ] OK
[ PLUGGABLE ................................ :: ExecPDBCrosscheck ......................... :: 2 of 8 ] OK
[ PLUGGABLE ................................ :: ExecPDB ................................... :: 3 of 8 ] OK
[ PLUGGABLE ................................ :: ExecCTRL .................................. :: 4 of 8 ] OK
[ PLUGGABLE ................................ :: ExecSPFile ................................ :: 5 of 8 ] OK
[ PLUGGABLE ................................ :: ValidPDB .................................. :: 6 of 8 ] OK
[ PLUGGABLE ................................ :: ValidPDBLogical ........................... :: 7 of 8 ] OK
[ PLUGGABLE ................................ :: ListPDB ................................... :: 8 of 8 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > Crosscheck or crosscheck ]
[ CROSSCHECK ............................... :: ExecCrosscheck ............................ :: 1 of 1 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > CleanAll or cleanall ]
[ CLEAN ALL ................................ :: ExecCrosscheck ............................ :: 1 of 2 ] OK
[ CLEAN ALL ................................ :: ExecCleanAll .............................. :: 2 of 2 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > Report or report ]
[ REPORT ................................... :: Report .................................... ::  1 of 12 ] OK
[ REPORT ................................... :: ListBackupSummary ......................... ::  2 of 12 ] OK
[ REPORT ................................... :: ReportObsolete ............................ ::  3 of 12 ] OK
[ REPORT ................................... :: ListFailures .............................. ::  4 of 12 ] OK
[ REPORT ................................... :: ListFailuresClosed ........................ ::  5 of 12 ] OK
[ REPORT ................................... :: AdviseFailures ............................ ::  6 of 12 ] OK
[ REPORT ................................... :: RepairFailures ............................ ::  7 of 12 ] OK
[ REPORT ................................... :: RestoreValidateDatabase ................... ::  8 of 12 ] OK
[ REPORT ................................... :: RestoreDatabasePreview .................... ::  9 of 12 ] OK
[ REPORT ................................... :: RestoreDatabasePreviewSummary ............. :: 10 of 12 ] OK
[ REPORT ................................... :: RecoverDatabasePreview .................... :: 11 of 12 ] OK
[ REPORT ................................... :: RecoverDatabasePreviewSummary ............. :: 12 of 12 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > RestoreDatabasePreview or restoredatabasepreview ]
[ RESTORE DATABASE PREVIEW ................. :: RestoreDatabasePreview .................... :: 1 of 2 ] OK
[ RESTORE DATABASE PREVIEW ................. :: RestoreDatabasePreviewSummary ............. :: 1 of 2 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > RecoverDatabasePreview or recoverdatabasepreview ]
[ RECOVER DATABASE PREVIEW ................. :: RecoverDatabasePreview .................... :: 1 of 2 ] OK
[ RECOVER DATABASE PREVIEW ................. :: RecoverDatabasePreviewSummary ............. :: 1 of 2 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > DATAPUMP < OPTION > or datapump < OPTIONS > ]
[ DATAPUMP ................................. :: ExecDataPump .............................. :: 1 of 2 ] OK
[ DATAPUMP ................................. :: ListDataPump .............................. :: 2 of 2 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > DATAPUMPClean or datapumpclean ]
[ DATAPUMP CLEAN ........................... :: ExecDataPumpClean ......................... :: 1 of 2 ] OK
[ DATAPUMP CLEAN ........................... :: ListDataPump .............................. :: 2 of 2 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > DATAPUMPConf or datapumpconf ]
[ DATAPUMP CONFIG .......................... :: DataPumpConfig ............................ :: 1 of 1 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > DATAPUMPShowConf or datapumpshowconf ]
[ DATAPUMP SHOW CONFIG...................... :: DataPumpShowConfig ........................ :: 1 of 1 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > RmanSetConf or rmansetconf ]
[ RMAN SET CONFIG .......................... :: RMANSetConfig ............................. :: 1 of 1 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > RmanReSetConfig or rmanresetconfig ]
[ RMAN RESET CONFIG ........................ :: RMANReSetConfig ........................... :: 1 of 1 ] OK
-------------------------------------------------------------------------------------------------------------
[ backup.sh < SID > RmanShowConfig or rmanshowconfig ]
[ RMAN SHOW CONFIG ......................... :: RMANShowConfig ............................ :: 1 of 1 ] OK
-------------------------------------------------------------------------------------------------------------
[ HELP ..................................... :: help ...................................... :: 1 of 1 ] OK
-------------------------------------------------------------------------------------------------------------"
}
#
#########################################################################################################
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute CONTROLFILE Backup
# "-------------------------------------------------------------------------------------------------------------"
# 
ExecCTRL() {
if [[ "${DefaultDevice}" == "DISK" ]]; then
  DATE=$(date +%Y%m%d_%H%M)                                                                                             >> ${LogFile}
  SepLine                                                                                                               >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Backup ControlFile"                                                       >> ${LogFile}
  SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
backup current controlfile format '${DirBase}/${FormatCTRL}' tag='${Global_Name}_ControlFile';
quit;
EOF
#
elif [[ "${DefaultDevice}" == "SBT_TAPE" ]]; then
  DATE=$(date +%Y%m%d_%H%M)                                                                                             >> ${LogFile}
  SepLine                                                                                                               >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Backup ControlFile"                                                       >> ${LogFile}
  SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
backup current controlfile format '${FormatCTRL}' tag='${Global_Name}_ControlFile';
quit;
EOF
#
else
  DATE=$(date +%Y%m%d_%H%M)                                                                                             >> ${LogFile}
  SepLine                                                                                                               >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): DEFAULT DEVICE UNKNOWN, PLEASE VERIFY THE RIGHT OPTION AND TRY IT AGAIN"            >> ${LogFile}
  SepLine                                                                                                               >> ${LogFile}
fi
SepLine                                                                                                                 >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Backup ControlFile"                                                          >> ${LogFile}
SepLine                                                                                                                 >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute CONTROLFILE Crosscheck
# "-------------------------------------------------------------------------------------------------------------"
#
ExecCTRLCrosscheck() {
DATE=$(date +%Y%m%d_%H%M)                                                                                               >> ${LogFile}
SepLine                                                                                                                 >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Crosscheck ControlFile"                                                     >> ${LogFile}
SepLine                                                                                                                 >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
crosscheck copy of controlfile;
crosscheck copy of controlfile tag='${Global_Name}_ControlFile';
quit;
EOF
SepLine                                                                                                                 >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Crosscheck ControlFile"                                                      >> ${LogFile}
SepLine                                                                                                                 >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Validate CONTROLFILE
# "-------------------------------------------------------------------------------------------------------------"
#
ValidCTRL() {
DATE=$(date +%Y%m%d_%H%M)                                                                                              >> ${LogFile}
SepLine                                                                                                                >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Validate ControlFile"                                                      >> ${LogFile}
SepLine                                                                                                                >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                       >> ${LogFile}
${ShowCommand}
validate current controlfile;
# validate controlfilecopy all;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Validate ControlFile"                                                      >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute Clean CONTROLFILE
# "-------------------------------------------------------------------------------------------------------------"
#
ExecCTRLClean() {
DATE=$(date +%Y%m%d_%H%M)                                                                                             >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Clean ControlFile"                                                        >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                      >> ${LogFile}
${ShowCommand}
delete noprompt expired backup of controlfile;
delete noprompt expired backup of controlfile tag='${Global_Name}_ControlFile';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Clean ControlFile"                                                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# List CONTROLFILE
# "-------------------------------------------------------------------------------------------------------------"
#
ListCTRL() {
DATE=$(date +%Y%m%d_%H%M)                                                                                             >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing List ControlFile"                                                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                      >> ${LogFile}
${ShowCommand}
list copy of controlfile;
list copy of controlfile tag='${Global_Name}_ControlFile';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished List ControlFile"                                                          >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
#########################################################################################################
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute SPFile Backup
# "-------------------------------------------------------------------------------------------------------------"
#
ExecSPFile() {
if [[ "${DefaultDevice}" == "DISK" ]]; then
  DATE=$(date +%Y%m%d_%H%M)                                                                                             >> ${LogFile}
  SepLine                                                                                                               >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): Executing SPFILE Backup"                                                            >> ${LogFile}
  SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
backup spfile format '${DirBase}/${FormatSPFile}' tag='${Global_Name}_SPFile';
quit;
EOF
#
elif [[ "${DefaultDevice}" == "SBT_TAPE" ]]; then
  DATE=$(date +%Y%m%d_%H%M)                                                                                             >> ${LogFile}
  SepLine                                                                                                               >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): Executing SPFILE Backup"                                                            >> ${LogFile}
  SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
backup spfile format '${FormatSPFile}' tag='${Global_Name}_SPFile';
quit;
EOF
else
  DATE=$(date +%Y%m%d_%H%M)                                                                                             >> ${LogFile}
  SepLine                                                                                                               >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): DEFAULT DEVICE UNKNOWN, PLEASE VERIFY THE RIGHT OPTION AND TRY IT AGAIN"            >> ${LogFile}
  SepLine                                                                                                               >> ${LogFile}
fi
SepLine                                                                                                                 >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished SPFILE Backup"                                                               >> ${LogFile}
SepLine                                                                                                                 >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute SPFile Crosscheck
# "-------------------------------------------------------------------------------------------------------------"
#
ExecSPFileCrosscheck() {
DATE=$(date +%Y%m%d_%H%M)                                                                                             >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing SPFILE Crosscheck"                                                        >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                      >> ${LogFile}
${ShowCommand}
crosscheck backup of spfile;
crosscheck backuppiece tag='${Global_Name}_SPFile';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished SPFILE Crosscheck"                                                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute Clean SPFile
# "-------------------------------------------------------------------------------------------------------------"
#
ExecSPFileClean() {
DATE=$(date +%Y%m%d_%H%M)                                                                                             >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Clean SPFILE"                                                             >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                      >> ${LogFile}
${ShowCommand}
delete noprompt expired backup of spfile;
delete noprompt expired backup of spfile tag='${Global_Name}_SPFile';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Clean SPFILE"                                                              >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# List SPFile
# "-------------------------------------------------------------------------------------------------------------"
#
ListSPFile() {
DATE=$(date +%Y%m%d_%H%M)                                                                                             >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing List SPFile"                                                              >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                      >> ${LogFile}
${ShowCommand}
list backup of spfile;
list backup of spfile tag='${Global_Name}_SPFile';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished List SPFILE"                                                               >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
#########################################################################################################
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute Full Backup
# "-------------------------------------------------------------------------------------------------------------"
#
ExecFull() {
if [[ "${DefaultDevice}" == "DISK" ]]; then
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
  DATE=$(date +%Y%m%d_%H%M)                                                                                             >> ${LogFile}
  SepLine                                                                                                               >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Full Backup - Compressed"                                                 >> ${LogFile}
  SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch2 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch3 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch4 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
backup full as ${CompressBKP} backupset database format '${DirBase}/${FormatFull}' tag='${Global_Name}_Full_Compressed';
}
quit;
EOF
  SepLine                                                                                                               >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Full Backup - Compressed"                                                  >> ${LogFile}
  SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
  DATE=$(date +%Y%m%d_%H%M)                                                                                               >> ${LogFile}
  SepLine                                                                                                                 >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Full Backup"                                                                >> ${LogFile}
  SepLine                                                                                                                 >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                          >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch2 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch3 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch4 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
backup database format '${DirBase}/${FormatFull}' tag='${Global_Name}_Full';
}
quit;
EOF
  SepLine                                                                                                               >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Full Backup"                                                               >> ${LogFile}
  SepLine                                                                                                               >> ${LogFile}
else
  DATE=$(date +%Y%m%d_%H%M)                                                                                             >> ${LogFile}
  SepLine                                                                                                               >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Full Backup"                                                              >> ${LogFile}
  SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
backup database format '${DirBase}/${FormatFull}' tag='${Global_Name}_Full';
}
quit;
EOF
  SepLine                                                                                                               >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Full Backup"                                                               >> ${LogFile}
  SepLine                                                                                                               >> ${LogFile}
fi
elif [[ "${DefaultDevice}" == "SBT_TAPE" ]]; then
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
  DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
  SepLine                                                                                                               >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Full Backup - Compressed"                                                 >> ${LogFile}
  SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch2 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch3 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch4 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
backup full as ${CompressBKP} backupset database format '${FormatFull}' tag='${Global_Name}_Full_Compressed';
}
quit;
EOF
  SepLine                                                                                                               >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Full Backup - Compressed"                                                  >> ${LogFile}
  SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
  DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
  SepLine                                                                                                               >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Full Backup"                                                              >> ${LogFile}
  SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch2 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch3 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch4 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
backup database format '${FormatFull}' tag='${Global_Name}_Full';
}
quit;
EOF
  SepLine                                                                                                               >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Full Backup"                                                               >> ${LogFile}
  SepLine                                                                                                               >> ${LogFile}
else
  DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
  SepLine                                                                                                               >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Full Backup"                                                              >> ${LogFile}
  SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
backup database format '${FormatFull}' tag='${Global_Name}_Full';
}
quit;
EOF
  SepLine                                                                                                               >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Full Backup"                                                               >> ${LogFile}
  SepLine                                                                                                               >> ${LogFile}
fi
else
  DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
  SepLine                                                                                                               >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): DEFAULT DEVICE UNKNOWN, PLEASE VERIFY THE RIGHT OPTION AND TRY IT AGAIN"            >> ${LogFile}
  SepLine                                                                                                               >> ${LogFile}
fi
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute Full Crosscheck
# "-------------------------------------------------------------------------------------------------------------"
#
ExecFullCrosscheck() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Full Crosscheck"                                                          >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
crosscheck backup;
crosscheck backup of database;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Full Crosscheck"                                                           >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Validate Full Backup
# "-------------------------------------------------------------------------------------------------------------"
#
ValidFull() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Validate Full Backup"                                                     >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
backup validate database;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Validate Full Backup"                                                      >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Validate Full Check Logical Backup
# "-------------------------------------------------------------------------------------------------------------"
#
ValidFullCheckLogical() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Validate Full Check Logical Backup"                                       >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
backup check logical database;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Validate Full Check Logical Backup"                                        >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# List Full Backup
# "-------------------------------------------------------------------------------------------------------------"
#
ListFull() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing List Full Backup"                                                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
list backup of database;
list backup of database tag='${Global_Name}_Full';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished List Full Backup"                                                          >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute Clean Full Backup
# "-------------------------------------------------------------------------------------------------------------"
#
ExecFullClean() {
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Clean Full Backup"                                                        >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
delete noprompt obsolete;
delete noprompt backup completed before 'sysdate - ${RetTimeDatabase}';
delete noprompt backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_Full_Compressed';
delete noprompt expired backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_Full_Compressed';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Clean Full Backup"                                                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Clean Full Backup"                                                        >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
delete noprompt obsolete;
delete noprompt backup completed before 'sysdate - ${RetTimeDatabase}';
delete noprompt backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_Full';
delete noprompt expired backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_Full';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Clean Full Backup"                                                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Clean Full Backup"                                                        >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
delete noprompt obsolete;
delete noprompt backup completed before 'sysdate - ${RetTimeDatabase}';
delete noprompt backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_Full';
delete noprompt expired backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_Full';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Clean Full Backup"                                                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
}
#
#########################################################################################################
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute Full Archivelog All
# "-------------------------------------------------------------------------------------------------------------"
#
ExecFullArchAll() {
if [[ "${DefaultDevice}" == "DISK" ]]; then
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Full Archivelog All - Compressed"                                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch2 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch3 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch4 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
backup database as ${CompressBKP} backupset format '${DirBase}/${FormatFull}' tag='${Global_Name}_FullArchAll_Compressed' 
archivelog all format '${DirBase}/${FormatArch}' tag='${Global_Name}_FullArchAll_Compressed';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Full Archivelog All - Compressed"                                          >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Full Archivelog All"                                                      >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch2 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch3 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch4 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
backup database format '${DirBase}/${FormatFull}' tag='${Global_Name}_FullArchAll'
archivelog all format '${DirBase}/${FormatArch}' tag='${Global_Name}_FullArchAll';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Full Archivelog All"                                                       >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Full Archivelog All"                                                      >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
backup database format '${DirBase}/${FormatFull}' tag='${Global_Name}_FullArchAll'
archivelog all format '${DirBase}/${FormatArch}' tag='${Global_Name}_FullArchAll';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Full Archivelog All"                                                       >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
elif [[ "${DefaultDevice}" == "SBT_TAPE" ]]; then
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Full Archivelog All - Compressed"                                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch2 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch3 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch4 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
backup full as ${CompressBKP} backupset format '${FormatFull}' tag='${Global_Name}_FullArchAll_Compressed'
archivelog all format '${FormatArch}' tag='${Global_Name}_FullArchAll_Compressed';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Full Archivelog All - Compressed"                                          >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Full Archivelog All"                                                      >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch2 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch3 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch4 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
backup database format '${FormatFull}' tag='${Global_Name}_FullArchAll'
archivelog all format '${FormatArch}' tag='${Global_Name}_FullArchAll';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Full Archivelog All"                                                       >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Full Archivelog All"                                                      >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
backup database format '${FormatFull}' tag='${Global_Name}_FullArchAll'
archivelog format '${FormatArch}' tag='${Global_Name}_FullArchAll';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Full Archivelog All"                                                       >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): DEFAULT DEVICE UNKNOWN, PLEASE VERIFY THE RIGHT OPTION AND TRY IT AGAIN"            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute Crosscheck Full Archivelog All
# "-------------------------------------------------------------------------------------------------------------"
#
ExecFullArchAllCrosscheck() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Crosscheck Full Archivelog All"                                           >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
crosscheck backup;
crosscheck backup of database;
crosscheck archivelog all;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Crosscheck Full Archivelog All"                                            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Validate Full Archivelog All
# "-------------------------------------------------------------------------------------------------------------"
#
ValidFullArchAll() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Validate Full Archivelog All"                                             >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
validate archivelog all;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Validate Full Archivelog All"                                              >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Validate Check Logical Full Archivelog All
# "-------------------------------------------------------------------------------------------------------------"
#
ValidFullArchAllCheckLogical() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Validate Check Logical Full Archivelog All"                               >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
backup validate check logical database archivelog all;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Validate Check Logical Full Archivelog All"                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# List Full Archivelog All
# "-------------------------------------------------------------------------------------------------------------"
#
ListFullArchAll() {
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing List Full Archivelog All - Compressed"                                    >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
list backup of database;
list backup tag='${Global_Name}_FullArchAll_Compressed';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished List Full Archivelog All - Compressed"                                     >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing List Full Archivelog All"                                                 >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
list backup of database;
list backup tag='${Global_Name}_FullArchAll';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished List Full Archivelog All"                                                  >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing List Full Archivelog All"                                                 >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
list backup of database;
list backup tag='${Global_Name}_FullArchAll';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished List Full Archivelog All"                                                  >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute Clean Full Archivelog All
# "-------------------------------------------------------------------------------------------------------------"
#
ExecFullArchAllClean() {
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Execute Clean Full Archivelog All - Compressed"                           >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
delete noprompt obsolete;
delete noprompt backup completed before 'sysdate - ${RetTimeDatabase}';
delete noprompt backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_FullArchAll_Compressed';
delete noprompt expired archivelog all completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_FullArchAll_Compressed';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Execute Clean Full Archivelog All - Compressed"                            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Execute Clean Full Archivelog All"                                        >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
delete noprompt obsolete;
delete noprompt backup completed before 'sysdate - ${RetTimeDatabase}';
delete noprompt backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_FullArchAll';
delete noprompt expired archivelog all completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_FullArchAll';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Execute Clean Full Archivelog All"                                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Execute Clean Full Archivelog All"                                        >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
delete noprompt obsolete;
delete noprompt backup completed before 'sysdate - ${RetTimeDatabase}';
delete noprompt backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_FullArchAll';
delete noprompt expired archivelog all completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_FullArchAll';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Execute Clean Full Archivelog All"                                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
}
#
#########################################################################################################
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute Archivelog All
# "-------------------------------------------------------------------------------------------------------------"
#
ExecArchAll() {
if [[ "${DefaultDevice}" == "DISK" ]]; then
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Archivelog All"                                                           >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch2 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch3 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch4 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
backup archivelog all format '${DirBase}/${FormatArch}' delete input tag='${Global_Name}_ArchAll';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Archivelog All"                                                            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]
then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Archivelog All"                                                           >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch2 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch3 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch4 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
backup archivelog all format '${DirBase}/${FormatArch}' delete input tag='${Global_Name}_ArchAll';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Archivelog All"                                                            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Archivelog All"                                                           >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
backup archivelog all format '${DirBase}/${FormatArch}' delete input tag='${Global_Name}_ArchAll';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Archivelog All"                                                            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
elif [[ "${DefaultDevice}" == "SBT_TAPE" ]]; then
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Archivelog All"                                                           >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch2 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch3 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch4 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
backup archivelog all format '${FormatArch}' delete input tag='${Global_Name}_ArchAll';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Archivelog All"                                                            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Archivelog All"                                                           >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch2 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch3 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch4 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
backup archivelog all format '${FormatArch}' delete input tag='${Global_Name}_ArchAll';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Archivelog All"                                                            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Archivelog All"                                                           >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
backup archivelog all format '${FormatArch}' delete input tag='${Global_Name}_ArchAll';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Archivelog All"                                                            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): DEFAULT DEVICE UNKNOWN, PLEASE VERIFY THE RIGHT OPTION AND TRY IT AGAIN"            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute Crosscheck Archivelog All
# "-------------------------------------------------------------------------------------------------------------"
#
ExecArchAllCrosscheck() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Crosscheck Archivelog All"                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
crosscheck archivelog all;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Crosscheck Archivelog All"                                                 >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# List Archivelog All
# "-------------------------------------------------------------------------------------------------------------"
#
ListArchAll() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing List Archivelog All"                                                      >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
list backup of archivelog all;
list backup of archivelog all tag='${Global_Name}_ArchAll';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished List Archivelog All"                                                       >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute Clean Archivelog All
# "-------------------------------------------------------------------------------------------------------------"
#
ExecArchAllClean() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Clean Archivelog All"                                                     >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
delete noprompt obsolete;
delete noprompt archivelog all completed before 'sysdate - ${RetTimeDatabase}';
delete noprompt archivelog all completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_ArchAll';
delete noprompt expired archivelog all completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_ArchAll';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Clean Archivelog All"                                                      >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
#########################################################################################################
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute Incremental Level 0
# "-------------------------------------------------------------------------------------------------------------"
#
ExecIncLev0() {
if [[ "${DefaultDevice}" == "DISK" ]]; then
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Incremental Level 0 - Compressed"                                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch2 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch3 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch4 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
backup as ${CompressBKP} backupset incremental level 0 database format '${DirBase}/${FormatIncLev0}' tag='${Global_Name}_IncLev0_Compressed';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Incremental Level 0 - Compressed"                                          >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Incremental Level 0"                                                      >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch2 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch3 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch4 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
backup incremental level 0 database format '${DirBase}/${FormatIncLev0}' tag='${Global_Name}_IncLev0';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Incremental Level 0"                                                       >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Incremental Level 0"                                                      >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
backup incremental level 0 database format '${DirBase}/${FormatIncLev0}' tag='${Global_Name}_IncLev0';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Incremental Level 0"                                                       >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
elif [[ "${DefaultDevice}" == "SBT_TAPE" ]]; then
  if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Incremental Level 0 - Compressed"                                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch2 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch3 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch4 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
backup as ${CompressBKP} backupset incremental level 0 database format '${FormatIncLev0}' tag='${Global_Name}_IncLev0_Compressed';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Incremental Level 0 - Compressed"                                          >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Incremental Level 0"                                                      >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch2 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch3 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch4 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
backup incremental level 0 database format '${FormatIncLev0}' tag='${Global_Name}_IncLev0';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Incremental Level 0"                                                       >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Incremental Level 0"                                                      >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
backup incremental level 0 database format '${FormatIncLev0}' tag='${Global_Name}_IncLev0';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Incremental Level 0"                                                       >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): DEFAULT DEVICE UNKNOWN, PLEASE VERIFY THE RIGHT OPTION AND TRY IT AGAIN"            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute Incremental Level 0 Crosscheck
# "-------------------------------------------------------------------------------------------------------------"
#
ExecIncLev0Crosscheck() {
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Crosscheck Incremental Level 0 - Compressed"                              >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
crosscheck backup;
crosscheck backuppiece tag='${Global_Name}_IncLev0_Compressed';
crosscheck backup of database tag='${Global_Name}_IncLev0_Compressed';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Crosscheck Incremental Level 0 - Compressed"                               >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Crosscheck Incremental Level 0"                                           >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
crosscheck backup;
crosscheck backuppiece tag='${Global_Name}_IncLev0';
crosscheck backup of database tag='${Global_Name}_IncLev0';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Crosscheck Incremental Level 0"                                            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Crosscheck Incremental Level 0"                                           >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
crosscheck backup;
crosscheck backuppiece tag='${Global_Name}_IncLev0';
crosscheck backup of database tag='${Global_Name}_IncLev0';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Crosscheck Incremental Level 0"                                            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Validate Incremental Level 0
# "-------------------------------------------------------------------------------------------------------------"
#
ValidIncLev0() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Validate Incremental Level 0"                                             >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
backup validate incremental level 0 database;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Validate Incremental Level 0"                                              >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Validate Incremental Level 0 Logical
# "-------------------------------------------------------------------------------------------------------------"
#
ValidIncLev0Logical() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Logical Validate Incremental Level 0"                                     >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
backup validate check logical database;
backup validate database archivelog all;
backup validate check logical database archivelog all;
backup validate database;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Logical Validate Incremental Level 0"                                      >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# List Incremental Level 0
# "-------------------------------------------------------------------------------------------------------------"
#
ListIncLev0() {
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing List Incremental Level 0 - Compressed"                                    >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
list backup tag='${Global_Name}_InvLev0_Compressed';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished List Incremental Level 0 - Compressed"                                     >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing List Incremental Level 0"                                                 >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
list backup tag='${Global_Name}_InvLev0';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished List Incremental Level 0"                                                  >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing List Incremental Level 0"                                                 >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
list backup tag='${Global_Name}_InvLev0';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished List Incremental Level 0"                                                  >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute Clean Incremental Level 0
# "-------------------------------------------------------------------------------------------------------------"
#
ExecIncLev0Clean() {
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Clean Incremental Level 0 - Compressed"                                   >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
delete noprompt obsolete;
delete noprompt backup completed before 'sysdate - ${RetTimeDatabase}';
delete noprompt backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_IncLev0_Compressed';
delete noprompt expired backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_IncLev0_Compressed';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Clean Incremental Level 0 - Compressed"                                    >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Clean Incremental Level 0"                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
delete noprompt obsolete;
delete noprompt backup completed before 'sysdate - ${RetTimeDatabase}';
delete noprompt backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_IncLev0';
delete noprompt expired backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_IncLev0';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Clean Incremental Level 0"                                                 >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Clean Incremental Level 0"                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
delete noprompt obsolete;
delete noprompt backup completed before 'sysdate - ${RetTimeDatabase}';
delete noprompt backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_IncLev0';
delete noprompt expired backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_IncLev0';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Clean Incremental Level 0"                                                 >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
}
#
#########################################################################################################
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute Incremental Level 1 Differential
# "-------------------------------------------------------------------------------------------------------------"
#
ExecIncLev1Diff() {
if [[ "${DefaultDevice}" == "DISK" ]]; then
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Incremental Level 1 Differential - Compressed"                            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch2 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch3 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch4 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
backup as ${CompressBKP} backupset incremental level 1 database format '${DirBase}/${FormatIncLev1Diff}' tag='${Global_Name}_IncLev1Diff_Compressed';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Incremental Level 1 Differential - Compressed"                             >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]
then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Incremental Level 1 Differential"                                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch2 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch3 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch4 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
backup incremental level 1 database format '${DirBase}/${FormatIncLev1Diff}' tag='${Global_Name}_IncLev1Diff';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Incremental Level 1 Differential"                                          >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Incremental Level 1 Differential"                                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
backup incremental level 1 database format '${DirBase}/${FormatIncLev1Diff}' tag='${Global_Name}_IncLev1Diff';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Incremental Level 1 Differential"                                          >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
elif [[ "${DefaultDevice}" == "SBT_TAPE" ]]; then
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Incremental Level 1 Differential - Compressed"                            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch2 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch3 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch4 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
backup as ${CompressBKP} backupset incremental level 1 database format '${FormatIncLev1Diff}' tag='${Global_Name}_IncLev1Diff_Compressed';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Incremental Level 1 Differential - Compressed"                             >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Incremental Level 1 Differential"                                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch2 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch3 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch4 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
backup incremental level 1 database format '${FormatIncLev1Diff}' tag='${Global_Name}_IncLev1Diff';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Incremental Level 1 Differential"                                          >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Incremental Level 1 Differential"                                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
backup incremental level 1 database format '${FormatIncLev1Diff}' tag='${Global_Name}_IncLev1Diff';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Incremental Level 1 Differential"                                          >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): DEFAULT DEVICE UNKNOWN, PLEASE VERIFY THE RIGHT OPTION AND TRY IT AGAIN"            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute Crosscheck Incremental Level 1 Differential
# "-------------------------------------------------------------------------------------------------------------"
#
ExecIncLev1DiffCrosscheck() {
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Crosscheck Incremental Level 1 Differential - Compressed"                 >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
crosscheck backup;
crosscheck backuppiece tag='${Global_Name}_IncLev1Diff_Compressed';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Crosscheck Incremental Level 1 Differential - Compressed"                  >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Crosscheck Incremental Level 1 Differential"                              >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
crosscheck backup;
crosscheck backuppiece tag='${Global_Name}_IncLev1Diff';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Crosscheck Incremental Level 1 Differential"                               >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Crosscheck Incremental Level 1 Differential"                              >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
crosscheck backup;
crosscheck backuppiece tag='${Global_Name}_IncLev1Diff';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Crosscheck Incremental Level 1 Differential"                               >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Validate Incremental 1 Differential
# "-------------------------------------------------------------------------------------------------------------"
#
ValidIncLev1Diff() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Validate Incremental 1 Differential"                                      >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
backup validate incremental level 1 database;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Validate Incremental 1 Differential"                                       >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Validate Incremental Level 1 Differential Logical
# "-------------------------------------------------------------------------------------------------------------"
#
ValidIncLev1DiffLogical() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Validate Incremental Level 1 Differential Logical"                        >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
backup validate check logical database;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Validate Incremental Level 1 Differential Logical"                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# List Incremental Level 1 Differential
# "-------------------------------------------------------------------------------------------------------------"
#
ListIncLev1Diff() {
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing List Incremental Level 1 Differential - Compressed"                       >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
list backup completed before 'sysdate - ${RetTimeDatabase}';
list backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_IncLev1Diff_Compressed';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished List Incremental Level 1 Differential - Compressed"                        >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing List Incremental Level 1 Differential"                                    >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
list backup completed before 'sysdate - ${RetTimeDatabase}';
list backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_IncLev1Diff';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished List Incremental Level 1 Differential"                                     >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing List Incremental Level 1 Differential"                                    >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
list backup completed before 'sysdate - ${RetTimeDatabase}';
list backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_IncLev1Diff';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished List Incremental Level 1 Differential"                                     >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute Clean Incremental Level 1 Differential
# "-------------------------------------------------------------------------------------------------------------"
#
ExecIncLev1DiffClean() {
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Clean Incremental Level 1 Differential - Compressed"                      >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
delete noprompt obsolete;
delete noprompt backup completed before 'sysdate - ${RetTimeDatabase}';
delete noprompt backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_IncLev1Diff_Compressed';
delete noprompt expired backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_IncLev1Diff_Compressed';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Clean Incremental Level 1 Differential - Compressed"                       >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Clean Incremental Level 1 Differential"                                   >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
delete noprompt obsolete;
delete noprompt backup completed before 'sysdate - ${RetTimeDatabase}';
delete noprompt backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_IncLev1Diff';
delete noprompt expired backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_IncLev1Diff';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Clean Incremental Level 1 Differential"                                    >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Clean Incremental Level 1 Differential"                                   >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
delete noprompt obsolete;
delete noprompt backup completed before 'sysdate - ${RetTimeDatabase}';
delete noprompt backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_IncLev1Diff';
delete noprompt expired backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_IncLev1Diff';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Clean Incremental Level 1 Differential"                                    >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
}
#
#########################################################################################################
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute Incremental Level 1 Cumulative
# "-------------------------------------------------------------------------------------------------------------"
#
ExecIncLev1Cum() {
if [[ "${DefaultDevice}" == "DISK" ]]; then
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Incremental Level 1 Cumulative - Compressed"                              >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch2 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch3 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch4 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
backup as ${CompressBKP} backupset incremental level 1 cumulative database format '${DirBase}/${FormatIncLev1Cum}' tag='${Global_Name}_IncLev1Cum_Compressed';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Incremental Level 1 Cumulative - Compressed"                               >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Incremental Level 1 Cumulative"                                           >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch2 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch3 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch4 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
backup incremental level 1 cumulative database format '${DirBase}/${FormatIncLev1Cum}' tag='${Global_Name}_IncLev1Cum';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Incremental Level 1 Cumulative"                                            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Incremental Level 1 Cumulative"                                           >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
backup incremental level 1 cumulative database format '${DirBase}/${FormatIncLev1Cum}' tag='${Global_Name}_IncLev1Cum';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Incremental Level 1 Cumulative"                                            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
elif [[ "${DefaultDevice}" == "SBT_TAPE" ]]; then
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Incremental Level 1 Cumulative - Compressed"                              >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch2 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch3 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch4 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
backup as ${CompressBKP} backupset incremental level 1 cumulative database format '${FormatIncLev1Cum}' tag='${Global_Name}_IncLev1Cum_Compressed';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Incremental Level 1 Cumulative - Compressed"                               >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Incremental Level 1 Cumulative"                                           >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch2 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch3 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch4 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
backup incremental level 1 cumulative database format '${FormatIncLev1Cum}' tag='${Global_Name}_IncLev1Cum';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Incremental Level 1 Cumulative"                                            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Incremental Level 1 Cumulative"                                           >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
backup incremental level 1 cumulative database format '${FormatIncLev1Cum}' tag='${Global_Name}_IncLev1Cum';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Incremental Level 1 Cumulative"                                            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): DEFAULT DEVICE UNKNOWN, PLEASE VERIFY THE RIGHT OPTION AND TRY IT AGAIN"            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute Crosscheck Incremental Level 1 Cumulative
# "-------------------------------------------------------------------------------------------------------------"
#
ExecIncLev1CumCrosscheck() {
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Crosscheck Incremental Level 1 Cumulative - Compressed"                   >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
crosscheck backup;
crosscheck backuppiece tag = '${ORACLE_SID}_IncLev1Cum_Compressed';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Crosscheck Incremental Level 1 Cumulative - Compressed"                    >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Crosscheck Incremental Level 1 Cumulative"                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
crosscheck backup;
crosscheck backuppiece tag = '${ORACLE_SID}_IncLev1Cum';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Crosscheck Incremental Level 1 Cumulative"                                 >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Crosscheck Incremental Level 1 Cumulative"                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
crosscheck backup;
crosscheck backuppiece tag = '${ORACLE_SID}_IncLev1Cum';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Crosscheck Incremental Level 1 Cumulative"                                 >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Validate Incremental Level 1 Cumulative
# "-------------------------------------------------------------------------------------------------------------"
#
ValidIncLev1Cum() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Validate Incremental Level 1 Cumulative"                                  >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
backup validate incremental level 1 cumulative database;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Validate Incremental Level 1 Cumulative"                                   >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Validate Incremental Level 1 Cumulative Logical
# "-------------------------------------------------------------------------------------------------------------"
#
ValidIncLev1CumLogical() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Validate Incremental Level 1 Cumulative Logical"                          >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
backup validate check logical database archivelog all;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Validate Incremental Level 1 Cumulative Logical"                           >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# List Incremental Level 1 Cumulative
# "-------------------------------------------------------------------------------------------------------------"
#
ListIncLev1Cum() {
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing List Incremental Level 1 Cumulative - Compressed"                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
list backup tag='${Global_Name}_IncLev1Cum_Compressed';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished List Incremental Level 1 Cumulative - Compressed"                          >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing List Incremental Level 1 Cumulative"                                      >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
list backup tag='${Global_Name}_IncLev1Cum';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished List Incremental Level 1 Cumulative"                                       >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing List Incremental Level 1 Cumulative"                                      >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
list backup tag='${Global_Name}_IncLev1Cum';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished List Incremental Level 1 Cumulative"                                       >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute Clean Incremental Level 1 Cumulative
# "-------------------------------------------------------------------------------------------------------------"
#
ExecIncLev1CumClean() {
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Clean Incremental Level 1 Cumulative - Compressed"                        >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
delete noprompt obsolete;
delete noprompt backup completed before 'sysdate - ${RetTimeDatabase}';
delete noprompt backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_IncLev1Cum_Compressed';
delete noprompt expired backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_IncLev1Cum_Compressed';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Clean Incremental Level 1 Cumulative - Compressed"                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Clean Incremental Level 1 Cumulative"                                     >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
delete noprompt obsolete;
delete noprompt backup completed before 'sysdate - ${RetTimeDatabase}';
delete noprompt backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_IncLev1Cum';
delete noprompt expired backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_IncLev1Cum';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Clean Incremental Level 1 Cumulative"                                      >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Clean Incremental Level 1 Cumulative"                                     >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
delete noprompt obsolete;
delete noprompt backup completed before 'sysdate - ${RetTimeDatabase}';
delete noprompt backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_IncLev1Cum';
delete noprompt expired backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_IncLev1Cum';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Clean Incremental Level 1 Cumulative"                                      >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
}
#
#########################################################################################################
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute Copy Database
# "-------------------------------------------------------------------------------------------------------------"
#
ExecCopyDB() {
if [[ "${DefaultDevice}" == "DISK" ]]; then
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Copy Database - Compressed"                                               >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch2 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch3 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch4 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
backup as copy database format '${DirBase}/${FormatCopyDB}' tag='${Global_Name}_CopyDB_Compressed'
archivelog all format '${DirBase}/${FormatArch}' tag='${Global_Name}_CopyDB_Compressed';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Copy Database - Compressed"                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Copy Database"                                                            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch2 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch3 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch4 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
backup as copy database format '${DirBase}/${FormatCopyDB}' tag='${Global_Name}_CopyDB'
archivelog all format '${DirBase}/${FormatArch}' tag='${Global_Name}_CopyDB';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Copy Database"                                                             >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Copy Database"                                                            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
backup as copy database format '${DirBase}/${FormatCopyDB}' tag='${Global_Name}_CopyDB'
archivelog all format '${DirBase}/${FormatArch}' tag='${Global_Name}_CopyDB';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Copy Database"                                                             >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
elif [[ "${DefaultDevice}" == "SBT_TAPE" ]]; then
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Copy Database - Compressed"                                               >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch2 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch3 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch4 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
backup as copy database format '${FormatCopyDB}' tag='${Global_Name}_CopyDB_Compressed'
archivelog all format '${DirBase}/${FormatArch}' tag='${Global_Name}_CopyDB_Compressed';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Copy Database - Compressed"                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Copy Database"                                                            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch2 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch3 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch4 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
backup as copy database format '${FormatCopyDB}' tag='${Global_Name}_CopyDB'
archivelog all format '${DirBase}/${FormatArch}' tag='${Global_Name}_CopyDB';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Copy Database"                                                             >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Copy Database"                                                            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
backup as copy database format '${FormatCopyDB}' tag='${Global_Name}_CopyDB'
archivelog all format '${DirBase}/${FormatArch}' tag='${Global_Name}_CopyDB';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Copy Database"                                                             >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): DEFAULT DEVICE UNKNOWN, PLEASE VERIFY THE RIGHT OPTION AND TRY IT AGAIN"            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute Crosscheck Copy Database
# "-------------------------------------------------------------------------------------------------------------"
#
ExecCopyDBCrosscheck() {
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Crosscheck Copy Database - Compressed"                                    >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
crosscheck backup;
crosscheck copy of database;
crosscheck copy tag='${Global_Name}_CopyDB_Compressed';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Crosscheck Copy Database - Compressed"                                     >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Crosscheck Copy Database"                                                 >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
crosscheck backup;
crosscheck copy of database;
crosscheck copy tag='${Global_Name}_CopyDB';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Crosscheck Copy Database"                                                  >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Crosscheck Copy Database"                                                 >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
crosscheck backup;
crosscheck copy of database;
crosscheck copy tag='${Global_Name}_CopyDB';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Crosscheck Copy Database"                                                  >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Validate Copy Database
# "-------------------------------------------------------------------------------------------------------------"
#
ValidCopyDB() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Validate Copy Database"                                                   >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
backup validate copy of database;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Validate Copy Database"                                                    >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Validate Copy Database Logical
# "-------------------------------------------------------------------------------------------------------------"
#
ValidCopyDBLogical() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Validate Copy Database Logical"                                           >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
backup validate check logical copy of database;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Validate Copy Database Logical"                                            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# List Copy Database
# "-------------------------------------------------------------------------------------------------------------"
#
ListCopyDB() {
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing List Copy Database - Compressed"                                          >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
list copy of database;
list backup tag='${Global_Name}_CopyDB_Compressed';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished List Copy Database - Compressed"                                           >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing List Copy Database"                                                       >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
list copy of database;
list backup tag='${Global_Name}_CopyDB';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished List Copy Database"                                                        >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing List Copy Database"                                                       >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
list copy of database;
list backup tag='${Global_Name}_CopyDB';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished List Copy Database"                                                        >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute Clean Copy Database
# "-------------------------------------------------------------------------------------------------------------"
#
ExecCopyDBClean() {
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Clean Copy Database - Compressed"                                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
delete noprompt expired copy of database;
delete noprompt expired copy of database completed before 'sysdate - ${RetTimeDatabase}';
delete noprompt expired copy of database completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_CopyDB_Compressed';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Clean Copy Database - Compressed"                                          >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Clean Copy Database"                                                      >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
delete noprompt expired copy of database;
delete noprompt expired copy of database completed before 'sysdate - ${RetTimeDatabase}';
delete noprompt expired copy of database completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_CopyDB';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Clean Copy Database"                                                       >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Clean Copy Database"                                                      >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
delete noprompt expired copy of database;
delete noprompt expired copy of database completed before 'sysdate - ${RetTimeDatabase}';
delete noprompt expired copy of database completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_CopyDB';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Clean Copy Database"                                                       >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
}
#
#########################################################################################################
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute Copy Datafile
# "-------------------------------------------------------------------------------------------------------------"
#
ExecCopyDF() {
if [[ "${DefaultDevice}" == "DISK" ]]; then
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Copy Datafile - Compressed"                                               >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch2 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch3 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch4 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
backup as copy datafile ${Options} format '${DirBase}/${FormatCopyDF}' tag='${Global_Name}_CopyDF_Compressed';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Copy Datafile - Compressed"                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Copy Datafile"                                                            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch2 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch3 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch4 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
backup as copy datafile ${Options} format '${DirBase}/${FormatCopyDF}' tag='${Global_Name}_CopyDF';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Copy Datafile"                                                             >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Copy Datafile"                                                            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
backup as copy datafile ${Options} format '${DirBase}/${FormatCopyDF}' tag='${Global_Name}_CopyDF';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Copy Datafile"                                                             >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
elif [[ "${DefaultDevice}" == "SBT_TAPE" ]]; then
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Copy Datafile - Compressed"                                               >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch2 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch3 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch4 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
backup as copy datafile ${Options} format '${FormatCopyDF}' tag='${Global_Name}_CopyDF_Compressed';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Copy Datafile - Compressed"                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Copy Datafile"                                                            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch2 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch3 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch4 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
backup as copy datafile ${Options} format '${FormatCopyDF}' tag='${Global_Name}_CopyDF';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Copy Datafile"                                                             >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Copy Datafile"                                                            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
backup as copy datafile ${Options} format '${FormatCopyDF}' tag='${Global_Name}_CopyDF';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Copy Datafile"                                                             >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): DEFAULT DEVICE UNKNOWN, PLEASE VERIFY THE RIGHT OPTION AND TRY IT AGAIN"            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute Crosscheck Copy Datafile
# "-------------------------------------------------------------------------------------------------------------"
#
ExecCopyDFCrosscheck() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Crosscheck Copy Datafile"                                                 >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
crosscheck datafilecopy all;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Crosscheck Copy Datafile"                                                  >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Validate Copy Datafile;
# "-------------------------------------------------------------------------------------------------------------"
#
ValidCopyDF() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Validate Copy Datafile;"                                                  >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
validate datafilecopy all;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Validate Copy Datafile;"                                                   >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Validate Copy Datafile Logical
# "-------------------------------------------------------------------------------------------------------------"
#
ValidCopyDFLogical() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Validate Copy Datafile Logical"                                           >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
backup validate check logical datafilecopy all;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Validate Copy Datafile Logical"                                            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# List Copy Datafile
# "-------------------------------------------------------------------------------------------------------------"
#
ListCopyDF() {
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing List Copy Datafile - Compressed"                                          >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
list datafilecopy all;
list backup completed before 'sysdate - ${RetTimeDatabase}';
list backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_CopyDF_Compressed';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished List Copy Datafile - Compressed"                                           >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing List Copy Datafile"                                                       >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
list datafilecopy all;
list backup completed before 'sysdate - ${RetTimeDatabase}';
list backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_CopyDF';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished List Copy Datafile"                                                        >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing List Copy Datafile"                                                       >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
list datafilecopy all;
list backup completed before 'sysdate - ${RetTimeDatabase}';
list backup completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_CopyDF';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished List Copy Datafile"                                                        >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute Clean Copy Datafile
# "-------------------------------------------------------------------------------------------------------------"
#
ExecCopyDFClean() {
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Clean Copy Datafile - Compressed"                                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
delete noprompt expired datafilecopy all;
delete noprompt datafilecopy tag='${Global_Name}_CopyDF_Compressed';
delete noprompt datafilecopy completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_CopyDF_Compressed';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Clean Copy Datafile - Compressed"                                          >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Clean Copy Datafile"                                                      >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
delete noprompt expired datafilecopy all;
delete noprompt datafilecopy tag='${Global_Name}_CopyDF';
delete noprompt datafilecopy completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_CopyDF';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Clean Copy Datafile"                                                       >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Clean Copy Datafile"                                                      >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
delete noprompt expired datafilecopy all;
delete noprompt datafilecopy tag='${Global_Name}_CopyDF';
delete noprompt copy completed before 'sysdate - ${RetTimeDatabase}' tag='${Global_Name}_CopyDF';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Clean Copy Datafile"                                                       >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
}
#
#########################################################################################################
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute Tablespace Backup
# "-------------------------------------------------------------------------------------------------------------"
#
ExecTBS() {
if [[ "${DefaultDevice}" == "DISK" ]]; then
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Tablespace Backup - Compressed"                                           >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch2 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch3 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch4 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
backup tablespace ${Options} format '${DirBase}/${FormatTBS}' tag='${Global_Name}_${Options}_TBS_Compressed';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Tablespace Backup - Compressed"                                            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Tablespace Backup"                                                        >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch2 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch3 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch4 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
backup tablespace ${Options} format '${DirBase}/${FormatTBS}' tag='${Global_Name}_${Options}_TBS';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Tablespace Backup"                                                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Tablespace Backup"                                                        >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
alter system switch logfile;
backup tablespace ${Options} format '${DirBase}/${FormatTBS}' tag='${Global_Name}_${Options}_TBS';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Tablespace Backup"                                                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
elif [[ "${DefaultDevice}" == "SBT_TAPE" ]]; then
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Tablespace Backup - Compressed"                                           >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch2 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch3 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch4 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
backup tablespace ${Options} format '${FormatTBS}' tag='${Global_Name}_${Options}_TBS_Compressed';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Tablespace Backup - Compressed"                                            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Tablespace Backup"                                                        >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch2 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch3 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch4 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
backup tablespace ${Options} format '${FormatTBS}' tag='${Global_Name}_${Options}_TBS';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Tablespace Backup"                                                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Tablespace Backup"                                                        >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
alter system switch logfile;
backup tablespace ${Options} format '${FormatTBS}' tag='${Global_Name}_${Options}_TBS';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Tablespace Backup"                                                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): DEFAULT DEVICE UNKNOWN, PLEASE VERIFY THE RIGHT OPTION AND TRY IT AGAIN"            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Validate Tablespace
# "-------------------------------------------------------------------------------------------------------------"
#
ValidTBS() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Validate Tablespace"                                                      >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
backup validate tablespace ${Options};
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Validate Tablespace"                                                       >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# List Tablespace
# "-------------------------------------------------------------------------------------------------------------"
#
ListTBS() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing List Tablespace"                                                          >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
list backup of tablespace ${Options};
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished List Tablespace"                                                           >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
#########################################################################################################
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute Pluggable Backup
# "-------------------------------------------------------------------------------------------------------------"
#
ExecPDB() {
if [[ "${DefaultDevice}" == "DISK" ]]; then
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Pluggable Backup - Compressed"                                            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch2 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch3 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch4 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
backup pluggable database ${Options} format '${DirBase}/${FormatPDB}' tag='${Global_Name}_${Options}_PDB_Compressed';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Pluggable Backup - Compressed"                                             >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Pluggable Backup"                                                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch2 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch3 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
allocate channel ch4 type ${DefaultDevice} ${Parms} maxpiecesize 32G;
backup pluggable database ${Options} format '${DirBase}/${FormatPDB}' tag='${Global_Name}_${Options}_PDB';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Pluggable Backup"                                                          >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Pluggable Backup"                                                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
alter system switch logfile;
backup pluggable database ${Options} format '${DirBase}/${FormatPDB}' tag='${Global_Name}_${Options}_PDB';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Pluggable Backup"                                                          >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
elif [[ "${DefaultDevice}" == "SBT_TAPE" ]]; then
if [[ "${CompressBackup}" == "YES" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Pluggable Backup - Compressed"                                            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch2 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch3 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch4 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
backup pluggable database ${Options} format '${FormatPDB}' tag='${Global_Name}_${Options}_PDB_Compressed';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Pluggable Backup - Compressed"                                             >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
elif [[ "${CompressBackup}" == "NO" ]] && [[ "${Parallel}" == "YES" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Pluggable Backup"                                                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
alter system switch logfile;
allocate channel ch1 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch2 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch3 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
allocate channel ch4 type '${DefaultDevice}' ${Parms} maxpiecesize 32G;
backup pluggable database ${Options} format '${FormatPDB}' tag='${Global_Name}_${Options}_PDB';
}
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Pluggable Backup"                                                          >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Pluggable Backup"                                                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
alter system switch logfile;
backup pluggable database ${Options} format '${FormatPDB}' tag='${Global_Name}_${Options}_PDB';
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Pluggable Backup"                                                          >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
else
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): DEFAULT DEVICE UNKNOWN, PLEASE VERIFY THE RIGHT OPTION AND TRY IT AGAIN"            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
fi
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Execute Crosscheck Pluggable
# "-------------------------------------------------------------------------------------------------------------"
#
ExecPDBCrosscheck() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Crosscheck Pluggable"                                                     >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
crosscheck backup;
crosscheck backup of pluggable database ${Options};
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Crosscheck Pluggable"                                                      >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Validate Pluggable
# "-------------------------------------------------------------------------------------------------------------"
#
ValidPDB() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Validate Pluggable"                                                       >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
validate pluggable database ${Options};
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Validate Pluggable"                                                        >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Validate Pluggable Logical
# "-------------------------------------------------------------------------------------------------------------"
#
ValidPDBLogical() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Validate Pluggable Logical"                                               >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
backup validate pluggable database ${Options};
backup validate check logical pluggable database ${Options};
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Validate Pluggable Logical"                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# List Pluggable
# "-------------------------------------------------------------------------------------------------------------"
#
ListPDB() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing List Pluggable"                                                           >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
list backup of pluggable database ${Options};
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished List Pluggable"                                                            >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#########################################################################################################
#
# "-------------------------------------------------------------------------------------------------------------"
# Crosscheck
# "-------------------------------------------------------------------------------------------------------------"
#
ExecCrosscheck() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Crosscheck"                                                               >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
crosscheck backup;
crosscheck archivelog all;
crosscheck copy of controlfile;
crosscheck backup of spfile;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Crosscheck"                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
#########################################################################################################
#
# "-------------------------------------------------------------------------------------------------------------"
# Clean All
# "-------------------------------------------------------------------------------------------------------------"
#
ExecCleanAll() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Clean All"                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
delete noprompt expired backup;
delete noprompt expired archivelog all;
delete noprompt expired backup of controlfile;
delete noprompt expired backup of spfile;
delete noprompt obsolete;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Clean All"                                                                 >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
#########################################################################################################
#
# "-------------------------------------------------------------------------------------------------------------"
# Report
# "-------------------------------------------------------------------------------------------------------------"
#
Report() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Report"                                                                   >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
report schema;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Report"                                                                    >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# List Backup Summary
# "-------------------------------------------------------------------------------------------------------------"
#
ListBackupSummary() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing List Backup Summary"                                                      >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
list backup summary;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished List Backup Summary"                                                       >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Report Obsolete
# "-------------------------------------------------------------------------------------------------------------"
#
ReportObsolete() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Report Obsolete"                                                          >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
report obsolete;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Report Obsolete"                                                           >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# List of Failures
# "-------------------------------------------------------------------------------------------------------------"
#
ListFailures() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing List of Failures"                                                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
list failure;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished List of Failures"                                                          >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# List of Failures Closed
# "-------------------------------------------------------------------------------------------------------------"
#
ListFailuresClosed() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing List of Failures Closed"                                                  >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
list failure closed;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished List of Failures Closed"                                                   >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Advise of Failures
# "-------------------------------------------------------------------------------------------------------------"
#
AdviseFailures() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Advise of Failures"                                                       >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
advise failure;
advise failure all;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Advise of Failures"                                                        >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Repair of Failures
# "-------------------------------------------------------------------------------------------------------------"
#
RepairFailures() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Repair of Failures"                                                       >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
repair failure;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Repair of Failures"                                                        >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Restore Database Preview Summary
# "-------------------------------------------------------------------------------------------------------------"
#
RestoreDatabasePrevSummary() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Restore Database Preview Summary"                                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
restore database preview;
restore database preview summary;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Restore Database Preview Summary"                                          >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
# "-------------------------------------------------------------------------------------------------------------"
# Restore Validate Database
# "-------------------------------------------------------------------------------------------------------------"
#
RestoreValidateDatabase() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Restore Validate Database"                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
restore validate database;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Restore Validate Database"                                                 >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
#########################################################################################################
#
# "-------------------------------------------------------------------------------------------------------------"
# Restore Database Preview
# "-------------------------------------------------------------------------------------------------------------"
#
RestoreDatabasePreview() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Restore Database Preview"                                                 >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
restore database preview;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Restore Database Preview"                                                  >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
#########################################################################################################
#
# "-------------------------------------------------------------------------------------------------------------"
# Restore Database Preview Summary
# "-------------------------------------------------------------------------------------------------------------"
#
RestoreDatabasePreviewSummary() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Restore Database Preview Summary"                                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
restore database preview summary;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Restore Database Preview Summary"                                          >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
#########################################################################################################
#
# "-------------------------------------------------------------------------------------------------------------"
# Recover Database Preview
# "-------------------------------------------------------------------------------------------------------------"
#
RecoverDatabasePreview() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Recover Database Preview"                                                 >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
recover database preview;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Recover Database Preview"                                                  >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#########################################################################################################
#
# "-------------------------------------------------------------------------------------------------------------"
# Recover Database Preview Summary
# "-------------------------------------------------------------------------------------------------------------"
#
RecoverDatabasePreviewSummary() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing Recover Database Preview Summary"                                         >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
recover database preview summary;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Recover Database Preview Summary"                                          >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
#########################################################################################################
#
# "-------------------------------------------------------------------------------------------------------------"
# Datapump
# "-------------------------------------------------------------------------------------------------------------"
#
ExecDataPump() {
SepLine                                                                                                               >> ${LogFile}
echo -e "$(date +%Y%m%d_%H\:%M\:%S):"                                                                                 >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
# Some Best Practices using Datapump
# flashback_time=systimestamp
# consistent=y
# exclude=statistics
# metrics=y
# logtime=all
# parallel=(2x number of cpu cores you have)
# stream_pool_size=128 (range of 64M until 256M)
# lob_storage=securefile (Migrate to SecureFile Lobs during DB Migration)

# expdp sys/password@$ORACLE_SID .....

}
#
ListDataPump() {
SepLine                                                                                                               >> ${LogFile}
echo -e "$(date +%Y%m%d_%H\:%M\:%S):"                                                                                 >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
ExecDataPumpClean() {
SepLine                                                                                                               >> ${LogFile}
echo -e "$(date +%Y%m%d_%H\:%M\:%S):"                                                                                 >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
DataPumpConfig() {
SepLine                                                                                                               >> ${LogFile}
echo -e "$(date +%Y%m%d_%H\:%M\:%S):"                                                                                 >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
DataPumpShowConfig() {
SepLine                                                                                                               >> ${LogFile}
echo -e "$(date +%Y%m%d_%H\:%M\:%S):"                                                                                 >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
#########################################################################################################
#
# "-------------------------------------------------------------------------------------------------------------"
# RMAN Set Configuration
# "-------------------------------------------------------------------------------------------------------------"
#
RMANSetConfig() {
if [[ "${DefaultDevice}" == "DISK" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing RMAN Set Configuration"                                                   >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
run {
CONFIGURE BACKUP OPTIMIZATION ON;
CONFIGURE CONTROLFILE AUTOBACKUP ON;
CONFIGURE DEFAULT DEVICE TYPE TO DISK;
CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF ${RetTimeDatabase} DAYS;
CONFIGURE DEVICE TYPE DISK PARALLELISM ${Parallelism} BACKUP TYPE TO COMPRESSED BACKUPSET;
CONFIGURE DATAFILE BACKUP COPIES FOR DEVICE TYPE DISK TO 1;
CONFIGURE ARCHIVELOG BACKUP COPIES FOR DEVICE TYPE DISK TO 1;
CONFIGURE CHANNEL DEVICE TYPE DISK FORMAT '/backup/${Global_Name}/${FormatFull}';
CONFIGURE MAXSETSIZE TO 32G;
CONFIGURE ENCRYPTION FOR DATABASE OFF;
CONFIGURE ENCRYPTION ALGORITHM 'AES128';
CONFIGURE ARCHIVELOG DELETION POLICY TO NONE;
CONFIGURE RMAN OUTPUT TO KEEP FOR ${RetTimeDatabase} DAYS;
CONFIGURE COMPRESSION ALGORITHM '${Compression}' AS OF RELEASE 'DEFAULT' OPTIMIZE FOR LOAD TRUE;
CONFIGURE SNAPSHOT CONTROLFILE NAME TO '/backup/${Global_Name}/SnapShot_CTRL_${Global_Name}.scf';
CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '/backup/${Global_Name}/${FormatCTRL}';
}
quit;
EOF
elif [[ "${DefaultDevice}" == "SBT_TAPE" ]]; then
DATE=$(date +%Y%m%d_%H%M)                                                                                      >> ${LogFile}
SepLine                                                                                                        >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing RMAN Set Configuration"                                            >> ${LogFile}
SepLine                                                                                                        >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                               >> ${LogFile}
${ShowCommand}
run {
CONFIGURE BACKUP OPTIMIZATION ON;
CONFIGURE CONTROLFILE AUTOBACKUP ON;
CONFIGURE DEFAULT DEVICE TYPE TO 'SBT_TAPE';
CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF ${RetTimeDatabase} DAYS;
CONFIGURE DEVICE TYPE 'SBT_TAPE' PARALLELISM ${Parallelism} BACKUP TYPE TO BACKUPSET;
CONFIGURE DATAFILE BACKUP COPIES FOR DEVICE TYPE 'SBT_TAPE' TO 1;
CONFIGURE ARCHIVELOG BACKUP COPIES FOR DEVICE TYPE 'SBT_TAPE' TO 1;
CONFIGURE CHANNEL DEVICE TYPE 'SBT_TAPE' ${Parms} FORMAT '${BackupFormat}'
CONFIGURE CHANNEL DEVICE TYPE 'SBT_TYPE' FORMAT '${FormatFull}';
CONFIGURE MAXSETSIZE TO 32G;
CONFIGURE ENCRYPTION FOR DATABASE OFF;
CONFIGURE ENCRYPTION ALGORITHM 'AES128';
CONFIGURE ARCHIVELOG DELETION POLICY TO NONE;
CONFIGURE RMAN OUTPUT TO KEEP FOR ${RetTimeDatabase} DAYS;
CONFIGURE COMPRESSION ALGORITHM '${Compression}' AS OF RELEASE 'DEFAULT' OPTIMIZE FOR LOAD TRUE;
CONFIGURE SNAPSHOT CONTROLFILE NAME TO '/backup/${Global_Name}/snapcf_${Global_Name}.scf';
CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE 'SBT_TAPE' TO '${FormatCTRL}';
}
quit;
EOF
else
DATE=$(date +%Y%m%d_%H%M)                                                                                      >> ${LogFile}
SepLine                                                                                                        >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): DEFAULT DEVICE UNKNOWN, PLEASE VERIFY THE RIGHT OPTION AND TRY IT AGAIN"     >> ${LogFile}
SepLine                                                                                                        >> ${LogFile}
DATE=$(date +%Y%m%d_%H%M)                                                                                      >> ${LogFile}
SepLine                                                                                                        >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished RMAN Set Configuration"                                             >> ${LogFile}
SepLine                                                                                                        >> ${LogFile}
fi
}
#
#########################################################################################################
#
# "-------------------------------------------------------------------------------------------------------------"
# RMAN ReSet Configuration
# "-------------------------------------------------------------------------------------------------------------"
#
RMANReSetConfig() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing RMAN RESET Configuration"                                                 >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
sqlplus -S /nolog <<EOF                                                                                                 >> ${LogFile}
conn / as sysdba
set pagesize 0 linesize 32767 feedback off verify off heading off echo off timing off colsep '|'
execute dbms_backup_restore.resetConfig;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished RMAN RESET Configuration"                                                  >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
#########################################################################################################
#
# "-------------------------------------------------------------------------------------------------------------"
# RMAN Show Configuration
# "-------------------------------------------------------------------------------------------------------------"
#
RMANShowConfig() {
DATE=$(date +%Y%m%d_%H%M)                                                                                                >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Executing RMAN Show Configuration"                                                  >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
rman target / ${CatalogDB} <<EOF                                                                                        >> ${LogFile}
${ShowCommand}
show all;
quit;
EOF
SepLine                                                                                                               >> ${LogFile}
echo "$(date +%Y%m%d_%H\:%M\:%S): Finished RMAN Show Configuration"                                                   >> ${LogFile}
SepLine                                                                                                               >> ${LogFile}
}
#
#########################################################################################################
#
# "-------------------------------------------------------------------------------------------------------------"
#
DBStatus="$(echo "select status from v\$instance;" | sqlplus -S / as sysdba | tail -2)"
#
Global_Name="$(echo "select value from v\$parameter where name = 'db_name';" | sqlplus -S / as sysdba | tail -2)"
#
DBVERSION="$(echo "select distinct substr(value,1,2) as value from v\$parameter where name = 'optimizer_features_enable';" | sqlplus -S / as sysdba | tail -2)"
#
DDBROLE="$(echo "select database_role from v\$database;" | sqlplus -S / as sysdba | tail -2)"
#
ISRACDB="$(echo "select distinct case when value = 'TRUE' then 'CLUSTER' when value = 'FALSE' then 'NONCLUSTER' end from v\$parameter where name = 'cluster_database';" | sqlplus -S / as sysdba | tail -2)"
#
ISCONTAINERDB="$(echo "select distinct case when cdb = 'YES' then 'CONTAINER' when cdb = 'NO' then 'NONCONTAINER' end from v\$database;" | sqlplus -S / as sysdba | tail -2)"
#
ISBIGFILE="$(echo "select distinct case when bigfile = 'YES' then 'BIGFILE' when bigfile = 'NO' then 'NONBIGFILE' end from dba_tablespaces;" | sqlplus -S / as sysdba | tail -2)"
#
DB_SIZEG="$(echo "select to_char(sum(bytes)/1024/1024/1024,'9G999G999D999') from (select sum(bytes) bytes from dba_data_files union all select sum(bytes) bytes from dba_temp_files union all select sum(bytes * members) from v\$log union all select sum(block_size * file_size_blks) from v\$controlfile);" | sqlplus -S / as sysdba | tail -2)"
#
DB_SIZET="$(echo "select to_char(sum(bytes)/1024/1024/1024/1024,'9G999G999D999') from (select sum(bytes) bytes from dba_data_files union all select sum(bytes) bytes from dba_temp_files union all select sum(bytes * members) from v\$log union all select sum(block_size * file_size_blks) from v\$controlfile);" | sqlplus -S / as sysdba | tail -2)"
#
# "-------------------------------------------------------------------------------------------------------------"
#
# "-------------------------------------------------------------------------------------------------------------"
#
#########################################################################################################
#
# "-------------------------------------------------------------------------------------------------------------"
#
if [[ "${ORACLE_HOME}" == "" ]]; then
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): SET THE VARIABLE AND TRY AGAIN"
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_HOME..........: ${ORACLE_HOME}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORATAB...............: ${ORATAB}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_VERSION.......: ${DBVERSION}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): DATABASE_STATUS......: ${DBStatus}"  
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_ROLE..........: ${DDBROLE}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_CLUSTER.......: ${ISRACDB}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_CONTAINER.....: ${ISCONTAINERDB}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): BIG_FILES............: ${ISBIGFILE}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): DATABASE_SIZE........: GB: ${DB_SIZEG} | TB: ${DB_SIZET}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): PARALLELISM..........: ${Parallelism}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): DEFAULT_DEVICE.......: ${DefaultDevice}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): COMPRESSION..........: ${Compression}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): BACKUP_SID...........: ${1}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): BACKUP_TYPE..........: ${2}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): BACKUP_OPTION........: ${3}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): sh backup.sh [ SID ] [ TYPE ] [ OPTION ]"
  echo "$(date +%Y%m%d_%H\:%M\:%S): EX: sh backup.sh dbprod FullArchAll [ Option ]"
  SepLine
  exit 1
fi
#
# "-------------------------------------------------------------------------------------------------------------"
#
if [[ "${ORACLE_SID}" == "" ]]; then
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): THE [ ORACLE_SID ] VARIABLE EXISTS ON YOUR ENVIRONMENT"
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): SET THE VARIABLE AND TRY AGAIN"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_HOME..........: ${ORACLE_HOME}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORATAB...............: ${ORATAB}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_VERSION.......: ${DBVERSION}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): DATABASE_STATUS......: ${DBStatus}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_ROLE..........: ${DDBROLE}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_CLUSTER.......: ${ISRACDB}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_CONTAINER.....: ${ISCONTAINERDB}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): BIG_FILES............: ${ISBIGFILE}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): DATABASE_SIZE........: GB: ${DB_SIZEG} | TB: ${DB_SIZET}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): PARALLELISM..........: ${Parallelism}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): DEFAULT_DEVICE.......: ${DefaultDevice}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): COMPRESSION..........: ${Compression}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): BACKUP_SID...........: ${1}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): BACKUP_TYPE..........: ${2}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): BACKUP_OPTION........: ${3}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): sh backup.sh [ SID ] [ TYPE ] [ OPTION ]"
  echo "$(date +%Y%m%d_%H\:%M\:%S): EX: sh backup.sh dbprod FullArchAll [ Option ]"
  SepLine
  exit 1
fi
#
# "-------------------------------------------------------------------------------------------------------------"
#
if [[ "${ORACLE_HOME}" == "$(grep -v '^\#' ${ORATAB} | grep -v '^$' | grep -i "^${ORACLE_SID}:" | cut -f3 | cut -f2 -d':')" ]]; then
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): THE [ ORACLE_HOME ] VARIABLE EXISTS ON YOUR ENVIRONMENT"
  SepLine
else
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): THE [ ORACLE_HOME ] VARIABLE DOES NOT EXISTS ON YOUR ENVIRONMENT"
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): SET THE VARIABLE AND TRY AGAIN"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_HOME..........: ${ORACLE_HOME}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORATAB...............: ${ORATAB}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_VERSION.......: ${DBVERSION}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): DATABASE_STATUS......: ${DBStatus}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_ROLE..........: ${DDBROLE}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_CLUSTER.......: ${ISRACDB}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_CONTAINER.....: ${ISCONTAINERDB}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): BIG_FILES............: ${ISBIGFILE}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): DATABASE_SIZE........: GB: ${DB_SIZEG} | TB: ${DB_SIZET}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): PARALLELISM..........: ${Parallelism}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): DEFAULT_DEVICE.......: ${DefaultDevice}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): COMPRESSION..........: ${Compression}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): BACKUP_SID...........: ${1}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): BACKUP_TYPE..........: ${2}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): BACKUP_OPTION........: ${3}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): sh backup.sh [ SID ] [ TYPE ] [ OPTION ]"
  echo "$(date +%Y%m%d_%H\:%M\:%S): EX: sh backup.sh dbprod FullArchAll [ Option ]"
  SepLine
  exit 1
fi
#
# "-------------------------------------------------------------------------------------------------------------"
#
if [[ "${ORACLE_SID}" == "$(grep -v '^\#' ${ORATAB} | grep -v '^$' | grep -i "^${ORACLE_SID}:" | cut -f3 | cut -f1 -d':')" ]]; then
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): THE [ ORACLE_SID ] VARIABLE EXISTS ON YOUR ENVIRONMENT"
  SepLine
else
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): THE [ ORACLE_SID ] VARIABLE DOES NOT EXISTS ON YOUR ENVIRONMENT"
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): SET THE VARIABLE AND TRY AGAIN"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_HOME..........: ${ORACLE_HOME}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORATAB...............: ${ORATAB}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_VERSION.......: ${DBVERSION}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): DATABASE_STATUS......: ${DBStatus}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_ROLE..........: ${DDBROLE}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_CLUSTER.......: ${ISRACDB}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_CONTAINER.....: ${ISCONTAINERDB}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): BIG_FILES............: ${ISBIGFILE}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): DATABASE_SIZE........: GB: ${DB_SIZEG} | TB: ${DB_SIZET}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): PARALLELISM..........: ${Parallelism}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): DEFAULT_DEVICE.......: ${DefaultDevice}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): COMPRESSION..........: ${Compression}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): BACKUP_SID...........: ${1}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): BACKUP_TYPE..........: ${2}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): BACKUP_OPTION........: ${3}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): sh backup.sh [ SID ] [ TYPE ] [ OPTION ]"
  echo "$(date +%Y%m%d_%H\:%M\:%S): EX: sh backup.sh dbprod FullArchAll [ Option ]"
  SepLine
  exit 1
fi
#
# "-------------------------------------------------------------------------------------------------------------"
#
if [[ "${1}" == "" ]]; then
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): THE [ ORACLE SID ] VARIABLE WAS NOT SETTED YET"
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): SET THE VARIABLE AND TRY AGAIN"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_HOME..........: ${ORACLE_HOME}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORATAB...............: ${ORATAB}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_VERSION.......: ${DBVERSION}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): DATABASE_STATUS......: ${DBStatus}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_ROLE..........: ${DDBROLE}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_CLUSTER.......: ${ISRACDB}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_CONTAINER.....: ${ISCONTAINERDB}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): BIG_FILES............: ${ISBIGFILE}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): DATABASE_SIZE........: GB: ${DB_SIZEG} | TB: ${DB_SIZET}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): PARALLELISM..........: ${Parallelism}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): DEFAULT_DEVICE.......: ${DefaultDevice}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): COMPRESSION..........: ${Compression}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): BACKUP_SID...........: ${1}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): BACKUP_TYPE..........: ${2}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): BACKUP_OPTION........: ${3}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): sh backup.sh [ SID ] [ TYPE ] [ OPTION ]"
  echo "$(date +%Y%m%d_%H\:%M\:%S): EX: sh backup.sh dbprod FullArchAll [ Option ]"
  SepLine
  exit 1
#
elif [[ "${1}" == "h" ]]; then
  Help
elif [[ "${1}" == "H" ]]; then
  Help
elif [[ "${1}" == "HELP" ]]; then
  Help
elif [[ "${1}" == "Help" ]]; then
  Help
elif [[ "${1}" == "help" ]]; then
  Help
fi
#
# "-------------------------------------------------------------------------------------------------------------"
#
if [[ "$(echo ${2} | tr '[a-z]' '[A-Z]')" == "" ]]; then
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): THE [ BACKUP TYPE ] VARIABLE WAS NOT SETTED YET"
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): SET THE VARIABLE AND TRY AGAIN"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_HOME..........: ${ORACLE_HOME}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORATAB...............: ${ORATAB}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_VERSION.......: ${DBVERSION}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): DATABASE_STATUS......: ${DBStatus}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): DATABASE_STATUS......: ${DBStatus}"  
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_ROLE..........: ${DDBROLE}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_CLUSTER.......: ${ISRACDB}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_CONTAINER.....: ${ISCONTAINERDB}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): BIG_FILES............: ${ISBIGFILE}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): DATABASE_SIZE........: GB: ${DB_SIZEG} | TB: ${DB_SIZET}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): PARALLELISM..........: ${Parallelism}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): DEFAULT_DEVICE.......: ${DefaultDevice}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): COMPRESSION..........: ${Compression}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): BACKUP_SID...........: ${1}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): BACKUP_TYPE..........: ${2}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): BACKUP_OPTION........: ${3}"
  echo "$(date +%Y%m%d_%H\:%M\:%S): sh backup.sh [ SID ] [ TYPE ] [ OPTION ]"
  echo "$(date +%Y%m%d_%H\:%M\:%S): EX: sh backup.sh dbprod FullArchAll [ Option ]"
  SepLine
  exit 1
#
elif [[ "${2}" == "h" ]]; then
  Help
elif [[ "${2}" == "H" ]]; then
  Help
elif [[ "${2}" == "HELP" ]]; then
  Help
elif [[ "${2}" == "Help" ]]; then
  Help
elif [[ "${2}" == "help" ]]; then
  Help
elif [[ "$(echo ${2} | tr '[a-z]' '[A-Z]')" == "PDB" ]] && [[ "${ISCONTAINERDB}" == "YES" ]]; then
if [[ "$(echo ${3} | tr '[a-z]' '[A-Z]')" == "" ]]; then
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): THE [ OPTION ] OF BACKUP VARIABLE WAS NOT SETTED YET"
  echo "$(date +%Y%m%d_%H\:%M\:%S): SET THE VARIABLE AND TRY AGAIN"
  SepLine
  exit 1
else
#
PDBS="$(echo "select distinct case when name = '' then 'NOTEXISTS' when name = '${3}' then '${3}' end from v\$containers where name = upper(('${3}'));" | sqlplus -S / as sysdba | tail -2)"
#
if [[ "$(echo ${3} | tr '[a-z]' '[A-Z]')" = "${PDBS}" ]]; then
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ OPTION ] PLUGGABLE DATABASE ......: ${PDBS}"
  SepLine
else
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): PLUGGABLE DATABASE DOES NOT EXIST"
  SepLine
  exit 1
fi
  fi
elif [[ "$(echo ${2} | tr '[a-z]' '[A-Z]')" == "TBS" ]]; then
  if [[ "$(echo ${3} | tr '[a-z]' '[A-Z]')" == "" ]]; then
    SepLine
    echo "$(date +%Y%m%d_%H\:%M\:%S): THE [ OPTION ] OF BACKUP VARIABLE WAS NOT SETTED YET"
    echo "$(date +%Y%m%d_%H\:%M\:%S): SET THE VARIABLE AND TRY AGAIN"
    SepLine
    exit 1
  else
#
TBSNAMES="$(echo "select tablespace_name as tbs_name from dba_tablespaces where tablespace_name = upper(('${3}'));" | sqlplus -S / as sysdba | tail -2)"
#
if [[ "$(echo ${3} | tr '[a-z]' '[A-Z]')" == "${TBSNAMES}" ]]; then
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ OPTION ] TABLESPACE NAME......: ${TBSNAMES}"
  SepLine
else
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): TABLESPACE NAME DOES NOT EXIST"
  SepLine
  exit 1
fi
  fi
elif [[ "$(echo ${2} | tr '[a-z]' '[A-Z]')" == "COPYDF" ]]; then
if [[ "$(echo ${3} | tr '[a-z]' '[A-Z]')" == "" ]]; then
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): THE [ OPTION ] OF BACKUP VARIABLE WAS NOT SETTED YET"
  echo "$(date +%Y%m%d_%H\:%M\:%S): SET THE VARIABLE AND TRY AGAIN"
  SepLine
  exit 1
else
if [[ "${DBVERSION}" -ge "12" ]]; then
#
DDATAFILE="$(echo "select distinct file_id from cdb_data_files where file_id = '${3}';" | sqlplus -S / as sysdba | tail -2)"
#
else
DDATAFILE="$(echo "select distinct file_id from dba_data_files where file_id = '${3}';" | sqlplus -S / as sysdba | tail -2)"
#
fi
#
if [[ "$(echo ${3} | tr '[a-z]' '[A-Z]')" == "${DDATAFILE}" ]]; then
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ OPTION ] FILE ID......: ${DDATAFILE}"
  SepLine
else
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): FILE ID DOES NOT EXIST"
  SepLine
  exit 1
fi
  fi
fi
#
# "-------------------------------------------------------------------------------------------------------------"
# Environment Variables
#
TERM=xterm                                                                    # The Default TERM
ShowCommand="set echo on;"                                                    # Show the Commands on Each Execution
RetTimeArchive="2"                                                            # How many days will be on the archivelog backup place
RetTimeDatabase="2"                                                           # How many days will be on the database backup place
SendMail="N"                                                                  # Y or N - To Send Emails after Backup
DefaultDevice="DISK"                                                          # DISK or SBT_TAPE
TDPO_PATH=""                                                                  # Example: "/opt/tivoli/tsm/client/oracle/bin64"
Parms=""                                                                      # Example: " parms 'ENV=(TDPO_OPTFILE=${TDPO_PATH}/tdpo_${Global_Name}.opt)' "
CompressBackup="NO"                                                           # YES or NO
CompressBKP="COMPRESSED"                                                      # COMPRESSED
Compression="BASIC"                                                           # LOW, BASIC or HIGH
Parallel="NO"                                                                 # YES or NO
Parallelism="1"                                                               # Number of Parallellism
CatalogDB=""                                                                  # " catalog rman/rmanpwd@catalogdb"
OracleVersion=${DBVERSION}                                                    # Oracle Version
OracleArchitecture=${ISRACDB}                                                 # Oracle Architecture
OracleContainer=${ISCONTAINERDB}                                              # Container
ORACLE_SID=${1}                                                               # Oracle Database Name
BackupType=${2}                                                               # Backup Type
Options=${3}                                                                  # Options
Status=${DBStatus}                                                            # Status of Database
OraHome=${ORACLE_HOME}                                                        # Oracle Home
DirScripts=/opt/dbnitro/backup                                                # Directory of Scripts
DirLogs=${DirScripts}/logs                                                    # Directory of Logs
DirTemp=${DirScripts}/temp                                                    # Directory of Temp
DirBase=/backup/${Global_Name}                                                # Directory of Backup
DirRemote=""                                                                  #
DirFull=${DirBase}                                                            # Directory of Datapump on OS
DirArchive=${DirBase}                                                         # 
DirDatapump="backup"                                                          # Directory Name of Datapump
DirDtPump=${DirBase}/dump                                                     # Directory of Datapump
FormatFull="%T_DB_%d_DBID_%I_NB_%s.full"                                     # Format of Backup Files
FormatArch="%T_DB_%d_DBID_%I_NB_%s.arch"                                     # Format of Backup Files
FormatCTRL="%T_DB_%d_DBID_%I_NB_%s.ctrl"                                     # Format of Backup Files
FormatSPFile="%T_DB_%d_DBID_%I_NB_%s.spfile"                                 # Format of Backup Files
FormatIncLev0="%T_DB_%d_DBID_%I_NB_%s_inc_lev_0.incr"                        # Format of Backup Files
FormatIncLev1Diff="%T_DB_%d_DBID_%I_NB_%s_inc_lev_1.diff"                    # Format of Backup Files
FormatIncLev1Cum="%T_DB_%d_DBID_%I_NB_%s_inc_lev_1_cum.incr"                 # Format of Backup Files
FormatCopyDB="%T_DB_%d_DBID_%I_NB_%s.copydb"                                 # Format of Backup Files
FormatCopyDF="%T_DB_%d_DBID_%I_NB_%s_DATAFILE_${Options}.copydf"             # Format of Backup Files
FormatTBS="%T_DB_%d_DBID_%I_NB_%s_TBS_${Options}.tbs"                        # Format of Backup Files
FormatPDB="%T_DB_%d_DBID_%I_NB_%s_PDB_${Options}.pdb.full"                   # Format of Backup Files
LockFile=${DirScripts}/backup_${Global_Name}_${BackupType}.lock               # Lock File
LogFile=${DirLogs}/$(date +%Y%m%d_%H%M)_${Global_Name}_${BackupType}.log      # Log File
#
# "-------------------------------------------------------------------------------------------------------------"
# Show All Variables
# "-------------------------------------------------------------------------------------------------------------"
#
echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_HOME..........: ${ORACLE_HOME}"
echo "$(date +%Y%m%d_%H\:%M\:%S): ORATAB...............: ${ORATAB}"
echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_VERSION.......: ${DBVERSION}"
echo "$(date +%Y%m%d_%H\:%M\:%S): DATABASE_STATUS......: ${DBStatus}"
echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_ROLE..........: ${DDBROLE}"
echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_CLUSTER.......: ${ISRACDB}"
echo "$(date +%Y%m%d_%H\:%M\:%S): ORACLE_CONTAINER.....: ${ISCONTAINERDB}"
echo "$(date +%Y%m%d_%H\:%M\:%S): BIG_FILES............: ${ISBIGFILE}"
echo "$(date +%Y%m%d_%H\:%M\:%S): PARALLELISM..........: ${Parallelism}"
echo "$(date +%Y%m%d_%H\:%M\:%S): DATABASE_SIZE........: GB: ${DB_SIZEG} | TB: ${DB_SIZET}"
echo "$(date +%Y%m%d_%H\:%M\:%S): DEFAULT_DEVICE.......: ${DefaultDevice}"
echo "$(date +%Y%m%d_%H\:%M\:%S): COMPRESSION..........: ${Compression}"
echo "$(date +%Y%m%d_%H\:%M\:%S): BACKUP_SID...........: ${1}"
echo "$(date +%Y%m%d_%H\:%M\:%S): BACKUP_TYPE..........: ${2}"
echo "$(date +%Y%m%d_%H\:%M\:%S): BACKUP_OPTION........: ${3}"
#
# "-------------------------------------------------------------------------------------------------------------"
#
if [[ -d "${DirBase}" ]]; then
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): THE FOLDER DESTINATION EXISTS ON YOUR ENVIRONMENT"
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): DESTINATION FOLDER: ${DirBase}"
else
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): >>> YOUR FOLDER DESTINATION DOES NOT EXIST <<<"
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): CHECK YOUR FOLDERS AND TRY AGAIN"
  exit 1
fi
#
# "-------------------------------------------------------------------------------------------------------------"
#
if [[ -f "${LockFile}" ]]; then
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): >>> THE BACKUP IS ALREADY RUNNING <<<"
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): LOCK FILE: ${LockFile}"
  exit 1
else
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): >>> THE BACKUP WILL START NOW <<<"
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): LOCK FILE: ${LockFile}"
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): LOG FILE: ${LogFile}"
  SepLine
  touch ${LockFile}
  touch ${LogFile}
#
# "-------------------------------------------------------------------------------------------------------------"
#
case ${BackupType} in
FULL|Full|full)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL .................................... :: Report .......................... :: 1 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL .................................... :: Report .......................... :: 1 of 8 ]"; Report
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL .................................... :: ExecFullCrosscheck .............. :: 2 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL .................................... :: ExecFullCrosscheck .............. :: 2 of 8 ]"; ExecFullCrosscheck
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL .................................... :: ExecFull ........................ :: 3 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL .................................... :: ExecFull ........................ :: 3 of 8 ]"; ExecFull
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL .................................... :: ExecCTRL ........................ :: 4 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL .................................... :: ExecCTRL ........................ :: 4 of 8 ]"; ExecCTRL
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL .................................... :: ExecSPFile ...................... :: 5 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL .................................... :: ExecSPFile ...................... :: 5 of 8 ]"; ExecSPFile
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL .................................... :: ValidFull ....................... :: 6 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL .................................... :: ValidFull ....................... :: 6 of 8 ]"; ValidFull
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL .................................... :: ValidFullCheckLogical ........... :: 7 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL .................................... :: ValidFullCheckLogical ........... :: 7 of 8 ]"; ValidFullCheckLogical
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL .................................... :: ListFull ........................ :: 8 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL .................................... :: ListFull ........................ :: 8 of 8 ]"; ListFull
;;
FULLCLEAN|FullClean|fullclean)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL CLEAN .............................. :: ExecFullCrosscheck .............. :: 1 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL CLEAN .............................. :: ExecFullCrosscheck .............. :: 1 of 3 ]"; ExecFullCrosscheck
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL CLEAN .............................. :: ExecFullClean ................... :: 2 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL CLEAN .............................. :: ExecFullClean ................... :: 2 of 3 ]"; ExecFullClean
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL CLEAN .............................. :: ListFull ........................ :: 3 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL CLEAN .............................. :: ListFull ........................ :: 3 of 3 ]"; ListFull
;;
FULLARCHALL|FullArchAll|fullarchall)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL ARCHIVE ALL ........................ :: Report .......................... :: 1 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL ARCHIVE ALL ........................ :: Report .......................... :: 1 of 8 ]"; Report
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL ARCHIVE ALL ........................ :: ExecFullArchAllCrosscheck ....... :: 2 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL ARCHIVE ALL ........................ :: ExecFullArchAllCrosscheck ....... :: 2 of 8 ]"; ExecFullArchAllCrosscheck
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL ARCHIVE ALL ........................ :: ExecFullArchAll ................. :: 3 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL ARCHIVE ALL ........................ :: ExecFullArchAll ................. :: 3 of 8 ]"; ExecFullArchAll
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL ARCHIVE ALL ........................ :: ExecCTRL ........................ :: 4 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL ARCHIVE ALL ........................ :: ExecCTRL ........................ :: 4 of 8 ]"; ExecCTRL
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL ARCHIVE ALL ........................ :: ExecSPFile ...................... :: 5 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL ARCHIVE ALL ........................ :: ExecSPFile ...................... :: 5 of 8 ]"; ExecSPFile
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL ARCHIVE ALL ........................ :: ValidFullArchAll ................ :: 6 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL ARCHIVE ALL ........................ :: ValidFullArchAll ................ :: 6 of 8 ]"; ValidFullArchAll
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL ARCHIVE ALL ........................ :: ValidFullArchAllCheckLogical .... :: 7 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL ARCHIVE ALL ........................ :: ValidFullArchAllCheckLogical .... :: 7 of 8 ]"; ValidFullArchAllCheckLogical
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL ARCHIVE ALL ........................ :: ListFullArchAll ................. :: 8 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL ARCHIVE ALL ........................ :: ListFullArchAll ................. :: 8 of 8 ]"; ListFullArchAll
;;
FULLARCHALLCLEAN|FullArchAllClean|fullarchallclean)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL ARCHIVE ALL CLEAN .................. :: ExecFullArchAllCrosscheck ....... :: 1 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL ARCHIVE ALL CLEAN .................. :: ExecFullArchAllCrosscheck ....... :: 1 of 3 ]"; ExecFullArchAllCrosscheck
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL ARCHIVE ALL CLEAN .................. :: ExecFullArchAllClean ............ :: 2 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL ARCHIVE ALL CLEAN .................. :: ExecFullArchAllClean ............ :: 2 of 3 ]"; ExecFullArchAllClean
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL ARCHIVE ALL CLEAN .................. :: ListFullArchAll ................. :: 3 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ FULL ARCHIVE ALL CLEAN .................. :: ListFullArchAll ................. :: 3 of 3 ]"; ListFullArchAll
;;
ARCHALL|ArchAll|archall)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ ARCHIVE ALL ............................. :: Report .......................... :: 1 of 4 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ ARCHIVE ALL ............................. :: Report .......................... :: 1 of 4 ]"; Report
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ ARCHIVE ALL ............................. :: ExecArchAllCrosscheck ........... :: 2 of 4 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ ARCHIVE ALL ............................. :: ExecArchAllCrosscheck ........... :: 2 of 4 ]"; ExecArchAllCrosscheck
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ ARCHIVE ALL ............................. :: ExecArchAll ..................... :: 3 of 4 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ ARCHIVE ALL ............................. :: ExecArchAll ..................... :: 3 of 4 ]"; ExecArchAll
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ ARCHIVE ALL ............................. :: ListArchAll ..................... :: 4 of 4 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ ARCHIVE ALL ............................. :: ListArchAll ..................... :: 4 of 4 ]"; ListArchAll
;;
ARCHALLCLEAN|ArchAllClean|archallclean)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ ARCHIVE ALL CLEAN ....................... :: ExecArchAllCrosscheck ........... :: 1 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ ARCHIVE ALL CLEAN ....................... :: ExecArchAllCrosscheck ........... :: 1 of 3 ]"; ExecArchAllCrosscheck
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ ARCHIVE ALL CLEAN ....................... :: ExecArchAllClean ................ :: 2 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ ARCHIVE ALL CLEAN ....................... :: ExecArchAllClean ................ :: 2 of 3 ]"; ExecArchAllClean
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ ARCHIVE ALL CLEAN ....................... :: ListArchAll ..................... :: 3 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ ARCHIVE ALL CLEAN ....................... :: ListArchAll ..................... :: 3 of 3 ]"; ListArchAll
;;
INCLEV0|IncLev0|inclev0)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 0 ..................... :: Report .......................... :: 1 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 0 ..................... :: Report .......................... :: 1 of 8 ]"; Report
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 0 ..................... :: ExecIncLev0Crosscheck ........... :: 2 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 0 ..................... :: ExecIncLev0Crosscheck ........... :: 2 of 8 ]"; ExecIncLev0Crosscheck
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 0 ..................... :: ExecIncLev0 ..................... :: 3 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 0 ..................... :: ExecIncLev0 ..................... :: 3 of 8 ]"; ExecIncLev0
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 0 ..................... :: ExecCTRL ........................ :: 4 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 0 ..................... :: ExecCTRL ........................ :: 4 of 8 ]"; ExecCTRL
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 0 ..................... :: ExecSPFile ...................... :: 5 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 0 ..................... :: ExecSPFile ...................... :: 5 of 8 ]"; ExecSPFile
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 0 ..................... :: ValidIncLev0 .................... :: 6 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 0 ..................... :: ValidIncLev0 .................... :: 6 of 8 ]"; ValidIncLev0
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 0 ..................... :: ValidIncLev0Logical ............. :: 7 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 0 ..................... :: ValidIncLev0Logical ............. :: 7 of 8 ]"; ValidIncLev0Logical
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 0 ..................... :: ListIncLev0 ..................... :: 8 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 0 ..................... :: ListIncLev0 ..................... :: 8 of 8 ]"; ListIncLev0
;;
INCLEV0CLEAN|IncLev0Clean|inclev0clean)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 0 CLEAN ............... :: ExecIncLev0Crosscheck ........... :: 1 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 0 CLEAN ............... :: ExecIncLev0Crosscheck ........... :: 1 of 3 ]"; ExecIncLev0Crosscheck
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 0 CLEAN ............... :: ExecIncLev0Clean ................ :: 2 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 0 CLEAN ............... :: ExecIncLev0Clean ................ :: 2 of 3 ]"; ExecIncLev0Clean
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 0 CLEAN ............... :: ListIncLev0 ..................... :: 3 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 0 CLEAN ............... :: ListIncLev0 ..................... :: 3 of 3 ]"; ListIncLev0
;;
INCLEV1DIFF|IncLev1Diff|inclev1diff)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 DIFFERENTIAL ........ :: Report .......................... :: 1 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 DIFFERENTIAL ........ :: Report .......................... :: 1 of 8 ]"; Report
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 DIFFERENTIAL ........ :: ExecIncLev1DiffCrosscheck ....... :: 2 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 DIFFERENTIAL ........ :: ExecIncLev1DiffCrosscheck ....... :: 2 of 8 ]"; ExecIncLev1DiffCrosscheck
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 DIFFERENTIAL ........ :: ExecIncLev1Diff ................. :: 3 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 DIFFERENTIAL ........ :: ExecIncLev1Diff ................. :: 3 of 8 ]"; ExecIncLev1Diff
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 DIFFERENTIAL ........ :: ExecCTRL ........................ :: 4 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 DIFFERENTIAL ........ :: ExecCTRL ........................ :: 4 of 8 ]"; ExecCTRL
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 DIFFERENTIAL ........ :: ExecSPFile ...................... :: 5 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 DIFFERENTIAL ........ :: ExecSPFile ...................... :: 5 of 8 ]"; ExecSPFile
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 DIFFERENTIAL ........ :: ValidIncLev1Diff ................ :: 6 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 DIFFERENTIAL ........ :: ValidIncLev1Diff ................ :: 6 of 8 ]"; ValidIncLev1Diff
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 DIFFERENTIAL ........ :: ValidIncLev1DiffLogical ......... :: 7 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 DIFFERENTIAL ........ :: ValidIncLev1DiffLogical ......... :: 7 of 8 ]"; ValidIncLev1DiffLogical
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 DIFFERENTIAL ........ :: ListIncLev1Diff ................. :: 8 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 DIFFERENTIAL ........ :: ListIncLev1Diff ................. :: 8 of 8 ]"; ListIncLev1Diff
;;
INCLEV1DIFFCLEAN|IncLev1DiffClean|inclev1diffclean)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 DIFFERENTIAL CLEAN .. :: ExecIncLev1DiffCrosscheck ....... :: 1 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 DIFFERENTIAL CLEAN .. :: ExecIncLev1DiffCrosscheck ....... :: 1 of 3 ]"; ExecIncLev1DiffCrosscheck
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 DIFFERENTIAL CLEAN .. :: ExecIncLev1DiffClean ............ :: 2 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 DIFFERENTIAL CLEAN .. :: ExecIncLev1DiffClean ............ :: 2 of 3 ]"; ExecIncLev1DiffClean
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 DIFFERENTIAL CLEAN .. :: ListIncLev1Diff ................. :: 3 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 DIFFERENTIAL CLEAN .. :: ListIncLev1Diff ................. :: 3 of 3 ]"; ListIncLev1Diff
;;
INCLEV1CUM|IncLev1Cum|inclev1cum)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 CUMULATIVE .......... :: Report .......................... :: 1 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 CUMULATIVE .......... :: Report .......................... :: 1 of 8 ]"; Report
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 CUMULATIVE .......... :: ExecIncLev1CumCrosscheck ........ :: 2 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 CUMULATIVE .......... :: ExecIncLev1CumCrosscheck ........ :: 2 of 8 ]"; #ExecIncLev1CumCrosscheck
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 CUMULATIVE .......... :: ExecIncLev1Cum .................. :: 3 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 CUMULATIVE .......... :: ExecIncLev1Cum .................. :: 3 of 8 ]"; ExecIncLev1Cum
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 CUMULATIVE .......... :: ExecCTRL ........................ :: 4 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 CUMULATIVE .......... :: ExecCTRL ........................ :: 4 of 8 ]"; ExecCTRL
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 CUMULATIVE .......... :: ExecSPFile ...................... :: 5 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 CUMULATIVE .......... :: ExecSPFile ...................... :: 5 of 8 ]"; ExecSPFile
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 CUMULATIVE .......... :: ValidIncLev1Cum ................. :: 6 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 CUMULATIVE .......... :: ValidIncLev1Cum ................. :: 6 of 8 ]"; ValidIncLev1Cum
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 CUMULATIVE .......... :: ValidIncLev1CumLogical .......... :: 7 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 CUMULATIVE .......... :: ValidIncLev1CumLogical .......... :: 7 of 8 ]"; ValidIncLev1CumLogical
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 CUMULATIVE .......... :: ListIncLev1Cum .................. :: 8 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 CUMULATIVE .......... :: ListIncLev1Cum .................. :: 8 of 8 ]"; ListIncLev1Cum
;;
INCLEV1CUMCLEAN|IncLev1CumClean|inclev1cumclean)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 CUMULATIVE CLEAN .... :: ExecIncLev1CumCrosscheck ........ :: 1 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 CUMULATIVE CLEAN .... :: ExecIncLev1CumCrosscheck ........ :: 1 of 3 ]"; ExecIncLev1CumCrosscheck
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 CUMULATIVE CLEAN .... :: ExecIncLev1CumClean ............. :: 2 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 CUMULATIVE CLEAN .... :: ExecIncLev1CumClean ............. :: 2 of 3 ]"; ExecIncLev1CumClean
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 CUMULATIVE CLEAN .... :: ListIncLev1Cum .................. :: 3 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ INCREMENTAL LEVEL 1 CUMULATIVE CLEAN .... :: ListIncLev1Cum .................. :: 3 of 3 ]"; ListIncLev1Cum
;;
COPYDB|CopyDB|copydb)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATABASE ........................... :: Report .......................... :: 1 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATABASE ........................... :: Report .......................... :: 1 of 8 ]"; Report
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATABASE ........................... :: ExecCopyDBCrosscheck ............ :: 2 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATABASE ........................... :: ExecCopyDBCrosscheck ............ :: 2 of 8 ]"; ExecCopyDBCrosscheck
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATABASE ........................... :: ExecCopyDB ...................... :: 3 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATABASE ........................... :: ExecCopyDB ...................... :: 3 of 8 ]"; ExecCopyDB
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATABASE ........................... :: ExecCTRL ........................ :: 4 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATABASE ........................... :: ExecCTRL ........................ :: 4 of 8 ]"; ExecCTRL
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATABASE ........................... :: ExecSPFile ...................... :: 5 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATABASE ........................... :: ExecSPFile ...................... :: 5 of 8 ]"; ExecSPFile
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATABASE ........................... :: ValidCopyDB ..................... :: 6 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATABASE ........................... :: ValidCopyDB ..................... :: 6 of 8 ]"; ValidCopyDB
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATABASE ........................... :: ValidCopyDBLogical .............. :: 7 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATABASE ........................... :: ValidCopyDBLogical .............. :: 7 of 8 ]"; ValidCopyDBLogical
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATABASE ........................... :: ListCopyDB ...................... :: 8 of 8 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATABASE ........................... :: ListCopyDB ...................... :: 8 of 8 ]"; ListCopyDB
;;
COPYDBCLEAN|CopyDBClean|copydbclean)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATABASE CLEAN ..................... :: ExecCopyDBCrosscheck ............ :: 1 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATABASE CLEAN ..................... :: ExecCopyDBCrosscheck ............ :: 1 of 3 ]"; ExecCopyDBCrosscheck
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATABASE CLEAN ..................... :: ExecCopyDBClean ................. :: 2 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATABASE CLEAN ..................... :: ExecCopyDBClean ................. :: 2 of 3 ]"; ExecCopyDBClean
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATABASE CLEAN ..................... :: ListCopyDB ...................... :: 3 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATABASE CLEAN ..................... :: ListCopyDB ...................... :: 3 of 3 ]"; ListCopyDB
;;
COPYDF|CopyDF|copydf)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATAFILE ........................... :: Report .......................... :: 1 of 9 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATAFILE ........................... :: Report .......................... :: 1 of 9 ]"; Report
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATAFILE ........................... :: ExecCopyDFCrosscheck ............ :: 2 of 9 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATAFILE ........................... :: ExecCopyDFCrosscheck ............ :: 2 of 9 ]"; ExecCopyDFCrosscheck
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATAFILE ........................... :: ExecCopyDF ...................... :: 3 of 9 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATAFILE ........................... :: ExecCopyDF ...................... :: 3 of 9 ]"; ExecCopyDF
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATAFILE ........................... :: ExecCTRL ........................ :: 4 of 9 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATAFILE ........................... :: ExecCTRL ........................ :: 4 of 9 ]"; ExecCTRL
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATAFILE ........................... :: ExecSPFile ...................... :: 5 of 9 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATAFILE ........................... :: ExecSPFile ...................... :: 5 of 9 ]"; ExecSPFile
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATAFILE ........................... :: ValidCopyDF ..................... :: 7 of 9 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATAFILE ........................... :: ValidCopyDF ..................... :: 7 of 9 ]"; ValidCopyDF
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATAFILE ........................... :: ValidCopyDFLogical .............. :: 8 of 9 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATAFILE ........................... :: ValidCopyDFLogical .............. :: 8 of 9 ]"; ValidCopyDFLogical
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATAFILE ........................... :: ListCopyDF ...................... :: 9 of 9 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATAFILE ........................... :: ListCopyDF ...................... :: 9 of 9 ]"; ListCopyDF
;;
COPYDFCLEAN|CopyDFClean|copydfclean)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATAFILE CLEAN ..................... :: ExecCopyDFCrosscheck ............ :: 1 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATAFILE CLEAN ..................... :: ExecCopyDFCrosscheck ............ :: 1 of 3 ]"; ExecCopyDFCrosscheck
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATAFILE CLEAN ..................... :: ExecCopyDFClean ................. :: 2 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATAFILE CLEAN ..................... :: ExecCopyDFClean ................. :: 2 of 3 ]"; ExecCopyDFClean
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATAFILE CLEAN ..................... :: ListCopyDF ...................... :: 3 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ COPY DATAFILE CLEAN ..................... :: ListCopyDF ...................... :: 3 of 3 ]"; ListCopyDF
;;
SPFILE|SPFile|spfile)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ SPFILE .................................. :: ExecSPFileCrosscheck ............ :: 1 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ SPFILE .................................. :: ExecSPFileCrosscheck ............ :: 1 of 3 ]"; ExecSPFileCrosscheck
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ SPFILE .................................. :: ExecSPFile ...................... :: 2 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ SPFILE .................................. :: ExecSPFile ...................... :: 2 of 3 ]"; ExecSPFile
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ SPFILE .................................. :: ListSPFile ...................... :: 3 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ SPFILE .................................. :: ListSPFile ...................... :: 3 of 3 ]"; ListSPFile
;;
SPFILECLEAN|SPFileClean|spfileclean)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ SPFILE CLEAN ............................ :: ExecSPFileCrosscheck ............ :: 1 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ SPFILE CLEAN ............................ :: ExecSPFileCrosscheck ............ :: 1 of 3 ]"; ExecSPFileCrosscheck
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ SPFILE CLEAN ............................ :: ExecSPFileClean ................. :: 2 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ SPFILE CLEAN ............................ :: ExecSPFileClean ................. :: 2 of 3 ]"; ExecSPFileClean
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ SPFILE CLEAN ............................ :: ListSPFile ...................... :: 3 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ SPFILE CLEAN ............................ :: ListSPFile ...................... :: 3 of 3 ]"; ListSPFile
;;
CTRL|Ctrl|ctrl)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ CONTROLFILE ............................. :: ExecCTRLCrosscheck .............. :: 1 of 4 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ CONTROLFILE ............................. :: ExecCTRLCrosscheck .............. :: 1 of 4 ]"; ExecCTRLCrosscheck
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ CONTROLFILE ............................. :: ExecCTRL ........................ :: 2 of 4 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ CONTROLFILE ............................. :: ExecCTRL ........................ :: 2 of 4 ]"; ExecCTRL
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ CONTROLFILE ............................. :: ValidCTRL ....................... :: 3 of 4 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ CONTROLFILE ............................. :: ValidCTRL ....................... :: 3 of 4 ]"; ValidCTRL
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ CONTROLFILE ............................. :: ListCTRL ........................ :: 4 of 4 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ CONTROLFILE ............................. :: ListCTRL ........................ :: 4 of 4 ]"; ListCTRL
;;
CTRLCLEAN|CTRLClean|ctrlclean)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ CONTROLFILE CLEAN ....................... :: ExecCTRLCrosscheck .............. :: 1 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ CONTROLFILE CLEAN ....................... :: ExecCTRLCrosscheck .............. :: 1 of 3 ]"; ExecCTRLCrosscheck
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ CONTROLFILE CLEAN ....................... :: ExecCTRLClean ................... :: 2 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ CONTROLFILE CLEAN ....................... :: ExecCTRLClean ................... :: 2 of 3 ]"; ExecCTRLClean
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ CONTROLFILE CLEAN ....................... :: ListCTRL ........................ :: 3 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ CONTROLFILE CLEAN ....................... :: ListCTRL ........................ :: 3 of 3 ]"; ListCTRL
;;
TBS|TBS|tbs)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ TABLESPACE .............................. :: ExecTBS ......................... :: 1 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ TABLESPACE .............................. :: ExecTBS ......................... :: 1 of 3 ]"; ExecTBS
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ TABLESPACE .............................. :: ValidTBS ........................ :: 2 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ TABLESPACE .............................. :: ValidTBS ........................ :: 2 of 3 ]"; ValidTBS
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ TABLESPACE .............................. :: ListTBS ......................... :: 3 of 3 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ TABLESPACE .............................. :: ListTBS ......................... :: 3 of 3 ]"; ListTBS
;;
PDB|Pdb|pdb)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ PLUGGABLE ............................... :: Report .......................... :: 1 of 9 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ PLUGGABLE ............................... :: Report .......................... :: 1 of 9 ]"; Report
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ PLUGGABLE ............................... :: ExecPDBCrosscheck ............... :: 2 of 9 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ PLUGGABLE ............................... :: ExecPDBCrosscheck ............... :: 2 of 9 ]"; ExecPDBCrosscheck
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ PLUGGABLE ............................... :: ExecPDB ......................... :: 3 of 9 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ PLUGGABLE ............................... :: ExecPDB ......................... :: 3 of 9 ]"; ExecPDB
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ PLUGGABLE ............................... :: ExecCTRL ........................ :: 4 of 9 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ PLUGGABLE ............................... :: ExecCTRL ........................ :: 4 of 9 ]"; ExecCTRL
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ PLUGGABLE ............................... :: ExecSPFile ...................... :: 5 of 9 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ PLUGGABLE ............................... :: ExecSPFile ...................... :: 5 of 9 ]"; ExecSPFile
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ PLUGGABLE ............................... :: ValidPDB ........................ :: 7 of 9 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ PLUGGABLE ............................... :: ValidPDB ........................ :: 7 of 9 ]"; ValidPDB
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ PLUGGABLE ............................... :: ValidPDBLogical ................. :: 8 of 9 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ PLUGGABLE ............................... :: ValidPDBLogical ................. :: 8 of 9 ]"; ValidPDBLogical
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ PLUGGABLE ............................... :: ListPDB ......................... :: 9 of 9 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ PLUGGABLE ............................... :: ListPDB ......................... :: 9 of 9 ]"; ListPDB
;;
CROSSCHECK|Crosscheck|crosscheck)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ CROSSCHECK .............................. :: ExecCrosscheck .................. :: 1 of 1 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ CROSSCHECK .............................. :: ExecCrosscheck .................. :: 1 of 1 ]"; ExecCrosscheck
;;
CLEANALL|CleanAll|cleanall)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ CLEAN ALL ............................... :: ExecCrosscheck .................. :: 1 of 2 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ CLEAN ALL ............................... :: ExecCrosscheck .................. :: 1 of 2 ]"; ExecCrosscheck
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ CLEAN ALL ............................... :: ExecCleanAll .................... :: 2 of 2 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ CLEAN ALL ............................... :: ExecCleanAll .................... :: 2 of 2 ]"; ExecCleanAll
;;
REPORT|Report|report)
  echo -e ">---------------------------------------------------------------------------------------------------------------------"   >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ REPORT .................................. :: Report .......................... ::  1 of 12 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ REPORT .................................. :: Report .......................... ::  1 of 12 ]"; Report
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ REPORT .................................. :: ListBackupSummary ............... ::  2 of 12 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ REPORT .................................. :: ListBackupSummary ............... ::  2 of 12 ]"; ListBackupSummary
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ REPORT .................................. :: ReportObsolete .................. ::  3 of 12 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ REPORT .................................. :: ReportObsolete .................. ::  3 of 12 ]"; ReportObsolete
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ REPORT .................................. :: ListFailures .................... ::  4 of 12 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ REPORT .................................. :: ListFailures .................... ::  4 of 12 ]"; ListFailures
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ REPORT .................................. :: ListFailuresClosed .............. ::  5 of 12 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ REPORT .................................. :: ListFailuresClosed .............. ::  5 of 12 ]"; ListFailuresClosed
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ REPORT .................................. :: AdviseFailures .................. ::  6 of 12 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ REPORT .................................. :: AdviseFailures .................. ::  6 of 12 ]"; AdviseFailures
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ REPORT .................................. :: RepairFailures .................. ::  7 of 12 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ REPORT .................................. :: RepairFailures .................. ::  7 of 12 ]"; RepairFailures
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ REPORT .................................. :: RestoreValidateDatabase ......... ::  8 of 12 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ REPORT .................................. :: RestoreValidateDatabase ......... ::  8 of 12 ]"; RestoreValidateDatabase
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ REPORT .................................. :: RestoreDatabasePreview .......... ::  9 of 12 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ REPORT .................................. :: RestoreDatabasePreview .......... ::  9 of 12 ]"; RestoreDatabasePreview
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ REPORT .................................. :: RestoreDatabasePreviewSummary ... :: 10 of 12 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ REPORT .................................. :: RestoreDatabasePreviewSummary ... :: 10 of 12 ]"; RestoreDatabasePreviewSummary
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ REPORT .................................. :: RecoverDatabasePreview .......... :: 11 of 12 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ REPORT .................................. :: RecoverDatabasePreview .......... :: 11 of 12 ]"; RecoverDatabasePreview
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ REPORT .................................. :: RecoverDatabasePreviewSummary ... :: 12 of 12 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ REPORT .................................. :: RecoverDatabasePreviewSummary ... :: 12 of 12 ]"; RecoverDatabasePreviewSummary
;;
RESTOREDATABASEPREVIEW|RestoreDatabasePreview|restoredatabasepreview)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ RESTORE DATABASE PREVIEW ................ :: RestoreDatabasePreview .......... :: 1 of 2 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ RESTORE DATABASE PREVIEW ................ :: RestoreDatabasePreview .......... :: 1 of 2 ]"  RestoreDatabasePreview
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ RESTORE DATABASE PREVIEW ................ :: RestoreDatabasePreviewSummary ... :: 2 of 2 ]" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ RESTORE DATABASE PREVIEW ................ :: RestoreDatabasePreviewSummary ... :: 2 of 2 ]"; RestoreDatabasePreviewSummary
;;
RECOVERDATABASEPREVIEW|RecoverDatabasePreview|recoverdatabasepreview)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ RECOVER DATABASE PREVIEW ................ :: RecoverDatabasePreview .......... :: 1 of 2 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ RECOVER DATABASE PREVIEW ................ :: RecoverDatabasePreview .......... :: 1 of 2 ]"; RecoverDatabasePreview
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ RECOVER DATABASE PREVIEW ................ :: RecoverDatabasePreviewSummary ... :: 2 of 2 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ RECOVER DATABASE PREVIEW ................ :: RecoverDatabasePreviewSummary ... :: 2 of 2 ]"; RecoverDatabasePreviewSummary
;;
DATAPUMP|DataPump|datapump)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ DATAPUMP ................................ :: ExecDataPump .................... :: 1 of 2 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ DATAPUMP ................................ :: ExecDataPump .................... :: 1 of 2 ]"; ExecDataPump
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ DATAPUMP ................................ :: ListDataPump .................... :: 2 of 2 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ DATAPUMP ................................ :: ListDataPump .................... :: 2 of 2 ]"; ListDataPump
;;
DATAPUMPCLEAN|DataPumpClean|datapumpclean)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ DATAPUMP CLEAN .......................... :: ExecDataPumpClean ............... :: 1 of 2 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ DATAPUMP CLEAN .......................... :: ExecDataPumpClean ............... :: 1 of 2 ]"; ExecDataPumpClean
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ DATAPUMP CLEAN .......................... :: ListDataPump .................... :: 2 of 2 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ DATAPUMP CLEAN .......................... :: ListDataPump .................... :: 2 of 2 ]"; ListDataPump
;;
DATAPUMPCONFIG|DataPumpConfig|datapumpconfig)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ DATAPUMP CONFIG ......................... :: DataPumpConfig .................. :: 1 of 1 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ DATAPUMP CONFIG ......................... :: DataPumpConfig .................. :: 1 of 1 ]"; DataPumpConfig
;;
DATAPUMPSHOWCONFIG|DataPumpShowConfig|datapumpshowconfig)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ DATAPUMP SHOW CONFIG .................... :: DataPumpShowConfig .............. :: 1 of 1 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ DATAPUMP SHOW CONFIG .................... :: DataPumpShowConfig .............. :: 1 of 1 ]"; DataPumpShowConfig
;;
RMANSETCONFIG|RMANSetConfig|rmansetconfig)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ RMAN SET CONFIG ......................... :: RMANSetConfig ................... :: 1 of 1 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ RMAN SET CONFIG ......................... :: RMANSetConfig ................... :: 1 of 1 ]"; RMANSetConfig
;;
RMANRESETCONFIG|RMANReSetConfig|rmanresetconfig)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ RMAN RESET CONFIG ....................... :: RMANReSetConfig ................. :: 1 of 1 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ RMAN RESET CONFIG ....................... :: RMANReSetConfig ................. :: 1 of 1 ]"; RMANReSetConfig
;;
RMANSHOWCONFIG|RMANShowConfig|rmanshowconfig)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ RMAN SHOW CONFIG ........................ :: RMANShowConfig .................. :: 1 of 1 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ RMAN SHOW CONFIG ........................ :: RMANShowConfig .................. :: 1 of 1 ]"; RMANShowConfig
;;
H|h)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ HELP .................................... :: Help ............................ :: 1 of 1 ]"  >> ${LogFile}
  echo "$(date +%Y%m%d_%H\:%M\:%S): [ HELP .................................... :: Help ............................ :: 1 of 1 ]"; Help
;;
*)
  echo -e ">---------------------------------------------------------------------------------------------------------------------" >> ${LogFile}
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): ONLY VALID OPTIONS on help"
  sleep 3
;;
esac
#
#########################################################################################################
#
# "-------------------------------------------------------------------------------------------------------------"
# Removing The Lock File
# "-------------------------------------------------------------------------------------------------------------"
#
SepLine
echo "$(date +%Y%m%d_%H\:%M\:%S): REMOVING THE LOCK FILE"
rm ${LockFile}
#
#########################################################################################################
#
# "-------------------------------------------------------------------------------------------------------------"
# Showing The Backup Destination Place
# "-------------------------------------------------------------------------------------------------------------"
#
if [[ "${DefaultDevice}" == "DISK" ]]; then
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): >>> THE BACKUP FINISHED NOW <<<"
  echo "$(date +%Y%m%d_%H\:%M\:%S): THE BACKUP FILES ARE ON THIS PLACE: ${DirBase}"
else
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): >>> THE BACKUP FINISHED NOW <<<"
  echo "$(date +%Y%m%d_%H\:%M\:%S): THE BACKUP FILES ARE ON THIS PLACE: ${DefaultDevice}"
fi
#
fi
#
#########################################################################################################
#
# "-------------------------------------------------------------------------------------------------------------"
# Verify Log
# "-------------------------------------------------------------------------------------------------------------"
#
Errors=$(cat ${LogFile} | egrep -i "error|warning|ora-|rman-|fatal|failed" | wc -l)
if [[ "${Errors}" == 0 ]]; then
  DATE=$(date +%Y%m%d_%H%M)
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): >>> EXECUTING VERIFICATION OF LOG RESULTS <<<"
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): >>> THERE IS NO ERRORS ON YOUR BACKUP EXECUTION <<<"
else
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): >>> EXECUTING VERIFICATION OF LOG RESULTS <<<"
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): SUMMARY...: ${Errors}"
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): ERROR.....: $(cat ${LogFile} | egrep -i "error" | wc -l)"
  echo "$(date +%Y%m%d_%H\:%M\:%S): FAILED....: $(cat ${LogFile} | egrep -i "failed" | wc -l)"
  echo "$(date +%Y%m%d_%H\:%M\:%S): FATAL.....: $(cat ${LogFile} | egrep -i "fatal" | wc -l)"
  echo "$(date +%Y%m%d_%H\:%M\:%S): WARNING...: $(cat ${LogFile} | egrep -i "warning" | wc -l)"
  echo "$(date +%Y%m%d_%H\:%M\:%S): ORA-%.....: $(cat ${LogFile} | egrep -i "ora-" | wc -l)"
  echo "$(date +%Y%m%d_%H\:%M\:%S): RMAN-%....: $(cat ${LogFile} | egrep -i "rman-" | wc -l)"
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): THERE IS ${Errors} ERRORS ON YOUR BACKUP EXECUTION, PLEASE VERIFY YOUR BACKUP"
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): Finished Verification of Log Results"
fi
SepLine
echo "$(date +%Y%m%d_%H\:%M\:%S): LOG FILE: ${LogFile}"
SepLine
echo "$(date +%Y%m%d_%H\:%M\:%S): COMPRESSED LOG FILE: ${LogFile}.bz2"
#
#########################################################################################################
#
# "-------------------------------------------------------------------------------------------------------------"
# Compressing Logfile
# "-------------------------------------------------------------------------------------------------------------"
#
bzip2 -9 ${LogFile}
#
#########################################################################################################
#
# "-------------------------------------------------------------------------------------------------------------"
# Sending Logfile
# "-------------------------------------------------------------------------------------------------------------"
#
if [[ "${SendMail}" == "Y" ]]; then
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): SENDING COMPRESSED LOGFILE TO: ${EMAIL_2}"
  SepLine
  mail -s "${LogFile}.bz2" -a ${LogFile}.bz2 ${EMAIL_2} < ${LogFile}.bz2 ${EMAIL_2}
else
  SepLine
  echo "$(date +%Y%m%d_%H\:%M\:%S): THERE IS NO CONFIGURED EMAIL TO SEND"
fi
#
#########################################################################################################
#
# "-------------------------------------------------------------------------------------------------------------"
# Finishing The Backup Execution
# "-------------------------------------------------------------------------------------------------------------"
#
EndTime=$(date +%s)
TotalTime=$((${EndTime}-${StartTime}))
TotalDays=$(((${EndTime}-${StartTime})/60/60/24))
TotalHours=$(((${EndTime}-${StartTime})/60/60))
TotalMin=$(((${EndTime}-${StartTime})/60))
TotalSec=$((${EndTime}-${StartTime}))
SepLine
echo "$(date +%Y%m%d_%H\:%M\:%S): THE BACKUP EXECUTION TOOK: DAYS: ${TotalDays} | HOURS: ${TotalHours} | MINUTES: ${TotalMin} | SECONDS: ${TotalSec}"
SepLine
echo "$(date +%Y%m%d_%H\:%M\:%S): >>> FINISHED <<<"
SepLine
#
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
# THE SCRIPT FINISHES HERE
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
#
