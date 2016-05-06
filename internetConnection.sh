#!/bin/sh
echo -e "\ninternetConnection script 1.4 - By the Caravan Systems\n"

currTime=$(date +%Y-%m-%d~%T~%Z)
logLoc="/home/sb5060tx/Logs/internetConnection-sh/$currTime"

echo -e "\n--------------------------------------------"

echo -e "Creating a directory to output all logs\n"
mkdir -v $logLoc

echo -e "\n--------------------------------------------"

echo -e "Checking if we are connected to the internet\n"
x=`iw dev wlp2s0 link`

wget -q --spider http://google.com &> $logLoc"/spider.txt"

if [ $? -eq 0 ]; then
    spider="yes"
else
    spider="no"
fi

echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1 &> $logLoc"/getEcho.txt"

if [ $? -eq 0 ]; then
    get="yes"
else
    get="no"
fi

ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null && conn="yes" || conn="no" &> $logLoc"/pingScr.txt"

timeout --preserve-status 10 ping -vW 3 -w 3 www.google.com &> $logLoc"/ping.txt"

if [ "$?" == "0" ] && [ "$x" != "Not connected." ] && [ "$conn" = "yes" ] && [ "$spider" = "yes" ] && [ "$get" = "yes" ]
then
	echo -e "Looks like we are connected. Have a nice day\n"
	exit 0
fi

echo -e "Not connected. Solving the problem"

echo -e "\n--------------------------------------------"

echo -e "Killing dhcpcd\n"
sudo killall dhcpcd &> $logLoc"/killAllDh1.txt"
echo -e "dhcpcd is killed\n"

echo -e "Killing wpa_supplicant\n"
sudo killall wpa_supplicant &> $logLoc"/killAllWpa.txt"
echo -e "wpa_supplicant is killed"

echo -e "\n--------------------------------------------"

"/run/wpa_supplicant/wlp2s0" &> $logLoc"/runwlp2s0.txt"
if [ "$?" != "127" ]
then
        echo -e "\nWe cant run wpa_supplicant. It seems that there is a file telling us that it is in use."
        echo -e "Check to make sure that is not the case so that we can remove that file."
        echo -e "\nPress any key to confirm."
        read
        sudo mv /run/wpa_supplicant/wlp2s0 $logLoc"/wlp2s0"
        echo -e "That is done. wpa_supplicant should now work"
fi

echo -e "Restarting wpa_supplicant\n"
sudo wpa_supplicant -B -i wlp2s0 -c /etc/wpa_supplicant/example.conf &> $logLoc"/wpaSupp1.txt"

echo -e "\nRestarting dhcpcd\n"
sudo dhcpcd -t 5 wlp2s0 &> $logLoc"/dhcpcd1.txt"

if [ "$?" != "0" ]
then
	echo -e "dhcpcd cannot connect - killing it again\n"
	sudo killall dhcpcd &> $logLoc"/killAllDh2.txt"
	
	echo -e "\n--------------------------------------------"
		
	echo -e "Starting wpa_cli\n"
	sudo wpa_cli
	
	echo -e "\n--------------------------------------------"	

	echo -e "\nStarting dhcpcd again\n"
	sudo dhcpcd -t 7 wlp2s0 &>$logLoc"/dhcpcd2.txt"

	if [ "$?" == "0" ]
	then
		echo -e "Okay now dhcpcd is working\n"
	fi
fi

echo -e "Now checking again if we are connected to the internet\n"
x=`iw dev wlp2s0 link`

wget -q --spider http://google.com &> $logLoc"/spider2.txt"

if [ $? -eq 0 ]; then
    spider="yes"
else
    spider="no"
fi

echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1 &> $logLoc"/getEcho2.txt"

if [ $? -eq 0 ]; then
    get="yes"
else
    get="no"
fi

ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null && conn="yes" || conn="no" &> $logLoc"/pingScr2.txt"

timeout --preserve-status 10 ping -vW 3 -w 3 www.google.com &> $logLoc"/ping2.txt"

if [ "$?" == "0" ] && [ "$x" != "Not connected." ] && [ "$conn" = "yes" ] && [ "$spider" = "yes" ] && [ "$get" = "yes" ]
then
        echo -e "\n--------------------------------------------"
	echo -e "Looks like we are connected. Have a nice day\n"
        exit 0
fi

echo -e "\n--------------------------------------------"

echo -e "\nNot connected. Sorry\n"
exit 1
