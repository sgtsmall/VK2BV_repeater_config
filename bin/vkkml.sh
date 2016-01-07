#!/bin/bash
# https://dl.dropboxusercontent.com/u/22223943/vkrep2google.kmz
body() {
    IFS= read -r header
    printf '%s\n' "$header"
    "$@"
}

#cd ~/Onedrive/wia
mkdir work
rm work/*
cd work
curl -o repdown.dat http://www.wia.org.au/members/repeaters/data/documents/Repeater%20Directory%20160103.csv
tr -d '\r' < repdown.dat > repdowntext.dat
gsed -f ../bin/wiahead.gsed repdowntext.dat > wiarepdir.csv
curl -o vkrep2google.zip https://dl.dropboxusercontent.com/u/22223943/vkrep2google.kmz
unzip vkrep2google.zip
let i=`awk '/<kml/{ print NR; exit }' vkrep2google.kml`
let j=`awk '/<Document>/{ print NR; exit }' vkrep2google.kml`+1
let k=`awk '/<name>Amateur Repeaters/{ print NR; exit }' vkrep2google.kml`-2
let l=`awk '/kml>/{ print NR; exit }' vkrep2google.kml`
range=`echo "$i"d\;"$j","$k"d\;"$l"d`
#echo $range
echo "starting the sed of vkrep2work.kml"
sed -e $range vkrep2google.kml  > vkrep2work.kml
#
# remove the line feed in the repeater names
#

echo "starting the ex of vkrep2work.kml"
ex -c "%g/name></j" -c "wq" vkrep2work.kml
#
# apply several cleanups 
#
echo "starting the sed of vkrep2work.kml vkrep.xml"
sed -f ../bin/2mdkml.sed vkrep2work.kml |xmllint --format - > vkrep.xml
#
# do some distance calculations and tiny amount od additional cleanup
#
cd ..
echo "starting vkrep3.pl create vkrep.csv extracted data from kml"
./bin/vkrep3.pl work/vkrep.xml | sed -f bin/vkrep.sed  |sort > vkrep.csv
echo "starting vkrep4.pl create vkrepdir.csv wialist merged with kml and distance"
./bin/vkrep4.pl work/wiarepdir.csv vkrep.csv|sed -f bin/vkrep.sed  |sort > vkrepdir.csv
sort --field-separator=',' --key=7,7 --key=5g,5 vkrepdir.csv > work/sortvkrepdir.csv
#
# get the local entries file vkrepstd from defaults
cp defaults/vkrepstd.srccsv work/vkrepstd.csv
echo "starting the create of vkrepftmerge.csv"
# reads vkrepdir and vkrepstd (simplex and other local)
./bin/vkrep27wft.pl work/sortvkrepdir.csv work/vkrepstd.csv work/vkrepftmerge.csv 
echo "starting the create of vkrepdsmerge.csv"
# reads vkrepdir and vkrepstd (simplex and other local)
./bin/vkrep27wds.pl work/sortvkrepdir.csv work/vkrepstd.csv work/dstemp.csv
cat work/dstemp.csv | body sort --field-separator=',' --key=3,3 > work/vkrepdsmerge.csv 
echo "starting vkrepft-2dr.pl create of vkrepft-2dr.csv"
./bin/vkrepft-2dr.pl work/vkrepftmerge.csv vkrepft-2dr.csv
echo "starting vkrepft-1dradms6.pl create of vkrepft-1dr.csv"
./bin/vkrepft-1dradms6.pl work/vkrepftmerge.csv vkrepft-1dradms6.csv
echo "starting vkrepftm-400dradms7.pl create of vkrepftm-400dra.csv and vkrepftm-400drb.csv"
./bin/vkrepftm-400dradms7.pl work/vkrepftmerge.csv vkrepftm-400dradms7
echo "starting vkrepicom51x.pl create of YYYYMMDDgnn.csv"
./bin/vkrepicom51x.pl work/vkrepdsmerge.csv 20160103
