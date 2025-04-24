#!/bin/sh
#
Author="Andre Augusto Ribas"
SoftwareVersion="1.0.5"
DateCreation="19/02/2024"
DateModification="17/04/2024"
EMAIL="ribas@dbnitro.net"
GITHUB="https://github.com/dbaribas/dbnitro.net"
WEBSITE="http://dbnitro.net"
#
# ------------------------------------------------------------------------
# Using WGET to download My Oracle Support Patches (Doc ID 980924.1)
#
# ------------------------------------------------------------------------
# Variables
#
PLATFORM="$(uname -i)"
#
if [[ "${PLATFORM}" == "x86_64" ]]; then 
  ARCHITECTURE="x86_64"
elif [[ "${PLATFORM}" == "aarch64" ]]; then
  ARCHITECTURE="ARM-64"
else
  echo "###############################################################"
  echo " -- Your platform architecture ${PLATFORM} is not supported!!!"
  exit 1
fi
#
# ------------------------------------------------------------------------
# Clear Screen Function
#
SetClear() {
  printf "\033c"
}
# ------------------------------------------------------------------------
#
SetClear
echo "###############################################################"
echo " -- Insert your MOS Account to download the patches --"
read -p    'Username: ' USERNAME
read -s -p 'Password: ' PASSWORD
echo ""
#
# ------------------------------------------------------------------------
#
if [[ "${USERNAME}" == "" ]]; then
  echo "###############################################################"
  echo " -- Username can not be empty, please insert the information!!!"
  exit 1
fi
#
if [[ "${PASSWORD}" == "" ]]; then
  echo "###############################################################"
  echo " -- Password can not be empty, please insert the information!!!"
  exit 1
