# This script creates .backup and .rsc files with current router configuration, 
# uploads them fo SFTP server and optionaly sends them via e-mail
#
# Scripts can't be uploaded in two folders of SFTP server, based on day of month. 
# First one (in days e.g. 1, 11 and 21) is unique for every router in organisation. 
# Another is the same for all routers.
#
# For unique folder uploads, naming convention is Router ID folowed by year, 
# month (as digits), date and time. For common folder, file name starts with 
# creation date and time, and ends with router ID.
#
# The idea behind this decision for different folders and file names, is to have
# different folders for every router but with small number of backup files, and
# one folder with many files from many routers, so they can be deleted quickly from one place only.
#
# Remember to add script via /System/Scripts WinBox menu and (optionaly, but recommended)
# to create a schedule for everyday run.


### Change variables
 
# Change brand and email
#=============================
:local branch "branch"
:local mail "my@email.com"

# hostname  from router identity or enter it manualy
:local hostname [/system identity get name]

# Sends email configuration (yes/no)
:local tomail "no"
 
# path to two sftp folders
#====================
:local ftpfolder1 "/home/mikrotik/backups/$branch/$hostname/"
:local ftpfolder2 "/home/mikrotik/backups/"
 
# sftp user, password and address
#====================
:local password "parolata_mi"
:local username "usera_mi"
:local ftpserver "stfp.servera.mi:porta_mu"

:global ftpfolder
:global backupfile

:log info "Mikrotik Backup Job Started ..."

# /system clock get date returns month as text. We convert text do digital representation
:local date [/system clock get date]
:local months ("jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec")
:local month ([:find $months [:pick $date 0 3 ]] + 1)
:if ($month < 10) do={:set $month ("0" . $month);}
 
# year and day ot month
:local year [:pick $date 7 11]
:local day [:pick $date 4 6]

 
# system time
:local time [/system clock get time]
:local hour [:pick $time 0 2]
:local minute [:pick $time 3 5]
 
# Days to save in "personal" folder
# You can add and branch in backupfile. e.g. :global backupfile "$year-$month-$day_$hour-$minute_$hostname_$branch"
:if ($day != "01" && $day != "11" && $day !="21") do {
   :global ftpfolder $ftpfolder2
   :global backupfile "$year-$month-$day_$hour-$minute_$hostname"
} else {
   :global ftpfolder $ftpfolder1
   :global backupfile "$hostname_$year-$month-$day_$hour-$minute"
}
 
# Creates .backuo and .rsc files
:log info "Creating Backup ... "
export file="$backupfile" show-sensitive
/system backup save name="$backupfile"
:delay 5s
:log info "Backup Created Successfully"
 
 
# Uploads files to SFTP server. You can'change to ftp, but remember to add mode=ftp
/tool fetch upload=yes url="sftp://$ftpserver$ftpfolder$backupfile.rsc" src-path="$backupfile.rsc" user=$username password=$password    

:delay 5s
:log info "Config File Uploaded Successfully"

/tool fetch upload=yes url="sftp://$ftpserver$ftpfolder$backupfile.backup" src-path="$backupfile.backup" user=$username password=$password    
:delay 5s
:log info "Backup File Uploaded Successfully"


# Will send email?
:if ($tomail = "yes") do {
    :log info "Start Sending Backup File via Email" 
    /tool e-mail send to=$mail subject="$hostname MikroTik Backup taken on $year/$month/$day/, at $hour:$minute" body="MikroTik $hostname email Backup"  file="$backupfile.backup"
    :delay 10s
    :log info "Backup mail sent to $mail..."
} else {
    :log info "Not sending backup's to emai..."
}

# Deletes created files
/file remove "$backupfile.rsc"
/file remove "$backupfile.backup"
:log info "Local Backup Files Deleted Successfully"
