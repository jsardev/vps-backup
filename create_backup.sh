#!/bin/bash

# Configuration
vpsName='vps1'
mySqlPassword='AB7f0vDvgGzT0IJ'
daysToLive=7

# Preparation
mkdir -p $HOME/backup/tmp
cd $HOME/backup

# Create sub backup packages
currentDayTimestamp=$(date +'%d%m%Y%H%M')

7z a -t7z -mx9 $HOME/backup/tmp/backup_${vpsName}_opt_${currentDayTimestamp}.7z -r /opt/*
7z a -t7z -mx9 $HOME/backup/tmp/backup_${vpsName}_apache_${currentDayTimestamp}.7z -r /etc/apache2/*
7z a -t7z -mx9 $HOME/backup/tmp/backup_${vpsName}_supervisor_${currentDayTimestamp}.7z -r /etc/supervisor/*
7z a -t7z -mx9 $HOME/backup/tmp/backup_${vpsName}_www_${currentDayTimestamp}.7z -r /var/www/*

# Create MySQL dump
mysqldump -u root -p${mySqlPassword} --all-databases > $HOME/backup/tmp/backup_${vpsName}_mysql_${currentDayTimestamp}.sql

# Create main backup package
7z a -t7z -mx9 $HOME/backup/backup_${vpsName}_${currentDayTimestamp}.7z $HOME/backup/tmp/*

# Push to Google Drive
drive push -quiet -no-clobber

# Remove leftovers and backups older than 7 days from Google Drive
rm -rf $HOME/backup/*

packages=$(drive list | grep -Po 'backup_vps[0-9]_[0-9]{12}')
packagesToDelete=${packages}

for dayCount in $(seq 0 ${daysToLive})
do
        timestamp=$(date -d "$dayCount day ago" +%d%m%Y)
        packagesToDelete=$(echo "$packagesToDelete" | grep -v ${timestamp})
done

for package in ${packagesToDelete}
do
        drive trash -quiet -matches ${package}
done