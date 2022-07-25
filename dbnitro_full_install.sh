#!/bin/sh
#
Author="Andre Augusto Ribas"
SoftwareVersion="1.0.1"
DateCreation="22/06/2022"
DateModification="22/06/2022"
EMAIL_1="dba.ribas@gmail.com"
EMAIL_2="andre.ribas@icloud.com"
WEBSITE="http://dbnitro.net"
#
# ------------------------------------------------------------------------
# Verify if you are ROOT or not
#
if [[ "$(whoami)" != "root" ]]; then
  echo " -- YOU ARE NOT ROOT, YOU MUST BE ROOT TO EXECUTE THIS SCRIPT --"
  exit 1
fi
# ------------------------------------------------------------------------
# Verifying the Linux Version
#
OS_VERSION=$(cat /etc/os-release | grep "VERSION_ID=" | cut -f2 -d '=' -d '"')
#
# ------------------------------------------------------------------------
# In case of errors connection via SSH
#
cat >> /etc/environment <<EOF
LANG=en_US.UTF-8
LANGUAGE=en_US.UTF-8
LC_CTYPE=en_US.UTF-8
LC_COLLATE=C
EOF
#
# ------------------------------------------------------------------------
# ROOT PROFILE SETUP 
#
cat > /root/.bash_profile <<EOF
# .bash_profile

# Get the aliases and functions
if [[ -f ~/.bashrc ]]; then
       . ~/.bashrc
fi

# User specific environment and startup programs
export ORACLE_BASE=/u01/app/grid
export GRID_VERSION=19.3.0.1
export GRID_HOME=/u01/app/\${GRID_VERSION}/grid
export ORACLE_HOME=\${GRID_HOME}
export OPATCH=\${ORACLE_HOME}/OPatch
export JAVA_HOME=\${ORACLE_HOME}/jdk
export PATH=\${PATH}:\${HOME}/bin:\${GRID_HOME}/bin:\${OPATCH}:\${JAVA_HOME}/bin
export PS1=\$'[ \${LOGNAME}@\h:\$(pwd): ]\$ '
umask 0022
EOF
#
. /root/.bash_profile
#
# ------------------------------------------------------------------------
# Disable IPTABLES/FIREWALL
#
if [[ ${OS_VERSION} == "6".* ]]; then 
  iptables -F
  ip6tables -F
  chkconfig iptables off
  chkconfig ip6tables off
elif [[ ${OS_VERSION} == "7".* ]]; then 
  systemctl stop firewalld
  systemctl disable firewalld
elif [[ ${OS_VERSION} == "8".* ]]; then 
  systemctl stop firewalld
  systemctl disable firewalld
fi
#
# ------------------------------------------------------------------------
# Install and Enable the CHRONY (Substitute of NTP SYSTEM) 
#
if [[ ${OS_VERSION} == "6".* ]]; then 
  yum -y install chrony
elif [[ ${OS_VERSION} == "7".* ]]; then 
  yum -y install chrony
  systemctl enable chronyd.service
  systemctl status chronyd.service
  systemctl start chronyd.service
  systemctl restart chronyd.service
  systemctl status chronyd.service
elif [[ ${OS_VERSION} == "8".* ]]; then 
  dnf -y install chrony
  systemctl enable chronyd.service
  systemctl status chronyd.service
  systemctl start chronyd.service
  systemctl restart chronyd.service
  systemctl status chronyd.service
fi
#
# ------------------------------------------------------------------------
# INSTALL JAVA OPEN JDK AND UPDATE THE LINUX
#
if [[ ${OS_VERSION} == "6".* ]]; then 
  rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
  yum -y install java-1.8.0-openjdk-devel.x86_64 java-1.8.0-openjdk.x86_64
  yum -y upgrade
elif [[ ${OS_VERSION} == "7".* ]]; then 
  rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
  yum -y install java-1.8.0-openjdk-devel.x86_64 java-1.8.0-openjdk.x86_64
  yum -y upgrade
