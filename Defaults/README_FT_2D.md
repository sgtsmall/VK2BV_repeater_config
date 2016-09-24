# Yaesu FT-2D Files

## Overview

This folder contains Programming files for the Yaesu FT-2D

Release: MDDATEFLD

The files were prepared using the RT-Systems FT-2D software with Data extracted from the WIA data set.

## Files
* Configuration
    - VKBVREP.FT2D - most recent RT Systems file
    - BACKUP.dat - generated SD card file.
    - MEMORY.dat - generated file of Memories only.

* Build Files to create standard configuration

    - These files are only needed if you wish to create yor own config files from scratch

        - VKBV2D.FT2D - template used to import more memories, includes the bank names.
        - VKBV2D.rsf - basic settings file options
        - vkrepft-2drrts.csv - Output from the repeater configuration

### Radio Load Steps

    General Note: The user interface to the FT-2DR is inconsistent. Some operations can be completed by rotation of  the VFO(selector) knob and pressing DISP, whilst others require screen presses. In the following instructions the "OK" commands generally need to be pressed on the screen, however for reliability it is best to select it with the knob first! then press it.

* Steps to Load the config
* Create the directory structure on an SD card if you haven't already.
    - Insert and format an SD card in the radio.
    - Use the 1. BACKUP> Write to SD> Write OK.
This will create the folders and a backup file.

* Copy the new configuration to the card
    - Power off handset and unload card, insert into PC.
    - The standard format on the radio sometimes sets a read only flag on files and directories.
    - Right click/Properties on the FT2D Folder on the drive just mounted and unset the Read-Only Attribute
    - The file just created will be x:\\FT2D\\BACKUP\\BACKUP.dat copy or rename this file as a backup and move the provided backup.dat to the same folder.
    - Eject the card and load to radio.
    - Load the backup   SD CARD> Backup > Read from SD> Read OK. 
     [Sometimes this comes back straight away and it hasn't loaded.
     Repeat and it seems to load properly.. you will see the flashing
     Waiting message and SDSymbol]

* Configure your call sign and APRS
   - Both menus (Callsign and APRS) available from the DISP
   - [For some reason the callsign field is filled with spaces and you first have to go one rightarrow to wrap to the beginning of line.]
   - APRS call sign is APRS>23 CALLSIGN.
   - Testing APRS - the preconfigured manual position in "24 MY Position" is the Opera House.
* Enable BANK mode on VFO A and B
     You need to be in M R mode rather than Vfo mode, In VFO mode pressing Band cycles through the other bands from 540KHz up.
    - Press F/MW then BANK
    - To choose a bank Press BAND key then rotate through selection
    - In particular select Bank 14 APRS on VFO B for APRS.
* In this configuration GPS is OFF by Default and Memories are set to MID (Low 3) Power.

    > The MEMORY.dat can be stored in x:\\FT2D_MEMORY-CH\\MEMORY.dat and loaded by choosing the MEMORY CH from the SD CARD Menu. This will not assign the correct bank names.

    > To help find entries, switch to extended display (Hold the A/B button for several seconds). However this only allows 1 VFO to be active at a time.

### Structure of entries

The FT-2D supports 2 VFO's 'A' and 'B' with 2 Tranceivers. Both VFO's can process C4FM. Memories are available to both VFO's.

* In most sections entries are sorted by Callsign

* The FT-2DR supports 24 "Banks", a Memory can be assigned to multiple Banks.
    - For example the VK2RBV entries are assigned to banks 'Fav', 'SYDCBD' and 'C4FM'.
        - Fav A selection of Favourites
            - VK2RBV VK2ROT VK2RCG VK2RCF VK2RWI VK2RMP VK2RBM
        - SYDCBD Stations within 60km of Sydney
        - VK2 South Coast
        - VK2 North Coast
        - VK1 and 2 West
        - WICEN
        - MEL within 80km of Melbourne
        - VK3
        - VK4SE within 80 km of Tamborine
        - VK4
        - VK5-8
        - VK6
        - VK7
        - APRS including AU and ISS and other countries
        - Test
        - C4FM
        - Marine Fav
        - Marine
