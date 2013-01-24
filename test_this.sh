#!/bin/bash

date_born=19570101
now=$(date +%Y%m%d)

sec1=$(date -d $date_born +'%s')
sec2=$(date -d $now +'%s')
diffsec=$(($sec2 - $sec1))
age=$(($diffsec / 365 / 24 / 3600))
echo $age