elif [[ ${OS_VERSION} == "8".* ]]; then 
  rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
  dnf -y install java-1.8.0-openjdk-devel.x86_64 java-1.8.0-openjdk.x86_64
  dnf -y upgrade
fi
#
# ------------------------------------------------------------------------
# Install and Enable the CHRONY (Substitute of NTP SYSTEM)
#
PACKAGES_6="atop bc.x86_64 beakerlib-vim-syntax binutils bind-utils bzip2-devel.x86_64 bzip2-libs.x86_64 bzip2.x86_64 chrony cpp compat-libstdc++-33 compat-libcap1 dialog elinks elfutils-libelf elfutils-libelf-devel epel-release.noarch firefox gcc gcc-c++ glances glibc glibc-common glibc-devel glibc-headers htop iotop iptraf-ng iscsi-initiator-utils iscsi-initiator-utils-iscsiuio lsscsi libiscsi netbsd-iscsi targetcli ksh libaio libaio-devel libgcc libstdc++ libstdc++-devel libiscsi libXtst libXtst-devel compat-glibc.x86_64 compat-glibc-headers.x86_64 glibc.i686 glibc.x86_64 glibc-devel.i686 glibc-devel.x86_64 glibc-headers.x86_64 glibc-static.i686 glibc-static.x86_64 glibc-utils.x86_64 libXp.i686 libXp.x86_64 libXp-devel.i686 libXp-devel.x86_64 libXpm.i686 libXpm.x86_64 libXpm-devel.i686 libXpm-devel.x86_64 libXtst.i686 libXtst.x86_64 libXtst-devel.i686 libXtst-devel.x86_64 lm_sensors lsof make mlocate nawk.x86_64 net-tools ntp nfs-utils nmap policycoreutils-python perl perl-DBI perl-TermReadKey perl-ExtUtils-MakeMaker perl-CPAN perl-CGI perl-URI.noarch psmisc readline-devel rlwrap smartmontools sos sysstat strace telnet tmux tuned tuned-utils unixODBC unixODBC-devel unzip vim-X11 vim-common vim-enhanced vim-filesystem vim-minimal wget xorg-x11-server-Xorg xorg-x11-server-common xorg-x11-utils xorg-x11-apps xorg-x11-xauth xterm.x86_64"
PACKAGES_7="atop bc.x86_64 beakerlib-vim-syntax binutils bind-utils bzip2-devel.x86_64 bzip2-libs.x86_64 bzip2.x86_64 chrony cpp compat-libstdc++-33 compat-libcap1 dialog elinks elfutils-libelf elfutils-libelf-devel epel-release.noarch firefox gcc gcc-c++ glances glibc glibc-common glibc-devel glibc-headers htop iotop iptraf-ng iscsi-initiator-utils iscsi-initiator-utils-iscsiuio lsscsi libiscsi netbsd-iscsi targetcli ksh libaio libaio-devel libgcc libstdc++ libstdc++-devel libiscsi libXtst libXtst-devel lm_sensors lsof make mlocate nawk.x86_64 net-tools ntp nfs-utils nmap policycoreutils-python perl perl-DBI perl-TermReadKey perl-ExtUtils-MakeMaker perl-CPAN perl-CGI perl-URI.noarch psmisc readline-devel rlwrap smartmontools sos cockpit sysstat strace telnet tmux tuned tuned-utils unixODBC unixODBC-devel unzip vim-X11 vim-common vim-enhanced vim-filesystem vim-minimal wget xorg-x11-server-Xorg xorg-x11-server-common xorg-x11-utils xorg-x11-apps xorg-x11-xauth xterm.x86_64 whois"
PACKAGES_8="atop bc.x86_64 binutils bind-utils bzip2-devel.x86_64 bzip2-libs.x86_64 bzip2.x86_64 chrony cpp elfutils-libelf elfutils-libelf-devel firefox gcc gcc-c++ glibc glibc-common glibc-devel glibc-headers iotop iptraf-ng iscsi-initiator-utils iscsi-initiator-utils-iscsiuio lsscsi libiscsi targetcli ksh libaio libaio-devel libgcc libnsl libstdc++ libstdc++-devel libiscsi libXtst libXtst-devel lm_sensors lsof make mlocate ncurses.x86_64 ncurses-libs.x86_64 ncurses-libs.x86_64 ncurses-c++-libs.x86_64 ncurses-compat-libs.x86_64 ncurses-devel.x86_64 ncurses-base.noarch ncurses-term.noarch ncurses-base.noarch net-tools nfs-utils nmap policycoreutils-python perl perl-DBI perl-TermReadKey perl-ExtUtils-MakeMaker perl-CPAN perl-CGI perl-URI.noarch psmisc readline-devel smartmontools sos cockpit sysstat strace telnet tmux tuned tuned-utils unixODBC unixODBC-devel unzip vim-X11 vim-common vim-enhanced vim-filesystem vim-minimal wget xorg-x11-server-Xorg xorg-x11-server-common xorg-x11-utils xorg-x11-xauth xterm.x86_64 whois"
#
if [[ ${OS_VERSION} == "6".* ]]; then 
  if [[ $(rpm -q --qf '%{NAME}-%{VERSION}-%{RELEASE} (%{ARCH})\n' ${PACKAGES_6} | egrep "is not installed" | wc -l) != 0 ]]; then
	yum -y install ${PACKAGES_6}
  else
    rpm -q --qf '%{NAME}-%{VERSION}-%{RELEASE} (%{ARCH})\n' ${PACKAGES_6} | egrep "is not installed"
  fi
