#!/bin/sh
############################################################################################################################
#   Name                :  system_information         ::          Alias:sys-info                                           #
#   Purpose             :  Fetch the system information and create a XML Report.                                           #
#   Author              :  Prateek Malik     Last modified by: Prateek    ::   ver 1.0                                     #
############################################################################################################################

#Set Env Variables
NOW=$(date +"%b%Y")
CUSER=`whoami`
LOG_DIR="/var/log/patching/$NOW"
LOG_FILE="$LOG_DIR/sysinfo-log.xml"
CUS_FILE="$LOG_DIR/cusinfo-log.xml"
TEMP_DIR="/tmp/"
TEMP_FILE="$LOG_DIR/t1.dat"
STATFILE="/etc/patchstatus.dat"
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

#Customer Information
if [ ! -f $CUS_FILE ]; then
{	
		echo -E '<?xml version="1.0" encoding="UTF-8"?>' >> $CUS_FILE
		echo -e "<CUSINFO>" >> $CUS_FILE
		#Instance ID
		echo "<INSTID>"$(cat /etc/ec2/instance)"</INSTID>" >> $CUS_FILE
		#Customer Name
		echo "Enter Customer Name"
		read c_name
		echo "<CNAME>$c_name</CNAME>" >> $CUS_FILE
		while [ "$c_name" == "" ]
		do 
                { 
					echo "Customer name cannot be null"
                    echo "Enter Customer Name"
                    read cus_name
                    echo "<CNAME>$c_name</CNAME>" >> $CUS_FILE
                }
		done
		#Environment Type
		F_CENV= 'facter env_type' 
		echo "Enter environment type of the customer"
		read c_env
		echo "<CENV>$c_env</CENV>" >> $CUS_FILE
		while [ "$c_env" == "" ]
			do 
                { 
					echo "Customer environment type cannot be null"
					echo "Enter environment type of the customer"
					read c_env
                    echo "<CENV>$c_env</CENV>" >> $CUS_FILE
                }
			done
		echo -e "<CUSINFO/>" >> $CUS_FILE	
		#Instance Status
		
}	
fi		

#System Information
echo -E '<?xml version="1.0" encoding="UTF-8"?>' >> $LOG_FILE
echo -e "<SYSINFO>" >> $LOG_FILE
#Network Information
IPADDR=`ifconfig eth0|grep -i "inet addr:"|awk -F ':' '{print$2}'|awk '{print$1}'` 
echo "<IP>$IPADDR</IP>" >> $LOG_FILE
FQDN=`nslookup $IPADDR |grep -i name |awk '{print $4}'|grep company_name` 
echo "<FQDN>$FQDN</FQDN>" >> $LOG_FILE
echo -e "<FSTAB>" >> $LOG_FILE
cat /etc/fstab > $TEMP_FILE
input="$TEMP_FILE"
while IFS= read -r var
	do
		echo -e "\t<n1> $var </n1> "|tr '\n' ' ' >> $LOG_FILE
	done < "$input"
echo -e "</FSTAB>" >> $LOG_FILE
echo -e "<DF-H>" >> $LOG_FILE
df -h > $TEMP_FILE
input="$TEMP_FILE"
while IFS= read -r var
	do
		echo -e "\t<n1>$var</n1>"|tr '\n' ' ' >> $LOG_FILE
	done < "$input"
echo -e "</DF-H>" >> $LOG_FILE
echo -e "<Package-versions>" >> $LOG_FILE
rpm -qa > $TEMP_FILE
input="$TEMP_FILE"
while IFS= read -r var
	do
		echo -e "\t<n1>$var</n1>"|tr '\n' ' ' >> $LOG_FILE
	done < "$input"
echo -e "</Package-versions>" >> $LOG_FILE
echo -e "<CRONTAB>" >> $LOG_FILE
echo -e "<CRONTAB-root>" >> $LOG_FILE
crontab -l|grep -v "#" > $TEMP_FILE
input="$TEMP_FILE"
while IFS= read -r var
	do
		echo -e "<n1>$var</n1>" >> $LOG_FILE
		done < "$input"
echo -e "</CRONTAB-root>" >> $LOG_FILE	
#echo -e "<CRONTAB-company_name>" >> $LOG_FILE	
		#crontab -l -u company_name |grep -v "#" > $TEMP_FILE
		#	input="$TEMP_FILE"
		#	while IFS= read -r var
		#	do
		#	  echo -e "<n1>$var</n1>" >> $LOG_FILE
		#	done < "$input"
	#echo -e "</CRONTAB-company_name>" >> $LOG_FILE		
echo -e "</CRONTAB>" >> $LOG_FILE

#Reboot Status
UPTIME= 'who -b | awk {'print $4 $3 $5'}'
echo -e "</SYSINFO>" >> $LOG_FILE
clear
#echo -e " \t Attached is the list of App user company_name processes \n \t Please stop these process in order to proceed with auto patching" | mail -s "company_name user have active processs" -a $LOG_FILE -r cloud.infra.us@company_name.com  abkumar@company_name.com
