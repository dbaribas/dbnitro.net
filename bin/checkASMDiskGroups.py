#!/bin/python
#
# $Header: tfa/src/v2/tfa_home/resources/scripts/checkASMDiskGroups.py /main/1 2022/07/01 12:53:11 bvongray Exp $
#
# checkASMDiskGroups.py
#
# Copyright (c) 2022, Oracle and/or its affiliates.
#
#    NAME
#      checkASMDiskGroups.py - ASM Diskgroup Validation
#
#    DESCRIPTION
#      Provided and Maintained by Scalability Support Team
#       Only change from MOS version is the date stamp in the filename is removed
#
#    NOTES
#      N/A
#
#    MODIFIED   (MM/DD/YY)
#    mhunasigi    01 July 2022 - Creation
#    mhunasigi    04 July 2022 - Identify diskgroup member disks and determine its mount state
#    mhunasigi    15 July 2022 - Added logic to detect AFD/ASMLib disks
#    mhunasigi    21 July 2022 - Changed pattern to detect provisioning string
#    mhunasigi    21 July 2022 - Append '/*' if discovery string is a directory to detect disks at OS level (using glob module)
#    mhunasigi    28 July 2022 - Check disk backup header if corruption found in primary header
#    mhunasigi    09 Dec 2022  - Sanitize characters ($`;<>&|) from command output to avoid possibility of a command injection
##############################################################################################

SCRIPT_VERSION = "09122022"

import os, re, sys, pwd, grp, glob, logging, tarfile, argparse, datetime, platform, subprocess, xml.etree.ElementTree as ET

class Diskgroup:
  ausize: str = "0"
  redundancy: str = ""
  state: str = "N/A"
  dg_name: str = ""

  def __init__(self,dg_name,disks):
    self.dg_members = list()
    self.mount_time = set()
    self.dg_name = dg_name
    CMD = [ASMCMD, "lsdg", "--suppressheader", self.dg_name]
    logging.info(f"Executing \'{' '.join(CMD)}\'")
    RESULT = subprocess.run(CMD,stdout=subprocess.PIPE,stderr=subprocess.PIPE)

    for LINE in RESULT.stdout.decode().splitlines():
      LINE = sanitizeCharInLine(LINE)
      if dg_name in LINE and "ASMCMD-8001" not in LINE:
        self.state = LINE.split()[0]
        break
    else:
      logging.info(f"STDOUT = {RESULT.stdout.decode()}\nSTDERR = {RESULT.stderr.decode()}\n")
      logging.error(f"Error : Could not fetch information regarding diskgroup '{self.dg_name}' by executing {' '.join(CMD)}")

    for disk in disks:
      if disk.primary_header['kfdhdb_grpname'] == self.dg_name:
        self.dg_members.append(disk)
        self.mount_time.add(disk.primary_header['mount_time'])
        if self.ausize == "0":
          self.ausize = disk.primary_header['kfdhdb_ausize']
        elif self.ausize != disk.primary_header['kfdhdb_ausize']:
          logging.error(f"Error : AU size of disk '{disk.disk_path}' does not match the AU size found for other disks in the diskgroup ({self.dg_name})\n")
        if self.redundancy == "":
          self.redundancy = disk.primary_header['kfdhdb_grptyp'].split("_")[1]
        elif self.redundancy != disk.primary_header['kfdhdb_grptyp'].split("_")[1]:
          logging.error(f"Error : Redundancy of disk '{disk.disk_path}' does not match the redundancy found for other disks in the diskgroup ({self.dg_name})\n")

    # All disks in the diskgroup should have the same mount timestamp
    if len(self.mount_time) > 1:
      logging.error(f"Error : Disks in diskgroup '{self.dg_name}' have different mount timestamps")

  def __str__(self):
    members = list()
    for disk in self.dg_members:
      members.append(disk.disk_path + " (" + disk.primary_header['kfdhdb_dsknum'] + ")")
    return (
      self.dg_name + " : \n\t" +
      "State : " + self.state + "\n\t" +
      "Last Mount Time (yyyy/mm/dd hh:mm:ss.ms) : " + self.mount_time.copy().pop() + "\n\t" +
      "AU Size : " + self.ausize + " bytes \n\t" +
      "Redundancy : " + self.redundancy + "\n\t" +
      "Member Disks : " + " , ".join(members) + "\n"
    )

