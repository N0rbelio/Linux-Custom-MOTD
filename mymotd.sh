#!/bin/bash
#Made with love by N0bleDeath

BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
RESET='\033[0m'
echo -e  ""
echo -e  " Welcome to © NAME We have ${YELLOW}terms and conditions${RESET} but if you are Portuguese dont worry reading them m8."
echo -e  ""
figlet -w 80 -f Slant NAME |lolcat -S 17 -a -d 1 -t
#cowsay -f tux Kubuntu says: Fuck Windows! Linux for ever!

# get cpu load 
LOAD1=`cat /proc/loadavg | awk {'print $1'}`
LOAD5=`cat /proc/loadavg | awk {'print $2'}`
LOAD15=`cat /proc/loadavg | awk {'print $3'}`
# get load averages
IFS=" " read LOAD1 LOAD5 LOAD15 <<<$(cat /proc/loadavg | awk '{ print $1,$2,$3 }')
# get free memory
IFS=" " read USED AVAIL TOTAL <<<$(free -htm | grep "Mem" | awk {'print $3,$7,$2'})
# get processes
PROCESS=`ps -eo user=|sort|uniq -c | awk '{ print $2 " " $1 }'`
PROCESS_ALL=`echo "$PROCESS"| awk {'print $2'} | awk '{ SUM += $1} END { print SUM }'`
PROCESS_ROOT=`echo "$PROCESS"| grep root | awk {'print $2'}`
PROCESS_USER=`echo "$PROCESS"| grep -v root | awk {'print $2'} | awk '{ SUM += $1} END { print SUM }'`
# get processors
PROCESSOR_NAME=`grep "model name" /proc/cpuinfo | cut -d ' ' -f3- | awk {'print $0'} | head -1`
PROCESSOR_COUNT=`grep -ioP 'processor\t:' /proc/cpuinfo | wc -l`


W="\e[0;39m"
G="\e[1;32m"

echo -e "
${W}System Info:
$W  Distro......: $W`cat /etc/*release | grep "PRETTY_NAME" | cut -d "=" -f 2- | sed 's/"//g'`
$W  Kernel......: $W`uname -sr`

$W  Uptime......: $W`uptime -p`
$W  Processes...:$W $G$PROCESS_ROOT$W (root), $G$PROCESS_USER$W (user), $G$PROCESS_ALL$W (total)

$W  CPU.........: $W$PROCESSOR_NAME ($G$PROCESSOR_COUNT$W vCPU)
$W  CPU Usage...: $G$LOAD1$W% (1m), $G$LOAD5$W% (5m), $G$LOAD15$W% (15m)
$W  Memory......: $G$USED$W used, $G$AVAIL$W avail, $G$TOTAL$W total$W"





# config
max_usage=90
bar_width=50
# colors
white="\e[39m"
green="\e[1;32m"
red="\e[1;31m"
dim="\e[2m"
undim="\e[0m"

# disk usage: ignore zfs, squashfs & tmpfs
mapfile -t dfs < <(df -H -x zfs -x squashfs -x tmpfs -x devtmpfs -x overlay --output=target,pcent,size | tail -n+2)
printf "\nDisk usage:\n"

for line in "${dfs[@]}"; do
    # get disk usage
    usage=$(echo "$line" | awk '{print $2}' | sed 's/%//')
    used_width=$((($usage*$bar_width)/100))
    # color is green if usage < max_usage, else red
    if [ "${usage}" -ge "${max_usage}" ]; then
        color=$red
    else
        color=$green
    fi
    # print green/red bar until used_width
    bar="[${color}"
    for ((i=0; i<$used_width; i++)); do
        bar+="■"
    done
    # print dimmmed bar until end
    bar+="${white}${dim}"
    for ((i=$used_width; i<$bar_width; i++)); do
        bar+="="
    done
    bar+="${undim}]"
    # print usage line & bar
    echo "${line}" | awk '{ printf("%-31s%+3s used out of %+4s\n", $1, $2, $3); }' | sed -e 's/^/  /'
    echo -e "${bar}" | sed -e 's/^/  /'
done
echo ""

