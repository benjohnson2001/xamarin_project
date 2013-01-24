#!/bin/bash

actor='Daniel Day-Lewis'

wget -U firefox "http://www.google.com/search?q=$actor imdb&btnI=Im+Feeling+Lucky" 2> imdb_messages.txt

# error handling if there is connection problem
if ! grep -q "$actor imdb&btnI=Im+Feeling+Lucky.* saved" imdb_messages.txt; then
	echo "[ERROR] could not connect to imdb.com"
	exit 1
fi

# extract the birth date from the value of the datetime id and store the value in date_born
date_born=$(grep datetime= search\?q\=Daniel\ Day-Lewis\ imdb\&btnI\=Im+Feeling+Lucky | awk 'BEGIN {FS = "datetime=" } ; NF {print $2}' | cut -c 2- | rev | cut -c 3- | rev | sed -e 's/-//g')
now=$(date +%Y%m%d)

sec1=$(date -d $date_born +'%s')
sec2=$(date -d $now +'%s')
diffsec=$(($sec2 - $sec1))
age=$(($diffsec / 365 / 24 / 3600))
echo $age


rm imdb_messages.txt
rm *"${actor}"*Im+Feeling+Lucky