class Disk:
  disk_path: str = ""
  disk_permission: str = ""
  disk_permission_ok: str = ""
  owner: str = ""
  owner_ok: str = ""
  group: str = ""
  kfed_output_primary: str = ""
  kfed_output_backup: str = ""

  def __init__(self,disk_path):
    self.primary_header = {'valid_asm_disk':False, 'voting_file_found':False, 'voting_file_location':'', 'kfbh_endian':'', 'kfbh_type':'', 'kfdhdb_driver_provstr':'', 'kfdhdb_compat':'', 'kfdhdb_dsknum':'', 'kfdhdb_grptyp':'', 'kfdhdb_hdrsts':'', 'kfdhdb_dskname':'', 'kfdhdb_grpname':'', 'kfdhdb_fgname':'', 'kfdhdb_crestmp_hi':'', 'kfdhdb_crestmp_lo':'', 'kfdhdb_mntstmp_hi':'', 'kfdhdb_mntstmp_lo':'', 'kfdhdb_secsize':'', 'kfdhdb_blksize':'', 'kfdhdb_ausize':'0', 'kfdhdb_dsksize':'0', 'kfdhdb_dbcompat':'', 'kfdhdb_grpstmp_hi':'', 'kfdhdb_grpstmp_lo':'', 'kfdhdb_vfstart':'', 'kfdhdb_vfend':'', 'pst_metadata_found':False, 'mount_time':''}
    self.backup_header = {'valid_asm_disk':False, 'voting_file_found':False, 'voting_file_location':'', 'kfbh_endian':'', 'kfbh_type':'', 'kfdhdb_driver_provstr':'', 'kfdhdb_compat':'', 'kfdhdb_dsknum':'', 'kfdhdb_grptyp':'', 'kfdhdb_hdrsts':'', 'kfdhdb_dskname':'', 'kfdhdb_grpname':'', 'kfdhdb_fgname':'', 'kfdhdb_crestmp_hi':'', 'kfdhdb_crestmp_lo':'', 'kfdhdb_mntstmp_hi':'', 'kfdhdb_mntstmp_lo':'', 'kfdhdb_secsize':'', 'kfdhdb_blksize':'', 'kfdhdb_ausize':'0', 'kfdhdb_dsksize':'0', 'kfdhdb_dbcompat':'', 'kfdhdb_grpstmp_hi':'', 'kfdhdb_grpstmp_lo':'', 'kfdhdb_vfstart':'', 'kfdhdb_vfend':'', 'pst_metadata_found':False, 'mount_time':''}
    self.disk_path = disk_path
    self.disk_permission = oct(os.stat(disk_path).st_mode)[-4:]
    self.disk_permission_ok = "yes" if self.disk_permission >= "0600" else "no"
    self.owner = pwd.getpwuid(os.stat(disk_path).st_uid).pw_name
    self.owner_ok = "yes" if CRS_OWNER == self.owner else "no"
    self.group = grp.getgrgid(os.stat(disk_path).st_gid).gr_name
    OUTPUT = self.read_disk_headers(HDR="primary")
    self.parse_kfed_output()
    OPTS = "aun=11 ausz=" + self.primary_header['kfdhdb_ausize']
    OUTPUT = self.read_disk_headers(OPTS=OPTS,HDR="backup")
    self.parse_kfed_output(HDR="backup")
    if self.primary_header['valid_asm_disk'] and self.primary_header['kfdhdb_ausize'] != "0":
      self.check_pst_existence()
    MOUNT_TIMESTAMP = self.primary_header['kfdhdb_mntstmp_hi'] + " " + self.primary_header['kfdhdb_mntstmp_lo']
    PATTERN = r"HOUR=(?P<HOUR>\w+)\s+DAYS=(?P<DAYS>\w+)\s+MNTH=(?P<MONTH>\w+)\s+YEAR=(?P<YEAR>\w+)\s+USEC=(?P<USEC>\w+)\s+MSEC=(?P<MSEC>\w+)\s+SECS=(?P<SECS>\w+)\s+MINS=(?P<MINS>\w+)"
    RES = re.match(PATTERN,MOUNT_TIMESTAMP,re.IGNORECASE)
    if RES != None:
      year = int(RES.group('YEAR'),16)
      month = int(RES.group('MONTH'),16)
      days = int(RES.group('DAYS'),16)
      hour = int(RES.group('HOUR'),16)
      minutes = int(RES.group('MINS'),16)
      seconds = int(RES.group('SECS'),16)
      msec = int(RES.group('MSEC'),16) + int(int(RES.group('USEC'),16)/1000)
      self.primary_header['mount_time'] = f"{year:04d}/{month:02d}/{days:02d} {hour:02d}:{minutes:02d}:{seconds:02d}.{msec}"
    else:
      logging.error(f"Could not get last mount time of disk '{self.disk_path}' by reading the headers")

  def __str__(self):
    if not self.primary_header['valid_asm_disk']:
      return (self.disk_path + " => Not an ASM disk")
    return (self.disk_path + "\n\t" +
      "Diskgroup Name : " + self.primary_header['kfdhdb_grpname'] + "\n\t" +
      "Valid ASM Disk : " + str(self.primary_header['valid_asm_disk']) + "\n\t" +
      "Last Mount Time (yyyy/mm/dd hh:mm:ss.ms) : " + self.primary_header['mount_time'] + "\n\t" +
      "Disk Name : " + self.primary_header['kfdhdb_dskname'] + "\n\t" +
      "Disk Number : " + self.primary_header['kfdhdb_dsknum'] + "\n\t" +
      "Disk Endian : " + self.primary_header['kfbh_endian'] + f" ({sys.byteorder})\n\t" + 
      "OS Endian : " + ENDIAN_DICT[sys.byteorder] + f" ({sys.byteorder})\n\t" +
      "Voting File Found : " + str(self.primary_header['voting_file_found']) + "\n\t" +
      "Voting File Location (AU#) : " + self.primary_header['voting_file_location'] + "\n\t" +
      "Permission : " + self.disk_permission + "\n\t" +
      "Owner : " + self.owner + "\n\t" +
      "Group : " + self.group + "\n\t" +
      "Redundancy : " + self.primary_header['kfdhdb_grptyp'].split("_")[1] + "\n\t" +
      "Header Status : " + self.primary_header['kfdhdb_hdrsts'].split("_")[1] + "\n\t" +
      "Provisioning String : " + self.primary_header['kfdhdb_driver_provstr'] + "\n\t" +
      "Sector Size : " + self.primary_header['kfdhdb_secsize'] + " bytes \n\t" +
      "Block Size : " + self.primary_header['kfdhdb_blksize'] + " bytes \n\t" +
      "AU Size : " + self.primary_header['kfdhdb_ausize'] + " bytes \n\t" +
      "Disk Size : " + self.primary_header['kfdhdb_dsksize'] + "\n\t" +
      "Partner Status Table (PST) metadata found: " + str(self.primary_header['pst_metadata_found'])
    )

  def get_attr_from_backup_header(self,VAL):
    return self.backup_header.get(VAL,None)

  def check_disk_header_corruption(self):
    DISK_HEADER_CORRUPTION_FOUND = False
    ELEM = ET.SubElement(ROOT, "CHECK")
    ELEM.set("name", "check_provstr_" + os.path.basename(self.disk_path))
    ELEM.set("disk", self.disk_path)
    ELEM.set("kfdhdb_driver_provstr", self.primary_header['kfdhdb_driver_provstr'])
    ELEM_RESULT = ET.SubElement(ELEM, "RESULT")
    if not self.check_provstr():
      if not self.check_provstr(HDR='backup'):
        logging.error(f"Error : Both primary and backup headers are corrupt")
        logging.error(f"self.primary_header['kfdhdb_driver_provstr']")
        logging.error(f"self.backup_header['kfdhdb_driver_provstr']")
        ELEM_RESULT.text = "FAILED"
        return
      logging.error(f"Error : The provisioning string in header of disk '{self.disk_path}' is corrupt")
      CAUSE = f"Cause : The provisioning string in header of disk '{self.disk_path}' is corrupt"
      RECOMMENDATION = f"Action Plan : Execute \'ORACLE_HOME={os.environ.get('ORACLE_HOME',None)} {KFED} repair {self.disk_path} ausz={self.primary_header['kfdhdb_ausize']}\' command to fix the header"
      logging.error(CAUSE)
      logging.error(RECOMMENDATION)
      ELEM_CAUSE = ET.SubElement(ELEM, "CAUSE")
      ELEM_RECOMMENDATION = ET.SubElement(ELEM, "RECOMMENDATION")
      ELEM_CAUSE.text = CAUSE
      ELEM_RECOMMENDATION.text = RECOMMENDATION
      DISK_HEADER_CORRUPTION_FOUND = True
      ELEM_RESULT.text = "FAILED"
    else:
      logging.info(f"Info : The provisioning string in header of disk '{self.disk_path}' is intact")
      ELEM_RESULT.text = "PASSED"

    ELEM = ET.SubElement(ROOT, "CHECK")
    ELEM.set("name", "validate_endianness")
    ELEM.set("ENDIAN_OS", f"{ENDIAN_DICT[sys.byteorder]} ({sys.byteorder})")
    ELEM.set("ENDIAN_" + os.path.basename(self.disk_path), f"{self.primary_header['kfbh_endian']} ({sys.byteorder})")
    ELEM_RESULT = ET.SubElement(ELEM, "RESULT")
    if not self.validate_endianness():
      logging.error(f"Alert!!! Endianness recorded in header of disk '{self.disk_path}' does not match the endianness of the platform\n")
      CAUSE = f"Cause : The endianness recorded in header of disk '{self.disk_path}' does not match the endianness of the platform"
      RECOMMENDATION = f"Action Plan : Check backup header (AU 11) of disk '{self.disk_path}' by executing \'kfed read {self.disk_path} aun=11 ausz={self.primary_header['kfdhdb_ausize']}\' and if the endian is proper, use \'kfed repair {self.disk_path} ausz={self.primary_header['kfdhdb_ausize']}\' command to fix the header"
      logging.error(CAUSE)
      logging.error(RECOMMENDATION)
      ELEM_CAUSE = ET.SubElement(ELEM, "CAUSE")
      ELEM_RECOMMENDATION = ET.SubElement(ELEM, "RECOMMENDATION")
      ELEM_CAUSE.text = CAUSE
      ELEM_RECOMMENDATION.text = RECOMMENDATION
      DISK_HEADER_CORRUPTION_FOUND = True
      ELEM_RESULT.text = "FAILED"
    else:
      logging.info(f"Info : The endian in header of disk '{self.disk_path}' is intact\n")
      ELEM_RESULT.text = "PASSED"
        
    ELEM = ET.SubElement(ROOT, "CHECK")
    ELEM.set("name", "check_disk_header_corruption_" + os.path.basename(self.disk_path))
    ELEM_RESULT = ET.SubElement(ELEM, "RESULT")
    if DISK_HEADER_CORRUPTION_FOUND:
      ELEM_RESULT.text = "FAILED"
      return False
    else:
      ELEM_RESULT.text = "PASSED"
      return True

  def check_provstr(self,HDR='primary'):
    DICT1 = self.primary_header if HDR == 'primary' else self.backup_header
    if DICT1['kfdhdb_driver_provstr'].startswith("ORCLDISK"):
      return True
    else:
      return False

  def validate_endianness(self):
    if self.primary_header['kfbh_endian'] == ENDIAN_DICT[sys.byteorder]:
      return True
    else:
      return False

  def check_pst_existence(self):
    OPTS = "aun=1 ausz=" + self.primary_header['kfdhdb_ausize']
    OUTPUT = self.read_disk_headers(OPTS=OPTS)
    for LINE in OUTPUT.splitlines():
      if "KFBTYP_PST_META" in LINE:
        self.primary_header['pst_metadata_found'] = True

  def parse_kfed_output(self,HDR="primary"):
    OUTPUT = self.kfed_output_primary if HDR == "primary" else self.kfed_output_backup
    DICT1 = self.primary_header if HDR == "primary" else self.backup_header
    PATTERN1 = r"(?P<KEY>\w+\.\w+(\.\w+)*):\s*(?P<VALUE>\w+).*"
    PATTERN2 = r"(?P<KEY>\w+\.\w+):\s*\w+\s*\;\s*\w+:\s*(?P<VALUE>\w+)$"
    PATTERN3 = r"(?P<KEY>\w+\.\w+\.\w+):\s*\w+\s*\;\s*\w+:\s*(?P<VALUE>.*)$"
    for LINE in OUTPUT.splitlines():
      try:
        VOTING_FILE_PATTERN = r"^kfdhdb.vfstart\:\s+(?P<VOTING_FILE>\d+).*"
        RESULT = re.match(VOTING_FILE_PATTERN,LINE,re.IGNORECASE)
        if RESULT != None:
          DICT1['voting_file_location'] = RESULT.group('VOTING_FILE')
          if DICT1['voting_file_location'] != "0":
            DICT1['voting_file_found'] = True

        if "kfbh.endian" in LINE:
          RESULT = re.match(PATTERN1,LINE,re.IGNORECASE)
          if RESULT != None:
            DICT1['kfbh_endian'] = RESULT.group('VALUE')

        if "kfdhdb.grptyp" in LINE:
          RESULT = re.match(PATTERN2,LINE,re.IGNORECASE)
          if RESULT != None:
            DICT1['kfdhdb_grptyp'] = RESULT.group('VALUE') 

        if "kfdhdb.mntstmp.hi" in LINE:
          RESULT = re.match(PATTERN3,LINE,re.IGNORECASE)
          if RESULT != None:
            DICT1['kfdhdb_mntstmp_hi'] = RESULT.group('VALUE') 

        if "kfdhdb.mntstmp.lo" in LINE:
          RESULT = re.match(PATTERN3,LINE,re.IGNORECASE)
          if RESULT != None:
            DICT1['kfdhdb_mntstmp_lo'] = RESULT.group('VALUE') 

        if "kfdhdb.hdrsts" in LINE:
          RESULT = re.match(PATTERN2,LINE,re.IGNORECASE)
          if RESULT != None:
            DICT1['kfdhdb_hdrsts'] = RESULT.group('VALUE') 
      
        if "provstr" in LINE:
          RESULT = re.match(PATTERN1,LINE,re.IGNORECASE)
          if RESULT != None:
            DICT1['kfdhdb_driver_provstr'] = RESULT.group('VALUE') 

        if "kfbh.type" in LINE:
          RESULT = re.match(PATTERN2,LINE,re.IGNORECASE)
          if RESULT != None:
            DICT1['kfbh_type'] = RESULT.group('VALUE') 

        if "dskname" in LINE:
          RESULT = re.match(PATTERN1,LINE,re.IGNORECASE)
          if RESULT != None:
            DICT1['kfdhdb_dskname'] = RESULT.group('VALUE') 

        if "ausize" in LINE:
          RESULT = re.match(PATTERN1,LINE,re.IGNORECASE)
          if RESULT != None:
            DICT1['kfdhdb_ausize'] = RESULT.group('VALUE') 

        if "grpname" in LINE:
          RESULT = re.match(PATTERN1,LINE,re.IGNORECASE)
          if RESULT != None:
            DICT1['kfdhdb_grpname'] = RESULT.group('VALUE') 
            DISKGROUPS.add(DICT1['kfdhdb_grpname'])

        if "dsknum" in LINE:
          RESULT = re.match(PATTERN1,LINE,re.IGNORECASE)
          if RESULT != None:
            DICT1['kfdhdb_dsknum'] = RESULT.group('VALUE') 

        if "secsize" in LINE:
          RESULT = re.match(PATTERN1,LINE,re.IGNORECASE)
          if RESULT != None:
            DICT1['kfdhdb_secsize'] = RESULT.group('VALUE') 

        if "blksize" in LINE:
          RESULT = re.match(PATTERN1,LINE,re.IGNORECASE)
          if RESULT != None:
            DICT1['kfdhdb_blksize'] = RESULT.group('VALUE') 

        if "dsksize" in LINE:
          RESULT = re.match(PATTERN1,LINE,re.IGNORECASE)
          if RESULT != None:
            DICT1['kfdhdb_dsksize'] = RESULT.group('VALUE')

        if "KFBTYP_DISKHEAD" in LINE:
          DICT1['valid_asm_disk'] = True

      except Exception as e:
        logging.info("An error occurred")
        logging.info(e)
        exception_type, exception_object, exception_traceback = sys.exc_info()
        file_name = exception_traceback.tb_frame.f_code.co_filename
        line_number = exception_traceback.tb_lineno
        logging.debug(f"Exception type: {exception_type}")
        logging.debug(f"File name: {file_name}")
        logging.debug(f"Line number: {line_number}")


    if DICT1['valid_asm_disk'] and DICT1['kfdhdb_dsksize'] != "0" and DICT1['kfdhdb_ausize'] != "0":
      try:
        VALUE = int(DICT1['kfdhdb_dsksize']) * int(DICT1['kfdhdb_ausize']) / (1024 * 1024)
        DICT1['kfdhdb_dsksize'] = str(VALUE) + " MB"
