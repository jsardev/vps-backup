#!/bin/bash

# Prepare variables
vpsName='vps1'
currentDate=$(date +'%d%m%Y%H%M')
mySqlPassword='PoleKwadratu123'

# Prepare backup directory
mkdir -p /backup/tmp

# Create sub backup packages
7z a -t7z -mx9 /backup/tmp/backup_${vpsName}_opt_${currentDate}.7z -r /opt/*
7z a -t7z -mx9 /backup/tmp/backup_${vpsName}_apache_${currentDate}.7z -r /etc/apache2/*
7z a -t7z -mx9 /backup/tmp/backup_${vpsName}_supervisor_${currentDate}.7z -r /etc/supervisor/*
7z a -t7z -mx9 /backup/tmp/backup_${vpsName}_www_${currentDate}.7z -r /var/www/*
7z a -t7z -mx9 /backup/tmp/backup_${vpsName}_git_${currentDate}.7z -r /home/gogs/repositories/*

# Create MySQL dump
mysqldump -u root -p${mySqlPassword} --databases redmine > /backup/tmp/backup_${vpsName}_mysql_redmine_${currentDate}.sql
mysqldump -u root -p${mySqlPassword} --databases gogs > /backup/tmp/backup_${vpsName}_mysql_gogs_${currentDate}.sql

# Create main backup package
7z a -t7z -mx9 /backup/backup_${vpsName}_${currentDate}.7z /backup/tmp/*

# Cleanup
rm -rf /backup/tmp

# Push to Google Drive
drive push -quiet /backup/