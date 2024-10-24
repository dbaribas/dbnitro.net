#!/bin/sh
# "-------------------------------------------------------------------------------------------------------------"
#
Author="Andre Augusto Ribas"
SoftwareVersion="1.1.1"
DateCreation="24/10/2024"
DateModification="24/10/2024"
EMAIL_1="andre.ribas@icloud.com"
EMAIL_2="dba.ribas@gmail.com"
WEBSITE="http://dbnitro.net"
#
# "-------------------------------------------------------------------------------------------------------------"
#
if [[ "$#" -lt 1 ]]; then
  echo "Usage: $0 srv01 srv02 server3 ..."
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
if [[ "${USER}" == "root" ]]; then
  read -sp "Enter SSH password for ${USER}: " SSHPASS
  echo
elif [[ "${USER}" == "grid" ]]; then
  read -sp "Enter SSH password for ${USER}: " SSHPASS
  echo
elif [[ "${USER}" == "oracle" ]]; then
  read -sp "Enter SSH password for ${USER}: " SSHPASS
  echo
fi
break
done
}
USER

# Loop through all servers and copy the SSH key using sshpass and ssh-copy-id
#
for SERVER in "${SERVERS[@]}"; do
  echo "Copying SSH key to ${USER}@${SERVER}"
  sshpass -p "$SSHPASS" ssh-copy-id -o StrictHostKeyChecking=no "${USER}@${SERVER}"

  # Test the connection and show the date on the remote server
  echo "Testing connection to ${USER}@${SERVER}"
  ssh "${USER}@${SERVER}" 'echo "Connection successful. Server date:"; date'
done
echo "SSH key copied to all servers."
