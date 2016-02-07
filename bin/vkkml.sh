#!/bin/bash
# https://dl.dropboxusercontent.com/u/22223943/vkrep2google.kmz
body() {
    IFS= read -r header
    printf '%s\n' "$header"
    "$@"
}
usage() {
echo "Usage: $(basename $0) -r repdate [-h]|[-c]|[-i]|[-y]"
echo "  -r  repdate is YYMMDD from wia website"
echo "  -h This help text"
echo "  -c Suppress Chirp Files"
echo "  -i Suppress Icom Files"
echo "  -y Suppress Yaesu Files"

echo ""
echo "e.g. ...../Repeater Directory 160103.csv   -r 160103"
}

mand=
if [ "$1" != "" ]; then
    outicom=0
    outyaesu=0
    outchirp=0
    publish=0
    args=$(getopt r:chiyp $*)
    if [ $? != 0 ] ; then usage ; exit 0 ; fi

    set -- $args

    for i
    do 
        case "$i"
        in
            -r ) repdate=$2 ; mand=0 ; shift 2 ;;
            -h ) usage ; exit 0 ;;
            -c ) outchirp= ; shift ;;
            -i ) outicom= ; shift ;;
            -y ) outyaesu= ; shift ;;
            -p ) publish= ; shift ;;
        esac
    done
fi
if [ ! -n "$mand" ] ; then 
   usage 
   exit 0 
fi
#
#exit
#cd ~/Onedrive/wia
mkdir work
rm work/*
cd work
curl -o repdown.dat http://www.wia.org.au/members/repeaters/data/documents/Repeater%20Directory%20$repdate.csv
tr -d '\r' < repdown.dat > repdowntext.dat
gsed -f ../bin/wiahead.gsed repdowntext.dat > wiarepdir.csv
curl -o vkrep2google.zip https://dl.dropboxusercontent.com/u/22223943/vkrep2google.kmz
unzip vkrep2google.zip
# now get rid of most of the file 
    let i=`awk '/<kml/{ print NR; exit }' vkrep2google.kml`
    let j=`awk '/<Document>/{ print NR; exit }' vkrep2google.kml`+1
    let k=`awk '/<name>Amateur Repeaters/{ print NR; exit }' vkrep2google.kml`-2
    let l=`awk '/kml>/{ print NR; exit }' vkrep2google.kml`
    range=`echo "$i"d\;"$j","$k"d\;"$l"d`
#echo $range
echo "starting the sed of vkrep2work.kml"
# 
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
#
    sed -f ../bin/2mdkml.sed vkrep2work.kml |xmllint --format - > vkrep.xml
#
# do some distance calculations and tiny amount of additional cleanup
#
cd ..
echo "starting vkrep3.pl create vkrep.csv extracted data from kml"
    ./bin/vkrep3.pl work/vkrep.xml | sed -f bin/vkrep.sed  |sort > vkrep.csv
echo "starting vkrep4.pl create vkrepdir.csv wialist merged with kml and distance"
    ./bin/vkrep4.pl work/wiarepdir.csv vkrep.csv|sed -f bin/vkrep.sed  |sort > vkrepdir.csv
#
# This is callsign then input frequency
sort --field-separator=',' --key=7,7 --key=5g,5 vkrepdir.csv > work/sortvkrepdir.csv
#
# get the local entries file vkrepstd from defaults
cp defaults/vkrepstd.srccsv work/vkrepstd.csv
if [ -n "$outyaesu" ] ;  then 
    echo "starting the create of vkrepftmerge.csv"
# reads vkrepdir and vkrepstd (simplex and other local)
        ./bin/vkrep27wft.pl work/sortvkrepdir.csv work/vkrepstd.csv work/vkrepftmerge.csv 
    echo "starting vkrepft-2dr.pl create of vkrepft-2dr.csv"
        ./bin/vkrepft-2dr.pl work/vkrepftmerge.csv vkrepft-2dr.csv
    echo "starting vkrepft-1dradms6.pl create of vkrepft-1dr.csv"
        ./bin/vkrepft-1dradms6.pl work/vkrepftmerge.csv vkrepft-1dradms6.csv
    echo "starting vkrepftm-400dradms7.pl create of vkrepftm-400dra.csv and vkrepftm-400drb.csv"
        ./bin/vkrepftm-400dradms7.pl work/vkrepftmerge.csv vkrepftm-400dradms7
else
    echo "suppressed yaesu"
fi
if [ -n "$outicom" ] ;  then 
    echo "starting the create of vkrepdsmerge.csv"
# reads vkrepdir and vkrepstd (simplex and other local)
        ./bin/vkrep27wds.pl work/sortvkrepdir.csv work/vkrepstd.csv work/dstemp.csv
        cat work/dstemp.csv | body sort --field-separator=',' --key=3,3 > work/vkrepdsmerge.csv 
    echo "starting vkrepicom51x.pl create of YYYYMMDDgnn.csv"
        ./bin/vkrepicom51x.pl work/vkrepdsmerge.csv 20$repdate
else
   echo "suppressed icom"
fi  
if [ -n "$outchirp" ] ;  then 
    echo "starting the create of vkrepchmerge.csv [coming soon!!]"
## reads vkrepdir and vkrepstd (simplex and other local)
#        ./bin/vkrep27wch.pl work/sortvkrepdir.csv work/vkrepstd.csv work/chtemp.csv
#        cat work/chtemp.csv | body sort --field-separator=',' --key=3,3 > work/vkrepchmerge.csv 
#    echo "starting vkrepchirp.pl create of vkrepchirp.csv"
#        ./bin/vkrepchirp.pl work/vkrepchmerge.csv $repdate_chirp
else
   echo "suppressed chirp"
fi 
if [ -n "$publish" ] ;  then 
    echo "starting the publish"
else
    echo "suppressed publishing"
fi