#!/bin/sh
echo -e "\ninternetConnection script 1.5.1 - By the Caravan Systems\n"

currTime=$(date +%Y-%m-%d~%T~%Z)
logLoc="/home/sb5060tx/Logs/internetConnection-sh/$currTime"

echo -e "\n--------------------------------------------"

echo -e "Creating a directory to output all logs\n"
mkdir -v $logLoc

echo -e "\n--------------------------------------------"

echo -e "Checking if we are connected to the internet\n"

###################################################

echo -e "\nRunning Test 1 of 3"
timeout --preserve-status 4 wget -q --spider http://google.com &> $logLoc"/testOne.txt"

if [ $? -eq 0 ]; then
    testOne="Pass"
else
    testOne="Fail"
fi
echo -e "Finish Test 1 of 3 - Result is $testOne"

###################################################

echo -e "\nRunning Test 2 of 3"
timeout --preserve-status 4 ping -vW 3 -w 3 www.google.com &> $logLoc"/testTwo.txt"

if [ $? -eq 0 ]; then
    testTwo="Pass"
else
    testTwo="Fail"
fi
echo -e "Finished Test 2 of 3 - Result is $testTwo"

####################################################

echo -e "\nRunning Test 3 of 3"

if [ "`iw dev wlp2s0 link`" != "Not connected." ]; then
    testThree="Pass"
else
    testThree="Fail"
fi

echo -e "Finished Test 3 of 3 - Result is $testThree"

#####################################################

if [ "$testOne" = "Pass" ] && [ "$testTwo" = "Pass" ] && [ "$testThree" = "Pass" ]
then
	echo -e "\nLooks like we are connected. Have a nice day\n"
	exit 0
fi

echo -e "Not connected. Solving the problem"

echo -e "\n--------------------------------------------"

echo -e "Killing dhcpcd\n"
sudo killall dhcpcd &> $logLoc"/killAllDh1.txt"
echo -e "dhcpcd is killed\n"

########################################################

echo -e "Killing wpa_supplicant\n"
sudo killall wpa_supplicant &> $logLoc"/killAllWpa.txt"
echo -e "wpa_supplicant is killed"

echo -e "\n--------------------------------------------"

echo -e "Restarting wpa_supplicant\n"
sudo wpa_supplicant -B -i wlp2s0 -c /etc/wpa_supplicant/example.conf &> $logLoc"/wpaSupp1.txt"

########################################################

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

###################################################

echo -e "\nRunning Test 1 of 3"
timeout --preserve-status 4 wget -q --spider http://google.com &> $logLoc"/testOne2.txt"

if [ $? -eq 0 ]; then
    testOne="Pass"
else
    testOne="Fail"
fi
echo -e "Finish Test 1 of 3 - Result is $testOne"

###################################################

echo -e "\nRunning Test 2 of 3"
timeout --preserve-status 4 ping -vW 3 -w 3 www.google.com &> $logLoc"/testTwo.txt"

if [ $? -eq 0 ]; then
    testTwo="Pass"
else
    testTwo="Fail"
fi
echo -e "Finished Test 2 of 3 - Result is $testTwo"

####################################################

echo -e "\nRunning Test 3 of 3"

if [ "`iw dev wlp2s0 link`" != "Not connected." ]; then
    testThree="Pass"
else
    testThree="Fail"
fi

echo -e "Finished Test 3 of 3 - Result is $testThree"

#####################################################

if [ "$testOne" = "Pass" ] && [ "$testTwo" = "Pass" ] && [ "$testThree" = "Pass" ] 
then
        echo -e "\nLooks like we are connected. Have a nice day\n"
        exit 0
fi


echo -e "\n--------------------------------------------"

echo -e "\nNot connected. Sorry\n"
exit 1
