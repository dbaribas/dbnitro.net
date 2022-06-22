The OracleMenu.sh is a script to select different Oracle Homes, Oracle SIDs and Oracle Environments.

Download the Profile Script

https://raw.githubusercontent.com/dbaribas/dbnitro/main/OracleMenu.sh

Modify the Name of the Profile Script

mv /opt/OracleMenu.sh /opt/.OracleMenu.sh

Change the Owner of the Profile Script

chown oracle.oinstall /opt/.OracleMenu.sh

Change the executable of the Profile Script

chmod a+x /opt/.OracleMenu.sh

chmod g+w /opt/.OracleMenu.sh

OR

# AutoInstallation

wget -O /tmp/dbnitro.sh https://raw.githubusercontent.com/dbaribas/dbnitro/main/dbnitro.sh

vim /tmp/dbnitro.sh

chmod a+x /tmp/dbnitro.sh

sh /tmp/dbnitro.sh


# After you download and change like this example, you can just connect as grid or as oracle, and execute the alias: 

" db "

It will show you all options to work with this script.

A special thanks to:
* Fabio Specht
* Ricardo Portilho
* Fred Denis
* Rodrigo Mufalani
* Leonardo Lopes

With your help, patient and some laughs, we did this easier!!!
