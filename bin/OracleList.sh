#!/bin/sh
Author="Andre Augusto Ribas"
SoftwareVersion="1.0.9"
DateCreation="18/09/2023"
DateModification="14/12/2023"
EMAIL_1="dba.ribas@gmail.com"
EMAIL_2="andre.ribas@icloud.com"
WEBSITE="http://dbnitro.net"
#
# ------------------------------------------------------------------------
# Verify OS Parameters and Variables
#
ORA_HOMES_IGNORE_0="REMOVED|REFHOME|DEPHOME|PLUGINS|/usr/lib/oracle/sbin"
ORA_HOMES_IGNORE_1="${ORA_HOMES_IGNORE_0}|goldengate|ogg|gg|middleware|agent"
ORA_HOMES_IGNORE_2="${ORA_HOMES_IGNORE_0}|goldengate|ogg|gg|middleware"
ORA_HOMES_IGNORE_3="${ORA_HOMES_IGNORE_0}|middleware|agent"
ORA_HOMES_IGNORE_4="${ORA_HOMES_IGNORE_0}|goldengate|ogg|gg|agent"
ORA_HOMES_IGNORE_5="+apx|-mgmtdb"
#
if [[ "$(uname)" == "SunOS" ]]; then
  OS="Solaris"
  ORATAB="/var/opt/oracle/oratab"
  ORA_INST="/var/opt/oracle/oraInst.loc"
  ORA_INVENTORY="$(cat ${ORA_INST}      | egrep -i "inventory_loc"                           | cut -f2 -d '=')/ContentsXML/inventory.xml"
  ASM_PROC="$(ps -ef                    | egrep -i -v "grep|egrep|sed"                       | egrep -i "asm_pmon"    | awk '{ print $NF }'          | sed s/asm_pmon_//g | uniq           | sort  | wc -l | xargs)"
  CRSD_PROC="$(ps -ef                   | egrep -i -v 'grep|egrep'                           | egrep -i 'crsd.bin'    | uniq                         | sort               | wc -l          | xargs)"
  OCSSD_PROC="$(ps -ef                  | egrep -i -v 'grep|egrep'                           | egrep -i 'ocssd.bin'   | uniq                         | sort               | wc -l          | xargs)"
  OHASD_PROC="$(ps -ef                  | egrep -i -v 'grep|egrep'                           | egrep -i 'ohasd.bin'   | uniq                         | sort               | wc -l          | xargs)"
  DATABASE_PROC="$(ps -ef               | egrep -i -v "grep|egrep|sed"                       | egrep -i "ora_pmon"    | awk '{ print $NF }'          | sed s/ora_pmon_//g | uniq           | sort  | wc -l | xargs)"
  LISTENER_PROC="$(ps -ef               | egrep -i -v "grep|egrep|zabbix|webmin"             | egrep -i "listener"    | awk '{ print $9 }'           | uniq               | sort           | wc -l | xargs)"
  AGENT_PROC="$(ps -ef                  | egrep -i -v "grep|egrep|zabbix|webmin"             | egrep -i "agent_|perl" | uniq                         | sort               | wc -l          | xargs)"
  OMS_PROC="$(ps -ef                    | egrep -i -v "grep|egrep|zabbix|webmin"             | egrep -i "wlserver"    | uniq                         | sort               | wc -l          | xargs)"
  OGG_PROC="$(ps -ef                    | egrep -i -v "grep|egrep|zabbix|qmgr|clmgrs|dgmgrl" | egrep -i "mgr|prm"     | uniq                         | sort               | wc -l          | xargs)"
  ASM_HOME="$(cat ${ORA_INVENTORY}      | egrep -i -v "^#|${ORA_HOMES_IGNORE_0}"             | egrep -i "LOC"         | egrep -i "OraGI"             | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)"
  DATABASE_HOME="$(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_0}"             | egrep -i "LOC"         | egrep -i "OraDB|OraHome"     | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)"
  CLIENT_HOME="$(cat ${ORA_INVENTORY}   | egrep -i -v "^#|${ORA_HOMES_IGNORE_0}"             | egrep -i "LOC"         | egrep -i "OraClient"         | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)"
  AGENT_HOME="$(cat ${ORA_INVENTORY}    | egrep -i -v "^#|${ORA_HOMES_IGNORE_0}"             | egrep -i "LOC"         | egrep -i "agent"             | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)"
  OMS_HOME="$(cat ${ORA_INVENTORY}      | egrep -i -v "^#|${ORA_HOMES_IGNORE_0}"             | egrep -i "LOC"         | egrep -i "oms"               | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)"
  OGG_HOME="$(cat ${ORA_INVENTORY}      | egrep -i -v "^#|${ORA_HOMES_IGNORE_0}"             | egrep -i "LOC"         | egrep -i "goldengate|ogg|gg" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)"
