#!/bin/bash

function get_date {
  if [ -z $1 ]
  then
    opt=0
  else
    opt=$1
  fi
  date --utc +%Y-%m-%d --date="-$opt day"
}

backup_dir=$(readlink ~/backups)
date_stamp=$(get_date)
time_stamp=$(date --utc +%H-%M-%S)

dir="$backup_dir/$date_stamp"
file="$dir/$time_stamp-home.tgz"
logfile="$dir/$time_stamp.log"

dayly_found=false
weekly_found=false
monthly_found=false

for i in {0..30}
do
  if [ -d "$backup_dir/$(get_date $i)" ]; then
    if [ $i -lt 1 ]; then
      dayly_found=true
    fi
    if [ $i -lt 7 ]; then
      weekly_found=true
    fi
    if [ $i -lt 30 ]; then
      monthly_found=true
    fi
  fi
done

if [ "$monthly_found" = false ]; then
list="monthly-list"
else
  if [ "$weekly_found" = false ]; then
    list="weekly-list"
  else
    if [ "$dayly_found" = false ]; then
      list="dayly-list"
    else
      echo "$dayly_found"
      exit
    fi
  fi
fi

backup_list="$backup_dir/$list.sh"

echo "$backup_list"
exit

mkdir -p $dir
rc=$?
if [[ $rc != 0 ]] ; then
  zenity --info --title "Backup problem" --text "Cannot create directory $dir"
  exit
fi

if ! [[ -x $backup_list ]]
then
  zenity --info --title "Backup problem" --text "List file is not executable"
  exit
fi

t1=$(date +"%s")
~/code/delo.sh
~/prog/delo.sh
$backup_list | xargs tar cvfz $file | tee $logfile
t2=$(date +"%s")

t_diff=$(($t2-$t1))
size=$(stat -c%s "$file")
mb_size=$(expr $size / 1024 / 1024)

zenity --info --title "Backup OK" --text "Backup file $file created\nLog file: $logfile\nTotal size: $size ($mb_size MiB)\nTime needed: $t_diff seconds"
