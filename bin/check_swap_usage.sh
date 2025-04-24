#!/bin/sh
Author="Andre Augusto Ribas"
SoftwareVersion="1.0.1"
DateCreation="07/02/2025"
DateModification="07/02/2025"
EMAIL="ribas@dbnitro.net"
GITHUB="https://github.com/dbaribas/dbnitro.net"
WEBSITE="http://dbnitro.net"
#
# ------------------------------------------------------------------------
# Separate Line Function
#
SepLine() {
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' - 
}
#
# ------------------------------------------------------------------------
# Clear Screen Function
#
SetClear() {
  printf "\033c"
}
#
# ------------------------------------------------------------------------
#
#
SepLine
printf "Checking Swap Usage\n"
free -m | awk 'NR==2{print "Total Swap: " $2 " MB, Used Swap: " $3 " MB, Free Swap: " $4 " MB"}'
SepLine
printf "Top Processes Using Swap\n"
sudo smem -s swap -r | head -n 15
SepLine
printf "Oracle Processes Using Swap\n"
ps -eo pid,comm,vsize,rss,pmem --sort=-vsize | grep -i oracle | head -n 10
SepLine
printf "Identifying Top Memory Consumers\n"
ps aux --sort=-%mem | head -n 10
SepLine
printf "Checking System-wide Memory Usage\n"
vmstat -s | grep -E "swap|memory"
SepLine
printf "Checking Swap-in/Swap-out Activity\n"
vmstat 1 5 | awk 'NR==1 || NR>2 {print}'
SepLine
printf "Checking Swappiness Value\n"
cat /proc/sys/vm/swappiness
SepLine
printf "Checking I/O Activity\n"
iostat -xm 1 5 | awk 'NR<=3 || NR>6'
SepLine
printf "Checking Huge Pages Usage\n"
grep HugePages_ /proc/meminfo
SepLine
printf "Checking NUMA Memory Policy\n"
numactl --show
SepLine
printf "Recommendations:\n"
printf " * Reduce Oracle SGA/PGA memory if possible.\n"
printf " * Check for excessive parallel query usage.\n"
printf " * Consider adding more RAM or tuning swap settings.\n"
printf " * Reduce system swappiness (e.g., set vm.swappiness=10).\n"
SepLine
printf "Script Execution Completed\n"




#!/bin/bash

# Configuration
LOG_FILE="/var/log/oracle_swap_check.log"
ALERT_EMAIL="admin@example.com"
SWAP_THRESHOLD=80  # Alert if swap usage exceeds this percentage

# Start logging
echo "=== Oracle Swap Check - $(date) ===" | tee -a "$LOG_FILE"

# Check swap usage
TOTAL_SWAP=$(free -m | awk 'NR==2{print $2}')
USED_SWAP=$(free -m | awk 'NR==2{print $3}')
SWAP_PERCENT=$((100 * USED_SWAP / TOTAL_SWAP))

echo "Total Swap: $TOTAL_SWAP MB, Used Swap: $USED_SWAP MB ($SWAP_PERCENT%)" | tee -a "$LOG_FILE"

# Alert if swap usage exceeds threshold
if [ "$SWAP_PERCENT" -ge "$SWAP_THRESHOLD" ]; then
    echo "ALERT: Swap usage is high! ($SWAP_PERCENT%)" | tee -a "$LOG_FILE"
    echo "Swap usage exceeded threshold on $(hostname) at $(date)" | mail -s "High Swap Usage Alert" "$ALERT_EMAIL"
fi

# Top processes using swap
echo -e "\n=== Top Processes Using Swap ===" | tee -a "$LOG_FILE"
sudo smem -s swap -r | head -n 15 | tee -a "$LOG_FILE"

# Oracle processes using swap
echo -e "\n=== Oracle Processes Using Swap ===" | tee -a "$LOG_FILE"
ps -eo pid,comm,vsize,rss,pmem --sort=-vsize | grep -i oracle | head -n 10 | tee -a "$LOG_FILE"

# Top memory consumers
echo -e "\n=== Top Memory Consumers ===" | tee -a "$LOG_FILE"
ps aux --sort=-%mem | head -n 10 | tee -a "$LOG_FILE"

# System-wide memory usage
echo -e "\n=== Checking System-wide Memory Usage ===" | tee -a "$LOG_FILE"
vmstat -s | grep -E "swap|memory" | tee -a "$LOG_FILE"

# Swap-in/Swap-out activity
echo -e "\n=== Checking Swap-in/Swap-out Activity ===" | tee -a "$LOG_FILE"
vmstat 1 5 | awk 'NR==1 || NR>2 {print}' | tee -a "$LOG_FILE"

# Check swappiness setting
echo -e "\n=== Checking Swappiness Value ===" | tee -a "$LOG_FILE"
cat /proc/sys/vm/swappiness | tee -a "$LOG_FILE"

# Check I/O activity
echo -e "\n=== Checking I/O Activity ===" | tee -a "$LOG_FILE"
iostat -xm 1 5 | awk 'NR<=3 || NR>6' | tee -a "$LOG_FILE"

# Check NUMA Memory Policy
echo -e "\n=== Checking NUMA Memory Policy ===" | tee -a "$LOG_FILE"
numactl --show | tee -a "$LOG_FILE"

# Recommendations
echo -e "\n=== Recommendations ===" | tee -a "$LOG_FILE"
if [ "$SWAP_PERCENT" -ge "$SWAP_THRESHOLD" ]; then
    echo "- Reduce Oracle SGA/PGA memory if possible." | tee -a "$LOG_FILE"
    echo "- Reduce parallel query usage." | tee -a "$LOG_FILE"
    echo "- Tune vm.swappiness (e.g., set it to 10)." | tee -a "$LOG_FILE"
    echo "- Consider adding more RAM or tuning shared memory settings." | tee -a "$LOG_FILE"
else
    echo "- Swap usage is within normal limits." | tee -a "$LOG_FILE"
fi

echo -e "\n=== Script Execution Completed ===\n" | tee -a "$LOG_FILE"
