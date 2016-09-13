#!/bin/bash

#######################
#### CONFIGURATION ####
#######################

DIRECTORIES=()

while [[ $# -gt 1 ]]
do

key="$1"

case $key in
    -n|--name)
    NAME="$2"
    shift;;
    -d|--directories)
    DIRECTORIES+=("$2")
    shift;;
    -m|--mysql)
    MYSQL=true
    shift;;
    -mp|--mysql-password)
    MYSQL_PASSWORD="$2"
    shift;;
esac

shift
done

if [ -v $NAME ]; then
    echo "define server name (-n/--name parameter)"
    exit
fi

if [ "$MYSQL" = true ]; then
    if [ -v $MYSQL_PASSWORD ]; then
        echo "define mysql password (-mp/--mysql-password parameter)"
        exit
    fi
fi

if [ "${#DIRECTORIES[@]}" -le 0 ]; then
    echo "define directories to backup (-d/--directories parameter)"
    exit
fi

###############################
#### CREATING SUB PACKAGES ####
###############################

echo "[$(date)] Creating sub packages..."

DAYS_TO_LIVE=7
CURRENT_DAY_TIMESTAMP=$(date +'%d%m%Y%H%M')

mkdir -p $HOME/backup/tmp
cd $HOME/backup

for DIRECTORY in ${DIRECTORIES[@]}
do
    DIRECTORY_STRING="($(sed "s/\//_/g" <<< ${DIRECTORY}))"
    SUB_PACKAGE_DESTINATION_PATH="${HOME}/backup/tmp/backup_${NAME}${DIRECTORY_STRING}_${CURRENT_DAY_TIMESTAMP}.7z"
    SUB_PACKAGE_BACKUP_PATH="${DIRECTORY}/*"

    7z a -t7z -mx9 ${SUB_PACKAGE_DESTINATION_PATH} -r ${SUB_PACKAGE_BACKUP_PATH} > /dev/null
done

###############################
#### CREATING MYSQL BACKUP ####
###############################

echo "[$(date)] Creating mysql dump..."

if [ "$MYSQL" = true ]; then
    MYSQL_DESTINATION_PATH="${HOME}/backup/tmp/backup_${NAME}(mysql)_${CURRENT_DAY_TIMESTAMP}.sql"

    mysqldump -u root -p${MYSQL_PASSWORD} --all-databases > ${MYSQL_DESTINATION_PATH} > /dev/null
fi

#############################################
#### CREATING MAIN PACKAGE AND UPLOADING ####
#############################################

echo "[$(date)] Creating main package..."

MAIN_PACKAGE_DESTINATION_PATH="${HOME}/backup/backup_${NAME}_${CURRENT_DAY_TIMESTAMP}.7z"
MAIN_PACKAGE_BACKUP_PATH="${HOME}/backup/tmp/*"

7z a -t7z -mx9 ${MAIN_PACKAGE_DESTINATION_PATH} ${MAIN_PACKAGE_BACKUP_PATH} > /dev/null

drive push -quiet -no-clobber

#################
#### CLEANUP ####
#################

echo "[$(date)] Cleaning up..."

rm -rf $HOME/backup/*

PACKAGES=$(drive list | grep -Po 'backup_vps[0-9]_[0-9]{12}')
PACKAGES_TO_DELETE=${PACKAGES}

for DAY_COUNT in $(seq 0 ${DAYS_TO_LIVE})
do
        TIMESTAMP=$(date -d "$DAY_COUNT day ago" +%d%m%Y)
        PACKAGES_TO_DELETE=$(echo "$PACKAGES_TO_DELETE" | grep -v ${TIMESTAMP})
done

for PACKAGE in ${PACKAGES_TO_DELETE}
do
        drive trash -quiet -matches ${PACKAGE}
done