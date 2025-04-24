#!/bin/sh
#
Author="Andre Augusto Ribas"
SoftwareVersion="1.0.1"
DateCreation="05/10/2023"
DateModification="05/10/2023"
EMAIL="dba.ribas@gmail.com"
GITHUB="https://github.com/dbaribas/dbnitro.net"
WEBSITE="http://dbnitro.net"
#
# Execution of purgeTFA
#
/usr/bin/tfactl managelogs -purge -older 30d -dryrun
/usr/bin/tfactl managelogs -purge -older 30d
/usr/bin/tfactl managelogs -show usage
/usr/bin/tfactl run managelogs -purge -older 30d -dryrun
/usr/bin/tfactl run managelogs -purge -older 30d
/usr/bin/tfactl run managelogs -show usage
#
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
# THE SCRIPT FINISHES HERE
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
#