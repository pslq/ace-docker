#!/bin/bash

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

[ -z "${MQSI_VERSION}" ] && [ -f /opt/ibm/ace-12/server/bin/mqsiprofile ] && . /opt/ibm/ace-12/server/bin/mqsiprofile
[ -f "${SCRIPT_DIR}/ace_config_logging.sh" ] && . ${SCRIPT_DIR}/ace_config_logging.sh
log "Handling setdbparms configuration"

if [ -s "/home/aceuser/initial-config/setdbparms/setdbparms.txt" ]; then
  awk '{
    if ( $0 !~ /^#|^$/ )
    {
      if ( $0 ~ /mqsisetdbparms/ )
      {
        print($0);
      } else
        print("mqsisetdbparms -w /home/aceuser/ace-server -n \""$1"\" -u \""$2"\" -p \""$3"\"");
    }
  }' | while read CMD
  do
    (
      (
        log "Running mqsisetdbparms..."
        OUTPUT=`eval "${CMD}"`
        [ ${?} -ne 0 ] && logAndExitIfError ${?} ${OUTPUT}
      )&
    )
  done
  wait
fi
log "setdbparms configuration complete"
exit 0
