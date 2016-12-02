#bin/bash

############################################################################################################################
#   Name                :  sysinfo.sh			Alias:System Update                                                        #
#   Purpose             :  Script for system post patching data collection 									   #
#   Author				:	Prateek Malik        	      ver 1.0                                                          #
############################################################################################################################

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

#Set Env Variables
NOW=$(date +"%b%Y")
CUSER=`whoami`
LOG_DIR="/var/log/patching/$NOW"
LOG_FILE="$LOG_DIR/$NOWpostpatching.log"
TEMP_DIR="/tmp/"
TEMP_FILE="$LOG_DIR/t1.dat"
pwd=`pwd`
output=""
zypperbin=`which zypper`
rebootbin=`which reboot`
STATFILE="/etc/patchstatus.dat"
POSTPATCH="/etc/postpatching.sh"
#creating stat file
if [ ! -f $STATFILE ]; then
	{
		echo "STATFILE DOESNOT EXIST" >> $LOG_FILE
	}
else
echo	"$STATFILE 	file exists" >> $LOG_FILE
fi
# Verifying Directories
if [ ! -d $LOG_DIR ]; then
mkdir -p $LOG_DIR
echo "$LOG_DIR log directory doesn't exists , directory created" 
fi
if [ ! -d $TEMP_DIR ]; then
mkdir -p $TEMP_DIR
echo "$TEMP_DIR temp directory doesn't exists , directory created"
fi
# Intializing log files
> $LOG_FILE
> $TEMP_FILE
#Updating log file with PID
echo "$NOW" >> $LOG_FILE
echo PID $$ >> $LOG_FILE
#
#Network Informatiions
IPADDR=`/sbin/ifconfig|grep -i "inet addr:"|grep -v "inet addr:127.0.0.1"|awk -F ':' '{print$2}'|awk '{print$1}'` 
echo "$IPADDR" >> $LOG_FILE
FQDN=`nslookup $IPADDR |grep -i name |awk '{print $4}'|grep company_name` 
echo "$FQDN" >> $LOG_FILE
echo "Enter Customer Name"
read cus_name
do "$cus_name" = "" 
	{ 
		echo "Customer name cannot be null"
		echo "Enter Customer Name"
		read cus_name
		
	}
		
		

