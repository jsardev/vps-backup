# Requirements

* [Drive](https://github.com/odeke-em/drive) - Google Drive push/pull cli
* [7-Zip](http://www.7-zip.org/download.html) - Compression app

# How to install

* Clone repository on your server
* Create a directory in `$HOME/backup`
* Init drive in the backup directory
* Add `HOME` and `PATH` variables in your server's crontab, i.e. 
    * Make sure that `drive` binary is in one of the `PATH` directories
* Add an entry in your server's crontab, i.e. `00 04 * * * sh /path/to/repo/create_backup.sh`
* Enjoy your backups!

# Notes

Remember to create a `.driveignore` file with `tmp` entry in your Google Drive directory!

# Troubleshooting

## It produces weird output and doesn't work in general
Probably the script has been commited from a Windows machine with wrong encoding. Try to convert the script to be Unix compatible.

* `sudo apt-get install dos2unix`
* `dos2unix /path/to/repo/create_backup.sh`