elif [[ "$(uname)" == "AIX" ]]; then
  OS="AIX"
  ORATAB="/etc/oratab"
  ORA_INST="/opt/oracle/etc/oraInst.loc"
  ORA_INVENTORY="$(cat ${ORA_INST}      | egrep -i "inventory_loc"                           | cut -f2 -d '=')/ContentsXML/inventory.xml"
  ASM_PROC="$(ps -ef                    | egrep -i -v "grep|egrep|sed"                       | egrep -i "asm_pmon"    | awk '{ print $NF }'          | sed s/asm_pmon_//g | uniq           | sort  | wc -l | xargs)"
  CRSD_PROC="$(ps -ef                   | egrep -i -v 'grep|egrep'                           | egrep -i 'crsd.bin'    | uniq                         | sort               | wc -l          | xargs)"
  OCSSD_PROC="$(ps -ef                  | egrep -i -v 'grep|egrep'                           | egrep -i 'ocssd.bin'   | uniq                         | sort               | wc -l          | xargs)"
  OHASD_PROC="$(ps -ef                  | egrep -i -v 'grep|egrep'                           | egrep -i 'ohasd.bin'   | uniq                         | sort               | wc -l          | xargs)"
  DATABASE_PROC="$(ps -ef               | egrep -i -v "grep|egrep|sed"                       | egrep -i "ora_pmon"    | awk '{ print $NF }'          | sed s/ora_pmon_//g | uniq           | sort  | wc -l | xargs)"
  LISTENER_PROC="$(ps -ef               | egrep -i -v "grep|egrep|zabbix|webmin"             | egrep -i "listener"    | awk '{ print $9 }'           | uniq               | sort           | wc -l | xargs)"
  AGENT_PROC="$(ps -ef                  | egrep -i -v "grep|egrep|zabbix|webmin"             | egrep -i "agent_|perl" | uniq                         | sort               | wc -l          | xargs)"
  OMS_PROC="$(ps -ef                    | egrep -i -v "grep|egrep|zabbix|webmin"             | egrep -i "wlserver"    | uniq                         | sort               | wc -l          | xargs)"
  OGG_PROC="$(ps -ef                    | egrep -i -v "grep|egrep|zabbix|qmgr|clmgrs|dgmgrl" | egrep -i "mgr|prm"     | uniq                         | sort               | wc -l          | xargs)"
  ASM_HOME="$(cat ${ORA_INVENTORY}      | egrep -i -v "^#|${ORA_HOMES_IGNORE_0}"             | egrep -i "LOC"         | egrep -i "OraGI"             | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)"
  DATABASE_HOME="$(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_0}"             | egrep -i "LOC"         | egrep -i "OraDB|OraHome"     | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)"
  CLIENT_HOME="$(cat ${ORA_INVENTORY}   | egrep -i -v "^#|${ORA_HOMES_IGNORE_0}"             | egrep -i "LOC"         | egrep -i "OraClient"         | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)"
  AGENT_HOME="$(cat ${ORA_INVENTORY}    | egrep -i -v "^#|${ORA_HOMES_IGNORE_0}"             | egrep -i "LOC"         | egrep -i "agent"             | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)"
  OMS_HOME="$(cat ${ORA_INVENTORY}      | egrep -i -v "^#|${ORA_HOMES_IGNORE_0}"             | egrep -i "LOC"         | egrep -i "oms"               | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)"
  OGG_HOME="$(cat ${ORA_INVENTORY}      | egrep -i -v "^#|${ORA_HOMES_IGNORE_0}"             | egrep -i "LOC"         | egrep -i "goldengate|ogg|gg" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)"
