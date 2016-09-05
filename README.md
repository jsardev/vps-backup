# Requirements

* [Drive](https://github.com/odeke-em/drive) - Google Drive push/pull cli
* [7-Zip](http://www.7-zip.org/download.html) - Compression app

# How to install

* Clone repository on your server
* Create a directory in ```$HOME/backup```
* Init drive in the backup directory
* Add an entry in your server's crontab, i.e. ```00 04 * * * sh /path/to/repo/create_backup.sh```
* Enjoy your backups!

# Notes

Remember to create a ```.driveignore``` file with ```/tmp``` entry in your Google Drive directory!
