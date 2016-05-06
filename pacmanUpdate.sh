#!/bin/sh
echo -e "\npacmanUpdate 1.0 - By the Caravan Systems\n"

currTime=$(date +%Y-%m-%d~%T~%Z)
logLoc="/home/sb5060tx/Logs/pacmanUpdate-sh/$currTime"

echo -e "\n--------------------------------------------"

echo -e "Creating a directory to output all logs\n"
mkdir -v $logLoc

echo -e "\n--------------------------------------------"

"/var/lib/pacman/db.lck" &> $logLoc"/dbLck127.txt"
if [ "$?" != "127" ]
then
	echo -e "\nWe cant run pacman. It seems that there is a file telling us that it is in use."
	echo -e "Check to make sure that is not the case so that we can remove that file."
	echo -e "\nPress any key to confirm."
	read
	sudo mv /var/lib/pacman/db.lck $logLoc"/db.lck"
	echo -e "That is done. Pacman should now work"
fi 

echo -e "Calling pacman system upgrade\n"
sudo pacman -Syyuuv --debug | tee $logLoc"/pacmanSyyuuvDebug.txt"


if [ $(date +%d) = "05" ]
then
	echo -e "\nIt is the fifth of the month, so it is time to do some optimizations"
	echo -e "\nPress any key to confirm"
        read
	sudo pacman-optimize 2>&1 | tee $logLoc"/pacmanOptimize.txt"
fi	

"/etc/pacman.d/mirrorlist.pacnew" &> $logLoc"/mirrorlist127.txt"
if [ "$?" != "127" ]
then
	echo -e "\nPacman apparently gave us a new mirror list"
	echo -e "You need to work on it so that we can overwrite the old one"
	echo -e "\nPress any key to confirm"
	read
	sudo nano "/etc/pacman.d/mirrorlist.pacnew"
	
	echo -e "\nNow overwriting and archiving mirrorlists"
	sudo mv /etc/pacman.d/mirrorlist $logLoc"/pacmanOldMirrorList"
	sudo mv /etc/pacman.d/mirrorlist.pacnew /etc/pacman.d/mirrorlist
	sudo mv /etc/pacman.d/mirrorlist $logLoc"/pacmanNewMirrorList"
	echo -e "\nDone. The new mirrorlists should be in effect."
fi

exit 0
