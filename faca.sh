#!/bin/bash

# faca: find average cast age

title=$1

# retrieve imdb url from "I'm Feeling Lucky" Google Search
wget -U firefox "http://www.google.com/search?q=$title imdb&btnI=Im+Feeling+Lucky" 2> imdb_messages.txt

# error handling if there is connection problem
if ! grep -q "saved" imdb_messages.txt; then
	echo "[ERROR] could not connect to imdb.com"
	rm imdb_messages.txt
	IFS=$OLD_IFS	
	exit 1
fi

# modify url to display full cast information
url=$(grep Location imdb_messages.txt | cut -c 11- | rev | cut -c 13- | rev)fullcredits#cast

		# save html source to file
		wget -U firefox "$url" 2> /dev/null
		
		# find line numbers surrounding cast list
		start=$(grep -n "(in.*order)" fullcredits | cut -f1 -d:)
		end=$(grep -n "Produced by" fullcredits | cut -f1 -d:)		
		
		# crop document for cast list
		sed -n "$start,$(($end-1))p" fullcredits | awk 'BEGIN {FS = "rder)" } ; NF {print $2}' > castlist.txt
				
		rm fullcredits		
				
		# extract links from "fullcredits" source file, extract name tags and remove duplicates
		links=$(python extract_links.py castlist.txt | grep nm | uniq)
		
		# store actor imdb urls in array
		# temporarily change internal field separator to newlines, helps avoid word splitting issues
		OLD_IFS=$IFS
		IFS=$'\n'

		# store actor names in bash array
		i=0
		for t in ${links[@]}
		do
			actor_url[i]=http://www.imdb.com$t
			((i++))
		done		

# fetch text version of website
lynx -dump "$url" > full_cast_and_crew.txt

# find line numbers surrounding cast list
start=$(grep -n "Cast (in.*order)" full_cast_and_crew.txt | cut -f1 -d:)
end=$(grep -n "Produced by" full_cast_and_crew.txt | cut -f1 -d:)

# print results if there is no cast (i.e. documentaries)
if [[ $start -eq 0 ]]; then

	# clear the last three lines
	#	 \r 		moves cursor to beginning of the line
	#	 \033[1A	moves cursor up one line		
	#	 \033[K 	clears the line for new text		
	#	 -n 		does not output the trailing newline
	#	 -e 		enables escape sequences	
	echo -e -n "\r\033[K\033[1A\r\033[K\033[1A\r\033[K\033[1A\r\033[K"

	echo -e "\r\033[KMovie: $1\r\t\t\t\t\t    Average Age: no ages listed"
	IFS=$OLD_IFS
	rm imdb_messages.txt
	rm full_cast_and_crew.txt
	exit 0
fi


# crop document for cast list
sed -n "$start,${end}p" full_cast_and_crew.txt > full_cast.txt

# remove left over junk between square brackets
sed -i -n '1h;1!H;${;g;s/\[[^][]*\]//g;p;}' full_cast.txt

# remove more cruft by delimiting lines with ... using grep and awk and removing leading white space with sed
rawlist=$(cat full_cast.txt | grep '\.\.\.' | awk 'BEGIN {FS = "[.][.][.]"} ; NF {print $1}' | sed -e 's/^[ \t]*//')

#accumulator
acc=0

# store actor names in bash array
iter=0
for t in ${rawlist[@]}
do

	actors[$iter]="$t"

	# retrieve html source file of actor's imdb page
	wget -O ${actors[$iter]} -U firefox "${actor_url[$iter]}" 2> imdb_messages.txt
					
	# error handling if there is connection problem
	if ! grep -q "saved" imdb_messages.txt; then
		echo "[ERROR] could not connect to imdb.com"
		rm imdb_messages.txt
		rm full_cast_and_crew.txt
		rm full_cast.txt
		rm ${actors[$iter]}		
		IFS=$OLD_IFS		
		exit 1
	fi

	# if birth date is not provided, continue to the next actor
	if ! grep -q "birthDate\" datetime=" *"${actors[$iter]}"*; then
		echo -e -n "\r\033[K\033[1A\r\033[K\033[1A\r\033[K\033[1A\r\033[K"
		echo -n -e "\r\033[KMovie: $1\n  |\n  | Actor: ${actors[$iter]}\n  | Age: not listed"
				
		((iter++))	
		continue
	fi		

	# extract the birth date from the value of the datetime id and store the value in date_born
	date_born=$(grep "birthDate\" datetime=" *"${actors[$iter]}"* | awk 'BEGIN {FS = "datetime=" } ; NF {print $2}' | cut -c 2- | rev | cut -c 3- | rev | sed -e 's/-//g')
	now=$(date +%Y%m%d)
	
	# if only the birth year is given, pad the number
	if [[ "${#date_born}" -eq 4 ]]; then
		date_born=${date_born}0101
	fi
	
	# if only the birth year and month is given, pad the number
	if [[ "${#date_born}" -eq 6 ]]; then
		date_born=${date_born}01
	fi	

	# determine age by subtracting birth date from the current date
	sec1=$(date -d $date_born +'%s')
	sec2=$(date -d $now +'%s')
	diffsec=$(($sec2 - $sec1))
	age=$(($diffsec / 365 / 24 / 3600))
		
	# accumulate ages for calculation of average
	acc=$(($acc + $age))	

	# print actor names and ages to show real-time progress
	echo -e -n "\r\033[K\033[1A\r\033[K\033[1A\r\033[K\033[1A"	
	echo -n -e "\r\033[KMovie: $1\n  |\n  | Actor: ${actors[$iter]}\n  | Age: $age"

	# clear files for next loop
	rm imdb_messages.txt

	((iter++))	
done

	# if there are no ages listed, print the results
	if [[ $acc -eq 0 ]]; then
		echo -e -n "\r\033[K\033[1A\r\033[K\033[1A\r\033[K\033[1A\r\033[K"
		echo -e "\r\033[KMovie: $1\r\t\t\t\t\t    Average Age: no ages listed"
		IFS=$OLD_IFS
		rm imdb_messages.txt
		rm full_cast_and_crew.txt
		exit 0
	fi

	# calculate average age of cast
	average_age=$(bc <<< "scale = 2; $acc / $iter")

	# clear last three lines and print result
	echo -e -n "\r\033[K\033[1A\r\033[K\033[1A\r\033[K\033[1A\r\033[K"
	echo -e "Movie: $1\r\t\t\t\t\t    Average Age: $average_age"	


# clean up files for next invocation

# check if file exists first before attempting to delete
if [[ -f imdb_messages.txt ]]; then
	rm imdb_messages.txt
fi

rm full_cast_and_crew.txt
rm full_cast.txt
rm ${actors[$iter]}	

# return environment variable to previous state
IFS=$OLD_IFS
