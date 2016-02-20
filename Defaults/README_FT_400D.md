# Yaesu FTM-400D

##  Overview

This folder contains Programming files for the FTM-400D

Release: Draft Jan 16


The files were prepared using the Yaesu FTM-400D software with Data extracted from the WIA data set.

## Files

### Radio Load Steps

Files can be copied to the sd card and loaded to the radio.
* Insert and format an SD card in the radio.
* Use the 1. BACKUP> Write to SD> Write OK.
* Power off radio and unload card, insert into PC.

The file structure on the SD card should be similar to this area.
For a new radio you can replace everything under BACKUP directory on the SD with this one. In other circumstances you may want to just use the new BACKUP/MEMORY/MEMFTM400D.dat

* “I thought CLONE/CLNMFT400D.dat would replace both Memory and Setup but it doesn’t seem to… more investigation required ”

Eject the card and load to radio.
* Load the Card 
new radio - do setup first
   DISP/SETUP>SD CARD> BACKUP > Read from SD(press twice)> SETUP(Twice).
reboots
* Configure your call sign and APRS
   - APRS call sign is APRS>23 CALLSIGN.

load MEMORY
   DISP/SETUP>SD CARD> BACKUP > Read from SD(press twice)> MEMORY(Twice).


The source files for ADMS7 are FTM-400DVKBV.FTM400D.

