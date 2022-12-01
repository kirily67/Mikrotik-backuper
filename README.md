# Mikrotik backuper

This script creates .backup and .rsc files with current router configuration, uploads them fo SFTP server and optionaly sends them via e-mail

Scripts can't be uploaded in two folders of SFTP server, based on day of month. First one (in days e.g. 1, 11 and 21) is unique for every router in organisation. Another is the same for all routers.

For unique folder uploads, naming convention is Router ID folowed by year, month (as digits), date and time. For common folder, file name starts with creation date and time, and ends with router ID. 

The idea behind this decision for different folders and file names, is to have different folders for every router but with small number of backup files, and one folder with many files from many routers, so they can be deleted quickly from one place only.

Remember to add script via /System/Scripts WinBox menu and (optionaly, but recommended) to create a schedule for everyday run. 
