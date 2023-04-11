The OracleMenu.sh is a script to select different Oracle Homes, Oracle SIDs and Oracle Environments.

AutoInstallation

wget -O /tmp/DBNitroMenu.sh https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/DBNitroMenu.sh

chmod a+x /tmp/DBNitroMenu.sh

sh /tmp/DBNitroMenu.sh


After you download and change like this example, you can just connect as grid or as oracle, and execute the alias: 

" db "

It will show you all options to work with this script.

A special thanks to:
* Fabio Specht
* Ricardo Portilho
* Fred Denis
* Rodrigo Mufalani
* Leonardo Lopes

With your help, patient and some laughs, we did this easier!!!


# Alternative way.
wget -O /opt/DBNitro.zip https://github.com/dbaribas/dbnitro.net/archive/refs/heads/main.zip

unzip /opt/DBNitro.zip -d /opt/

mv /opt/dbnitro.net-main /opt/dbnitro

chown oracle.oinstall -R /opt/dbnitro

chmod 775 -R /opt/dbnitro

