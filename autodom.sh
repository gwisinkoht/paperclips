## Function ##

This script runs nslookup against a list of subdomains and
outputs their associated public IP addresses in a folder
of your choice.

## Parameters ##

# $1 newline separated list of subdomains to interrogate 

# $2 name for output folder
output_id=$2

###################

# Get the 2nd level domain as a string
name=`echo $1 | rev | cut -f 2 -d "." | rev`

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

	# Check if the subdomain resolved, if so save it
	if [ $answer_found -gt 0 ];
	then
		raw_resolved=`cat $nslook_output | grep -A 1 "Name:"`;
		echo $raw_resolved | tr "\ Name:" "\nName:" | grep -v "Name:" | grep -v "Address:" >> "$temp/resolved.txt"
	fi
done;

# Reformat the resolving subdomains into a useful layout.
count=1
for f in `cat $temp/resolved.txt`;
do
	if [ $count -eq 1 ]
	then
		url=$f
		count=2
		pass
	else
		ip=$f
		count=1
	fi
	echo $url $ip >> $output/subdomains-resolving.txt
done

# Clean up the temporary files
rm -r $temp

# Filter out subdomains for in scope external IPs.
while read f;
do
	ip=`echo $f | cut -f 2 -d " "`
	is_inscope=`cat $2 | grep "$ip" | wc -l`
	if [ $is_inscope -gt 0 ]
	then
		echo $f >> $output/subdomains-inscope.txt
	fi
done < $output/subdomains-resolving.txt