elif [[ "$(uname)" == "Linux" ]]; then
  OS="Linux"
  ORATAB="/etc/oratab"
  ORA_INST="/etc/oraInst.loc"
  ORA_INVENTORY="$(cat ${ORA_INST}      | egrep -i "inventory_loc"                           | cut -f2 -d '=')/ContentsXML/inventory.xml"
  ASM_PROC="$(ps -ef                    | egrep -i -v "grep|egrep|sed"                       | egrep -i "asm_pmon"    | awk '{ print $NF }'          | sed s/asm_pmon_//g | uniq           | sort  | wc -l | xargs)"
  CRSD_PROC="$(ps -ef                   | egrep -i -v 'grep|egrep'                           | egrep -i 'crsd.bin'    | uniq                         | sort               | wc -l          | xargs)"
  OCSSD_PROC="$(ps -ef                  | egrep -i -v 'grep|egrep'                           | egrep -i 'ocssd.bin'   | uniq                         | sort               | wc -l          | xargs)"
  OHASD_PROC="$(ps -ef                  | egrep -i -v 'grep|egrep'                           | egrep -i 'ohasd.bin'   | uniq                         | sort               | wc -l          | xargs)"
  DATABASE_PROC="$(ps -ef               | egrep -i -v "grep|egrep|sed"                       | egrep -i "ora_pmon"    | awk '{ print $NF }'          | sed s/ora_pmon_//g | uniq           | sort  | wc -l | xargs)"
  LISTENER_PROC="$(ps -ef               | egrep -i -v "grep|egrep|zabbix|webmin"             | egrep -i "listener"    | awk '{ print $9 }'           | uniq               | sort           | wc -l | xargs)"
  AGENT_PROC="$(ps -ef                  | egrep -i -v "grep|egrep|zabbix|webmin"             | egrep -i "agent_|perl" | uniq                         | sort               | wc -l          | xargs)"
  OMS_PROC="$(ps -ef                    | egrep -i -v "grep|egrep|zabbix|webmin"             | egrep -i "wlserver"    | uniq                         | sort               | wc -l          | xargs)"
  OGG_PROC="$(ps -ef                    | egrep -i -v "grep|egrep|zabbix|qmgr|clmgrs|dgmgrl" | egrep -i "mgr|prm"     | uniq                         | sort               | wc -l          | xargs)"
  ASM_HOME="$(cat ${ORA_INVENTORY}      | egrep -i -v "^#|${ORA_HOMES_IGNORE_0}"             | egrep -i "LOC"         | egrep -i "OraGI"             | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)"
  DATABASE_HOME="$(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_0}"             | egrep -i "LOC"         | egrep -i "OraDB|OraHome"     | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)"
  CLIENT_HOME="$(cat ${ORA_INVENTORY}   | egrep -i -v "^#|${ORA_HOMES_IGNORE_0}"             | egrep -i "LOC"         | egrep -i "OraClient"         | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)"
  AGENT_HOME="$(cat ${ORA_INVENTORY}    | egrep -i -v "^#|${ORA_HOMES_IGNORE_0}"             | egrep -i "LOC"         | egrep -i "agent"             | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)"
  OMS_HOME="$(cat ${ORA_INVENTORY}      | egrep -i -v "^#|${ORA_HOMES_IGNORE_0}"             | egrep -i "LOC"         | egrep -i "oms"               | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)"
  OGG_HOME="$(cat ${ORA_INVENTORY}      | egrep -i -v "^#|${ORA_HOMES_IGNORE_0}"             | egrep -i "LOC"         | egrep -i "goldengate|ogg|gg" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort)"
