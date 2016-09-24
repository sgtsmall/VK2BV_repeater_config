# MD 380 Files

## Overview

This folder contains Programming files for the Tytera MD 380 radios

Release: MDDATEFLD

The files were prepared using the Tytera MD 380 V1.30 and the CPS utilities software with Data extracted from the WIA data set.

## Files
* Configuration
    - MD380_VK2BV.rdt - most recent MD 380 file, YOU MUST change your radio id.


* Build Files to create standard configuration

    - contacts.csv - Output from the marc database
    - cont-n0gsg.csv - Output from the marc database
    - chan.csv - output from the repeater configuration
    - scan.csv - output from the repeater configuration
    - zone.csv - output from the repeater configuration

## Notes

    Still early days here
    
    Radio Buttons 
        Top Short - Scan, Long - Talkaround
        Bot Short - Monitor, Long - Power
    
    NB: You can't change Monitor (or Power?) when scanning.
    
    This is a fairly automated build so once you get the rdt file you should change a few things.
     * Your ID and similar fields in General Settings.
     
     You probably want to move some other channels into the VK2RCG zone (e.g. ROT,ROZ, RCG FM).
     
     The tools I am using:-
        - Tyt MD-380 CPS 
        - ContactManagerV132.exe from n0gsg
        - CPS Programmer V0-25 from DL5MCC
        I also originally used 
        G4EML tools, but I generate all that data now.

