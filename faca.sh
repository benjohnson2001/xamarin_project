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

echo $url

# rm imdb_messages.txt
# rm search@q=*