fi
#
# ------------------------------------------------------------------------
# Verify oraInst.loc file
#
if [[ ! -f "${ORA_INST}" ]]; then
  echo " -- THIS SERVER DOES NOT HAVE AN ORACLE INSTALLATION YET --"
  exit 1
fi
#
#
# ------------------------------------------------------------------------
# Verify ORACLE Inventory
#
if [[ ! -f "${ORA_INVENTORY}" ]]; then
  echo " -- YOU DO NOT HAVE THE ORACLE INVENTORY IN YOUR ENVIRONMENT --"
  echo " -- PLEASE CHECK YOUR CONFIGURATION --"
  exit 1
fi
#
# ------------------------------------------------------------------------
# Verify ORACLE Services
#
if [[ "${ORA_SERVICES} | xargs" == "0" ]]; then
  echo " -- YOU DO NOT HAVE THE ORACLE INVENTORY IN YOUR ENVIRONMENT --"
  echo " -- PLEASE CHECK YOUR CONFIGURATION --"
  exit 1
fi
#
# ------------------------------------------------------------------------
# Function to display Oracle service status
# USE BREAK ON IFs BECAUSE IT IS A FUNCTION
#
OracleServices() {
#
# ASM OK
# CRSD OK
# OCSSD OK
# OHASD OK
# LISTENER OK
# AGENT OK
# MIDDLEWARE OK
# GOLDENGATE OK
# DATABASE OK
#
if [[ "${ASM_PROC}" != "0" ]] || [[ "${CRSD_PROC}" != "0" ]] || [[ "${OCSSD_PROC}" != "0" ]] || [[ "${OHASD_PROC}" != "0" ]] || [[ "${LISTENER_PROC}" != "0" ]] || [[ "${AGENT_PROC}" != "0" ]] || [[ "${OMS_PROC}" != "0" ]] || [[ "${OGG_PROC}" != "0" ]] || [[ "${DATABASE_PROC}" != "0" ]]; then
#
printf "+%-50s+\n"    "--------------------------------------------------"
printf "|%-50s%-s|\n" " ORACLE SERVICES RUNNING                          "
printf "+%-50s+\n"    "--------------------------------------------------"
#
printf "+%-16s+%-16s+%-16s+%-50s+\n" "----------------------" "----------------------" "----------------------" "------------------------------------------------------------"
printf "|%-16s|%-16s|%-16s|%-50s|\n" " SERVICE              " " STATUS               " " INFO                 " " ORACLE HOME                                                "
printf "+%-16s+%-16s+%-16s+%-50s+\n" "----------------------" "----------------------" "----------------------" "------------------------------------------------------------"
#
# ASM
#
if [[ "${ASM_PROC}" != "0" ]]; then
  ASM_SERVICE="$(ps -ef | egrep -i -v "grep|egrep|sed" | egrep -i "asm_pmon" | awk '{ print $NF }' | sed s/asm_pmon_//g | uniq | sort)"
  ASM_STARTED="$(ps -ef | egrep -i -v "grep|egrep|sed" | egrep -i "asm_pmon" | awk '{ print $5 }' | uniq | tail -2)"
  printf "|%-22s|%-22s|%-22s|%-60s|\n" " ${ASM_SERVICE} " " RUNNING " " UP SINCE: ${ASM_STARTED} " " ${ASM_HOME}"
fi
#
# CRSD
#
if [[ "${CRSD_PROC}" != "0" ]]; then
  CRSD_SERVICE="$(ps -ef | egrep -v "grep|egrep" | egrep "crsd.bin" | awk '{ print $8 }' | uniq | sort)"
  CRSD_STARTED="$(ps -ef | egrep -v "grep|egrep" | egrep "crsd.bin" | awk '{ print $5 }' | uniq | tail -2)"
  printf "|%-22s|%-22s|%-22s|%-60s|\n" " CRSD " " RUNNING " " UP SINCE: ${CRSD_STARTED} " " ${CRSD_SERVICE}"
fi
#
# OCSSD
#
if [[ "${OCSSD_PROC}" != "0" ]]; then
  OCSSD_SERVICE="$(ps -ef | egrep -v "grep|egrep" | egrep "ocssd.bin" | awk '{ print $8 }' | uniq | sort)"
  OCSSD_STARTED="$(ps -ef | egrep -v "grep|egrep" | egrep "ocssd.bin" | awk '{ print $5 }' | uniq | tail -2)"
  printf "|%-22s|%-22s|%-22s|%-60s|\n" " OCSSD " " RUNNING " " UP SINCE: ${OCSSD_STARTED} " " ${OCSSD_SERVICE}"
fi
#
# OHASD
#
if [[ "${OHASD_PROC}" != "0" ]]; then
  OHASD_SERVICE="$(ps -ef | egrep -v "grep|egrep" | egrep "ohasd.bin" | awk '{ print $8 }' | uniq | sort)"
  OHASD_STARTED="$(ps -ef | egrep -v "grep|egrep" | egrep "ohasd.bin" | awk '{ print $5 }' | uniq | tail -2)"
  printf "|%-22s|%-22s|%-22s|%-60s|\n" " OHASD " " RUNNING " " UP SINCE: ${OHASD_STARTED} " " ${OHASD_SERVICE}"
fi
#
# LISTENER
#
if [[ "${LISTENER_PROC}" != "0" ]]; then
  for LISTENER_SERVICE in $(ps -ef | egrep -i -v "grep|egrep|zabbix" | egrep -i "listener" | awk '{ print $9 }' | uniq | sort); do
       LISTENER_HOME="$(ps -ef | egrep -i -v "grep|egrep|zabbix" | egrep -i -w "${LISTENER_SERVICE}" | awk '{ print $8 }' | uniq | sort)"
    LISTENER_STARTED="$(ps -ef | egrep -i -v "grep|egrep|zabbix" | egrep -i -w "${LISTENER_SERVICE}" | awk '{ print $5 }' | uniq | tail -2)"
    printf "|%-22s|%-22s|%-22s|%-60s|\n" " ${LISTENER_SERVICE} " " RUNNING " " UP SINCE: ${LISTENER_STARTED} " " ${LISTENER_HOME}"
  done
fi
#
# AGENT
#
if [[ "${AGENT_PROC}" != "0" ]]; then
  for AGENT_SERVICE in $(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_0}" | egrep -i "LOC" | egrep -i "agent" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort); do
    AGENT_STARTED="$(ps -ef | egrep -i "grep|egrep|zabbix" | egrep -i -w "${AGENT_SERVICE}" | awk '{ print $5 }' | uniq | tail -2)"
    printf "|%-22s|%-22s|%-22s|%-60s|\n" " AGENT " " RUNNING " " UP SINCE: ${LISTENER_STARTED} " " ${AGENT_SERVICE}"
  done
fi
#
# MIDDLEWARE
#
if [[ "${OMS_PROC}" != "0" ]]; then
  for OMS_SERVICE in $(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_0}" | egrep -i "LOC" | egrep -i "oms" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort); do
    OMS_STARTED="$(ps -ef | egrep -i "grep|egrep|zabbix" | egrep -i -w "${OMS_SERVICE}" | awk '{ print $5 }' | uniq | tail -2)"
    printf "|%-22s|%-22s|%-22s|%-60s|\n" " OMS " " RUNNING " " UP SINCE: ${OMS_STARTED} " " ${OMS_SERVICE}"
  done
fi
#
# GOLDENGATE
#
if [[ "${OGG_PROC}" != "0" ]]; then
  for OGG_SERVICE in $(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_0}" | egrep -i "LOC" | egrep -i "goldengate|ogg|gg" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort); do
    OGG_STARTED="$(ps -ef | egrep -i "grep|egrep|zabbix" | egrep -i -w "${OGG_SERVICE}" | awk '{ print $5 }' | uniq | tail -2)"
    printf "|%-22s|%-22s|%-22s|%-60s|\n" " OGG " " RUNNING " " UP SINCE: ${OGG_STARTED} " " ${OGG_SERVICE}"
  done
fi
#
# DATABASE
#
if [[ "$(whoami)" == "oracle" ]] || [[ "$(whoami)" == "grid" ]] ; then
  if [[ "${DATABASE_PROC}" != "0" ]]; then
    for DATABASE_SERVICE in $(ps -ef | egrep -i -v "grep|egrep|sed" | egrep -i "ora_pmon" | awk '{ print $NF }' | sed s/ora_pmon_//g | uniq | sort); do
      if [[ $(cat ${ORATAB} | awk '{ print $1 }' | cut -f1 -d ':' | egrep -w "${DATABASE_SERVICE}") != ${DATABASE_SERVICE} ]]; then
        DATABASE_STARTED="$(ps -ef | egrep -i "ora_pmon" | egrep -i "${DATABASE_SERVICE}" | awk '{ print $5 }' | uniq | tail -2)"
           DATABASE_TYPE="$(ps -ef | egrep -i "ora_mrp" | egrep -i "${DATABASE_SERVICE}" | sort | wc -l | xargs | uniq)"
        printf "|%-22s|%-22s|%-22s|%-60s|\n" " ${DATABASE_SERVICE} " " RUNNING " " UP SINCE: ${DATABASE_STARTED} " " ${DATABASE_TYPE}"
      else
      ORAENV_ASK=NO
      ORACLE_SID=${DATABASE_SERVICE}
      . /usr/local/bin/oraenv <<< ${ORACLE_SID} > /dev/null
      #
      # DATABASE STATUS
      #
DATABASE_STATUS="$(echo "select status || ' ' || (select case when value = 'TRUE' then '[RAC]' else '[SING]' end from v\$parameter where name = 'cluster_database') as status from v\$instance;" | sqlplus -S / as sysdba | tail -2)"
#
# DATABASE ROLE
#
DATABASE_ROLE="$(echo "select database_role from v\$database;" | sqlplus -S / as sysdba | tail -2)"
#
# DATABASE OPEN MODE
#
DATABASE_MODE="$(echo "select case when OPEN_MODE = 'READ WRITE' then '(RW)' when OPEN_MODE = 'READ ONLY' then '(RO)' when OPEN_MODE = 'MOUNTED' then '(MO)' when OPEN_MODE = 'MIGRATE' then '(MI)' end as PDBS from v\$database;" | sqlplus -S / as sysdba | tail -2)"
#
# DATABASE STARTED UP
#
DATABASE_STARTED="$(echo "select to_char(startup_time, 'DD/MM/YYYY') from v\$instance;" | sqlplus -S / as sysdba | tail -2)"
#
# DB RESULT
#
      printf "|%-22s|%-22s|%-22s|%-60s|\n" " ${DATABASE_SERVICE} " " ${DATABASE_STATUS} " " ${DATABASE_ROLE} ${DATABASE_MODE}" " ${ORACLE_HOME}"
    fi
    done
  fi
else 
  if [[ "${DATABASE_PROC}" != "0" ]]; then
    for DATABASE_SERVICE in $(ps -ef | egrep -i -v "grep|egrep|sed" | egrep -i "ora_pmon" | awk '{ print $NF }' | sed s/ora_pmon_//g | uniq | sort); do
      DATABASE_STARTED="$(ps -ef | egrep -i "ora_pmon" | egrep -i "${DATABASE_SERVICE}" | awk '{ print $5 }' | uniq | tail -2)"
         DATABASE_TYPE="$(ps -ef | egrep -i "ora_mrp" | egrep -i "${DATABASE_SERVICE}" | sort | wc -l | xargs | uniq)"
      if [[ "$(cat ${ORATAB} | awk '{ print $1 }' | cut -f1 -d ':' | egrep -w "${DATABASE_SERVICE}" | wc -l | xargs | uniq)" == "0" ]]; then
        printf "|%-22s|%-22s|%-22s|%-60s|\n" " ${DATABASE_SERVICE} " " RUNNING " " UP SINCE: ${DATABASE_STARTED}" " $(if [[ "${DATABASE_TYPE}" == "0" ]]; then echo "PRIMARY"; else echo "STANDBY"; fi) "
      else
        DATABASE_HOMES="$(cat ${ORATAB} | egrep -w "${DATABASE_SERVICE}" | cut -f2 -d ':')"
        printf "|%-22s|%-22s|%-22s|%-60s|\n" " ${DATABASE_SERVICE} " " RUNNING " " UP SINCE: ${DATABASE_STARTED}" " ${DATABASE_HOMES}: $(if [[ "${DATABASE_TYPE}" == "0" ]]; then echo "PRIMARY"; else echo "STANDBY"; fi) "
      fi
  done
  fi
fi
#
printf "+%-16s+%-16s+%-16s+%-50s+\n" "----------------------" "----------------------" "----------------------" "------------------------------------------------------------"
#
fi
#
}
# --------------------------------------------------------------------------------------------------------------------------------------------
OracleProducts() {
#
# ASM OK
# DATABASE OK
# CLIENT OK
# AGENT OK
# MIDDLEWARE OK
# GOLDENGATE OK
#
if [[ "$(echo ${ASM_HOME} | wc -l | xargs)" != "0" ]] || [[ "$(echo ${DATABASE_HOME} | wc -l | xargs)" != "0" ]] || [[ "$(echo ${CLIENT_HOME} | wc -l | xargs)" != "0" ]] || [[ "$(echo ${AGENT_HOME} | wc -l | xargs)" != "0" ]] || [[ "$(echo ${OMS_HOME} | wc -l | xargs)" != "0" ]] || [[ "$(echo ${OGG_HOME} | wc -l | xargs)" != "0" ]]; then
#
printf "+%-50s+\n"    "--------------------------------------------------"
printf "|%-50s%-s|\n" " ORACLE PRODUCTS INSTALLED                        "
printf "+%-50s+\n"    "--------------------------------------------------"
#
printf "+%-16s+%-50s+%-16s+\n" "----------------------" "------------------------------------------------------------" "----------------------"
printf "|%-16s|%-50s|%-16s|\n" " HOME NAME            " " HOME                                                       " " OWNER                "
printf "+%-16s+%-50s+%-16s+\n" "----------------------" "------------------------------------------------------------" "----------------------"
#
# ASM HOME AND OWNER
#
if [[ "$(echo ${ASM_HOME} | wc -l | xargs)" != "0" ]]; then
  for ASM_INVENTORY in ${ASM_HOME}; do
        ASM_OWNER="$(ls -l ${ASM_INVENTORY} | awk '{ print $3 }' | egrep -i -v "root" | egrep -Ev "^$" | uniq)"
    ASM_HOME_NAME="$(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_0}" | egrep -i "LOC" | egrep -i "${ASM_INVENTORY}" | awk '{ print $2 }' | cut -f2 -d '=' | cut -f2 -d '"')"
    printf "|%-22s|%-60s|%-22s|\n" " ${ASM_HOME_NAME} "     " ${ASM_INVENTORY} "                                           " ${ASM_OWNER}"
    printf "+%-16s+%-50s+%-16s+\n" "----------------------" "------------------------------------------------------------" "----------------------"
  done
fi
#
# DB HOME AND OWNER
#
if [[ "$(echo ${DATABASE_HOME} | wc -l | xargs)" != "0" ]]; then
  for DATABASE_INVENTORY in ${DATABASE_HOME}; do
        DB_OWNER="$(ls -l ${DATABASE_INVENTORY} | awk '{ print $3 }' | egrep -i -v "root" | egrep -Ev "^$" | uniq)"
    DB_HOME_NAME="$(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_0}" | egrep -i "LOC" | egrep -i "${DATABASE_INVENTORY}" | awk '{ print $2 }' | cut -f2 -d '=' | cut -f2 -d '"')"
    printf "|%-22s|%-60s|%-22s|\n" " ${DB_HOME_NAME} "      " ${DATABASE_INVENTORY} "                                      " ${DB_OWNER}"
    printf "+%-16s+%-50s+%-16s+\n" "----------------------" "------------------------------------------------------------" "----------------------"
  done
fi
#
# CLIENT HOME AND OWNER
#
if [[ "$(echo ${CLIENT_HOME} | wc -l | xargs)" != "0" ]]; then
  for CLIENT_INVENTORY in ${CLIENT_HOME}; do
        CLIENT_OWNER="$(ls -l ${CLIENT_INVENTORY} | awk '{ print $3 }' | egrep -i -v "root" | egrep -Ev "^$" | uniq)"
    CLIENT_HOME_NAME="$(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_0}" | egrep -i "LOC" | egrep -i "${CLIENT_INVENTORY}" | awk '{ print $2 }' | cut -f2 -d '=' | cut -f2 -d '"')"
    printf "|%-22s|%-60s|%-22s|\n" " ${CLIENT_HOME_NAME} "  " ${CLIENT_INVENTORY} "                                        " ${CLIENT_OWNER}"
    printf "+%-16s+%-50s+%-16s+\n" "----------------------" "------------------------------------------------------------" "----------------------"
  done
