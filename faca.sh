#!/bin/bash

# faca: find average cast age

title='Lincoln'

wget -U firefox "http://www.google.com/search?q=$title imdb&btnI=Im+Feeling+Lucky" 2> imdb_messages.txt

# error handling if there is connection problem
if ! grep -q "search@q=$title imdb&btnI=Im+Feeling+Lucky""'"" saved" imdb_messages.txt; then
	echo "[ERROR] could not connect to imdb.com"
	exit 1
fi

url=$(grep Location imdb_messages.txt | cut -c 11- | rev | cut -c 13- | rev)fullcredits#cast

lynx -dump "$url" > full_cast_and_crew.txt

start=$(grep -n "Cast (in credits order)" full_cast_and_crew.txt | cut -f1 -d:)
end=$(grep -n "Produced by" full_cast_and_crew.txt | cut -f1 -d:)

sed -n "$start,${end}p" full_cast_and_crew.txt > full_cast.txt

rm imdb_messages.txt
rm search@q=*
