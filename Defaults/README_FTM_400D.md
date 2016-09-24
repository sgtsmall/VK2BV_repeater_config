# Yaesu FTM-400D

##  Overview

This folder contains Programming files for the Yaesu FTM-400D

Release: MDDATEFLD


The files were prepared using the RT-Systems software with Data extracted from the WIA data set. (Import files for the Yaesu ADMS-7 software are also provided)

## Files

* Configuration
    - VKBVREP.FTM400 - most recent RT Systems file
    - CLNFTM400D.dat - generated SD card file.

    - VKBVREP.FTM400D - most recent Yaesu ADMS7 file

> This file was built for a FTM-400DR-AUS running main 2.1.
> Loading an incorrect CLN file can brick radios. (This also applies to firmware upgrades)

* Build Files to create standard configuration
    - RT-Systems
        - VKBV400.FTM400 - template used to import more memories
        - VKBV400.rsf - basic settings file options
        - vkrepftm-400drrtsa.csv - Output from the repeater configuration
        - vkrepftm-400drrtsa.csv - Output from the repeater configuration
    - Yaesu ADMS-7 
        - vkrepftm-400dradms7a.csv - Output from the repeater configuration
        - vkrepftm-400dradms7a.csv - Output from the repeater configuration

### Radio Load Steps

> I recommend actually dowloading your current config by cable or SD card and then importing the csv files into banda and bandb rather than using the CLNFTM400D.dat. Use the VKBV400.FTM400 and VKBV400.rsf files as a reference for a clean setup.

* Steps to Load the config
* Create the directory structure on an SD card if you haven't already.
    - Insert and format an SD card in the radio.
    - Use the 1. BACKUP> Write to SD> 
        - select ALL > OK to create CLNFTM400D.dat
This will create the folders and a clone and memories file.

* Copy the new configuration to the card
    - Power off radio and unload card, insert into PC.
    - The standard format on the radio sometimes sets a read only flag on files and directories.
    - Right click/Properties on the xxx Folder on the drive just mounted and unset the Read-Only Attribute
    - The file just created will be x:\\BACKUP\\CLONE\\CLNFTM400D.dat copy or rename this file as a backup and move the provided CLNFTM400D.dat to the same folder.
    - Eject the card and load to radio.
    - Load the clone 
    - Use the 1. BACKUP> Read from SD> 
        - select ALL > OK to read CLNFTM400D.dat

* Configure your call sign and APRS
    - If you load this CLN file it should prompt for a callsign on reboot.
    - Both menus (Callsign and APRS) available from the DISP
    - APRS - Modem and Auto Beacon are off in the config.
        - Menu 23. Callsign
        - Menu 5. Modem [OFF]/ON (ON means radio can start encoding and decoding)
        - Menu 15. Beacon TX - AUTO [OFF]/ON/Smart
* If mobile probably change DISP>DISPLAY>7 fromTime to VDD for voltage.        
* In this configuration GPS is ON by Default and VFO A and B memory entries are configured with MID power.

### Structure of entries

The FTM-400D supports 2 VFO's 'A' and 'B' with 2 Tranceivers. However only VFO 'A' can process C4FM. Each Band is allowed 500 entries.

* In most sections entries are sorted by Callsign

* Bank A memories are sorted:-
    - VK2RBV 7 (FM with TSQL 91.5)
    - VK2RBV 4 (FM with TSQL 91.5 Some Yaesu radios allow the specification of FM and C4FM with the memory entry, unfortunately the FTM don't)
    - A selection of Favourites
        - VK2RBV VK2ROT VK2RCG VK2RCF VK2RWI VK2RMP VK2RBM
    - Remaining stations within 60km of Sydney
    - VK2 South Coast
    - VK2 North Coast
    - VK1 and 2 West
    - VK3 within 80km of Melbourne
    - VK3
    - VK4 within 80 km of Tamborine
    - APRS including AU and ISS and other countries
    - SIMPLEX including WICEN
    - VK1,2,3,4 without a permanent location (usually WICEN repeaters)
    - Some test entries 

* Bank B memories are sorted:-
    - APRS AU
    - A selection of Favourites
        - VK2RBV VK2ROT VK2RCG VK2RCF VK2RWI VK2RMP VK2RBM
    - VK5
    - VK6
    - VK7
    - VK8
    - APRS including AU and ISS and other countries
    - SIMPLEX including WICEN
    - VK5,6,7,8 without a permanent location (usually WICEN repeaters)
    
    