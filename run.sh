#!/bin/bash

# retrieve list of movies currently playing
# wget -U firefox 'http://www.rottentomatoes.com/syndication/tab/in_theaters.txt' 2> in_theaters_messages.txt

# error handling if there is connection problem
if ! grep -q 'saved' in_theaters_messages.txt; then
	echo "[ERROR] could not connect to rottentomatoes.com feed"
	IFS=$OLD_IFS
	exit 1
fi

# parse list for movie titles
rawlist=$(cat in_theaters.txt | awk 'BEGIN {FS = "\t" } ; NF {print $2}' | sed -e '1,1d')

# temporarily change internal field separator to newlines, helps avoid word splitting issues
OLD_IFS=$IFS
IFS=$'\n'

# store movie titles in bash array
iter=0
for t in ${rawlist[@]}
do
	movies[$iter]="$t"
		
	# print movie title to screen	
	#	 \r 		moves cursor to beginning of the line		
	#	 \033[K 	clears the line for new text		
	#	 -n 		does not output the trailing newline
	#	 -e 		enables escape sequences			
	echo -n -e "\r\033[KMovie: ${movies[$iter]}\n\n\n"
		
	# find average age
	bash faca.sh ${movies[$iter]}

	((iter++))	
done

# clean up files that are no longer needed
rm in_theaters.txt
rm in_theaters_messages.txt

# return environment variable to previous state
IFS=$OLD_IFS
