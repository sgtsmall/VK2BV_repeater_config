# Installation

## General unix and Linux (OSX)
 The scripts here are using bash, curl, awk, gsed, sed, sort, ex, tr, perl (and probably some other bits) I will try and migrate most to perl

It was developed with the QAN (Quick and Nasty) principle over a couple of years, and finally got out of hand!

Note that despite this it runs in about 3 seconds on my mac (2.5 seconds is the curl get of files)

### Apr-16 Now uses pandoc and BasicTeX on my mac to generate documentation
Start with pandoc (available for most platforms) then find how it generates pdf.

## Install some perl modules
Ham::Locator
Geo::Direction::Distance
Text::CSV_XS
XML::LibXML
List::MoreUtils

### ubuntu
sudo apt-get install libtext-csv-xs-perl  libxml-libxml-perl
cpan   Ham::Locator Geo::Direction::Distance
cd /usr/bin
sudo ln -s /bin/sed gsed
and some other bits

* I just run and have a quick look at errors until things are fixed up
