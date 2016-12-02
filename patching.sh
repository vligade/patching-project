#bin/bash

############################################################################################################################
#   Name                :  pathing.sh			Alias:System Update                                                        #
#   Purpose             :  Script for system update management with package exclusion 									   #
#   Author				:	Prateek Malik        	      ver 1.0                                                          #
############################################################################################################################

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

#Set Env Variables
NOW=$(date +"Time-%H-%M-%S-DAY-%d-%m-%Y")
CUSER=`whoami`
LOG_DIR="/var/patching/$NOW"
LOG_FILE="$LOG_DIR/infra-te$NOW.log"
TEMP_DIR="/tmp/"
TEMP_FILE="$LOG_DIR/t1.dat"
pwd=`pwd`
home=""
current_key=""
key2update=""
output=""
zypperbin=`which zypper`
# Verifying Directories

if [ ! -d $LOG_DIR ]; then
mkdir -p $LOG_DIR
echo "$LOG_DIR log directory doesn't exists , directory created" 
fi
if [ ! -d $TEMP_DIR ]; then
mkdir -p $TEMP_DIR
echo "$TEMP_DIR temp directory doesn't exists , directory created"
fi

#Updating log file with PID
> $LOG_FILE
echo "$NOW" >> $LOG_FILE
echo PID $$ >> $LOG_FILE
#Network Informatiions
IPADDR=`ifconfig eth0|grep -i "inet addr:"|awk -F ':' '{print$2}'|awk '{print$1}'` 
echo "$IPADDR" >> $LOG_FILE
FQDN=`nslookup $IPADDR 10.129.250.41|grep -i name |awk '{print $4}'` 
echo "$FQDN" >> $LOG_FILE
# Checking & listing suse client activation
echo "##  listing suse client activation" >> $LOG_FILE
ls -l /etc/init.d/rc3.d|grep -i sces-client >> $LOG_DIR/scesata.dat
output="`cat /$LOG_DIR/scesata.dat`"
if [ "$output" = "" ];
  then
	{
    echo "Suse Cline Activation not present" >> $LOG_FILE
	echo "$USER on $IPADDR $FQDN at $NOW Suse Cline Activation fine not present" >> $LOG_FILE
	}
  else
	{
    echo "Suse Clint Activation exists" >> $LOG_FILE
	echo "$USER on $IPADDR $FQDN Suse Cline Activation present =$output" >> $LOG_FILE
	cd /etc/init.d/rc3.d
	rm *sces-client
	cd $pwd
	echo "$pwd" >> $LOG_FILE
	
	}	
fi
echo " Moving forward to system patching"

sleep 10s
# software management 
echo " Moving forward to system patching :: " 

echo "System Update Management In Progress"
echo "System Update Management engaged" >> $LOG_FILE
echo "Checking for repo services" >> $LOG_FILE
$zypperbin ls|grep -v "#"|awk '{print $3}' > $TEMP_FILE
echo "Listing path to raw repo data file : $TEMP_FILE" >>$LOG_FILE
ln=`cat $TEMP_FILE|wc -l `
echo "Lines in raw file :$ln" >> $LOG_FILE
ln2=`expr $ln - 1`
tail -$ln2 $TEMP_FILE > $LOG_DIR/repolist.dat
echo "Remaining Lines :$ln2" >> $LOG_FILE
echo "Listing Repo Service Name" >> $LOG_FILE
cat $LOG_DIR/repolist.dat >> $LOG_FILE
$zypperbin rs susecloud
$zypperbin rs oss
$zypperbin ref
# Mention Updates to be excluded.  			
$zypperbin lu | awk '!/kernel/ && !/xen/'|grep -iE '(v)'|awk '{print $5}'|grep -v Name >> $TEMP_FILE
lines=`$zypperbin lu | awk '!/kernel/ && !/xen/ && !/slessp3-glibc/'|grep -iE '(v)'|awk '{print $5}'|grep -v Name | wc -l`
lines=`expr $lines - 1`
cat $TEMP_FILE > $LOG_DIR/patches.dat
####### send patch list to syslog for patching### user input for rebooot confirmation
################################################################################################
IFS=$'\r\n' GLOBIGNORE='*' :; patches=($(cat $LOG_DIR/patches.dat))
echo "${patches[@]}" >> $LOG_FILE
$zypperbin up ${patches[@]}
# running twice if first run updates only software management package
$zypperbin up ${patches[@]}
#Mention Packages to be removed
$zypperbin rm ruby
#$zypperbin --non-interactive-include-reboot-patches up install-new-recommends ${patches[@]} --auto-agree-with-licenses
$zypperbin lu
