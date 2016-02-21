# Yaesu FT-2D Files

## Overview

This folder contains Programming files for the FT-2D

Release: Draft Feb 16

The files were prepared using the RT-Systems FT-2D software with Data extracted from the WIA data set.

## Files

VKBV2D.rsf - basic settings file options
VKBV2D.FT2D - template used to import more memories, includes the bank names.

VKBVyymmmdd.FT2D - most recent RT Systems file
BACKUP.dat - generated SD card file.

### Radio Load Steps

backup.dat can be copied to a sd card and loaded to the radio.
* Insert and format an SD card in the radio.
* Use the 1. BACKUP> Write to SD> Write OK.
* Power off handset and unload card, insert into PC.
* The standard format on the radio sometimes sets a read only flag on files and directories.
* Right click/Properties on the FT2D Folder on the drive just mounted and unset the Read-Only Attribute
* The file just created will be x:\FT2D\BACKUP\BACKUP.dat copy or rename this file as a backup and move 
    the provided backup.dat to the same folder. Eject the card and load to radio.
* Load the backup   SD CARD> Backup > Read from SD> Read OK. [Sometimes this comes back straight away and it hasn't loaded. Repeat and it seems to load properly.. you will see the flashing Waiting message and SDSymbol]
* Configure your call sign and APRS
   - Both menus (Callsign and APRS) available from the DISP
   - [For some reason the callsign field is filled with spaces and you first have to go one rightarrow to wrap to the beginning of line.]
   - APRS call sign is APRS>23 CALLSIGN.
   - Testing APRS - the preconfigured manual position in "24 MY Position" is the Opera House.


The source files for RT Systems are VK2_yymondd.FT2D   and VKBVFT2D.rsf.

