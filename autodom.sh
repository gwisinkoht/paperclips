## Function ##

# This script runs nslookup against a list of subdomains and
# outputs their associated public IP addresses in a folder
# of your choice.

## Parameters ##

# $1 newline separated list of subdomains to interrogate 

# $2 name for output folder
output_id=$2

###################

## Debug Flag ##

_DEBUG_=true

# Create all folders that will be used
mkdir $output_id
mkdir $output_id/raw_outputs
mkdir $output_id/temp

# Create path variables
raws="./$output_id/raw_outputs/"
output="$output_id"
temp="$output_id/temp"

# Create files to be written
touch $output/subdomains-resolving.txt
touch $output/subdomains-inscope.txt
touch $temp/resolved.txt

# Perform nslookups on all the subdomains excluding wildcards
for f in `cat $1 | grep -v '*'`; 
do	
	defang=`echo $f | tr [.] [_]`;
	touch "$raws/nslook-$defang";
	nslook_output="$raws/nslook-$defang";
	echo "nslookup $f" >> "$nslook_output";
	nslookup $f >> "$nslook_output";
	answer_found=`cat $nslook_output | grep "Name:" | wc -l`

	if [ $_DEBUG_ ]; # debug hint
	then
		echo "nslookup for $f"
		echo "$nslook_output"
	fi

	# Check if the subdomain resolved, if so save it
	if [ $answer_found -gt 0 ];
	then
		raw_resolved=`cat $nslook_output | grep -A 1 "Name:"`;
		echo $raw_resolved | tr "\ Name:" "\nName:" | grep -v "Name:" | grep -v "Address:" >> "$temp/resolved.txt"
	fi
done;

# Reformat the resolving subdomains into a useful layout.

if [ $_DEBUG_ ]; # debug hint
then
	echo "Begin formatting the resolving subdomains into useful layouts.";
	echo "\n#######\n"
fi

count=1
for f in `cat $temp/resolved.txt`;
do
	if [ $_DEBUG_ ];
	then
		echo "The count is: $count"
	fi


	if [ $count -eq 1 ]
	then
		url=$f
		count=2
		if [ $_DEBUG_ ];
		then
			echo "url is: $f"
			echo "count is: $count"
		fi
		continue
	else
		ip=$f
		count=1
		if [ $_DEBUG_ ];
		then
			echo "ip is: $f"
			echo "count is: $count"
			echo "output line is: $url $ip"
		fi
		echo $url $ip >> $output/subdomains-resolving.txt
	fi

	if [ $_DEBUG_ ]
	then
		echo "End of iteration."
	fi
done

# Clean up the temporary files
rm -r $temp


