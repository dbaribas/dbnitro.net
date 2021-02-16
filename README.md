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




# Save the Content on this file

vim /opt/.OracleMenu.sh


# Modify the permissions of this file

chmod a+x /opt/.OracleMenu.sh
chmod g+w /opt/.OracleMenu.sh


# Add the Content on Grid Profile

cat > /home/grid/.bash_profile <<EOF
# .bash_profile

# Get the aliases and functions
if [[ -f ~/.bashrc ]]; then
       . ~/.bashrc
fi
#
# User specific environment and startup programs
#
export PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/oracle/.local/bin:/home/oracle/bin
export PS1=\$'[ \${LOGNAME}@\h:\$(pwd): ]\$ '
#
echo " -- TO SELECT ANY ORACLE PRODUCT, JUST TYPE: db --"
echo " -- IT WILL SHOW YOU ALL OPTIONS YOU CAN USE --"
alias db='. /opt/.OracleMenu.sh'
#
umask 0022
EOF


# Add the Content on Oracle Profile

cat > /home/oracle/.bash_profile <<EOF
# .bash_profile

# Get the aliases and functions
if [[ -f ~/.bashrc ]]; then
       . ~/.bashrc
fi
#
# User specific environment and startup programs
#
export PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/oracle/.local/bin:/home/oracle/bin
export PS1=\$'[ \${LOGNAME}@\h:\$(pwd): ]\$ '
#
echo " -- TO SELECT ANY ORACLE PRODUCT, JUST TYPE: db --"
echo " -- IT WILL SHOW YOU ALL OPTIONS YOU CAN USE --"
alias db='. /opt/.OracleMenu.sh'
#
umask 0022
EOF



After you download and change like this example, you can just connect as grid or as oracle, and execute the alias " db ", it will show you all options to work with this script.
