#!/bin/sh
#
Author="Andre Augusto Ribas"
SoftwareVersion="1.0.7"
DateCreation="28/09/2021"
DateModification="12/04/2024"
EMAIL="dba.ribas@gmail.com"
GITHUB="https://github.com/dbaribas/dbnitro.net"
WEBSITE="http://dbnitro.net"
#
# Usage:
# purgelogs.bin cleanup [--days <days> [--aud] [--lsnr]] |
#                       [--orcl <days> [--aud] [--lsnr]] |
#                       [--tfa <days>] |
#                       [--osw <days>] |
#                       [--oda <days>] |
#                       [--extra '<folder>':<days> | [, '<folder>':<days>]]
#                       [--automigrate]
#                       [--dryrun]
# 
# purgeLogs cleanup OPTIONS
# --days   <days>           Purge orcl,tfa,osw,oda components logs & traces older then # days
# --orcl   <days>           Purge only GI/RDBMS logs & traces (Default 30 days)
# --tfa    <days>           Purge only TFA repository older then # days (Default 30 days)
# --osw    <days>           Purge only OSW archives older then # days (Default 30 days)
# --oda    <days>           Purge only ODA logs and trace older then # days (Default 30 days)
# --extra '<folder>':<days> Purge only files in user specified folders (Default 30 days)
# --aud                     Purge Audit logs based on '-orcl <days>' option
# --lsnr                    It will force the cleanup of listeners log independently by the age
# --automigrate             It will run the adrci schema migrate commands in case of DIA-49803
# --dryrun                  It will show the purge commands w/o execute them
# --help                    Display this help and exit
#
# Execution of purgeLogs
#
if [[ -f "/usr/local/sbin/purgelogs.bin" ]]; then /usr/local/sbin/purgelogs.bin cleanup -automigrate; else /usr/local/sbin/purgeLogs -automigrate; fi
if [[ -f "/usr/local/sbin/purgelogs.bin" ]]; then /usr/local/sbin/purgelogs.bin cleanup -days 30; else /usr/local/sbin/purgeLogs -days 30; fi
if [[ -f "/usr/local/sbin/purgelogs.bin" ]]; then /usr/local/sbin/purgelogs.bin cleanup -orcl 30; else /usr/local/sbin/purgeLogs -orcl 30; fi
if [[ -f "/usr/local/sbin/purgelogs.bin" ]]; then /usr/local/sbin/purgelogs.bin cleanup -days 30 -aud -lsnr; else /usr/local/sbin/purgeLogs -days 30 -aud -lsnr; fi
if [[ -f "/usr/local/sbin/purgelogs.bin" ]]; then /usr/local/sbin/purgelogs.bin cleanup -orcl 30 -aud -lsnr; else /usr/local/sbin/purgeLogs -orcl 30 -aud -lsnr; fi
if [[ -f "/usr/local/sbin/purgelogs.bin" ]]; then /usr/local/sbin/purgelogs.bin cleanup --tfa 30; else /usr/local/sbin/purgeLogs --tfa 30; fi
if [[ -f "/usr/local/sbin/purgelogs.bin" ]]; then /usr/local/sbin/purgelogs.bin cleanup --dryrun; else /usr/local/sbin/purgeLogs --dryrun; fi
#
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
# THE SCRIPT FINISHES HERE
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
#
# cp -r /u00/Scripts/purgeLogs.sh /etc/cron.daily/
# cat /var/log/oracle_purge_logs.log
# su - grid -c 'mkdir -p /u01/app/grid/admin/_mgmtdb/adump'
# su - grid -c 'mkdir -p /u01/app/grid/admin/+ASM/adump'
#
# su - oracle -c 'mkdir -p /u01/app/oracle/admin/_mgmtdb/adump'
# su - oracle -c 'mkdir -p /u01/app/oracle/admin/+ASM/adump'
# purgeLogs: Cleanup traces, logs in one command (Doc ID 2081655.1)

