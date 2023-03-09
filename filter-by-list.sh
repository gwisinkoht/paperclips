## DESCRIPTION ##
# This script accepts two lists. It returns values
# from the second list that match values in the first
# list.
#
## PARAMETERS ##
# List of values to match in the second file. Must contain no duplicates.
filter=$1

# List to be filtered.
rawdata=$2

while read line
do
cat $rawdata | grep $line
done < $filter
