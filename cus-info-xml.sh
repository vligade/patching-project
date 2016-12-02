#!/bin/bash
#Set Env Variables
NOW=$(date +"%b%Y")
LOG_DIR="/home/axway/patching/$NOW"
CUS_FILE="$LOG_DIR/cusinfo-log.xml"

# Verifying Directories
if [ ! -d $LOG_DIR ]; then
mkdir -p $LOG_DIR
echo "$LOG_DIR log directory doesn't exists , directory created" 
fi


#Customer Information
#Customer Information
if [ ! -f $CUS_FILE ]; then
{	
		# Initializing log files
		> $CUS_FILE
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
		#F_CENV= 'facter env_type' 
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
