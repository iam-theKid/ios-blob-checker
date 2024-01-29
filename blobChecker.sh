#!/usr/bin/env sh
#!/bin/bash

set -e

osversion=$(sw_vers | grep 'ProductVersion' | cut -d ':' -f2 | cut -d ' ' -f2)
cd "`dirname "$0"`"
binsDir=$(echo $(pwd)\/bins\/)
chmod -R 755 $binsDir 

if [[ $osversion =~ 10.13.* ]]; then img4toolV="img4tool10.13" ; else img4toolV="img4tool10.15" ; fi

function blobChecker {
    clear
    printf '\e[8;29;120t'
    echo "\033[32m\n
                         ______  _       _       _______ _                 _                 
                        (____  \| |     | |     (_______) |               | |                
                         ____)  ) | ___ | |__    _      | |__  _____  ____| |  _ _____  ____ 
                        |  __  (| |/ _ \|  _ \  | |     |  _ \| ___ |/ ___) |_/ ) ___ |/ ___)
                        | |__)  ) | |_| | |_) ) | |_____| | | | ____( (___|  _ (| ____| |    
                        |______/ \_)___/|____/   \______)_| |_|_____)\____)_| \_)_____)_|    \n"                                                                                  
        
            echo "
                        --------------------------------------------------------------------\n
                                                                               by iam-theKid\n"
    echo "\033[32m --- Please drag and drop the SHSH / SHSH2 file that you want to validate into this terminal window and press enter: \033[0m"
    read blobFile
    echo "\033[32m\n --- Now, let me know the device identifier (ex. iPhone10,4 or iPad7,6): \033[0m" && read deviceid
    echo "\033[32m\n --- Validate blob against which iOS version(s)? Exact version is not required! (ex: 15, 15.3, 15.3 beta ): \033[0m" && read iosVersion
    echo "\n"

    blobFile=$(echo "$blobFile" | tr -d "'")
    ecid=$($binsDir/$img4toolV -s "$blobFile" | grep "ECID" | cut -c13-)
    cp "$blobFile" "$ecid.shsh"

    if [ -f $iosLists.txt ]; then rm -f $iosLists.txt; fi
    if [ -f "BuildManifest.plist" ]; then rm -f "BuildManifest.plist"; fi

    echo "Building iOS versions list..."
    curl -sL "https://api.ipsw.me/v4/device/$deviceid?type=ipsw" | $binsDir/jq '.firmwares | .[] | select(.version | test("'$iosVersion'")) | .version,.url,.buildid' | cut -d '"' -f2 | while read line ; read line2 ; read line3 ; do echo "$line|$line2|$line3" >> $iosLists.txt ; done
    echo "iOS release versions captured..."
    if [[ $deviceid =~ iPhone* ]]; then deviceClass="iPhone"; elif [[ $deviceid =~ iPad* ]]; then deviceClass="iPad"; fi
    majorversion=$(echo $iosVersion | sed 's/\..*//'); betaUrl="https://theapplewiki.com/wiki/Beta_Firmware/$deviceClass/$majorversion.x"
    curl -sL "$betaUrl"  | grep -Eo ".*${deviceid}.*" -A 4 | grep 'class="external text" href="' | sed 's/\<td\>\<a rel\=\"nofollow\" class\=\"external text\" href\=\"//' | sed 's/ipsw.*/ipsw/' | \
        while read line; do \
            version=$(echo "$line" | sed "s/.*$majorversion/$majorversion/" | sed "s/_.*//"); \
            bid=$(echo "$line" | sed "s/.*$majorversion/$majorversion/" | sed "s/_Restore.ipsw//" | sed "s/.*_//"); \
            echo "$version|$line|$bid" >> $iosLists.txt; \
        done
    echo "iOS beta versions captured..."
    curl -sL "https://api.ipsw.me/v4/device/$deviceid?type=ota" | $binsDir/jq '.firmwares | .[] | select(.version | test("'$iosVersion'")) | .version,.url,.buildid' | cut -d '"' -f2 |  while read line ; read line2 ; read line3 ; do echo "$line|$line2|$line3" | sed 's/9.9.//' >> $iosLists.txt ; done
    echo "iOS ota versions captured..."
 
    echo "Validating blobs...\n"
    cat "$iosLists".txt | while read line 
    do 
        if grep -q "zip" <<< $line; then
            $binsDir/pzb -g AssetData/boot/BuildManifest.plist $(echo $line | grep "http" | cut -d "|" -f2) > /dev/null
            ota="OTA"
        else
            $binsDir/pzb -g BuildManifest.plist "$(echo $line | grep "http" | cut -d "|" -f2)" > /dev/null
            ota=""
        fi 
        
        if [[ ! "$(bins/$img4toolV --verify BuildManifest.plist -s $ecid.shsh | grep 'APTicket' | cut -d ' ' -f4)" == "GOOD!" ]]; then
            echo "Version: $(echo $line | grep "http" | cut -d "|" -f1) "$ota" BuildNumber: $(echo $line | grep "http" | cut -d "|" -f3) Result: ""\033[91m$(bins/$img4toolV --verify BuildManifest.plist -s $ecid.shsh | grep 'APTicket' | cut -d "]" -f2)""\033[0m"
        else
            echo "Version: $(echo $line | grep "http" | cut -d "|" -f1) "$ota" Result: \033[32m""$(bins/$img4toolV --verify BuildManifest.plist -s $ecid.shsh | grep 'APTicket' | cut -d "]" -f2)"
            bins/$img4toolV --verify BuildManifest.plist -s $ecid.shsh | grep 'TssAuthority\|IM4M is valid\|BuildNumber\|BuildTrain\|DeviceClass\|RestoreBehavior\|Variant'
            echo "Download Link: " "$(echo $line | grep "http" | cut -d "|" -f2)"
            echo "\nSaving blob file as \""$ecid"_"$deviceid"_"$(echo $line | grep "http" | cut -d "|" -f1)"_"$(echo $line | grep "http" | cut -d "|" -f3)".shsh\""
            echo "\033[0m"
            mv -f $ecid.shsh "$ecid"\_"$deviceid"\_"$(echo $line | grep "http" | cut -d "|" -f1)"\_"$(echo $line | grep "http" | cut -d "|" -f3)".shsh
            rm -f BuildManifest.plist    
            read -p "Press any key to exit..."   
            exit
        fi
    done
    rm -f BuildManifest.plist    
    read -p "Press any key to exit..."   
    exit
}

blobChecker
