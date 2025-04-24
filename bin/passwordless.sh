#!/bin/sh
# "-------------------------------------------------------------------------------------------------------------"
#
Author="Andre Augusto Ribas"
SoftwareVersion="1.0.3"
DateCreation="24/10/2024"
DateModification="28/10/2024"
EMAIL="ribas@dbnitro.net"
GITHUB="https://github.com/dbaribas/dbnitro.net"
WEBSITE="http://dbnitro.net"
#
# "-------------------------------------------------------------------------------------------------------------"
#
if [[ "$#" -lt 1 ]]; then
  echo "Usage: $0 srv01 srv02 srv03 ..."
  exit 1
fi
#
SERVERS=("$@")
#
USER() {
     USER=""
  SSHPASS=""
PS3="Select the Option: "
select USER in root grid oracle; do
  read -sp "Enter SSH password for ${USER}: " SSHPASS
  echo
break
done
}
USER
#
for SERVER in "${SERVERS[@]}"; do
  echo "Copying SSH key to ${USER}@${SERVER}"
  sshpass -p "$SSHPASS" ssh-copy-id -o StrictHostKeyChecking=no "${USER}@${SERVER}"
  #
  echo "Testing connection to ${USER}@${SERVER}"
  ssh "${USER}@${SERVER}" 'echo "$(date +%Y-%m-%d_%H\:%M\:%S): Connection successful."'
done
echo "SSH key copied to all servers."