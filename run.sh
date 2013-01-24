#!/bin/bash

# retrieve list of movies currently playing
wget -U firefox 'http://www.rottentomatoes.com/syndication/tab/in_theaters.txt' 2> in_theaters_messages.txt

# error handling if there is connection problem
if ! grep -q 'saved' in_theaters_messages.txt; then
	echo "[ERROR] could not connect to rottentomatoes.com feed"
	IFS=$OLD_IFS
	exit 1
fi

# parse list for movie titles
rawlist=$(cat in_theaters.txt | awk 'BEGIN {FS = "\t" } ; NF {print $2}' | sed -e '1,1d')

# temporarily change internal field separator to newlines
OLD_IFS=$IFS
IFS=$'\n'

# store values in array
iter=0
for t in ${rawlist[@]}
do
	movies[$iter]="$t"
		
		# \r 		moves cursor to beginning of the line		
		# \033[K 	clears the line for new text		
		# -n 		does not output the trailing newline
		# -e 		enables escape sequences	
		
		echo -n -e "\r\033[KMovie: ${movies[$iter]}\n\n\n"
		
	# strip newlines	
	param=$(echo ${movies[$iter]} | perl -ne 'chomp and print')

	# find average age
	bash faca.sh $param

	sleep 10

	((iter++))	
done

rm in_theaters.txt
rm in_theaters_messages.txt

IFS=$OLD_IFS
