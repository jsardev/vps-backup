#!/bin/bash

# Configuration
vpsName='vps1'
mySqlPassword='PoleKwadratu123'
daysToLive=7

# Preparation
mkdir -p /backup/tmp
cd /backup

# Create sub backup packages
currentDayTimestamp=$(date +'%d%m%Y%H%M')

7z a -t7z -mx9 /backup/tmp/backup_${vpsName}_opt_${currentDayTimestamp}.7z -r /opt/*
7z a -t7z -mx9 /backup/tmp/backup_${vpsName}_apache_${currentDayTimestamp}.7z -r /etc/apache2/*
7z a -t7z -mx9 /backup/tmp/backup_${vpsName}_supervisor_${currentDayTimestamp}.7z -r /etc/supervisor/*
7z a -t7z -mx9 /backup/tmp/backup_${vpsName}_www_${currentDayTimestamp}.7z -r /var/www/*
7z a -t7z -mx9 /backup/tmp/backup_${vpsName}_git_${currentDayTimestamp}.7z -r /home/gogs/repositories/*

# Create MySQL dump
mysqldump -u root -p${mySqlPassword} --databases redmine > /backup/tmp/backup_${vpsName}_mysql_redmine_${currentDayTimestamp}.sql
mysqldump -u root -p${mySqlPassword} --databases gogs > /backup/tmp/backup_${vpsName}_mysql_gogs_${currentDayTimestamp}.sql

# Create main backup package
7z a -t7z -mx9 /backup/backup_${vpsName}_${currentDayTimestamp}.7z /backup/tmp/*

# Push to Google Drive
drive push -quiet -no-clobber

# Remove leftovers and backups older than 7 days from Google Drive
rm -rf /backup/*

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