#!/bin/bash

# faca: find average cast age

title='Lincoln'

wget -U firefox "http://www.google.com/search?q=$title imdb&btnI=Im+Feeling+Lucky" 2> imdb_messages.txt

# error handling if there is connection problem
if ! grep -q "$title imdb&btnI=Im+Feeling+Lucky.* saved" imdb_messages.txt; then
	echo "[ERROR] could not connect to imdb.com"
	exit 1
fi

# retrieve url with imdb tt tag
url=$(grep Location imdb_messages.txt | cut -c 11- | rev | cut -c 13- | rev)fullcredits#cast

# fetch text version of website
lynx -dump "$url" > full_cast_and_crew.txt

# find line numbers surrounding cast list
start=$(grep -n "Cast (in credits order)" full_cast_and_crew.txt | cut -f1 -d:)
end=$(grep -n "Produced by" full_cast_and_crew.txt | cut -f1 -d:)

# crop document for cast list
sed -n "$start,${end}p" full_cast_and_crew.txt > raw_full_cast.txt

# remove left over cruft between square brackets
sed -i -n '1h;1!H;${;g;s/\[[^][]*\]//g;p;}' raw_full_cast.txt

# remove more cruft by delimiting lines with ... using grep and awk and removing leading white space with sed
rawlist=$(cat raw_full_cast.txt | grep '\.\.\.' | awk 'BEGIN {FS = "[.][.][.]"} ; NF {print $1}' | sed -e 's/^[ \t]*//')


# temporarily change internal field separator to newlines
OLD_IFS=$IFS
IFS=$'\n'

# store actor names in array
iter=0
for t in ${rawlist[@]}
do
	actors[$iter]="$t"
#	printf "$iter\n"	
#	printf "$t\n"	
	((iter++))	
done

#printf "\n\n\n${actors[0]}\n\n\n${actors[169]}\n"

rm imdb_messages.txt
rm full_cast_and_crew.txt
rm raw_full_cast.txt
rm *${title}*Im+Feeling+Lucky

IFS=$OLD_IFS
