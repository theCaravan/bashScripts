#!/bin/sh
echo -e "\npacmanUpdate 2.1 - By the Caravan Systems\n"

if [ "$(id -u)" == "0" ]; then
	echo -e "Sorry, we cannot run as root. We still need to call sudo, but run with a normal user instead" 
	exit 2
fi

currTime=$(date +%Y-%m-%d~%H%M%S~%Z)
logLoc="/home/sb5060tx/Logs/pacmanUpdate-sh/$currTime"

echo -e "--------------------------------------------"

echo -e "Creating a directory to output all logs\n"; mkdir -v $logLoc
echo -e "\n--------------------------------------------"

"/var/lib/pacman/db.lck" &> $logLoc"/dbLck127.txt"
if [ "$?" == "126" ]; then

	echo -e "\nWe cant run pacman. It seems that there is a file telling us that it is in use."
	echo -e "Check to make sure that is not the case so that we can remove that file."
	echo -e "\nPress any key to confirm."; read
	sudo mv /var/lib/pacman/db.lck $logLoc"/db.lck"
	echo -e "That is done. Pacman should now work"
fi 

echo -e "Calling pacman system upgrade\n"
trap 'echo -e "\n\nSkipping pacman system update"' SIGTERM SIGINT

sudo pacman -Syyuuv | tee $logLoc"/pacmanSyyuuv.txt"

trap SIGTERM SIGINT

echo -e "\n--------------------------------------------\nNow getting latest stuff from AUR\n"
aur="/home/sb5060tx/Logs/pacmanUpdate-sh/aur" 
aurLog=$aur"/"$currTime; mkdir $aurLog

pkgs=(package-query lib32-libjpeg6-turbo lib32-alsa-lib lib32-openal lib32-libstdc++5 lib32-libxv 
lib32-sdl lib32-libpulse ncurses5-compat-libs libcurl-compat ld-lsb libindicator-gtk2 
libdbusmenu-glib libdbusmenu-gtk2 libappindicator-gtk2 yaourt lib32-gtk2 lib32-libxt google-chrome 
vivaldi yaourt teamviewer libpng12 android-studio tor-browser-en android-sdk ttf-ms-fonts 
android-sdk-platform-tools jdk viber libdbusmenu-glib xnviewmp qbittorrent-stable-git popcorntime-bin ttf-roboto 
grub-customizer google-chrome-dev google-earth xflux grub2-theme-archlinux 
google-chrome-beta laptop-mode-tools fluxgui yaourt-gui speedometer systemd-manager-git ttf-mac-fonts jdk7 p7zip-gui geany-themes ttf-win7-fonts acroread android-studio)

# manually update intellij, vivaldi-ffmpeg-codecs

for pkg in ${pkgs[*]}; do
	
	aurpkg=$aur"/"$pkg; mkdir $aurpkg &> $aurLog"/mkdir.txt"
	echo -e "\n--------------------------------------------\nAUR - $pkg\n"
	trap 'echo -e "\n\nSkipping update of $pkg"; continue' SIGTERM SIGINT
	sudo rm $aur/$pkg.tar.g*
	cd $aur; wget "https://aur.archlinux.org/cgit/aur.git/snapshot/$pkg.tar.gz" -v &> $aurLog"/wget-$pkg.txt"
	
	if [ "$?" = "0" ]; then
		echo "Downloaded with no errors $pkg"
	
		cd $aur; tar -xvf $pkg.tar.gz &> $aurLog"/tar-xvf-$pkg.txt"

		if [ "$?" = "0" ]; then
                        echo -e "\nSuccessfully extracted $pkg with no errors\n"
                else
                        echo -e "\nSorry, an error was encountered in extracting $pkg"
                        exit 1
                fi
		
		cd $pkg; cp PKGBUILD $aurLog"/"$pkg".PKGBUILD"; makepkg -sri | tee $aurLog"/makepkg-sri-$pkg.txt"; cd ..
		trap SIGTERM SIGINT

		if [ "$?" = "0" ]; then
			echo -e "\n\nSuccessfully installed $pkg with no errors"
		else
			echo -e "\n\nSorry, an error was encountered in installing $pkg"
			exit 1
		fi
	
	else
		echo "Error found in downloading $pkg"
		echo "Skipping $pkg" 
	fi
done

if [ $(date +%d) = "05" ]; then

	echo -e "\nIt is the fifth of the month, so it is time to do some optimizations"
	echo -e "\nPress any key to confirm"; read
	sudo pacman-optimize 2>&1 | tee $logLoc"/pacmanOptimize.txt"
fi	

"/etc/pacman.d/mirrorlist.pacnew" &> $logLoc"/mirrorlist127.txt"
if [ "$?" != "127" ]; then

	echo -e "\nPacman apparently gave us a new mirror list"
	echo -e "You need to work on it so that we can overwrite the old one"
	echo -e "\nPress any key to confirm, type n to skip"
	read confirm
	
	if [ "$confirm" == "n" ]; then 
		exit 0
	fi
	
	sudo nano "/etc/pacman.d/mirrorlist.pacnew"
	
	echo -e "\nNow overwriting and archiving mirrorlists"
	sudo mv /etc/pacman.d/mirrorlist $logLoc"/pacmanOldMirrorList"
	sudo mv /etc/pacman.d/mirrorlist.pacnew /etc/pacman.d/mirrorlist
	sudo cp /etc/pacman.d/mirrorlist $logLoc"/pacmanNewMirrorList"
	echo -e "\nDone. The new mirrorlists should be in effect."
fi

exit 0
