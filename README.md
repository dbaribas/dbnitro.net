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

After you download and change like this example, you can just connect as grid or as oracle, and execute the:

alias " db "

It will show you all options to work with this script.

PS: The only line you have to take care is: export ORACLE_BASE, this is mandatory, if the variable/folder doesn't exists, you will out of the script.
So, please modify this variable as your environment is.
