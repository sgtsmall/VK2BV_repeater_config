# Icom ID-51A Plus Files

## Overview

This folder contains Programming files for the Icom ID-51A Plus

Release: MDDATEFLD

The files were prepared using the RT-Systems FT-2D software with Data extracted from the WIA data set.

## Files
* Configuration
    - 51P_AUS_VK2BV.icf - most recent icom file

* Build Files to create standard configuration
    - icomDStarplus.zip - Output from the repeater configuration
        - icombankX.csv, icomgX.csv, icommemX.csv

### Radio Load Steps

* Steps to Load the config
* Create the directory structure on an SD card if you haven't already.
    - Insert and format an SD card in the radio.
    - Menu>SD Card>Save Setting>New File>
This will create the folders and a backup file.

* Copy the new configuration to the card
    - Power off handset and unload card, insert into PC.
    - The file just created will be ID-51/Setting/setyyyymmdd.icf 
    - Copy the file 51P_AUS_VK2BV.icf onto the SD
    - Eject the card and load to radio.
    - Menu>SD Card>Load Setting> 51P_AUS_VK2BV.icf
        - Except My Station (If your radio already has a setup)
        - Keep Skip Yes
        - Load Yes
    - Reset Radio (Power on/off)

* Configure your radio
        
* Enable BANK mode on VFO A and B
    - Choose VFO A (short press om MAIN to swap)
    - Press M/CALL to get to MR (memory) mode.
    - Press Quick then select Bank Select > B:SYDCBD
    - The VFO will wrap around the memories in Bank B (about 45)
    - Repeat for VFO B
    > The radio is now ready to operate in Bank mode on both VFO's
    - Change back to VFO A
    - change to  [DR] "Digital Mode" and adjust TO and FROM values
        - To - change from "Local CQ" to "Your Call Sign" "Use Repeater" 
        - From - test near repeater.
    
    
### Structure of entries

The ID-51 supports 2 VFO's 'A' and 'B' with 1 Tranceivers. Both VFO's can process D-Star. Memories and banks are available to both VFO's.

* In most sections entries are sorted by Callsign

* The ID-51A supports 26 "Banks" (A-Z), a Memory can only be assigned to 1 bank.
    
    - A DStar entries
    - B SYDCBD Stations within 60km of Sydney
    - C VK2 South Coast
    - D VK2 North Coast
    - E VK1 and 2 West
    - F WICEN
    - G MEL within 80km of Melbourne
    - H VK3
    - I VK4SE within 80 km of Tamborine
    - J VK4
    - K VK5-8
    - L VK6
    - M VK7
    - N APRS including AU and ISS and other countries
    - O Test
    - X Marine
