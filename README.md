# Requirements

* [Drive](https://github.com/odeke-em/drive) - Google Drive push/pull cli
* [7-Zip](http://www.7-zip.org/download.html) - Compression app

# How to install

* Clone repository on your server
* Set executable permissions to backup script `chmod +x /path/to/repo/create_backup.sh`
* Create a directory in `$HOME/backup`
* Init `drive` in the backup directory
* Add `HOME` and `PATH` variables in your server's crontab
    * Make sure that `drive` binary is in the `PATH`
* Add an entry in your server's crontab, i.e. `00 04 * * * bash /path/to/repo/create_backup.sh`
    * Make sure you add all required parameters
    * Make sure that you run script with `bash /path/to/script.sh` syntax, not `sh /path/to/script.sh`
* Enjoy your backups!

# Usage

You can run the script with following parameters:

* `-n/--name` - server name, i.e. `-n vps1` (required)
* `-d/--directories` - backup directories, i.e. `-d /etc/hosts -d /var/www` (required)
    * if you want to pass multiple directories, pass each directory in separate `-d` parameter
    * directory files are taken recursively
* `-m/--mysql` - mysql backup switch
* `-mp/--mysql-password` - mysql root password

# Notes

Remember to create a `.driveignore` file with `tmp` entry in your Google Drive directory!

# Troubleshooting

## It produces weird output and doesn't work in general
Probably the script has been commited from a Windows machine with wrong encoding. Try to convert the script to be Unix compatible.

* `sudo apt-get install dos2unix`
* `dos2unix /path/to/repo/create_backup.sh`