#        self.kfdhdb_dsksize_primary = self.kfdhdb_dsksize_primary + f" AU (AU size = {self.kfdhdb_ausize_primary} bytes)"
      except ValueError as e:
        logging.error(f"An error occurred while calculating size of disk '{self.disk_path}'")
        logging.error(f"Disk = {self.disk_path} \nDisk size = {DICT1['kfdhdb_dsksize']} \nAusize = {DICT1['kfdhdb_ausize']}\n")
        logging.error(f"VALUE = {VALUE}")
        exception_type, exception_object, exception_traceback = sys.exc_info()
        file_name = exception_traceback.tb_frame.f_code.co_filename
        line_number = exception_traceback.tb_lineno
        logging.debug(f"Exception type: {exception_type}")
        logging.debug(f"File name: {file_name}")
        logging.debug(f"Line number: {line_number}")

  def read_disk_headers(self,OPTS="",HDR="primary"):
    CMD = [KFED,"read",self.disk_path,OPTS]
    OUTPUT = subprocess.run(CMD,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    ELEM = ET.SubElement(ROOT, "CHECK")
    TXT = f"{os.path.basename(self.disk_path)}_Primary_Header" if OPTS == "" else f"{os.path.basename(self.disk_path)}_Backup_Header"
    ELEM.set("name", TXT)
    VAL = f"kfed read {self.disk_path} {OPTS}" if OPTS != "" else f"kfed read {self.disk_path}"
    ELEM.set("cmd", VAL)
    ELEM.set("disk", self.disk_path)
    ELEM.text = OUTPUT.stdout.decode().strip()
    if HDR == "primary":
      self.kfed_output_primary = OUTPUT.stdout.decode().strip()
    elif HDR == "backup":
      self.kfed_output_backup = OUTPUT.stdout.decode().strip()
    return OUTPUT.stdout.decode().strip()

def sanitizeCharInLine(LINE):
  PATTERN = r"\$|`|;|<|>|&|\|"
  RESULT = re.search(PATTERN,LINE)
  if RESULT != None:
    logging.debug(f"One of the following characters found in the line and is being replaced by '#'\n{PATTERN}")
    logging.debug(f"Original line\n{LINE}")
    LINE = re.sub(PATTERN,'#',LINE)
    logging.debug(f"Line after replacement\n{LINE}")
    return LINE
  return LINE
          
def get_GRID_HOME():
  logging.debug("function get_GRID_HOME() : Obtain the location of GI home\n")
  # Obtain GRID_HOME location from OLR
  try:
    with open(OLR_LOC[PLATFORM]) as OLR:
      for line in OLR.read().splitlines():
        if "crs_home" in line:
          GRID_HOME = line.split("=")[1]
          break
      else:
        logging.info(f"GRID_HOME could not be determined from {OLR_LOC[PLATFORM]}. Exiting...")
        logging.info(f"\n{'---------- END REPORT ----------':^150}\n")
        sys.exit(1)
  except FileNotFoundError as e:
    logging.info(f"OLR file '{OLR_LOC[PLATFORM]}' not found. Exiting...")
    exception_type, exception_object, exception_traceback = sys.exc_info()
    file_name = exception_traceback.tb_frame.f_code.co_filename
    line_number = exception_traceback.tb_lineno
    logging.debug(f"Exception type: {exception_type}")
    logging.debug(f"File name: {file_name}")
    logging.debug(f"Line number: {line_number}")
    logging.info(f"\n{'---------- END REPORT ----------':^150}\n")
    sys.exit(1)

  # Check if GRID_HOME exists
  if not os.path.exists(GRID_HOME):
    logging.info(f"ALERT : '{GRID_HOME}' not found. Exiting...")
    logging.info(f"\n{'---------- END REPORT ----------':^150}\n")
    sys.exit(1)

  logging.debug(f"GRID_HOME = {GRID_HOME}\n")
  return GRID_HOME

# Get CRS Owner
def read_crsconfig_params(CRSCONFIG_PARAMS):
  '''Determine the GI software owner (CRS_OWNER)'''

  logging.debug(f"function read_crsconfig_params() : Determine the GI software owner (CRS_OWNER)\n")

  try:
    with open(CRSCONFIG_PARAMS) as crsconfig_params:
      for LINE in crsconfig_params:
        if LINE.startswith("ORACLE_BASE"):
          try:
            ORACLE_BASE = LINE.split("=")[1].strip()
          except IndexError as e:
            logging.info(f"An error occurred while parsing the following line \n'{LINE}' in {CRSCONFIG_PARAMS}\n")
            logging.info(e)
            exception_type, exception_object, exception_traceback = sys.exc_info()
            file_name = exception_traceback.tb_frame.f_code.co_filename
            line_number = exception_traceback.tb_lineno
            logging.debug(f"Exception type: {exception_type}")
            logging.debug(f"File name: {file_name}")
            logging.debug(f"Line number: {line_number}")
            logging.info(f"Exiting...\n\n")
            logging.info(f"\n{'---------- END REPORT ----------':^150}\n")
            sys.exit(1)
        if LINE.startswith("ORACLE_OWNER"):
          try:
            CRS_OWNER = LINE.split("=")[1].strip()
          except IndexError as e:
            logging.info(f"An error occurred while parsing the following line \n'{LINE}' in {CRSCONFIG_PARAMS}\n")
            logging.info(e)
            exception_type, exception_object, exception_traceback = sys.exc_info()
            file_name = exception_traceback.tb_frame.f_code.co_filename
            line_number = exception_traceback.tb_lineno
            logging.debug(f"Exception type: {exception_type}")
            logging.debug(f"File name: {file_name}")
            logging.debug(f"Line number: {line_number}")
            logging.info(f"Exiting...\n\n")
            logging.info(f"\n{'---------- END REPORT ----------':^150}\n")
            sys.exit(1)
  except FileNotFoundError as e:
    logging.info(f"ALERT!!! File {CRSCONFIG_PARAMS} not found or is not readable")
    logging.info(e)
    exception_type, exception_object, exception_traceback = sys.exc_info()
    file_name = exception_traceback.tb_frame.f_code.co_filename
    line_number = exception_traceback.tb_lineno
    logging.debug(f"Exception type: {exception_type}")
    logging.debug(f"File name: {file_name}")
    logging.debug(f"Line number: {line_number}")
    logging.info(f"Exiting...\n\n")
    logging.info(f"\n{'---------- END REPORT ----------':^150}\n")
    sys.exit(1)

  logging.debug(f"CRS Owner = {CRS_OWNER}\n")
  logging.debug(f"Oracle Base = {ORACLE_BASE}\n")

  return CRS_OWNER,ORACLE_BASE

# Get ASM disk string by reading GPNP profile
def get_ASM_DISK_STRING(GPNP_PROFILE):

  logging.debug(f"function GET_ASM_DISK_STRING() : Get ASM diskstring from GPNP profile\n")

  if not os.path.exists(GPNP_PROFILE):
    logging.info(f"ALERT : {GPNP_PROFILE} not found. Exiting...")
    logging.info(f"\n{'---------- END REPORT ----------':^150}\n")
    sys.exit(1)

  ARGS = "-p=" + GPNP_PROFILE
  CMD = [GPNPTOOL, "getpval", "-asm_dis", ARGS, "-o-"]

  logging.debug(f"CMD = {' '.join(CMD)}\n")

  logging.debug(f'''Executing '{" ".join(CMD)}' to fetch GPNP data''')

  RESULT = subprocess.run(CMD,stdout=subprocess.PIPE,stderr=subprocess.PIPE)

  logging.debug(f"STDOUT = {RESULT.stdout.decode()}\n")
  logging.debug(f"STDERR = {RESULT.stderr.decode()}\n")

  if RESULT.returncode:
    logging.info(f"An error occurred while executing \'{' '.join(CMD)}\'")
    logging.info(RESULT.stdout.decode())
    logging.info(RESULT.stderr.decode())
    logging.info(f"\n{'---------- END REPORT ----------':^150}\n")

  ASM_DISK_STRING = RESULT.stdout.decode().strip()

  logging.debug(f"ASM diskstring = {ASM_DISK_STRING}\n")

  # Check if GPNP returned null ASM Disk String in which case, use default value (platform specific)
  if ASM_DISK_STRING == "":
    ASM_DISK_STRING = DEFAULT_ASM_DISK_STRING[PLATFORM]
    logging.info(f"ASM diskstring could not be determined from GPNP profile. Using platform default\n")
    logging.info(f"ASM diskstring = {ASM_DISK_STRING}\n")

  # Check if Exadata storage is being used (SuperCluster or Exadata)
  for DISK_STRING in ASM_DISK_STRING.split(","):
    if DISK_STRING.startswith("o/"):
      raise Exception(f"Exadata storage found based on ASM discovery string ({ASM_DISK_STRING}). The script does not work with Exadata storage.")

  return ASM_DISK_STRING

# Check if a given kernel module is loaded
def check_module_loaded(KERNEL_MODULE):
  ''' Check if a given kernel module is loaded or not '''

  logging.debug(f"function check_module_loaded() : Check if a given kernel module is loaded or not\n")

  CMD = [LSMOD]

  logging.debug(f"CMD = {CMD}\n")

  try:
    RESULT = subprocess.run(CMD,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    logging.debug(f"STDOUT = {RESULT.stdout.decode()}\n")
    logging.debug(f"STDERR = {RESULT.stderr.decode()}\n")
  except Exception as e:
    logging.info(f"An error occurred while executing \'{' '.join(CMD)}\' command")
    logging.info(f"STDOUT and STDERR Output of command \'{' '.join(CMD)}\' follows")
    logging.info(f"STDOUT : \n{RESULT.stdout.decode()}")
    logging.info(f"STDERR : \n{RESULT.stderr.decode()}")
    logging.info(e)
    exception_type, exception_object, exception_traceback = sys.exc_info()
    file_name = exception_traceback.tb_frame.f_code.co_filename
    line_number = exception_traceback.tb_lineno
    logging.debug(f"Exception type: {exception_type}")
    logging.debug(f"File name: {file_name}")
    logging.debug(f"Line number: {line_number}")
    logging.info(f"\n\n")
    logging.info(f"Exiting...\n\n")
    logging.info(f"\n{'---------- END REPORT ----------':^150}\n")

  ELEM_COMMAND = ET.SubElement(ELEM, "COMMAND")
  ELEM_COMMAND.text = " ".join(CMD)
  ELEM_STDOUT = ET.SubElement(ELEM, "STDOUT")
  ELEM_STDOUT.text = RESULT.stdout.decode()
  ELEM_STDERR = ET.SubElement(ELEM, "STDERR")
  ELEM_STDERR.text = RESULT.stderr.decode()

  logging.debug(f"Loaded modules\n")
  for MODULE in RESULT.stdout.decode().splitlines():
    logging.debug(MODULE)
    if KERNEL_MODULE in MODULE:
      MODULE_LOADED = True
      break
  else:
    MODULE_LOADED = False

  return MODULE_LOADED

def resolve_disk(DISK):
  if "AFD" in DISK:
    return AFD_DISKS_BY_NAME[DISK.lstrip("AFD:")]
  if "ORCL" in DISK:
    DISK = DISK.lstrip("ORCL:")
    CMD = ["/usr/sbin/oracleasm", "querydisk", "-p", DISK]
    RES = subprocess.run(CMD, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for LINE in RES.stdout.decode().strip().splitlines():
      LINE = sanitizeCharInLine(LINE)
      if "LABEL" in LINE and "TYPE" in LINE:
        DISK = LINE.split(":")[0]
        return DISK

def get_ASM_DISKS_1(ASM_DISK_STRING,CRS_OWNER):
  '''Get the set of disks based on the ASM diskstring that we obtained from GPNP profile'''

  DISKS_KFOD = set()
  DISKS_OS = set()
  os.environ['ORACLE_HOME'] = GRID_HOME
  UID = os.getuid()

  logging.debug(f"function get_ASM_DISKS_1() : Get the set of disks based on the ASM diskstring that we obtained from GPNP profile\n")

  if ASM_DISK_STRING.upper() == "AFD:" or ASM_DISK_STRING.upper() == "ORCL:":   # ASM Diskstring contains only 'AFD:*' or 'ORCL:*'
    logging.info(f"ASM diskstring has {ASM_DISK_STRING}\n")

  if UID == 0:
    CMD = 'su - ' + CRS_OWNER + ' -c ' + '"ORACLE_HOME=' + GRID_HOME + ' ' + KFOD + ' nohdr=TRUE status=TRUE disks=all asm_diskstring=' + ASM_DISK_STRING + '"'
  else:
    CMD = 'ORACLE_HOME=' + GRID_HOME + ' ' + KFOD + ' nohdr=TRUE status=TRUE disks=all asm_diskstring=' + ASM_DISK_STRING

  RESULT = os.popen(CMD).read()
  logging.info(f"Output of command '{CMD}' follows\n{RESULT}")

#  PATTERN = r"(?P<DISK_SIZE>\d+)\s+(?P<HEADER>(UNKNOWN|CANDIDATE|INCOMPATIBLE|PROVISIONED|MEMBER|FORMER|CONFLICT|FOREIGN))\s+(?P<DISK>.*)\s+(?P<OWNER>\w+)\s+(?P<GROUP>\w+)"
  PATTERN = r"(?P<DISK_SIZE>\d+)\s+(?P<HEADER>(UNKNOWN|CANDIDATE|INCOMPATIBLE|PROVISIONED|MEMBER|FORMER|CONFLICT|FOREIGN))\s+(?P<DISK>(\w+:*\w+|(\w|/)+)).*"
  
  for LINE in RESULT.splitlines():
    LINE = sanitizeCharInLine(LINE)
    RES = re.match(PATTERN,LINE,re.IGNORECASE)
    if RES == None:
      continue
    if RES != None:
      DISK = RES.group("DISK")
      HEADER = RES.group("HEADER")

#    if DISK == '' or 'AFD:' in DISK or 'ORCL:' in DISK:       # Ignore the disks
    if DISK == "":       # Ignore the disks
      logging.warning(f"Could not find disk info from the following line\n{LINE}\n")
      continue

    if "AFD:" in DISK or "ORCL:" in DISK:
      DISK = resolve_disk(DISK)

    if DISK.startswith("/"):
      DISKS_KFOD.add(DISK)
    else:
      logging.warning(f"Could not resolve disk '{DISK}' to OS disk")

  logging.info(f"Disks detected (using kfod) based on asm_diskstring = {ASM_DISK_STRING}\n")

  for DISK in DISKS_KFOD:
    logging.info(f"{DISK}")
  logging.info(f"\n")

  logging.info(f"Disks detected (at OS level) based on asm_diskstring = {ASM_DISK_STRING}\n")

  if ASM_DISK_STRING == "AFD:*" or ASM_DISK_STRING == "ORCL:*":
    DISKS_OS = DISKS_KFOD.copy()
  else:
    DISK_STRING = list()
    for LINE in ASM_DISK_STRING.split(","):
      if "AFD" in LINE or "ORCL" in LINE:
        continue
      if os.path.isdir(LINE):
        logging.info(f"Discovery string '{LINE}' is a directory")
        DISK_STRING.append(LINE + "/*")
      else:
        DISK_STRING.append(LINE)
    DISK_STRING = ",".join(DISK_STRING)
    DISKS_OS = set(glob.glob(DISK_STRING))

  for DISK in DISKS_OS:
    logging.info(f"{DISK}")
  logging.info("\n")

  ELEM = ET.SubElement(ROOT,"CHECK")
  ELEM.set("name", "ASM_Disks")
  ELEM_DISKS_KFOD = ET.SubElement(ELEM,"DISKS_KFOD")
  ELEM_DISKS_KFOD.text = ",".join(DISKS_KFOD)
  ELEM_DISKS_OS = ET.SubElement(ELEM,"DISKS_OS")
  ELEM_DISKS_OS.text = ",".join(DISKS_OS)
  
  return DISKS_KFOD,DISKS_OS

def print_disk_info(disk):
  DICT1 = dict()
  PERM = disk.disk_permission
  PERM_OK = disk.disk_permission_ok
  OWNER = disk.owner
  OWNER_OK = disk.owner_ok
  GROUP = disk.group
  ELEM = ET.SubElement(ROOT, "CHECK")
  ELEM.set("name", os.path.basename(disk.disk_path))
  ELEM.set("disk", disk.disk_path)
  ELEM.set("permission", PERM)
  if PERM_OK == "no":
    ELEM_VISIBLE = ET.SubElement(ELEM, "VISIBLE")
    ELEM_VISIBLE.text = "Y"
    ELEM_CAUSE = ET.SubElement(ELEM, "CAUSE")
    ELEM_CAUSE.text = f"Cause : Permissions on disk '{disk.disk_path}' ({PERM}) is not correct"
    logging.error(f"Cause : Permissions on disk '{disk.disk_path}' ({PERM}) is not correct")
    ELEM_RECOMMENDATION = ET.SubElement(ELEM, "RECOMMENDATION")
    ELEM_RECOMMENDATION.text = f"Action Plan : Ensure the owner ({OWNER}) of the disk '{disk.disk_path}' has write permissions (0600)"
    logging.error(f"Action Plan : Ensure the owner ({OWNER}) of the disk '{disk.disk_path}' has write permissions (0600)")
  ELEM.set("permission_ok", PERM_OK)
  ELEM.set("owner", OWNER)
  ELEM.set("group", GROUP)
  ELEM.set("owner_ok", OWNER_OK)
#  ELEM_PRIMARY_HEADERS = ET.SubElement(ELEM,'Disk_Primary_Header')
#  ELEM_PRIMARY_HEADERS.text = disk.kfed_output_primary
#  ELEM_BACKUP_HEADERS = ET.SubElement(ELEM,'Disk_Backup_Header')
#  ELEM_BACKUP_HEADERS.text = disk.kfed_output_backup
#  logging.info(f"{DISK:^30s}\t{PERM:^4s}\t{PERM_OK:^7s}\t{OWNER:^10s}\t{GROUP:^10s}\t{OWNER_OK:^8s}")
#  DICT1 = check_disk_header(DISK)
  if disk.primary_header['kfdhdb_grpname'] == "":
    logging.info(f"Couldn't read header (kfdhdb.grpname) of disk '{disk.disk_path}'")
    return
#  DISK_PRIMARY_HEADER[DISK] = DICT1.copy()
  DICT1['DISKGROUP_NAME'] = disk.primary_header['kfdhdb_grpname']
  DICT1['REDUNDANCY'] = disk.primary_header['kfdhdb_grptyp'].split("_")[1]
  DICT1['DSKNAME'] = disk.primary_header['kfdhdb_dskname']
  DICT1['DSKNUM'] = disk.primary_header['kfdhdb_dsknum']
  DICT1['AUSIZE'] = disk.primary_header['kfdhdb_ausize']
  DICT1['TYPE'] = disk.primary_header['kfbh_type']
  DICT1['ENDIAN'] = disk.primary_header['kfbh_endian']
  DICT1['PERM'] = PERM
  DICT1['PERM_OK'] = PERM_OK
  DICT1['OWNER'] = OWNER
  DICT1['GROUP'] = GROUP
  DISK_METADATA[DISK] = DICT1
#  DISK_HEADER = DISK_METADATA[DISK]['DISK_HEADER']
#  AUN = DISK_METADATA[DISK]['AUN']
  DG_METADATA[disk.primary_header['kfdhdb_grpname']] = (disk.primary_header['kfdhdb_grptyp'].split("_")[1], disk.primary_header['kfdhdb_ausize'])
#  disk.validate_endianness()
  disk.check_disk_header_corruption()

#==========================================================================#

# Parse input parameters passed to the script
parser = argparse.ArgumentParser(add_help=True)
parser.add_argument("-debug", dest="debug", action='store_true', default=False)
parser.add_argument("-diskgroup", "-dg", help="diskgroup|dg", type=str)
parser.add_argument("-checkCorruption", dest="checkCorruption", action='store_true', default=True)
args = parser.parse_args()

try:
# Define variables used in the script
  ENDIAN_DICT = {'big':'0', 'little':'1'}
  DISKGROUPS = set()      # Diskgroups identified by reading disk header (or provided by customer as an argument to the script)
  DG_METADATA = dict()
  DISK_METADATA = dict()
  DISKGROUP_INFO = dict()
  DISK_PRIMARY_HEADER = dict()
  DISK_BACKUP_HEADER = dict()
  ASM_DISKS = list()
  AFD_DISKS_BY_NAME = dict()
  AFD_DISKS_BY_PATH = dict()
  DG_DISKS = dict()       # Set of disks belonging to each diskgroup
  DG_FOUND = False        # Check if the provided diskgroup has been discovered by reading disk headers
  DG_NOT_FOUND = set()    # Diskgroups that were not found after reading headers of all the disks that were discovered
  DISK_DIRECTORY_FOUND = dict()
  DEBUG = args.debug
  DATE = datetime.datetime.now()
  TIMESTAMP = str("{:0>4}-{:0>2}-{:0>2}.{:0>2}:{:0>2}:{:0>2}".format(DATE.year,DATE.month,DATE.day,DATE.hour,DATE.minute,DATE.second))
  LOCALNODE = platform.node().split(".")[0]
  FILENAME = "checkASMDiskGroups"
  TMP_DIR = os.getcwd() 
  LOG = os.path.join(TMP_DIR,FILENAME + '.log')
  ERRLOG = os.path.join(TMP_DIR,FILENAME + '.err')
  CONFIGFILE = os.path.join(TMP_DIR,FILENAME + '.config')
  TARFILE = os.path.join(TMP_DIR,FILENAME + '.tar.gz')
  XMLFILE = os.path.join(TMP_DIR,FILENAME + '.xml')
  LEVEL = logging.DEBUG if DEBUG else logging.INFO

  logging.basicConfig(filename=LOG, filemode="w", format="%(message)s", level=LEVEL)
  logging.info(f"{'---------- BEGIN REPORT ----------':^150}\n")
  logging.info(f"Script Version = {SCRIPT_VERSION} \n")
  ROOT = ET.Element("CHECKS")
  SCRIPT_EXECUTION_TS = ET.SubElement(ROOT, "SCRIPT_EXECUTION_TS")
  SCRIPT_EXECUTION_TS.text = TIMESTAMP.replace('.',' ')
  SCRIPTVERSION = ET.SubElement(ROOT, "SCRIPT_VERSION")
  SCRIPTVERSION.text = SCRIPT_VERSION
  OLR_LOC = {'linux':'/etc/oracle/olr.loc','sunos':'/var/opt/oracle/olr.loc','aix':'/etc/oracle/olr.loc'} # Define Oracle Local Registry (OLR) location based on OS platform
  DEFAULT_ASM_DISK_STRING = {'linux':'/dev/*','sunos':'/dev/rdsk/*','aix':'/dev/rhdisk*'}
  os.environ['LANG'] = "en_US.UTF-8"      # Set language to English to avoid false positives #

  if sys.platform.startswith("linux"):
    PLATFORM = "linux"
  elif sys.platform.startswith("aix"):
    PLATFORM = "aix"
  elif sys.platform.startswith("sunos"):
    PLATFORM = "sunos"
  else:
    raise Exception(f"Unknown OS platform : {sys.platform}")

  GRID_HOME = get_GRID_HOME()
  os.environ['ORACLE_HOME'] = GRID_HOME # Set ORACLE_HOME environment variable to avoid "ERROR!!! ORACLE HOME is not set" error when executing kfed/amdu command
  # Define the location of GI binaries/files
  GI_BIN_LOC = GRID_HOME + os.sep + "bin" + os.sep
  GPNPTOOL = GI_BIN_LOC + "gpnptool"
  KFED = GI_BIN_LOC + "kfed"
  KFOD = GI_BIN_LOC + "kfod"
  AMDU = GI_BIN_LOC + "amdu"
  ASMCMD = GI_BIN_LOC + "asmcmd"
  AFDTOOL = GI_BIN_LOC + "afdtool"
  CRSCONFIG_PARAMS = GRID_HOME + os.sep + "crs" + os.sep + "install" + os.sep + "crsconfig_params"
  LSMOD = "lsmod" if PLATFORM == "linux" else "modinfo"
  GPNP_PROFILE = GRID_HOME + os.sep + "gpnp" + os.sep + "profiles" + os.sep + "peer" + os.sep + "profile.xml"

  CRS_OWNER,ORACLE_BASE = read_crsconfig_params(CRSCONFIG_PARAMS)   # Get CRS Owner
  os.environ['ORACLE_BASE'] = ORACLE_BASE # Set ORACLE_BASE environment variable
  ASM_DISK_STRING = get_ASM_DISK_STRING(GPNP_PROFILE)   # Get ASM Disk String
  if "AFD" in ASM_DISK_STRING:
    CMD = [AFDTOOL, "-getdevlist", "-nohdr"]
    RES = subprocess.run(CMD, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for LINE in RES.stdout.decode().strip().splitlines():
      LINE = sanitizeCharInLine(LINE)
      AFD_NAME,AFD_PATH = LINE.split()
      AFD_DISKS_BY_NAME[AFD_NAME] = AFD_PATH
      AFD_DISKS_BY_PATH[AFD_PATH] = AFD_NAME

  ENVIRONMENT = ET.SubElement(ROOT, "ENVIRONMENT")
  ENVIRONMENT.set("GRID_HOME", GRID_HOME)
  ENVIRONMENT.set("SYSTEM_NAME", os.uname().sysname)
  ENVIRONMENT.set("NODE_NAME", os.uname().nodename)
  ENVIRONMENT.set("RELEASE", os.uname().release)
  ENVIRONMENT.set("VERSION", os.uname().version)
  ENVIRONMENT.set("MACHINE", os.uname().machine)
  ENVIRONMENT.set("CRS_OWNER", CRS_OWNER)
  ENVIRONMENT.set("ASM_DISK_STRING", ASM_DISK_STRING)

  logging.info(f"\n{'---------- Environment details ----------':^50}\n")
  logging.info(f"GRID_HOME = {GRID_HOME}")
  logging.info(f"System name = {os.uname().sysname}")
  logging.info(f"Node name = {os.uname().nodename}")
  logging.info(f"Release = {os.uname().release}")
  logging.info(f"Version = {os.uname().version}")
  logging.info(f"Machine = {os.uname().machine}")
  logging.info(f"CRS owner = {CRS_OWNER}")
  logging.info(f"ASM discovery string = {ASM_DISK_STRING}\n")

  # Check whether ASMLib or AFD kernel modules are loaded or not
  if os.path.exists("/etc/sysconfig/oracleasm") and ("ORCL" in ASM_DISK_STRING or "/dev/oracleasm/disks" in ASM_DISK_STRING):
    ELEM = ET.SubElement(ROOT,"CHECK")
    ELEM.set("name", "kernel_module")
    ELEM_MODULE_LOADED = ET.SubElement(ELEM,"ASMLib")
    ELEM_RESULT = ET.SubElement(ELEM,"RESULT")
    ELEM_VISIBLE = ET.SubElement(ELEM,"VISIBLE")
    ELEM_VISIBLE.text = "Y"
    if check_module_loaded("oracleasm"):
      ELEM_RESULT.text = "PASSED"
      logging.info(f'NOTE : Detected ASMLib being used and "oracleasm" kernel module is loaded\n\n')
      ELEM_MODULE_LOADED.text = "LOADED"
    else:
      ELEM_RESULT.text = "FAILED"
      logging.error(f'ALERT : Detected ASMLib being used and "oracleasm" kernel module is *not* loaded\n\n')
      ELEM_MODULE_LOADED.text = "NOT LOADED"
      ELEM_CAUSE = ET.SubElement(ELEM,"CAUSE")
      ELEM_CAUSE.text = "Cause : Kernel module 'oracleasm' is not loaded"
      ELEM_RECOMMENDATION = ET.SubElement(ELEM,"RECOMMENDATION")
      ELEM_RECOMMENDATION.text = "Action Plan : Ensure kernel module 'oracleasm' is loaded and execute '# oracleasm scandisks' as 'root' user to scan the disks"

  if os.path.exists("/etc/afd.conf") or os.path.exists("/etc/oracleafd.conf") or "AFD:*" in ASM_DISK_STRING:
    ELEM = ET.SubElement(ROOT,"CHECK")
    ELEM.set("name", "kernel_module")
    ELEM_MODULE_LOADED = ET.SubElement(ELEM,"AFD")
    ELEM_RESULT = ET.SubElement(ELEM,"RESULT")
    ELEM_VISIBLE = ET.SubElement(ELEM,"VISIBLE")
    ELEM_VISIBLE.text = "Y"
    if check_module_loaded("oracleafd"):
      ELEM_RESULT.text = "PASSED"
      logging.info(f'NOTE : Detected ASM Filter Driver (AFD) being used and "oracleafd" kernel module is loaded\n\n')
      ELEM_MODULE_LOADED.text = "LOADED"
    else:
      ELEM_RESULT.text = "FAILED"
      logging.error(f'ALERT : Detected ASM Filter Driver (AFD) being used and "oracleafd" kernel module is *not* loaded\n\n')
      ELEM_MODULE_LOADED.text = "NOT LOADED"
      ELEM_CAUSE = ET.SubElement(ELEM,"CAUSE")
      ELEM_CAUSE.text = "Cause : Kernel module 'oracleafd' is not loaded"
      ELEM_RECOMMENDATION = ET.SubElement(ELEM,"RECOMMENDATION")
      ELEM_RECOMMENDATION.text = "Action Plan : Ensure kernel module 'oracleafd' is loaded"


  DISKS_KFOD,DISKS_OS = get_ASM_DISKS_1(ASM_DISK_STRING,CRS_OWNER)            # Get the list of disks found based on ASM Disk String
#  print(DISKS_KFOD)
  if len(DISKS_KFOD) == 0:
    logging.info(f"No disks detected based on ASM discovery string '{ASM_DISK_STRING}'. Ensure the discovery string is correct, the disks are visible at the OS level, have appropriate permissions and kernel modules (ASMLib or AFD) are loaded")
    logging.info(f"\n{'---------- END REPORT ----------':^150}\n")

  STR1 = f"---------- Disk Details ----------"
  logging.info(f"{STR1:^100}\n")

  COUNTER = 1
  for DISK in DISKS_KFOD:
    disk = Disk(DISK)
    ASM_DISKS.append(disk)
    logging.info(f"{COUNTER:02d}) {disk}")
    if disk.primary_header['valid_asm_disk']:
      print_disk_info(disk)
    COUNTER += 1

  if DISKS_KFOD != DISKS_OS:
    logging.warning(f"WARNING : Disks discovered using kfod command and at OS level are *not* the same\n")
    logging.info(f"Details of the disk/s that were detected at the OS level but not by KFOD command follows\n")
    COUNTER = 1
    for DISK in (DISKS_OS - DISKS_KFOD):
      disk = Disk(DISK)
      ASM_DISKS.append(disk)
      logging.info(f"{COUNTER:02d}) {disk}")
      if disk.primary_header['valid_asm_disk']:
        print_disk_info(disk)
      COUNTER += 1
  else:
    logging.info(f"INFO : Disks discovered using kfod command and at OS level are the same\n")

  # All the diskgroups that were identified by reading disk headers
  logging.info(f"\n{'---------- Diskgroups identified by reading disk headers ----------':^100}\n")

  for DISKGROUP_NAME in DISKGROUPS:
    DG = Diskgroup(DISKGROUP_NAME,ASM_DISKS)
    logging.info(DG)
#    logging.info(f'{DISKGROUP_NAME} :\n\tRedundancy : {DG_METADATA[DISKGROUP_NAME][0]}\n\tAU Size : {DG_METADATA[DISKGROUP_NAME][1]}')
    DISKGROUP_INFO[DISKGROUP_NAME] = dict()
    DG_DISKS[DISKGROUP_NAME] = set()
    DISK_DIRECTORY_FOUND[DISKGROUP_NAME] = False

  if args.diskgroup != None:
    logging.info(f'\n\nNOTE : Using diskgroups ({args.diskgroup}) provided on command line\n')
    for DG in args.diskgroup.split(","):
      if DG in DISKGROUPS:
        DG_FOUND = True
      else:
        logging.warning(f'WARNING : Diskgroup "{DG}" not found after reading disk headers. Excluding it from the set of diskgroups to scan\n\n')
        DG_NOT_FOUND.add(DG)
    if not DG_FOUND:
      logging.info(f'None of the provided diskgroup/s ({args.diskgroup}) were discovered after reading disk headers. Choose among the discovered diskgroups {DISKGROUPS} and rerun the script. Exiting...')
      logging.info(f"\n{'---------- END REPORT ----------':^150}\n")
      sys.exit(1)
    DISKGROUPS = set(DG for DG in args.diskgroup.split(","))
  # Remove diskgroups that were not found
    DISKGROUPS = DISKGROUPS - DG_NOT_FOUND

  # Execute AMDU on the diskgroups if 'checkCorruption' option is provided
  if args.checkCorruption:
    print(f"\nThis may take some time (depending on the number of disks)...\n")

    logging.info(f"\n{'---------- ASM Metadata Corruption Check ----------':^100}\n")
    OPTS = ""
    for STRING in ASM_DISK_STRING.split(","):
      OPTS = OPTS + "-diskstring " + STRING + " "
    else:
      OPTS = OPTS + " -nodir -dump"
    for DISKGROUP in DISKGROUPS:
      CMD = [AMDU, OPTS, DISKGROUP]

      logging.info(f"\nExecuting \'{' '.join(CMD)}\'...This may take some time\n\n")

      RESULT = subprocess.run(CMD, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
      logging.info(f"STDOUT = {RESULT.stdout.decode()}\n")
      logging.info(f"STDERR = {RESULT.stderr.decode()}\n")
      FLAG = 0
      CORRUPTION = False
      for LINE in RESULT.stdout.decode().splitlines():
        LINE = sanitizeCharInLine(LINE)
        if "SUMMARY FOR DISKGROUP" not in LINE and FLAG == 0:
          continue
        FLAG = 1
        if "corrupt" in LINE.lower():
          CORRUPT_BLOCK_COUNT = int(LINE.split(":")[-1].strip())
          if CORRUPT_BLOCK_COUNT > 0:
            CORRUPTION = True
      if CORRUPTION:
        ELEM = ET.SubElement(ROOT, "CHECK")
        ELEM.set("name", "ASM_METADATA_CORRUPTION_" + DISKGROUP)
        ELEM_VISIBLE = ET.SubElement(ELEM, "VISIBLE")
        ELEM_VISIBLE.text = "Y"
        ELEM_CAUSE = ET.SubElement(ELEM, "CAUSE")
        ELEM_CAUSE.text = f"Cause : Metadata corruption found in diskgroup '{DISKGROUP}'"
        ELEM_RECOMMENDATION = ET.SubElement(ELEM, "RECOMMENDATION")
        ELEM_RECOMMENDATION.text = f"Action Plan : Recreate diskgroup '{DISKGROUP}' and restore data from backup"
        logging.info(f"ALERT : Corruption found in diskgroup '{DISKGROUP}'\n")
      else:
        logging.info(f"NOTE : No corruption found in diskgroup '{DISKGROUP}'\n")

  # Create a lookup table to get OS disk name based on the disk number or disk name
#  for DISK,DISK_INFO in DISK_METADATA.items():
#    DISKGROUP_INFO[DISK_INFO['GRPNAME']][DISK_INFO['DSKNUM']] = DISK.strip()
#    DISKGROUP_INFO[DISK_INFO['GRPNAME']][DISK_INFO['DSKNAME']] = DISK.strip()

  logging.info(f"\n==============================================================")
  logging.info(f"DISK_METADATA = {DISK_METADATA}\n\n")
  logging.info(f"DG_METADATA = {DG_METADATA}")
#  logging.info(f"DISKGROUP_INFO = {DISKGROUP_INFO}\n\n")
  logging.info(f"==============================================================")
  logging.info(f"\n{'---------- END REPORT ----------':^150}")

except Exception as e:
  logging.info(e)
  exception_type, exception_object, exception_traceback = sys.exc_info()
  file_name = exception_traceback.tb_frame.f_code.co_filename
  line_number = exception_traceback.tb_lineno
  logging.debug(f"Exception type: {exception_type}")
  logging.debug(f"File name: {file_name}")
  logging.debug(f"Line number: {line_number}")
finally:
  TREE = ET.ElementTree(ROOT)
  with open(XMLFILE,"wb") as xmlfile:
    TREE.write(xmlfile)

  with tarfile.open(TARFILE, "w:gz") as tar:
    for name in [XMLFILE,LOG]:
      tar.add(name)
    print(f"\n\nUpload {TARFILE} to My Oracle Support (MOS) for further analysis.\n\n")

