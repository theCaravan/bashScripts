#!/bin/sh
echo -e "\nmaintenanceAuto script 1.1 - By the Caravan Systems\n"

currTime=$(date +%Y-%m-%d~%T~%Z)
logLoc="/home/sb5060tx/Logs/maintainanceAuto-sh/$currTime"

echo -e "\n--------------------------------------------"

echo -e "Creating a directory to output all logs\n"
mkdir -v $logLoc

echo -e "\n--------------------------------------------"

echo -e "Outputting the current size of the logs\n"
ls --format=verbose -RHhsa --si &> $logLoc"/sizeLs.txt"

echo -e "\n--------------------------------------------"

echo -e "Checking for failed stuff from system control\n"
sudo systemctl --failed 2>&1 | tee $logLoc"/systemctl.txt"
echo -e "Done"

echo -e "\n--------------------------------------------"

echo -e "\nChecking for looking at journal control"
sudo journalctl -p 0..3 -xn &> $logLoc"/journalctlDis.txt"
echo -e "Done"

echo -e "\n--------------------------------------------"

echo -e "\nLooking at SMART control"
sudo smartctl -H /dev/sda | tee $logLoc"/smartctl-H.txt"
echo -e "Done 01/07"
sudo smartctl -a /dev/sda &> $logLoc"/smartctl-a.txt"
echo -e "Done 02/07"
sudo smartctl -i /dev/sda &> $logLoc"/smartctl-i.txt"
echo -e "Done 03/07"
sudo smartctl -c /dev/sda &> $logLoc"/smartctl-c.txt"
echo -e "Done 04/07"
sudo smartctl --test=long /dev/sda &> $logLoc"/smartctl-long.txt"
echo -e "Done 05/07"
sudo smartctl --smart=on --offlineauto=on --saveauto=on /dev/sda &> $logLoc"/smartctl-offline.txt"
echo -e "Done 06/07"
sudo smartctl --info /dev/sda &> $logLoc"/smartctl-info.txt"
echo -e "Done 07/07"

echo -e "\n--------------------------------------------"

echo -e "\nLooking at this battery"
sudo upower --dump &> $logLoc"/upower.txt"
echo -e "Done"

echo -e "\n--------------------------------------------"


echo -e "\nNow saving stuff from pacman for debugging and recovery\n"

sudo pacman -Qqen > $logLoc"/pkglist.txt"
echo -e "\nDone 01/15"

sudo tar -cjf $logLoc"/pacman_database.tar.bz2" /var/lib/pacman/local
echo -e "\nDone 02/15"

sudo find /etc /opt /usr | sort > $logLoc"/all_files.txt"
echo -e "\nDone 03/15"

sudo pacman -Qlq | sed 's|/$||' | sort > $logLoc"/owned_files.txt"
echo -e "\nDone 04/15"

sudo comm -23 all_files.txt owned_files.txt | sort > $logLoc"/files_not_in_second.txt"
echo -e "\nDone 05/15"

sudo pacman -Qm | sort > $logLoc"/foreign_pkgs.txt"
echo -e "\nDone 06/15"

sudo pacman -Qn | sort > $logLoc"/native_pkgs.txt"
echo -e "\nDone 07/15"

sudo expac -S -H M '%k\t%n' | sort > $logLoc"/download_pkgs_size.txt"
echo -e "\nDone 08/15"

sudo expac -H M "%011m\t%-20n\t%10d" $( comm -23 <(pacman -Qqen|sort) <(pacman -Qqg base base-devel|sort) ) | sort -n | sort > $logLoc"/installed_pkgs_size"
echo -e "\nDone 09/15"

sudo expac --timefmt='%Y-%m-%d %T' '%l\t%n' | sort | tail -20ls | sort > $logLoc"/latest_date.txt"
echo -e "\nDone 10/15"

sudo expac --timefmt=%s '%l\t%n' | sort -n | tail -20 | sort > $logLoc"/latest_size.txt"
echo -e "\nDone 11/15"

sudo expac -HM "%-20n\t%10d" $( comm -23 <(pacman -Qqt|sort) <(pacman -Qqg base base-devel|sort) ) | sort > $logLoc"/installed_description.txt"
echo -e "\nDone 12/15"

sudo pacman -Qtdq | sort > $logLoc"/orphans.txt")
echo -e "\nDone 13/15"

sudo pacman -Qdttq | sort > $logLoc"/optional.txt")
echo -e "\nDone 14/15"

sudo find . -type l -! -exec test -e {} \; -print | sort > $logLoc"/broken_symlinks.txt")
echo -e "\nDone 15/15"

exit 0
