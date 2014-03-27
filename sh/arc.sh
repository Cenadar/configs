#!/bin/bash

backup_dir=$(readlink ~/backups)
date_stamp=$(date --utc +%Y-%m-%d)
time_stamp=$(date --utc +%H-%M-%S)

dir="$backup_dir/$date_stamp"
file="$dir/$time_stamp-home.tgz"
logfile="$dir/$time_stamp.log"
backup_list="$backup_dir/1.list.sh"

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
opt=""
#opt="--use-compress-program=pigz"
~/code/delo.sh
~/prog/delo.sh
$backup_list | xargs tar cvfz $opt $file | tee $logfile
t2=$(date +"%s")

t_diff=$(($t2-$t1))
size=$(stat -c%s "$file")
mb_size=$(expr $size / 1024 / 1024)

zenity --info --title "Backup OK" --text "Backup file $file created\nLog file: $logfile\nTotal size: $size ($mb_size MiB)\nTime needed: $t_diff seconds"