elif [[ ${OS_VERSION} == "7".* ]]; then 
  if [[ $(rpm -q --qf '%{NAME}-%{VERSION}-%{RELEASE} (%{ARCH})\n' ${PACKAGES_7} | egrep "is not installed" | wc -l) != 0 ]]; then
	yum -y install ${PACKAGES_7}
  else
    rpm -q --qf '%{NAME}-%{VERSION}-%{RELEASE} (%{ARCH})\n' ${PACKAGES_7} | egrep "is not installed"
  fi
elif [[ ${OS_VERSION} == "8".* ]]; then 
  if [[ $(rpm -q --qf '%{NAME}-%{VERSION}-%{RELEASE} (%{ARCH})\n' ${PACKAGES_8} | egrep "is not installed" | wc -l) != 0 ]]; then
  	dnf -y install ${PACKAGES_8}
  else
    rpm -q --qf '%{NAME}-%{VERSION}-%{RELEASE} (%{ARCH})\n' ${PACKAGES_8} | egrep "is not installed"
  fi
fi
# ------------------------------------------------------------------------
# Setup /etc/hosts
#
cat >> /etc/hosts <<EOF
#
$(ip a | egrep -v "inet6|127.0.0.1" | egrep "inet" | awk '{ print $2 }' | cut -f1 -d '/')   $(hostname)   $(hostname -s)
EOF
#
# ------------------------------------------------------------------------
# Disable SELINUX
#
cat > /etc/sysconfig/selinux <<EOF
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=disabled
# SELINUXTYPE= can take one of these two values:
#     targeted - Targeted processes are protected,
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted
EOF
#
# ------------------------------------------------------------------------
# Kernel Parameters With 90% of Total Memory
#
MEM=$(free | grep Mem | awk '{ print $2 }'); TOTALMEM=$(echo "${MEM}*1024" | bc); HUGEPG=$(grep Hugepagesize /proc/meminfo | awk '{ print $2 }'); MAX=$(echo "${TOTALMEM}*90/100" | bc); ALL=$(echo "${MAX}/${HUGEPG}" | bc)
#
cat >> /etc/sysctl.conf <<EOF
#
# ORACLE PARAMETERS FOR SINGLE/RAC/MAA/RESTART/DG/OGG
#
fs.file-max = 6815744
fs.aio-max-nr = 1048576
vm.swappiness = 0
vm.dirty_background_ratio = 3
vm.dirty_ratio = 15
vm.dirty_expire_centisecs = 500
vm.dirty_writeback_centisecs = 100
# vm.min_free_kbytes = 5248000
# vm.nr_hugepages = ${HUGEPG}
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 4194304
net.ipv4.tcp_rmem = 4096 262144 4194304
net.ipv4.tcp_wmem = 4096 262144 4194304
net.ipv4.ip_local_port_range = 9000 65500
net.ipv4.conf.all.rp_filter = 2
net.ipv4.conf.default.rp_filter = 2
net.ipv4.tcp_keepalive_time = 30
net.ipv4.tcp_keepalive_intvl = 60
net.ipv4.tcp_keepalive_probes = 9
net.ipv4.tcp_retries2 = 3
net.ipv4.tcp_syn_retries = 2
kernel.panic_on_oops = 1
kernel.sem = 250 32000 128 2048
kernel.shmmax = ${MAX}
kernel.shmmni = 4096
kernel.shmall = ${ALL}
EOF
#
/sbin/sysctl -p
#
sysctl -p
# 
# ------------------------------------------------------------------------
# Configure limits.conf
#
cat >> /etc/security/limits.conf <<EOF
#
# Oracle Limits Configuration
#
* soft nproc 2047
* hard nproc 16384
* soft nofile 65536
* hard nofile 65536
* soft stack 10240
* hard stack 32768
* soft memlock 60397977
* hard memlock 60397977
EOF
#
# ------------------------------------------------------------------------
# Linux Groups
#
/usr/sbin/groupadd -g 54321 oinstall
/usr/sbin/groupadd -g 54322 dba
/usr/sbin/groupadd -g 54323 oper
/usr/sbin/groupadd -g 54324 backupdba
/usr/sbin/groupadd -g 54325 dgdba
/usr/sbin/groupadd -g 54326 kmdba
/usr/sbin/groupadd -g 54327 asmdba
/usr/sbin/groupadd -g 54328 asmadmin
/usr/sbin/groupadd -g 54329 asmoper
/usr/sbin/groupadd -g 54330 racdba
/usr/sbin/groupadd -g 54331 racoper
#
# ------------------------------------------------------------------------
# Linux Users
#
/usr/sbin/useradd -u 54321 -g oinstall -G oinstall,dba,oper,backupdba,asmdba,dgdba,kmdba,racdba,racoper oracle
/usr/sbin/useradd -u 54322 -g oinstall -G oinstall,dba,asmdba,asmadmin,asmoper,racdba,racoper grid
#
# ------------------------------------------------------------------------
# Verify Users and Groups
#
cat /etc/group | egrep -i "oracle|grid"
#
#
# ------------------------------------------------------------------------
# Create Users Password
#
echo 'oracle:oracle' | chpasswd
echo 'grid:grid' | chpasswd
#
# ------------------------------------------------------------------------
# Creating Directories to Grid and Database Installation
#
mkdir -p /u01/app/oraInventory
chmod -R 775 /u01/app/oraInventory
chmod -R g+w /u01/app/oraInventory
#
mkdir -p /u01/app/grid
mkdir -p /u01/app/grid/diag
#
mkdir -p /u01/app/oracle
mkdir -p /u01/app/oracle/diag
#
chown -R grid.oinstall /u01
chown -R grid.oinstall /u01/app/grid
chown -R grid.oinstall /u01/app/grid/diag
#
chown -R oracle.oinstall /u01/app/oracle
chown -R oracle.oinstall /u01/app/oracle/diag
#
chmod -R 775 /u01/
#
# ------------------------------------------------------------------------
# Mount tmpfs automatically on Linux
#
FULL_MEM=$(free -g | egrep -i "Mem:" | awk '{ print $2}')
echo "tmpfs                                     /dev/shm                tmpfs   size=${FULL_MEM}g        0 0" >> /etc/fstab
#
cat /etc/fstab
#
mount -a
#
df -Th
#
# ------------------------------------------------------------------------
# Creating and Installing the DBNITRO Components
#
wget -O /tmp/dbnitro.sh https://raw.githubusercontent.com/dbaribas/dbnitro/main/dbnitro.sh
chmod a+x /tmp/dbnitro.sh
sh /tmp/dbnitro.sh
#
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
# THE SCRIPT FINISHES HERE
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
#