fi
#
# ------------------------------------------------------------------------
# Help to use this script
#
HELP() {
echo -e "\
|#| OracleFree.......: YOU WILL DOWNLOAD THE ORACLE 23c Free Version
|#| Oracle19c........: YOU WILL DOWNLOAD THE ORACLE 19c Enterprise Version
|#| Oracle21c........: YOU WILL DOWNLOAD THE ORACLE 21c Enterprise Version
|#| Oracle23c........: YOU WILL DOWNLOAD THE ORACLE 23c Enterprise Version
|#| Oracle19cApr2023.: YOU WILL DOWNLOAD THE ORACLE PATCHES FROM APRIL 2023
|#| Oracle19cJul2023.: YOU WILL DOWNLOAD THE ORACLE PATCHES FROM JULY 2023
|#| Oracle19cOct2023.: YOU WILL DOWNLOAD THE ORACLE PATCHES FROM OCTOBER 2023
|#| Oracle19cJan2024.: YOU WILL DOWNLOAD THE ORACLE PATCHES FROM JANUARY 2024
|#| Oracle19cJan2024.: YOU WILL DOWNLOAD THE ORACLE PATCHES FROM APRIL 2024
|#| HELP.............: YOU CAN CHECK THE OPTIONS"
}
#
# ------------------------------------------------------------------------
# Oracle Free 23c
#
OracleFree() {
if [[ "${ARCHITECTURE}" == "x86_64" ]]; then 
  wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="oracle-database-free-23c-1.0-1.el8.x86_64.rpm" "https://download.oracle.com/otn-pub/otn_software/db-free/oracle-database-free-23c-1.0-1.el8.x86_64.rpm?patch_password=patch_password"
else
  echo "###############################################################"
  echo " -- Your platform architecture ${PLATFORM} is not supported!!!"
  return 1
fi
}
#
# ------------------------------------------------------------------------
#
Oracle19c() {
if [[ "${ARCHITECTURE}" == "x86_64" ]]; then 
  wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="LINUX.X64_193000_grid_home.zip" "https://download.oracle.com/otn/linux/oracle19c/190000/LINUX.X64_193000_grid_home.zip?patch_password=patch_password"
  wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="LINUX.X64_193000_db_home.zip" "https://download.oracle.com/otn/linux/oracle19c/190000/LINUX.X64_193000_db_home.zip?patch_password=patch_password"
elif [[ "${ARCHITECTURE}" == "ARM-64" ]]; then
  wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="LINUX.ARM64_1919000_grid_home.zip" "https://download.oracle.com/otn/linux/oracle19c/1919000/LINUX.ARM64_1919000_grid_home.zip?patch_password=patch_password"
  wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="LINUX.ARM64_1919000_db_home.zip" "https://download.oracle.com/otn/linux/oracle19c/1919000/LINUX.ARM64_1919000_db_home.zip?patch_password=patch_password"
else
  echo "###############################################################"
  echo " -- Your platform architecture ${PLATFORM} is not supported!!!"
  return 1
fi
}
#
# ------------------------------------------------------------------------
# Oracle 21c
#
Oracle21c() {
if [[ "${ARCHITECTURE}" == "x86_64" ]]; then 
  wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="LINUX.X64_213000_grid_home.zip" "https://download.oracle.com/otn/linux/oracle21c/LINUX.X64_213000_grid_home.zip?patch_password=patch_password"
  wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="LINUX.X64_213000_db_home.zip" "https://download.oracle.com/otn/linux/oracle21c/LINUX.X64_213000_db_home.zip?patch_password=patch_password"
else
  echo "###############################################################"
  echo " -- Your platform architecture ${PLATFORM} is not supported!!!"
  return 1
fi
}
#
#
# ------------------------------------------------------------------------
#
Oracle23c() {
  # wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p6880880_190000_Linux-${ARCHITECTURE}.zip" "https://updates.oracle.com/Orion/Download/download_patch/p6880880_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  echo "Oracle 23c Is Not Available Yet."
}
#
#
# ------------------------------------------------------------------------
#
Oracle19cApr2023() {
wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p6880880_190000_Linux-${ARCHITECTURE}.zip" "https://updates.oracle.com/Orion/Download/download_patch/p6880880_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p29511771_190000_Linux-${ARCHITECTURE}.zip" "https://updates.oracle.com/Orion/Download/download_patch/p29511771_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p30432118_190000_Linux-${ARCHITECTURE}.zip" "https://updates.oracle.com/Orion/Download/download_patch/p30432118_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p33912872_190000_Linux-${ARCHITECTURE}.zip" "https://updates.oracle.com/Orion/Download/download_patch/p33912872_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p34777391_190000_Linux-${ARCHITECTURE}.zip" "https://updates.oracle.com/Orion/Download/download_patch/p34777391_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p35037840_190000_Linux-${ARCHITECTURE}.zip" "https://updates.oracle.com/Orion/Download/download_patch/p35037840_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p35042068_190000_Linux-${ARCHITECTURE}.zip" "https://updates.oracle.com/Orion/Download/download_patch/p35042068_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p35050341_190000_Linux-${ARCHITECTURE}.zip" "https://updates.oracle.com/Orion/Download/download_patch/p35050341_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p30971231_196000OCWRU_Linux-${ARCHITECTURE}.zip" "https://updates.oracle.com/Orion/Download/download_patch/p30971231_196000OCWRU_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p35068505_1919000ACFSRU_Linux-${ARCHITECTURE}.zip" "https://updates.oracle.com/Orion/Download/download_patch/p35068505_1919000ACFSRU_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
}
#
# ------------------------------------------------------------------------
#
Oracle19cJul2023() {
wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p6880880_190000_Linux-${ARCHITECTURE}.zip" "https://updates.oracle.com/Orion/Download/download_patch/p6880880_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p35319490_190000_Linux-${ARCHITECTURE}.zip" "https://updates.oracle.com/Orion/Download/download_patch/p35319490_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p35320081_190000_Linux-${ARCHITECTURE}.zip" "https://updates.oracle.com/Orion/Download/download_patch/p35320081_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p35336174_190000_Linux-${ARCHITECTURE}.zip" "https://updates.oracle.com/Orion/Download/download_patch/p35336174_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p35354406_190000_Linux-${ARCHITECTURE}.zip" "https://updates.oracle.com/Orion/Download/download_patch/p35354406_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
}
#
# ------------------------------------------------------------------------
#
Oracle19cOct2023() {
wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p6880880_190000_Linux-${ARCHITECTURE}.zip" "https://updates.oracle.com/Orion/Download/download_patch/p6880880_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p35638318_190000_Linux-${ARCHITECTURE}.zip" "https://updates.oracle.com/Orion/Download/download_patch/p35638318_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p35642822_190000_Linux-${ARCHITECTURE}.zip" "https://updates.oracle.com/Orion/Download/download_patch/p35642822_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p35643107_190000_Linux-${ARCHITECTURE}.zip" "https://updates.oracle.com/Orion/Download/download_patch/p35643107_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p35648110_190000_Linux-${ARCHITECTURE}.zip" "https://updates.oracle.com/Orion/Download/download_patch/p35648110_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p35988503_1921000ACFSRU_Linux-${ARCHITECTURE}.zip" "https://updates.oracle.com/Orion/Download/download_patch/p35988503_1921000ACFSRU_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
}
#
# ------------------------------------------------------------------------
#
Oracle19cJan2024() {
wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p6880880_190000_Linux-${ARCHITECTURE}.zip" "https://updates.oracle.com/Orion/Download/download_patch/p6880880_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p35926646_190000_Linux-${ARCHITECTURE}.zip" "https://updates.oracle.com/Orion/Download/download_patch/p35926646_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p35940989_190000_Linux-${ARCHITECTURE}.zip" "https://updates.oracle.com/Orion/Download/download_patch/p35940989_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p35943157_190000_Linux-${ARCHITECTURE}.zip" "https://updates.oracle.com/Orion/Download/download_patch/p35943157_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p35949090_190000_Linux-${ARCHITECTURE}.zip" "https://updates.oracle.com/Orion/Download/download_patch/p35949090_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p35988503_1922000ACFSRU_Linux-${ARCHITECTURE}.zip" "https://updates.oracle.com/Orion/Download/download_patch/p35988503_1922000ACFSRU_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
}
#
# ------------------------------------------------------------------------
#
Oracle19cApr2024() {
wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p6880880_190000_Linux-${ARCHITECTURE}.zip" "https://updates.oracle.com/Orion/Download/download_patch/p6880880_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p36233263_190000_Linux-${ARCHITECTURE}_DB.zip" "https://updates.oracle.com/Orion/Download/download_patch/p36233263_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p36233126_190000_Linux-${ARCHITECTURE}_GI.zip" "https://updates.oracle.com/Orion/Download/download_patch/p36233126_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p36199232_190000_Linux-${ARCHITECTURE}_OJVM.zip" "https://updates.oracle.com/Orion/Download/download_patch/p36199232_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p36195566_190000_Linux-${ARCHITECTURE}_JDK.zip" "https://updates.oracle.com/Orion/Download/download_patch/p36195566_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
# wget --http-user="${USERNAME}" --http-password="${PASSWORD}" --no-check-certificate --output-document="p???_19??000ACFSRU_Linux-${ARCHITECTURE}.zip" "https://updates.oracle.com/Orion/Download/download_patch/p???_19??000ACFSRU_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
}
#
# ------------------------------------------------------------------------
# Main Menu
#
MainMenu() {
printf "+%-30s+%-100s+\n" "------------------------------" "----------------------------------------------------------------------------------------------------"
printf "|%-16s|%-100s|\n" " DBNITRO.net                  " " ORACLE :: Select an Option "
printf "+%-30s+%-100s+\n" "------------------------------" "----------------------------------------------------------------------------------------------------"
PS3="Select the Option: "
select OPT in OracleFree Oracle19c Oracle21c Oracle23c 19cApr2023 19cJul2023 19cOct2023 19cJan2024 19cApr2024 HELP QUIT; do
if [[ "${OPT}" == "OracleFree" ]]; then
  echo "###############################################################"
  echo " -- Downloading Oracle Product: ${OPT} Started --"
  echo ""
  OracleFree
  echo " -- Downloading Oracle Product: ${OPT} Finished --"
  echo ""
  MainMenu
elif [[ "${OPT}" == "Oracle19c" ]]; then
  echo "###############################################################"
  echo " -- Downloading Oracle Product: ${OPT} Started --"
  echo ""
  Oracle19c
  echo " -- Downloading Oracle Product: ${OPT} Finished --"
  echo ""
  MainMenu
elif [[ "${OPT}" == "Oracle21c" ]]; then
  echo "###############################################################"
  echo " -- Downloading Oracle Product: ${OPT} Started --"
  echo ""
  Oracle21c
  echo " -- Downloading Oracle Product: ${OPT} Finished --"
  echo ""
  MainMenu
elif [[ "${OPT}" == "Oracle23c" ]]; then
  echo "###############################################################"
  echo " -- Downloading Oracle Product: ${OPT} Started --"
  echo ""
  Oracle23c
  echo "###############################################################"
  echo " -- Downloading Oracle Product: ${OPT} Finished --"
  echo ""
  MainMenu
elif [[ "${OPT}" == "19cApr2023" ]]; then
  echo "###############################################################"
  echo " -- Downloading Oracle Patch: ${OPT} Started --"
  echo ""
  Oracle19cApr2023
  echo "###############################################################"
  echo " -- Downloading Oracle Patch: ${OPT} Finished --"
  echo ""
  MainMenu
elif [[ "${OPT}" == "19cJul2023" ]]; then
  echo "###############################################################"
  echo " -- Downloading Oracle Patch: ${OPT} Started --"
  echo ""
  Oracle19cJul2023
  echo "###############################################################"
  echo " -- Downloading Oracle Patch: ${OPT} Finished --"
  echo ""
  MainMenu
elif [[ "${OPT}" == "19cOct2023" ]]; then
  echo "###############################################################"
  echo " -- Downloading Oracle Patch: ${OPT} Started --"
  echo ""
  Oracle19cOct2023
  echo "###############################################################"
  echo " -- Downloading Oracle Patch: ${OPT} Finished --"
  echo ""
  MainMenu
elif [[ "${OPT}" == "19cJan2024" ]]; then
  echo "###############################################################"
  echo " -- Downloading Oracle Patch: ${OPT} Started --"
  echo ""
  Oracle19cJan2024
  echo "###############################################################"
  echo " -- Downloading Oracle Patch: ${OPT} Finished --"
  echo ""
  MainMenu
elif [[ "${OPT}" == "19cApr2024" ]]; then
  echo "###############################################################"
  echo " -- Downloading Oracle Patch: ${OPT} Started --"
  echo ""
  Oracle19cApr2024
  echo "###############################################################"
  echo " -- Downloading Oracle Patch: ${OPT} Finished --"
  echo ""
  MainMenu
elif [[ "${OPT}" == "QUIT" ]]; then
  echo "###############################################################"
  echo " -- Exit Menu --"
  echo ""
  exit 1
elif [[ "${OPT}" == "HELP" ]]; then
  HELP
  MainMenu
else
  echo "###############################################################"
  echo " -- Invalid Option --"
  echo ""
  return 1
fi
break
done
}
#
MainMenu
#
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
# THE SCRIPT FINISHES HERE
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
#