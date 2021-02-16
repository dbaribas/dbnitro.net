# dbnitro
All about Oracle

The bash_menu.sh is a script to select different Oracle Homes, Oracle SIDs and Oracle Environments.
The only mandatory parameter to check and change if necessary is the ORACLE_BASE, everything else will works deppending on the installation you have.

# Download the Profile Script

wget https://github.com/dbaribas/dbnitro/blob/main/OracleMenu.sh –P /opt/

# Modify the Name of the Profile Script

mv /opt/OracleMenu.sh /opt/.OracleMenu.sh

# Change the Owner of the Profile Script

chown oracle.oinstall /opt/.OracleMenu.sh

# Change the executable of the Profile Script

chmod a+x /opt/.OracleMenu.sh

chmod g+w /opt/.OracleMenu.sh
