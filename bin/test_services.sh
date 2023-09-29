function func_db_068() 
{
if [ "${GRID_HOME}" = "" ]
then
  echo ">--------------------------------------------------------------------------------------------------"
  echo " -- THE GRID_HOME WAS NOT CONFIGURED YET OR YOU ARE NOT USING GRID INFRASTRUCTURE --"
  echo ">--------------------------------------------------------------------------------------------------"
else
if [ `uname` = "SunOS" ]
then
  echo ">--------------------------------------------------------------------------------------------------"
  echo "Solaris"
  echo ">--------------------------------------------------------------------------------------------------"
elif [ `uname` = "AIX" ]
then
  echo ">--------------------------------------------------------------------------------------------------"
  echo "AIX"
  echo ">--------------------------------------------------------------------------------------------------"
elif [ `uname` = "HP-UX" ]
then
  echo ">--------------------------------------------------------------------------------------------------"
  echo "HP-UX"
  echo ">--------------------------------------------------------------------------------------------------"
elif [ `uname` = "Linux" ]
then
  echo ">--------------------------------------------------------------------------------------------------"
  echo "Linux"
  echo ">--------------------------------------------------------------------------------------------------"
  hash ccrsctl &> /dev/null
if [ $? -eq 1 ]
then
  echo ">--------------------------------------------------------------------------------------------------"
  echo " -- GRID INFRASTRUTURE WAS NOT FOUNDED --"
  echo ">--------------------------------------------------------------------------------------------------"
else
  ccrsctl=`which crsctl`
fi
if [ -f $ccrsctl ]
then
# ********* ENV VARIABLES *********
# MODIFY AS NEEDED ................
# *********************************
AWKCMD=`which awk | grep -v -i "alias"`;
GREPCMD=`which egrep | grep -v -i "alias"`;
SEDCMD=`which sed | grep -v -i "alias"`;
CATCMD=`which cat | grep -v -i "alias"`;
WCCMD=`which wc | grep -v -i "alias"`;
TRCMD=`which tr | grep -v -i "alias"`;
SORTCMD=`which sort | grep -v -i "alias"`;
ECHOCMD=`which echo | grep -v -i "alias"`;
PRINTFCMD=`which printf | grep -v -i "alias"`;
COLUMNCMD=`which column | grep -v -i "alias"`;
# ********* ENV VARIABLES *********
# Do NOT MODIFY....................
TODAY=`date +%d.%m.%Y`;
ORACLE_USER=`ls -alr ${GRID_HOME}/bin/sqlplus | ${AWKCMD} '{print $3}'`;
PATH_SET=${PATH};
# *********** COLOR CONTRAST ***********
# Change DISPLAY COLOR CODE for LOOK and FEEL..
# Keep the Format the same as "nnnm"...........
# NOTE: COLOR CODE's are available online SEARCH for "SHELL COLOR CODES"...
# KEEP COLOR options to FOREGROUND TEXT onl
HEADER_COLR='34m';
TRAILER_COLR='34m';
TAB_HEAD_COLR='33m';
TAB_TEXT_COLR='92m';
ALRT_COLR='31m';
DB_INST_COLR='34m';
SHELL_PROMPT_COLR='37m';
# *********** CODE BODY ******************************************************************
binary_setup()
{
  CRS_VERSION=`${GRID_HOME}/OPatch/opatch lsinventory | ${GREPCMD} "Oracle Database" | tail -1 | ${AWKCMD} '{print $(NF-0)}'`;
}
crsstat()
{
CHECK_RESOURCE=$1;
if [[ -z ${CHECK_RESOURCE} ]]
then
  CHECK_RESOURCE='';
else
  CHECK_RESOURCE=$1;
fi;
if [[ ${CHECK_RESOURCE} = 'h' ]]
then
${PRINTFCMD} "COLOR CODES:";
${PRINTFCMD} " \e[${HEADER_COLR}";
${PRINTFCMD} " \e[${TAB_HEAD_COLR}";
${PRINTFCMD} " \e[${TAB_HEAD_COLR}HEADER\e[${HEADER_COLR} ";
${PRINTFCMD} " \e[${TAB_TEXT_COLR}CONTENT\e[${TAB_TEXT_COLR} ";
${PRINTFCMD} " \e[${ALRT_COLR}ALERT\e[${ALRT_COLR} ";
${PRINTFCMD} " \e[${DB_INST_COLR}ORACLE_SID\e[${TRAILER_COLR} \n";
${ECHOCMD} "--------------------------------------------------------------------------------------------------";
${PRINTFCMD} "\e[${TAB_TEXT_COLR}\n";
${CATCMD} $0 | ${GREPCMD} "HELP:" | ${GREPCMD} -v "GREPCMD" | ${SEDCMD} 's/^.*crsstat/crsstat/g';
${PRINTFCMD} "\e[${TRAILER_COLR}\n";
${ECHOCMD} "--------------------------------------------------------------------------------------------------";
${PRINTFCMD} "\e[${SHELL_PROMPT_COLR}";
fi;
if [[ ${CHECK_RESOURCE} = 'res' ]]
then
V_RESOURCE_TYPE=`${GRID_HOME}/bin/crsctl status resource -p | \
${GREPCMD} "^NAME|^TYPE\=|^GEN_USR_ORA_INST_NAME@SERVERNAME|^VERSION=|^SERVICE_NAME=|DESCRIPTION=" | \
${SEDCMD} 's/^/|/g' | ${SEDCMD} 's/$/|/g' | ${TRCMD} "\n" " " | ${SEDCMD} 's/| |/|/g' | \
${SEDCMD} 's/| $//g' | ${SEDCMD} 's/|NAME/\n|NAME/g' | ${SEDCMD} 's/TYPE=ora./TYPE=/g' | ${SEDCMD} 's/.type//g' | \
${SORTCMD} -t'|' -k3 | ${SEDCMD} '/^$/d' | ${SEDCMD} 's/GEN_USR_ORA_INST_NAME\@SERVERNAME//g' | \
${SEDCMD} "s/TYPE=//g;s/DESCRIPTION=//g" | ${SEDCMD} 's/|!!!|/|NA|/g' | ${SEDCMD} 's/$/!!!/g' | \
${AWKCMD} -F\| '{print "|"$3"|"$4"|!!!"}' | ${SEDCMD} 's/|!!!|/|NO DESCRIPTION|/g' | ${SEDCMD} 's/\"//g' | \
${SORTCMD} -u`;
V_CRSP_COL_NAME='|RESOURCE_TYPE|DESCRIPTION|!!!';
V_CRSP_COL_LINE='|-------------|-----------|!!!';
${PRINTFCMD} "\e[${HEADER_COLR}\n";
${ECHOCMD} "--------------------------------------------------------------------------------------------------";
${PRINTFCMD} "\e[${TAB_HEAD_COLR}";
${PRINTFCMD} " CRSSTAT RESOURCE LIST ";
${PRINTFCMD} "\e[${HEADER_COLR}";
${ECHOCMD} "--------------------------------------------------------------------------------------------------";
${PRINTFCMD} "\e[${TAB_HEAD_COLR}";
${PRINTFCMD} "..::COLOR CODES:";
${PRINTFCMD} "\e[${HEADER_COLR}";
${PRINTFCMD} " \e[${TAB_HEAD_COLR}HEADER\e[${HEADER_COLR} ";
${PRINTFCMD} " \e[${TAB_TEXT_COLR}CONTENT\e[${TAB_TEXT_COLR} ";
${PRINTFCMD} " \e[${ALRT_COLR}ALERT\e[${ALRT_COLR} ";
${PRINTFCMD} " \e[${DB_INST_COLR}ORACLE_SID\e[${TRAILER_COLR} \n";
${ECHOCMD} "--------------------------------------------------------------------------------------------------";
V_RESOURCE_TYPE=`${ECHOCMD} ${V_CRSP_COL_NAME} ${V_CRSP_COL_LINE} ${V_RESOURCE_TYPE}`;
${PRINTFCMD} "\e[${TAB_TEXT_COLR}\n";
${ECHOCMD} ${V_RESOURCE_TYPE} | \
${SEDCMD} 's/[ ]\+|/|/g' | \
${SEDCMD} 's/!!!/\n/g' | \
${COLUMNCMD} -s"|" -t;
${PRINTFCMD} "\e[${TRAILER_COLR}\n";
${ECHOCMD} "--------------------------------------------------------------------------------------------------";
${PRINTFCMD} "\e[${SHELL_PROMPT_COLR}";
elif [[ ${CHECK_RESOURCE} != 'h' ]]
then
V_CRSP=`${GRID_HOME}/bin/crsctl status resource -p | \
${GREPCMD} "^NAME|^TYPE\=|^GEN_USR_ORA_INST_NAME@SERVERNAME|^VERSION=|^SERVICE_NAME=|SERVER_POOLS=" | \
${SEDCMD} 's/^/|/g' | ${SEDCMD} 's/$/|/g' | ${TRCMD} "\n" " " | ${SEDCMD} 's/| |/|/g' | \
${SEDCMD} 's/| $//g' | ${SEDCMD} 's/|NAME/\n|NAME/g' | ${SEDCMD} 's/TYPE=ora./TYPE=/g' | ${SEDCMD} 's/.type//g' | \
${SORTCMD} -t'|' -k3 | ${SEDCMD} '/^$/d' | ${SEDCMD} 's/GEN_USR_ORA_INST_NAME\@SERVERNAME//g' | ${SEDCMD} 's/$/!!!/g' | \
${GREPCMD} "${CHECK_RESOURCE}"`;
V_CRSV=`${GRID_HOME}/bin/crsctl status resource -v | \
${GREPCMD} "^NAME=|^TYPE=|^LAST_RESTART=|^STATE=|^TARGET=|^INTERNAL_STATE=" | \
${SEDCMD} 's/^/|/g' | ${SEDCMD} 's/$/|/g' | ${TRCMD} "\n" " " | ${SEDCMD} 's/| |/|/g' | \
${SEDCMD} 's/|NAME/\n|NAME/g' | ${SEDCMD} 's/TYPE=ora./TYPE=/g' | ${SEDCMD} 's/.type//g' | \
${SORTCMD} -t'|' -k3 | ${SEDCMD} '/^$/d' | ${SEDCMD} 's/$/!!!|/g' | \
${GREPCMD} "${CHECK_RESOURCE}"`;
# Database RESOURCES
for resource in `${ECHOCMD} ${V_CRSP}`
do
V_NAME=`${ECHOCMD} ${resource} | ${AWKCMD} -F \| '{print $2}'`;
V_TYPE=`${ECHOCMD} ${resource} | ${AWKCMD} -F \| '{print $3}'`;
V_VERSION=`${ECHOCMD} ${resource} | ${AWKCMD} -F\| '{print $NF}' | ${SEDCMD} 's/!!!//g'`;
V_RESOURCE=`${ECHOCMD} ${resource} | ${SEDCMD} 's/|'${V_NAME}'//g' | ${SEDCMD} 's/|'${V_TYPE}'//g' | ${SEDCMD} 's/'${V_VERSION}'//g'`;
V_ORIGINAL=`${ECHOCMD} ${V_CRSV} | ${SEDCMD} 's/!!!|/\n/g' | ${GREPCMD} ${V_NAME}`;
V_REPLACE=`${ECHOCMD} ${V_ORIGINAL}`;
if [[ `${ECHOCMD} ${V_REPLACE} | ${GREPCMD} "asm|database" | ${WCCMD} -l` -gt 0 ]]
then
for v_host_inst in `${ECHOCMD} ${V_RESOURCE} | ${SEDCMD} 's/|/ /g' | ${SEDCMD} 's/!!!//g'`
do
HOST_NAME=`${ECHOCMD} ${v_host_inst} | ${SEDCMD} 's/=/ /g' | ${SEDCMD} "s/(//g;s/)//g" | ${AWKCMD} '{print $1}'`;
INST_NAME=`${ECHOCMD} ${v_host_inst} | ${SEDCMD} 's/=/ /g' | ${AWKCMD} '{print $2}'`;
V_REPLACE=`${ECHOCMD} ${V_REPLACE} | ${SEDCMD} -e 's/'${HOST_NAME}'/'${HOST_NAME}' \('${INST_NAME}'\)/g'`;
done;
V_REPLACE=`${ECHOCMD} ${V_REPLACE} | ${SEDCMD} "s/|/|${V_VERSION}|/3"`;
elif [[ `${ECHOCMD} ${V_REPLACE} | ${GREPCMD} "dbfs" | ${WCCMD} -l` -gt 0 ]]
then
V_REPLACE=`${ECHOCMD} ${V_REPLACE} | ${SEDCMD} "s/|/|NA|/3"`;
else
V_REPLACE=`${ECHOCMD} ${V_REPLACE} | ${SEDCMD} "s/|/|${V_VERSION}|/3"`;
fi;
V_CRSV=`${ECHOCMD} ${V_CRSV} | ${SEDCMD} "s#${V_ORIGINAL}#${V_REPLACE}#g"`;
done;
V_CRSV=`${ECHOCMD} ${V_CRSV} | ${SEDCMD} 's/!!!/\n/g'`;
V_CRSP_COL_NAME='|NAME|TYPE|VERSION|STATE|TARGET|LAST_RESTART|INTERNAL_STATE|!!!';
V_CRSP_COL_LINE='|----|----|-------|-----|------|------------|--------------|!!!';
${PRINTFCMD} "\e[${HEADER_COLR}\n";
${ECHOCMD} "--------------------------------------------------------------------------------------------------";
${PRINTFCMD} "\e[${TAB_HEAD_COLR}";
${PRINTFCMD} "COLOR CODES:";
${PRINTFCMD} "\e[${HEADER_COLR}";
${PRINTFCMD} " \e[${TAB_HEAD_COLR}HEADER\e[${HEADER_COLR} ";
${PRINTFCMD} " \e[${TAB_TEXT_COLR}CONTENT\e[${TAB_TEXT_COLR} ";
${PRINTFCMD} " \e[${ALRT_COLR}ALERT\e[${ALRT_COLR} ";
${PRINTFCMD} " \e[${DB_INST_COLR}ORACLE_SID\e[${TRAILER_COLR} \n";
${ECHOCMD} "--------------------------------------------------------------------------------------------------";
V_CRSV=`${PRINTFCMD} "\e[${TAB_HEAD_COLR} ${V_CRSP_COL_NAME} ${V_CRSP_COL_LINE} \e[${TAB_TEXT_COLR} ${V_CRSV}"`;
${ECHOCMD} ${V_CRSV} | ${SEDCMD} 's/|--/\n|--/1' | ${SEDCMD} 's/|NAME/\n|NAME/g' | ${SEDCMD} 's/|STATE/| | | |\n| | | |STATE/2g' | \
${SEDCMD} -e "s/NAME=//g;s/TYPE=//g;s/TARGET=//g;s/LAST_RESTART=//g;s/INTERNAL_STATE=//g;s/STATE=//g;s/VERSION=//g" | \
${SEDCMD} 's/!!!//g' | ${COLUMNCMD} -s"|" -t | \
${SEDCMD} ''/OFFLINE/s//`${PRINTFCMD} "\e[${ALRT_COLR}OFFLINE\e[${TAB_TEXT_COLR}"`/g'' | \
${SEDCMD} ''/INTERMEDIATE/s//`${PRINTFCMD} "\e[${ALRT_COLR}INTERMEDIATE\e[${TAB_TEXT_COLR}"`/g'' | \
${SEDCMD} ''/UNKNOWN/s//`${PRINTFCMD} "\e[${ALRT_COLR}UNKNOWN\e[${TAB_TEXT_COLR}"`/g'' | \
${SEDCMD} ''/\(/s//`${PRINTFCMD} "\e[${DB_INST_COLR}\("`/g'' | \
${SEDCMD} ''/\)/s//`${PRINTFCMD} "\)\e[${TAB_TEXT_COLR}"`/g'' | \
${SEDCMD} -e 's/ \+$/ /g';
${PRINTFCMD} "\e[${TRAILER_COLR}\n";
${PRINTFCMD} "-----------------------------------";
${PRINTFCMD} " \e[${TAB_HEAD_COLR}SERVICE STATUS \e[${HEADER_COLR} --- \e[${ALRT_COLR} CHECK ALERTS\e[${TRAILER_COLR} ";
${PRINTFCMD} "-----------------------------------";
${PRINTFCMD} " \e[${TAB_TEXT_COLR}\n";
service_chk;
${PRINTFCMD} "\e[${TRAILER_COLR}\n";
${PRINTFCMD} "\e[${SHELL_PROMPT_COLR}";
fi;
}
# SERVICE STATUS
service_chk()
{
### V_SERVICE_CONFIG='';
V_SERVICE_CONFIG="";
### V_SERVICE_STATUS='';
V_SERVICE_STATUS="";
### V_SERVICES='';
V_SERVICES="";
V_DATABASE_RESOURCE=`${GRID_HOME}/bin/crsctl status resource -p | \
${GREPCMD} "^NAME|^ORACLE_HOME" | ${GREPCMD} "\.db|^ORACLE_HOME=" | \
${GREPCMD} -v "\%" | ${SEDCMD} "s/^.*=//g;s/ora\.//g;s/\.db//g" | \
${SEDCMD} '$!N;s/\n/::/'`;
for db_data in `${ECHOCMD} ${V_DATABASE_RESOURCE}`
do
db_name=`${PRINTFCMD} "${db_data}" | ${AWKCMD} -F"::" '{ print $1}'`;
db_home=`${PRINTFCMD} "${db_data}" | ${AWKCMD} -F"::" '{ print $2}'`;
#${PRINTFCMD} "Database = ${db_name} \n";
#${PRINTFCMD} "Database Home = ${db_home}\n";
V_SERVICE_CONFIG=`${db_home}/bin/srvctl config service -d ${db_name} | \
${GREPCMD} "Service name|Service is enabled|TAF policy specification|Preferred|Available|Pluggable database name" | \
${SEDCMD} -e :a -e '$!N; s/\n/|/; ta' | ${SEDCMD} 's/|Service name/\nService name/g' | ${SEDCMD} -e "s/|/|${db_name}|/1" | \
${SEDCMD} -e "s/Service name: //g;s/Service is //g;s/TAF policy specification: //g;s/Preferred instances: //g;s/Available instances: //g; s/Pluggable database name: //g"`;
for srv in `${ECHOCMD} ${V_SERVICE_CONFIG}`
do
V_SERVICE=`${PRINTFCMD} "${srv}" | ${AWKCMD} -F"|" '{ print $1}'`;
#${PRINTFCMD} "V_SERVICE=${V_SERVICE} \n\n";
V_ACTIVE_ON=`${db_home}/bin/srvctl status service -d ${db_name} -s ${V_SERVICE} | \
${SEDCMD} -e "s/Service //g;s/ is running on instance(s) /|/g" | \
${AWKCMD} -F"|" '{print $2}'`;
V_ON_PREFFERED=`${PRINTFCMD} "${srv}|${V_ACTIVE_ON}" | ${AWKCMD} -F"|" '{print $(NF-2)}'`;
V_ON_AVAILABLE=`${PRINTFCMD} "${srv}|${V_ACTIVE_ON}" | ${AWKCMD} -F"|" '{print $(NF)}'`;
srv="${srv}|${V_ON_AVAILABLE}";
srv=`${PRINTFCMD} "${srv}" | ${SEDCMD} 's/|$/|Not-Started|/g'`;
srv=`${PRINTFCMD} "${srv}" | ${SEDCMD} 's/||/|Not-Setup|/g'`;
srv=`${PRINTFCMD} "${srv}" | ${AWKCMD} -F'|' '$5 ~ /Not-Setup/ { OFS= "|"; $5 = "NA"; }1'`;
if [[ `${PRINTFCMD} "${srv}" | ${AWKCMD} -F '|' '{print NF-1}'` -eq 6 ]]
then
srv=`${PRINTFCMD} "${srv}" | ${SEDCMD} -e "s/|/|NA|/4"`;
fi;
if [[ ${V_ON_PREFFERED} != ${V_ON_AVAILABLE} && "x\${V_ON_AVAILABLE}" != "x" ]]
then
srv=`${ECHOCMD} ${srv} | ${SEDCMD} 's/'${V_ON_AVAILABLE}'/BBB'${V_ON_AVAILABLE}'EEE/2'`;
fi;
V_SERVICES="${V_SERVICES}|||${srv}::";
done;
done;
V_CRSP_COL_NAME='|SERVICE_NAME|DATABASE|STATE|TAF_POLICY|PDB|PREFFERED_INSTANCE|AVAILABLE_INSTANCE|ACTIVE_ON|::';
V_CRSP_COL_LINE='|------------|--------|-----|----------|---|------------------|------------------|---------|::';
V_SRV_ALRT=`${PRINTFCMD} "\e[${TAB_HEAD_COLR} \n${V_CRSP_COL_NAME} \n${V_CRSP_COL_LINE} \e[${TAB_TEXT_COLR} \n${V_SERVICES}"`;
${ECHOCMD} "${V_SRV_ALRT}" | \
${SEDCMD} 's/::/\n/g' | \
${SEDCMD} '/^$/d' | \
${COLUMNCMD} -s"|" -t | \
${SEDCMD} ''/BBB/s//`${PRINTFCMD} "\e[${ALRT_COLR}"`/g'' | \
${SEDCMD} ''/EEE/s//`${PRINTFCMD} "\e[${TAB_TEXT_COLR}"`/g'' | \
${SEDCMD} ''/Not-Started/s//`${PRINTFCMD} "\e[${ALRT_COLR}Not-Started\e[${TAB_TEXT_COLR}"`/g'' | \
${SEDCMD} ''/Not-Setup/s//`${PRINTFCMD} "\e[${ALRT_COLR}Not-Setup\e[${TAB_TEXT_COLR}"`/g'' | \
${SEDCMD} ''/NONE/s//`${PRINTFCMD} "\e[${ALRT_COLR}NONE\e[${TAB_TEXT_COLR}"`/g'';
}
# *********** CODE CALL ***********
CHECK_RESOURCE=$1;
binary_setup;
crsstat ${CHECK_RESOURCE};
else
  echo ">--------------------------------------------------------------------------------------------------"
  echo " -- GRID INFRASTRUTURE WAS NOT FOUNDED --"
  echo ">--------------------------------------------------------------------------------------------------"
fi
else
  echo ">--------------------------------------------------------------------------------------------------"
  echo " -- This Operation System is Unknown --"
  echo ">--------------------------------------------------------------------------------------------------"
fi
fi
}
func_db_068