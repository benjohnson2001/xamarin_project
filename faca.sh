#!/bin/bash

# faca: find average cast age

title=$1

wget -U firefox "http://www.google.com/search?q=$title imdb&btnI=Im+Feeling+Lucky" 2> imdb_messages.txt

# error handling if there is connection problem
if ! grep -q "$title imdb&btnI=Im+Feeling+Lucky.* saved" imdb_messages.txt; then
	echo "[ERROR] could not connect to imdb.com"
	IFS=$OLD_IFS	
	exit 1
fi

# retrieve url with imdb tt tag
url=$(grep Location imdb_messages.txt | cut -c 11- | rev | cut -c 13- | rev)fullcredits#cast

# fetch text version of website
lynx -dump "$url" > full_cast_and_crew.txt

# find line numbers surrounding cast list
start=$(grep -n "Cast (in.*order)" full_cast_and_crew.txt | cut -f1 -d:)
end=$(grep -n "Produced by" full_cast_and_crew.txt | cut -f1 -d:)

# error handling if there is no cast (i.e. documentaries)
if [[ $start -eq 0 ]]; then
	echo -e "\r\033[KMovie: $1\t\tAverage Age: no cast listed"
	IFS=$OLD_IFS
	exit 0
fi


# crop document for cast list
sed -n "$start,${end}p" full_cast_and_crew.txt > full_cast.txt

# remove left over cruft between square brackets
sed -i -n '1h;1!H;${;g;s/\[[^][]*\]//g;p;}' full_cast.txt

# remove more cruft by delimiting lines with ... using grep and awk and removing leading white space with sed
rawlist=$(cat full_cast.txt | grep '\.\.\.' | awk 'BEGIN {FS = "[.][.][.]"} ; NF {print $1}' | sed -e 's/^[ \t]*//')


#accumulator
acc=0

# temporarily change internal field separator to newlines
OLD_IFS=$IFS
IFS=$'\n'

# store actor names in array
iter=0
for t in ${rawlist[@]}
do
	actors[$iter]="$t"

		wget -U firefox "http://www.google.com/search?q=${actors[$iter]} imdb&btnI=Im+Feeling+Lucky" 2> imdb_messages.txt

		# error handling if there is connection problem
		if ! grep -q "${actors[$iter]} imdb&btnI=Im+Feeling+Lucky.* saved" imdb_messages.txt; then
			echo "[ERROR] could not connect to imdb.com"
			IFS=$OLD_IFS		
			exit 1
		fi

		# if birth date is not provided, continue to the next actor
		if ! grep -q "birthDate\" datetime=" *"${actors[$iter]}"*Im+Feeling+Lucky; then
			echo -n -e "\r\033[KMovie: $1\t\tActor: ${actors[$iter]}\t\tAge: not listed"
			rm *"${actors[$iter]}"*Im+Feeling+Lucky		
			continue
		fi		
	
		# extract the birth date from the value of the datetime id and store the value in date_born
		date_born=$(grep "birthDate\" datetime=" *"${actors[$iter]}"*Im+Feeling+Lucky | awk 'BEGIN {FS = "datetime=" } ; NF {print $2}' | cut -c 2- | rev | cut -c 3- | rev | sed -e 's/-//g')
		now=$(date +%Y%m%d)

		# determine age by subtracting birth date from the current date
		sec1=$(date -d $date_born +'%s')
		sec2=$(date -d $now +'%s')
		diffsec=$(($sec2 - $sec1))
		age=$(($diffsec / 365 / 24 / 3600))
				


		echo -n -e "\r\033[KMovie: $1\t\tActor: ${actors[$iter]}\t\tAge: $age"
		acc=$(($acc + $age))

		rm imdb_messages.txt
		rm *"${actors[$iter]}"*Im+Feeling+Lucky

	((iter++))	
done



	average_age=$(bc <<< "scale = 2; $acc / $iter")
	echo -e "\r\033[KMovie: $1\t\tAverage Age: $average_age"	





rm imdb_messages.txt
rm full_cast_and_crew.txt
rm full_cast.txt
rm *"${title}"*Im+Feeling+Lucky