fi
#
# AGENT HOME AND OWNER
#
if [[ "$(echo ${AGENT_HOME} | wc -l | xargs)" != "0" ]]; then
  for AGENT_INVENTORY in ${AGENT_HOME}; do
        AGENT_OWNER="$(ls -l ${AGENT_INVENTORY} | awk '{ print $3 }' | egrep -i -v "root" | egrep -Ev "^$" | uniq)"
    AGENT_HOME_NAME="$(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_0}" | egrep -i "LOC" | egrep -i "${AGENT_INVENTORY}" | awk '{ print $2 }' | cut -f2 -d '=' | cut -f2 -d '"')"
    printf "|%-22s|%-60s|%-22s|\n" " ${AGENT_HOME_NAME} "   " ${AGENT_INVENTORY} "                                         " ${AGENT_OWNER}"
    printf "+%-16s+%-50s+%-16s+\n" "----------------------" "------------------------------------------------------------" "----------------------"
  done
fi
#
# MIDDLEWARE HOME AND OWNER
#
if [[ "$(echo ${OMS_HOME} | wc -l | xargs)" != "0" ]]; then
  for OMS_INVENTORY in ${OMS_HOME}; do
        OMS_OWNER="$(ls -l ${OMS_INVENTORY} | awk '{ print $3 }' | egrep -i -v "root" | egrep -Ev "^$" | uniq)"
    OMS_HOME_NAME="$(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_0}" | egrep -i "LOC" | egrep -i "${OMS_INVENTORY}" | awk '{ print $2 }' | cut -f2 -d '=' | cut -f2 -d '"')"
    printf "|%-22s|%-60s|%-22s|\n" " ${OMS_HOME_NAME} "     " ${OMS_INVENTORY} "                                           " ${OMS_OWNER}"
    printf "+%-16s+%-50s+%-16s+\n" "----------------------" "------------------------------------------------------------" "----------------------"
  done
fi
#
# GOLDENGATE HOME AND OWNER
#
if [[ "$(echo ${OGG_HOME} | wc -l | xargs)" != "0" ]]; then
  for OGG_INVENTORY in ${OGG_HOME}; do
        OGG_OWNER="$(ls -l ${OGG_INVENTORY} | awk '{ print $3 }' | egrep -i -v "root" | egrep -Ev "^$" | uniq)"
    OGG_HOME_NAME="$(cat ${ORA_INVENTORY} | egrep -i -v "^#|${ORA_HOMES_IGNORE_0}" | egrep -i "LOC" | egrep -i "${OGG_INVENTORY}" | awk '{ print $2 }' | cut -f2 -d '=' | cut -f2 -d '"')"
    printf "|%-22s|%-60s|%-22s|\n" " ${OGG_HOME_NAME} "     " ${OGG_INVENTORY} "                                           " ${OGG_OWNER}"
    printf "+%-16s+%-50s+%-16s+\n" "----------------------" "------------------------------------------------------------" "----------------------"
  done
fi
#
fi
}
#
OracleServices
OracleProducts
#
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
# THE SCRIPT FINISHES HERE
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
#
