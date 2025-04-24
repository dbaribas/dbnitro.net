#!/bin/bash

## The script looks for python3 from TFA and if not available, locates OS python3 and uses it to execute ##

CMD=checkASMDiskGroups.py
PYTHON=""

if [[ -f /etc/init.d/init.tfa ]]; then
  TFA_HOME=`egrep '^TFA_HOME' /etc/init.d/init.tfa 2>/dev/null | cut -f2 -d'='`
  if [[ $TFA_HOME != "" ]]; then
    AHF_HOME=`egrep '^AHF_HOME' $TFA_HOME/tfa.install.properties 2>/dev/null | cut -f2 -d'='`
    if [[ $AHF_HOME != "" ]]; then
      PYTHON=$AHF_HOME/python/bin/python
    else
      echo "Could not determine AHF_HOME location"
    fi
  else
    echo "Could not determine TFA_HOME location"
  fi
fi

if [[ $PYTHON == "" ]]; then
  PYTHON=`which python3 2>/dev/null`
fi

if [[ $PYTHON != "" && -x $PYTHON ]]; then
  $PYTHON $CMD "$@"
else
  echo "Could not find supported version of python3. Please install TFA from MOS note 2550798.1 which includes the required Python version and then execute this script"
fi