# config
MAX_TEMP=40
# set column width
COLUMNS=2
# colors
white="\e[39m"
green="\e[1;32m"
red="\e[1;31m"
dim="\e[2m"
undim="\e[0m"

echo "Smartd status:"
for i in $(lsblk | grep -E "disk" | awk '{print $1}')
	do
	DevSupport=`smartctl -a /dev/$i | awk '/SMART support is:/{print $0}' | awk '{print $4}' | tail -1`
	if [ "$DevSupport" == "Enabled" ]
	then  
	DevTemp=`smartctl -d ata -A /dev/$i | awk '/Temperature/{print $0}' | awk '{print $10 ""}'`
	DevStatus1=`smartctl -a /dev/$i | awk '/SMART overall-health/{print $0}' | awk '{print $5}'`
	DevStatus2=`smartctl -a /dev/$i | awk '/SMART overall-health/{print $0}' | awk '{print $6}'`
	if [[ "${DevTemp}" -gt "${MAX_TEMP}" ]]; then
		color=$(tput setaf 1)
	else
		color=$(tput setaf 2)
	fi
	if [[ "$DevTemp" =~ ^[0-9]+$ ]]; then
			temp="${DevTemp}"
		fi
	if [[ "${DevStatus2}" == "SMART result: PASSED" ]]; then
		status_color=$(tput setaf 1)
	else
		status_color=$(tput setaf 2)
	fi
	echo " $i:  ${color}${DevTemp}°$(tput setaf 7) | ${DevStatus1}${status_color}${DevStatus2}$(tput setaf 7)" | awk -F:: '{printf "%-7s%-6s%-22s%-20s%s\n", $1, $2, $3, $4, $5}'
	fi
done
 
 
# set column width
COLUMNS=3
# colors
green="\e[1;32m"
red="\e[1;31m"
undim="\e[0m"

services=("fail2ban" "smartd" "openvpn")
# sort services
IFS=$'\n' services=($(sort <<<"${services[*]}"))
unset IFS

service_status=()
# get status of all services
for service in "${services[@]}"; do
    service_status+=($(systemctl is-active "$service"))
done

out=""
for i in ${!services[@]}; do
    # color green if service is active, else red
    if [[ "${service_status[$i]}" == "active" ]]; then
        out+="${services[$i]}:,${green}${service_status[$i]}${undim},"
    else
        out+="${services[$i]}:,${red}${service_status[$i]}${undim},"
    fi
    # insert \n every $COLUMNS column
    if [ $((($i+1) % $COLUMNS)) -eq 0 ]; then
        out+="\n"
    fi
done
out+="\n"

printf "\nServices:\n"
printf "$out" | column -ts $',' | sed -e 's/^/  /'


logfile='/var/log/fail2ban.log*'
mapfile -t lines < <(grep -hioP '(\[[a-z-]+\]) ?(?:restore)? (ban|unban)' $logfile | sort | uniq -c)
jails=($(printf -- '%s\n' "${lines[@]}" | grep -oP '\[\K[^\]]+' | sort | uniq))

out=""
for jail in ${jails[@]}; do
    bans=$(printf -- '%s\n' "${lines[@]}" | grep -iP "[[:digit:]]+ \[$jail\] ban" | awk '{print $1}')
    restores=$(printf -- '%s\n' "${lines[@]}" | grep -iP "[[:digit:]]+ \[$jail\] restore ban" | awk '{print $1}')
    unbans=$(printf -- '%s\n' "${lines[@]}" | grep -iP "[[:digit:]]+ \[$jail\] unban" | awk '{print $1}')
    bans=${bans:-0} # default value
    restores=${restores:-0} # default value
    unbans=${unbans:-0} # default value
    bans=$(($bans+$restores))
    diff=$(($bans-$unbans))
    out+=$(printf "$jail, %+3s bans, %+3s unbans, %+3s active" $bans $unbans $diff)"\n"
done

printf "\nFail2ban status (monthly): $(tput setaf 1)Offline\n$(tput setaf 7)"
printf "$out" | column -ts $',' | sed -e 's/^/  /'
